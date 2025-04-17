```markdown
# ShellCtl 🚀

ShellCtl is an open‑source Bash script that lets you spin up multi‑connection reverse shells inside GNU screen. It watches a port, automatically re‑launches listeners when connections drop, and gives you easy commands to list, attach, and kill sessions. Perfect for pentesters, red‑teamers, or anyone needing reliable remote shell management.

---

## 📥 Installation

### 1. Using `curl` (or `wget`)

Download the `ShellCtl.sh` script to a system‑wide location and make it executable:

#### With `curl`
```bash
sudo curl -L https://github.com/YourUser/ShellCtl/raw/main/ShellCtl.sh -o /usr/local/bin/ShellCtl
sudo chmod +x /usr/local/bin/ShellCtl
```

#### With `wget`
```bash
sudo wget https://github.com/YourUser/ShellCtl/raw/main/ShellCtl.sh -O /usr/local/bin/ShellCtl
sudo chmod +x /usr/local/bin/ShellCtl
```

Now you can run `ShellCtl` from anywhere!

### 2. From Git

Alternatively, clone the repository and install manually:
```bash
git clone https://github.com/YourUser/ShellCtl.git
cd ShellCtl
sudo cp ShellCtl.sh /usr/local/bin/ShellCtl
sudo chmod +x /usr/local/bin/ShellCtl
```

---

## ✨ Features

- **Multi‑Connection Listeners** 🔁  
  Automatically tracks and relaunches new listener windows whenever your port frees up.

- **GNU screen Integration** 🖥️  
  Runs each shell in its own named `screen` window—detach, reattach, and manage sessions at will.

- **Session Management Commands** 🎛️  
  - `list` to view active sessions  
  - `attach` to jump into any live shell  
  - `kill` to terminate a specific session  
  - `killall` to clean up everything

- **Automatic Bash‑Completion** ⌨️  
  Installs a NetCtl‑style completion script so you can tab‑complete ports and session names.

- **Customizable Status Banners** 🏷️  
  Clear, colorized output with simple bullet‑list banners showing all active sessions.

---

## 🚀 Usage

```bash
# Start listening on port 4444
ShellCtl 4444

# List all active shell sessions
ShellCtl list

# Attach to session 'shellctl_4444'
ShellCtl attach 4444
# (or by window name: ShellCtl attach shellctl_4444)

# Kill a specific session
ShellCtl kill 4444

# Kill all sessions
ShellCtl killall

# Show help
ShellCtl help
```

When you launch on a port, ShellCtl will:

1. Create a detached `screen` session named `shellctl_<port>`.  
2. Spin up a watcher that re‑launches listeners whenever the port frees.  
3. Open your first listener window and automatically attach you.  

---

## 🛠️ Dependencies

ShellCtl uses a handful of standard Unix tools:

- [`bash`](https://www.gnu.org/software/bash/) (v4.2+)  
- [`screen`](https://www.gnu.org/software/screen/) for session management  
- [`ncat`](https://nmap.org/ncat/) (or `netcat`) to listen on ports  
- [`lsof`](https://linux.die.net/man/8/lsof/) to clean up processes  
- [`stty`](https://linux.die.net/man/1/stty/) & [`script`](https://linux.die.net/man/1/script/) for proper TTY handling  

If `bash‑completion` is installed, ShellCtl will drop its completion script into `~/.bash_completion.d/`.

---

## 🤝 Contributing

Contributions are welcome! Feel free to:

- Report bugs or request features via GitHub Issues  
- Fork the repo and submit pull requests  
- Suggest improved banners, themes, or integrations  

Please follow the existing style and add tests/examples where appropriate.

---

## 📄 License

This project is licensed under the **MIT License**. See [LICENSE](LICENSE) for details.

---

Made with ❤️ by Your Name  
```

# ShellCtl 🚀

ShellCtl is a reverse‑shell handler manager with multi‑connection support, auto‑respawning listeners, session tracking, and GNU screen integration. Ideal for pentesters, red‑teamers, or anyone who needs reliable remote shell orchestration.

---

## 📥 Installation

### 1. Using `curl` (or `wget`)

Download the `ShellCtl.sh` script to a system‑wide location and make it executable:

#### With `curl`
```bash
sudo curl -L https://github.com/TheHouseWithTheBackdoor/ShellCtl/raw/main/ShellCtl.sh \
  -o /usr/local/bin/ShellCtl
sudo chmod +x /usr/local/bin/ShellCtl
```

#### With `wget`
```bash
sudo wget https://github.com/TheHouseWithTheBackdoor/ShellCtl/raw/main/ShellCtl.sh \
  -O /usr/local/bin/ShellCtl
sudo chmod +x /usr/local/bin/ShellCtl
```

> You can now run `ShellCtl` from anywhere on your system.

### 2. From Git

Clone the repo and install manually:
```bash
git clone https://github.com/YourUser/ShellCtl.git
cd ShellCtl
sudo cp ShellCtl.sh /usr/local/bin/ShellCtl
sudo chmod +x /usr/local/bin/ShellCtl
```

---

## ✨ Features

- **Multi‑Connection Listeners** 🔁  
  Automatically tracks and relaunches new listeners whenever your port frees up.

- **GNU screen Integration** 🖥️  
  Runs each shell in its own named `screen` window—detach, reattach, and manage sessions at will.

- **Session Management Commands** 🎛️  
  - `list`   → view active sessions  
  - `attach` → jump into any live shell  
  - `kill`   → terminate a specific session  
  - `killall`→ terminate all sessions

- **Automatic Bash‑Completion** ⌨️  
  Installs a NetCtl‑style completion script so you can tab‑complete ports and session names.

- **Clear Status Banners** 🏷️  
  Colorized output with simple bullet‑list banners showing all active sessions.

---

## 🚀 Usage

```bash
# Start listening on port 4444
ShellCtl 4444

# List all active shell sessions
ShellCtl list

# Attach to session on port 4444
ShellCtl attach 4444
# (or by name: ShellCtl attach shellctl_4444)

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

ShellCtl relies on standard Unix utilities:

- **bash** (v4.2+)  
- **screen** for session management  
- **ncat** (or **netcat**) to listen on ports  
- **lsof** to clean up lingering processes  
- **stty** & **script** for proper TTY handling  

If you have `bash‑completion`, ShellCtl will install its completion script in `~/.bash_completion.d/`.

---

## 🤝 Contributing

Contributions are welcome! Please:

- File issues or feature requests on GitHub  
- Fork the repo and submit pull requests  
- Propose new banner themes or workflows  

Follow the existing style and include examples or tests when possible.

---

## 📄 License

This project is licensed under the **MIT License**. See [LICENSE](LICENSE) for details.

---

Made with ❤️ by Garpoz Master

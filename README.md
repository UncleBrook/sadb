# 🚀 sadb (Smart ADB)

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Bash Version](https://img.shields.io/badge/bash-%3E%3D%204.0-green.svg)](https://www.gnu.org/software/bash/)

`sadb` is a powerful wrapper for Android Debug Bridge (`adb`) that simplifies multi-device management and command automation.

## ✨ Key Features

- **📱 Smart Device Selection**: Automatically prompts for device selection when multiple devices are connected. Supports `fzf` for fuzzy searching.
- **⚡ Batch Execution**: Run a single command on ALL connected devices simultaneously.
- **🔗 Command Aliases**: Define short aliases for complex adb commands (e.g., `sadb alias log "logcat -v time"`).
- **🛠️ Custom Methods**: Create powerful multi-line scripts combining `adb` and local shell commands with automatic device targeting.
- **🎯 Active Device Lock**: Lock onto a specific device serial for the current session to skip selection prompts.
- **🎨 Modern UI**: Beautifully formatted tables with status-based coloring and clear execution headers.

## 🚀 Installation

### Manual Installation

#### 1. Install the Script
Download the `sadb` script and set the execution permission:

```shell
# For system-wide install (requires sudo):
sudo curl -L https://raw.githubusercontent.com/UncleBrook/sadb/main/sadb -o /usr/local/bin/sadb
sudo chmod +x /usr/local/bin/sadb

# For user-only install (ensure ~/.local/bin is in your PATH):
mkdir -p ~/.local/bin
curl -L https://raw.githubusercontent.com/UncleBrook/sadb/main/sadb -o ~/.local/bin/sadb
chmod +x ~/.local/bin/sadb
```

#### 2. Install Shell Completion
Download the completion script and load it in your shell configuration:

**For Bash:**
1. Download the script:
   ```shell
   mkdir -p ~/.config/sadb
   curl -L https://raw.githubusercontent.com/UncleBrook/sadb/main/sadb-completion.bash -o ~/.config/sadb/sadb-completion.bash
   ```
2. Add the following to your `~/.bashrc`:
   ```shell
   [[ -f ~/.config/sadb/sadb-completion.bash ]] && source ~/.config/sadb/sadb-completion.bash
   ```

**For Zsh:**
1. Download the script:
   ```shell
   mkdir -p ~/.config/sadb
   curl -L https://raw.githubusercontent.com/UncleBrook/sadb/main/sadb-completion.bash -o ~/.config/sadb/sadb-completion.bash
   ```
2. Add the following to your `~/.zshrc`:
   ```zsh
   autoload -Uz bashcompinit && bashcompinit
   source ~/.config/sadb/sadb-completion.bash
   ```

#### 3. Add Alias (Recommended)
Add an alias to your shell configuration (`~/.bashrc` or `~/.zshrc`) to use `sadb` as a drop-in replacement for `adb`:
```shell
alias adb="sadb"
```

### Quick Install (Automated)
If you prefer an automated setup, use the installation script which handles everything above for you:
```shell
curl -s https://raw.githubusercontent.com/UncleBrook/sadb/main/install.sh | bash
```

## 🪟 Windows (WSL) Usage

`sadb` has been **verified to work on WSL (Windows Subsystem for Linux)** with the **Windows `adb.exe`** — you don't need a separate Linux build of `adb` inside WSL.

### Prerequisites
- Windows 10/11 with WSL installed (WSL 1 or WSL 2)
- Windows Platform Tools (contains `adb.exe`)

### Setup

#### 1. Get Windows `adb`
Download [Platform Tools for Windows](https://developer.android.com/studio/releases/platform-tools) and extract it to a folder such as `C:\platform-tools`.

#### 2. Add `adb.exe` to the WSL `PATH`
Add the following line to `~/.bashrc` or `~/.zshrc` **inside WSL**:

```bash
export PATH="$PATH:/mnt/c/platform-tools"
```

> Adjust `/mnt/c/platform-tools` to match the actual location where you extracted Platform Tools (e.g. `/mnt/d/tools/platform-tools`).

Then reload your shell:

```bash
source ~/.bashrc    # or: source ~/.zshrc
```

#### 3. Install sadb
Install `sadb` inside WSL using any Linux method above:

```bash
curl -s https://raw.githubusercontent.com/UncleBrook/sadb/main/install.sh | bash
```

#### 4. Verify
```bash
which adb       # should point to /mnt/c/platform-tools/adb.exe
sadb devices    # lists the devices connected through Windows
```

### How It Works
- `sadb` invokes the Windows `adb.exe`, which talks to the **adb server running on Windows**, so USB devices are managed by Windows — no extra setup (`usbipd`, etc.) is needed inside WSL.
- `sadb` automatically strips the Windows CRLF line endings from `adb.exe` output, so device lists and serial numbers are always parsed correctly.

### Tips
- Keep WSL and Windows on the same Platform Tools version.
- If the adb server is not running yet, run `sadb start-server` once to launch the Windows adb server.
- Instead of editing `PATH`, you can symlink `adb.exe` into your Linux `PATH`:
  ```bash
  sudo ln -s /mnt/c/platform-tools/adb.exe /usr/local/bin/adb
  ```

## 📖 Commands Reference

`sadb` supports all standard `adb` commands and adds several powerful management features.

### 🧩 Alias Management
The `alias` command allows you to manage short commands and complex methods.

| Command | Description |
| :--- | :--- |
| `sadb alias -l -s [mode]` | List and sort aliases/methods (`a\|alpha`, `r\|reverse`, `l\|length`) |
| `sadb alias -r <key>` | Remove a specific alias or method |
| `sadb alias -h`, `--help` | Display detailed help for the alias command |
| `sadb alias <key> <value>` | Add or update a command alias |
| `sadb alias.<key> <value>` | Shorthand to add a command alias |
| `sadb alias <key>` | Show the definition of a specific alias |

### 🎯 Active Device Control
Set an active device for the **current terminal session only**. This avoids selection prompts without affecting other windows.

| Command | Description |
| :--- | :--- |
| `sadb active` | Trigger interactive selection (or auto-select if only one device is connected) |
| `sadb active <serial>` | Lock the current session to a specific device serial |
| `sadb active -d` | Unlock and return to interactive selection mode |
| `sadb active -h` | Display detailed help for the active command |

### 📱 Beautified Device List
`sadb` provides a modern, color-coded table for listing devices. Active devices for the current session are highlighted in yellow.

| Command | Description |
| :--- | :--- |
| `sadb devices` | List connected devices in a beautified table and highlight the active device |

### ⚙️ Standard ADB Passthrough
Commands like `start-server`, `kill-server`, `connect`, `pair`, `version`, etc., are passed directly to the original `adb` binary.

## 💡 Usage Examples

### Interactive Selection
If multiple devices are connected, simply run any adb command:
```shell
sadb shell
```
*If `fzf` is installed, you can search and select your device instantly.*

### Active Device Management
```shell
sadb active          # Select a device to lock onto for this terminal session
sadb devices         # See the list with the active device highlighted
sadb active -d       # Unlock and return to interactive selection mode
```

### Aliases
```shell
# Create an alias
sadb alias ws "wm size"

# Use it
sadb ws
```

### Methods (Automation)
Define complex workflows in `~/.config/sadb/.alias`:
```bash
# Example Method
my_workflow() {
    local scale=$1
    echo "Starting workflow..."
    adb shell settings put global window_animation_scale $scale
    adb shell settings put global transition_animation_scale $scale
    adb shell settings put global animator_duration_scale $scale
    echo "Workflow complete!"
}
```
*`sadb` automatically injects `ANDROID_SERIAL`, so you don't need `-s` inside methods.*

## 📋 Requirements
- **Bash v4.0+** (Required for associative arrays)
- **adb** (Android SDK Platform-Tools)
- **fzf** (Optional, for better interactive experience)
- **WSL + `adb.exe`** (Optional, on Windows — see [Windows (WSL) Usage](#-windows-wsl-usage))

## 🎥 Demo

### 📱 Smart Device Selection & Beautified List
![devices demo](examples/devices.gif)

### 🔗 Command Aliases & Methods
![alias demo](examples/alias.gif)

### ⚡ Interactive Usage & Execution
![execute demo](examples/excute.gif)

## 📄 License
This project is licensed under the [Apache License 2.0](LICENSE).

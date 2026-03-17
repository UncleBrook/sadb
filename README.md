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

### Quick Install
```shell
curl -s https://raw.githubusercontent.com/UncleBrook/sadb/main/install.sh | bash
```

### Manual Installation
1. Download the script:
   ```shell
   curl -L https://raw.githubusercontent.com/UncleBrook/sadb/main/sadb > /usr/local/bin/sadb
   chmod +x /usr/local/bin/sadb
   ```
2. (Recommended) Add an alias to your `~/.bashrc` or `~/.zshrc`:
   ```shell
   alias adb="sadb"
   ```

### Shell Completion
```shell
# For Bash
sudo cp ./sadb-completion.bash /usr/share/bash-completion/completions/sadb
source /usr/share/bash-completion/completions/sadb
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

## 🎥 Demo
[![Demo of the sadb script](https://i.ytimg.com/vi/GebidcL_W64/maxresdefault.jpg)](https://www.youtube.com/watch?v=GebidcL_W64 "Demo of the sadb script")

## 📄 License
This project is licensed under the [Apache License 2.0](LICENSE).

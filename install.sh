#!/usr/bin/env bash
set -euo pipefail

SCRIPT_URL="https://raw.githubusercontent.com/UncleBrook/sadb/main/sadb"
CONFIG_URL="https://raw.githubusercontent.com/UncleBrook/sadb/main/.alias"
COMPLETION_URL="https://raw.githubusercontent.com/UncleBrook/sadb/main/sadb-completion.bash"

# Determine installation directory for the script
if [[ ":$PATH:" == *":$HOME/.local/bin:"* ]]; then
    INSTALL_DIR="$HOME/.local/bin"
    mkdir -p "$INSTALL_DIR"
elif [ -w "/usr/local/bin" ]; then
    INSTALL_DIR="/usr/local/bin"
elif [ -w "/usr/bin" ]; then
    INSTALL_DIR="/usr/bin"
else
    INSTALL_DIR="/usr/local/bin"
fi

CONFIG_DIR="$HOME/.config/sadb/"
mkdir -p "$CONFIG_DIR"

echo "Installing to $INSTALL_DIR..."

SUDO=""
if [ ! -w "$INSTALL_DIR" ]; then
    if command -v sudo >/dev/null 2>&1; then
        SUDO="sudo"
        echo "Note: Writing to $INSTALL_DIR requires sudo privileges."
    else
        echo "Error: Cannot write to $INSTALL_DIR and sudo is not available."
        exit 1
    fi
fi

echo "Downloading script..."
$SUDO curl -L -s -o "$INSTALL_DIR/sadb" "$SCRIPT_URL"
$SUDO chmod +x "$INSTALL_DIR/sadb"

if [ ! -f "$CONFIG_DIR/.alias" ]; then
    echo "Downloading default config..."
    curl -L -s -o "$CONFIG_DIR/.alias" "$CONFIG_URL"
else
    echo "Config file already exists at $CONFIG_DIR/.alias, skipping download."
fi

# Determine completion directory (Ensuring consistency across Linux and macOS)
COMPLETION_DIR=""
if [[ "$OSTYPE" == "darwin"* ]]; then
    if command -v brew >/dev/null 2>&1; then
        BREW_PREFIX=$(brew --prefix)
        if [ -d "$BREW_PREFIX/etc/bash_completion.d" ]; then
            COMPLETION_DIR="$BREW_PREFIX/etc/bash_completion.d"
        fi
    fi
fi

if [ -z "$COMPLETION_DIR" ]; then
    # User-level bash completion directory
    USER_COMPLETION_DIR="$HOME/.local/share/bash-completion/completions"
    mkdir -p "$USER_COMPLETION_DIR"
    if [ -w "$USER_COMPLETION_DIR" ]; then
        COMPLETION_DIR="$USER_COMPLETION_DIR"
    else
        COMPLETION_DIR="$CONFIG_DIR"
    fi
fi

# Always use the consistent filename: sadb-completion.bash
COMPLETION_FILE="$COMPLETION_DIR/sadb-completion.bash"

echo "Downloading completion script to $COMPLETION_DIR..."
curl -L -s -o "$COMPLETION_FILE" "$COMPLETION_URL"

echo "Initializing shell profiles..."

# Common shell config files
CONFIG_FILES=("$HOME/.bashrc" "$HOME/.zshrc")
if [[ "$OSTYPE" == "darwin"* ]]; then
    CONFIG_FILES+=("$HOME/.bash_profile")
fi

for FILE in "${CONFIG_FILES[@]}"; do
    if [ -f "$FILE" ]; then
        # 1. Add alias
        if ! grep -q "adb='sadb'" "$FILE"; then
            echo "Adding alias to $FILE..."
            echo -e "\n# >>> sadb initialize >>>" >> "$FILE"
            echo "alias adb='sadb'" >> "$FILE"
            echo "# <<< sadb initialize <<<" >> "$FILE"
        fi
        
        # 2. Add completion loading (Consistent across all environments)
        if ! grep -q "sadb completion" "$FILE"; then
            echo "Adding completion loading to $FILE..."
            echo -e "\n# >>> sadb completion >>>" >> "$FILE"
            if [[ "$FILE" == *".zshrc" ]]; then
                echo "autoload -Uz bashcompinit && bashcompinit" >> "$FILE"
            fi
            echo "[[ -f \"$COMPLETION_FILE\" ]] && source \"$COMPLETION_FILE\"" >> "$FILE"
            echo "# <<< sadb completion <<<" >> "$FILE"
        fi
    fi
done

echo "Install completed successfully!"

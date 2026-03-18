#!/usr/bin/env bash
set -euo pipefail

SCRIPT_URL="https://raw.githubusercontent.com/UncleBrook/sadb/main/sadb"
CONFIG_URL="https://raw.githubusercontent.com/UncleBrook/sadb/main/.alias"
COMPLETION_URL="https://raw.githubusercontent.com/UncleBrook/sadb/main/sadb-completion.bash"

# Determine installation directory for the script
# Priority:
# 1. ~/.local/bin (If in PATH, avoid sudo)
# 2. /usr/local/bin (If writable)
# 3. /usr/bin (If writable)
# 4. /usr/local/bin (Fallback, needs sudo)

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

echo "Downloading default config..."
curl -L -s -o "$CONFIG_DIR/.alias" "$CONFIG_URL"

# Determine completion directory
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
    # Linux user-level bash completion
    USER_COMPLETION_DIR="$HOME/.local/share/bash-completion/completions"
    mkdir -p "$USER_COMPLETION_DIR"
    if [ -w "$USER_COMPLETION_DIR" ]; then
        COMPLETION_DIR="$USER_COMPLETION_DIR"
    else
        COMPLETION_DIR="$CONFIG_DIR"
    fi
fi

echo "Downloading completion script to $COMPLETION_DIR..."
COMPLETION_FILE="$COMPLETION_DIR/sadb"
if [[ "$COMPLETION_DIR" == "$CONFIG_DIR" ]]; then
    COMPLETION_FILE="$COMPLETION_DIR/sadb-completion.bash"
fi
curl -L -s -o "$COMPLETION_FILE" "$COMPLETION_URL"

echo "Initializing shell profiles..."

# Common shell config files
CONFIG_FILES=("$HOME/.bashrc" "$HOME/.zshrc")
if [[ "$OSTYPE" == "darwin"* ]]; then
    CONFIG_FILES+=("$HOME/.bash_profile")
fi

for FILE in "${CONFIG_FILES[@]}"; do
    if [ -f "$FILE" ]; then
        Add alias
        if ! grep -q "adb='sadb'" "$FILE"; then
            echo "Adding alias to $FILE..."
            echo -e "\n# >>> sadb initialize >>>" >> "$FILE"
            echo "alias adb='sadb'" >> "$FILE"
            echo "# <<< sadb initialize <<<" >> "$FILE"
        fi
        
        # Add completion loading for Zsh and non-standard Bash paths
        if [[ "$FILE" == *".zshrc" ]]; then
            if ! grep -q "bashcompinit" "$FILE"; then
                echo "Adding Zsh completion support to $FILE..."
                echo -e "\n# >>> sadb completion >>>" >> "$FILE"
                echo "autoload -Uz bashcompinit && bashcompinit" >> "$FILE"
                echo "source \"$COMPLETION_FILE\"" >> "$FILE"
                echo "# <<< sadb completion <<<" >> "$FILE"
            fi
        elif [[ "$COMPLETION_DIR" == "$CONFIG_DIR" ]]; then
             if ! grep -q "sadb-completion.bash" "$FILE"; then
                echo "Adding Bash completion loading to $FILE..."
                echo -e "\n# >>> sadb completion >>>" >> "$FILE"
                echo "[[ -f \"$COMPLETION_FILE\" ]] && source \"$COMPLETION_FILE\"" >> "$FILE"
                echo "# <<< sadb completion <<<" >> "$FILE"
            fi
        fi
    fi
done

echo "Install completed successfully!"

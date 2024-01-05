#!/usr/bin/env bash
set -euo pipefail

SCRIPT_URL="https://raw.githubusercontent.com/UncleBrook/sadb/main/sadb"
CONFIG_URL="https://raw.githubusercontent.com/UncleBrook/sadb/main/.alias"
INSTALL_DIR="/usr/bin"
CONFIG_DIR="$HOME/.config/sadb/"

mkdir -p "$CONFIG_DIR"

echo "Downloading..."

curl -o "$INSTALL_DIR/sadb" "$SCRIPT_URL"
curl -o "$CONFIG_DIR/.alias" "$CONFIG_URL"

chmod +x "$INSTALL_DIR/sadb"

echo "Initializing..."

if ! grep -q "adb='sadb'" "$HOME/.bashrc"; then
    echo "# >>> sadb initialize >>>" >> "$HOME/.bashrc"
    echo "alias adb='sadb'" >> "$HOME/.bashrc"
    echo "# <<< sadb initialize <<<" >> "$HOME/.bashrc"
fi

echo "Install completed."

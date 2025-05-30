#!/bin/bash
# install_cleanmac.sh — Downloads and installs cleanmac.sh

set -euo pipefail

SCRIPT_URL="https://raw.githubusercontent.com/Dan13681989/cleanmac/main/cleanmac.sh"
INSTALL_PATH="/usr/local/bin/cleanmac"
TEMP_FILE="/tmp/cleanmac.sh"

echo "[*] Downloading cleanmac script..."
if ! curl -fsSL "$SCRIPT_URL" -o "$TEMP_FILE"; then
  echo "[!] Failed to download cleanmac script. Check your connection or URL."
  exit 1
fi

echo "[*] Installing to $INSTALL_PATH..."
sudo mv "$TEMP_FILE" "$INSTALL_PATH"
sudo chmod +x "$INSTALL_PATH"

echo "[+] cleanmac installed successfully! Run it with: cleanmac"

#!/bin/bash

# Safer cleanmac installer script

SCRIPT_URL="https://raw.githubusercontent.com/Dan13681989/cleanmac/main/cleanmac.sh"
SCRIPT_PATH="/usr/local/bin/cleanmac"

echo "[*] Downloading cleanmac script..."

# Download to a temporary file first
TEMP_FILE="/tmp/cleanmac.sh"

if ! curl -fsSL "$SCRIPT_URL" -o "$TEMP_FILE"; then
  echo "[!] Failed to download cleanmac script. Check your internet connection or URL."
  exit 1
fi

# Move to the correct location with proper permissions
echo "[*] Installing to $SCRIPT_PATH..."
sudo mv "$TEMP_FILE" "$SCRIPT_PATH"
sudo chmod +x "$SCRIPT_PATH"

# Success message
echo "[+] cleanmac installed successfully! Run it with: cleanmac"

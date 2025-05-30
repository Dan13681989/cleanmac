#!/bin/bash
# run_cleanmac.sh — one-click installer launcher

INSTALLER_URL="https://raw.githubusercontent.com/Dan13681989/cleanmac/main/install_cleanmac.sh"
INSTALLER_FILE="install_cleanmac.sh"

echo "[*] Fetching installer..."
curl -fsSL "$INSTALLER_URL" -o "$INSTALLER_FILE"
chmod +x "$INSTALLER_FILE"

echo "[*] Running installer..."
./"$INSTALLER_FILE"

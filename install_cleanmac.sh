#!/bin/sh

# Variables
REPO_RAW_BASE="https://raw.githubusercontent.com/Dan13681989/cleanmac/main"
SCRIPT_NAME="cleanmac.sh"
INSTALL_PATH="/tmp/$SCRIPT_NAME"

echo "[install_cleanmac] Downloading latest cleanmac.sh..."

if command -v curl >/dev/null 2>&1; then
  curl -fsSL "$REPO_RAW_BASE/$SCRIPT_NAME" -o "$INSTALL_PATH"
elif command -v wget >/dev/null 2>&1; then
  wget -qO "$INSTALL_PATH" "$REPO_RAW_BASE/$SCRIPT_NAME"
else
  echo "[install_cleanmac] Error: curl or wget required to download files."
  exit 1
fi

if [ ! -f "$INSTALL_PATH" ]; then
  echo "[install_cleanmac] Error: Failed to download cleanmac.sh"
  exit 1
fi

chmod +x "$INSTALL_PATH"

echo "[install_cleanmac] Running cleanmac.sh..."
sh "$INSTALL_PATH"

echo "[install_cleanmac] Finished."

exit 0

#!/bin/bash
# run_cleanmac.sh - one-click installer launcher

INSTALLER_URL="https://raw.githubusercontent.com/Dan13681989/cleanmac/main/install_cleanmac.sh"
INSTALLER_FILE="install_cleanmac.sh"

# Download installer script
curl -fsSL "$INSTALLER_URL" -o "$INSTALLER_FILE"

# Make it executable
chmod +x "$INSTALLER_FILE"

# Run installer
./"$INSTALLER_FILE"

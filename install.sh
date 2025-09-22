#!/bin/bash

# CleanMac Installation Script
echo "🧹 CleanMac Installation"

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ This script is for macOS only"
    exit 1
fi

# Create installation directory
INSTALL_DIR="/usr/local/bin"
SCRIPT_NAME="cleanmac"

# Copy script to bin directory
echo "📦 Installing CleanMac to $INSTALL_DIR..."
sudo cp cleanmac.sh "$INSTALL_DIR/$SCRIPT_NAME"
sudo chmod +x "$INSTALL_DIR/$SCRIPT_NAME"

# Verify installation
if command -v $SCRIPT_NAME &> /dev/null; then
    echo "✅ CleanMac installed successfully!"
    echo "🚀 Usage: $SCRIPT_NAME"
else
    echo "❌ Installation failed"
    exit 1
fi

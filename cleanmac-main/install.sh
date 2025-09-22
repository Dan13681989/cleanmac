#!/bin/bash

# CleanMac Simple Installer
echo "🧹 CleanMac Installation"
echo "========================"

# Installation directory
INSTALL_DIR="/usr/local/bin"
LIB_DIR="/usr/local/lib/cleanmac"

# Create directories
echo "📦 Creating installation directories..."
sudo mkdir -p "$LIB_DIR"

# Get current directory
CURRENT_DIR="$(pwd)"

# Copy main script
echo "📦 Installing CleanMac to $INSTALL_DIR..."
sudo cp "$CURRENT_DIR/cleanmac.sh" "$INSTALL_DIR/cleanmac"
sudo chmod +x "$INSTALL_DIR/cleanmac"

# Copy supporting files
if [ -f "$CURRENT_DIR/hotspot_fix.py" ]; then
    sudo cp "$CURRENT_DIR/hotspot_fix.py" "$LIB_DIR/"
    echo "✅ hotspot_fix.py installed"
fi

if [ -f "$CURRENT_DIR/README.md" ]; then
    sudo cp "$CURRENT_DIR/README.md" "$LIB_DIR/"
    echo "✅ README.md installed"
fi

echo "✅ CleanMac installed successfully!"
echo "🚀 Usage: cleanmac"
echo "📖 Documentation: $LIB_DIR/README.md"

# Verify installation
if command -v cleanmac &> /dev/null; then
    echo "🎉 Installation verified! You can now run 'cleanmac'"
else
    echo "⚠️  Note: You may need to restart your terminal or run:"
    echo "   export PATH=\"/usr/local/bin:\$PATH\""
fi

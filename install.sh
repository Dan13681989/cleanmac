#!/bin/bash

# CleanMac Pro Installer
# One-command setup for CleanMac Pro

echo "🚀 CleanMac Pro Installer"
echo "========================="

# Check if cleanmac_pro.sh exists in current directory
if [ ! -f "cleanmac_pro.sh" ]; then
    echo "❌ Error: cleanmac_pro.sh not found in current directory"
    echo "Please run this script from the CleanMac Pro directory"
    exit 1
fi

# Make the main script executable
chmod +x cleanmac_pro.sh

# Install system-wide
./cleanmac_pro.sh --install

echo ""
echo "🎉 Installation Complete!"
echo "💡 You can now use:"
echo "   cleanmac --help          # See all commands"
echo "   quickclean               # Fast cleanup"
echo "   sysinfo                  # System information"
echo "   health-score             # System health check"
echo "   security-audit           # Security audit"

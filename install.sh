#!/bin/bash

# CleanMac Pro Installer
echo "🚀 CleanMac Pro Installer"
echo "========================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Download the main script from GitHub
echo "📥 Downloading CleanMac Pro..."
curl -fsSL https://raw.githubusercontent.com/Dan13681989/cleanmac/main/cleanmac_pro.sh -o cleanmac_pro.sh

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Failed to download CleanMac Pro${NC}"
    exit 1
fi

# Make the main script executable
chmod +x cleanmac_pro.sh

# Install system-wide
echo "🔧 Installing system-wide..."
./cleanmac_pro.sh --install

echo ""
echo -e "${GREEN}🎉 Installation Complete!${NC}"
echo "💡 You can now use these commands anywhere:"
echo "   cleanmac --help          # See all commands"
echo "   health-score             # System health check"
echo "   security-audit           # Security audit"
echo "   quickclean               # Fast cleanup"
echo "   sysinfo                  # System information"

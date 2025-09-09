#!/bin/zsh
# CleanMAC Complete Setup

echo "=== CleanMAC Complete Setup ==="

# Create directories
sudo mkdir -p /usr/local/bin

# Copy main script
sudo cp ~/CleanMAC/src/cleanmac_core.sh /usr/local/bin/cleanmac

# Set permissions
sudo chmod +x /usr/local/bin/cleanmac

# Create alias in shell profile
echo "alias cleanmac='/usr/local/bin/cleanmac'" >> ~/.zshrc

echo "✅ CleanMAC installation complete!"
echo "You can now use: cleanmac --help"

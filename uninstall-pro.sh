#!/bin/bash

echo "🧹 CleanMac Pro Uninstallation"
echo "=============================="

echo "🗑️ Removing installed commands..."
sudo rm -f /usr/local/bin/cleanmac-pro
sudo rm -f /usr/local/bin/iphone-health
sudo rm -f /usr/local/bin/iphone-dashboard  
sudo rm -f /usr/local/bin/iphone-security
sudo rm -f /usr/local/bin/iphone-backup
sudo rm -f /usr/local/bin/iphone-deploy

echo "🗑️ Removing desktop shortcut..."
rm -f "$HOME/Desktop/CleanMac-Pro.command"

echo "📁 Remove configuration? (y/n)"
read -p "Choice: " remove_config
if [ "$remove_config" = "y" ]; then
    rm -rf "$HOME/.cleanmac"
    echo "✅ Configuration removed"
else
    echo "ℹ️  Configuration kept at $HOME/.cleanmac"
fi

echo "🎉 Uninstallation complete!"

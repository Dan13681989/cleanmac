#!/bin/bash

echo "🧹 CleanMac Pro v3.0.0 Installation"
echo "===================================="

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "❌ Please don't run as root. We'll use sudo when needed."
    exit 1
fi

# Create installation directory
INSTALL_DIR="/usr/local/bin"
CONFIG_DIR="$HOME/.cleanmac"

echo "📁 Creating directories..."
mkdir -p "$CONFIG_DIR" "$CONFIG_DIR/backups" "$CONFIG_DIR/logs"

echo "🔧 Installing main script..."
sudo cp cleanmac-pro "$INSTALL_DIR/"
sudo chmod +x "$INSTALL_DIR/cleanmac-pro"

echo "📱 Installing iPhone tools..."
sudo ln -sf "$(pwd)/iphone-config/health_check.sh" "$INSTALL_DIR/iphone-health"
sudo ln -sf "$(pwd)/iphone-config/system_dashboard.sh" "$INSTALL_DIR/iphone-dashboard"
sudo ln -sf "$(pwd)/iphone-config/security_setup.sh" "$INSTALL_DIR/iphone-security"
sudo ln -sf "$(pwd)/iphone-config/backup_configs.sh" "$INSTALL_DIR/iphone-backup"
sudo ln -sf "$(pwd)/iphone-config/deploy_all.sh" "$INSTALL_DIR/iphone-deploy"

echo "📝 Creating desktop shortcuts..."
cat > "$HOME/Desktop/CleanMac-Pro.command" << 'EOL'
#!/bin/bash
cd ~/cleanmac
./cleanmac-pro
EOL
chmod +x "$HOME/Desktop/CleanMac-Pro.command"

echo "🎉 Installation Complete!"
echo ""
echo "Available Commands:"
echo "  cleanmac-pro      - Full CleanMac Pro interface"
echo "  iphone-health     - System health check"
echo "  iphone-dashboard  - System dashboard"
echo "  iphone-security   - Security setup"
echo "  iphone-backup     - Configuration backup"
echo "  iphone-deploy     - Full deployment"
echo ""
echo "Desktop shortcut created: CleanMac-Pro.command"
echo "Configuration: $CONFIG_DIR"

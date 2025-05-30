#!/bin/bash
set -euo pipefail

# Diagnostic tools and system info
function diagnostics() {
  echo "[diagnostic] System Information:"
  uname -a
  echo "[diagnostic] Disk Usage:"
  df -h
  echo "[diagnostic] Memory Usage:"
  vm_stat | grep 'Pages'
  echo "[diagnostic] Running Processes:"
  ps aux | head -10
}

# Check for SIP status (macOS only)
function check_sip() {
  if [[ "$(uname)" == "Darwin" ]]; then
    echo "[info] Checking System Integrity Protection (SIP) status..."
    csrutil status 2>/dev/null || echo "[warning] Unable to determine SIP status. Run in recovery mode if needed."
  fi
}

# Display help message
function show_help() {
  echo "\n[cleanmac installer] Usage:"
  echo "  install_cleanmac.sh [--help]"
  echo "\nOptions:"
  echo "  --help       Show this help message"
  echo "\nDescription:"
  echo "  Installs cleanmac CLI and macOS app. Includes diagnostics and SIP checks."
}

# Handle command-line args
if [[ "${1:-}" == "--help" ]]; then
  show_help
  exit 0
fi

# Download the cleanmac script
SCRIPT_URL="https://raw.githubusercontent.com/Dan13681989/cleanmac/main/cleanmac.sh"
INSTALL_PATH="/usr/local/bin/cleanmac"

echo "[*] Downloading cleanmac script..."
curl -fsSL "$SCRIPT_URL" -o /tmp/cleanmac.sh
chmod +x /tmp/cleanmac.sh

# Install the script to a system-wide location
echo "[*] Installing to $INSTALL_PATH..."
sudo cp /tmp/cleanmac.sh "$INSTALL_PATH"
sudo chmod +x "$INSTALL_PATH"

# Create macOS app bundle
APP_DIR="$HOME/Applications/Cleanmac.app/Contents/MacOS"
mkdir -p "$APP_DIR"
echo -e '#!/bin/bash\n/usr/local/bin/cleanmac' > "$APP_DIR/Cleanmac"
chmod +x "$APP_DIR/Cleanmac"

# Create README.md
cat > "$HOME/Applications/Cleanmac.app/README.md" <<EOF
# 🧼 CleanMac

**CleanMac** is a lightweight, privacy-focused system cleaner and diagnostics tool.

## Features
- ✅ Cache cleanup (user + system)
- 🧠 Basic diagnostic readout
- 🔐 SIP (System Integrity Protection) status check
- 🧰 Compatible with macOS, Linux, Tails
- 🖱️ Launchable from Finder/Launchpad as Cleanmac.app

## Usage
```bash
cleanmac        # Run cleanup
cleanmac --help # Show options
```

## Installation
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Dan13681989/cleanmac/main/install_cleanmac.sh)"
```

EOF

# Output results
echo "[+] cleanmac installed successfully! Run it with: cleanmac"
echo "[+] macOS app 'Cleanmac.app' created at $HOME/Applications/Cleanmac.app"
echo "    You can launch it from Finder or Launchpad."
echo "[+] README.md available at $HOME/Applications/Cleanmac.app/README.md"

# Perform diagnostics, SIP check, then run cleanmac
diagnostics
check_sip
/usr/local/bin/cleanmac

#!/bin/sh
echo "[install_cleanmac] Downloading latest cleanmac.sh..."
curl -fsSL https://raw.githubusercontent.com/Dan13681989/cleanmac/main/cleanmac.sh -o "$HOME/cleanmac.sh"
chmod +x "$HOME/cleanmac.sh"
echo "[install_cleanmac] Running cleanmac.sh..."
"$HOME/cleanmac.sh"
echo "[install_cleanmac] Finished."

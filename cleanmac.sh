cleanup_system() {
  echo "[cleanmac] Starting system cleanup..."

  # Confirm action
  read -p "Do you want to proceed with cleaning temporary files, logs, and caches? (y/n): " confirm
  if [ "$confirm" != "y" ]; then
    echo "[cleanmac] Cleanup aborted."
    return
  fi

  echo "[cleanmac] Cleaning user cache..."
  rm -rf ~/Library/Caches/* ~/.cache/* 2>/dev/null

  echo "[cleanmac] Cleaning system logs..."
  sudo rm -rf /private/var/log/* /Library/Logs/* /var/log/* 2>/dev/null

  echo "[cleanmac] Cleaning temporary files..."
  sudo rm -rf /private/tmp/* /tmp/* 2>/dev/null

  echo "[cleanmac] Cleaning trash..."
  rm -rf ~/.Trash/* 2>/dev/null

  echo "[cleanmac] Optionally cleaning Downloads..."
  read -p "Do you want to clean ~/Downloads as well? (y/n): " clean_dl
  if [ "$clean_dl" = "y" ]; then
    rm -rf ~/Downloads/* 2>/dev/null
  fi

  echo "[cleanmac] Cleanup complete."
}

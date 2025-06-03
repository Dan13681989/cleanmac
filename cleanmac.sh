#!/bin/bash

# cleanmac.sh - A powerful system tool for cleanup and bootable USB creation
# Author: Dan13681989
# License: MIT

echo "[cleanmac] Starting Cleanmac tool..."
echo "[cleanmac] This script is under active development."

# ===============================
# Basic Environment Diagnostics
# ===============================
echo "[cleanmac] Performing basic environment checks..."
uname -a
df -h /

# ===============================
# Interactive Menu
# ===============================
show_menu() {
  echo ""
  echo "===== Cleanmac Menu ====="
  echo "1) System Cleanup"
  echo "2) Create Bootable USB"
  echo "q) Quit"
  echo "========================="
  read -p "Choose an option: " choice
  case "$choice" in
    1) cleanup_system ;;
    2) create_bootable_usb ;;
    q|Q) echo "[cleanmac] Goodbye!" && exit 0 ;;
    *) echo "[cleanmac] Invalid option. Try again." && show_menu ;;
  esac
}

# ===============================
# Cleanup System Function
# ===============================
cleanup_system() {
  echo "[cleanmac] Starting system cleanup..."

  read -p "Proceed with cleaning temporary files, logs, and caches? (y/n): " confirm
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

  echo "[cleanmac] Cleaning Trash..."
  rm -rf ~/.Trash/* 2>/dev/null

  read -p "Do you want to clean ~/Downloads as well? (y/n): " clean_dl
  if [ "$clean_dl" = "y" ]; then
    rm -rf ~/Downloads/* 2>/dev/null
  fi

  echo "[cleanmac] Cleanup complete."
}

# ===============================
# Bootable USB Creator Function
# ===============================
create_bootable_usb() {
  echo "[cleanmac] Starting bootable USB creator..."

  read -p "Enter the path to the ISO file (e.g., ~/Downloads/ubuntu.iso): " iso_path
  if [ ! -f "$iso_path" ]; then
    echo "[cleanmac] ISO file not found at $iso_path"
    return
  fi

  echo "[cleanmac] Available disks:"
  diskutil list

  read -p "Enter the disk identifier (e.g., disk2): " disk_id
  if [ -z "$disk_id" ]; then
    echo "[cleanmac] Invalid disk identifier."
    return
  fi

  echo "[cleanmac] WARNING: This will erase /dev/$disk_id!"
  read -p "Are you sure? (y/n): " confirm_disk
  if [ "$confirm_disk" != "y" ]; then
    echo "[cleanmac] Operation cancelled."
    return
  fi

  diskutil unmountDisk /dev/$disk_id
  sudo dd if="$iso_path" of=/dev/r$disk_id bs=1m status=progress
  sync
  diskutil eject /dev/$disk_id

  echo "[cleanmac] Bootable USB created successfully."
}

# ===============================
# Launch the Menu
# ===============================
show_menu

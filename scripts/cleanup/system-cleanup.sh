#!/bin/bash

# system-cleanup.sh
# macOS system cleanup and maintenance

echo "🧹 Starting macOS system cleanup..."

# Clean caches
echo "Cleaning user caches..."
rm -rf ~/Library/Caches/*

# Clean logs
echo "Cleaning logs..."
sudo rm -rf /var/log/*.old

echo "✅ System cleanup completed!"

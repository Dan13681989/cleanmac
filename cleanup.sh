#!/bin/bash
echo "=== Starting Weekly Cleanup ==="
find ~/Downloads -type f -mtime +30 -delete
find ~/Desktop -name "*.tmp" -delete
find ~ -name ".DS_Store" -delete 2>/dev/null
echo "Cleaned temporary files"
du -sh ~/Documents ~/Development ~/Media
echo "=== Cleanup Complete ==="

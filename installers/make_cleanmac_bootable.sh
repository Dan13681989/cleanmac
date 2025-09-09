#!/bin/zsh
# ADATA Bootable Setup Script

echo "=== CleanMAC ADATA Bootable Setup ==="

# Use the main ADATA volume
ADATA_VOLUME="/Volumes/ADATA"

if [[ ! -d "$ADATA_VOLUME" ]]; then
    echo "❌ ADATA drive not found at $ADATA_VOLUME"
    echo "Available volumes:"
    ls /Volumes/
    exit 1
fi

# Create directory structure on ADATA
mkdir -p $ADATA_VOLUME/CleanMAC/{bin,scripts,recovery,logs}

# Copy scripts to ADATA
cp ~/CleanMAC/src/cleanmac_core.sh $ADATA_VOLUME/CleanMAC/bin/

# Create autorun script
cat > $ADATA_VOLUME/CleanMAC/autorun.sh << 'AUTOEOF'
#!/bin/zsh
echo "=== CleanMAC ADATA Autorun ==="
echo "Running from ADATA drive..."
/Volumes/ADATA/CleanMAC/bin/cleanmac_core.sh --smart
AUTOEOF

# Create recovery script
cat > $ADATA_VOLUME/CleanMAC/recovery/recovery_mode.sh << 'RECEOF'
#!/bin/zsh
echo "=== CleanMAC Recovery Mode ==="
echo "Available in Recovery Mode:"
echo "1. Mount main volume: diskutil mountDisk /dev/disk1s1"
echo "2. Run disk repair: diskutil verifyVolume /Volumes/Macintosh\ HD"
echo "3. Clean caches: rm -rf /Volumes/Macintosh\ HD/Users/*/Library/Caches/*"
RECEOF

# Make scripts executable
chmod +x $ADATA_VOLUME/CleanMAC/autorun.sh
chmod +x $ADATA_VOLUME/CleanMAC/recovery/recovery_mode.sh
chmod +x $ADATA_VOLUME/CleanMAC/bin/cleanmac_core.sh

echo "✅ ADATA Bootable Setup Complete!"
echo "Your drive now contains CleanMAC with:"
echo "• Auto-run capability: $ADATA_VOLUME/CleanMAC/autorun.sh"
echo "• Recovery Mode tools: $ADATA_VOLUME/CleanMAC/recovery/recovery_mode.sh"

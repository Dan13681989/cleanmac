#!/usr/bin/env python3
"""
Hotspot Stability Module for CleanMac
Fixes unstable iPhone hotspot connections
"""

import subprocess
import sys
import time

class HotspotFix:
    def __init__(self):
        self.wifi_interface = "en0"
        
    def apply_stability_fixes(self):
        """Apply all hotspot stability fixes"""
        print("🔧 Applying hotspot stability fixes...")
        
        try:
            # Set MTU
            subprocess.run(["sudo", "ifconfig", self.wifi_interface, "mtu", "1300"], check=True)
            print("📡 MTU set to 1300")
            
            # Disable IPv6
            subprocess.run(["sudo", "networksetup", "-setv6off", "Wi-Fi"], check=True)
            print("🔌 IPv6 disabled")
            
            # Flush DNS
            subprocess.run(["sudo", "dscacheutil", "-flushcache"], check=True)
            subprocess.run(["sudo", "killall", "-HUP", "mDNSResponder"], check=True)
            print("🗑️ DNS cache flushed")
            
            # TCP optimizations (safe ones that work on all macOS versions)
            try:
                subprocess.run(["sudo", "sysctl", "-w", "net.inet.tcp.mssdflt=1260"], check=True)
                print("⚡ TCP parameters optimized")
            except:
                print("⚠️  TCP optimization not available (OK for older macOS)")
            
            print("✅ Hotspot stability fixes applied!")
            return True
            
        except Exception as e:
            print(f"❌ Error applying fixes: {e}")
            return False

def main():
    """Main function for command-line usage"""
    hotspot = HotspotFix()
    hotspot.apply_stability_fixes()

if __name__ == "__main__":
    main()

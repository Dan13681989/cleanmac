#!/bin/bash

echo "Updating CleanMac Pro with new features..."

# Backup the original
cp cleanmac_pro.sh cleanmac_pro.sh.backup

# Find the line number where we need to insert new functions
insert_line=$(grep -n "full_clean()" cleanmac_pro.sh | tail -1 | cut -d: -f1)
insert_line=$((insert_line + 1))

# Create a temporary file with the new content
{
    # Copy everything before the insertion point
    head -n $insert_line cleanmac_pro.sh
    
    # Add the new functions
    cat << 'NEWFUNCTIONS'

# System Health Scoring
health_score() {
    echo -e "${YELLOW}🔍 Calculating System Health Score...${NC}"
    
    local score=100
    
    # Check disk space
    local disk_usage=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
    if [ "$disk_usage" -gt 90 ]; then
        score=$((score - 20))
        echo -e "${RED}⚠️  Disk usage high: ${disk_usage}%${NC}"
    elif [ "$disk_usage" -gt 80 ]; then
        score=$((score - 10))
        echo -e "${YELLOW}⚠️  Disk usage: ${disk_usage}%${NC}"
    else
        echo -e "${GREEN}✅ Disk usage: ${disk_usage}%${NC}"
    fi
    
    # Check memory pressure  
    local memory_pressure=$(memory_pressure 2>/dev/null | grep "System-wide memory free" | awk '{print $5}' | sed 's/%//' || echo "0")
    if [ ! -z "$memory_pressure" ] && [ "$memory_pressure" != "0" ]; then
        if [ "$memory_pressure" -lt 10 ]; then
            score=$((score - 15))
            echo -e "${RED}⚠️  Memory pressure: ${memory_pressure}% free${NC}"
        elif [ "$memory_pressure" -lt 20 ]; then
            score=$((score - 5))
            echo -e "${YELLOW}⚠️  Memory pressure: ${memory_pressure}% free${NC}"
        else
            echo -e "${GREEN}✅ Memory pressure: ${memory_pressure}% free${NC}"
        fi
    fi
    
    # Check SIP status
    if csrutil status 2>/dev/null | grep -q "disabled"; then
        score=$((score - 10))
        echo -e "${RED}⚠️  SIP is disabled${NC}"
    else
        echo -e "${GREEN}✅ SIP is enabled${NC}"
    fi
    
    # Check system updates
    if softwareupdate -l 2>&1 | grep -q "No new software available"; then
        echo -e "${GREEN}✅ System is up to date${NC}"
    else
        score=$((score - 5))
        echo -e "${YELLOW}⚠️  System updates available${NC}"
    fi
    
    # Determine rating
    local rating
    if [ "$score" -ge 90 ]; then
        rating="${GREEN}Excellent${NC}"
    elif [ "$score" -ge 80 ]; then
        rating="${YELLOW}Good${NC}"
    elif [ "$score" -ge 70 ]; then
        rating="${YELLOW}Fair${NC}"
    else
        rating="${RED}Needs Attention${NC}"
    fi
    
    echo ""
    echo -e "${GREEN}📊 System Health: ${score}/100 - ${rating}${NC}"
}

# Security Audit
security_audit() {
    echo -e "${YELLOW}🔒 Running Security Audit...${NC}"
    echo ""
    
    # Check SIP
    echo -e "${BLUE}System Integrity Protection:${NC}"
    csrutil status
    echo ""
    
    # Check Firewall
    echo -e "${BLUE}Firewall Status:${NC}"
    if /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate 2>/dev/null | grep -q "Enabled"; then
        echo -e "${GREEN}✅ Firewall is enabled${NC}"
    else
        echo -e "${RED}❌ Firewall is disabled${NC}"
    fi
    echo ""
    
    # Check Gatekeeper
    echo -e "${BLUE}Gatekeeper Status:${NC}"
    spctl --status
    echo ""
    
    # Check automatic updates
    echo -e "${BLUE}Automatic Updates:${NC}"
    local auto_update=$(defaults read /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled 2>/dev/null || echo "0")
    if [ "$auto_update" = "1" ]; then
        echo -e "${GREEN}✅ Automatic updates enabled${NC}"
    else
        echo -e "${YELLOW}⚠️  Automatic updates disabled${NC}"
    fi
    echo ""
    
    # List login items
    echo -e "${BLUE}User Login Items:${NC}"
    osascript -e 'tell application "System Events" to get the name of every login item' 2>/dev/null || echo "No login items found"
    echo ""
}

# Backup Verification
verify_backup() {
    echo -e "${YELLOW}🔍 Verifying Time Machine Backup...${NC}"
    
    # Check if Time Machine is enabled
    if tmutil destinationinfo | grep -q "Mount Point"; then
        echo -e "${GREEN}✅ Time Machine is configured${NC}"
        
        # Get latest backup
        local latest_backup=$(tmutil listbackups 2>/dev/null | tail -1)
        if [ -n "$latest_backup" ]; then
            echo -e "${BLUE}Latest backup: ${latest_backup}${NC}"
            echo -e "${GREEN}✅ Backups are running${NC}"
        else
            echo -e "${RED}❌ No backups found${NC}"
        fi
    else
        echo -e "${RED}❌ Time Machine not configured${NC}"
    fi
}

# Installation function
install_cleanmac() {
    echo -e "${YELLOW}🚀 Installing CleanMac Pro system-wide...${NC}"
    
    # Copy to /usr/local/bin
    local install_dir="/usr/local/bin"
    local script_name="cleanmac"
    
    sudo cp -f "$0" "$install_dir/$script_name"
    sudo chmod +x "$install_dir/$script_name"
    
    echo -e "${GREEN}✅ CleanMac Pro installed successfully!${NC}"
}

NEWFUNCTIONS

    # Copy the rest of the original file, but update the case statement
    tail -n +$((insert_line + 1)) cleanmac_pro.sh | sed '
        /case "${1:-}" in/,/esac/{
            /"--clean")/,/;;/b
            /"--quick-clean")/,/;;/b  
            /"--dry-run")/,/;;/b
            /"--help"|"")/i\
    "--health-score")\
        health_score\
        ;;\
    "--security-audit")\
        security_audit\
        ;;\
    "--verify-backup")\
        verify_backup\
        ;;\
    "--install")\
        install_cleanmac\
        ;;\
    "--sip-status")\
        check_sip_status\
        ;;\
    "--sip-enable")\
        enable_sip\
        ;;\
    "--sip-disable")\
        disable_sip\
        ;;\
    "--sip-help")\
        show_sip_help\
        ;;\
    "--sys-info")\
        show_system_info\
        ;;\
    "--disk-info")\
        show_disk_info\
        ;;\
    "--tm-status")\
        check_tm_status\
        ;;\
    "--tm-start")\
        start_tm_backup\
        ;;\
    "--tm-stop")\
        stop_tm_backup\
        ;;\
    "--tm-list")\
        list_tm_backups\
        ;;
        }
    '

} > cleanmac_pro_updated.sh

# Replace the original
mv cleanmac_pro_updated.sh cleanmac_pro.sh
chmod +x cleanmac_pro.sh

echo "Update complete!"

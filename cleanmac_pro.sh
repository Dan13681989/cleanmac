#!/bin/bash

# CleanMac Pro - All-in-One macOS Management
# Complete system cleaning, SIP control, and Time Machine management

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Settings
DRY_RUN=false
INTERACTIVE=false

# =============================================================================
# TIME MACHINE FUNCTIONS
# =============================================================================

tm_status() {
    echo -e "${CYAN}🕐 Checking Time Machine Status...${NC}"
    local status=$(tmutil status)
    
    if echo "$status" | grep -q "Running = 1"; then
        echo -e "${GREEN}✅ Time Machine: BACKUP IN PROGRESS${NC}"
    elif echo "$status" | grep -q "Running = 0"; then
        echo -e "${BLUE}⏸️  Time Machine: IDLE${NC}"
    else
        echo -e "${YELLOW}⚠️  Time Machine: STATUS UNKNOWN${NC}"
    fi
    
    echo -e "${BLUE}📋 Time Machine Details:${NC}"
    tmutil status | grep -E "(Running|Percent|TimeRemaining|BackupPhase|_raw_Percent)" | head -10
    
    echo -e "${BLUE}📅 Latest Backup:${NC}"
    tmutil latestbackup 2>/dev/null || echo "No backups found"
    
    echo -e "${BLUE}💾 Backup Destination:${NC}"
    tmutil destinationinfo | grep -E "(Name|URL|Kind)" | head -6
    
    # Check if Time Machine is set up
    if ! tmutil destinationinfo | grep -q "Mount Point"; then
        echo -e "${YELLOW}📝 Time Machine is not set up. Use --tm-setup to configure.${NC}"
    fi
}

tm_start() {
    echo -e "${GREEN}🔄 Starting Time Machine Backup...${NC}"
    if tmutil startbackup; then
        echo -e "${GREEN}✅ Backup started successfully${NC}"
        echo -e "${BLUE}💡 Run 'cleanmac --tm-status' to monitor progress${NC}"
    else
        echo -e "${RED}❌ Failed to start backup${NC}"
        echo -e "${YELLOW}📝 Time Machine may not be set up. Use --tm-setup first.${NC}"
    fi
}

tm_stop() {
    echo -e "${YELLOW}⏹️  Stopping Time Machine Backup...${NC}"
    if tmutil stopbackup; then
        echo -e "${GREEN}✅ Backup stopped successfully${NC}"
    else
        echo -e "${RED}❌ Failed to stop backup${NC}"
    fi
}

tm_list_backups() {
    echo -e "${CYAN}📚 Listing Time Machine Backups...${NC}"
    local backups=$(tmutil listbackups 2>/dev/null)
    
    if [ -z "$backups" ]; then
        echo -e "${YELLOW}No backups found${NC}"
        echo -e "${BLUE}💡 Set up Time Machine first with --tm-setup${NC}"
    else
        echo "$backups" | tail -10
        echo -e "${BLUE}💡 Showing last 10 backups. Total: $(echo "$backups" | wc -l)${NC}"
    fi
}

tm_delete_old() {
    echo -e "${YELLOW}🗑️  Deleting Old Time Machine Backups...${NC}"
    echo -e "${RED}⚠️  WARNING: This will delete old backups to free space${NC}"
    
    read -p "Are you sure you want to delete old backups? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}✅ Operation cancelled${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}⏳ Attempting to delete backups older than 30 days...${NC}"
    
    if sudo tmutil delete -d 30 2>/dev/null; then
        echo -e "${GREEN}✅ Old backups deleted successfully${NC}"
    else
        echo -e "${YELLOW}🔄 Trying alternative method...${NC}"
        local latest_backup=$(tmutil latestbackup 2>/dev/null)
        if [ -n "$latest_backup" ]; then
            echo -e "${BLUE}💡 Latest backup: $latest_backup${NC}"
            echo -e "${YELLOW}📝 To delete old backups manually, run:${NC}"
            echo "sudo tmutil delete /Volumes/Time\ Machine\ Backups/Backups.backupdb"
        else
            echo -e "${YELLOW}📝 No backups found or Time Machine not configured${NC}"
        fi
        echo -e "${BLUE}💡 Set up Time Machine first with --tm-setup${NC}"
    fi
}

tm_exclude_list() {
    echo -e "${CYAN}📋 Current Time Machine Exclusions...${NC}"
    tmutil isexcluded "$HOME" | while read line; do
        if echo "$line" | grep -q "is excluded"; then
            echo -e "${RED}🚫 $line${NC}"
        else
            echo -e "${GREEN}✅ $line${NC}"
        fi
    done
}

tm_destination_info() {
    echo -e "${CYAN}💾 Time Machine Destination Info...${NC}"
    tmutil destinationinfo
}

tm_setup() {
    echo -e "${CYAN}🚀 Setting up Time Machine...${NC}"
    
    # Check for available drives
    echo -e "${BLUE}📀 Available Drives:${NC}"
    diskutil list | grep -E "(disk|Volume Name)" | head -20
    
    echo -e "${YELLOW}Please enter the path to your backup drive (e.g., /Volumes/ADATA):${NC}"
    read -r backup_drive
    
    if [ -z "$backup_drive" ]; then
        echo -e "${RED}❌ No drive specified${NC}"
        return 1
    fi
    
    if [ ! -d "$backup_drive" ]; then
        echo -e "${RED}❌ Drive not found: $backup_drive${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}⏳ Setting up Time Machine on $backup_drive...${NC}"
    
    # Set up Time Machine
    if sudo tmutil setdestination "$backup_drive"; then
        echo -e "${GREEN}✅ Time Machine destination set${NC}"
    else
        echo -e "${RED}❌ Failed to set destination${NC}"
        return 1
    fi
    
    # Enable automatic backups
    if sudo tmutil enable; then
        echo -e "${GREEN}✅ Automatic backups enabled${NC}"
    else
        echo -e "${RED}❌ Failed to enable automatic backups${NC}"
        return 1
    fi
    
    # Add common exclusions
    echo -e "${YELLOW}📝 Setting up smart exclusions...${NC}"
    sudo tmutil addexclusion -p "$HOME/Downloads" 2>/dev/null && echo "✅ Excluded Downloads"
    sudo tmutil addexclusion -p "$HOME/.cache" 2>/dev/null && echo "✅ Excluded .cache"
    sudo tmutil addexclusion -p "/Applications" 2>/dev/null && echo "✅ Excluded Applications"
    
    echo -e "${GREEN}🎉 Time Machine setup complete!${NC}"
    echo -e "${BLUE}💡 First backup will start automatically. Run --tm-start to start immediately.${NC}"
    
    # Show final status
    tm_status
}

# =============================================================================
# SIP MANAGEMENT FUNCTIONS
# =============================================================================

check_sip() {
    echo -e "🛡️  Checking SIP Status..."
    local status=$(csrutil status 2>/dev/null)
    if [ $? -eq 0 ]; then
        if echo "$status" | grep -q "enabled"; then
            echo -e "${GREEN}✅ SIP Enabled${NC}"
        elif echo "$status" | grep -q "disabled"; then
            echo -e "${RED}⚠️  SIP Disabled${NC}"
        else
            echo -e "${YELLOW}⚙️  SIP Custom${NC}"
        fi
        echo "$status"
    else
        echo -e "${RED}❌ Cannot check SIP${NC}"
    fi
}

get_sudo() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${YELLOW}🔐 Need sudo privileges...${NC}"
        sudo -v && return 0 || return 1
    fi
    return 0
}

enable_sip() {
    echo -e "${GREEN}🛡️  Enabling SIP...${NC}"
    if get_sudo; then
        if sudo csrutil enable 2>/dev/null; then
            echo -e "${GREEN}✅ SIP Enabled! Restart required.${NC}"
        else
            echo -e "${RED}❌ Failed. Try Recovery Mode.${NC}"
            echo -e "${YELLOW}📝 Recovery Mode: Shutdown → Hold Cmd+R → Terminal → csrutil enable${NC}"
        fi
    fi
}

disable_sip() {
    echo -e "${RED}⚠️  Disabling SIP...${NC}"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if get_sudo; then
            if sudo csrutil disable 2>/dev/null; then
                echo -e "${RED}🔓 SIP Disabled! Restart required.${NC}"
            else
                echo -e "${RED}❌ Failed. Try Recovery Mode.${NC}"
                echo -e "${YELLOW}📝 Recovery Mode: Shutdown → Hold Cmd+R → Terminal → csrutil disable${NC}"
            fi
        fi
    else
        echo -e "${GREEN}✅ Cancelled${NC}"
    fi
}

sip_recovery_help() {
    echo -e "${CYAN}🛡️  SIP Recovery Mode Instructions:${NC}"
    echo "========================================"
    echo "1. Shut down your Mac"
    echo "2. Hold Cmd+R and press Power button"
    echo "3. Wait for Recovery Mode to load"
    echo "4. Open Terminal from Utilities menu"
    echo "5. Run one of these commands:"
    echo "   - csrutil enable          # Enable full SIP"
    echo "   - csrutil disable         # Disable SIP" 
    echo "   - csrutil clear           # Reset to default"
    echo "   - csrutil status          # Check status"
    echo "6. Restart your Mac"
    echo ""
    echo "💡 Your current SIP status: Custom Configuration"
}

# =============================================================================
# SYSTEM CLEANING FUNCTIONS
# =============================================================================

clean_brew() {
    echo -e "🍺 Cleaning Homebrew..."
    if command -v brew >/dev/null; then
        brew cleanup && brew autoremove
        echo -e "✅ Homebrew cleaned"
    else
        echo -e "⚠️  Homebrew not found"
    fi
}

clean_npm() {
    echo -e "📦 Cleaning npm..."
    if command -v npm >/dev/null; then
        npm cache clean --force
        echo -e "✅ npm cleaned"
    else
        echo -e "⚠️  npm not found"
    fi
}

clean_docker() {
    echo -e "🐳 Cleaning Docker..."
    if command -v docker >/dev/null; then
        docker system prune -f
        echo -e "✅ Docker cleaned"
    else
        echo -e "⚠️  Docker not found"
    fi
}

clean_caches() {
    echo -e "💾 Cleaning caches..."
    local dirs=("$HOME/Library/Caches" "$HOME/Library/Logs" "$HOME/.cache")
    for dir in "${dirs[@]}"; do
        if [ -d "$dir" ]; then
            find "$dir" -type f -delete 2>/dev/null || true
        fi
    done
    echo -e "✅ Caches cleaned"
}

clean_python() {
    echo -e "🐍 Cleaning Python cache..."
    find "$HOME" -name "__pycache__" -type d -delete 2>/dev/null || true
    echo -e "✅ Python cache cleaned"
}

clean_trash() {
    echo -e "🗑️  Emptying Trash..."
    rm -rf ~/.Trash/* 2>/dev/null || true
    echo -e "✅ Trash emptied"
}

quick_clean() {
    echo -e "🧹 Quick cleaning..."
    brew cleanup 2>/dev/null && echo "✅ Homebrew cleaned"
    npm cache clean --force 2>/dev/null && echo "✅ npm cache cleaned"
    docker system prune -f 2>/dev/null && echo "✅ Docker cleaned"
    echo -e "✅ Quick clean complete!"
}

# =============================================================================
# MAIN FUNCTIONS & HELP
# =============================================================================

show_help() {
    echo "CleanMac Pro - All-in-One macOS Management"
    echo ""
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "System Cleaning:"
    echo "  --clean         Run all system cleaners"
    echo "  --quick-clean   Fast cleanup (Homebrew, npm, Docker only)"
    echo "  --dry-run       Show what would be cleaned"
    echo ""
    echo "SIP Management:"
    echo "  --sip-status    Check SIP status"
    echo "  --sip-enable    Enable SIP (sudo)"
    echo "  --sip-disable   Disable SIP (sudo)"
    echo "  --sip-help      Show Recovery Mode instructions"
    echo ""
    echo "Time Machine:"
    echo "  --tm-status     Check Time Machine status & info"
    echo "  --tm-start      Start Time Machine backup"
    echo "  --tm-stop       Stop Time Machine backup"
    echo "  --tm-list       List recent backups"
    echo "  --tm-delete-old Delete backups older than 30 days"
    echo "  --tm-exclude    Show exclusion list"
    echo "  --tm-dest-info  Show destination info"
    echo "  --tm-setup      Set up Time Machine (interactive)"
    echo ""
    echo "System Info:"
    echo "  --disk-info     Show disk usage information"
    echo "  --sys-info      Show system overview"
    echo ""
    echo "Help:"
    echo "  --help          Show this help"
    echo ""
    echo "Examples:"
    echo "  $0 --clean                    # Full system cleanup"
    echo "  $0 --tm-setup                 # Set up Time Machine"
    echo "  $0 --sip-status --tm-status   # Check security & backups"
    echo "  $0 --disk-info --sys-info     # System health check"
}

disk_info() {
    echo -e "${CYAN}💾 Disk Usage Information:${NC}"
    echo "=============================="
    df -h | grep -E "(Filesystem|/dev/disk)"
    echo ""
    echo -e "${BLUE}📁 Home Directory Usage:${NC}"
    du -sh ~/ 2>/dev/null | cut -f1
}

sys_info() {
    echo -e "${CYAN}🖥️  System Information:${NC}"
    echo "=========================="
    echo -e "${BLUE}Model:${NC} $(sysctl -n hw.model)"
    echo -e "${BLUE}Processor:${NC} $(sysctl -n machdep.cpu.brand_string)"
    echo -e "${BLUE}Memory:${NC} $(sysctl -n hw.memsize | awk '{print $1/1024/1024/1024 " GB"}')"
    echo -e "${BLUE}macOS:${NC} $(sw_vers -productVersion)"
    echo -e "${BLUE}Storage:${NC} $(diskutil info / | grep "Container Total Space:" | cut -d: -f2 | sed 's/^ *//')"
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

main() {
    case "${1:-}" in
        # System Cleaning
        "--clean")
            check_sip
            echo "=================================="
            clean_brew
            clean_npm
            clean_docker
            clean_caches
            clean_python
            clean_trash
            echo -e "${GREEN}✅ All clean!${NC}"
            ;;
        "--quick-clean")
            quick_clean
            ;;
        "--dry-run")
            echo -e "${YELLOW}🧹 DRY RUN - Nothing will be deleted:${NC}"
            echo "• Homebrew cache & old versions"
            echo "• npm cache"
            echo "• Docker system"
            echo "• System caches & logs"
            echo "• Python __pycache__ directories"
            echo "• Trash contents"
            ;;
            
        # SIP Management
        "--sip-status")
            check_sip
            ;;
        "--sip-enable")
            enable_sip
            ;;
        "--sip-disable")
            disable_sip
            ;;
        "--sip-help")
            sip_recovery_help
            ;;
            
        # Time Machine Management
        "--tm-status")
            tm_status
            ;;
        "--tm-start")
            tm_start
            ;;
        "--tm-stop")
            tm_stop
            ;;
        "--tm-list")
            tm_list_backups
            ;;
        "--tm-delete-old")
            tm_delete_old
            ;;
        "--tm-exclude")
            tm_exclude_list
            ;;
        "--tm-dest-info")
            tm_destination_info
            ;;
        "--tm-setup")
            tm_setup
            ;;
            
        # System Information
        "--disk-info")
            disk_info
            ;;
        "--sys-info")
            sys_info
            ;;
            
        # Help
        "--help"|"-h"|"")
            show_help
            ;;
        *)
            echo -e "${RED}❌ Unknown option: $1${NC}"
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"

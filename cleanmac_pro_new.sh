#!/bin/bash

# CleanMac Pro - Advanced macOS Optimization Suite
# GitHub: https://github.com/Dan13681989/cleanmac

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to show help
show_help() {
    cat << EOF
CleanMac Pro - All-in-One macOS Management

Usage: $0 [OPTION]

System Cleaning:
  --clean         Run all system cleaners
  --quick-clean   Fast cleanup (Homebrew, npm, Docker only)
  --dry-run       Show what would be cleaned

SIP Management:
  --sip-status    Check SIP status
  --sip-enable    Enable SIP (sudo)
  --sip-disable   Disable SIP (sudo)
  --sip-help      Show Recovery Mode instructions

Time Machine:
  --tm-status     Check Time Machine status & info
  --tm-start      Start Time Machine backup
  --tm-stop       Stop Time Machine backup
  --tm-list       List recent backups

System Info:
  --disk-info     Show disk usage information
  --sys-info      Show system overview

Help:
  --help          Show this help

Examples:
  $0 --clean                    # Full system cleanup
  $0 --sip-status --tm-status   # Check security & backups
  $0 --disk-info --sys-info     # System health check
EOF
}

# Function to check SIP status
check_sip_status() {
    echo -e "${BLUE}🛡️  Checking SIP Status...${NC}"
    csrutil status
}

# Function to show system info
show_system_info() {
    echo -e "${BLUE}🖥️  System Information:${NC}"
    echo "=========================="
    echo "Model: $(sysctl -n hw.model)"
    echo "Processor: $(sysctl -n machdep.cpu.brand_string)"
    echo "Memory: $(sysctl -n hw.memsize | awk '{print $1/1024/1024/1024 " GB"}')"
    echo "macOS: $(sw_vers -productVersion)"
    echo "Storage: $(diskutil info / | grep "Container Total Space:" | cut -d: -f2 | sed 's/^ *//')"
}

# Function to show disk info
show_disk_info() {
    echo -e "${BLUE}💾 Disk Usage Information:${NC}"
    echo "=============================="
    df -h | grep -E "(Filesystem|/dev/disk)"
    echo -e "\n${BLUE}📁 Home Directory Usage:${NC}"
    du -sh ~ | cut -f1
}

# Function to check Time Machine status
check_tm_status() {
    echo -e "${BLUE}🕐 Checking Time Machine Status...${NC}"
    tmutil status
}

# Function to start Time Machine backup
start_tm_backup() {
    echo -e "${BLUE}🔄 Starting Time Machine Backup...${NC}"
    tmutil startbackup
    echo -e "${GREEN}✅ Backup started successfully${NC}"
}

# Function to stop Time Machine backup
stop_tm_backup() {
    echo -e "${BLUE}⏹️  Stopping Time Machine Backup...${NC}"
    tmutil stopbackup
    echo -e "${GREEN}✅ Backup stopped successfully${NC}"
}

# Function to list Time Machine backups
list_tm_backups() {
    echo -e "${BLUE}📚 Listing Time Machine Backups...${NC}"
    tmutil listbackups | tail -10
    local total=$(tmutil listbackups | wc -l)
    echo -e "${BLUE}💡 Showing last 10 backups. Total: $total${NC}"
}

# Function to clean Homebrew
clean_homebrew() {
    echo -e "${BLUE}🍺 Cleaning Homebrew...${NC}"
    if command -v brew &> /dev/null; then
        brew cleanup
        brew autoremove
        echo -e "${GREEN}✅ Homebrew cleaned${NC}"
    else
        echo -e "${YELLOW}⚠️  Homebrew not installed, skipping${NC}"
    fi
}

# Function to clean npm
clean_npm() {
    echo -e "${BLUE}📦 Cleaning npm...${NC}"
    if command -v npm &> /dev/null; then
        npm cache clean --force
        echo -e "${GREEN}✅ npm cleaned${NC}"
    else
        echo -e "${YELLOW}⚠️  npm not installed, skipping${NC}"
    fi
}

# Function to clean Docker
clean_docker() {
    echo -e "${BLUE}🐳 Cleaning Docker...${NC}"
    if command -v docker &> /dev/null; then
        docker system prune -f
        echo -e "${GREEN}✅ Docker cleaned${NC}"
    else
        echo -e "${YELLOW}⚠️  Docker not installed, skipping${NC}"
    fi
}

# Function to clean caches
clean_caches() {
    echo -e "${BLUE}💾 Cleaning caches...${NC}"
    rm -rf ~/Library/Caches/*
    rm -rf /Library/Caches/*
    echo -e "${GREEN}✅ Caches cleaned${NC}"
}

# Function to clean Python cache
clean_python_cache() {
    echo -e "${BLUE}🐍 Cleaning Python cache...${NC}"
    find ~ -name "__pycache__" -type d -delete 2>/dev/null || true
    echo -e "${GREEN}✅ Python cache cleaned${NC}"
}

# Function to empty trash
empty_trash() {
    echo -e "${BLUE}🗑️  Emptying Trash...${NC}"
    rm -rf ~/.Trash/*
    echo -e "${GREEN}✅ Trash emptied${NC}"
}

# Function for dry run
dry_run() {
    echo -e "${YELLOW}🧹 DRY RUN - Nothing will be deleted:${NC}"
    echo "• Homebrew cache & old versions"
    echo "• npm cache"
    echo "• Docker system"
    echo "• System caches & logs"
    echo "• Python __pycache__ directories"
    echo "• Trash contents"
}

# Function for quick clean
quick_clean() {
    echo -e "${BLUE}🧹 Quick cleaning...${NC}"
    clean_homebrew
    clean_npm
    clean_docker
    echo -e "${GREEN}✅ Quick clean complete!${NC}"
}

# Function for full clean
full_clean() {
    echo -e "${BLUE}🚀 Starting full system cleanup...${NC}"
    check_sip_status
    echo "=================================="
    clean_homebrew
    clean_npm
    clean_docker
    clean_caches
    clean_python_cache
    empty_trash
    echo -e "${GREEN}✅ All clean!${NC}"
}

# Main argument parsing
case "${1:-}" in
    "--clean")
        full_clean
        ;;
    "--quick-clean")
        quick_clean
        ;;
    "--dry-run")
        dry_run
        ;;
    "--sip-status")
        check_sip_status
        ;;
    "--sys-info")
        show_system_info
        ;;
    "--disk-info")
        show_disk_info
        ;;
    "--tm-status")
        check_tm_status
        ;;
    "--tm-start")
        start_tm_backup
        ;;
    "--tm-stop")
        stop_tm_backup
        ;;
    "--tm-list")
        list_tm_backups
        ;;
    "--help"|"")
        show_help
        ;;
    *)
        echo -e "${RED}❌ Unknown option: $1${NC}"
        echo ""
        show_help
        exit 1
        ;;
esac

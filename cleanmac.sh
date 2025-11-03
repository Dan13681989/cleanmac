#!/bin/bash

# CleanMac - Comprehensive macOS Cleaning Script
# GitHub: https://github.com/Dan13681989/cleanmac

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
DRY_RUN=false
INTERACTIVE=false
BACKUP=false
TOTAL_SPACE_SAVED=0

# Display help
show_help() {
    cat << EOF
Usage: $0 [OPTIONS]

CleanMac - Comprehensive macOS Cleaning Script

OPTIONS:
    -d, --dry-run       Show what would be deleted without actually 
deleting
    -i, --interactive   Prompt before each cleanup operation
    -b, --backup        Create backup before cleaning (not implemented 
yet)
    -h, --help          Show this help message

EXAMPLES:
    $0                  # Run normal cleanup
    $0 --dry-run        # Show what would be cleaned
    $0 --interactive    # Run with prompts for each operation

EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -i|--interactive)
            INTERACTIVE=true
            shift
            ;;
        -b|--backup)
            BACKUP=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

# Confirm before proceeding
confirm_action() {
    local message="$1"
    if [ "$INTERACTIVE" = true ]; then
        echo -e "${YELLOW}❓ $message (y/N): ${NC}"
        read -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 1
        fi
    fi
    return 0
}

# Calculate directory size
get_size() {
    local dir="$1"
    if [ -d "$dir" ]; then
        du -sh "$dir" 2>/dev/null | cut -f1 || echo "0B"
    else
        echo "0B"
    fi
}

# Homebrew cleanup
brew_cleanup() {
    echo -e "${BLUE}🍺 Cleaning Homebrew...${NC}"
    
    if command -v brew &> /dev/null; then
        if [ "$DRY_RUN" = true ]; then
            echo -e "${YELLOW}[DRY RUN] Would run: brew cleanup${NC}"
            echo -e "${YELLOW}[DRY RUN] Would run: brew autoremove${NC}"
        else
            if confirm_action "Clean Homebrew cache and remove old 
versions?"; then
                brew cleanup
                brew autoremove
                echo -e "${GREEN}✅ Homebrew cleaned${NC}"
            fi
        fi
    else
        echo -e "${YELLOW}⚠️  Homebrew not installed, skipping${NC}"
    fi
}

# npm cleanup
npm_cleanup() {
    echo -e "${BLUE}📦 Cleaning npm cache...${NC}"
    
    if command -v npm &> /dev/null; then
        if [ "$DRY_RUN" = true ]; then
            echo -e "${YELLOW}[DRY RUN] Would run: npm cache clean 
--force${NC}"
        else
            if confirm_action "Clean npm cache?"; then
                npm cache clean --force
                echo -e "${GREEN}✅ npm cache cleaned${NC}"
            fi
        fi
    else
        echo -e "${YELLOW}⚠️  npm not installed, skipping${NC}"
    fi
}

# Docker cleanup
docker_cleanup() {
    echo -e "${BLUE}🐳 Cleaning Docker...${NC}"
    
    if command -v docker &> /dev/null; then
        if [ "$DRY_RUN" = true ]; then
            echo -e "${YELLOW}[DRY RUN] Would run: docker system prune 
-f${NC}"
        else
            if confirm_action "Clean Docker system (remove unused 
containers, images, networks)?"; then
                docker system prune -f
                echo -e "${GREEN}✅ Docker cleaned${NC}"
            fi
        fi
    else
        echo -e "${YELLOW}⚠️  Docker not installed, skipping${NC}"
    fi
}

# System cache cleanup
system_cache_cleanup() {
    echo -e "${BLUE}💾 Cleaning system caches...${NC}"
    
    local cache_dirs=(
        "$HOME/Library/Caches"
        "/Library/Caches"
        "/System/Library/Caches"
    )
    
    for cache_dir in "${cache_dirs[@]}"; do
        if [ -d "$cache_dir" ]; then
            local size=$(get_size "$cache_dir")
            if [ "$DRY_RUN" = true ]; then
                echo -e "${YELLOW}[DRY RUN] Would clean: $cache_dir 
($size)${NC}"
            else
                if confirm_action "Clean $cache_dir ($size)?"; then
                    rm -rf "$cache_dir"/*
                    echo -e "${GREEN}✅ Cleaned $cache_dir${NC}"
                fi
            fi
        fi
    done
}

# User cache cleanup
user_cache_cleanup() {
    echo -e "${BLUE}👤 Cleaning user caches...${NC}"
    
    local user_caches=(
        "$HOME/Library/Developer/Xcode/DerivedData"
        "$HOME/Library/Developer/Xcode/Archives"
        "$HOME/Library/Logs"
        "$HOME/.npm"
        "$HOME/.cache"
    )
    
    for cache_dir in "${user_caches[@]}"; do
        if [ -d "$cache_dir" ]; then
            local size=$(get_size "$cache_dir")
            if [ "$DRY_RUN" = true ]; then
                echo -e "${YELLOW}[DRY RUN] Would clean: $cache_dir 
($size)${NC}"
            else
                if confirm_action "Clean $cache_dir ($size)?"; then
                    rm -rf "$cache_dir"/*
                    echo -e "${GREEN}✅ Cleaned $cache_dir${NC}"
                fi
            fi
        fi
    done
}

# Python cleanup
python_cleanup() {
    echo -e "${BLUE}🐍 Cleaning Python cache...${NC}"
    
    # Clean __pycache__ directories
    if command -v find &> /dev/null; then
        if [ "$DRY_RUN" = true ]; then
            local pycache_count=$(find "$HOME" -name "__pycache__" -type d 
2>/dev/null | wc -l)
            echo -e "${YELLOW}[DRY RUN] Would remove $pycache_count 
__pycache__ directories${NC}"
        else
            if confirm_action "Remove Python __pycache__ directories?"; 
then
                find "$HOME" -name "__pycache__" -type d -exec rm -rf {} + 
2>/dev/null || true
                echo -e "${GREEN}✅ Python cache cleaned${NC}"
            fi
        fi
    fi
}

# Empty Trash
empty_trash() {
    echo -e "${BLUE}🗑️  Emptying Trash...${NC}"
    
    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}[DRY RUN] Would empty Trash${NC}"
    else
        if confirm_action "Empty the Trash?"; then
            rm -rf "$HOME/.Trash"/*
            echo -e "${GREEN}✅ Trash emptied${NC}"
        fi
    fi
}

# Main cleanup function
main_cleanup() {
    echo -e "${GREEN}🚀 Starting CleanMac...${NC}"
    echo "=========================================="
    
    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}⚠️  DRY RUN MODE - No files will be 
deleted${NC}"
        echo "=========================================="
    fi
    
    # Run all cleanup functions
    brew_cleanup
    npm_cleanup
    docker_cleanup
    system_cache_cleanup
    user_cache_cleanup
    python_cleanup
    empty_trash
    
    echo "=========================================="
    echo -e "${GREEN}✅ CleanMac completed!${NC}"
    
    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}This was a dry run. Run without --dry-run to 
actually clean.${NC}"
    fi
}

# Run the script
main_cleanup

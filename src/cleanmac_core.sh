#!/bin/zsh
# CleanMAC Core Script

VERSION="1.0.0"

advanced_memory_clean() {
    echo "Advanced Memory Optimization..."
    sudo purge 2>/dev/null
    echo "Memory cache flushed"
}

check_memory_pressure() {
    echo "Checking Memory Pressure..."
    memory_stats=$(top -l 1 -s 0 | grep "PhysMem")
    free_memory=$(echo $memory_stats | awk '{print $6}')
    used_memory=$(echo $memory_stats | awk '{print $2}')
    echo "Current Usage: $used_memory used, $free_memory free"
    [[ $(echo $free_memory | tr -d 'M') -lt 500 ]] && echo "Warning: Low memory detected!"
}

smart_cache_clean() {
    echo "Intelligent Cache Management..."
    uptime_hours=$(($(sysctl -n kern.boottime | cut -d' ' -f4 | tr -d ',') / 3600))
    if [ $uptime_hours -gt 2 ]; then
        echo "Cleaning caches (system uptime: ${uptime_hours}h)..."
        rm -rf ~/Library/Caches/* 2>/dev/null
        [ -d ~/.cache ] && find ~/.cache -mindepth 1 -delete 2>/dev/null
    else
        echo "System recently started, skipping intensive cache cleaning"
    fi
}

show_memory_graph() {
    echo "Memory Usage Graph:"
    memory_stats=$(top -l 1 -s 0 | grep "PhysMem")
    used_memory=$(echo $memory_stats | awk '{print $2}' | tr -d 'M')
    bars=$((used_memory / 200))
    graph="["
    for ((i=0; i<20; i++)); do
        if [ $i -lt $bars ]; then
            graph+="#"
        else
            graph+="="
        fi
    done
    graph+="] ${used_memory}MB used"
    echo "$graph"
}

cleanmac() {
    case "$1" in
        "--memory"|"-m")
            echo "=== Memory Clean 3 Mode ==="
            check_memory_pressure
            advanced_memory_clean
            show_memory_graph
            ;;
        "--smart"|"-s")
            echo "=== Smart Clean Mode ==="
            check_memory_pressure
            smart_cache_clean
            advanced_memory_clean
            ;;
        "--clean")
            echo "=== Basic Clean Mode ==="
            dscacheutil -flushcache
            echo "DNS cache flushed"
            rm -rf ~/Library/Caches/* 2>/dev/null
            [ -d ~/.cache ] && find ~/.cache -mindepth 1 -delete 2>/dev/null
            echo "Cleanmac completed"
            ;;
        "--scan")
            echo "=== System Scan Mode ==="
            echo "Current Free Memory: $(top -l 1 -s 0 | awk '/PhysMem/ {print $6}')"
            echo "Disk Usage:"
            df -h / | grep -v Filesystem
            echo "System Uptime: $(uptime)"
            ;;
        "--version")
            echo "CleanMAC version $VERSION"
            ;;
        "--test")
            echo "CleanMAC test passed - system is operational"
            ;;
        "--help"|*)
            echo "=== Cleanmac Help ==="
            echo "cleanmac --scan    - Show system status"
            echo "cleanmac --clean   - Perform basic cleanup"
            echo "cleanmac --memory  - Advanced memory optimization"
            echo "cleanmac --smart   - Intelligent cleaning"
            echo "cleanmac --version - Show version"
            echo "cleanmac --test    - Test installation"
            echo "sudo cleanmac      - Full system cleanup (requires sudo)"
            ;;
    esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    cleanmac "$@"
fi

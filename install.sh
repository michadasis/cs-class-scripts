#!/bin/bash

LOG_FILE="/var/log/conversion_status.log"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}
source scripts/check_sudo.sh
check_sudo
source scripts/run.sh
source scripts/editions/core.sh
source scripts/editions/home.sh
source scripts/editions/security.sh
source scripts/editions/htb.sh

check_system() {
    log "Performing system checks..."
    
    # Simple check if running Debian (Le'ts ignore for this project.)
    #if ! grep -q "Debian" /etc/os-release; then
    #    log "ERROR: This script requires Debian"
    #    return 1
    #fi
    
    local required_space=15000 # 15GB in MB
    local available_space=$(df -m / | awk 'NR==2 {print $4}')
        
        if [ "$available_space" -lt "$required_space" ]; then
            log "ERROR: Insufficient disk space. Required: 15 GB, Available: ${available_space}MB"
            return 1
        fi
    
    log "System checks passed successfully"
    return 0
}

display_menu() {
    clear
    echo "╔═════════════════════════════════════════════╗"
    echo "║        UoWM Debian Script                   ║"
    echo "╠═════════════════════════════════════════════╣"
    echo "║ 1) Core					║" 
    echo "║    Install all of the department's programs ║"
    echo "║ 2) Exit                                     ║"
    echo "╚═════════════════════════════════════════════╝"
}

install_edition() {
    local edition=$1
    log "Starting installation of $edition"
    
    if ! check_system; then
        log "System checks failed. Installation aborted."
        return 1
    fi
    
    log "Updating package lists..."
    apt-get update
    
    case $edition in
        "core") core ;;
        *) log "Invalid edition selected"; return 1 ;;
    esac
    
    log "Installation of $edition edition completed successfully!"
}

touch "$LOG_FILE"
log "Installation script started..."

while true; do
    display_menu
    read -p "Enter the option number: " option
    case $option in
        1) install_edition "core" ;;
        2) log "Exiting installation script..."; exit 0 ;;
        *) echo "Invalid option. Please try again." ;;
    esac
    
    read -p "Press Enter to continue..."
done

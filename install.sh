#!/bin/bash

# Source necessary scripts
source scripts/check_sudo.sh
source scripts/editions/core.sh
source scripts/env_checker.sh
source scripts/editions/home.sh
source scripts/editions/security.sh
source scripts/editions/htb.sh
source scripts/editions/headless.sh

# Function to display menu
display_menu() {
    echo "========== ParrotOS Editions Installer =========="
    echo "1) Install Core Edition: Minimal installation for server use."
    echo "2) Install Home Edition: Full desktop environment for daily use."
    echo "3) Install Security Edition: Tools for security testing and auditing."
    echo "4) Install Hack The Box Edition: Customized environment for Hack The Box labs."
    echo "5) Install Headless Edition: Minimal installation without GUI for servers."
    echo "6) Exit"
    echo "================================================="
}

# Check for sudo privileges
check_sudo

# Validate the environment
echo "🔧 Validating environment setup..."
ensure_environment || { 
    echo "❌ Environment validation failed. Please resolve the issues and try again."
    exit 1
}
echo "✅ Environment is ready."

# Main menu loop
while true; do
    display_menu
    read -p "Enter the option number: " option
    case $option in
        1) core ;;                                    # Install Core Edition
        2) core && home ;;                            # Install Core + Home Edition
        3) core && security ;;                        # Install Core + Security Edition
        4) core && htb ;;                             # Install Core + HTB Edition
        5) core && headless ;;                        # Install Core + Headless Edition
        6) echo "Exiting..."; exit 0 ;;               # Exit script
        *) echo "Invalid option. Please try again." ;; # Invalid input handling
    esac
done


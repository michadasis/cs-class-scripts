#!/bin/bash

# Color variables for output formatting
endColor="\e[0m"
redColor="\e[31m"
greenColor="\e[32m"
yellowColor="\e[33m"

# Trap for CTRL+C to exit gracefully
trap ctrl_c INT
ctrl_c() {
    echo -e "\n${yellowColor}Exiting script...${endColor}"
    exit 1
}

# Function to validate APT repository configuration
validate_apt_sources() {
    echo -e "${yellowColor}🔍 Validating APT repository configuration...${endColor}"

    if ! grep -q "deb https://deb.parrot.sh/parrot" /etc/apt/sources.list; then
        echo -e "${redColor}❌ ParrotSec APT repository is missing. Adding it now...${endColor}"
        echo "deb https://deb.parrot.sh/parrot lory main contrib non-free non-free-firmware" | sudo tee -a /etc/apt/sources.list
    else
        echo -e "${greenColor}✅ ParrotSec APT repository is configured correctly.${endColor}"
    fi
}

# Function to validate security repository
validate_security_repo() {
    echo -e "${yellowColor}🔍 Validating security repository configuration...${endColor}"

    if ! grep -q "deb https://deb.parrot.sh/direct/parrot lory-security" /etc/apt/sources.list; then
        echo -e "${redColor}❌ Security repository is missing. Adding it now...${endColor}"
        echo "deb https://deb.parrot.sh/direct/parrot lory-security main contrib non-free non-free-firmware" | sudo tee -a /etc/apt/sources.list
    else
        echo -e "${greenColor}✅ Security repository is configured correctly.${endColor}"
    fi
}

# Function to configure the best mirror
configure_best_mirror() {
    echo -e "${yellowColor}🔄 Configuring the best mirror for faster downloads...${endColor}"
    sudo sed -i 's|https://deb.parrot.sh/parrot|https://mirror.0x.sg/parrot|g' /etc/apt/sources.list
    sudo apt update
    echo -e "${greenColor}✅ Best mirror configured successfully.${endColor}"
}

# Function to ensure a package is installed
ensure_package_installed() {
    local package=$1
    echo -e "${yellowColor}🔍 Checking for $package...${endColor}"

    if ! dpkg -l | grep -q "^ii  $package "; then
        echo -e "${redColor}❌ $package is not installed. Installing...${endColor}"
        sudo apt-get install -y "$package"
        if [ $? -ne 0 ]; then
            echo -e "${redColor}❌ Failed to install $package. Exiting.${endColor}"
            exit 1
        fi
        echo -e "${greenColor}✅ $package installed successfully.${endColor}"
    else
        echo -e "${greenColor}✅ $package is already installed.${endColor}"
    fi
}

# Function to ensure tools are installed
ensure_environment() {
    echo -e "${yellowColor}🔧 Ensuring all required tools are installed...${endColor}"

    # Define tools to validate
    declare -a tools=(
        "nmap"
        "curl"
        "wireshark"
    )

    # Loop through tools and ensure they are installed
    for tool in "${tools[@]}"; do
        ensure_package_installed "$tool"
    done

    echo -e "${greenColor}🎉 All tools are installed and up to date!${endColor}"
}

# Main function
main() {
    validate_apt_sources
    validate_security_repo
    configure_best_mirror
    ensure_environment
}

# Run the main function
main


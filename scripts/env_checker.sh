#!/bin/bash

# Define colors for output
endColor="\e[0m"
redColor="\e[31m"
greenColor="\e[32m"
yellowColor="\e[33m"

# List of ParrotSec mirrors
MIRRORS=(
    "https://deb.parrot.sh/parrot"
    "https://mirror.0x.sg/parrot"
    "https://mirror.yandex.ru/mirrors/parrot"
    "https://parrot.mirror.garr.it/mirrors/parrot"
    "https://ftp.nluug.nl/os/Linux/distr/parrot"
)

# Define tools for each edition
declare -a HOME_TOOLS=("vlc" "firefox" "libreoffice")          # Tools for the Home Edition
declare -a SECURITY_TOOLS=("nmap" "wireshark")                 # Tools for the Security Edition

# Function to check if a package is available in the repository
is_package_available() {
    local package=$1
    apt-cache show "$package" > /dev/null 2>&1
    return $?
}

# Function to ensure a package is installed, only if available
ensure_package_installed() {
    local package=$1
    echo -e "${yellowColor}Checking if $package is installed...${endColor}"
    if ! is_package_available "$package"; then
        echo -e "${redColor}⚠️ $package is not available in the repositories. Skipping...${endColor}"
        return
    fi

    if ! dpkg -l | grep -q "^ii  $package "; then
        echo -e "${yellowColor}Installing $package...${endColor}"
        apt-get install -y "$package"
        if [ $? -eq 0 ]; then
            echo -e "${greenColor}✅ $package installed successfully.${endColor}"
        else
            echo -e "${redColor}❌ Failed to install $package.${endColor}"
        fi
    else
        echo -e "${greenColor}✅ $package is already installed.${endColor}"
    fi
}

# Function to validate APT repository configuration
validate_apt_sources() {
    echo -e "${yellowColor}Validating APT repository configuration...${endColor}"
    if ! grep -q "deb https://deb.parrot.sh/parrot" /etc/apt/sources.list; then
        echo -e "${redColor}ParrotSec APT repository is missing. Adding it now...${endColor}"
        echo "deb https://deb.parrot.sh/parrot lory main contrib non-free non-free-firmware" | sudo tee -a /etc/apt/sources.list
    else
        echo -e "${greenColor}ParrotSec APT repository is configured correctly.${endColor}"
    fi
}

# Function to validate security repository configuration
validate_security_repo() {
    echo -e "${yellowColor}Validating security repository configuration...${endColor}"
    if ! grep -q "deb https://deb.parrot.sh/direct/parrot lory-security" /etc/apt/sources.list; then
        echo -e "${redColor}Security repository is missing. Adding it now...${endColor}"
        echo "deb https://deb.parrot.sh/direct/parrot lory-security main contrib non-free non-free-firmware" | sudo tee -a /etc/apt/sources.list
    else
        echo -e "${greenColor}Security repository is configured correctly.${endColor}"
    fi
}

# Function to configure the fastest mirror
configure_best_mirror() {
    echo -e "${yellowColor}🔄 Finding the fastest mirror for your location...${endColor}"
    local best_mirror=""
    local best_time=1000000  # Arbitrary high initial value for latency

    for mirror in "${MIRRORS[@]}"; do
        echo -e "Pinging $mirror..."
        local start_time=$(date +%s%N)
        curl -s --head --connect-timeout 5 "$mirror" > /dev/null
        local end_time=$(date +%s%N)

        # Calculate elapsed time in milliseconds
        local elapsed=$(( (end_time - start_time) / 1000000 ))

        if [ $? -eq 0 ] && [ $elapsed -lt $best_time ]; then
            best_time=$elapsed
            best_mirror=$mirror
        fi
        echo -e "Latency: ${elapsed}ms"
    done

    # If no mirror was reachable, use the default
    if [ -z "$best_mirror" ]; then
        echo -e "${redColor}❌ No mirrors were reachable. Using default repository.${endColor}"
        best_mirror="https://deb.parrot.sh/parrot"
    fi

    echo -e "${greenColor}✅ Best mirror: $best_mirror${endColor}"

    # Update sources.list to use the best mirror
    sudo sed -i "s|https://deb.parrot.sh/parrot|$best_mirror|g" /etc/apt/sources.list
}

# Function to install tools based on edition
install_tools() {
    local edition=$1
    echo -e "${yellowColor}Installing tools for the $edition edition...${endColor}"

    local tools
    if [ "$edition" == "home" ]; then
        tools=("${HOME_TOOLS[@]}")
    elif [ "$edition" == "security" ]; then
        tools=("${SECURITY_TOOLS[@]}")
    else
        echo -e "${redColor}Unknown edition: $edition. Valid options are 'home' or 'security'.${endColor}"
        exit 1
    fi

    for tool in "${tools[@]}"; do
        ensure_package_installed "$tool"
    done

    echo -e "${greenColor}All tools for the $edition edition are installed.${endColor}"
}

# Main function to validate the environment and install tools
main() {
    if [ $# -ne 1 ]; then
        echo -e "${redColor}Usage: $0 <home|security>${endColor}"
        echo "Example: $0 home"
        echo "         $0 security"
        exit 1
    fi

    local edition=$1

    # Validate environment
    validate_apt_sources
    validate_security_repo
    configure_best_mirror

    # Install tools for the selected edition
    install_tools "$edition"
}

# Run the main function
main "$@"






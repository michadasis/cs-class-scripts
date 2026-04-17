#!/bin/bash

source scripts/run.sh
source scripts/install_packages.sh
source scripts/install_toulopoulos_stack.sh

core() {
    local core_packages
    mapfile -t core_packages < config/packages/core.txt

    run "wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg | gpg --dearmor | dd of=/usr/share/keyrings/vscodium-archive-keyring.gpg" "Adding VSCodium GPG key"
    run "echo 'deb [ signed-by=/usr/share/keyrings/vscodium-archive-keyring.gpg ] https://download.vscodium.com/debs vscodium main' | tee /etc/apt/sources.list.d/vscodium.list" "Adding VSCodium repository"

    # direct download DBeaver DEB package because the repository is not reliable
    run "wget https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb -O /tmp/dbeaver-ce.deb" "Downloading DBeaver DEB package"
    run "apt install -y /tmp/dbeaver-ce.deb" "Installing DBeaver from DEB"
    install_toulopoulos_stack "Installing Toulopoulos stack"

    run "apt update" "Updating package lists"
    install_packages "${core_packages[@]}"

    run "apt upgrade -y" "Upgrading packages"
}

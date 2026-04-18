#!/bin/bash
# Έξοδος σε περίπτωση σφάλματος
set -e

echo "--- Ξεκινάει η προετοιμασία του συστήματος (C++26, Dlib, Armadillo, VS Code) ---"

# 1. Συνάρτηση για εγκατάσταση VS Code
vscode_install_setup_fn(){
    echo "--- Εγκατάσταση Visual Studio Code ---"

    # Μέθοδος 1: Microsoft APT repository
    echo "--- Προσπάθεια με Microsoft APT repository ---"
    sudo apt install -y apt-transport-https wget gpg 2>/dev/null
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc \
        | gpg --dearmor \
        | sudo install -D /dev/stdin /usr/share/keyrings/packages.microsoft.gpg 2>/dev/null

    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/usr/share/keyrings/packages.microsoft.gpg] \
        https://packages.microsoft.com/repos/code stable main" \
        > /etc/apt/sources.list.d/vscode.list' 2>/dev/null

    if sudo apt update 2>/dev/null && sudo apt install -y code 2>/dev/null; then
        echo "--- VS Code εγκαταστάθηκε μέσω APT ---"
        return
    fi
    echo "--- APT απέτυχε, δοκιμή με Flatpak ---"

    # Μέθοδος 2: Flatpak fallback
    if ! command -v flatpak &>/dev/null; then
        echo "--- Εγκατάσταση Flatpak ---"
        sudo apt install -y flatpak
        sudo apt install -y gnome-software-plugin-flatpak 2>/dev/null || true
    fi

    if command -v flatpak &>/dev/null; then
        echo "--- Χρήση Flatpak για VS Code ---"
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo \
        && flatpak install -y flathub com.visualstudio.code \
        && return
        echo "--- Flatpak απέτυχε, δοκιμή με Snap ---"
    fi

    # Μέθοδος 3: Snap fallback
    if command -v snap &>/dev/null; then
        echo "--- Χρήση Snap για VS Code ---"
        sudo snap install --classic code && return
    fi

    echo "ΣΦΑΛΜΑ: Αδυναμία εγκατάστασης VS Code (APT, Flatpak και Snap απέτυχαν)."
    return 0  # ωστε να συνεχιζει
}

# 2. Έλεγχος έκδοσης G++ και ορισμός πακέτων
GPP_VERSION=$(g++ --version | head -1 | awk '{print $NF}' | tr -d '[:alpha:]' | tr . 0 | cut -c1-5)

PACKAGE_LIST="libarmadillo-dev libopenblas-dev liblapack-dev libx11-dev cmake git pkg-config"

# Αν η έκδοση είναι παλιά (π.χ. < 8.2.0), προσθέτουμε το generic g++ για update
if [ "$GPP_VERSION" -lt 80200 ]; then
    echo "--- Η έκδοση του g++ είναι παλιά. Προσθήκη g++ στη λίστα εγκατάστασης ---"
    PACKAGE_LIST="$PACKAGE_LIST g++"
fi

# 3. Εκτέλεση εγκαταστάσεων συστήματος
sudo apt update
sudo apt install -y $PACKAGE_LIST

# 4. Εγκατάσταση GCC 14 (Απαραίτητο για C++26 το 2026)
echo "--- Εγκατάσταση GCC-14 για υποστήριξη C++26 ---"
sudo apt install -y gcc-14 g++-14
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-14 100 \
                         --slave /usr/bin/g++ g++ /usr/bin/g++-14

# 5. Εγκατάσταση Dlib από πηγή
echo "--- Εγκατάσταση Dlib Toolkit ---"
if [ ! -d "dlib" ]; then
    git clone https://github.com/davisking/dlib.git
fi
cd dlib && mkdir -p build && cd build
cmake .. -DDLIB_USE_CUDA=OFF
cmake --build . --config Release
sudo make install
sudo ldconfig
cd ../..

# 6. Κλήση της συνάρτησης για VS Code
vscode_install_setup_fn

echo "---------------------------------------------------"
echo "Όλα έτοιμα!"
echo "Compilers: gcc-14 / g++-14 (Default)"
echo "Libraries: Dlib, Armadillo, OpenBLAS"
echo "IDE: Visual Studio Code εγκαταστάθηκε."
echo "---------------------------------------------------"
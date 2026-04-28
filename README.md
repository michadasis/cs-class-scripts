# UoWM CS Stack Installer Script

## ⚖️ License & Authors

This project is a fork of [Debian Conversion Script](https://gitlab.com/parrotsec/project/debian-conversion-script).

- **Original Creators:** [ParrotSec Team](https://www.parrotsec.org/)
- **Maintained & Modified by:**
  - [Apostolos Chalis](mailto:achalis@csd.auth.gr) — cs05414@uowm.gr
  - [Ioannis Michadasis](mailto:johnmichadasis@gmail.com) — cs05415@uowm.gr

Licensed under the **GPL v3 License**. See the [LICENSE](LICENSE) file for more details.

## Table of Contents

- [Overview](#overview)
- [How to Use](#how-to-use)
- [Menu Options](#menu-options)
- [Available Editions](#available-editions)
- [Contributions](#contributions)
- [Post installation](#post-installation)
  - [bashrc](#bashrc)
  - [profile](#profile)
  - [/etc/skel](#etc-skel)

## Overview

**CS Class Scripts** is a tool to install all needed applications that the university's curriculum requires.

## How to Use

Using this script is quite simple. Follow the steps below:

1. **Open a terminal window**
2. **Clone this repository**

   ```bash
   git clone git@github.com:ieeesbkastoria/cs-class-scripts.git
   cd cs-class-scripts
   sudo chmod +x ./install.sh
   sudo ./install.sh
   ```

## Menu Options

Upon running the script, a menu will appear:

```
╔═════════════════════════════════════════════╗
║       UoWM CS Stack Installer Script        ║
╠═════════════════════════════════════════════╣
║  1) Core                                    ║
║     Proceed with installation               ║
║  2) Exit                                    ║
╚═════════════════════════════════════════════╝
Enter the option number:
```

Choose the desired option by typing the corresponding number (e.g., type 1 to install the Core Edition packages).

## Available Editions

- **Core**: Installs all of the department's programs

## Contributions

Contributions are welcome! If you encounter any issues or have suggestions for improvements, please open an issue or submit a pull request.

## Post installation

Some configuration files that may contains customization won't be converted by this script and (if wanted) need to be copyied manually.

### bashrc

The parrot version for the default bashrc can be found in **/usr/share/base-files/dot.bashrc**. This file can be copied to the following locations:
- /etc/bash.bashrc
- /etc/skel/.bashrc
- /root/.bashrc

### profile

The parrot version for the default profile can be found in **/usr/share/base-files/dot.profile**. This file can be copied to the following locations:
- /etc/profile
- /etc/skel/.profile
- /root/.profile

### /etc/skel

The configuration files in **/etc/skel** are used to populate every user home
directory upon the user creation. Since the conversion script relies on a pre-installed distribution all the already created users won't have parrot default configurations installed in their home directories. 
To reach a full parrot customization the content of /etc/skel should be copied
on every user home directory, but paying attention to avoid override customization that the user may have done on those files.


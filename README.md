# RTAI-on-Ubuntu-14.04.4
Install RTAI on Ubuntu 14.04.4

This has been tested on a clean Ubuntu 14.04.4 image on VMware Workstation 12.0.

## About
This downloads, patches, configures, builds and installs RTAI for Ubuntu 14.04.4.
The process takes a while to do manualy and can be quite tricky for some, so this scripts should make your life easier.

#### Explain me the magic!
On first run:
 * The script downloads kernel 3.10.32 and RTAI 4.1. Why these versions? Simple, they are the versions used in my reference instruction.
 * All required packages are installed silently
 * After a small configuration step, the kernel is built with the RTAI patch
 * The kernel is installed
 * Grub config files are changed to launch the RTAI kernel automatically once
 * The system is rebooted into the new kernel

On second run:
 * RTAI is configured
 * RTAI is built
 * RTAI is installed
 * Some config and path patchwork is applied

... aaaand you're done. This process takes about 1 to 2 hours. Just fire it up and go drink your coffee!

## Getting started

**It is recommended to run this on a VM**

Download and install [Ubuntu 14.04.4](http://releases.ubuntu.com/14.04/) **64-bit!**.

Download this script:
```
curl -O https://raw.githubusercontent.com/Scoudem/RTAI-on-Ubuntu-14.04.4/master/rtai-on-ubuntu
```

Set executable:
```
chmod +x rtai-on-ubuntu
```

**While running, you will be prompted to configure the kernel. Please configure as follows:**
```
Processor type and features
    -> Processor family: select your architecture (probably default x86)
    -> Maximum number of CPUs (NR_CPUS): enter your cores (it's generally "4")
    -> SMT (Hyperthreading) scheduler support = no
Power Management and ACPI options
    CPU idle PM support = no (if possible)
```

Run as root:
```
sudo ./rtai-on-ubuntu
```

Notes:
 * The build process can take a long time (1 hour?)
 * You will be prompted before building
 * Your machine will reboot to the RTAI kernel after installation

## Quick start:
```
curl -O https://raw.githubusercontent.com/Scoudem/RTAI-on-Ubuntu-14.04.4/master/rtai-on-ubuntu; chmod +x rtai-on-ubuntu; sudo ./rtai-on-ubuntu
```

## Improvements
There is probably a better, more universal way to achieve the same result, but this does something, and thats good too right?

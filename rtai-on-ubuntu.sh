#!/bin/bash

# Author:   Tristan van Vaalen
# Date:     April 2016
# Comments: This script is built for Ubuntu 14.04.4:
#            - http://releases.ubuntu.com/14.04/
#           This is based on instructions found on:
#           Instructions taken and modified from:
#            - https://gist.github.com/gaoyifan/c881aa36cd02fb5c1c20
#           !! Make sure you have at least 10GB free space in your root partition !!
#           It is recommended to execute this on a VM! Use at your own risk.

# Make sure we are root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Display license info
echo "RTAI on Unbuntu 14.04.4 Installer Copyright (C) 2016 Tristan van Vaalen"
echo "This program comes with ABSOLUTELY NO WARRANTY; for details see license file."
echo "This is free software, and you are welcome to redistribute it under certain conditions; see license file."
read -rsp $'Press any key to start...\n' -n 1 key

# We are installing this next to the other kernel sources
cd /usr/src

# Download and unpack RTAI 4.1 and kernel v3.10.32
echo "Downloading RTAI 4.1..."
curl -s -L https://www.rtai.org/userfiles/downloads/RTAI/rtai-4.1.tar.bz2 | tar xj
echo "Downloading Linux 3.10.32..."
curl -s -L https://www.kernel.org/pub/linux/kernel/v3.x/linux-3.10.32.tar.xz | tar xJ
echo "Downloading Linux image 3.10.32..."
curl -s -L http://kernel.ubuntu.com/~kernel-ppa/mainline/v3.10.32-saucy/linux-image-3.10.32-031032-generic_3.10.32-031032.201402221635_amd64.deb -o linux-image-3.10.32-generic-amd64.deb

# Unpack the archive
echo "Unpacking image..."
dpkg-deb -x linux-image-3.10.32-generic-amd64.deb linux-image-3.10.32-generic-amd64 > /dev/null

# Create symlinks to the files for ease of use (optional?)
ln -s linux-3.10.32 linux
ln -s rtai-4.1 rtai

# Make sure we have all the packages
echo "Updating package list..."
apt-get -qq update
echo "Installing Linux build packages (if needed)..."
apt-get -qq install --yes cvs subversion build-essential git-core g++-multilib gcc-multilib
echo "Installing RTAI build packages (if needed)..."
apt-get -qq install --yes libtool automake libncurses5-dev kernel-package

# Copy the standard config
echo "Copying standard config..."
cp /usr/src/linux-image-3.10.32-generic-amd64/boot/config-3.10.32-031032-generic /usr/src/linux/.config

# Move in the kernel source dir
cd /usr/src/linux

# Apply the RTAI kernel patch
echo "Patching kernel with RTAI..."
patch -s -p1 < /usr/src/rtai/base/arch/x86/patches/hal-linux-3.10.32-x86-5.patch

# Create the config file:
echo "===============MENUCONFIG==============="
echo "----> Your input is needed! <----"
echo "Write these instruction down somehwere!"
echo ""
echo "Please configure the following settings:"
echo ""
echo "Processor type and features"
echo "    -> Processor family = Select yours"
echo "    -> Maximum number of CPUs (NR_CPUS) = Set your number (it's generally "4")"
echo "    -> SMT (Hyperthreading) scheduler support = DISABLE IT"
echo "Power Management and ACPI options"
echo "    CPU idle PM support = DISABLE IT"
echo "========================================"
read -rsp $'Press any key to start menuconfig...\n' -n 1 key
make -s menuconfig

# Buidling kernel
echo "Building kernel (takes a looong time)..."
make -j `getconf _NPROCESSORS_ONLN` deb-pkg LOCALVERSION=-rtai

# Installing kernel
echo "Installing linux image..."
dpkg -i linux-image-3.10.32-rtai_3.10.32-rtai-1_amd64.deb > /dev/null
echo "Installing linux headers..."
dpkg -i linux-headers-3.10.32-rtai_3.10.32-rtai-1_amd64.deb > /dev/null

# Patch grub to start our kernel next time
GRUB_DEFAULT="saved"
GRUB_TIMEOUT="2"
GRUB_HIDDEN_TIMEOUT="10" # make sure grub menu shows
GRUB_HIDDEN_TIMEOUT_QUIET="false"
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash lapic=notscdeadline panic=5"
grub-set-default "Ubuntu, with Linux 4.2.0-27-generic"
grub-reboot "Ubuntu, with Linux 3.10.32-rtai"
update-grub > /dev/null

echo "=========Installation complete!========="
echo "The system will reboot to the RTAI kernel now!"
echo "========================================"

echo -n "Rebooting in "
for i in {30..1}; do echo -n "$i " && sleep 1; done

reboot
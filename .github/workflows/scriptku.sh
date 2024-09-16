#!/bin/bash

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Variables
WINDOWS_ISO_URL="https://drive.massgrave.dev/en-us_windows_server_2022_updated_aug_2024_x64_dvd_17b2bb17.iso"  # Update with your actual ISO URL
WINDOWS_ISO="/tmp/windows.iso"
DISK_IMAGE="/var/lib/libvirt/images/windows-disk.qcow2"
DISK_SIZE="40G"  # Adjust disk size as needed

# Step 1: Update the system and install required packages
echo "Updating system and installing QEMU..."
apt-get update && apt-get upgrade -y
apt-get install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager

# Step 2: Download Windows ISO
echo "Downloading Windows ISO..."
wget -O "$WINDOWS_ISO" "$WINDOWS_ISO_URL"

# Step 3: Create a virtual disk for Windows
echo "Creating a virtual disk for Windows..."
qemu-img create -f qcow2 "$DISK_IMAGE" "$DISK_SIZE"

# Step 4: Install Windows using QEMU
echo "Starting Windows installation using QEMU..."
qemu-system-x86_64 \
    -m 4G \  # Amount of memory for the VM
    -cdrom "$WINDOWS_ISO" \
    -drive file="$DISK_IMAGE",format=qcow2 \
    -boot d \
    -net nic \
    -net user,hostfwd=tcp::3389-:3389 \  # This will forward RDP traffic to the guest Windows
    -enable-kvm \
    -vga std \
    -nographic

# Step 5: Post-installation instructions
echo "Windows installation started in QEMU. Connect via VNC or wait for installation to finish."
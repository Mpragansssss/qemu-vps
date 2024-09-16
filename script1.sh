#!/bin/bash

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

# Variables
WINDOWS_ISO_URL="https://example.com/path-to-windows-server-iso.iso"  # Replace with actual URL
WINDOWS_ISO="/tmp/windows.iso"
DISK_IMAGE="/var/lib/libvirt/images/windows-disk.qcow2"
DISK_SIZE="40G"  # Adjust disk size as needed

# Step 1: Update the system and install required packages
echo "Updating system and installing QEMU..."
apt-get update && apt-get upgrade -y
apt-get install -y qemu qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils wget

# Step 2: Download Windows ISO
echo "Downloading Windows ISO..."
wget -O "$WINDOWS_ISO" "$WINDOWS_ISO_URL"

# Step 3: Create a virtual disk for Windows
echo "Creating a virtual disk for Windows..."
qemu-img create -f qcow2 "$DISK_IMAGE" "$DISK_SIZE"

# Step 4: Install Windows using QEMU
echo "Starting Windows installation using QEMU..."
qemu-system-x86_64 \
    -m 4G \  # Set memory for the VM
    -cdrom "$WINDOWS_ISO" \
    -drive file="$DISK_IMAGE",format=qcow2 \
    -boot d \
    -net nic \
    -net user,hostfwd=tcp::3389-:3389 \  # Forward RDP traffic
    -vga std \
    -nographic \
    -vnc :0 &  # Use VNC display on port 5900 (VNC port :0)

# Step 5: Provide access instructions for VNC
echo "QEMU is running. You can access the installation process via VNC viewer on <Your VPS IP>:5900"

#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (e.g., sudo $0)"
  exit 1
fi

echo "Updating package lists..."
apt update && apt upgrade -y

echo "Installing minimal GNOME desktop environment..."
apt install -y \
  gnome-session \
  gdm3 \
  gnome-terminal \
  nautilus \
  gnome-control-center \
  gnome-settings-daemon \
  gnome-shell-extensions \
  network-manager-gnome

echo "Installing Firefox..."
apt install -y firefox

echo "Enabling GDM as display manager..."
systemctl enable gdm3

echo "Setup complete. Rebooting into graphical session..."
reboot

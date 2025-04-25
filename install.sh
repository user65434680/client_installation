#!/bin/bash

sudo apt update -y
sudo apt upgrade -y
sudo systemctl disable apparmor --now

sudo apt install unbound -y
sudo systemctl enable unbound
sudo apt install openssh-server -y
sudo systemctl enable ssh

sudo apt install policycoreutils selinux-utils selinux-basics -y
sudo selinux-activate
# in the future add sudo selinux-config-enforcing
chmod +x echo_ip_range.sh
chmod +x network.sh
chmod +x add_to_sudoers.sh
sudo bash echo_ip_range.sh
sudo bash network.sh
sudo bash add_to_sudoers.sh

sudo reboot

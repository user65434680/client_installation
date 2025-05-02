#!/bin/bash

sudo apt update -y
sudo apt upgrade -y

sudo apt install unbound -y
sudo systemctl enable unbound
sudo apt install openssh-server -y
sudo systemctl enable ssh
sudo apt install -y inotify-tools iptables ipset iptables-persistent
sudo systemctl enable netfilter-persistent
sudo apt install jq -y
sudo apt install dnsutils -y
sudo apt install net-tools -y
sudo apt-get install apparmor-utils -y
sudo apt install auditd -y
sudo systemctl enable --now auditd
sudo apt install mitmproxy -y

chmod +x echo_ip_range.sh
chmod +x network.sh
chmod +x add_to_sudoers.sh
chmod +x IP_tables_install.sh
chmod +x resolve_domains.sh
chmod +x block_unauthorized_ips.sh
chmod +x block_commands_install.sh
chmod +x apparmor_monitor_install.sh
chmod +x mitm_proxy.sh
sudo bash apparmor_monitor_install.sh
sudo bash block_commands_install.sh
sudo bash echo_ip_range.sh
sudo bash network.sh
sudo bash add_to_sudoers.sh
bash IP_tables_install.sh
sudo bash mitm_proxy.sh

sudo reboot

#!/bin/bash
set -e

echo "Creating directory for the monitoring script..."
sudo mkdir -p /opt/IP_blocker
sudo chmod 700 /opt/IP_blocker

sudo mkdir -p /opt/realtime_blocking
sudo chmod 700 /opt/realtime_blocking

echo "Copying blocking script..."
sudo cp resolve_and_block.sh /opt/IP_blocker/resolve_and_block.sh
sudo chmod +x /opt/IP_blocker/resolve_and_block.sh

echo "Copying allowed_domains.txt file..."
sudo cp allowed_domains.txt /opt/IP_blocker/allowed_domains.txt
sudo chmod 600 /opt/IP_blocker/allowed_domains.txt

echo "Copying realtime blocking"
sudo cp realtime_blocking.sh /opt/realtime_blocker/realtime_blocking.sh
chmod +x /opt/realtime_blocking/realtime_blocking.sh

echo "Creating systemd service for resolve_and_block.sh..."
cat <<EOF | sudo tee /etc/systemd/system/resolve_and_block.service > /dev/null
[Unit]
Description=Resolve Allowed Domains and Block Unauthorized IPs

[Service]
ExecStart=/opt/IP_blocker/resolve_and_block.sh
Restart=on-failure
User=root

[Install]
WantedBy=multi-user.target
EOF

# add a config to prevent all IPV6 traffic
sudo ip6tables -P INPUT DROP
sudo ip6tables -P FORWARD DROP
sudo ip6tables -P OUTPUT DROP

# add so that it stays after reboot
sudo ip6tables-save > /etc/iptables/rules.v6

echo "Reloading systemd..."
sudo systemctl daemon-reload

echo "Enabling and starting the resolve_and_block.service..."
sudo systemctl enable resolve_and_block.service
sudo systemctl start resolve_and_block.service

sudo chown root:root /opt/IP_blocker/resolve_and_block.sh
sudo chmod 700 /opt/IP_blocker/resolve_and_block.sh

sudo chown root:root /opt/IP_blocker/allowed_domains.txt
sudo chmod 600 /opt/IP_blocker/allowed_domains.txt
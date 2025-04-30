#!/bin/bash

sudo mkdir -p /opt/apparmor_monitor_and_block
sudo chmod 700 /opt/apparmor_monitor_and_block

echo "Copying realtime blocking script..."
sudo cp realtime_blocking.sh /opt/apparmor_monitor_and_block/apparmor_monitor_and_block.sh
sudo chmod +x /opt/apparmor_monitor_and_block/apparmor_monitor_and_block.sh

echo "Creating systemd service for apparmor_monitor_and_block..."
cat <<EOF | sudo tee /etc/systemd/system/apparmor_monitor_and_block.service > /dev/null
[Unit]
Description=Block unauthorized installs and file access
After=network.target

[Service]
Type=simple
ExecStart=/opt/apparmor_monitor_and_block/apparmor_monitor_and_block.sh
Restart=on-failure
User=root

[Install]
WantedBy=multi-user.target
EOF

echo "Reloading systemd..."
sudo systemctl daemon-reload

echo "Enabling and starting apparmor_monitor_and_block.service..."
sudo systemctl enable apparmor_monitor_and_block.service
sudo systemctl start apparmor_monitor_and_block.service

echo "Setting permissions..."
sudo chown root:root /opt/apparmor_monitor_and_block/apparmor_monitor_and_block.sh
sudo chmod 700 /opt/apparmor_monitor_and_block/apparmor_monitor_and_block.sh
sudo chmod 700 /opt/apparmor_monitor_and_block

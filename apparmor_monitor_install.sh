#!/bin/bash

sudo mkdir -p /opt/apparmor_monitor_and_block
sudo chmod 700 /opt/apparmor_monitor_and_block

echo "Copying realtime blocking"
sudo cp realtime_blocking.sh /opt/apparmor_monitor_and_block/apparmor_monitor_and_block.sh
chmod +x /opt/realtime_blocking/apparmor_monitor_and_block/apparmor_monitor_and_block.sh

echo "Creating systemd service for resolve_and_block.sh..."
cat <<EOF | sudo tee /etc/systemd/system/apparmor_monitor_and_block.service > /dev/null
[Unit]
Description=Block unauthorized installs and file access

[Service]
ExecStart=/opt/apparmor_monitor_and_block/apparmor_monitor_and_block.sh
Restart=on-failure
User=root

[Install]
WantedBy=multi-user.target
EOF

echo "Reloading systemd..."
sudo systemctl daemon-reload

echo "Enabling and starting the realtime_blocking.service..."
sudo systemctl enable apparmor_monitor_and_block.service
sudo systemctl start apparmor_monitor_and_block.service

sudo chown root:root /opt/apparmor_monitor_and_block/apparmor_monitor_and_block.sh
sudo chmod 700 /opt/apparmor_monitor_and_block/apparmor_monitor_and_block.sh
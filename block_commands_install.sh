#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root." >&2
    exit 1
fi

sudo mkdir -p /opt/realtime_blocking

echo "Copying realtime blocking"
sudo cp realtime_blocking.sh /opt/realtime_blocking/realtime_blocking.sh
sudo chmod +x /opt/realtime_blocking/realtime_blocking.sh

echo "Creating systemd service for resolve_and_block.sh..."
cat <<EOF | sudo tee /etc/systemd/system/realtime_blocking.service > /dev/null
[Unit]
Description=Block unauthorized commands

[Service]
ExecStart=/opt/realtime_blocking/realtime_blocking.sh
Restart=on-failure
User=root

[Install]
WantedBy=multi-user.target
EOF

echo "Reloading systemd..."
sudo systemctl daemon-reload

cat << 'EOF' > /etc/audit/rules.d/block.rules
-a always,exit -F path=/usr/bin/apt-get -F perm=x -k apt-get-block
-a always,exit -F path=/usr/bin/apt -F perm=x -k apt-block
-a always,exit -F path=/usr/bin/mount -F perm=x -k mount-block
-a always,exit -F path=/usr/bin/umount -F perm=x -k umount-block
-a always,exit -F path=/usr/bin/scp -F perm=x -k scp-block
EOF

echo "Reloading audit rules..."
augenrules --load

if auditctl -l | grep -q apt-get-block; then
    echo "Audit rules successfully applied."
else
    echo "Failed to apply audit rules." >&2
    exit 2
fi

echo "Enabling and starting the realtime_blocking.service..."
sudo systemctl enable realtime_blocking.service
sudo systemctl start realtime_blocking.service

echo "Setting permissions..."
sudo chmod 700 /opt/realtime_blocking
sudo chmod 700 /opt/realtime_blocking/realtime_blocking.sh
sudo chown root:root /opt/realtime_blocking/realtime_blocking.sh

#!/bin/bash
set -e

echo "Creating directory for the monitoring script..."
sudo mkdir -p /opt/IP_blocker
sudo chmod 700 /opt/IP_blocker

echo "Copying blocking script..."
sudo cp block_unauthorized_ips.sh /opt/IP_blocker/block_unauthorized_ips.sh
sudo chmod +x /opt/IP_blocker/block_unauthorized_ips.sh

echo "Copying resolve_domains file..."
sudo cp resolve_domains.sh /opt/IP_blocker/resolve_domains.sh
sudo chmod +x /opt/IP_blocker/resolve_domains.sh

echo "Copying allowed_domains.txt file..."
sudo cp allowed_domains.txt /opt/IP_blocker/allowed_domains.txt
sudo chmod 600 /opt/IP_blocker/allowed_domains.txt

echo "Creating systemd service for resolve_domains.sh..."
cat <<EOF | sudo tee /etc/systemd/system/resolve_domains.service > /dev/null
[Unit]
Description=Query DNS for Allowed Domains and Update IP List

[Service]
ExecStart=/opt/IP_blocker/scripts/resolve_domains.sh
Restart=on-failure
User=root

[Install]
WantedBy=multi-user.target
EOF

echo "Creating systemd service for block-ips..."
cat <<EOF | sudo tee /etc/systemd/system/block_unauthorized_ips.service > /dev/null
[Unit]
Description=Block IPs Not Found in Allowed Domain List

[Service]
ExecStart=/opt/IP_blocker/scripts/block_unauthorized_ips.sh
Restart=on-failure
User=root

[Install]
WantedBy=multi-user.target
EOF

echo "Reloading systemd..."
sudo systemctl daemon-reload

echo "Enabling and starting the block_unauthorized_ips.service..."
sudo systemctl enable block_unauthorized_ips.service
sudo systemctl start block_unauthorized_ips.service

echo "Enabling and starting the resolve_domains.service..."
sudo systemctl enable resolve_domains.service
sudo systemctl start resolve_domains.service

sudo chown root:root /opt/IP_blocker/block_unauthorized_ips.sh
sudo chmod 700 /opt/IP_blocker/block_unauthorized_ips.sh

sudo chown root:root /opt/IP_blocker/resolve_domains.sh
sudo chmod 700 /opt/IP_blocker/resolve_domains.sh

sudo chown root:root /opt/IP_blocker/allowed_domains.txt
sudo chmod 600 /opt/IP_blocker/allowed_domains.txt

#!/bin/bash
set -e

echo "Creating directory for the monitoring script..."
sudo mkdir -p /opt/unbound-monitor

echo "Copying the monitoring script..."
sudo cp unbound-monitor.sh /opt/unbound-monitor/unbound-monitor.sh
sudo chmod +x /opt/unbound-monitor/unbound-monitor.sh

sudo chown root:root /opt/unbound-monitor/unbound-monitor.sh
sudo chmod 700 /opt/unbound-monitor/unbound-monitor.sh

echo "Creating systemd service for unbound-monitor..."
cat <<EOF | sudo tee /etc/systemd/system/unbound-monitor.service > /dev/null
[Unit]
Description=Monitor Unbound DNS Log and Update iptables

[Service]
ExecStart=/opt/unbound-monitor/unbound-monitor.sh
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

echo "Reloading systemd..."
sudo systemctl daemon-reload

echo "Enabling and starting the unbound-monitor service..."
sudo systemctl enable unbound-monitor.service
sudo systemctl start unbound-monitor.service

echo "Setting up iptables rules..."
sudo iptables -A OUTPUT -d 127.0.0.1 -p udp --dport 53 -j ACCEPT
sudo iptables -A OUTPUT -d 127.0.0.1 -p tcp --dport 53 -j ACCEPT
sudo iptables -A OUTPUT -j REJECT

echo "Saving iptables rules..."
sudo sh -c 'iptables-save > /etc/iptables/rules.v4'

echo "Setup complete! The unbound-monitor service is running, and iptables rules are configured."

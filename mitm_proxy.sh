mitmdump -p 8080

sudo iptables -t nat -A OUTPUT -p tcp --dport 80 -j REDIRECT --to-port 8080
sudo iptables -t nat -A OUTPUT -p tcp --dport 443 -j REDIRECT --to-port 8080

sudo iptables-save > /etc/iptables/rules.v4

sudo nano /etc/systemd/system/mitmproxy.service

cat <<EOF | sudo tee /etc/systemd/system/mitmproxy.service > /dev/null
[Unit]
Description=MITMProxy Service
After=network.target

[Service]
Type=simple
User=yourusername
ExecStart=/usr/local/bin/mitmproxy --mode transparent --showhost -p 8080
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable mitmproxy
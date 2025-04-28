#!/bin/bash

ALLOWED_IPS_FILE="/path/to/allowed_domain_IP.txt"
BLOCKED_LOG="/path/to/blocked_ips.log"

echo "Starting to check active connections every 2 seconds..."

while true; do
    echo "Checking active connections..."
    CURRENT_CONNECTIONS=$(netstat -tn | awk '{print $5}' | cut -d':' -f1 | sort | uniq)

    echo "Cross-referencing connections with allowed IPs..."

    for ip in $CURRENT_CONNECTIONS; do
        if ! grep -q "^$ip$" "$ALLOWED_IPS_FILE"; then
            echo "Blocking unauthorized IP: $ip"
            sudo iptables -A INPUT -s "$ip" -j DROP
            
            echo "$(date) - Blocked IP: $ip" >> "$BLOCKED_LOG"
        fi
    done

    echo "Sleeping for 2 seconds..."
    sleep 2
done
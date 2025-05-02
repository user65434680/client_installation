#!/bin/bash

SCRIPT_DIR=$(dirname "$(realpath "$0")")

ALLOWED_DOMAINS_FILE="$SCRIPT_DIR/allowed_domains.txt"
ALLOWED_IPS_FILE="$SCRIPT_DIR/allowed_domain_IP.txt"
BLOCKED_LOG="$SCRIPT_DIR/blocked_ips.log"

echo "Starting to resolve domains and block unauthorized IPs..."

while true; do
    if [[ ! -f "$ALLOWED_DOMAINS_FILE" ]]; then
        echo "Error: $ALLOWED_DOMAINS_FILE not found."
        sleep 1
        continue
    fi

    if [[ ! -s "$ALLOWED_DOMAINS_FILE" ]]; then
        echo "No domains in $ALLOWED_DOMAINS_FILE. Sleeping for 30 seconds..."
        sleep 30
        continue
    fi

    echo "Resolving domains to IPs..."
    TEMP_FILE=$(mktemp)

    while read -r domain; do
        if [[ -n "$domain" ]]; then
            ips=$(dig +short "$domain")
            
            if [[ -n "$ips" ]]; then
                for ip in $ips; do
                    echo "$ip" >> "$TEMP_FILE"
                done
            else
                echo "No IP found for domain: $domain"
            fi
        fi
    done < "$ALLOWED_DOMAINS_FILE"

    mv "$TEMP_FILE" "$ALLOWED_IPS_FILE"
    echo "Updated allowed IPs in $ALLOWED_IPS_FILE."

    echo "Checking active connections..."
    CURRENT_CONNECTIONS=$(netstat -tn | awk 'NR>2 {print $5}' | cut -d':' -f1 | sort | uniq)

    echo "Cross-referencing connections with allowed IPs..."
    for ip in $CURRENT_CONNECTIONS; do
        if [[ -n "$ip" ]] && ! grep -q "^$ip$" "$ALLOWED_IPS_FILE"; then
            echo "Blocking unauthorized IP: $ip"
            sudo iptables -A INPUT -s "$ip" -j DROP
            
            echo "$(date) - Blocked IP: $ip" >> "$BLOCKED_LOG"
        fi
    done

    echo "Sleeping for 1 second before the next iteration..."
    sleep 1
done
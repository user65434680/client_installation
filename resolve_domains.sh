#!/bin/bash

ALLOWED_DOMAINS_FILE="allowed_domains.txt"
ALLOWED_IPS_FILE="allowed_domain_IP.txt"

echo "Starting to resolve domains to IPs every 5 seconds..."

while true; do
    echo "Resolving domains to IPs..."
    > "$ALLOWED_IPS_FILE"

    while read -r domain; do
        ips=$(dig +short "$domain")
        
        if [[ -n "$ips" ]]; then
            for ip in $ips; do
                echo "$ip" >> "$ALLOWED_IPS_FILE"
            done
        else
            echo "No IP found for domain: $domain"
        fi
    done < "$ALLOWED_DOMAINS_FILE"

    echo "Sleeping for 5 seconds..."
    sleep 5
done

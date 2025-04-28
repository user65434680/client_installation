#!/bin/bash
# service file
# will run constantly after startup in the background
set -e

if ! iptables -C OUTPUT -p udp --dport 53 -j ACCEPT 2>/dev/null; then
    echo "Allowing outgoing DNS traffic (UDP)"
    iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
fi

if ! iptables -C OUTPUT -p tcp --dport 53 -j ACCEPT 2>/dev/null; then
    echo "Allowing outgoing DNS traffic (TCP)"
    iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT
fi

while true; do
    if [ ! -f /opt/unbound-monitor/allowed_domains.json ]; then
        echo "Error: /opt/unbound-monitor/allowed_domains.json not found."
        sleep 10
        continue
    fi

    domains=$(jq -r '.domains[]' /opt/unbound-monitor/allowed_domains.json 2>/dev/null || echo "")

    if [ -z "$domains" ]; then
        echo "Error: No domains found in /opt/unbound-monitor/allowed_domains.json."
        sleep 10
        continue
    fi

    for domain in $domains; do
        echo "Resolving domain: $domain"
        resolved_ip=$(dig +short +time=10 $domain)
        
        if [ -z "$resolved_ip" ]; then
            echo "Error: No IPs resolved for $domain."
            continue
        fi

        for ip in $resolved_ip; do
            echo "Checking if iptables rule exists for $ip"
            if ! iptables -C OUTPUT -d $ip -j ACCEPT 2>/dev/null; then
                echo "Allowing outgoing traffic to $domain ($ip)"
                iptables -A OUTPUT -d $ip -j ACCEPT
            fi
        done
    done
    sleep 10
done

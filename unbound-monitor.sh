#!/bin/bash
# service file
# will run constantly after startup in the background
set -e

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
        resolved_ip=$(dig +short $domain)
        for ip in $resolved_ip; do
            if ! iptables -C OUTPUT -d $ip -j ACCEPT 2>/dev/null; then
                echo "Allowing outgoing traffic to $domain ($ip)"
                iptables -A OUTPUT -d $ip -j ACCEPT
            fi
        done
    done
    sleep 10
done

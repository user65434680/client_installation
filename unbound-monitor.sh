#!/bin/bash
# service file
# will run constantly after startup in the background
set -e

while true; do
    domains=$(jq -r '.domains[]' /opt/unbound-monitor/allowed_domains.json)

    for domain in $domains; do
        resolved_ip=$(dig +short $domain)
        for ip in $resolved_ip; do
            if ! iptables -C OUTPUT -d $ip -j ACCEPT 2>/dev/null; then
                echo "Allowing outgoing traffic to $domain ($ip)"
                iptables -A OUTPUT -d $ip -j ACCEPT
            fi
        done
    done
# NEVER EVER REMOVE SLEEP COMMAND OR THE SCRIPT WILL EAT ALL SYSTEM RESOURCES AND CRASH.
# even 1 second is better than nothing.
    sleep 10
done

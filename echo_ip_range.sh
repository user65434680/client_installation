#!/bin/bash

network=$(ip -o -f inet addr show | grep -v lo | awk '{print $4}' | cut -d/ -f1 | head -n 1)
netmask=$(ip -o -f inet addr show | grep -v lo | awk '{print $4}' | cut -d/ -f2 | head -n 1)

IFS='.' read -r -a ip_array <<< "$network"
IFS='.' read -r -a netmask_array <<< "$(ipcalc -n $network/$netmask | grep Network | awk '{print $2}')"

start_ip="${ip_array[0]}.${ip_array[1]}.${ip_array[2]}.3"
end_ip="${ip_array[0]}.${ip_array[1]}.${ip_array[2]}.254"


for ip in $(seq 3 254); do
    current_ip="${ip_array[0]}.${ip_array[1]}.${ip_array[2]}.$ip"
    
    if ! ping -c 1 -W 1 $current_ip &>/dev/null; then
        echo "Found non-responding IP: $current_ip"
        
        echo "{
    \"STATIC_IP\": \"$current_ip/24\",
    \"GATEWAY\": \"${ip_array[0]}.${ip_array[1]}.${ip_array[2]}.1\",
    \"DNS_SERVERS\": \"127.0.0.1\"
}" > network.json
        break
    fi
done

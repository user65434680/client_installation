#!/bin/bash

echo "Starting network scan and configuration..."

IFACE=$(ip route | awk '/default/ {print $5}')
if [ -z "$IFACE" ]; then
    echo "No default network interface found."
    exit 1
fi

IP_CIDR=$(ip -o -f inet addr show "$IFACE" | awk '{print $4}')
IP_ADDR=$(echo "$IP_CIDR" | cut -d'/' -f1)
CIDR=$(echo "$IP_CIDR" | cut -d'/' -f2)

IFS='.' read -r o1 o2 o3 _ <<< "$IP_ADDR"
BASE="${o1}.${o2}.${o3}"

for i in {3..254}; do
    IP="${BASE}.${i}"
    if ! ping -c 1 -W 1 "$IP" > /dev/null 2>&1; then
        NEW_IP="$IP"
        break
    fi
done

if [ -z "$NEW_IP" ]; then
    echo "No available IP found in the range ${BASE}.3-${BASE}.254."
    exit 1
fi

echo "Found available IP: $NEW_IP"

GATEWAY="${BASE}.1"

DNS_SERVERS="127.0.0.1"


sudo ip addr add "$NEW_IP/$CIDR" dev "$IFACE"
sudo ip link set dev "$IFACE" up


OUTPUT_FILE="network.json"
{
echo "{"
echo '  "STATIC_IP": "'"$NEW_IP/$CIDR"'",'
echo '  "GATEWAY": "'"$GATEWAY"'",'
echo '  "DNS_SERVERS": "'"$DNS_SERVERS"'"'
echo "}"
} > "$OUTPUT_FILE"

echo "Configuration complete. Output written to $OUTPUT_FILE:"
cat "$OUTPUT_FILE"

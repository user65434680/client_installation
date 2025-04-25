#!/bin/bash

echo "Starting automatic network scan and configuration..."

IFACE=$(ip route | awk '/default/ {print $5}')
if [ -z "$IFACE" ]; then
    echo "No default network interface found."
    exit 1
fi

IP_CIDR=$(ip -o -f inet addr show "$IFACE" | awk '{print $4}')
IP_ADDR=$(echo "$IP_CIDR" | cut -d'/' -f1)
CIDR=$(echo "$IP_CIDR" | cut -d'/' -f2)

GATEWAY=$(ip route | awk '/default/ {print $3}')

DNS_SERVERS="127.0.0.1"

echo "Detected Interface: $IFACE"
echo "IP Address: $IP_ADDR"
echo "Gateway: $GATEWAY"
echo "CIDR: $CIDR"
echo "DNS Servers: $DNS_SERVERS"

OUTPUT_FILE="network.json"

{
echo "{"
echo '  "STATIC_IP": "'"$IP_ADDR/$CIDR"'",'
echo '  "GATEWAY": "'"$GATEWAY"'",'
echo '  "DNS_SERVERS": "'"$DNS_SERVERS"'"'
echo "}"
} > "$OUTPUT_FILE"

echo "Configuration complete. Output written to $OUTPUT_FILE:"
cat "$OUTPUT_FILE"

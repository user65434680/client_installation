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

IFS='.' read -r o1 o2 o3 _ <<< "$IP_ADDR"
BASE="${o1}.${o2}.${o3}"
IP_RANGE="${BASE}.0/${CIDR}"

echo "Detected Interface: $IFACE"
echo "IP Address: $IP_ADDR"
echo "Gateway: $GATEWAY"
echo "CIDR: $CIDR"
echo "Scanning $IP_RANGE..."

TEMP_FILE=$(mktemp)

for i in {3..254}; do
    IP="${BASE}.${i}"
    if ping -c 1 -W 1 "$IP" > /dev/null 2>&1; then
        echo "$IP" >> "$TEMP_FILE"
    fi
done

OUTPUT_FILE="network.json"
{
echo "{"
echo '  "STATIC_IP": "'"$IP_ADDR"'",'
echo '  "GATEWAY": "'"$GATEWAY"'",'
echo '  "LIVE_HOSTS": ['
first=1
while read -r ip; do
    if [ "$first" -eq 1 ]; then
        echo "    \"$ip\""
        first=0
    else
        echo "    , \"$ip\""
    fi
done < "$TEMP_FILE"
echo '  ]'
echo "}"
} > "$OUTPUT_FILE"

rm "$TEMP_FILE"

echo "Scan complete. Output written to $OUTPUT_FILE:"
cat "$OUTPUT_FILE"

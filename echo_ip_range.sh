#!/bin/bash

echo "Starting automatic network scan and configuration..."

IFACE=$(ip route | awk '/default/ {print $5}')
IP_CIDR=$(ip -o -f inet addr show "$IFACE" | awk '{print $4}')

if [ -z "$IP_CIDR" ]; then
    echo "Could not determine IP range. Exiting."
    exit 1
fi

IFS='/' read -r BASE_IP CIDR <<< "$IP_CIDR"
IFS='.' read -r o1 o2 o3 _ <<< "$BASE_IP"
BASE="${o1}.${o2}.${o3}"
IP_RANGE="${BASE}.0/${CIDR}"

echo "Detected IP range: $IP_RANGE"

TEMP_FILE=$(mktemp)

echo "Scanning for live hosts in $IP_RANGE..."
for i in {3..254}; do
    IP="${BASE}.${i}"
    if ping -c 1 -W 1 "$IP" > /dev/null 2>&1; then
        echo "$IP" >> "$TEMP_FILE"
    fi
done

OUTPUT_FILE="network.json"
{
echo "{"
echo '  "STATIC_IP": "127.0.0.1",'
echo '  "GATEWAY": "'"${BASE}.1"'",'
echo '  "DNS_SERVERS": "127.0.0.1",'
echo '  "IP_RANGE": "'"$IP_RANGE"'",'
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

echo "Scan complete. Results saved to $OUTPUT_FILE"
cat "$OUTPUT_FILE"

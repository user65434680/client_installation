#!/bin/bash

CONFIG_FILE="network.json"

STATIC_IP=$(jq -r '.STATIC_IP' "$CONFIG_FILE")
GATEWAY=$(jq -r '.GATEWAY' "$CONFIG_FILE")
DNS_SERVERS=$(jq -r '.DNS_SERVERS' "$CONFIG_FILE")

CON_NAME=$(nmcli -t -f NAME,TYPE connection show --active | grep ethernet | cut -d: -f1)

if [ -z "$CON_NAME" ]; then
  echo "No active wired connection found."
  exit 1
fi

echo "Configuring static IP on connection: $CON_NAME"

nmcli connection modify "$CON_NAME" ipv4.addresses "$STATIC_IP"
nmcli connection modify "$CON_NAME" ipv4.gateway "$GATEWAY"
nmcli connection modify "$CON_NAME" ipv4.dns "$DNS_SERVERS"
nmcli connection modify "$CON_NAME" ipv4.method manual

nmcli connection down "$CON_NAME"
nmcli connection up "$CON_NAME"

echo "Static IP configuration applied: $STATIC_IP"

#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root." >&2
    exit 1
fi

cat << 'EOF' > /etc/audit/rules.d/block.rules
# /etc/audit/rules.d/block.rules

-a always,exit -F path=/usr/bin/apt-get -F perm=x -k apt-get-block
-a always,exit -F path=/usr/bin/apt -F perm=x -k apt-block
-a always,exit -F path=/usr/bin/mount -F perm=x -k mount-block
-a always,exit -F path=/usr/bin/umount -F perm=x -k umount-block
-a always,exit -F path=/usr/bin/scp -F perm=x -k scp-block
EOF

echo "Reloading audit rules..."
augenrules --load

if auditctl -l | grep -q apt-get-block; then
    echo "Audit rules successfully applied."
else
    echo "Failed to apply audit rules." >&2
    exit 2
fi

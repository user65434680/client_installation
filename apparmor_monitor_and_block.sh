#!/bin/bash

MONITOR_DIRS=("/opt" "/usr/local/sbin" "/usr/local/bin")

APPARMOR_PROFILE="/etc/apparmor.d/custom-list"

LOG_FILE="/var/log/enforce_apparmor.log"

update_apparmor_profile() {
    if [ ! -f "$APPARMOR_PROFILE" ]; then
        echo "AppArmor profile does not exist. Creating..."
        echo "profile custom-list {" > "$APPARMOR_PROFILE"
        echo "    # Rules will go here..." >> "$APPARMOR_PROFILE"
        echo "}" >> "$APPARMOR_PROFILE"
        apparmor_parser -r "$APPARMOR_PROFILE"
    fi

    for DIR in "${MONITOR_DIRS[@]}"; do
        echo "Adding rule to block execution from user-installed files in $DIR"
        echo "deny $DIR/* rix," >> "$APPARMOR_PROFILE"
    done

    apparmor_parser -r "$APPARMOR_PROFILE"
}

log_activity() {
    echo "$(date) - $1" >> "$LOG_FILE"
}

while true; do
    update_apparmor_profile

    log_activity "Enforcing AppArmor profile from $APPARMOR_PROFILE"
    
    sleep 30
done

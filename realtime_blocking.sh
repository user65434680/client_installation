#!/bin/bash

while true; do
    for cmd in apt apt-get mount umount scp git; do
        logs=$(ausearch -m execve -c $cmd --start recent | grep 'command')
        
        if [ -n "$logs" ]; then
            uid=$(echo "$logs" | grep -oP 'uid=\K[0-9]+' | head -n 1)
            username=$(getent passwd $uid | cut -d: -f1)

            if [[ "$username" != "root" && "$(id -Gn "$username")" != *"sudo"* ]]; then
                pkill -u "$username" -f "$cmd"
                echo "Command '$cmd' attempt by $username blocked!" | mail -s "$cmd Blocked" admin@example.com
            fi
        fi
    done

    sleep 1
done
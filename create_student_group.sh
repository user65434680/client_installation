#!/bin/bash

GROUP_NAME="students"

if getent group "$GROUP_NAME" > /dev/null 2>&1; then
    echo "Group '$GROUP_NAME' already exists."
else
    sudo groupadd "$GROUP_NAME"
    if [[ $? -eq 0 ]]; then
        echo "Group '$GROUP_NAME' created successfully."
    else
        echo "Failed to create group '$GROUP_NAME'."
        exit 1
    fi
fi
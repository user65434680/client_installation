#!/bin/bash

USER=$(whoami)

if ! sudo grep -q "$USER ALL=(ALL) NOPASSWD:ALL" /etc/sudoers; then
    echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers > /dev/null
    echo "User $USER added to sudoers with NOPASSWD."
else
    echo "User $USER is already in the sudoers file with NOPASSWD."
fi

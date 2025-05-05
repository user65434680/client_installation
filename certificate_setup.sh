#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Use sudo." 
   exit 1
fi

CUSTOM_CERT_DIR="/etc/ssl/custom-certs"
GROUP_NAME="students"
PROFILE_SCRIPT="/etc/profile.d/students-ssl.sh"

if ! getent group "$GROUP_NAME" > /dev/null; then
    groupadd "$GROUP_NAME"
    echo "Group '$GROUP_NAME' created."
else
    echo "Group '$GROUP_NAME' already exists."
fi

mkdir -p "$CUSTOM_CERT_DIR"
echo "Certificate directory '$CUSTOM_CERT_DIR' created."

cat > "$PROFILE_SCRIPT" <<EOF
if id -nG "\$USER" | grep -qw "$GROUP_NAME"; then
    export SSL_CERT_DIR=$CUSTOM_CERT_DIR
    export SSL_CERT_FILE=$CUSTOM_CERT_DIR/combined.pem
fi
EOF

chmod 644 "$PROFILE_SCRIPT"
echo "Profile script '$PROFILE_SCRIPT' created and configured."

echo "Environment setup complete. Add users to the '$GROUP_NAME' group using:"
echo "sudo usermod -aG $GROUP_NAME <username>"
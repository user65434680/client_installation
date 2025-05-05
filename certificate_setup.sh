#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Use sudo." 
   exit 1
fi

CUSTOM_CERT_DIR="/etc/ssl/custom-certs"
GROUP_NAME="students"
PROFILE_SCRIPT="/etc/profile.d/students-ssl.sh"
COMBINED_PEM="$CUSTOM_CERT_DIR/combined.pem"
SRC_CERTS_DIR="/my/custom/certs"

if ! getent group "$GROUP_NAME" > /dev/null; then
    groupadd "$GROUP_NAME"
fi

mkdir -p "$CUSTOM_CERT_DIR"

cp "$SRC_CERTS_DIR"/*.crt "$CUSTOM_CERT_DIR"/ || {
    echo "Failed to copy certificates. Check that $SRC_CERTS_DIR/*.crt exists."
    exit 1
}

c_rehash "$CUSTOM_CERT_DIR"

cat "$CUSTOM_CERT_DIR"/*.crt > "$COMBINED_PEM"

cat > "$PROFILE_SCRIPT" <<EOF
if id -nG "\$USER" | grep -qw "$GROUP_NAME"; then
    export SSL_CERT_DIR=$CUSTOM_CERT_DIR
    export SSL_CERT_FILE=$COMBINED_PEM
fi
EOF

chmod 644 "$PROFILE_SCRIPT"

echo "Setup complete."
# Add users to the stundents group with: sudo usermod -aG students <username>

#!/bin/bash
#
# Edera Installer - Remote Installation Script
#
# This script copies the installation files to a remote node and runs the installer.
# Usage: INSTALLER_IP=<node-ip> ./scripts/install.sh
#

set -e

# Check that INSTALLER_IP is set
if [ -z "$INSTALLER_IP" ]; then
    echo "Error: INSTALLER_IP is not set"
    echo "Usage: INSTALLER_IP=<node-ip> ./scripts/install.sh"
    exit 1
fi

# Check that key.json exists
if [ ! -f "key.json" ]; then
    echo "Error: key.json not found"
    echo "Please save your Google Artifact Registry key as key.json"
    exit 1
fi

echo "Installing Edera on $INSTALLER_IP..."

# Copy files to target node
scp ./key.json root@$INSTALLER_IP:/tmp/
scp ./scripts/edera-install.sh root@$INSTALLER_IP:~

# Run the installer
ssh "root@$INSTALLER_IP" 'chmod +x ~/edera-install.sh && ~/edera-install.sh'

echo ""
echo "Installation complete on $INSTALLER_IP"

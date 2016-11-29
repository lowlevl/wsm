#!/bin/bash

# Load config
source modules/configReader.sh "config.cfg"

# Getting parameters
serverName="$1"

echo -e "\nCleaning up SSL certificates..."
echo "   - Revoking SSL Let's Encrypt Certificate for '$serverName'..."
$letsEncryptExec revoke --cert-path "$letsEncryptDir/live/$serverName/fullchain.pem"
echo "   - Removing certificate and renewal configuration for '$serverName'..."
rm -rf "$letsEncryptDir/live/$serverName"
rm -rf "$letsEncryptDir/archive/$serverName"
rm "$letsEncryptDir/renewal/$serverName.conf"

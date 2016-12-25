#!/bin/bash

# Load config
source modules/configReader.sh "config.cfg"

# Getting parameters
serverName="$1"
serverAlias="$2"
serverDir="$3"

echo -e "\nGenerating SSL Let's Encrypt Certificate..."
echo "   * Setting up web config for Let's Encrypt activation.."
echo "<Directory $serverDir/www>
Require all granted
</Directory>
<VirtualHost *:80>
ServerAdmin $adminEmail
DocumentRoot $serverDir/www

ServerName $serverName
ServerAlias $serverAlias
</VirtualHost>" > "/etc/apache2/sites-enabled/$serverName.conf"

# Reloading apache2
echo -n "Reloading apache2.. "
service apache2 reload
echo "Ok."

echo "   *** Generating certificate ***"
if [ ! -z "$serverAlias" ]; then # Check if aliases
  $letsEncryptExec certonly --webroot --webroot-path "$serverDir/www/" -d "$serverName" -d "$serverAlias"
else
  $letsEncryptExec certonly --webroot --webroot-path "$serverDir/www/" -d "$serverName"
fi

# Removing apache cfg file needed by Let's Encrypt
rm "/etc/apache2/sites-enabled/$serverName.conf"

# Removing temporary files created by Let's Encrypt
rm -rf "$serverDir/www/.well-known"

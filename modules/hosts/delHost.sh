#!/bin/bash

# Load config
source modules/configReader.sh "config.cfg"

# Getting parameters
serverName="$1"

# Check if there is a server name
if [ -z "$serverName" ]
then
  echo "Error: No server name specified. Try '$0 remove --help'"
  exit 1
fi

# Creating vars
serverDir=$(find "$userBasePath"/*/ -maxdepth 1 -name "$serverName")


if [ -f "/etc/apache2/sites-available/$serverName.conf" ] && [ -d "$serverDir" ]
then
  echo "Found '$serverName' in '$serverDir'.."

  # Disabling site
  echo -ne "\n * Disabling site '$serverName'.. "
  a2dissite "$serverName" > /dev/null
  echo "Ok"

  # Revoking and removing ssl cert
  if [ -d "$letsEncryptDir/live/$serverName/" ]
  then
    bash modules/hosts/delHTTPs.sh "$serverName"
  fi

  echo -e "\nRemoving files..."
  # Removing files
  rm -rf "$serverDir"
  echo "   - Server dir deleted."

  # Deleting apache virtual server
  rm -f "/etc/apache2/sites-available/$serverName.conf"
  echo "   - Apache configuration for '$serverName' removed."

  # Reloading php-fpm
  echo -ne "\nReloading php-fpm.. "
  service php*-fpm restart
  echo "Ok"

  # Reloading apache2
  echo -n "Reloading apache2.. "
  service apache2 reload
  echo "Ok"
else
  echo -e "Error: Server not found."
  exit 1
fi

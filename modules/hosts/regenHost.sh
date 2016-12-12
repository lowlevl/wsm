#!/bin/bash

# Load config
source modules/configReader.sh "config.cfg"

# Default params (overwritten by the install.cfg file if exist)
chrootHost=1
sslSecured=0
hostRedir=0

# Getting parameters
serverName="$1"

# Check if there is a server name
if [ -z "$serverName" ]
then
  echo "Error: No server name specified. Try '$0 regen --help'"
  exit 1
fi

serverAlias=$(grep ServerAlias /etc/apache2/sites-available/$serverName.conf | sed -e 's/.*ServerAlias //' | head -1)
serverDir=$(find "$userBasePath"/*/ -maxdepth 1 -name "$serverName")
userName=$(basename $(dirname $serverDir))

if [ -f "/etc/apache2/sites-available/$serverName.conf" ]
then
  echo " ~ Regen started ~"

  echo -n "  -> Moving files in backup dir.. "
  mkdir -p "$backupDir/$serverName"
  mv "$serverDir"/www/* "$backupDir/$serverName"
  echo "Ok"

  echo -n "  -> Removing host.. "
  bash modules/hosts/delHost.sh "$serverName" > /dev/null
  echo "Ok"

  echo -n "  -> Loading install.cfg.. "
  [ -f "$serverDir/conf.d/install.cfg" ] && source modules/configReader.sh "$serverDir/conf.d/install.cfg"
  echo "Ok"

  echo -n "  -> Creating host.. "
  bash modules/hosts/addHost.sh "$serverName" "$serverAlias" "$userName" "$sslSecured" "$chrootHost" "$hostRedir" > /dev/null
  echo "Ok"

  echo -n "  -> Recovering backup.. "
  rm -rf "$serverDir"/www/*
  mv "$backupDir/$serverName"/* "$serverDir/www/"
  rm -rf "$backupDir/$serverName"
  echo "Ok"
else
  echo -e "Error: Server not found."
  exit 1
fi

#!/bin/bash

# Load config
source modules/configReader.sh "config.cfg"

# Getting parameters
serverName="$1"

# Check if there is a server name
if [ -z "$serverName" ]
then
  echo "Error: No server name specified. Try '$0 regen --help'"
  exit 1
fi

serverDir=$(find "$userBasePath"/*/ -maxdepth 1 -name "$serverName")

if [ -f "/etc/apache2/sites-available/$serverName.conf" ]
then
  # Start regen
  echo ""
else
  echo -e "Error: Server not found."
  exit 1
fi

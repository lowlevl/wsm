#!/bin/bash

# Load config
source modules/configReader.sh "config.cfg"

# Getting parameters
userName="$1"

# Check if there is an user name
if [ -z "$userName" ]; then
  echo "Error: No user name specified. Try '$0 userwipe --help'"
  exit 1
fi

# Creating vars
userDir=$userBasePath/${userName}${userDirSuffix}
userName=${userName}${userNameSuffix}

if [ ! -d "$userDir/web.conf" ]; then
  echo "Error: User not found or not www user !"
  exit 1
fi

# Recursive server remove
echo "Recursively removing hosts from user dir.."
serverList=($(ls "$userDir" -I "readme" -I "web.conf"))

for serverName in ${serverList[@]}
do
  if [ -f "$userDir/$serverName/conf.d/pool.cfg" ]; then
    echo -n "  * $serverName found, removing host.. "
    bash modules/hosts/delHost.sh "$serverName" > /dev/null
    echo "Done."
  else
    echo "  * /conf.d/pool.cfg not found in dir '$serverName'"
  fi
done

# Removing Unix user
echo -ne "\nRemoving Unix user.. "
userdel -rf "$userName" 2>/dev/null
echo "Done."

# Removing ftp user
echo -n "Removing ftp user.. "
pure-pw userdel "$userName"
pure-pw mkdb
service pure-ftpd restart
echo "Done."

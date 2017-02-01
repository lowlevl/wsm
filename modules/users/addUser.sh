#!/bin/bash

# Load config
source modules/configReader.sh "config.cfg"

# Getting parameters
userName="$1"
userDir="$2"

# Generating vars
userPass=$(cat /dev/urandom | tr -dc a-z0-9A-Z | head -c16)

# Add an user
echo -n "Creating new Unix user.. "
useradd "$userName" --gid www-data --no-create-home --home-dir "$userDir" --system -s /usr/sbin/nologin
passwd --lock "$userName" > /dev/null
echo "Done."

# Creating dir
echo -n "Creating user dir.. "
mkdir "$userDir"
echo "Done."

# Create a subdir to know that is a web user
mkdir "$userDir"/web.conf

# Add ftp user
echo -ne "Creating ftp user.. "
( echo "$userPass" ; echo "$userPass" ) | pure-pw useradd "$userName" -u "$userName" -g www-data -d "$userDir" > /dev/null
pure-pw mkdb
service pure-ftpd restart
echo "Done."

# Creating passwd file to keep password
echo -e "{\n    \"username\": \"$userName\",\n    \"password\": \"$userPass\"\n}" > "$userDir/web.conf/passwd"

# Copy readme file to the user root
cp readme.default "$userDir"/readme

# Fixing permissions
chown -R "$userName":www-data "$userDir"
chmod 510 -R "$userDir"
chmod 0 "$userDir"/web.conf

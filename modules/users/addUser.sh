#!/bin/bash

# Getting parameters
userName="$1"
userDir="$2"

# Generating vars
ftpPassword=$(openssl rand -base64 12)

# Add an user
echo -n "Creating new Unix user.. "
useradd "$userName" --gid www-data --create-home --home-dir "$userDir" --system -s /usr/sbin/nologin
passwd --lock "$userName" > /dev/null
echo "Done."

# Cleaning user dir
rm -f "$userDir"/*

# Create a subdir to know that is a web user
mkdir "$userDir"/web.conf

# Add ftp user
echo -ne "Creating ftp user.. "
( echo "$ftpPassword" ; echo "$ftpPassword" ) | pure-pw useradd "$userName" -u "$userName" -g www-data -d "$userDir" > /dev/null
pure-pw mkdb
service pure-ftpd restart
echo "Done."

# Creating passwd file to keep password
echo -e "{\n    \"username\": \"$userName\",\n    \"password\": \"$ftpPassword\"\n}" > "$userDir/web.conf/passwd"

# Copy readme file to the user root
cp readme.default "$userDir"/readme

# Fixing permissions
chown -R "$userName":www-data "$userDir"
chmod 550 -R "$userDir"
chmod 000 "$userDir"/web.conf

#!/bin/bash

# Load config
source modules/configReader.sh "config.cfg"

# Getting parameters
serverName="$1"
serverAlias="$2"
userName="$3"

sslSecured="$4"
chrootHost="$5"
hostRedir="$6"

# Check if there is a server name
if [ -z "$serverName" ]
then
  echo "Error: No server name specified. Try '$0 add --help'"
  exit 1
fi

# Check if there is an user name
if [ -z "$userName" ]
then
  echo "Error: No user name specified. Try '$0 add --help'"
  exit 1
fi

if [ "$hostRedir" == 1 ] && [ -z "$serverAlias" ]
then
  echo "Error: You can't request redirecting all aliases to domain, there isn't any alias."
  exit 1
fi

# Generating vars
userDir="$userBasePath/${userName}${userDirSuffix}"
userName="${userName}${userNameSuffix}"
serverDir="$userDir/$serverName"

# If server is not configured, launch creation
if [ ! -f "/etc/apache2/sites-available/$serverName.conf" ]
then

  # Check for userBasePath dir
  if [ ! -d "$userBasePath" ]
  then
    echo "Info: The base dir was not found, creating."
    mkdir -p "$userBasePath"
    chmod 555 "$userBasePath"
  fi

  if [ ! -d "$userDir/web.conf" ]
  then
    bash modules/users/addUser.sh "$userName" "$userDir"
  fi

  # Making dirs
  echo "Making dirs.."
  echo "   + /"
  mkdir "$serverDir"
  echo "   + /www"
  mkdir "$serverDir/www"
  echo "   + /log"
  mkdir "$serverDir/log"
  echo "   + /conf.d"
  mkdir "$serverDir/conf.d"

  # Setting up default vhost
  echo "   + Copying default website to www/ dir"
  cp -R web.default/* "$serverDir/www/"

  # Pregenerating certificate if needed
  if [ "$sslSecured" == 1 ]
  then
    bash modules/hosts/addHTTPs.sh "$serverName" "$serverAlias" "$serverDir"
  fi

  # Generating config files
  bash modules/config/genConfig.sh "$serverName" "$serverAlias" "$serverDir" "$userName" "$sslSecured" "$chrootHost" "$hostRedir"

  # PHP requirements in chroot
  if [ "$chrootHost" == 1 ]
  then
    echo "Copying files to setup chroot.."
    mkdir -p "$serverDir"/{etc,usr/share,var/lib/php/sessions,tmp,dev,lib/x86_64-linux-gnu}
    echo -n " * Local time.. "
    cp /etc/localtime "$serverDir"/etc
    cp -r /usr/share/zoneinfo "$serverDir"/usr/share
    echo "Ok"

    echo " * System files.."
    echo -n "   -> /dev/ stuff.. "
    cp -a /dev/urandom /dev/null /dev/zero "$serverDir"/dev
    echo "Ok"

    echo -n "   -> /etc/ stuff.. "
    cp hosts.default "$serverDir"/etc/hosts
    cp /etc/nsswitch.conf "$serverDir"/etc/
    cp /etc/resolv.conf "$serverDir"/etc/
    cp /etc/services "$serverDir"/etc/
    echo "Ok"

    echo -n "   -> copying libs for 'php' and php-fpm.. "
    fileArray=$(ldd /usr/bin/php7.0 /usr/bin/php5.6 /usr/sbin/php-fpm7.0 /usr/sbin/php-fpm5.6 2>/dev/null | awk 'NF == 4 {print $3}; NF == 2 {print $1}' | sort -u)

    for file in $fileArray
    do
      dirName="$(dirname $file)"
      [ ! -d "$serverDir$dirName" ] && mkdir -p "$serverDir$dirName" || :
      cp $file "$serverDir$dirName"
    done
    echo "Ok"

    echo -n "   -> Creating symlink to make php-fpm work.. "
    mkdir -p "$serverDir$serverDir"
    ln -s ../../../../www/ "$serverDir$serverDir"/www
    echo "Ok"

  fi

  # Keeping install parameters in conf.d dir
  touch "$serverDir/conf.d/install.cfg"

  # Fix permissions
  echo -ne "\nFixing permissions for better security.. "
  chmod 550 "$serverDir" -R
  chmod 000 "$serverDir/conf.d" -R

  chmod 750 "$serverDir/www"

  chown "$userName:www-data" "$serverDir" -R
  echo "Done"


  # Enabling site
  echo -ne "\n * Enabling site '$serverName'.. "
  a2ensite "$serverName" > /dev/null
  echo "Ok"

  # Reloading php-fpm
  echo -n "Reloading php-fpm.. "
  service php*-fpm restart
  echo "Ok"

  # Reloading apache2
  echo -n "Reloading apache2.. "
  service apache2 reload
  echo "Ok"
else
  echo "Error: Server already found."
  exit 1
fi

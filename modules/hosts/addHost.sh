#!/bin/bash

# Load config
source modules/configReader.sh "config.cfg"

# Getting parameters
userName="$1"
serverName="$2"

sslSecured="$3"
chrootHost="$4"
hostRedir="$5"

# Generating vars
userDir=$userBasePath/${userName}${userDirSuffix}
userName=${userName}${userNameSuffix}
serverDir=$userDir/$serverName

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
    _addUser
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
  if [ $sslSecured == 1 ]
  then
    _addSSL
  fi

  # Generating config files
  _generateConf

  # PHP requirements in chroot
  if [ $chrootHost == 1 ]
  then
    echo "Copying files to setup chroot.."
    mkdir -p "$serverDir"/{etc,usr/share,var/lib/php/sessions,tmp,dev,lib/x86_64-linux-gnu}
    echo -n " * Local time.. "
    cp /etc/localtime "$serverDir/etc"
    cp -r /usr/share/zoneinfo "$serverDir/usr/share"
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
      [ ! -d $serverDir$dirName ] && mkdir -p $serverDir$dirName || :
      cp $file $serverDir$dirName
    done
    echo "Ok"
  fi

  # Keeping install parameters in conf.d dir
  if [ $sslSecured == 1 ]
  then
    touch "$serverDir"/conf.d/ssl
  fi
  if [ $chrootHost == 1 ]
  then
    touch "$serverDir"/conf.d/chroot
  fi
  if [ $hostRedir == 1 ]
  then
    touch "$serverDir"/conf.d/redir
  fi

  # Fix permissions
  echo -ne "\nFixing permissions for better security.. "
  chmod 750 "$serverDir" -R -f
  chown "$userName:www-data" "$serverDir" -R

  chmod 004 "$serverDir"/conf.d -R
  echo "Done."

  # Reloading php-fpm
  echo -ne "\nReloading php-fpm.. "
  service php*-fpm restart
  echo "Ok."

  # Enabling site
  $0 resume -s "$serverName"
else
  echo "Error: Server already found."
  exit 1
fi

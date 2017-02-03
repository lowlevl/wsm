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

phpVer="$7"

# Check if there is a server name
if [ -z "$serverName" ]; then
  echo "Error: No server name specified. Try '$0 add --help'"
  exit 1
fi

# Check if there is an user name
if [ -z "$userName" ]; then
  echo "Error: No user name specified. Try '$0 add --help'"
  exit 1
fi

if [ "$hostRedir" == 1 ] && [ -z "$serverAlias" ]; then
  echo "Error: You can't request redirecting all aliases to domain, there isn't any alias."
  exit 1
fi

# Generating vars
userDir="$userBasePath/${userName}"
userName="${userName}${userNameSuffix}"
serverDir="$userDir/$serverName"

# If server is not configured, launch creation
if [ ! -f "/etc/apache2/sites-available/$serverName.conf" ]; then

  # Check if phpVer is valid
  if [ -z "$phpVer" ]; then
    phpVer="$phpDefVer"
  fi

  if [ "$phpVer" != "5.6" ] && [ "$phpVer" != "7.0" ] && [ "$phpVer" != "7.1" ]; then
    echo "Invalid php version ('$phpVer'), only '5.6', '7.0' and '7.1' are supported.."
    exit 1
  fi

  echo "Using php version '$phpVer'.."

  # Check for userBasePath dir
  if [ ! -d "$userBasePath" ]; then
    echo "Info: The base dir was not found, creating."
    mkdir -p "$userBasePath"
    chmod 711 "$userBasePath"
  fi

  if [ ! -d "$userDir/web.conf" ]; then
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
  if [ "$sslSecured" == 1 ]; then
    bash modules/hosts/addHTTPs.sh "$serverName" "$serverAlias" "$serverDir"
  fi

  # Generating config files
  bash modules/config/genConfig.sh "$serverName" "$serverAlias" "$serverDir" "$userName" "$sslSecured" "$chrootHost" "$hostRedir"

  # PHP requirements in chroot
  if [ "$chrootHost" == 1 ]; then
    echo "Copying files to setup chroot.."
    mkdir -p "$serverDir"/{etc,usr/share,var/lib/php/sessions,tmp,dev}
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

    echo -n "   -> Copying libs for 'php' and php-fpm.. "
    fileArray=$(ls /lib/*/libnss_dns.so.2)

    for file in $fileArray
    do
      dirName="$(dirname $file)"
      [ ! -d "$serverDir$dirName" ] && mkdir -p "$serverDir$dirName" || :
      cp $file "$serverDir$dirName"
    done
    echo "Ok"

    echo -n "   -> Copying certs and ca to make openssl work in chroot.. "
    certDir=$(php -r "echo openssl_get_cert_locations()['default_cert_dir'];" 2>/dev/null)

    mkdir -p $serverDir$certDir

    cp $certDir/* $serverDir$certDir -R
    echo "Ok"

    echo -n "   -> Creating symlinks to make php-fpm work.. "
    mkdir -p "$serverDir$serverDir"
    ln -s ../../../../www/ "$serverDir$serverDir"/www

    echo "Ok"

    echo -n "    + cUrl fix."
    mkdir -p "$serverDir"/etc/ssl/certs/
    ln -s ../../../$certDir/ca-certificates.crt "$serverDir"/etc/ssl/certs/ca-certificates.crt
    echo "Ok"
  fi

  # Keeping install parameters in conf.d dir
  source modules/configWriter.sh "$serverDir/conf.d/install.cfg" "serverAlias" "hostRedir" "sslSecured" "chrootHost" "phpVer"

  # Fix permissions
  echo -ne "\nFixing permissions for better security.. "
  chmod 510 "$serverDir" -R
  chmod 0 "$serverDir/conf.d" -R

  if [ "$chrootHost" == 1 ]; then
    chmod 700 "$serverDir/"{var/lib/php/sessions,tmp,log} -R
  else
    chmod 700 "$serverDir"/log -R
  fi

  chmod 750 "$serverDir"/www -R

  chown "$userName:www-data" "$serverDir" -R
  echo "Done"

  # Symlinking the good php version
  echo -ne "\n * Creating symlink for php$phpVer-fpm.. "
  ln -s "./pool.cfg" "$serverDir"/conf.d/pool$phpVer.cfg
  echo "Ok"

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

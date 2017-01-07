#!/bin/bash

source modules/configReader.sh "config.cfg"

# If check not already passed, execute it
if [ ! -f .saneInstall ]; then
  # Check for installed dependencies
  echo "Verifying system to find if the script can be executed.."

  # Apache
  echo -n "  * Apache2 install status.. "
  if ! dpkg -l | grep '^ii  apache2 ' > /dev/null; then
    echo "Failed"
    exit 1
  else
    echo "Ok"
  fi

  # Mod rewrite
  echo -n "    [mod] rewrite_module enable status.. "
  if ! apache2ctl -M | grep -e 'rewrite_module' > /dev/null; then
    echo "Failed"
    exit 1
  else
    echo "Ok"
  fi

  # Mod proxy
  echo -n "    [mod] proxy_module enable status.. "
  if ! apache2ctl -M | grep -e 'proxy_module' > /dev/null; then
    echo "Failed"
    exit 1
  else
    echo "Ok"
  fi

  # Mod proxy_fcgi
  echo -n "    [mod] proxy_fcgi enable status.. "
  if ! apache2ctl -M | grep -e 'proxy_fcgi' > /dev/null; then
    echo "Failed"
    exit 1
  else
    echo "Ok"
  fi

  # Mod headers
  echo -n "    [mod] headers_module enable status.. "
  if ! apache2ctl -M | grep -e 'headers_module' > /dev/null; then
    echo "Failed"
    exit 1
  else
    echo "Ok"
  fi

  # Mod ssl
  echo -n "    [mod] ssl_module enable status.. "
  if ! apache2ctl -M | grep -e 'ssl_module' > /dev/null; then
    echo "Failed"
    exit 1
  else
    echo "Ok"
  fi

  # pure-ftpd
  echo -ne "\n  * pure-ftpd install status.. "
  if ! dpkg -l | grep -e '^ii  pure-ftpd ' > /dev/null; then
    echo "Failed"
    exit 1
  else
    echo "Ok"
  fi

  # php-fpm
  echo -n "    [cgi] php*-fpm install status.. "
  if ! dpkg -l | grep -e '^ii  php5.6-fpm ' -e '^ii  php7.0-fpm ' -e '^ii  php7.1-fpm ' > /dev/null; then
    echo "Failed"
    exit 1
  else
    echo "Ok"

    if [ -f /etc/php/5.6/fpm/php-fpm.conf ]; then
      echo -n "       -> php5.6-fpm conf.. "
      if ! grep -qF "include=$userBasePath/*/*/conf.d/pool5.6.cfg" /etc/php/5.6/fpm/php-fpm.conf; then
        echo "Warning, auto-configured."
        sed -i -e "s/.*include=/;&/" -e "/;include=/a include=$userBasePath/*/*/conf.d/pool5.6.cfg" /etc/php/5.6/fpm/php-fpm.conf
      else
        echo "Ok"
      fi
    fi

    if [ -f /etc/php/7.0/fpm/php-fpm.conf ]; then
      echo -n "       -> php7.0-fpm conf.. "
      if ! grep -qF "include=$userBasePath/*/*/conf.d/pool7.0.cfg" /etc/php/7.0/fpm/php-fpm.conf; then
        echo "Warning, auto-configured."
        sed -i -e "s/.*include=/;&/" -e "/;include=/a include=$userBasePath/*/*/conf.d/pool7.0.cfg" /etc/php/7.0/fpm/php-fpm.conf
      else
        echo "Ok"
      fi
    fi

    if [ -f /etc/php/7.1/fpm/php-fpm.conf ]; then
      echo -n "       -> php7.1-fpm conf.. "
      if ! grep -qF "include=$userBasePath/*/*/conf.d/pool7.1.cfg" /etc/php/7.1/fpm/php-fpm.conf; then
        echo "Warning, auto-configured."
        sed -i -e "s/.*include=/;&/" -e "/;include=/a include=$userBasePath/*/*/conf.d/pool7.1.cfg" /etc/php/7.1/fpm/php-fpm.conf
      else
        echo "Ok"
      fi
    fi
  fi

  # letsencrypt binary
  echo -ne "\n  * letsencrypt binary presence.. "
  if ! which "$letsEncryptExec" > /dev/null; then
    echo "Failed"
    exit 1
  else
    echo "Ok"
  fi

  # letsencrypt dir
  echo -ne "       -> letsencrypt directory presence.. "
  if [ "$letsEncryptDir" != "/etc/letsencrypt" ] && [ ! -d "$letsEncryptDir" ]; then
    echo "Failed"
    exit 1
  else
    echo "Ok"
  fi

  touch .saneInstall

  echo -e "\nEverything OK."
  echo "Now you can retype your command."
  exit 2
fi

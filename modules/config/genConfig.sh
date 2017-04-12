#!/bin/bash

# Load config
source modules/configReader.sh "config.cfg"

# Getting parameters
serverName="$1"
serverAlias="$2"
serverDir="$3"
userName="$4"

sslSecured="$5"
chrootHost="$6"
hostRedir="$7"

# Creating apache config file
echo -e "\nCreating VirtualHost file in '/etc/apache2/sites-available/'"
echo "<Directory $serverDir/www>
  Options -Indexes +FollowSymLinks +MultiViews
  AllowOverride All
  Require all granted
</Directory>
<VirtualHost *:80>
  ServerAdmin $adminEmail
  DocumentRoot $serverDir/www

  ServerName $serverName
  ServerAlias $serverAlias

  ErrorLog $serverDir/log/error.log" > "/etc/apache2/sites-available/$serverName.conf"

if [ "$sslSecured" == 1 ]; then
  echo -e "\n  <IfModule mod_rewrite.c>
    RewriteEngine on
    RewriteCond %{HTTPS} off
    RewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI}
  </IfModule>
</VirtualHost>
<IfModule mod_ssl.c>
  <VirtualHost *:443>
    ServerAdmin $adminEmail
    DocumentRoot $serverDir/www

    ServerName $serverName
    ServerAlias $serverAlias

    ErrorLog $serverDir/log/error.log" >> "/etc/apache2/sites-available/$serverName.conf"

  # Rewrites
  if [ "$hostRedir" == 1 ]; then
    echo -e "\n    <IfModule mod_rewrite.c>
      RewriteEngine on
      RewriteCond %{HTTP_HOST} !$serverName
      RewriteRule ^/(.*) http://$serverName/\$1 [R,L]
    </IfModule>" >> "/etc/apache2/sites-available/$serverName.conf"
  fi

  echo -e "\n    ProxyErrorOverride on
    <FilesMatch \"\\.php\$\">
      SetHandler \"proxy:unix:/run/php/php-fpm.$serverName.sock|fcgi://localhost/\"
    </FilesMatch>

    Header always set Strict-Transport-Security \"max-age=31536000; includeSubDomains\"

    SSLEngine on
    SSLProtocol all -SSLv2 -SSLv3
    SSLHonorCipherOrder on
    SSLCipherSuite 'EECDH+ECDSA+AESGCM EECDH+aRSA+AESGCM EECDH+ECDSA+SHA384 EECDH+ECDSA+SHA256 EECDH+aRSA+SHA384 EECDH+aRSA+SHA256 EECDH+aRSA+RC4 EECDH EDH+aRSA RC4 !aNULL !eNULL !LOW !3DES !MD5 !EXP !PSK !SRP !DSS !RC4'
    SSLCertificateFile $letsEncryptDir/live/$serverName/cert.pem
    SSLCertificateKeyFile $letsEncryptDir/live/$serverName/privkey.pem
    SSLCertificateChainFile $letsEncryptDir/live/$serverName/chain.pem
    SSLOptions +StdEnvVars +ExportCertData
  </VirtualHost>
</IfModule>" >> "/etc/apache2/sites-available/$serverName.conf"
else
  # Rewrites
  if [ "$hostRedir" == 1 ]; then
    echo -e "\n  <IfModule mod_rewrite.c>
    RewriteEngine on
    RewriteCond %{HTTP_HOST} !^$serverName$
    RewriteRule ^/(.*) http://$serverName/\$1 [R=301,L]
  </IfModule>" >> "/etc/apache2/sites-available/$serverName.conf"
  fi

  echo -e "\n  ProxyErrorOverride on
  <FilesMatch \"\\.php\$\">
    SetHandler \"proxy:unix:/run/php/php-fpm.$serverName.sock|fcgi://localhost/\"
  </FilesMatch>
</VirtualHost>" >> "/etc/apache2/sites-available/$serverName.conf"
fi

# Configuring CGI
echo "Creating php-fpm pool for '$serverName'..."
echo "[$serverName]
; Define socket
listen = /run/php/php-fpm.$serverName.sock

; Define env var for this instance
env[DOCUMENT_ROOT] = $serverDir/www/" > "$serverDir/conf.d/pool.cfg"

if [ "$chrootHost" == 1 ]; then
  echo -e "\n; Chrooting dir
chroot = $serverDir/

; Default pool settings
chdir = /www/" >> "$serverDir/conf.d/pool.cfg"
else
  echo -e "\n; Default pool settings
chdir = /" >> "$serverDir/conf.d/pool.cfg"
fi

echo "user = $userName
group = www-data
listen.owner = $userName
listen.group = www-data
listen.mode = 0666

pm = ondemand
pm.max_children = 16
pm.process_idle_timeout = 8s
pm.max_requests = 64

; Redirect worker stdout and stderr into main error log. If not set, stdout and
; stderr will be redirected to /dev/null according to FastCGI specs.
catch_workers_output = yes

; Pool mix fix
php_admin_value[opcache.enable] = 0

; Log file
php_admin_flag[log_errors] = on" >> "$serverDir/conf.d/pool.cfg"
if [ "$chrootHost" == 1 ]; then
  echo "php_admin_value[error_log] = /log/phperror.log

; Restrict access
php_admin_value[open_basedir]=/www:/tmp:/usr/share/php" >> "$serverDir/conf.d/pool.cfg"
else
  echo "php_admin_value[error_log] = $serverDir/log/phperror.log

; Restrict access
php_admin_value[open_basedir]=$serverDir/www:/tmp:/usr/share/php" >> "$serverDir/conf.d/pool.cfg"
fi

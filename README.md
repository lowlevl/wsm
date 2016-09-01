# securhOst
Simple script to create apache virtual servers, with jail and ability to auto create SSL Certificate with Let's Encrypt and set up HSTS.

# Dependencies
```
Packages:
  - apache2
  - php
  - php-fpm

Apache Mods:
  - proxy
  - proxy_fcgi
  - headers
```

# Why securhOst ?

1. It's very easy to create virtual host in seconds.
2. It creates automatically ftp user and pass for customers.
3. It's open source.
4. The virtual host note on www.ssllabs.com is a+ (When you specify the --ssl argument.)!

# File system tree

```
  Used vars:
  $serverName --> Specified by -s|--server
  $serverDir --> $userDir/$serverName
  $userName --> Specified by -u|--user
  $userDir --> /home/$userName-www/
  
  /
  `home/
   `$userDir/
    |.wwwUser --> File that specifies that the user is created by this script
    `$serverDir/
     |pool.cfg --> PHP-Fpm pool config
     |userpass --> Json file with user and password
     |<tmp,var,etc> --> Dirs for chroot and php
     |<.sslCert> --> File that specifies that the server have ssl certificate
     |log/ --> Log dir
     `www/ --> Web dir 
```

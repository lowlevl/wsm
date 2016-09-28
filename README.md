# hostmgr
Simple script to create apache virtual servers, with jail and ability to auto create SSL Certificate with Let's Encrypt. 
It can be used in production, at your own risk..

# Features:
  - Create/Remove virtual hosts very quickly (~3s without ssl).
  - Create a system user asociated to an ftp user to protect data inside and outside the home dir.
  - Ability to create multiples hosts for one user.
  - Create trusted ssl certificates easily with Let's Encrypt.
  - Auto jail all virtual hosts, with a disable option '--no-chroot'.
  - Default webserver/hosts file/readme personalisation.

# Dependencies
Packages:
  - apache2
  - php
  - php-fpm
  - pure-ftpd

Apache Mods:
  - rewrite
  - proxy
  - proxy_fcgi
  - headers

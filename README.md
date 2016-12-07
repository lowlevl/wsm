# wSm (for web Server manager)
<img src="docs/logo-b.png" alt="Entropi Logo">
> Simple cli utility to create apache virtual servers, with jail and ability to auto create SSL Certificate with Let's Encrypt.

# Features:
  - Create/Remove virtual hosts very quickly (~3s without ssl).
  - Create a system user asociated to an ftp user to protect data inside and outside the home dir.
  - Ability to create multiples hosts for one user(and ftp user).
  - Create trusted ssl certificates easily with Let's Encrypt.
  - Auto jail all virtual hosts, with a disable option '--no-chroot'.
  - Default webserver/hosts file/readme personalisation.
  - [Web Panel](https://github.com/Thecakeisgit/wSmP) (In dev :D)

# Dependencies:
  - apache2
  - php >= 5.6
  - php-fpm >= 5.6
  - pure-ftpd

Apache Mods:
  - rewrite
  - proxy
  - proxy_fcgi
  - headers
  - ssl

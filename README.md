# wSm [![MIT Licence](https://badges.frapsoft.com/os/mit/mit.svg?v=103)](https://opensource.org/licenses/mit-license.php) [![GitHub version](https://badge.fury.io/gh/Thecakeisgit%2FwSm.svg)](https://github.com/Thecakeisgit/wSm/releases)
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

### Apache Mods:
  - rewrite
  - proxy
  - proxy_fcgi
  - headers
  - ssl

# Troubleshooting:

  - `child 9916 said into stderr: "php-fpm: pool www.example.com: relocation error: /lib/x86_64-linux-gnu/libnss_dns.so.2: symbol __res_maybe_init version GLIBC_PRIVATE not defined in file libc.so.6 with link time reference"`

#### You need to update the embedded libnss_dns.so.2 of your web hosts.

```
$ sudo tee /home/web/*/*/lib/i386-linux-gnu/libnss_dns.so.2 < /lib/i386-linux-gnu/libnss_dns.so.2 > /dev/null
$ sudo tee /home/web/*/*/lib/x86_64-linux-gnu/libnss_dns.so.2 < /lib/x86_64-linux-gnu/libnss_dns.so.2 > /dev/null
```

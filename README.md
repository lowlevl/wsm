# securhOst
Simple script to create apache virtual servers, with php-fpm pool(and chroot jail), and possibility to auto create SSL Certificate with Let's Encrypt.

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

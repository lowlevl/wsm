#!/bin/bash

echo "no" > /etc/pure-ftpd/conf/PAMAuthentication
ln -s /etc/pure-ftpd/conf/PureDB /etc/pure-ftpd/auth/50puredb
echo "990" > /etc/pure-ftpd/conf/MinUID
touch /etc/pure-ftpd/pure-ftpd.pdb

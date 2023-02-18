#!/bin/sh
apt-get update -y
apt-get upgrade -y
apt-get install python2 -y 
ln -s /usr/bin/python2 /usr/bin/python
curl -sL https://deb.nodesource.com/setup_16.x -o /tmp/nodesource_setup.sh
bash /tmp/nodesource_setup.sh
apt install nodejs
apt install docker.io
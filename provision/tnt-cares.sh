#!/usr/bin/env bash
sudo apt-get install -y curl
curl https://packagecloud.io/tarantool/1_7/gpgkey | sudo apt-key add -

sudo apt-get -y install apt-transport-https
release=`lsb_release -c -s`

sudo rm -f /etc/apt/sources.list.d/*tarantool*.list
sudo bash -c 'cat > /etc/apt/sources.list.d/tarantool.list <<- EOF
deb https://packagecloud.io/tarantool/1_7/ubuntu/ `lsb_release -c -s` main
deb-src https://packagecloud.io/tarantool/1_7/ubuntu/ `lsb_release -c -s` main
EOF'

sudo apt-get update
sudo apt-get install -y tarantool

USR_SRC=/usr/local/src
wget http://c-ares.haxx.se/download/c-ares-1.10.0.tar.gz -O - | sudo tar -C ${USR_SRC} -xzvf -
cd ${USR_SRC}/c-ares-1.10.0

sudo ./configure
sudo make
sudo make install

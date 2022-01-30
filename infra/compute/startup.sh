#!/bin/bash

sudo apt-get update
sudo apt-get install git -y
sudo apt-get install docker.io -y
sudo curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
cd ~/
mkdir work
cd work
git clone https://github.com/zulip/docker-zulip
cd docker-zulip
sed -i 's/SETTING_EXTERNAL_HOST: "localhost.localdomain"/SETTING_EXTERNAL_HOST: "35.200.217.44"/g' docker-compose.yml
sudo docker-compose up -d --build

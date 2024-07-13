#!/bin/bash

cd /home/azurecore/

sudo sed -i 's/#$nrconf{restart} = '"'"'i'"'"';/$nrconf{restart} = '"'"'a'"'"';/g' /etc/needrestart/needrestart.conf

yes Y | sudo apt update
yes Y | sudo apt install gnupg

echo "Installing Mongo"

yes Y | wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
yes Y | sudo apt-get update
yes Y | sudo apt-get install mongodb-org

yes Y | sudo systemctl start mongod
yes Y | sudo systemctl enable mongod

echo "Installing Open5GS through Package Manager"

yes Y | sudo add-apt-repository ppa:open5gs/latest
yes Y | sudo apt update
yes Y | sudo apt install open5gs

#!/bin/bash

cd /home/azurecore/

sudo sed -i 's/#$nrconf{restart} = '"'"'i'"'"';/$nrconf{restart} = '"'"'a'"'"';/g' /etc/needrestart/needrestart.conf

yes Y | sudo apt update
yes Y | sudo apt install gnupg

echo "Installing Mongo"

yes Y | wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -
yes Y | echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
yes Y | sudo apt-get update
yes Y | sudo apt-get install mongodb-org

yes Y | sudo systemctl start mongod
yes Y | sudo systemctl enable mongod

echo "Setting up TUN device"

sudo ip tuntap add name ogstun mode tun
sudo ip addr add 10.45.0.1/16 dev ogstun
sudo ip addr add 2001:db8:cafe::1/48 dev ogstun
sudo ip link set ogstun up

echo "Installing the dependencies for building the Open5GS"

yes Y | sudo apt install python3-pip python3-setuptools python3-wheel ninja-build build-essential flex bison git cmake libsctp-dev libgnutls28-dev libgcrypt-dev libssl-dev libidn11-dev libmongoc-dev libbson-dev libyaml-dev libnghttp2-dev libmicrohttpd-dev libcurl4-gnutls-dev libnghttp2-dev libtins-dev libtalloc-dev meson

echo "Git Clone Open5GS"

yes Y | git clone https://github.com/open5gs/open5gs

echo "Compiling with meson"

cd open5gs
yes Y | meson build --prefix=`pwd`/install
yes Y | ninja -C build

echo "running all the test program"

cd build
meson test -v >> test.log
ninja install

sudo tee /etc/systemd/system/5gc.service > /dev/null << EOF
[Unit]
Description=NrfService

[Service]
User=azurecore
WorkingDirectory=/home/azurecore/open5gs
ExecStart=/home/azurecore/open5gs/build/tests/app/5gc
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

sudo chown azurecore:azurecore /home/azurecore/open5gs/install/var/log/open5gs
sudo chmod 755 /home/azurecore/open5gs/install/var/log/open5gs

sudo systemctl daemon-reload
sudo systemctl enable 5gc.service
sudo systemctl start 5gc.service

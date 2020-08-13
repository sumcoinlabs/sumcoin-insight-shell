#!/usr/bin/env bash

D=$PWD

if [ ! -f /swapfile ]; then
fallocate -l 4G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
sudo sh -c "echo '/swapfile none swap sw 0' >> /etc/fstab"
fi

sudo apt-get update

sudo apt-get install \
      build-essential pkg-config libc6-dev m4 g++-multilib \
      autoconf libtool ncurses-dev unzip git python python-zmq \
      zlib1g-dev wget bsdmainutils automake curl apache2 libzmq3-dev
      
sudo service apache2 start

# install npm and use node v4
cd ..

curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install nodejs -y

# install ZeroMQ libraries
sudo apt-get -y install libzmq3-dev

# install mongodb
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6
echo "deb [ arch=amd64,arm64 ] http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.4.list
sudo apt-get update
sudo apt-get install -y mongodb-org
sudo service mongod start

# install sumcoin version of bitcore
npm install sumcore-node

# create bitcore node
./node_modules/sumcore-node/bin/sumcore-node create insight-sumcoin
cd insight-sumcoin

wget -N https://github.com/sumcoinlabs/sumcoin/archive/v0.16.1.zip -O binary.zip
unzip -o binary.zip

# install insight api/ui
../node_modules/sumcore-node/bin/sumcore-node install sumcoinlabs/insight-sum-api sumcoinlabs/insight-sum-ui

# create sumcore config file for sumcore
cat << EOF > sumcore-node.json
{
  "network": "mainnet",
  "port": 3001,
  "services": [
    "sumcoind",
    "insight-sum-api",
    "insight-sum-ui",
    "web"
  ],
  "servicesConfig": {
    "sumcoind": {
      "spawn": {
        "datadir": "./data",
        "exec": "./sumcoind"
      }
    },
     "insight-sum-ui": {
      "apiPrefix": "api"
     },
    "insight-sum-api": {
      "routePrefix": "api"
    }
  }
}
EOF

#need to sync blockchain again with indexed

# create sumcoin.conf
cat << EOF > data/sumcoin.conf
server=1
whitelist=127.0.0.1
txindex=1
addressindex=1
timestampindex=1
#masternodeprotection=1
spentindex=1
zmqpubrawtx=tcp://127.0.0.1:3332
zmqpubhashblock=tcp://127.0.0.1:3332
rpcallowip=127.0.0.1
rpcuser=sumcoinusername
rpcpassword=SecurePassword
#uacomment=bitcore
showmetrics=0
rpcport=3332
maxconnections=100
EOF

cd ~/sumcoin-explorer

echo "Start the insight block explorer, then, open in your browser http://server_ip:3001"
echo "Run this command to start insight explorer"
echo "./node_modules/sumcore-node/bin/sumcore-node start"

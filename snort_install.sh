#!/bin/bash

# Create snort directory
mkdir -p /root/snort

# Update package lists
sudo apt-get update

# Install necessary libraries
sudo apt-get install -y build-essential autotools-dev libdumbnet-dev libluajit-5.1-dev libpcap-dev \
zlib1g-dev pkg-config libhwloc-dev cmake liblzma-dev openssl libssl-dev cpputest libsqlite3-dev \
libtool uuid-dev git autoconf bison flex libcmocka-dev libnetfilter-queue-dev libunwind-dev \
libmnl-dev ethtool libjemalloc-dev

# STEP 1 – Install PCRE
cd /root/snort
wget https://sourceforge.net/projects/pcre/files/pcre/8.45/pcre-8.45.tar.gz
tar -xzvf pcre-8.45.tar.gz
cd pcre-8.45
./configure
make
sudo make install

sleep 4

# STEP 3 – Install gperftools
cd /root/snort
wget https://github.com/gperftools/gperftools/releases/download/gperftools-2.9.1/gperftools-2.9.1.tar.gz
tar xzvf gperftools-2.9.1.tar.gz
cd gperftools-2.9.1
./configure
make
sudo make install

sleep 4

# STEP 4 – Install Ragel
cd /root/snort
wget http://www.colm.net/files/ragel/ragel-6.10.tar.gz
tar -xzvf ragel-6.10.tar.gz
cd ragel-6.10
./configure
make
sudo make install

sleep 4

# STEP 5 - Download (but don’t install) the Boost C++ Libraries
cd /root/snort
wget https://boostorg.jfrog.io/artifactory/main/release/1.77.0/source/boost_1_77_0.tar.gz
tar -xvzf boost_1_77_0.tar.gz

sleep 4

# STEP 6 – Install Hyperscan
cd /root/snort
wget https://github.com/intel/hyperscan/archive/refs/tags/v5.4.2.tar.gz
tar -xvzf v5.4.2.tar.gz
mkdir /root/snort/hyperscan-5.4.2-build
cd /root/snort/hyperscan-5.4.2-build/
cmake -DCMAKE_INSTALL_PREFIX=/usr/local -DBOOST_ROOT=/root/snort/boost_1_77_0/ ../hyperscan-5.4.2
make
sudo make install

sleep 4

# STEP 7 – Install flatbuffers
cd /root/snort
wget https://github.com/google/flatbuffers/archive/refs/tags/v2.0.0.tar.gz -O flatbuffers-v2.0.0.tar.gz
tar -xzvf flatbuffers-v2.0.0.tar.gz
mkdir /root/snort/flatbuffers-build
cd /root/snort/flatbuffers-build
cmake ../flatbuffers-2.0.0
make
sudo make install

sleep 4

# STEP 8 - Install Data Acquisition (DAQ) from Snort
cd /root/snort
wget https://github.com/snort3/libdaq/archive/refs/tags/v3.0.13.tar.gz -O libdaq-3.0.13.tar.gz
tar -xzvf libdaq-3.0.13.tar.gz
cd libdaq-3.0.13
./bootstrap
./configure
make
sudo make install

sleep 4

# STEP 9 - Update shared libraries
sudo ldconfig

sleep 4

# STEP 10 – Download latest version of Snort 3
cd /root/snort
wget https://github.com/snort3/snort3/archive/refs/tags/3.1.74.0.tar.gz -O snort3-3.1.74.0.tar.gz
tar -xzvf snort3-3.1.74.0.tar.gz
cd snort3-3.1.74.0
./configure_cmake.sh --prefix=/usr/local --enable-jemalloc
cd build
make
sudo make install

sleep 4

# STEP 11 - Disable LRO & GRO using a service
sudo bash -c 'cat > /etc/systemd/system/disable-lro-gro.service << EOF
[Unit]
Description=Ethtool Configuration for Network Interface
[Service]
Requires=network.target
Type=oneshot
ExecStart=/sbin/ethtool -K <network adapter> gro off
ExecStart=/sbin/ethtool -K <network adapter> lro off
[Install]
WantedBy=multi-user.target
EOF'

# Replace <network adapter> with your actual network interface
sudo sed -i "s/<network adapter>/$(ip -o -4 route show to default | awk '{print $5}')/g" /etc/systemd/system/disable-lro-gro.service

sudo systemctl daemon-reload
sudo systemctl enable disable-lro-gro.service
sudo systemctl start disable-lro-gro.service

sleep 4

# STEP 12 – Install PulledPork3
cd /root/snort
git clone https://github.com/shirkdog/pulledpork3.git
cd pulledpork3
sudo mkdir -p /usr/local/bin/pulledpork3
sudo cp pulledpork.py /usr/local/bin/pulledpork3/
sudo cp -r lib/ /usr/local/bin/pulledpork3/
sudo chmod +x /usr/local/bin/pulledpork3/pulledpork.py
sudo mkdir -p /usr/local/etc/pulledpork3
sudo cp etc/pulledpork.conf /usr/local/etc/pulledpork3/

sleep 4

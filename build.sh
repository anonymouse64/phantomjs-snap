#!/bin/bash
set -x

cd src
export PHANTOMJSDIR=$(pwd)

# prepare apt to download sources
sudo sed -i~orig -e 's/# deb-src/deb-src/' /etc/apt/sources.list
sudo apt-get update

# download and install openssl
apt-get source openssl
cd openssl-1.0.*
./Configure --prefix=/usr --openssldir=/etc/ssl --libdir=lib ${OPENSSL_FLAGS} linux-generic64
make -j$SNAPCRAFT_PARALLEL_BUILD_COUNT depend
make -j$SNAPCRAFT_PARALLEL_BUILD_COUNT
sudo make install_sw

# download and install icu
cd 
apt-get source icu
cd icu-5*/source
./configure --prefix=/usr --enable-static --disable-shared
make -j$SNAPCRAFT_PARALLEL_BUILD_COUNT
sudo make install

# build phantomjs now
export CLANG_DIR=$SNAPCRAFT_STAGE/clang+llvm-3.8.0-aarch64-linux-gnu/bin/
cd $PHANTOMJSDIR
export CC=$CLANG_DIR/clang
export CXX=$CLANG_DIR/clang++
python build.py  --confirm --release --qt-config="-no-pkg-config" --git-clean-qtbase --git-clean-qtwebkit
mkdir -p $SNAPCRAFT_PART_INSTALL/bin
cp /tmp/phantomjs/bin/phantomjs $SNAPCRAFT_PART_INSTALL/bin/phantomjs
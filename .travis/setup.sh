#!/bin/bash
# Copyright 2018 Tymoteusz Blazejczyk
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e
set -u

function install_systemc {
    if [ ! -f "$SYSTEMC_ARCHIVE_DIR/$SYSTEMC_TAR" ]; then
        echo "Downloading $SYSTEMC_URL/$SYSTEMC_TAR..."
        wget $SYSTEMC_URL/$SYSTEMC_TAR -O $SYSTEMC_ARCHIVE_DIR/$SYSTEMC_TAR
    else
        echo "SystemC $SYSTEMC_URL/$SYSTEMC_TAR already downloaded"
    fi

    if [ ! -f "$INSTALL/systemc/$SYSTEMC_VERSION/include/systemc.h" ];then
        echo "Creating SystemC directories..."
        mkdir -p $INSTALL/systemc/$SYSTEMC_VERSION
        mkdir -p /tmp/src/systemc/$SYSTEMC_VERSION
        mkdir -p /tmp/src/systemc/$SYSTEMC_VERSION/build

        echo "Unpacking SystemC archive file..."
        tar -xf $SYSTEMC_ARCHIVE_DIR/$SYSTEMC_TAR \
            -C /tmp/src/systemc/$SYSTEMC_VERSION --strip-components 1

        echo "Patching SystemC sources..."
        cd /tmp/src/systemc/$SYSTEMC_VERSION
        sed -i 's/nb_put/this->nb_put/' \
            src/tlm_core/tlm_1/tlm_analysis/tlm_analysis_fifo.h

        echo "Configuring SystemC sources..."
        cd /tmp/src/systemc/$SYSTEMC_VERSION/build
        ../configure --enable-pthreads --enable-shared \
            --prefix=$INSTALL/systemc/$SYSTEMC_VERSION

        echo "Building SystemC library..."
        make -j`nproc`

        echo "Installing SystemC library..."
        make install
    else
        echo "SystemC library already installed"
    fi

    export SYSTEMC_INCLUDE=$INSTALL/systemc/$SYSTEMC_VERSION/include
    export SYSTEMC_LIBDIR=$INSTALL/systemc/$SYSTEMC_VERSION/lib-linux64
}

function install_uvm_systemc {
    if [ ! -f "$UVM_SYSTEMC_ARCHIVE_DIR/$UVM_SYSTEMC_TAR" ]; then
        echo "Downloading $UVM_SYSTEMC_URL/$UVM_SYSTEMC_TAR..."
        wget $UVM_SYSTEMC_URL/$UVM_SYSTEMC_TAR \
            -O $UVM_SYSTEMC_ARCHIVE_DIR/$UVM_SYSTEMC_TAR
    else
        echo "UVM-SystemC $UVM_SYSTEMC_URL/$UVM_SYSTEMC_TAR already downloaded"
    fi

    if [ ! -f "$INSTALL/systemc/$SYSTEMC_VERSION/include/uvm.h" ]; then
        echo "Creating UVM-SystemC directories..."
        mkdir -p /tmp/src/uvm-systemc/$UVM_SYSTEMC_VERSION
        mkdir -p /tmp/src/uvm-systemc/$UVM_SYSTEMC_VERSION/build

        echo "Unpacking UVM-SystemC archive file..."
        tar -xf $UVM_SYSTEMC_ARCHIVE_DIR/$UVM_SYSTEMC_TAR \
            -C /tmp/src/uvm-systemc/$UVM_SYSTEMC_VERSION --strip-components 1

        echo "Creating UVM-SystemC configure file..."
        cd /tmp/src/uvm-systemc/$UVM_SYSTEMC_VERSION
        ./config/bootstrap

        echo "Configuring UVM-SystemC sources..."
        cd /tmp/src/uvm-systemc/$UVM_SYSTEMC_VERSION/build
        ../configure --enable-shared --with-systemc=$INSTALL/systemc/$SYSTEMC_VERSION \
            --prefix=$INSTALL/systemc/$SYSTEMC_VERSION

        echo "Building UVM-SystemC library..."
        make -j`nproc`

        echo "Installing UVM-SystemC library..."
        make install
    else
        echo "UVM-SystemC library already installed"
    fi
}

function install_scv {
    if [ ! -f "$SCV_ARCHIVE_DIR/$SCV_TAR" ]; then
        echo "Downloading $SCV_URL/$SCV_TAR..."
        wget $SCV_URL/$SCV_TAR -O $SCV_ARCHIVE_DIR/$SCV_TAR
    else
        echo "SCV $SCV_URL/$SCV_TAR already downloaded"
    fi

    if [ ! -f "$INSTALL/systemc/$SYSTEMC_VERSION/include/scv.h" ]; then
        echo "Creating SCV directories..."
        mkdir -p /tmp/src/scv/$SCV_VERSION
        mkdir -p /tmp/src/scv/$SCV_VERSION/build

        echo "Unpacking SCV archive file..."
        tar -xf $SCV_ARCHIVE_DIR/$SCV_TAR \
            -C /tmp/src/scv/$SCV_VERSION --strip-components 1

        echo "Configuring SCV sources..."
        cd /tmp/src/scv/$SCV_VERSION/build
        ../configure --enable-shared --with-systemc=$INSTALL/systemc/$SYSTEMC_VERSION \
            --prefix=$INSTALL/systemc/$SYSTEMC_VERSION

        echo "Building SCV library..."
        make -j`nproc`

        echo "Installing SCV library..."
        make install
    else
        echo "SCV library already installed"
    fi
}

function install_verilator {
    if [ ! -f "$VERILATOR_ARCHIVE_DIR/$VERILATOR_TAR" ]; then
        echo "Downloading $VERILATOR_URL/$VERILATOR_TAR..."
        wget $VERILATOR_URL/$VERILATOR_TAR \
            -O $VERILATOR_ARCHIVE_DIR/$VERILATOR_TAR
    else
        echo "Verilator $VERILATOR_URL/$VERILATOR_TAR already downloaded"
    fi

    if [ ! -x "$INSTALL/verilator/$VERILATOR_VERSION/bin/verilator" ]; then
        echo "Creating Verilator directories..."
        mkdir -p $INSTALL/verilator/$VERILATOR_VERSION
        mkdir -p /tmp/src/verilator/$VERILATOR_VERSION

        echo "Unpacking Verilator archive file..."
        tar -xzf $VERILATOR_ARCHIVE_DIR/$VERILATOR_TAR \
            -C /tmp/src/verilator/$VERILATOR_VERSION --strip-components 1

        echo "Installing Verilator dependencies..."
        sudo apt-get install git make autoconf g++ flex bison -y

        echo "Configuring Verilator sources..."
        cd /tmp/src/verilator/$VERILATOR_VERSION
        ./configure --prefix=$INSTALL/verilator/$VERILATOR_VERSION

        echo "Building Verilator library..."
        make -j`nproc`

        echo "Installing Verilator library..."
        make install
    else
        echo "Verilator already installed"
    fi

    export VERILATOR_ROOT=$INSTALL/verilator/$VERILATOR_VERSION
}

function install_gtest {
    if [ ! -f "$INSTALL/gtest/$GTEST_VERSION/include/gtest/gtest.h" ]; then
        echo "Creating Google Test directories..."
        mkdir -p $INSTALL/gtest/$GTEST_VERSION
        mkdir -p /tmp/src/gtest/$GTEST_VERSION
        mkdir -p /tmp/src/gtest/$GTEST_VERSION/build

        echo "Downloading Google Test sources..."
        cd /tmp/src/gtest/$GTEST_VERSION
        git clone https://github.com/google/googletest.git build
        git checkout 703b4a8

        echo "Configuring Google Test sources..."
        cd /tmp/src/gtest/$GTEST_VERSION/build
        cmake -DBUILD_SHARED_LIBS=ON \
            -DCMAKE_INSTALL_PREFIX=$INSTALL/gtest/$GTEST_VERSION ..

        echo "Building Google Test library..."
        cmake --build . --target all -- -j`nproc`

        echo "Installing Google Test library..."
        cmake --build . --target install
    else
        echo "Google Test library already installed"
    fi

    export GTEST_ROOT=$INSTALL/gtest/$GTEST_VERSION
}

echo "Preparing tools..."

sudo apt-get update -qq

INSTALL=$HOME/tools

SYSTEMC_ARCHIVE_DIR=$HOME/archive/systemc
SYSTEMC_VERSION=2.3.2
SYSTEMC_URL=http://accellera.org/images/downloads/standards/systemc
SYSTEMC_TAR=systemc-$SYSTEMC_VERSION.tar.gz

install_systemc

UVM_SYSTEMC_ARCHIVE_DIR=$HOME/archive/uvm-systemc
UVM_SYSTEMC_VERSION=1.0-beta1
UVM_SYSTEMC_URL=http://accellera.org/images/downloads/standards/systemc
UVM_SYSTEMC_TAR=uvm-systemc-$UVM_SYSTEMC_VERSION.tar.gz

install_uvm_systemc

SCV_ARCHIVE_DIR=$HOME/archive/scv
SCV_VERSION=2.0.1
SCV_URL=http://accellera.org/images/downloads/standards/systemc
SCV_TAR=scv-$SCV_VERSION.tar.gz

install_scv

VERILATOR_ARCHIVE_DIR=$HOME/archive/verilator
VERILATOR_VERSION=3.920
VERILATOR_URL=https://www.veripool.org/ftp
VERILATOR_TAR=verilator-$VERILATOR_VERSION.tgz

install_verilator

GTEST_ROOT=$HOME/archive/gtest
GTEST_VERSION=master
GTEST_URL=https://github.com/google/googletest/archive
GTEST_TAR=$GTEST_VERSION.zip

install_gtest

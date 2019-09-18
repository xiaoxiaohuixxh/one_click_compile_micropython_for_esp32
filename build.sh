#!/bin/bash
tmp_root_dir=$PWD
echo "============================================================"
echo "      One Key Install bpi bit mpy development"
echo "============================================================"
echo "clone the mpy project from github..."
sudo apt-get update
sudo apt-get install -y git
git clone --recursive https://github.com/BPI-STEAM/micropython.git
# read support idf hash
while read line
do
    # echo "File:${line}"
    tmp_line=`echo ${line} | sed s/[[:space:]]//g`
    # echo "tmp_line:$tmp_line"
    if [[ $tmp_line =~ 'ESPIDF_SUPHASH:=' ]]
    then
        sup_idf_hash=${tmp_line#*ESPIDF_SUPHASH:=}
        echo "sup_idf_hash:$sup_idf_hash";
        break
    fi
done  < micropython/ports/esp32/Makefile
echo "sup_idf_hash:$sup_idf_hash";
echo "clone the idf project from github..."
git clone https://github.com/espressif/esp-idf.git
cd esp-idf
git checkout $sup_idf_hash
git submodule update --init --recursive
cd $tmp_root_dir
echo "instal development"
sudo apt-get install -y gcc git wget make libncurses-dev flex bison gperf python python-pip python-setuptools python-serial python-cryptography python-future python-pyparsing python-pyelftools tar python3 python3-pip
sudo apt-get install -y python3-setuptools
sudo apt-get install -y libssl-dev
echo "download esp32 toolchain"
if [ $(getconf WORD_BIT) = '32' ] && [ $(getconf LONG_BIT) = '64' ] ; then
    if [ -f xtensa-esp32-elf-linux64-1.22.0-80-g6c4433a-5.2.0.tar.gz ] ;then
        echo "remove old file"
        rm -f xtensa-esp32-elf-linux64-1.22.0-80-g6c4433a-5.2.0.tar.gz
    fi
    # wget http://192.254.69.211/xtensa-esp32-elf-linux64-1.22.0-80-g6c4433a-5.2.0.tar.gz
    # tar xvf xtensa-esp32-elf-linux64-1.22.0-80-g6c4433a-5.2.0.tar.gz
    wget https://dl.espressif.com/dl/xtensa-esp32-elf-linux64-1.22.0-80-g6c4433a-5.2.0.tar.gz&&tar xvf xtensa-esp32-elf-linux64-1.22.0-80-g6c4433a-5.2.0.tar.gz
elif [ $(getconf LONG_BIT) = '32' ] ;then
    if [ -f xtensa-esp32-elf-linux32-1.22.0-80-g6c4433a-5.2.0.tar.gz ]; then
        rm -f xtensa-esp32-elf-linux32-1.22.0-80-g6c4433a-5.2.0.tar.gz
    fi
    wget https://dl.espressif.com/dl/xtensa-esp32-elf-linux32-1.22.0-80-g6c4433a-5.2.0.tar.gz&&tar xvf xtensa-esp32-elf-linux32-1.22.0-80-g6c4433a-5.2.0.tar.gz
else
    echo "error:not support this machine"
    exit 0
fi
if [ -d xtensa-esp32-elf ];then
    echo $PWD
    echo $tmp_root_dir
    echo "root_dir:$tmp_root_dir"
    echo "export PATH=\"$tmp_root_dir/xtensa-esp32-elf/bin:\$PATH\"" >> ~/.profile
    echo "export IDF_PATH=$tmp_root_dir/esp-idf" >> ~/.profile
    echo "export ESPIDF=$tmp_root_dir/esp-idf" >> ~/.profile
    source ~/.profile
    pip3 install --user -r $IDF_PATH/requirements.txt
else
    echo "error: install toolchains failed"
    exit 0
fi
source ~/.profile
echo "============================================================"
echo "      Compiling"
echo "============================================================"
cd $tmp_root_dir
cd micropython/mpy-cross && make && cd $tmp_root_dir
cd $tmp_root_dir
cd micropython/ports/esp32 && make

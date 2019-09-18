#!/bin/bash
tmp_root_dir=$PWD
echo "============================================================"
echo "      One Key COMPILE bpi bit mpy development"
echo "============================================================"
echo "clone the mpy project from github..."

echo "============================================================"
echo "      Compiling"
echo "============================================================"
cd $tmp_root_dir
cd micropython/mpy-cross && make && cd $tmp_root_dir
cd $tmp_root_dir
cd micropython/ports/esp32 && make
echo "============================================================"
echo "      Compiled"
echo "============================================================"

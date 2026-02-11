#!/bin/bash
# File: stage00/gcc-s1.sh
set -e
echo "---------------- gcc-s1.sh -----------------------"
echo "--- Шаг 0: Настройка окружения ---"
export MAKEFLAGS="-j$(nproc)"

export WORK_DIR=$HOME/work
export PREFIX=$HOME/toolchain
export TARGET=x86_64-custom-linux-gnu

mkdir -p $WORK_DIR
mkdir -p $PREFIX

echo "--- Шаг 1: Загрузка исходников ---"
echo "gcc-s1 placeholder" > $PREFIX/gcc-s1.txt

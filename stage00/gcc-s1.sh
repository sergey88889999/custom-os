#!/bin/bash
# File: stage00/gcc-s1.sh
set -e
echo "---------------- gcc-s1.sh -----------------------"
echo "--- Шаг 0: Настройка окружения ---"
# Выводим количество ядер и инфо по памяти
CORES=$(nproc)
MEM_TOTAL=$(free -h | awk '/^Mem:/ {print $2}')
echo "CPU Cores available: $CORES"
echo "Total RAM available: $MEM_TOTAL"
export MAKEFLAGS="-j$CORES"

export WORK_DIR=$HOME/work
export PREFIX=$HOME/toolchain
export TARGET=x86_64-custom-linux-gnu

mkdir -p $WORK_DIR
mkdir -p $PREFIX

echo "--- Шаг 1: Загрузка исходников ---"
echo "gcc-s1 placeholder" > $PREFIX/gcc-s1.txt

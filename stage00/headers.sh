#!/bin/bash
# File: stage00/headers.sh
set -e
echo "---------------- headers.sh -----------------------"
echo "--- Шаг 0: Настройка окружения ---"
export MAKEFLAGS="-j$(nproc)"

export WORK_DIR=$HOME/work
export PREFIX=$HOME/toolchain
export TARGET=x86_64-custom-linux-gnu

mkdir -p $WORK_DIR
mkdir -p $PREFIX

echo "--- Шаг 1: Загрузка исходников ---"
echo "headers placeholder" > $PREFIX/headers.txt


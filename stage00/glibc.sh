#!/bin/bash
# File: stage00/glibc.sh
set -e
echo "---------------- glibc.sh -----------------------"
echo "--- Шаг 0: Настройка окружения ---"
export MAKEFLAGS="-j$(nproc)"

export WORK_DIR=$HOME/work
export PREFIX=$HOME/toolchain
export TARGET=x86_64-custom-linux-gnu
export PATH="$PREFIX/bin:$PATH"

mkdir -p $WORK_DIR
mkdir -p $PREFIX

echo "--- Шаг 1: Загрузка исходников ---"
echo "glibc placeholder" > $PREFIX/glibc.txt

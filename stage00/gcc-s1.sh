#!/bin/bash
# File: stage00/gcc-s1.sh
set -e
echo "---------------- gcc-s1.sh -----------------------"
echo "--- Шаг 0: Настройка окружения ---"
CORES=$(nproc)

export MAKEFLAGS="-j$CORES"
export WORK_DIR=$HOME/work
export PREFIX=$HOME/toolchain
export TARGET=x86_64-custom-linux-gnu
export PATH="$PREFIX/bin:$PATH"

VERSION_GCC="15.2.0"

mkdir -p $WORK_DIR
cd $WORK_DIR

echo "--- Шаг 1: Загрузка исходников GCC ---"
wget -c https://ftp.gnu.org/gnu/gcc/gcc-${VERSION_GCC}/gcc-${VERSION_GCC}.tar.xz
tar -xJf gcc-${VERSION_GCC}.tar.xz

echo "--- Шаг 2: Загрузка зависимостей (GMP, MPFR, MPC) ---"
cd gcc-${VERSION_GCC}
./contrib/download_prerequisites
cd ..

echo "--- Шаг 3: Конфигурация Stage 1 (ВНЕ дерева исходников) ---"
rm -rf gcc-build && mkdir gcc-build && cd gcc-build

../gcc-${VERSION_GCC}/configure --target=$TARGET \
    --prefix=$PREFIX \
    --with-sysroot=$PREFIX/$TARGET \
    --with-newlib \
    --without-headers \
    --disable-nls \
    --disable-shared \
    --disable-multilib \
    --disable-decimal-float \
    --disable-threads \
    --disable-libatomic \
    --disable-libgomp \
    --disable-libquadmath \
    --disable-libssp \
    --disable-libvtv \
    --disable-libstdcxx \
    --enable-languages=c,c++

echo "--- Шаг 4: Компиляция ---"
make all-gcc all-target-libgcc
make install-gcc install-target-libgcc

echo "--- Шаг 5: Очистка ---"
cd $WORK_DIR
# Удаляем и исходники, и папку сборки
rm -rf gcc-${VERSION_GCC} gcc-build

echo "---------------- gcc-s1.sh DONE ------------------"
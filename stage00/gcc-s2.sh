#!/bin/bash
# File: stage00/gcc-s2.sh
set -e

echo "---------------- gcc-s2.sh -----------------------"
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

echo "--- Шаг 1: Подготовка исходников ---"
# Мы скачиваем заново или используем кэш, чтобы папка была чистой
wget -c https://ftp.gnu.org/gnu/gcc/gcc-${VERSION_GCC}/gcc-${VERSION_GCC}.tar.xz
tar -xJf gcc-${VERSION_GCC}.tar.xz
cd gcc-${VERSION_GCC}
./contrib/download_prerequisites
cd ..

echo "--- Шаг 2: Конфигурация Stage 2 (Финальный кросс-компилятор) ---"
rm -rf gcc-build-final && mkdir gcc-build-final && cd gcc-build-final

../gcc-${VERSION_GCC}/configure --target=$TARGET \
    --prefix=$PREFIX \
    --with-sysroot=$PREFIX/$TARGET \
    --enable-languages=c,c++ \
    --enable-shared \
    --enable-threads=posix \
    --enable-clocale=gnu \
    --enable-libstdcxx \
    --disable-multilib \
    --disable-nls \
    --disable-bootstrap \
    --disable-libstdcxx-pch \
    --with-system-zlib

echo "--- Шаг 3: Компиляция ---"
make 
make install

echo "--- Шаг 4: Проверка ---"
echo ""
echo 'int main(){return 0;}' > test.c
$PREFIX/bin/$TARGET-gcc test.c -o test
file test
echo ""

echo "--- Шаг 5: Очистка ---"
cd $WORK_DIR
rm -rf gcc-${VERSION_GCC} gcc-build-final

echo "---------------- gcc-s2.sh DONE ------------------"

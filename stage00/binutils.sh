#!/bin/bash
# File: stage00/binutils.sh
set -e
echo "---------------- binutils.sh -----------------------"
echo ""
echo "--- Шаг 0: Настройка окружения ---"
export MAKEFLAGS="-j$(nproc)"

export WORK_DIR=$HOME/work
export PREFIX=$HOME/toolchain
export TARGET=x86_64-custom-linux-gnu

# весии компилируемых пакетов
VERSION_BINUTILS="2.46.0"

mkdir -p $WORK_DIR
mkdir -p $PREFIX

echo "--- Шаг 1: Загрузка исходников ---"
cd $WORK_DIR
wget -c https://ftp.gnu.org/gnu/binutils/binutils-${VERSION_BINUTILS}.tar.xz
tar -xJf binutils-${VERSION_BINUTILS}.tar.xz

echo "--- Шаг 2: Компиляция (Stage 0: Binutils) ---"
cd binutils-${VERSION_BINUTILS}
rm -rf build && mkdir build && cd build

# Ссылаемся на конфиг в папке с исходниками
../configure --target=$TARGET \
    --prefix=$PREFIX \
    --with-sysroot=$PREFIX/$TARGET \
    --disable-nls \
    --disable-werror
make && make install

echo "--- Шаг 3: Проверка ---"
$PREFIX/bin/$TARGET-ld --version

echo "--- Шаг 4: Готово (Binutils собраны и установлены в $PREFIX) ---"
echo ""
echo "Ядер: $MAKEFLAGS"
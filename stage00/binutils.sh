#!/bin/bash
# File: stage00/binutils.sh
set -e
echo "---------------- binutils.sh -----------------------"
echo ""
echo "--- Шаг 0: Настройка окружения ---"

# Выводим количество ядер и инфо по памяти
CORES=$(nproc)
MEM_TOTAL=$(free -h | awk '/^Mem:/ {print $2}')
DISK_AVAIL=$(df -h . | awk 'NR==2 {print $4}')

export MAKEFLAGS="-j$CORES"

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

echo "--- Шаг 4: Очистка рабочего пространства ---"
cd $WORK_DIR
rm -rf binutils-${VERSION_BINUTILS}


echo "------------------- Statistic ---------------------"
echo "CPU Cores used: $CORES"
echo "Total RAM: $MEM_TOTAL"
echo "Disk space available: $DISK_AVAIL"
echo "---------------- binutils.sh DONE ------------------"

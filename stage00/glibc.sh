#!/bin/bash
# File: stage00/glibc.sh
set -e

echo "---------------- glibc.sh -----------------------"
echo "--- Шаг 0: Настройка окружения ---"

# Количество ядер и переменные
CORES=$(nproc)
export MAKEFLAGS="-j$CORES"
export WORK_DIR=$HOME/work
export PREFIX=$HOME/toolchain
export TARGET=x86_64-custom-linux-gnu
export PATH="$PREFIX/bin:$PATH"

VERSION_GLIBC="2.43" 

mkdir -p $WORK_DIR
cd $WORK_DIR

echo "--- Шаг 1: Загрузка исходников  ---"
wget -c https://ftp.gnu.org/gnu/glibc/glibc-${VERSION_GLIBC}.tar.xz
tar -xJf glibc-${VERSION_GLIBC}.tar.xz

echo "--- Шаг 2: Конфигурация ---"
cd glibc-${VERSION_GLIBC}
rm -rf build && mkdir build && cd build

# Нюансы конфига:
# --host: указываем наш таргет, чтобы включить кросс-компиляцию
# --with-headers: путь к тем самым заголовкам из stage00/headers.sh
# libc_cv_slibdir: исправляет путь для библиотек в x86_64 (чтобы не улетели в /lib64)
../configure \
      --prefix=/usr \
      --host=$TARGET \
      --build=$(../scripts/config.guess) \
      --enable-kernel=6.18.0 \
      --with-headers=$PREFIX/$TARGET/include \
      --disable-werror \
      libc_cv_slibdir=/usr/lib

echo "--- Шаг 3: Компиляция ---"
make && make DESTDIR=$PREFIX/$TARGET install

echo "--- Шаг 4: Копирование в sysroot для GCC Stage 2 ---"
# GCC ищет заголовки и библиотеки в корне sysroot
mkdir -p $PREFIX/$TARGET/lib
cp -a $PREFIX/$TARGET/usr/include/* $PREFIX/$TARGET/include/
cp -a $PREFIX/$TARGET/usr/lib/* $PREFIX/$TARGET/lib/

echo "--- Шаг 5: Проверка линковки ---"
# Простая проверка: видит ли наш кросс-компилятор библиотеку?
if [ -f "$PREFIX/$TARGET/usr/lib/libc.so" ]; then
    echo "SUCCESS: Glibc установлен в $PREFIX/$TARGET/usr/lib"
else
    echo "ERROR: libc.so не найден!"
    exit 1
fi
if [ -f "$PREFIX/$TARGET/include/stdio.h" ]; then
    echo "SUCCESS: Headers скопированы в $PREFIX/$TARGET/include"
else
    echo "ERROR: stdio.h не найден в sysroot!"
    exit 1
fi

echo "--- Шаг 6: Очистка ---"
cd $WORK_DIR
rm -rf glibc-${VERSION_GLIBC}

echo "---------------- glibc.sh DONE ------------------"

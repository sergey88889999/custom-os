#!/bin/bash
# File: stage00/glibc.sh
set -e
echo "---------------- glibc.sh -----------------------"
echo "--- Шаг 0: Настройка окружения ---"
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
mkdir -p $PREFIX/$TARGET/lib
cp -a $PREFIX/$TARGET/usr/include/* $PREFIX/$TARGET/include/
cp -a $PREFIX/$TARGET/usr/lib/* $PREFIX/$TARGET/lib/

echo "--- Шаг 4.1: Исправление линкерных скриптов ---"
# Файлы .so в glibc - это текстовые линкерные скрипты с абсолютными путями
# Заменяем /usr/lib на относительный путь в sysroot
for libscript in $PREFIX/$TARGET/lib/libc.so $PREFIX/$TARGET/lib/libpthread.so $PREFIX/$TARGET/lib/libm.so; do
    if [ -f "$libscript" ] && file "$libscript" | grep -q "ASCII text"; then
        echo "Fixing linker script: $libscript"
        sed -i "s|/usr/lib|/lib|g" "$libscript"
    fi
done

# Также исправляем в usr/lib (на всякий случай)
for libscript in $PREFIX/$TARGET/usr/lib/libc.so $PREFIX/$TARGET/usr/lib/libpthread.so $PREFIX/$TARGET/usr/lib/libm.so; do
    if [ -f "$libscript" ] && file "$libscript" | grep -q "ASCII text"; then
        echo "Fixing linker script: $libscript"
        sed -i "s|/usr/lib|/lib|g" "$libscript"
    fi
done

echo "--- Шаг 5: Проверка линковки ---"
if [ -f "$PREFIX/$TARGET/usr/lib/libc.so" ]; then
    echo "SUCCESS: Glibc установлен в $PREFIX/$TARGET/usr/lib"
    echo "Content of libc.so linker script:"
    cat "$PREFIX/$TARGET/lib/libc.so" || true
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

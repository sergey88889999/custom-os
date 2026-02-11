#!/bin/bash
# File: stage00/headers.sh
set -e
echo "---------------- headers.sh -----------------------"
echo "--- Шаг 0: Настройка окружения ---"
# Выводим количество ядер и инфо по памяти
CORES=$(nproc)
export MAKEFLAGS="-j$CORES"

export WORK_DIR=$HOME/work
export PREFIX=$HOME/toolchain
export TARGET=x86_64-custom-linux-gnu

# Твой выбор: Самая свежая стабильная версия на февраль 2026
VERSION_LINUX="6.18.10"

mkdir -p $WORK_DIR
mkdir -p $PREFIX

echo "--- Шаг 1: Загрузка исходников ядра ($VERSION_LINUX) ---"
cd $WORK_DIR
# Используем зеркало kernel.org
wget -c https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-${VERSION_LINUX}.tar.xz
tar -xJf linux-${VERSION_LINUX}.tar.xz

echo "--- Шаг 2: Установка заголовков ---"
cd linux-${VERSION_LINUX}

# Очистка дерева исходников
make mrproper

# Установка заголовков в sysroot
# ARCH=x86_64 гарантирует правильную генерацию заголовочных файлов asm
make ARCH=x86_64 INSTALL_HDR_PATH=$PREFIX/$TARGET headers_install

echo "--- Шаг 3: Проверка ---"
if [ -d "$PREFIX/$TARGET/include/linux" ]; then
    echo "SUCCESS: Заголовки ядра 6.18.10 установлены."
    # Проверим наличие базового заголовочного файла
    ls -l $PREFIX/$TARGET/include/linux/version.h
else
    echo "FATAL: Заголовки не найдены!"
    exit 1
fi

echo "--- Шаг 4: Чистка WORK_DIR ---"
cd $WORK_DIR
rm -rf linux-${VERSION_LINUX}

echo "---------------- headers.sh DONE ------------------"
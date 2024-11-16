#!/bin/bash

###
### Use toolchain https://github.com/Neutron-Toolchains/clang-build-catalogue/releases/download/16012023/neutron-clang-16012023.tar.zst
### Extract to $HOME/android/toolchains/neutron-clang
### git submodule add https://gitlab.com/kalilinux/nethunter/build-scripts/kali-nethunter-kernel-builder
### cd kali-nethunter-kernel-builder/
### export KBUILD_BUILD_HOST=ubuntu
###

# Define colors
GREEN="\e[1;32m"
RED="\e[1;31m"
YELLOW="\e[1;33m"
CYAN="\e[1;36m"
DEFAULT="\e[0m"


# Define variables
CLANG_VER="clang-r510928"

# Check if CLANG_DIR exists, if not try alternative paths
if [ -d "$HOME/02.KERNEL/TOOLCHAINS/toolchain-neutron-clang/clang-r510928" ]; then
    CLANG_DIR="$HOME/02.KERNEL/TOOLCHAINS/toolchain-neutron-clang/clang-r510928"
else
    echo -e "${RED}Could not find the specified clang directory.${DEFAULT}"
    exit 1
fi

echo -e "${YELLOW}Using clang directory: $CLANG_DIR${DEFAULT}"


KERNEL_DIR=$PWD
Anykernel_DIR=$KERNEL_DIR/AnyKernel3/
DATE=$(date +"[%d%m%Y]")
TIME=$(date +"%H.%M.%S")
KERNEL_NAME="4.14.355-NetHunter"
DEVICE="samurai"
FINAL_ZIP="$DEVICE"-"$KERNEL_NAME"-"$DATE"-KSU
export KBUILD_BUILD_USER=zahid
export LOCALVERSION=-NetHunter+KSU


# Sync submodule
#git submodule init && git submodule update

#Installing necessary components
! sudo apt-get install bc git gnupg flex bison build-essential zip curl zlib1g-dev libc6-dev-i386 x11proto-core-dev libx11-dev lib32z1-dev libgl1-mesa-dev libxml2-utils xsltproc unzip fontconfig libssl-dev ccache cpio axel bc build-essential ccache curl device-tree-compiler pandoc libncurses5-dev lynx lz4 fakeroot xz-utils bc build-essential ccache curl device-tree-compiler pandoc lynx lz4 fakeroot xz-utils

git clone https://github.com/zahid5656/AnyKernel3.git -b nethunter $Anykernel_DIR

BUILD_START=$(date +"%s")

# Export variables
export TARGET_KERNEL_CLANG_COMPILE=true
PATH="$CLANG_DIR/bin:${PATH}"

echo -e "${CYAN}***********************************************${DEFAULT}"
echo -e "${CYAN}        Compiling NetHunter Kernel             ${DEFAULT}"
echo -e "${CYAN}***********************************************${DEFAULT}"

# Finally build it
mkdir -p out
export ARCH=arm64
#let it continue building, don't always start from scratch
#make mrproper
#if [[ -f arch/arm64/configs/nethunter_defconfig ]]; then make O=out ARCH=arm64 nethunter_defconfig; else
#make O=out ARCH=arm64 samurai_defconfig;fi
#make O=out ARCH=arm64 menuconfig
#cp out/.config arch/arm64/configs/nethunter_defconfig
make O=out ARCH=arm64 nethunter_defconfig
make -j$(nproc --all) O=out ARCH=arm64 CC=clang CLANG_TRIPLE=aarch64-linux-gnu- CROSS_COMPILE=$CLANG_DIR/bin/llvm- LLVM=1 LLVM_IAS=1 Image.gz-dtb dtbo.img || exit

# Build complete
BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo -e "${GREEN}Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.${DEFAULT}"

#!/bin/bash


# DEFINE COLORS
NC='\033[0m'
RED='\033[0;31m'
LRD='\033[1;31m'
LGR='\033[1;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'

rm -rf out
#make clean && make mrproper

KERNEL_DIR="${PWD}"
CCACHE=$(command -v ccache)
OBJDIR="${KERNEL_DIR}/out"
Anykernel_DIR=$KERNEL_DIR/Anykernel3
BUILDDIR="${KERNEL_DIR}/build"
ZIMAGE=$KERNEL_DIR/out/arch/arm64/boot/Image.gz-dtb
KERNEL_NAME="samurai-4.14.355"
DATE=$(date +"[%d%m%Y-%H%M]")
TIME=$(date +"%H.%M.%S")
ZIP_NAME="$KERNEL_NAME-$DATE-KSU.zip"
TC_CLONE_FILE=${KERNEL_DIR}/toolchain_clone.sh
export CONFIG_FILE="samurai_defconfig"
export ARCH="arm64"
export KBUILD_BUILD_HOST=ubuntu
export KBUILD_BUILD_USER=zahid
#export LOCALVERSION=+KSU

# DEFINE VARIABLES & CLANG TOOLCHAIN
TC_DIR=${HOME}/02.KERNEL/TOOLCHAINS/toolchain
CLANG_DIR=$TC_DIR/clang-r536225

##Check if CLANG_DIR exists........
if ! [ -d "$TC_DIR" ]; then
    echo -e "${LRD}Toolchain not found! Cloning to $TC_DIR...${NC}"
    if ! bash $TC_CLONE_FILE; then
        echo -e "${RED}Cloning failed! Aborting...${NC}"
        exit 1      
    fi
fi

echo -e "${YELLOW}Using clang directory: $CLANG_DIR${NC}"
export PATH="$CLANG_DIR/bin:$PATH"

##SYNC SUBMODULE
#git submodule init && git submodule update

##Installing necessary components
! sudo apt-get install bc git gnupg flex bison build-essential zip curl zlib1g-dev libc6-dev-i386 x11proto-core-dev libx11-dev lib32z1-dev libgl1-mesa-dev libxml2-utils xsltproc unzip fontconfig libssl-dev ccache cpio axel bc build-essential ccache curl device-tree-compiler pandoc libncurses5-dev lynx lz4 fakeroot xz-utils bc build-essential ccache curl device-tree-compiler pandoc lynx lz4 fakeroot xz-utils

##BUILD STARTED.....!!!
make_defconfig()
{
    BUILD_START=$(date +"%s")
    echo -e ${LGR} "*********************************************${NC}"
    echo -e ${LGR} "########### Generating Defconfig ############${NC}"
    make -s ARCH=${ARCH} O=${OBJDIR} ${CONFIG_FILE} -j$(nproc --all)
#    make -s ARCH=${ARCH} O=${OBJDIR} menuconfig
}
compile()
{
    cd ${KERNEL_DIR}
    echo -e "${CYAN}*********************************************${NC}"
    echo -e "${CYAN}              COMPILING KERNEL               ${NC}"
    echo -e "${CYAN}*********************************************${NC}"
    make -j$(nproc --all) \
    O=out \
    ARCH=${ARCH}\
    CC="ccache clang" \
    CLANG_TRIPLE="aarch64-linux-gnu-" \
    CROSS_COMPILE="aarch64-linux-gnu-" \
    CROSS_COMPILE_ARM32="arm-linux-gnueabi-" \
    LLVM=1 \
    LLVM_IAS=1
}

completion()
{
    cd ${OBJDIR}
    COMPILED_IMAGE=arch/arm64/boot/Image.gz-dtb
    COMPILED_DTBO=arch/arm64/boot/dtbo.img
    if [[ -f ${COMPILED_IMAGE} && ${COMPILED_DTBO} ]]; then

        git clone https://github.com/zahid5656/AnyKernel3.git $Anykernel_DIR

        mv -f $ZIMAGE ${COMPILED_DTBO} $Anykernel_DIR

        cd $Anykernel_DIR
        find . -name "*.zip" -type f
        find . -name "*.zip" -type f -delete
        zip -r AnyKernel.zip *
        mv AnyKernel.zip $ZIP_NAME
        mv $Anykernel_DIR/$ZIP_NAME $KERNEL_DIR/$ZIP_NAME
        rm -rf $Anykernel_DIR
        echo -e ${LGR} "###################################################"
        echo -e ${LGR} "######   KERNEL COMPILED SUCCESSFULLY!!! :)  ######"
        echo -e ${LGR} "###################################################${NC}"
        BUILD_END=$(date +"%s")
        DIFF=$(($BUILD_END - $BUILD_START))
        echo -e "${LGR}BUILD COMPLETED in $(($DIFF / 60)) minute(s) & $(($DIFF % 60)) seconds.${NC}"
        exit 0
    else
        echo -e ${LRD} "############################################"
        echo -e ${LRD} "###       ERROR!!! Unsccessfull :'(      ###"
        echo -e ${LRD} "############################################${NC}"
        exit 1
    fi
}
make_defconfig
compile
completion
cd ${KERNEL_DIR}

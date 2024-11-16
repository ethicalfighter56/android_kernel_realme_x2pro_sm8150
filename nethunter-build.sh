#!/bin/bash

### git submodule add https://gitlab.com/kalilinux/nethunter/build-scripts/kali-nethunter-kernel-builder
### cd kali-nethunter-kernel-builder/
### export KBUILD_BUILD_HOST=ubuntu

rm -rf out
make clean && make mrproper

kernel_dir="${PWD}"
CCACHE=$(command -v ccache)
objdir="${kernel_dir}/out"
anykernel=$kernel_dir/anykernel
builddir="${kernel_dir}/build"
ZIMAGE=$kernel_dir/out/arch/arm64/boot/Image.gz-dtb
kernel_name="samurai-4.14.355-NH"
zip_name="$kernel_name-$(date +"%d%m%Y-%H%M")-KSU.zip"
TC_DIR=$HOME/02.KERNEL/TOOLCHAIN/toolchain
CLANG_DIR=$TC_DIR/clang-r536225
export CONFIG_FILE="nethunter_defconfig"
export ARCH="arm64"
export KBUILD_BUILD_USER=zahid
export LOCALVERSION=-NetHunter+KSU 

export PATH="$CLANG_DIR/bin:$PATH"

# Sync submodule
git submodule init && git submodule update

#Installing necessary components
! sudo apt-get install bc git gnupg flex bison build-essential zip curl zlib1g-dev libc6-dev-i386 x11proto-core-dev libx11-dev lib32z1-dev libgl1-mesa-dev libxml2-utils xsltproc unzip fontconfig libssl-dev ccache cpio

if ! [ -d "$TC_DIR" ]; then
    echo "Toolchain not found! Cloning to $TC_DIR..."
    if ! git clone -q --depth=1 --single-branch https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86 -b master $TC_DIR; then
        echo "Cloning failed! Aborting..."
        exit 1
    fi
fi

# Colors
NC='\033[0m'
RED='\033[0;31m'
LRD='\033[1;31m'
LGR='\033[1;32m'

make_defconfig()
{
    START=$(date +"%s")
    echo -e ${LGR} "########### Generating Defconfig ############${NC}"
    make -s ARCH=${ARCH} O=${objdir} ${CONFIG_FILE} -j$(nproc --all)
#    make -s ARCH=${ARCH} O=${objdir} menuconfig
}
compile()
{
    cd ${kernel_dir}
    echo -e ${LGR} "######### Compiling kernel #########${NC}"
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
    cd ${objdir}
    COMPILED_IMAGE=arch/arm64/boot/Image.gz-dtb
    COMPILED_DTBO=arch/arm64/boot/dtbo.img
    if [[ -f ${COMPILED_IMAGE} && ${COMPILED_DTBO} ]]; then

        git clone https://github.com/zahid5656/AnyKernel3.git -b nethunter $anykernel


        mv -f $ZIMAGE ${COMPILED_DTBO} $anykernel
        
        cp ${objdir}/drivers/media/dvb-frontends/*.ko $anykernel/modules/system/lib/modules
        cp ${objdir}/drivers/media/dvb-frontends/drx39xyj/*.ko $anykernel/modules/system/lib/modules
        cp ${objdir}/drivers/media/tuners/*.ko $anykernel/modules/system/lib/modules
        rm -rf $anykernel/modules/system/lib/modules/placeholder

        cd $anykernel
        find . -name "*.zip" -type f
        find . -name "*.zip" -type f -delete
        zip -r AnyKernel.zip *
        mv AnyKernel.zip $zip_name
        mv $anykernel/$zip_name $kernel_dir/$zip_name
        rm -rf $anykernel
        END=$(date +"%s")
        DIFF=$(($END - $START))
        echo -e ${LGR} "############################################"
        echo -e ${LGR} "########  Compiled Successfully!!  #########"
        echo -e ${LGR} "############################################${NC}"
        exit 0
    else
        echo -e ${RED} "############################################"
        echo -e ${RED} "##        ERROR!!! Unsccessfull :'(       ##"
        echo -e ${RED} "############################################${NC}"
        exit 1
    fi
}
make_defconfig
compile
completion
cd ${kernel_dir}

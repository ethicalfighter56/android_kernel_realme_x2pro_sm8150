#!/bin/bash

kernel_dir="${PWD}"
TC_DIR=$kernel_dir/toolchain
CLANG_DIR=$TC_DIR/clang-r536225

# Colors
NC='\033[0m'
RED='\033[0;31m'
LRD='\033[1;31m'
LGR='\033[1;32m'

# Clone ToolChain
function_cloneTC() 
{
    echo -e ${LGR} "××××××××××××××××××××××××××××××××××××××××××××"
    echo -e ${LGR} "...Checking if Clang is already cloned...???"
    echo -e ${LGR} "××××××××××××××××××××××××××××××××××××××××××××${NC}"
    if [ -d "$TC_DIR" ]; then
        echo -e ${LGR} "××××××××××××××××××××××××××××××××××××××××"
        echo -e ${LGR} "##### Already Cloned AOSP Clang!...#####"
        echo -e ${LGR} "××××××××××××××××××××××××××××××××××××××××${NC}"
        else
        export CLANG_VERSION="clang-r536225"
        echo -e ${RED} "××××××××××××××××××××××××××××××××××××××××"
        echo -e ${RED} "##########  It's not cloned...!#########"
        echo -e ${RED} "××××××××××××××××××××××××××××××××××××××××${NC}"
        echo -e ${LGR} "××××××××××××××××××××××××××××××××××××××××"
        echo -e ${LGR} "###########  Cloning it!... ############"
        echo -e ${LGR} "××××××××××××××××××××××××××××××××××××××××${NC}"
        mkdir -p toolchain/clang-r536225
        cd toolchain/clang-r536225 || exit
        wget -q https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/heads/master/${CLANG_VERSION}.tgz
            tar -xf ${CLANG_VERSION}.tgz
            rm -rf ${CLANG_VERSION}.tgz
            cd .. || exit
        git clone --depth=1 https://github.com/zahid5656/toolchain.git
        cd toolchain
        mv toolchain.zip ..
        cd ..
        unzip toolchain.zip
        rm -rf toolchain toolchain.zip
        echo -e ${LGR} "××××××××××××××××××××××××××××××××××××××××"
        echo -e ${LGR} "######  AOSP Toolchain Cloned... #######"
        echo -e ${LGR} "××××××××××××××××××××××××××××××××××××××××${NC}"
    fi
}
function_cloneTC
cd ${kernel_dir}

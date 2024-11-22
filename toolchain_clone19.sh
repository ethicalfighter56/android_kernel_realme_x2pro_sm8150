#!/bin/bash

KERNEL_DIR="${PWD}"
TC_DIR=$KERNEL_DIR/toolchain
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
        mkdir -p toolchain
        cd toolchain
        git clone --depth=1 https://git.codelinaro.org/clo/la/kernelplatform/prebuilts-master/clang/host/linux-x86.git -b aosp-new/main-kernel clang-r536225
            cd .. || exit
        echo -e ${LGR} "××××××××××××××××××××××××××××××××××××××××"
        echo -e ${LGR} "######  AOSP Toolchain Cloned... #######"
        echo -e ${LGR} "××××××××××××××××××××××××××××××××××××××××${NC}"
    fi
}
function_cloneTC

#!/bin/bash

fetch_repo() # directory, repo-url
{
	directory="${BUILD_DIR}/$1"
	url="$2"
	if [ "$1" != "" ] || [ "$2" != "" ]; then
		if [ ! -e ${directory} ]; then
			git clone ${url} ${directory}
			cd ${directory}
		else
			cd ${directory}
			git pull
		fi
		cd ${BASE_ROOT}
	else
		echo "fetch_repo(): Error: wrong arguments!"
		exit 1
	fi
}

check_tools()
{
	ZIP=`zip -v 2> /dev/null`
	CURL=`curl --version 2> /dev/null`

	if [ "$ZIP" == "" ]; then
		echo "Error: Missing zip tool!"
		exit 1
	fi

	if [ "$CURL" == "" ]; then
		echo "Error: Missing curl tool!"
		exit 1
	fi
}

prepare_xdc_tools()
{
	cd ${BUILD_DIR}
	if [ ! -e ${BUILD_DIR}/xdc ]; then
		case `uname -s` in
		Darwin)
			curl https://software-dl.ti.com/dsps/dsps_public_sw/sdo_sb/targetcontent/rtsc/${XDCCOREVERSION}/exports/xdccore/xdctools_${XDCCOREVERSION}_core_macos.zip?tracked=1 \
			--output xdctools_${XDCCOREVERSION}_core_macos.zip
			;;
		Linux)
			curl https://software-dl.ti.com/dsps/dsps_public_sw/sdo_sb/targetcontent/rtsc/${XDCCOREVERSION}/exports/xdccore/xdctools_${XDCCOREVERSION}_core_linux.zip?tracked=1 \
			--output xdctools_${XDCCOREVERSION}_core_linux.zip
		;;
		esac
		unzip xdctools_*_core_*.zip
		rm -f *.zip
		mv xdctools_*_core xdc
		rm -f xdc/gmake
	fi
	cd ${BASE_ROOT}
}

prepare_arm_compiler()
{
	cd ${BUILD_DIR}
	if [ ! -e ${BUILD_DIR}/armt ]; then
		case `uname -s` in
		Darwin)
			curl https://dr-download.ti.com/software-development/ide-configuration-compiler-or-debugger/MD-sDOoXkUcde/${TCGARMVERSION}/ti_cgt_tms470_${TCGARMVERSION}_osx_installer.app.zip \
				--output ti_cgt_tms470_${TCGARMVERSION}_osx_installer.zip
			unzip ti_cgt_tms470*.zip
			ti_cgt_tms470_*/Contents/MacOS/osx-x86_64 --mode unattended --prefix .
			mv ti-cgt-arm* armt
			rm -rf ti_cgt_tms470_*
			rm -f *.zip
			;;
		Linux)
			curl https://dr-download.ti.com/software-development/ide-configuration-compiler-or-debugger/MD-sDOoXkUcde/${TCGARMVERSION}/ti_cgt_tms470_${TCGARMVERSION}_linux-x64_installer.bin \
				--output ti_cgt_tms470_${TCGARMVERSION}_linux-x64_installer.bin
			chmod +x *.bin
			./ti_cgt_tms470_*_linux-x64_installer --mode unattended --prefix .
			mv ti-cgt-arm* armt
			rm -rf ti_cgt_tms470_*
			;;
		esac
	fi
	cd ${BASE_ROOT}
}

build_fw() {
	mkdir -f ${BUILD_DIR} 2> /dev/null

	fetch_repo bios https://github.com/mobiaqua/ti-sysbios.git
	fetch_repo ce https://github.com/mobiaqua/ti-ce.git
	fetch_repo fc https://github.com/mobiaqua/ti-fc.git
	fetch_repo osal https://github.com/mobiaqua/ti-osal.git
	fetch_repo xdais https://github.com/mobiaqua/ti-xdais.git
	fetch_repo codecs https://github.com/mobiaqua/ti-codecs.git
	fetch_repo ipc https://github.com/mobiaqua/ti-ipcdev.git
	fetch_repo ipumm https://github.com/mobiaqua/ti-ipumm.git

	prepare_xdc_tools
	prepare_arm_compiler

	make -C ${BASE_ROOT} TARGET=${TARGET} PLATFORM=${PLATFORM} HW_TYPE=${HW_TYPE} HW_VER=${HW_VER} OUTEXT=${OUTEXT} OUTNAME=${OUTNAME} \
	    PROFILE=${PROFILE} TRACELEVEL=${TRACELEVEL} BIOS_TYPE=${BIOS_TYPE} NJOBS=${JOBS} all
	mkdir -p bin
	cp sources/ipumm/*.xem* bin/
}

case `uname -s` in
Darwin)
	export XDCTOOLS_GMAKE=gmake
	;;
Linux)
	export XDCTOOLS_GMAKE=make
	;;
esac
TCGARMVERSION=20.2.7.LTS
TCGARMMAJORVERSION=`echo ${TCGARMVERSION} | cut -c 1-3`
XDCCOREVERSION=3_62_00_08
JOBS=16

check_tools

BASE_ROOT=`pwd`
BUILD_DIR=${BASE_ROOT}/sources


# Options for FW
BIOS_TYPE=SMP
PROFILE=release
TRACELEVEL=0


# OMAP4
TARGET=ti.targets.arm.elf.M3
PLATFORM=OMAP44XX
HW_TYPE=OMAP4
HW_VER=ES20
OUTEXT=xem3
OUTNAME=omap4-ipu-fw
build_fw

# OMAP5
TARGET=ti.targets.arm.elf.M4
PLATFORM=OMAP54XX
HW_TYPE=OMAP5
HW_VER=ES20
OUTEXT=xem4
OUTNAME=omap5-ipu-fw
build_fw

# AM572x
TARGET=ti.targets.arm.elf.M4
PLATFORM=DRA7XX
HW_TYPE=VAYU
HW_VER=ES10
OUTEXT=xem4
OUTNAME=dra7-ipu2-fw
build_fw

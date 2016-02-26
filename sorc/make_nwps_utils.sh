#!/bin/bash
# ----------------------------------------------------------- 
# UNIX Shell Script File
# Tested Operating System(s): RHEL 5,6
# Tested Run Level(s): 3, 5
# Shell Used: BASH shell
# Original Author(s): Douglas.Gaer@noaa.gov
# File Creation Date: 01/25/2011
# Date Last Modified: 11/14/2014
#
# Version control: 1.13
#
# Support Team:
#
# Contributors:
# ----------------------------------------------------------- 
# ------------- Program Description and Details ------------- 
# ----------------------------------------------------------- 
#
# Script used to build NWPS Utils
#
# ----------------------------------------------------------- 

# Setup our NWPS environment                                                    
export pwd=`pwd`
export NWPSdir=${pwd%/*}

if [ "${NWPSdir}" == "" ]
    then 
    echo "ERROR - Your NWPSdir variable is not set"
    exit 1
fi

#if [ ! -e ${NWPSdir}/utils/etc/nwps_config.sh ]
#    then
#    "ERROR - Cannot find ${NWPSdir}/utils/etc/nwps_config.sh"
#    exit 1
#fi
#    
## Setup our NWPS environment                                                    
#unset LD_LIBRARY_PATH
#source ${NWPSdir}/utils/etc/nwps_config.sh
#
## Setup our build environment
#source ${NWPSdir}/sorc/set_compiler.sh

export CC=icc
export CXX=icc
export CPP=icpc
export F90=ifort
export F77=ifort
export FC=ifort
PWD=$(pwd)
export ARCHBITS="64"

cd nwps_utils; ./build_utils.sh | tee -a ./nwps_utils_build.log 

cd ${PWD}

# ----------------------------------------------------------- 
# ******************************* 
# ********* End of File ********* 
# ******************************* 

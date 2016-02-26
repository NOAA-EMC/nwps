#!/bin/bash
set -xa
# ----------------------------------------------------------- 
# UNIX Shell Script File
# Tested Operating System(s): RHEL 5,6
# Tested Run Level(s): 3, 5
# Shell Used: BASH shell
# Original Author(s): Roberto.Padilla@noaa.gov
# File Creation Date: 06/25/2015
# Date Last Modified: 
#
# Version control: 1.14
#
# Support Team:
#
# Contributors:
# ----------------------------------------------------------- 
# ------------- Program Description and Details ------------- 
# ----------------------------------------------------------- 
#
# Script used to build WGRIB2
#
# ----------------------------------------------------------- 

echo "Building source code DIRs"

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

# Setup our build environment
#source ${NWPSdir}/sorc/set_compiler.sh

PWD=$(pwd)
#mkdir -p ${LOGdir}

#export CPPFLAGS=-I${NWPSdir}/lib${ARCHBITS}/hdf5/include 
#export LDFLAGS=-L${NWPSdir}/lib${ARCHBITS}/hdf5/lib
export ARCHBITS="64"
export COMPILER="INTEL"
#export CC=gcc
#export CPP=icpc
#export F90=mpfort
#export F77=mpfort
#export FC=mpfort
export CC=icc
export CPP=icpc
export F90=ifort
export F77=ifort
export FC=ifort

echo "Building wgrib2" | tee -a ./wgrib2_build.log
echo $(module list) | tee -a ./wgrib2_build.log
cd ${NWPSdir}/sorc/wgrib2
LOGdir=$(pwd)
# Modules load
module load ics

if [ "${COMPILER}" == "INTEL" ]
then
    make -f make_intel_linux_${ARCHBITS}.mak 
    make -f make_intel_linux_${ARCHBITS}.mak install 
    make -f make_intel_linux_${ARCHBITS}.mak clean 
else
    make -f make_linux_${ARCHBITS}.mak 
    make -f make_linux_${ARCHBITS}.mak install
    make -f make_linux_${ARCHBITS}.mak clean 
fi

cd ${PWD}
echo "Done building WGRIB2"

# ----------------------------------------------------------- 
# ******************************* 
# ********* End of File ********* 
# ******************************* 

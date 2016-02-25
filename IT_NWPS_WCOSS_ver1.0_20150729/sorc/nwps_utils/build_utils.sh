#!/bin/bash
# ----------------------------------------------------------- 
# UNIX Shell Script File
# Tested Operating System(s): RHEL 5,6
# Tested Run Level(s): 3, 5
# Shell Used: BASH shell
# Original Author(s): Douglas.Gaer@noaa.gov
# File Creation Date: 06/25/2011
# Date Last Modified: 11/15/2014
#
# Version control: 1.06
#
# Support Team:
#
# Contributors:
# ----------------------------------------------------------- 
# ------------- Program Description and Details ------------- 
# ----------------------------------------------------------- 
#
# Script used to build NWPS utils
#
# ----------------------------------------------------------- 

echo "Building NWPS utils"

# Setup our NWPS environment                                                    
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

WORKDIR=$(pwd)

cd makelibs
if [ "${ARCHBITS}" == "64" ];
then
    make 64BITCFG=1 FINAL=1
else
    make 64BITCFG=0 FINAL=1
fi
make install
make clean
cd ${WORKDIR}

cd read_template
if [ "${ARCHBITS}" == "64" ]; 
then 
    make 64BITCFG=1 FINAL=1
else 
    make 64BITCFG=0 FINAL=1
fi 
make install 
make clean 
cd ${WORKDIR}

cd swan_out_to_bin
if [ "${ARCHBITS}" == "64" ]; 
then 
    make 64BITCFG=1 FINAL=1
else 
    make 64BITCFG=0 FINAL=1
fi 
make install 
make clean
cd ${WORKDIR}

cd readdat_util
if [ "${ARCHBITS}" == "64" ]; 
then 
    make 64BITCFG=1 FINAL=1
else 
    make 64BITCFG=0 FINAL=1
fi 
make install
make clean
cd ${WORKDIR}

cd writedat_util
if [ "${ARCHBITS}" == "64" ]; 
then 
    make 64BITCFG=1 FINAL=1
else 
    make 64BITCFG=0 FINAL=1
fi 
make install
make clean
cd ${WORKDIR}

cd write_template
if [ "${ARCHBITS}" == "64" ]; 
then 
    make 64BITCFG=1 FINAL=1
else 
    make 64BITCFG=0 FINAL=1
fi 
make install
make clean
cd ${WORKDIR}

cd fix_ascii_point_data
if [ "${ARCHBITS}" == "64" ]; 
then 
    make 64BITCFG=1 FINAL=1
else 
    make 64BITCFG=0 FINAL=1
fi 
make install
make clean
cd ${WORKDIR}

cd read_awips_windfile
if [ "${ARCHBITS}" == "64" ]; 
then 
    make 64BITCFG=1 FINAL=1
else 
    make 64BITCFG=0 FINAL=1
fi 
make install
make clean
cd ${WORKDIR}

echo "NWPS utils build complete"

# ----------------------------------------------------------- 
# ******************************* 
# ********* End of File ********* 
# ******************************* 

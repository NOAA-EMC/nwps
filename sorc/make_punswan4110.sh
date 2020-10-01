#!/bin/bash
# ----------------------------------------------------------- 
# UNIX Shell Script File
# Tested Operating System(s): RHEL 5,6
# Tested Run Level(s): 3, 5
# Shell Used: BASH shell
# Original Author(s): Andre.VanDerWesthuysen@noaa.gov
# File Creation Date: 02/01/2017
# Date Last Modified: 03/03/2017
#
# Version control: 1.0
#
# Support Team:
#
# Contributors:
# ----------------------------------------------------------- 
# ------------- Program Description and Details ------------- 
# ----------------------------------------------------------- 
#
# Script used to build binaries required to SWAN and WW3 models.
#
# ----------------------------------------------------------- 

echo "Building SWAN"
# Setup our NWPS environment                                                    
export pwd=`pwd`
export NWPSdir=${pwd%/*}
if [ "${NWPSdir}" == "" ]
    then 
    echo "ERROR - Your NWPSdir variable is not set"
    exit 1
fi

PWD=$(pwd)
mkdir -p ${NWPSdir}/exec

#module purge
#module load ncep
#module load ../modulefiles/NWPS/v1.3.0
module list

cd ${NWPSdir}/sorc/punswan4110.fd

echo "Building OpenMPI SWAN binary" | tee ./punswan_build.log
make clobber | tee -a ./punswan_build.log
make config | tee -a ./punswan_build.log

#Build parallel unstructured version
make punswan FLAGS_OPT="${OPTFLAGS}" | tee -a ./punswan_build.log
cp -pfv swan.exe ${NWPSdir}/exec/punswan4110.exe

make clobber | tee -a ./punswan_build.log
cd ${PWD}
echo "Done building SWAN"

# ----------------------------------------------------------- 
# ******************************* 
# ********* End of File ********* 
# ******************************* 

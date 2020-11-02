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
# Version control: 1.14
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

cd ${NWPSdir}/sorc/swan.fd

echo "Building OpenMPI SWAN binary" | tee ./swan_build.log
make clobber | tee -a ./swan_build.log
make config | tee -a ./swan_build.log
make mpi FLAGS_OPT="${OPTFLAGS}" | tee -a ./swan_build.log
cp -pfv swan.exe ${NWPSdir}/exec/swan.exe

make clobber | tee -a ./swan_build.log
cd ${PWD}
echo "Done building SWAN"

# ----------------------------------------------------------- 
# ******************************* 
# ********* End of File ********* 
# ******************************* 

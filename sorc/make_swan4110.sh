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
#module load ../modulefiles/NWPS/v1.2.0
#module list

# Loading Intel Compiler Suite
module load PrgEnv-intel/5.2.56
module load craype-haswell

# Loading ncep prod modules
module load HDF5-serial-intel-haswell/1.8.9
module load NetCDF-intel-haswell/4.2
module load jasper-gnu-haswell/1.900.1
module load png-intel-haswell/1.2.49
module load zlib-intel-haswell/1.2.7
module load nco-gnu-haswell/4.4.4 

# Loading ncep libs 
module load bacio-intel/2.0.1
module load bufr-intel/11.0.2
module load g2-intel/2.5.0
module load w3emc-intel/2.2.0
module load w3nco-intel/2.0.6
module load iobuf/2.0.5

echo "Building OpenMPI SWAN binary" | tee ./swan_build.log
cd ${NWPSdir}/sorc/swan4110
make clobber | tee -a ./swan_build.log
make config | tee -a ./swan_build.log

#Build parallel unstructured version
make punswan FLAGS_OPT="${OPTFLAGS}" | tee -a ./swan_build.log
cp -pfv swan.exe ${NWPSdir}/exec/punswan4110-mpi.exe

make clobber | tee -a ./swan_build.log
cd ${PWD}
echo "Done building SWAN"

# ----------------------------------------------------------- 
# ******************************* 
# ********* End of File ********* 
# ******************************* 

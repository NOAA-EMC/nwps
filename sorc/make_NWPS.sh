#!/bin/bash
# ----------------------------------------------------------- 
# UNIX Shell Script File
# Original Author(s): Roberto.Padilla@noaa.gov
# File Creation Date: 03/25/2015
# Date Last Modified: 
#
# Version control: 1.14
#
# Support Team:
#
# Contributors: Andre.VanderWesthuysen@noaa.gov
# ------------- Program Description and Details ------------- 
# ----------------------------------------------------------- 
#  This script produce all executables (as described bellow)
#  for NWPS
#
# ----------------------------------------------------------- 
export pwd=`pwd`
export NWPSdir=${pwd%/*}

if [ "${NWPSdir}" == "" ]
    then 
    echo "ERROR - Your NWPSdir variable is not set"
    exit 1
fi

#Fetching external fix and binary files from rzdm
cd ${NWPSdir}/sorc
./get_externals.sh

mkdir -p ${NWPSdir}/exec

#FOR DEGRIB
#Using the GNU compiler or the Jasper/JPEG compression library will not work properly
echo "================== FOR DEGRIB : make_degrib.sh =================="
cd ${NWPSdir}/sorc
./make_degrib.sh

module purge
module load ncep
module load ../modulefiles/NWPS/v1.3.0
module list

#FOR SWAN (REGULAR GRID)
echo "================== FOR SWAN (REGULAR GRID) : make_swan.sh  =================="
cd ${NWPSdir}/sorc
./make_swan.sh

#FOR WAVE TRACKING
#The executable is ww3_systrk_mpi
echo "================== FOR WAVE TRACKING : make_ww3_systrk.sh =================="
cd ${NWPSdir}/sorc
./make_ww3_systrk.sh

#FOR WAVE TRACKING PREPROCESSOR
#The executable is ww3_sysprep.exe
echo "================== FOR WAVE TRACKING PREPROCESSOR : make_sysprep.sh =================="
cd ${NWPSdir}/sorc
./make_sysprep.sh

#FOR SWAN (UNSTRUCTURED MESH, incl. parallel libraries in estofs_padcirc.fd/work/odir4/)
echo "================== FOR SWAN (UNSTRUCTURED MESH,..) : make_padcirc.sh make_swan4110.sh =================="
cd ${NWPSdir}/sorc
./make_padcirc.sh
./make_swan4110.sh

#FOR RIP CURRENTS
#The executable is ripforecast.x
echo "================== FOR RIP CURRENTS : make_ripforecast.sh =================="
./make_ripforecast.sh

#FOR RUNUP
#The executable is runupforecast.exe
echo "================== FOR RUNUP : make_runupforecast.sh =================="
./make_runupforecast.sh

#FOR PSURGE2NWPS
#The following will generate the executables: psurge2nwps_64, psurge_identify.exe and  psoutTOnwps.exe.
echo "================== FOR PSURGE2NWPS : make_Psurge2NWPS.sh =================="
./make_Psurge2NWPS.sh

#FOR UTILITY PROGRAMS
echo "================== FOR UTILITY PROGRAMS : make_nwps_utils.sh =================="
./make_nwps_utils.sh

echo "NWPS Build complete"
exit 0


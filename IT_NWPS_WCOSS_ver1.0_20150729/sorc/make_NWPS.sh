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
# Contributors:
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

module load ics
#FOR SWAN
cd ${NWPSdir}/sorc
./make_swan.sh

#FOR WAVE TRACKING
#The executable is ww3_systrk_mpi
./make_ww3_systrk.sh

#FOR RIP CURRENTS
#The executable is ripforecast.x
./make_rip_current_program.sh

#FOR RUNUP
#The executable is runupforecast.exe
./make_runup_program.sh

#FOR UTILITY PROGRAMS
./make_nwps_utils.sh

#FOR WGRIB2
./make_wgrib2.sh

#PYTHON MODULES (Basemap and Matplotlib)
./make_python_modules.sh

#BASEMAP FOR PYTHON
./make_basemap.sh

#FOR DEGRIB
./make_degrib.sh

#FOR PSURGE2NWPS
#The following will generate the executables: psurge2nwps_64, psurge_identify.exe and  psoutTOnwps.exe.
./make_Psurge2NWPS.sh

echo "Build complete"
exit 0


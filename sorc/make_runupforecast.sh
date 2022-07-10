#!/bin/bash
# ----------------------------------------------------------- 
# UNIX Shell Script File
# Original Author(s): Roberto.Padilla@noaa.gov
# File Creation Date: 01/25/2011
# Date Last Modified: 11/14/2014
#
# Version control: 1.14
#
# Support Team:
#
# Contributors:

if [ "${NWPSdir}" == "" ]
    then 
    echo "ERROR - Your NWPSdir variable is not set"
    exit 1
fi

#module purge
#module load ncep
#module load ../modulefiles/NWPS/v1.3.0
#module list

# Original Stockdon et al. formulation for SR and ER
cd ${NWPSdir}/sorc/runupforecast.fd/
make runupforecast | tee ./runup_build.log
rm *.o
mv -v runupforecast.exe ${NWPSdir}/exec/runupforecast.exe

# Multi-formula version for WR
cd ${NWPSdir}/sorc/runupforecast.fd/wr/
make runupforecast_wr | tee ./runup_build.log
rm *.o
mv -v runupforecast_wr.exe ${NWPSdir}/exec/runupforecast_wr.exe

echo "Build complete"
exit 0




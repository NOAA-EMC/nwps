#!/bin/bash
# ----------------------------------------------------------- 
# UNIX Shell Script File
# Original Author(s): Andre.VanderWesthuysen@noaa.gov
# File Creation Date: 10/06/2015
# Date Last Modified: 10/06/2015
#
# Version control: 1.14
#
# Support Team:
#
# Contributors:

#module purge
#module load ncep
#module load ../modulefiles/NWPS/v1.2.0
#module list

if [ "${NWPSdir}" == "" ]
    then 
    echo "ERROR - Your NWPSdir variable is not set"
    exit 1
fi

cd ${NWPSdir}/sorc/python_modules/
./build_python_modules.sh

echo "Build complete"
exit 0


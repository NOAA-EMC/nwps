#!/bin/bash
# ----------------------------------------------------------- 
# UNIX Shell Script File
# Tested Operating System(s): RHEL 5,6
# Tested Run Level(s): 3, 5
# Shell Used: BASH shell
# Original Author(s): Douglas.Gaer@noaa.gov
# File Creation Date: 06/25/2011
# Date Last Modified: 06/03/2016
#
# Version control: 4.01
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

#loading the necessary modules 
module purge
module load ncep
module load ../modulefiles/NWPS/v1.3.0
module list

cd nwps_utils.cd; ./build_utils.sh | tee -a ./nwps_utils_build.log 

cd ${PWD}

# ----------------------------------------------------------- 
# ******************************* 
# ********* End of File ********* 
# ******************************* 

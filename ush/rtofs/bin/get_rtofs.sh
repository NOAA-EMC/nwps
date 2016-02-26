#!/bin/bash
# -----------------------------------------------------------
# UNIX Shell Script
# Tested Operating System(s): RHEL 5
# Tested Run Level(s): 3, 5
# Shell Used: BASH shell
# Original Author(s): Douglas.Gaer@noaa.gov
# File Creation Date: 09/29/2009
# Date Last Modified: 07/29/2014
#
# Version control: 1.44
#
# Support Team:
#
# Contributors: Roberto.Padilla@noaa.gov (NCEP/MMAB/IMSG)
#               
# -----------------------------------------------------------
# ------------- Program Description and Details -------------
# -----------------------------------------------------------
#
# Script used to download RTOFS grid. 
#
#
# -----------------------------------------------------------

# Check to see if our SITEID is set
if [ "${SITEID}" == "" ]
    then
    echo "ERROR - Your SITEID variable is not set"
    export err=1; err_chk
fi

if [ "${USHnwps}" == "" ]
    then 
    echo "ERROR - Your USHnwps variable is not set"
    export err=1; err_chk
fi

if [ -e ${USHnwps}/nwps_config.sh ]
then
    source ${USHnwps}/nwps_config.sh
else
    echo "ERROR - Cannot find ${USHnwps}/nwps_config.sh"
    export err=1; err_chk
fi

# Script variables
# ===========================================================
BINdir="${USHnwps}/rtofs/bin"
myPWD=$(pwd)

# Setup our Regional domain here based on our NWPS site's region
REGION=$(echo "${REGIONID}" | tr [:lower:] [:upper:])
region=$(echo "${regionid}" | tr [:upper:] [:lower:])

# Read our NWPS config
if [ -e ${USHnwps}/${region}_nwps_config.sh ]
then
    source ${USHnwps}/${region}_nwps_config.sh 
    HAS_REGIONAL_CONFIG="TRUE"
else
    echo "WARNING - ${USHnwps}/${region}_nwps_config.sh file does not exist"
    echo "WARNING - will use ${USHnwps}/nwps_config.sh default setting for RTOFS data"
    HAS_REGIONAL_CONFIG="FALSE"
fi

if [ "${RTOFSSOURCE}" == "global" ]
then
    echo "Our RTOFS source is set to ${RTOFSSOURCE}"
    ${BINdir}/get_rtofs_global.sh $1 $2 $3 $4 $5 $6 $7 $8 $9
else
    echo "ERROR - Invalid RTOFSSOURCE: ${RTOFSSOURCE}"
    echo "ERROR - Not processing any ocean current data"
    cd ${myPWD}
    export err=1; err_chk
fi
 
cd ${myPWD}
exit 0
# -----------------------------------------------------------
# *******************************
# ********* End of File *********
# *******************************

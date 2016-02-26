#!/bin/bash
set -xa
# ----------------------------------------------------------- 
# UNIX Shell Script File
# Tested Operating System(s): RHEL 5,6
# Tested Run Level(s): 3, 5
# Shell Used: BASH shell
# Original Author(s): Douglas.Gaer@noaa.gov
# File Creation Date: 08/22/2011
# Date Last Modified: 07/29/2014
#
# Version control: 1.04
#
# Support Team:
#
# Contributors:
# ----------------------------------------------------------- 
# ------------- Program Description and Details ------------- 
# ----------------------------------------------------------- 
#
# Script used to signal NAM winds from AWIPS/GFE or used to 
# download NAM wind forcing from NCEP.
#
# ----------------------------------------------------------- 

# Check to see if our SITEID is set
if [ "${SITEID}" == "" ]
    then
    echo "ERROR - Your SITEID variable is not set"
    export err=1; err_chk
fi

# Setup our NWPS environment                                                    
if [ "${USHnwps}" == "" ]
    then 
    echo "ERROR - Your USHnwps variable is not set"
    export err=1; err_chk
fi

# Check to see if our NWPS env is set
if [ "${NWPSenvset}" == "" ]
then 
    if [ -e ${USHnwps}/nwps_config.sh ]
    then
	source ${USHnwps}/nwps_config.sh
    else
	"ERROR - Cannot find ${USHnwps}/nwps_config.sh"
	export err=1; err_chk
    fi
fi

if [ -e ${INPUTdir}/SWANflag ]
then
    echo ""
    echo "INFO - We received a flag from AWIPS that we are using NAM winds from GFE"
    echo "INFO - Continuing the run using forecaster grid made from NAM winds..."
    echo ""
    exit 0
fi

echo ""
echo "INFO - The NCEP download feature has not been implemented in this release"
echo "EXITING run..."
echo ""
export err=1; err_chk

# ----------------------------------------------------------- 
# ******************************* 
# ********* End of File ********* 
# ******************************* 

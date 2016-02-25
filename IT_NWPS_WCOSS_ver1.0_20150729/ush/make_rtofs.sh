#!/bin/bash
set -xa
# -----------------------------------------------------------
# UNIX Shell Script
# Tested Operating System(s): RHEL 5
# Tested Run Level(s): 3, 5
# Shell Used: BASH shell
# Original Author(s): Douglas.Gaer@noaa.gov
# File Creation Date: 09/29/2009
# Date Last Modified: 07/14/2015
#
# Version control: 3.20
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
set -xa

if [ "${HOMEnwps}" == "" ]
    then 
    echo "ERROR - Your HOMEnwps variable is not set"
    export err=1; err_chk
fi

if [ -e ${USHnwps}/rtofs/bin/nwps_config.sh ]
then
    source ${USHnwps}/rtofs/bin/nwps_config.sh
else
    echo "ERROR - Cannot find ${HOMEnwps}/etc/nwps_config.sh"
    export err=1; err_chk
fi

# Script variables
# ===========================================================
BINdir="${USHnwps}/rtofs/bin"
myPWD=$(pwd)

export RTOFSSOURCE="sector"
echo "Our RTOFS source is set to ${RTOFSSOURCE}"
#                               CYCLE Totalhrs Tstep YYYYMMDD DOWNLOADRETRIES  (NOT DEFINED)
#${BINdir}/make_rtofs_sector.sh $1    $2       $3    $4       $5               $6 $7 $8 $9
#                            
#${BINdir}/make_rtofs_sector.sh $1 $2 $3 $4 $5 $6 $7 $8 $9
#
${BINdir}/make_rtofs_sector.sh 00 144 3 20150812 $5 $6 $7 $8 $9


cd ${myPWD}
exit 0
# -----------------------------------------------------------
# *******************************
# ********* End of File *********
# *******************************

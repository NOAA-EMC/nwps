#!/bin/bash
#
# ----------------------------------------------------------- 
# Original Author(s): Douglas.Gaer@noaa.gov
# File Creation Date: 05/14/2016
# Date Last Modified: 05/14/2016
#
# Version control: 1.17
#
# Support Team:
#
# Contributors:
# ----------------------------------------------------------- 
# ------------- Program Description and Details ------------- 
# ----------------------------------------------------------- 
export pwd=`pwd`
export NWPSdir=${pwd%/*}
if [ "${NWPSdir}" == "" ]
   then 
   if [ -e /gpfs/gd1 ]
   then
      echo "INFO - WCOSS is on GYRE system"
      export  WCOSS_SYSTEM="gd1"
   fi
   if [ -e /gpfs/td1 ]
   then
      echo "INFO - WCOSS is on TIDE system"
      export WCOSS_SYSTEM="td1"
   fi
   export DEVWCOSS_USER=$(whoami)
   export NWPSdir="/gpfs/${WCOSS_SYSTEM}/emc/marine/save/${DEVWCOSS_USER}/NWPS/emc_nwps"
fi

mkdir -p ${NWPSdir}/exec

# We can only use the GNU compiler or the Jasper/JPEG compression library will not work properly
cd ${NWPSdir}/sorc/degrib.cd/
./build_degrib.sh


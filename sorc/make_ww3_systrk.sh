#!/bin/bash
#
# ----------------------------------------------------------- 
# Original Author(s): Douglas.Gaer@noaa.gov, Roberto.Padilla@noaa.gov
# File Creation Date: 04/06/2015
# Date Last Modified: 06/24/2015
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

#loading the necessary modules 
#module purge
#module load ncep
#module load ../modulefiles/NWPS/v1.2.0
#module list

# The gnu fortran compiler  buffers the writes on default, the intel fortran compiler 
# does not.So if you are writing a small amount of data it won't buffer it and actually
# writes the data to disk when you say write.   When you set the environment variable
# "export FORT_BUFFERED=true" it will buffer the data like the gnu fortran compiler does.
export FORT_BUFFERED=true

${NWPSdir}/sorc/ww3_systrack/make_ww3_systrk_mpi.sh



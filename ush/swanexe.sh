#!/bin/bash
set -xa
# ----------------------------------------------------------- 
# UNIX Shell Script File
# Tested Operating System(s): RHEL 5,6
# Tested Run Level(s): 3, 5
# Shell Used: BASH shell
# Original Author(s): Douglas.Gaer@noaa.gov
# File Creation Date: 01/25/2011
# Date Last Modified: 07/09/2013
#
# Version control: 1.12
#
# Support Team:
#
# Contributors:
# ----------------------------------------------------------- 
# ------------- Program Description and Details ------------- 
# ----------------------------------------------------------- 
#
# Script used to auto detect the hardware platform and select 
# the correct SWAN binary. 
#
# ----------------------------------------------------------- 
echo "in swanexe.sh"
set -x
env

# Setup our NWPS environment                                                    
if [ "${USHnwps}" == "" ]
    then 
    echo "FATAL ERROR: Your USHnwps variable is not set"
    export err=1; err_chk
fi

# Check to see if our NWPS env is set
if [ "${NWPSenvset}" == "" ]
then 
    if [ -e ${USHnwps}/nwps_config.sh ];then
	    source ${USHnwps}/nwps_config.sh
    else
	    "FATAL ERROR: Cannot find ${USHnwps}/nwps_config.sh"
	    export err=1; err_chk
    fi
fi

cd ${RUNdir}

if [ "${ARCH}" == "" ] || [ "${ARCHBITS}" == "" ] || [ "${NUMCPUS}" == "" ] || [ "${MPIEXEC}" == "" ]
then
    source ${USHnwps}/set_os_env.sh
fi

echo "Starting mpirun.lsf"
${MPIRUN} ${EXECnwps}/swan-mpi.exe
export err=$?;
#echo "Exit Code: ${SAVEPAR}" | tee -a ${LOGdir}/swan_exe_error.log
echo "Exit Code: ${err}" | tee -a ${LOGdir}/swan_exe_error.log
cp -f *CG1* ${DATA}/output/grid
if [ "${err}" != "0" ];then
   msg="FATAL ERROR: Wave model executable swan-mpi.exe failed."
   postmsg "$jlogfile" "$msg"
fi
err_chk

exit 0
# -----------------------------------------------------------
# *******************************
# ********* End of File *********
# *******************************

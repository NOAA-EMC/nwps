#!/bin/bash
# -----------------------------------------------------------
# UNIX Shell Script
# Tested Operating System(s): RHEL 5, 6
# Tested Run Level(s): 3, 5
# Shell Used: BASH shell
# Original Author(s): Roberto.Padilla@noaa.gov
# File Creation Date: 05/05/2015
# Date Last Modified: 0
#
# Version control: 1.0
#
# Support Team:
#
# Contributors: 
#               
# -----------------------------------------------------------
# ------------- Program Description and Details -------------
# -----------------------------------------------------------
#
# PSURGE workstation master configuration.
#
# BASH include script use to setup the run-time environment
# for the model run. 
#
# ----------------------------------------------------------- 

# Variable used to setup the root directory for NWPS package
# Default is ${HOME}/nwps
if [ "${USHnwps}" == "" ]
    then
    echo "ERROR - Your USHnwps variable is not set"
    export err=1; err_chk
fi

export DATAdir="${DATA}"

if [ "${SITETYPE}" == "" ]; then export SITETYPE="DEV"; fi

# Set user name that started the NWPS processes
if [ "${USERNAME}" == "" ]; then export USERNAME=$(whoami); fi

export PSURGEHOURS=${PSURGEHOURS:-102}
export PSURGETIMESTEP=${PSURGETIMESTEP:-1}

# Set our default processing DIRs here
if [ "${ARCHdir}" == "" ]; then export ARCHdir=${DATAdir}/archive; fi
if [ "${DATAdir}" == "" ]; then export DATAdir=${DATAdir}/data; fi
if [ "${INPUTdir}" == "" ]; then export INPUTdir=${DATAdir}/input/psurge; fi
if [ "${LOGdir}" == "" ]; then export LOGdir=${DATAdir}/logs; fi
if [ "${VARdir}" == "" ]; then export VARdir=${DATAdir}/var; fi
if [ "${OUTPUTdir}" == "" ]; then export OUTPUTdir=${DATAdir}/output; fi
if [ "${RUNdir}" == "" ]; then export RUNdir=${DATAdir}/run; fi
if [ "${TMPdir}" == "" ]; then export TMPdir=${DATAdir}/tmp; fi

if [ ! -e ${ARCHdir} ]; then mkdir -vp ${ARCHdir}; fi
if [ ! -e ${DATAdir} ]; then mkdir -vp ${DATAdir}; fi
if [ ! -e ${INPUTdir} ]; then mkdir -vp ${INPUTdir}; fi
if [ ! -e ${LOGdir} ]; then mkdir -vp ${LOGdir}; fi
if [ ! -e ${VARdir} ]; then mkdir -vp ${VARdir}; fi
if [ ! -e ${OUTPUTdir} ]; then mkdir -vp ${OUTPUTdir}; fi
if [ ! -e ${RUNdir} ]; then mkdir -vp ${RUNdir}; fi
if [ ! -e ${TMPdir} ]; then mkdir -vp ${TMPdir}; fi

# ----------------------------------------------------------- 
# ******************************* 
# ********* End of File ********* 
# ******************************* 

#!/bin/bash
# ----------------------------------------------------------- 
# UNIX Shell Script File
# Tested Operating System(s): RHEL 5,6
# Tested Run Level(s): 3, 5
# Shell Used: BASH shell
# Original Author(s): Douglas.Gaer@noaa.gov
# File Creation Date: 02/05/2011
# Date Last Modified: 03/05/2013
#
# Version control: 1.23
#
# Support Team:
#
# Contributors:
# ----------------------------------------------------------- 
# ------------- Program Description and Details ------------- 
# ----------------------------------------------------------- 
#
# NWPS workstation master configuration.
#
# BASH include script use to setup the run-time environment
# for the model run. 
#
# ----------------------------------------------------------- 

# Variable used to setup the root directory for NWPS package
# Default is ${HOME}/nwps
if [ "${NWPSdir}" == "" ]; then export NWPSdir="${HOMEnwps}"; fi

# Variable to signal our NWPS env is set
if [ "${NWPSenvset}" == "" ]; then export NWPSenvset="TRUE"; fi

# Turn debuggin on or off, TRUE/FALSE
# Default is TRUE
if [ "${DEBUGGING}" == "" ]; then export DEBUGGING="TRUE"; fi
# Setup our debug level
# Default is level 1
if [ "${DEBUG_LEVEL}" == "" ]; then export DEBUG_LEVEL="1"; fi

# Is this a development model or production model, TRUE/FALSE
# Default is FALSE
if [ "${ISPRODUCTION}" == "" ]; then export ISPRODUCTION="FALSE"; fi

# Set our site type to one of the follow:
# DEV - Development workstation, default
# WFO - Weather Forecast Office
# RCF - River Forecast Office
# RHQ - Regional headquarters
# EMC - Environmental Modeling Center
# EDU - University or other education center
if [ "${SITETYPE}" == "" ]; then export SITETYPE="DEV"; fi

# Set our default model to run
# SWAN - Run SWAN model if no model type specified
# WW3 - Run Wave watch III if no model type specified 
# ENSEMBLE - Run both models 
if [ "${MODELTYPE}" == "" ]; then export MODELTYPE="SWAN"; fi

# Set HOTSTART variable
if [ "${HOTSTART}" == "" ]; then export HOTSTART="TRUE"; fi

# Set extra output types to generate following model run
# The primary output is GRIB2 but we can alos generate the 
# the following type if needed.
if [ "${GEN_NETCDF}" == "" ]; then export GEN_NETCDF="TRUE"; fi

if [ "${GEN_HDF5}" == "" ]; then export GEN_HDF5="TRUE"; fi 

# Validate our output settings
if [ "${GEN_HDF5}" == "TRUE" ] && [ "${GEN_NETCDF}" == "FALSE" ]; then export GEN_NETCDF="TRUE"; fi


# Set our default processing DIRs here
if [ "${ARCHdir}" == "" ]; then export ARCHdir=${Datadir}/archive; fi
if [ "${DATAdir}" == "" ]; then export DATAdir=${Datadir}/data; fi
if [ "${INPUTdir}" == "" ]; then export INPUTdir=${Datadir}/input; fi
if [ "${LOGdir}" == "" ]; then export LOGdir=${Datadir}/logs; fi
if [ "${VARdir}" == "" ]; then export VARdir=${Datadir}/var; fi
if [ "${OUTPUTdir}" == "" ]; then export OUTPUTdir=${Datadir}/output; fi
if [ "${RUNdir}" == "" ]; then export RUNdir=${Datadir}/run; fi
if [ "${TMPdir}" == "" ]; then export TMPdir=${Datadir}/tmp; fi
if [ "${LDMdir}" == "" ]; then export LDMdir=${DATAdir}/lmd; fi


echo "Setting up our NWPS environment"

# Include files required to complete model setup 
if [ ! -e ${NWPSdir}/fix/configs/siteid.sh ]
    then
    echo "ERROR - Missing ${NWPSdir}/fix/configs/siteid.sh"
    echo "ERROR - You must setup a domain for this site"
    exit 1
fi
source ${NWPSdir}/fix/configs/siteid.sh

echo ""
echo "BATHYdb = ${BATHYdb}"
echo "SHAPEFILEdb = ${SHAPEFILEdb}"
echo "ARCHdir = ${ARCHdir}"
echo "DATAdir = ${DATAdir}"
echo "INPUTdir = ${INPUTdir}"
echo "LDMdir = ${LDMdir}"
echo "LOGdir = ${LOGdir}"
echo "VARdir = ${VARdir}"
echo "OUTPUTdir = ${OUTPUTdir}"
echo "RUNdir = ${RUNdir}"
echo "TMPdir = ${TMPdir}"

if [ ! -e ${BATHYdb} ]; then mkdir -vp ${BATHYdb}; fi
if [ ! -e ${SHAPEFILEdb} ]; then mkdir -vp ${SHAPEFILEdb}; fi
if [ ! -e ${ARCHdir} ]; then mkdir -vp ${ARCHdir}; fi
if [ ! -e ${DATAdir} ]; then mkdir -vp ${DATAdir}; fi
if [ ! -e ${INPUTdir} ]; then mkdir -vp ${INPUTdir}; fi
if [ ! -e ${LOGdir} ]; then mkdir -vp ${LOGdir}; fi
if [ ! -e ${VARdir} ]; then mkdir -vp ${VARdir}; fi
if [ ! -e ${OUTPUTdir} ]; then mkdir -vp ${OUTPUTdir}; fi
if [ ! -e ${RUNdir} ]; then mkdir -vp ${RUNdir}; fi
if [ ! -e ${TMPdir} ]; then mkdir -vp ${TMPdir}; fi
if [ ! -e ${LDMdir} ]; then mkdir -vp ${LDMdir}; fi

# ----------------------------------------------------------- 
# ******************************* 
# ********* End of File ********* 
# ******************************* 

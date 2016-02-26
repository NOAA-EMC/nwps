#!/bin/bash
set -xa
# ----------------------------------------------------------- 
# UNIX Shell Script File
# Tested Operating System(s): RHEL 5,6
# Tested Run Level(s): 3, 5
# Shell Used: BASH shell
# Original Author(s): Douglas.Gaer@noaa.gov
# File Creation Date: 02/05/2011
# Date Last Modified: 11/18/2014
#
# Version control: 1.35
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

if [ "${SITEID}" == "" ] 
then
    echo "ERROR - You SITEID is not set"
    echo "ERROR - You must set a SITEID, example: export SITEID=TXX"
    export err=1; err_chk
fi

export siteid=$(echo "${SITEID}" | tr [:upper:] [:lower:])
export SITEID=$(echo "${siteid}" | tr [:lower:] [:upper:])

echo "Our NWPS site is $SITEID $siteid"

# Variable used to setup the root directory for NWPS package
# Default is ${HOME}/nwps
if [ "${NWPSdir}" == "" ]; then export NWPSdir="${HOMEnwps}"; fi
if [ "${NWPSDATA}" == "" ]; then export NWPSDATA="${DATA}"; fi

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
if [ "${ISPRODUCTION}" == "" ]; then export ISPRODUCTION="TRUE"; fi

# Set our site type to one of the follow:
# DEV - Development workstation, default
# WFO - Weather Forecast Office
# RCF - River Forecast Office
# RHQ - Regional headquarters
# EMC - Environmental Modeling Center
# EDU - University or other education center
if [ "${SITETYPE}" == "" ]; then export SITETYPE="EMC"; fi

# Set our default model to run
# SWAN - Run SWAN model if no model type specified
# WW3 - Run Wave watch III if no model type specified 
# ENSEMBLE - Run both models 
if [ "${MODELTYPE}" == "" ]; then export MODELTYPE="SWAN"; fi

# Set our default multi processor mode 
# SER = Single processor only
# MPI = OpenMPI for distributed processing, multi-node cluster
# OMP = OpenMP for share processing
# PAR = Auto parallelization binaries
if [ "${MPMODE}" == "" ]; then export MPMODE="MPI"; fi

# Set our default compiler for source code builds
# GCC = Use gfortan binaries
# INTEL = Use Intel binaries
# PGI = Use portland group binaries
if [ "${COMPILER}" == "" ]; then export COMPILER="INTEL"; fi

# Default compiler optimzation for GCC and Intel builds 
if [ "${OPTFLAGS}" == "" ]; then export OPTFLAGS="-O2"; fi 

# Intel compiler setup
#if [ "${INTEL_INSTALL_DIR}" == "" ]; then export INTEL_INSTALL_DIR="/opt/intel"; fi
#if [ "${INTEL_INSTALL_DIR}" == "" ]; then export INTELVARS="${INTEL_INSTALL_DIR}/bin/compilervars.sh"; fi

# Set HOTSTART variable
if [ "${HOTSTART}" == "" ]; then export HOTSTART="TRUE"; fi

# Set extra output types to generate following model run
# The primary output is GRIB2 but we can alos generate the 
# the following type if needed.
# 11/17/2014: For WCOSS and AWIPS2 sites there is no need to output AWIPS1 netCDF files.
if [ "${GEN_NETCDF}" == "" ]; then export GEN_NETCDF="FALSE"; fi

# 11/17/2014: Disable HDF5 out by default as it is no longer needed for WCOSS, AWIPS1, or AWIPS2 sites
if [ "${GEN_HDF5}" == "" ]; then export GEN_HDF5="FALSE"; fi 

# Set our default database DIRs here
if [ "${BATHYdb}" == "" ]; then export BATHYdb=${NWPSdir}/fix/bathy_db; fi
if [ "${SHAPEFILEdb}" == "" ]; then export SHAPEFILEdb=${NWPSdir}/fix/shapefile_db; fi

# Set our default processing DIRs here
if [ "${DATAdir}" == "" ]; then export DATAdir="${HOME}/data/nwps_${siteid}"; fi
if [ "${ARCHdir}" == "" ]; then export ARCHdir=${DATAdir}/archive; fi
if [ "${INPUTdir}" == "" ]; then export INPUTdir=${DATAdir}/input; fi
if [ "${LOGdir}" == "" ]; then export LOGdir=${DATAdir}/logs; fi
if [ "${VARdir}" == "" ]; then export VARdir=${DATAdir}/var; fi
if [ "${OUTPUTdir}" == "" ]; then export OUTPUTdir=${DATAdir}/output; fi
if [ "${RUNdir}" == "" ]; then export RUNdir=${DATAdir}/run; fi
if [ "${TMPdir}" == "" ]; then export TMPdir=${DATAdir}/tmp; fi
if [ "${LDMdir}" == "" ]; then export LDMdir=${DATAdir}/ldm; fi

# Setup our default wind profile
if [ "${WindInterpolationType}" == "" ]; then export WindInterpolationType="bilinear"; fi
# A setting of 0 will use the netCDF value for the wind timestep
if [ "${WindTimeStep}" == "" ]; then export WindTimeStep="0"; fi

# Set user name that started the NWPS processes
if [ "${USERNAME}" == "" ]; then export USERNAME=$(whoami); fi

# Send forecaster aleart messages through ldad
if [ "${SENDLDADALERTS}" == "" ]; then export SENDLDADALERTS="FALSE"; fi

echo "Setting up our NWPS environment for $SITEID"

# Include files required to complete model setup 
if [ ! -e ${DATA}/parm/templates/${siteid}/siteid.sh ]
    then
    echo "ERROR - Missing ${DATA}/parm/templates/${siteid}/siteid.sh"
    echo "ERROR - You must setup a domain for this site"
    export err=1; err_chk
fi
source ${DATA}/parm/templates/${siteid}/siteid.sh

if [ ! -e ${USHnwps}/set_os_env.sh ]
then
    echo "ERROR - Missing ${USHnwps}/set_os_env.sh"
    echo "ERROR - Check your NWPSdir setting"
    export err=1; err_chk
fi

source ${USHnwps}/set_os_env.sh

if [ "${NWPSplatform}" == "WCOSS" ]
then
    WCOSS="TRUE"
    WCOSS_SYSTEM=""
    WCOSS_USER=$(whoami)
    if [ -e /u/${WCOSS_USER} ] && [ -e /ptmpp1 ]
    then
        echo "INFO - Configuring NWPS for WCOSS system"
        WCOSS="TRUE"
        if [ -e /gpfs/gd1 ]
        then
    	echo "INFO - WOCSS is on GYRE system"
    	WCOSS_SYSTEM="GYRE"
        fi
        if [ -e /gpfs/td1 ]
        then
    	echo "INFO - WOCSS is on TIDE system"
    	WCOSS_SYSTEM="TIDE"
        fi
    fi
fi

if [ "${NWPSplatform}" == "DEVWCOSS" ]
then
    echo "NWPS is installed on DEVWCOSS platform, loading WCOSS config"
    if [ ! -e ${NWPSdir}/ush/devwcoss_config.sh ]
    then
	echo "ERROR - Missing WCOSS config file ${NWPSdir}/utils/etc/devwcoss_config.sh"
	echo "ERROR - Check your NWPS platform type"
	export err=1; err_chk
    else
	source ${NWPSdir}/ush/devwcoss_config.sh
    fi
fi

# Set the default RTOFS source to: will always be global for none SBN feeds
export DEFAULT_RTOFSSOURCE="global"

if [ "${RTOFSSOURCE}" == "" ]; then export RTOFSSOURCE="${DEFAULT_RTOFSSOURCE}"; fi

# RTOFS grid defaults to global grid
# Checking for region specific setting, and will apply defaults if not set
export DEFAULT_RTOFSLON="262.00 282.00"
export DEFAULT_RTOFSLAT="23.0 33.00"
export DEFAULT_RTOFSDATFILE="pdef_ncep_global.gz"
export DEFAULT_RTOFSHOURS="144"
export DEFAULT_RTOFSTIMESTEP="3"

if [ "${RTOFSLON}" == "" ]; then export RTOFSLON=${DEFAULT_RTOFSLON}; fi
if [ "${RTOFSLAT}" == "" ]; then export RTOFSLAT=${DEFAULT_RTOFSLAT}; fi
if [ "${RTOFSDATFILE}" == "" ]; then export RTOFSDATFILE="${DEFAULT_RTOFSDATFILE}"; fi
if [ "${RTOFSHOURS}" == "" ]; then export RTOFSHOURS=${DEFAULT_RTOFSHOURS}; fi
if [ "${RTOFSTIMESTEP}" == "" ]; then export RTOFSTIMESTEP=${DEFAULT_RTOFSTIMESTEP}; fi


# ESTOFS Domain for water level
export DEFAULT_ESTOFS_REGION="conus"
# ESFOTSDOMAIN="LON LAT 0. NX NY EW-RESOLUTION NS-RESOLUTION"
export DEFAULT_ESTOFSDOMAIN="262.00 23.0 0. 682 370 0.029326 0.027027"
export DEFAULT_ESTOFSNX="683"
export DEFAULT_ESTOFSNY="371"
export DEFAULT_ESTOFSHOURS="144"
export DEFAULT_ESTOFSTIMESTEP="1"

if [ "${ESTOFS_REGION}" == "" ]; then export ESTOFS_REGION="${DEFAULT_ESTOFS_REGION}"; fi
if [ "${ESTOFSDOMAIN}" == "" ]; then export ESTOFSDOMAIN="${DEFAULT_ESTOFSDOMAIN}"; fi
if [ "${ESTOFSNX}" == "" ]; then export ESTOFSNX=${DEFAULT_ESTOFSNX}; fi
if [ "${ESTOFSNY}" == "" ]; then export ESTOFSNY=${DEFAULT_ESTOFSNY}; fi
if [ "${ESTOFSHOURS}" == "" ]; then export ESTOFSHOURS=${DEFAULT_ESTOFSHOURS}; fi
if [ "${ESTOFSTIMESTEP}" == "" ]; then export ESTOFSTIMESTEP=${DEFAULT_ESTOFSTIMESTEP}; fi
#FOR PSURGE
export PSURGEHOURS="78"

# GFS wind domain settings
# GFSWINDDOMAIN="LON LAT 0. NX NY EW-RESOLUTION NS-RESOLUTION"
export DEFAULT_GFSWINDDOMAIN="262.00 23.0 0. 681 369 0.029369 0.0271"
export DEFAULT_GFSWINDNX="682"
export DEFAULT_GFSWINDNY="370"
export DEFAULT_GFSHOURS="144"
export DEFAULT_GFSTIMESTEP="3"

if [ "${GFSWINDDOMAIN}" == "" ]; then export GFSWINDDOMAIN="${DEFAULT_GFSWINDDOMAIN}"; fi
if [ "${GFSWINDNX}" == "" ]; then export GFSWINDNX=${DEFAULT_GFSWINDNX}; fi
if [ "${GFSWINDNY}" == "" ]; then export GFSWINDNY=${DEFAULT_GFSWINDNY}; fi
if [ "${GFSHOURS}" == "" ]; then export GFSHOURS=${DEFAULT_GFSHOURS}; fi
if [ "${GFSTIMESTEP}" == "" ]; then export GFSTIMESTEP=${DEFAULT_GFSTIMESTEP}; fi

# End of configuration load above.
#
# Echo our NWPS setup below.
echo "NWPS site ID is ${SITEID}"
echo "NWPS site type is ${SITETYPE}"
echo "NWPS home DIR is ${NWPSdir}"
echo "NWPS run started by user ${USERNAME}"

if [ "${DEBUGGING}" == "TRUE" ]
then 
    echo "INFO - Debugging is enabled for this run"
    echo "INFO - Debug level ${DEBUG_LEVEL}"
else
    echo "INFO - Debugging is disabled for this run"
fi

if [ "${ISPRODUCTION}" == "TRUE" ]
then 
    echo "INFO - Production mode is enabled for this run"
else
    echo "INFO - Production mode is disabled for this run"
fi

if [ "${ISPRODUCTION}" == "TRUE" ] && [ "${DEBUGGING}" == "TRUE" ]
then
    echo "WARNING - This is a production workstation with debugging on"
    echo "WARNING - Check your DEBUGGING setting"
fi

# Look for region specific overrides
if [ -e ${DATA}/parm/templates/${siteid}/${siteid}_config.sh ] && [ -e ${NWPSdir}/parm/regions/${regionid}_config.sh ]
then
    echo "INFO - Found ${NWPSdir}/parm/regions/${regionid}_config.sh"
    echo "INFO - Applying ${regionid} region specific settings for ${SITEID}"
    # Read the SITE config to get the regionid for this site
    source ${DATA}/parm/templates/${siteid}/${siteid}_config.sh
    # Read the region config file
    source ${NWPSdir}/parm/regions/${regionid}_config.sh 
fi

echo "MPMODE = ${MPMODE}"
echo "COMPILER for SRC builds = ${COMPILER}"
echo "USERNAME = ${USERNAME}"
echo "MODELTYPE = ${MODELTYPE}"
echo "HOTSTART = ${HOTSTART}"
echo "GEN_NETCDF = ${GEN_NETCDF}"
echo "GEN_HDF5 = ${GEN_HDF5}"
echo "SENDLDADALERTS = ${SENDLDADALERTS}"
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

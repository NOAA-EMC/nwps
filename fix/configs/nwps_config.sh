#!/bin/bash
# ----------------------------------------------------------- 
# UNIX Shell Script File
# Tested Operating System(s): RHEL 5,6
# Tested Run Level(s): 3, 5
# Shell Used: BASH shell
# Original Author(s): Douglas.Gaer@noaa.gov
# File Creation Date: 02/05/2011
# Date Last Modified: 07/11/2015
#
# Version control: 1.24
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
if [ "${NWPSdir}" == "" ]; then export NWPSdir="${HOME}/nwps"; fi

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

# Set our default database DIRs here
if [ "${BATHYdb}" == "" ]; then export BATHYdb=${NWPSdir}/bathy_db; fi
if [ "${SHAPEFILEdb}" == "" ]; then export SHAPEFILEdb=${NWPSdir}/shapefile_db; fi

# Set our default processing DIRs here
if [ "${ARCHdir}" == "" ]; then export ARCHdir=${NWPSdir}/archive; fi
if [ "${DATAdir}" == "" ]; then export DATAdir=${NWPSdir}/data; fi
if [ "${INPUTdir}" == "" ]; then export INPUTdir=${NWPSdir}/input; fi
if [ "${LOGdir}" == "" ]; then export LOGdir=${NWPSdir}/logs; fi
if [ "${VARdir}" == "" ]; then export VARdir=${NWPSdir}/var; fi
if [ "${OUTPUTdir}" == "" ]; then export OUTPUTdir=${NWPSdir}/output; fi
if [ "${RUNdir}" == "" ]; then export RUNdir=${NWPSdir}/run; fi
if [ "${TMPdir}" == "" ]; then export TMPdir=${NWPSdir}/tmp; fi
if [ "${LDMdir}" == "" ]; then export LDMdir=${LDMdir}/tmp; fi

# Setup our default wind profile
if [ "${WindInterpolationType}" == "" ]; then export WindInterpolationType="bilinear"; fi
# A setting of 0 will use the netCDF value for the wind timestep
if [ "${WindTimeStep}" == "" ]; then export WindTimeStep="0"; fi

# Set user name that started the NWPS processes
if [ "${USERNAME}" == "" ]; then export USERNAME=$(whoami); fi

# Send forecaster aleart messages through ldad
if [ "${SENDLDADALERTS}" == "" ]; then export SENDLDADALERTS="FALSE"; fi

echo "Setting up our NWPS environment"

# Include files required to complete model setup 
if [ ! -e ${NWPSdir}/etc/siteid.sh ]
    then
    echo "ERROR - Missing ${NWPSdir}/etc/siteid.sh"
    echo "ERROR - You must setup a domain for this site"
    exit 1
fi
source ${NWPSdir}/etc/siteid.sh

if [ ! -e ${NWPSdir}/etc/set_os_env.sh ]
then
    echo "ERROR - Missing ${NWPSdir}/etc/set_os_env.sh"
    echo "ERROR - Check your NWPSdir setting"
    exit 1
fi
source ${NWPSdir}/etc/set_os_env.sh

# Check our platform type for processing overrides
source ${NWPSdir}/etc/set_platform.sh

if [ "${NWPSplatform}" == "DEV" ]
then
    echo "NWPS is installed on development platform, using DEV config"
    if [ ! -e ${NWPSdir}/etc/dev_config.sh ]
    then
	echo "INFO - Missing DEV config file ${NWPSdir}/etc/dev_config.sh"
	echo "INFO - Using NWPS default for DEV workstation"
    else
	source ${NWPSdir}/etc/dev_config.sh
    fi
fi

if [ "${NWPSplatform}" == "AWIPS2" ]
then
    echo "NWPS is installed on AWIPS2 platform, loading AWIPS2 config"
    if [ ! -e ${NWPSdir}/etc/awips2_config.sh ]
    then
	echo "ERROR - Missing AWIPS2 config file ${NWPSdir}/etc/awips2_config.sh"
	echo "ERROR - Check your NWPS platform type"
	exit 1
    else
	source ${NWPSdir}/etc/awips2_config.sh
    fi
fi

if [ "${NWPSplatform}" == "NCEP" ]
then
    echo "NWPS is installed on NCEP platform, loading NCEP config"
    if [ ! -e ${NWPSdir}/etc/ncep_config.sh ]
    then
	echo "ERROR - Missing NCEP config file ${NWPSdir}/etc/ncep_config.sh"
	echo "ERROR - Check your NWPS platform type"
	exit 1
    else
	source ${NWPSdir}/etc/ncep_config.sh
    fi
fi

if [ "${NWPSplatform}" == "SRSWAN" ]
then
    echo "NWPS is installed on SRSWAN platform, loading SRSWAN config"
    if [ ! -e ${NWPSdir}/etc/srswan_config.sh ]
    then
	echo "ERROR - Missing SRSWAN config file ${NWPSdir}/etc/srswan_config.sh"
	echo "ERROR - Check your NWPS platform type"
	exit 1
    else
	source ${NWPSdir}/etc/srswan_config.sh
    fi
fi

if [ "${NWPSplatform}" == "IFPSWAN" ]
then
    echo "NWPS is installed on IFPSWAN platform, loading IFPSWAN config"
    if [ ! -e ${NWPSdir}/etc/ifpswan_config.sh ]
    then
	echo "ERROR - Missing IFPSWAN config file ${NWPSdir}/etc/ifpswan_config.sh"
	echo "ERROR - Check your NWPS platform type"
	exit 1
    else
	source ${NWPSdir}/etc/ifpswan_config.sh
    fi
fi

# Look for region specific overrides
if [ -e ${NWPSdir}/etc/${region}_config.sh ]
then
    echo "INFO - Found ${NWPSdir}/etc/${region}_config.sh"
    echo "INFO - Applying region specific settings for ${SITEID}"
    source ${NWPSdir}/etc/${region}_config.sh 
fi

# Look for site specific overrides
if [ -e ${NWPSdir}/etc/${siteid}_config.sh ]
then
    echo "INFO - Found ${NWPSdir}/etc/${siteid}_config.sh"
    echo "INFO - Applying site specific settings for ${SITEID}"
    source ${NWPSdir}/etc/${siteid}_config.sh 
fi

# Set the default RTOFS source
# global for entire netCDF grid
# sector for grib2 sectors
##export DEFAULT_RTOFSSOURCE="global"
export DEFAULT_RTOFSSOURCE="sector"

# Match this to the grib2 file sector name 
export DEFAULT_RTOFSSECTOR="west_atl"

if [ "${RTOFSSOURCE}" == "" ]; then export RTOFSSOURCE="${DEFAULT_RTOFSSOURCE}"; fi
if [ "${RTOFSSECTOR}" == "" ]; then export RTOFSSECTOR="${DEFAULT_RTOFSSECTOR}"; fi

# RTOFS grid defaults to global grid
# Checking for region specific setting, and will apply defaults if not set
export DEFAULT_RTOFSLON="262.00 282.00"
export DEFAULT_RTOFSLAT="23.0 33.00"
export DEFAULT_RTOFSDATFILE="pdef_ncep_global.gz"

# RTOFS grid defaults for grib2 sectors
export DEFAULT_RTOFSDOMAIN="262.00 23.0 0. 682 370 0.029326 0.027027"
export DEFAULT_RTOFSNX="683"
export DEFAULT_RTOFSNY="371"

export DEFAULT_RTOFSHOURS="144"
export DEFAULT_RTOFSTIMESTEP="3"

if [ "${RTOFSLON}" == "" ]; then export RTOFSLON=${DEFAULT_RTOFSLON}; fi
if [ "${RTOFSLAT}" == "" ]; then export RTOFSLAT=${DEFAULT_RTOFSLAT}; fi
if [ "${RTOFSDATFILE}" == "" ]; then export RTOFSDATFILE="${DEFAULT_RTOFSDATFILE}"; fi

# RTOFS grid defaults for grib2 sectors
if [ "${RTOFSDOMAIN}" == "" ]; then export RTOFSDOMAIN="${DEFAULT_RTOFSDOMAIN}"; fi
if [ "${RTOFSNX}" == "" ]; then export RTOFSNX=${DEFAULT_RTOFSNX}; fi
if [ "${RTOFSNY}" == "" ]; then export RTOFSNY=${DEFAULT_RTOFSNY}; fi

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

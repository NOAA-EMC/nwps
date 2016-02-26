#!/bin/bash
# -----------------------------------------------------------
# UNIX Shell Script
# Tested Operating System(s): RHEL 5, 6
# Tested Run Level(s): 3, 5, 6
# Shell Used: BASH shell
# Original Author(s): Douglas.Gaer@noaa.gov
# File Creation Date: 01/17/2013
# Date Last Modified: 01/30/2013
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
# This script is used to purge the previous GFS data set.
# We need to keep the current run, which is good out to 5 days
# This will allow to use the GFS data in the event of a 
# data ingest problem. The GFS model input script will know
# what times this data set is valid for and alert the forecaster
# if GFS data is not available for their model run times.
#
# -----------------------------------------------------------

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

GFSWINDdir="${INPUTdir}/gfswind"
last_hour="${GFSHOURS}"

# Allow calling script to set the GFSWIND data dir
if [ "${1}" != "" ]; then GFSWINDdir="${1}"; fi
if [ "${2}" != "" ]; then last_hour="${2}"; fi

FF=`echo $last_hour`
if [ $last_hour -le 99 ]
then
    FF=`echo 0$last_hour`
fi
if [ $last_hour -le 9 ]
then
    FF=`echo 00$last_hour`
fi

echo "Purging previous GFSWIND data in DIR ${GFSWINDdir}"
if [ ! -e ${GFSWINDdir} ]
    then
    echo "INFO - Cannot find DIR ${GFSWINDdir}"
    export err=1; err_chk
fi

if [ -e ${GFSWINDdir}/gfswind_start_time.txt ]
    then
    gfswind_run_time=$(cat ${GFSWINDdir}/gfswind_start_time.txt)
    cd ${GFSWINDdir}

    file=$(ls --color=none -1 ${GFSWINDdir}/gfswind*.dat | grep ${gfswind_run_time} | grep f${FF}.dat)
    if [ "${file}" != "" ] 
    then
	old_files=$(ls --color=none -1 ${GFSWINDdir}/gfswind*.dat | grep -v ${gfswind_run_time})
	for i in ${old_files}
	do
	    echo "Purging ${i}"
	    rm -f ${i}
	done
    else
	echo "INFO - We do not have latest GFSWIND data out to ${last_hour} hours for U/V 10m winds"
	echo "INFO - Not purging any data"
    fi
else
    echo "INFO - Cannot find DIR ${GFSWINDdir}/gfswind_start_time.txt file"
    export err=1; err_chk
fi

echo "Purge complete"
exit 0
# -----------------------------------------------------------
# *******************************
# ********* End of File *********
# *******************************

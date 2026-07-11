#!/bin/bash
# -----------------------------------------------------------
# UNIX Shell Script
# Tested Operating System(s): RHEL 5, 6
# Tested Run Level(s): 3, 5, 6
# Shell Used: BASH shell
# Original Author(s): Douglas.Gaer@noaa.gov
# File Creation Date: 12/14/2012
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
# This script is used to purge the previous STOFS data set.
# We need to keep the current run, which is good out to 5 days
# This will allow to use the STOFS data in the event of a 
# data ingest problem. The STOFS model input script will know
# what times this data set is valid for and alert the forecaster
# if STOFS data is not available for their model run times.
#
# -----------------------------------------------------------
set -xa

# Check to see if our SITEID is set
if [ "${SITEID}" == "" ]
    then
    echo "ERROR - Your SITEID variable is not set"
    export err=1; err_chk
fi

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

STOFSdir="${INPUTdir}/stofs"
last_hour="${STOFSHOURS}"

# Allow calling script to set the STOFS data dir
if [ "${1}" != "" ]; then STOFSdir="${1}"; fi
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

echo "Purging previous STOFS data in DIR ${STOFSdir}"
if [ ! -e ${STOFSdir} ]
    then
    echo "INFO - Cannot find DIR ${STOFSdir}"
    export err=1; err_chk
fi

if [ -e ${STOFSdir}/stofs_waterlevel_start_time.txt ]
    then
    water_run_time=$(cat ${STOFSdir}/stofs_waterlevel_start_time.txt)
    cd ${STOFSdir}

    file=$(ls --color=none -1 ${STOFSdir}/* | grep wave_stofs_waterlevel | grep ${water_run_time} | grep f${FF}.dat)
    if [ "${file}" != "" ] 
    then
	old_files=$(ls --color=none -1 ${STOFSdir}/wave_stofs_waterlevel*.dat | grep -v ${water_run_time})
	for i in ${old_files}
	do
	    echo "Purging ${i}"
	    rm -f ${i}
	done
    else
	echo "INFO - We do not have latest STOFS data out to ${last_hour} hours for waterlevel"
	echo "INFO - Not purging any data"
    fi
else
    echo "INFO - Cannot find DIR ${STOFSdir}/stofs_waterlevel_start_time.txt file"
fi

echo "Purge complete"
exit 0
# -----------------------------------------------------------
# *******************************
# ********* End of File *********
# *******************************

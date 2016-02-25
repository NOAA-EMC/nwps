#!/bin/bash
# -----------------------------------------------------------
# UNIX Shell Script
# Tested Operating System(s): RHEL 5
# Tested Run Level(s): 3, 5, 6
# Shell Used: BASH shell
# Original Author(s): Douglas.Gaer@noaa.gov
# File Creation Date: 09/29/2009
# Date Last Modified: 07/29/2014
#
# Version control: 1.26
#
# Support Team:
#
# Contributors:
# -----------------------------------------------------------
# ------------- Program Description and Details -------------
# -----------------------------------------------------------
#
# This script is used to purge the previous RTOFS data set.
# We need to keep the current run, which is good out to 5 days
# This will allow to use the RTOFS data in the event of a 
# data ingest problem. The RTOFS model input script will know
# what times this data set is valid for and alert the forecaster
# if RTOFS data is not available for their model run times.
#
# -----------------------------------------------------------

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

RTOFSdir="${INPUTdir}/rtofs"
last_hour="${RTOFSHOURS}"

# Allow calling script to set the RTOFS data dir
if [ "${1}" != "" ]; then RTOFSdir="${1}"; fi
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

echo "Purging previous RTOFS data in DIR ${RTOFSdir}"
if [ ! -e ${RTOFSdir} ]
    then
    echo "INFO - Cannot find DIR ${RTOFSdir}"
    export err=1; err_chk
fi

if [ ! -e ${RTOFSdir}/rtofs_current_start_time.txt ]
    then
    echo "INFO - Cannot find DIR ${RTOFSdir}/rtofs_current_start_time.txt file"
    export err=1; err_chk
fi
curr_run_time=$(cat ${RTOFSdir}/rtofs_current_start_time.txt)

cd ${RTOFSdir}

file=$(ls --color=none -1 ${RTOFSdir}/* | grep wave_rtofs_uv | grep ${curr_run_time} | grep f${FF}.dat)
if [ "${file}" == "" ] 
    then
    echo "INFO - We do not have latest RTOFS data out to ${last_hour} hours for UV current"
    echo "INFO - Not purging any data"
    exit 0
fi

old_files=$(ls --color=none -1 ${RTOFSdir}/*wave_rtofs_uv*.dat | grep -v ${curr_run_time})
for i in ${old_files}
do
  echo "Purging ${i}"
  rm -f ${i}
done

echo "Purge complete"
exit 0
# -----------------------------------------------------------
# *******************************
# ********* End of File *********
# *******************************

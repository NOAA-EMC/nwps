#!/bin/bash
set -xa
# -----------------------------------------------------------
# UNIX Shell Script File Name: calc_runtime.sh
# Tested Operating System(s): RHEL 3, 4, 5
# Tested Run Level(s): 3, 5
# Shell Used: BASH shell
# Original Author(s): Douglas.Gaer@noaa.gov
# File Creation Date: 08/01/2008
# Date Last Modified: 07/09/2013
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
# Include script used to calculate a process script's run time.
#
# -----------------------------------------------------------

function calc_runtime() {
    # Caller must supply a start and finish time by adding the following
    # lines at the top and bottom of the script or function:
    #
    # START=`date +%s`
    # ...
    # FINISH=`date +%s`
    #
    # source ~/bin/calc_runtime.sh
    # calc_runtime $START $FINISH "My process"
    #

    START="$1"
    FINISH="$2"
    PROCNAME="${3}"

    diff=$((FINISH - START))
    echo -n "Total run time for ${PROCNAME}: "
    HRS=`expr $diff / 3600`
    MIN=`expr $diff % 3600 / 60`
    SEC=`expr $diff % 3600 % 60`
    if [ $HRS -gt 0 ]
	then
	echo -n "$HRS hrs. "
    fi
    if [ $MIN -gt 0 ]
	then
	echo -n "$MIN mins. "
    fi
    if [ $SEC -gt 0 ]
	then
	if [ $MIN -gt 0 ]
	    then
	    echo "and $SEC secs."
	elif [ $HRS -gt 0 ]
	    then
	    echo "and $SEC secs."
	else
	    echo "$SEC secs."
	fi
    fi
}

# ----------------------------------------------------------- 
# ******************************* 
# ********* End of File ********* 
# ******************************* 

#!/bin/bash
set -xa
# ----------------------------------------------------------- 
# UNIX Shell Script File
# Tested Operating System(s): RHEL 5,6
# Tested Run Level(s): 3, 5
# Shell Used: BASH shell
# Original Author(s): Douglas.Gaer@noaa.gov
# File Creation Date: 06/26/2014
# Date Last Modified: 11/16/2014
#
# Version control: 1.03
#
# Support Team:
#
# Contributors:
# ----------------------------------------------------------- 
# ------------- Program Description and Details ------------- 
# ----------------------------------------------------------- 
#
# Multi-site script used to halt NWPS for specified site
#
# ----------------------------------------------------------- 

if [ "${1}" == "" ]
then
    echo "ERROR - you must suppply a site ID"
    export err=1; err_chk
fi

# Check to see if our NWPS directory is set
if [ "${HOMEnwps}" == "" ]
    then 
    echo "ERROR - Your NWPSdir variable is not set"
    export err=1; err_chk
fi

# Check to see if our NWPS env is set
if [ -e ${USHnwps}/nwps_config.sh ]
then
    source ${USHnwps}/nwps_config.sh
else
    "ERROR - Cannot find ${USHnwps}/nwps_config.sh"
    export err=1; err_chk
fi

# Set our site ID here
export SITEID=$(echo ${1} | tr [:lower:] [:upper:])
export siteid=$(echo ${1} | tr [:upper:] [:lower:])
 
# Source and BASH includes
#source ${USHnwps}/process_lock.sh

# Setup process locking
PROGRAMname="$0"
if [ ! -e ${VARdir} ]; then mkdir -p ${VARdir}; fi
#LOCKfile="${VARdir}/stopSwan.lck"
#MINold="5"
#LockFileCheck $MINold
#CreateLockFile

# Setup up logging DIR and log file
if [ ! -e ${LOGdir} ]; then mkdir -vp ${LOGdir}; fi
logfile=${LOGdir}/stopSwan.log 

cat /dev/null > ${LOGdir}/stopSwan.log
echo "Stopping previous NWPS run for site: $SITEID " | tee -a $logfile
date -u | tee -a $logfile
echo "Checking for processing directories" | tee -a $logfile
if [ ! -e ${TMPdir}/${USERNAME}/nwps ]; then mkdir -vp ${TMPdir}/${USERNAME}/nwps | tee -a $logfile; fi
if [ ! -e ${RUNdir} ]; then mkdir -vp ${RUNdir} | tee -a $logfile; fi

PIDFILES=$(find ${TMPdir}/${USERNAME}/nwps -name "*.pid" -print | sort -n)
if [ "${PIDFILES}" == "" ]
then
    echo "INFO - We do not have any processes running for site: ${SITEID}" | tee -a $logfile
    if [ -e ${TMPdir}/${USERNAME}/nwps/nwps_pids.running ]; then rm -f ${TMPdir}/${USERNAME}/nwps/nwps_pids.running; fi
    echo "Stop script complete " | tee -a $logfile
    cd ${DATA}/
    #RemoveLockFile
    exit 0
fi

echo "INFO - We have NWPS processes running for site: ${SITEID}" | tee -a $logfile
echo "INFO - Stopping current processes" | tee -a $logfile

has_error=0

for pidfile in ${PIDFILES}
do
    echo -n "${pidfile} PPDI:"  | tee -a $logfile
    cat ${pidfile}  | tee -a $logfile
    ppid=$(cat ${pidfile})
    systemppid=$(ps -ef | grep ${USERNAME} | grep ${ppid} | grep -v grep)
    if [ "${systemppid}" == "" ]
    then
	echo "INFO - ${ppid} processing stopped for user ${USERNAME}"  | tee -a $logfile
	rm -f ${pidfile}
	continue
    fi

    echo "INFO - Stoping ${ppid} for ${USERNAME}"  | tee -a $logfile
    kill -- -$(ps -o pgid= ${ppid} | grep -o [0-9]*)  | tee -a $logfile
    systemppid=$(ps -ef | grep ${USERNAME} | grep ${ppid} | grep -v grep)
    if [ "${systemppid}" == "" ]
    then
	echo "INFO - ${ppid} processing stopped for user ${USERNAME}"  | tee -a $logfile
        rm -f ${pidfile}
        continue
    fi
    kill -9 -$(ps -o pgid= ${ppid} | grep -o [0-9]*)  | tee -a $logfile
    systemppid=$(ps -ef | grep ${USERNAME} | grep ${ppid} | grep -v grep)
    if [ "${systemppid}" == "" ]
    then
	echo "INFO - ${ppid} processing stopped for user ${USERNAME}"  | tee -a $logfile
        rm -f ${pidfile}
        continue
    else 
	echo "ERROR - Could not stop ${ppid} processing stopped for user ${USERNAME}" | tee -a $logfile
	COUNTER=0
        while [  $COUNTER -lt 5 ]; do
            let COUNTER=COUNTER+1 
	    echo "WARN - Retry ${COUNTER} to stop ${ppid} processing stopped for user ${USERNAME}"
	    sleep 3
	    kill -- -$(ps -o pgid= ${ppid} | grep -o [0-9]*)  | tee -a $logfile
	    kill -9 -$(ps -o pgid= ${ppid} | grep -o [0-9]*)  | tee -a $logfile
	    systemppid=$(ps -ef | grep ${USERNAME} | grep ${ppid} | grep -v grep)
	    if [ "${systemppid}" == "" ]
	    then
		echo "INFO - ${ppid} processing stopped for user ${USERNAME}"  | tee -a $logfile
		rm -f ${pidfile}
		break
	    fi
        done
	 systemppid=$(ps -ef | grep ${USERNAME} | grep ${ppid} | grep -v grep)
         if [ "${systemppid}" != "" ]
	 then
	     echo "ERROR - Could not stop ${ppid} processing stopped for user ${USERNAME}" | tee -a $logfile
	     has_error=1
	 fi
    fi
done

if [ $has_error -ne 0 ]
then
    date -u | tee -a $logfile
    echo "ERROR - Stop script could not stop all processed for ${USERNAME} ${SITEID} " | tee -a $logfile
    cd ${DATA}/
    #RemoveLockFile
    export err=1; err_chk
fi

date -u | tee -a $logfile
echo "Stop script complete" | tee -a $logfile
echo "All processes for ${USERNAME} ${SITEID} have been stopped"
cd ${DATA}/
#RemoveLockFile
exit 0
# ----------------------------------------------------------- 
# ******************************* 
# ********* End of File ********* 
# ******************************* 

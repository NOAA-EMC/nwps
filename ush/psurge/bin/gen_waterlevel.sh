#!/bin/bash
set -xa
# -----------------------------------------------------------
# UNIX Shell Script
# Tested Operating System(s): RHEL 5, 6
# Tested Run Level(s): 3, 5
# Shell Used: BASH shell
# Original Author(s): Douglas.Gaer@noaa.gov
# File Creation Date: 12/14/2012
# Date Last Modified: 07/07/2015
#
# Version control: 1.13
#
# Support Team:
#
# Contributors: Roberto.Padilla@noaa.gov
# -----------------------------------------------------------
# ------------- Program Description and Details -------------
# -----------------------------------------------------------
#
# Script used to create water level files for SWAN
# using hi-res PSURGE data.
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
	echo "ERROR - Cannot find ${USHnwps}/nwps_config.sh"
	export err=1; err_chk
    fi
fi

# NOTE: Data is processed on the server in UTC
export TZ="UTC"

# Source our alert functions script
#source ${USHnwps}/alert_messages.sh

# Script variables
# ===========================================================
BINdir="${USHnwps}/psurge/bin"
LOGfile="${LOGdir}/gen_waterlevel.log"

# Set our data processing directory
LDMdir="${LDMdir}/psurge"
INPUTdir="${INPUTdir}/psurge"

# Set our locking variables
PROGRAMname="$0"
#LOCKfile="$VARdir/gen_waterlevel.lck"
#MINold="30"

#source ${USHnwps}/process_lock.sh

# Make any of the following directories if needed
mkdir -p ${INPUTdir}
mkdir -p ${VARdir}
mkdir -p ${LOGdir}

cat /dev/null > ${LOGfile}

echo "Generating waterlevel files for NWPS model" | tee -a ${LOGfile}
#echo "Checking for lock files" | tee -a ${LOGfile}
#LockFileCheck $MINold

datetime=`date -u`
echo "Starting processing at at $datetime UTC" | tee -a ${LOGfile}

##CreateLockFile

myPWD=`pwd`

if [ "${RETROSPECTIVE}" == "FALSE" ]; then    #RETROSPECTIVE

if [ ! -e ${INPUTdir}/psurge_waterlevel_start_time.txt ] || [ ! -e ${INPUTdir}/psurge_waterlevel_domain_${siteid}.txt ]
    then
    echo "INFO - No PSURGE data to process" | tee -a ${LOGfile}
    echo "INFO - Will try to copy files from ${LDMdir}" | tee -a ${LOGfile}
    if [ ! -e ${LDMdir}/psurge_waterlevel_start_time.txt ]
    then
       echo "ERROR - No PSURGE data to process" | tee -a ${LOGfile}
       echo "ERROR - Missing PSURGE start time file ${LDMdir}/psurge_waterlevel_start_time.txt" | tee -a ${LOGfile}
       ##RemoveLockFile
       export err=1; err_chk
    fi
    rsync -av --force --stats --progress ${LDMdir}/*waterlevel* ${INPUTdir}/.
fi


input_dir_start=$(cat ${INPUTdir}/psurge_waterlevel_start_time.txt)

if [ -e ${LDMdir}/psurge_waterlevel_start_time.txt ]
    then 
    ingest_dir_start=$(cat ${LDMdir}/psurge_waterlevel_start_time.txt)

    cd ${LDMdir}
    ingest_filehours=$(ls -1rat --color=none *.dat)
    cd ${INPUTdir} 
    input_filehours=$(ls -1rat --color=none *.dat)
    
    for h in ${ingest_filehours} 
    do 
	ingest_lasthour=$(echo "${h}" | awk -F_ '{ print $9 }' | sed s/.dat//g | sed s/f//g) 
    done
    
    for h in ${input_filehours} 
    do 
	input_lasthour=$(echo "${h}" | awk -F_ '{ print $9 }' | sed s/.dat//g | sed s/f//g) 
    done
    
    if [ $ingest_dir_start -gt $input_dir_start ] || [ $ingest_lasthour -gt $input_lasthour ]
    then
	echo "INFO - New PSURGE data to process in ingest DIR" | tee -a ${LOGfile}
	echo "INFO - Will copy files from ${LDMdir}" | tee -a ${LOGfile}
	rsync -av --force --stats --progress ${LDMdir}/*waterlevel* ${INPUTdir}/.
    fi

    if [ ! -e ${INPUTdir}/psurge_waterlevel_start_time.txt ]
    then
	echo "ERROR - No PSURGE data to process" | tee -a ${LOGfile}
	echo "ERROR - Missing PSURGE start time file ${INPUTdir}/psurge_waterlevel_start_time.txt" | tee -a ${LOGfile}
	#RemoveLockFile
	export err=1; err_chk
    fi
fi

fi    #RETROSPECTIVE

if [ ! -e ${INPUTdir}/psurge_waterlevel_domain_${siteid}.txt ]
then 
    echo "ERROR - No domain info found with this data set"
    echo "ERROR - Missing ${INPUTdir}/psurge_waterlevel_domain_${siteid}.txt"
    #RemoveLockFile
    export err=1; err_chk
fi

# This file must contain a line in the following format
# PSURGEDOMAIN:LON LAT NX NY EW-RESOLUTION NS-RESOLUTION 
# for example:
#
# PSURGEDOMAIN:254.97 16.5 0. 1001 670 0.05000 0.050000"
#
PSURGEDOMAIN=$(grep ^PSURGEDOMAIN ${INPUTdir}/psurge_waterlevel_domain_${siteid}.txt | awk -F: '{ print $2 }')
cd ${LDMdir}

if [ "${RETROSPECTIVE}" == "FALSE" ]; then    #RETROSPECTIVE
   echo "INFO - Checking ${LDMdir} for updates" | tee -a ${LOGfile}
   diff ${INPUTdir}/psurge_waterlevel_start_time.txt ${LDMdir}/psurge_waterlevel_start_time.txt
   if [ "$?" == "0" ]
   then
       echo "INFO - We have no more forecast hours to add to this data set" | tee -a ${LOGfile}
   fi
fi    #RETROSPECTIVE

cd ${myPWD}

echo "Cleaning up any previous ${RUNdir}/*.wlev files" | tee -a ${LOGfile}
files=`ls -1rat ${RUNdir}/*.wlev`
for file in ${files}
  do
  echo "Removing ${file}" | tee -a ${LOGfile}
  # NOTE: The RM command does not like globbing with an underscore in the
  # NOTE: file name in our SHELL env. So we will delete the files one by one.
  rm -f ${file}
done

echo "Purging any old model ingest" | tee -a ${LOGfile}
last_hour=${PSURGEHOURS}
${BINdir}/purge_psurge.sh ${INPUTdir} ${last_hour}

# Find most recent water level file by comparing the model init epoch time 
# to those of all available PSURGE files (ignoring psurge_waterlevel_start_time.txt)
# This allows the same water level file to be used in case of a model rerun.
# NOTE: The availability and age of wave_combnd_waterlevel* is checked in ush/get_ncep_initfiles.sh
# NOTE: so that $psurge_waterlevel_start_time will always be defined, and <= $model_start_time.
# NOTE: Otherwise, ush/get_ncep_initfiles.sh will fail over to using ESTOFS water levels.
psurge_waterlevel_start_time=`ls ${INPUTdir}/wave_combnd_waterlevel* | xargs -n1 basename | cut -b24-33 | sort | uniq | awk -v thresh=$model_start_time '$1 <= thresh' | tail -1`
psurge_date_str=`echo ${psurge_waterlevel_start_time} | awk '{ print strftime("%Y%m%d", $1) }'`
psurge_model_cycle=`echo ${psurge_waterlevel_start_time} | awk '{ print strftime("%H", $1) }'`

let fin=psurge_waterlevel_start_time
fin1=$(echo " ${PSURGEHOURS}* 3600" | bc -l)
let fin+=fin1
psurge_end_time_str=`echo ${fin} | awk '{ print strftime("%Y%m%d%H", $1) }'`

echo "PSURGE end TIME: ${psurge_end_time_str}"

if [ "$1" != "" ]
    then 
    YYYYMMDDHH=${1}
else
    YYYYMMDDHH=`echo ${psurge_waterlevel_start_time} | awk '{ print strftime("%Y%m%d%H", $1) }'`
fi

PROCESS_WATERLEVEL="TRUE"
if [ "$2" != "" ]
    then
    if [ "$2" == "No" ]; then PROCESS_WATERLEVEL="FALSE"; fi
fi

echo "Our YYYYMMDDHH is ${YYYYMMDDHH}" | tee -a ${LOGfile}

YYYY=`echo ${YYYYMMDDHH} | cut -b1-4`
MM=`echo ${YYYYMMDDHH} | cut -b5-6`
DD=`echo ${YYYYMMDDHH} | cut -b7-8`
HH=`echo ${YYYYMMDDHH} | cut -b9-10`

time_str="${YYYY} ${MM} ${DD} ${HH} 00 00"
model_start_time=`echo ${time_str} | awk -F: '{ print mktime($1 $2 $3 $4 $5 $6) }'`

echo "PSURGE start UNIX time: ${psurge_waterlevel_start_time}" | tee -a ${LOGfile}
echo "Model start UNIX time: ${model_start_time}" | tee -a ${LOGfile}

# Calculate our start time for the PSURGE data set
# Start with the SWAN RUN time input by the user
start=$model_start_time
# Subtract the PSURGE start time and convert seconds to hours
let start-=psurge_waterlevel_start_time
let start/=3600

# Lets clean the waterlevel data from all inputCG files
SWANPARMS=`perl -I${PMnwps} -I${RUNdir} ${BINdir}/psurge_match.pl`
for parm in ${SWANPARMS}
  do
  CG=`echo ${parm} | awk -F, '{ print $1 }'`
  inputCG="${RUNdir}/input${CG}"

#  echo "Removing any old water level lines from ${inputCG}" | tee -a ${LOGfile}
  if [ ! -e ${inputCG} ]
      then
      echo "ERROR - Missing input file: ${inputCG}" | tee -a ${LOGfile}
  else
      tmpfile="${VARdir}/input${CG}.$$"
      grep -v "INPGRID WLEV " ${inputCG} > ${tmpfile} 
      grep -v "READINP WLEV " ${tmpfile} > ${inputCG} 
      rm -f ${tmpfile}
  fi
done

if [ "${PROCESS_WATERLEVEL}"  == "FALSE" ]
    then 
    echo "WARNING - The caller of this script has disabled water level data" | tee -a ${LOGfile}
    echo "WARNING - Argument 2 is set: ${2}" | tee -a ${LOGfile}
    echo "WARNING - To enable again re-run without argument 2 set to NO" | tee -a ${LOGfile}
    echo "WARNING - This SWAN run will not have any water level interaction" | tee -a ${LOGfile}
    #RemoveLockFile
    export err=1; err_chk
fi

# Lets check our forecast length and compare it against the hours we have for 
# the waterlevel data. If the forecaster has exceeded the number number of hours
# we will truncate the forecast hours to match the waterlevel data.
SWANPARMS=`perl -I${PMnwps} -I${RUNdir} ${BINdir}/psurge_match.pl`
FCSTLENGTH=`echo ${parm} | awk -F, '{ print $3 }'`
lencheck=$FCSTLENGTH
let lencheck*=3600
timecheck=model_start_time
let timecheck-=psurge_waterlevel_start_time

# Max hours old our waterlevel data can be
maxage=60
let maxage*=3600

if [ $timecheck -gt $maxage ]
    then
    echo "ERROR - PSURGE data is too old" | tee -a ${LOGfile}
    echo "ERROR - Check the PSURGE download from NCEP" | tee -a ${LOGfile}
    echo "ERROR - The SWAN will not include any PSURGE water level interaction" | tee -a ${LOGfile}
    
    # Alert the forecasters that the forecast length was truncated
    echo "Sending alert message to the forecasters"  | tee -a ${LOGfile}
    SendAWIPSMessage ${VARdir} "PSURGE DATA IS TOO OLD" \
	"HAVE IT OR SOO CHECK THE PSURGE DOWNLOAD FROM LDM or from NCEP" \
	"THE SWAN WILL NOT INCLUDE ANY WATER LEVEL INTERACTION" | tee -a ${LOGfile} 2>&1
    #RemoveLockFile
    export err=1; err_chk
fi

maxhours="${PSURGEHOURS}"
let maxhours*=3600
let maxhours-=timecheck

if [ $lencheck -gt $maxhours ]
    then 
    lencheck=$maxhours
    let lencheckhours=$lencheck/3600
    echo "WARNING: Run length of ${FCSTLENGTH} h exceeds the max hours of available PSURGE water level data. ESTOFS will be applied after $lencheckhours h." | tee -a ${LOGfile}
    echo "WARNING: Run length of ${FCSTLENGTH} h exceeds the max hours of available PSURGE water level data. ESTOFS will be applied after $lencheckhours h."| tee -a ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt
    #AW: This warning message to the jlogfile/SDM is perhaps too verbose, since 
    #    it will occur regularly and doesn't require any action.
    #msg="WARNING: Run length of ${FCSTLENGTH} h exceeds the max hours of available PSURGE water level data. ESTOFS will be applied after $lencheck h."
    #postmsg "$jlogfile" "$msg"
    #let lencheck*=3600

    #########XXX FCSTLENGTH=`echo $lencheck`
    #echo "WARNING - THIS NOT THE CASE ANYMORE FCSTLENGTH = ${FCSTLENGTH} " | tee -a ${LOGfile}
    #echo "Changing the forecast length in ${RUNdir}/ConfigSwan.pm to match the waterlevel data"  | tee -a ${LOGfile}
    #export RUNLEN=`grep "use constant SWANFCSTLENGTH =>" ${RUNdir}/ConfigSwan.pm`
    #sed -i s/"$RUNLEN"/"use constant SWANFCSTLENGTH => '${FCSTLENGTH}';"/g ${RUNdir}/ConfigSwan.pm
    
      # Alert the forecasters that the forecast length was truncated
    #echo "Sending alert message to the forecasters"  | tee -a ${LOGfile}
    #SendAWIPSMessage ${VARdir} "THE FORECAST LENGTH HAS EXCEEDED THE MAX HOURS OF WATERLEVEL DATA" \
	#"TRUNCATING THE FORECAST LENGTH FROM $FCSTLENGTH TO $lencheck" | tee -a ${LOGfile} 2>&1
fi

let lencheck/=3600

# Generate the waterlevel data for SWAN and update all inputCG files
SWANPARMS=`perl -I${PMnwps} -I${RUNdir} ${BINdir}/psurge_match.pl`
for parm in ${SWANPARMS}
  do
  echo "Processing SWAN parameters: ${parm}" | tee -a ${LOGfile}
  CG=`echo ${parm} | awk -F, '{ print $1 }'`
  #TIMESTEP=`echo ${parm} | awk -F, '{ print $2 }'`
  #Variable PSURGETIMESTEP set in ush/psurge/bin/psurge_config.sh 
  source ${USHnwps}/psurge_config.sh
  FCSTLENGTH=`echo ${parm} | awk -F, '{ print $3 }'`
  echo "CG=${CG} PSURGETIMESTEP=${PSURGETIMESTEP} FCSTLENGTH=${FCSTLENGTH}" | tee -a ${LOGfile}

  inputCG="${RUNdir}/input${CG}"
  if [ ! -e ${inputCG} ]
      then
      echo "ERROR - Missing input file: ${inputCG}" | tee -a ${LOGfile}
      #RemoveLockFile
      export err=1; err_chk
  fi

  end=0
  let t0=start
  #outfile="${RUNdir}/${YYYYMMDDHH}_${CG}.wlev"
  outfile="${RUNdir}/${YYYYMMDDHH}_${CG}_psurge.wlev"
  echo "SWAN waterlevel file: ${outfile}" | tee -a ${LOGfile}

  FF=`echo $t0`
  if [ $t0 -le 99 ]
      then
      FF=`echo 0$t0`
  fi
  if [ $t0 -le 9 ]
      then
      FF=`echo 00$t0`
  fi
  source ${RUNdir}/PEXCD
  #infile="${INPUTdir}/wave_psurge_waterlevel_${psurge_waterlevel_start_time}_${psurge_date_str}_${psurge_model_cycle}_${siteid}_e${EXCD}_f${FF}.dat"
  infile="${INPUTdir}/wave_combnd_waterlevel_${psurge_waterlevel_start_time}_${psurge_date_str}_${psurge_model_cycle}_${siteid}_e${EXCD}_f${FF}.dat"
  echo "SWAN input file for $t0: ${infile}" | tee -a ${LOGfile}
  if [ ! -e ${infile} ]
  then
      echo "ERROR - Missing input file: ${infile}" | tee -a ${LOGfile}
      #RemoveLockFile
      export err=1; err_chk
  fi
  cat ${infile} > ${VARdir}/wlevel_temp.$$

  #until [ $end -ge $FCSTLENGTH ]; do
  until [ $end -ge $lencheck ]; do
      let end+=$PSURGETIMESTEP
      let tstep=start+end
      FF=`echo $tstep`
      if [ $tstep -le 99 ]
	  then
	  FF=`echo 0$tstep`
      fi
      if [ $tstep -le 9 ]
	  then
	  FF=`echo 00$tstep`
      fi

      #infile="${INPUTdir}/wave_psurge_waterlevel_${psurge_waterlevel_start_time}_${psurge_date_str}_${psurge_model_cycle}_${siteid}_e${EXCD}_f${FF}.dat"
      infile="${INPUTdir}/wave_combnd_waterlevel_${psurge_waterlevel_start_time}_${psurge_date_str}_${psurge_model_cycle}_${siteid}_e${EXCD}_f${FF}.dat"
      echo "SWAN input file for $tstep: ${infile}" | tee -a ${LOGfile}  
      if [ ! -e ${infile} ]
	then
	  echo "ERROR - Missing input file: ${infile}" | tee -a ${LOGfile}
	  rm -f ${VARdir}/wlevel_temp.$$
	  #RemoveLockFile
	  export err=1; err_chk
      fi
      cat ${infile} >> ${VARdir}/wlevel_temp.$$
  done
  
  # Put the waterlevel file for each CG in the SWAN processing directory
  cat ${VARdir}/wlevel_temp.$$ > ${outfile}
  rm -f ${VARdir}/wlevel_temp.$$

  # Generate lines for INPUTCG files
  model_end_time=$model_start_time
  let secs=$FCSTLENGTH*3600
  let model_end_time+=$secs
  model_end_time_str=`echo ${model_end_time} | awk '{ print strftime("%Y%m%d.%H00", $1) }'`

  YYYYP=`echo ${psurge_end_time_str} | cut -b1-4`
  MMP=`echo ${psurge_end_time_str} | cut -b5-6`
  DDP=`echo ${psurge_end_time_str} | cut -b7-8`
  HHP=`echo ${psurge_end_time_str} | cut -b9-10`
  End_Time_str="${YYYYP}${MMP}${DDP}.${HHP}00"

  PsFile_End_Time="${RUNdir}/Psurge_End_Time"
  if [ -e ${PsFile_End_Time} ]
      then
      rm -f ${PsFile_End_Time}
  fi
  cat /dev/null > ${PsFile_End_Time}
  echo "${End_Time_str}" >> ${PsFile_End_Time}

  cat /dev/null > ${tmpfile}
  while read line; do
      echo "${line}" >> ${tmpfile}
      if [ "${line}" == "\$ WLEVEL STARTS HERE" ]
	 then
         #echo "INPGRID WLEV ${PSURGEDOMAIN} EXC -9999.000 NONSTAT ${YYYY}${MM}${DD}.${HH}00 ${PSURGETIMESTEP}.0 HR ${model_end_time_str}" >> ${tmpfile}

         echo "INPGRID WLEV ${PSURGEDOMAIN} EXC -9999.000 NONSTAT ${YYYY}${MM}${DD}.${HH}00 ${PSURGETIMESTEP}.0 HR ${psurge_end_time_str}" >> ${tmpfile}
         echo "READINP WLEV 1.0 '${YYYYMMDDHH}_${CG}_psurge.wlev' 3 0 0 FREE" >> ${tmpfile}
      fi
  done < ${inputCG}

  cat ${tmpfile} > ${inputCG}
  rm -f ${tmpfile}
done

echo "Processing complete" | tee -a ${LOGfile}

cd ${myPWD}
echo "Exiting..." | tee -a ${LOGfile}
#RemoveLockFile

exit 0
# -----------------------------------------------------------
# *******************************
# ********* End of File *********
# *******************************

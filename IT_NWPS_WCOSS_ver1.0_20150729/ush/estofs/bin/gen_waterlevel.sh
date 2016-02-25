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
# Version control: 1.15
#
# Support Team:
#
# Contributors: Roberto.Padilla@noaa.gov
# -----------------------------------------------------------
# ------------- Program Description and Details -------------
# -----------------------------------------------------------
#
# Script used to create water level files for SWAN
# using hi-res ESTOFS data.
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
BINdir="${USHnwps}/estofs/bin"
LOGfile="${LOGdir}/gen_waterlevel.log"

# Set our data processing directory
LDMdir="${LDMdir}/estofs"
INPUTdir="${INPUTdir}/estofs"

# Set our locking variables
PROGRAMname="$0"
LOCKfile="$VARdir/gen_waterlevel.lck"
MINold="30"

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

#CreateLockFile

echo $$ > /${TMPdir}/${USERNAME}/nwps/8889_gen_waterlevel_sh.pid

myPWD=`pwd`

if [ ! -e ${INPUTdir}/estofs_waterlevel_start_time.txt ] || [ ! -e ${INPUTdir}/estofs_waterlevel_domain.txt ]
    then
    echo "INFO - No ESTOFS data to process" | tee -a ${LOGfile}
    echo "INFO - Will try to copy files from ${LDMdir}" | tee -a ${LOGfile}
    if [ ! -e ${LDMdir}/estofs_waterlevel_start_time.txt ]
    then
    echo "ERROR - No ESTOFS data to process" | tee -a ${LOGfile}
    echo "ERROR - Missing ESTOFS start time file ${LDMdir}/estofs_waterlevel_start_time.txt" | tee -a ${LOGfile}
    #RemoveLockFile
    export err=1; err_chk
    fi
    rsync -av --force --stats --progress ${LDMdir}/*waterlevel* ${INPUTdir}/.
fi


input_dir_start=$(cat ${INPUTdir}/estofs_waterlevel_start_time.txt)

if [ -e ${LDMdir}/estofs_waterlevel_start_time.txt ]
    then 
    ingest_dir_start=$(cat ${LDMdir}/estofs_waterlevel_start_time.txt)

    cd ${LDMdir}
    ingest_filehours=$(ls -1rat --color=none *.dat)
    cd ${INPUTdir} 
    input_filehours=$(ls -1rat --color=none *.dat)
    
    for h in ${ingest_filehours} 
    do 
	ingest_lasthour=$(echo "${h}" | awk -F_ '{ print $7 }' | sed s/.dat//g | sed s/f//g) 
    done
    
    for h in ${input_filehours} 
    do 
	input_lasthour=$(echo "${h}" | awk -F_ '{ print $7 }' | sed s/.dat//g | sed s/f//g) 
    done
    
    if [ $ingest_dir_start -gt $input_dir_start ] || [ $ingest_lasthour -gt $input_lasthour ]
    then
	echo "INFO - New ESTOFS data to process in ingest DIR" | tee -a ${LOGfile}
	echo "INFO - Will copy files from ${LDMdir}" | tee -a ${LOGfile}
	rsync -av --force --stats --progress ${LDMdir}/*waterlevel* ${INPUTdir}/.
    fi

    if [ ! -e ${INPUTdir}/estofs_waterlevel_start_time.txt ]
    then
	echo "ERROR - No ESTOFS data to process" | tee -a ${LOGfile}
	echo "ERROR - Missing ESTOFS start time file ${INPUTdir}/estofs_waterlevel_start_time.txt" | tee -a ${LOGfile}
	#RemoveLockFile
	export err=1; err_chk
    fi
fi

if [ ! -e ${INPUTdir}/estofs_waterlevel_domain.txt ]
then 
    echo "ERROR - No domain info found with this data set"
    echo "ERROR - Missing ${INPUTdir}/estofs_waterlevel_domain.txt"
    #RemoveLockFile
    export err=1; err_chk
fi

# This file must contain a line in the following format
# ESTOFSDOMAIN:LON LAT NX NY EW-RESOLUTION NS-RESOLUTION 
# for example:
#
# ESTOFSDOMAIN:254.97 16.5 0. 1001 670 0.05000 0.050000"
#
ESTOFSDOMAIN=$(grep ^ESTOFSDOMAIN ${INPUTdir}/estofs_waterlevel_domain.txt | awk -F: '{ print $2 }')
cd ${LDMdir}

echo "INFO - Checking ${LDMdir} for updates" | tee -a ${LOGfile}
diff ${INPUTdir}/estofs_waterlevel_start_time.txt ${LDMdir}/estofs_waterlevel_start_time.txt
if [ "$?" == "0" ]
then
    echo "INFO - We have no more forecast hours to add to this data set" | tee -a ${LOGfile}
fi

cd ${myPWD}
#Don't clean, we can have Psurge files already
#echo "Cleaning up any previous ${RUNdir}/*.wlev files" | tee -a ${LOGfile}
#files=`ls -1rat ${RUNdir}/*.wlev`
#for file in ${files}
#  do
#  echo "Removing ${file}" | tee -a ${LOGfile}
#  # NOTE: The RM command does not like globbing with an underscore in the
#  # NOTE: file name in our SHELL env. So we will delete the files one by one.
#  rm -f ${file}
#done

echo "Purging any old model ingest" | tee -a ${LOGfile}
last_hour="${ESTOFSHOURS}"
${BINdir}/purge_estofs.sh ${INPUTdir} ${last_hour}

estofs_waterlevel_start_time=`cat ${INPUTdir}/estofs_waterlevel_start_time.txt`
estofs_date_str=`echo ${estofs_waterlevel_start_time} | awk '{ print strftime("%Y%m%d", $1) }'`
estofs_model_cycle=`echo ${estofs_waterlevel_start_time} | awk '{ print strftime("%H", $1) }'`
if [ "$1" != "" ]
    then 
    YYYYMMDDHH=${1}
else
    YYYYMMDDHH=`echo ${estofs_waterlevel_start_time} | awk '{ print strftime("%Y%m%d%H", $1) }'`
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

echo "ESTOFS start UNIX time: ${estofs_waterlevel_start_time}" | tee -a ${LOGfile}
echo "Model start UNIX time: ${model_start_time}" | tee -a ${LOGfile}

# Calculate our start time for the ESTOFS data set
# Start with the SWAN RUN time input by the user
start=$model_start_time
# Subtract the ESTOFS start time and convert seconds to hours
let start-=estofs_waterlevel_start_time
let start/=3600
  if [ $start -le 0 ]
      then
      start=0
  fi

# Lets clean the waterlevel data from all inputCG files
SWANPARMS=`perl -I${PMnwps} -I${RUNdir} ${BINdir}/estofs_match.pl`
for parm in ${SWANPARMS}
  do
  CG=`echo ${parm} | awk -F, '{ print $1 }'`
  inputCG="${RUNdir}/input${CG}"

  echo "Removing any old water level lines from ${inputCG}" | tee -a ${LOGfile}
  Psurge_End_Time="${RUNdir}/Psurge_End_Time"
  if [ ! -e ${Psurge_End_Time} ]
     then
     if [ ! -e ${inputCG} ]
        then
        echo "ERROR - Missing input file: ${inputCG}" | tee -a ${LOGfile}
     else
        tmpfile="${VARdir}/input${CG}.$$"
        grep -v "INPGRID WLEV " ${inputCG} > ${tmpfile} 
        grep -v "READINP WLEV " ${tmpfile} > ${inputCG} 
        rm -f ${tmpfile}
     fi
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
SWANPARMS=`perl -I${PMnwps} -I${RUNdir} ${BINdir}/estofs_match.pl`
FCSTLENGTH=`echo ${parm} | awk -F, '{ print $3 }'`
lencheck=$FCSTLENGTH
let lencheck*=3600
timecheck=model_start_time
let timecheck-=estofs_waterlevel_start_time

# Max hours old our waterlevel data can be
maxage=60
let maxage*=3600

if [ $timecheck -gt $maxage ]
    then
    echo "WARNING: ESTOFS data is too old - check the ESTOFS download from NCEP" | tee -a ${LOGfile}
    echo "WARNING The NWPS run will not include any ESTOFS water level variation" | tee -a ${LOGfile}

    echo "WARNING: ESTOFS data is too old or absent. Run will not include any ESTOFS water level variation" | tee -a ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt
    msg="WARNING: ESTOFS data is too old or absent. Run will not include any ESTOFS water level variation."
    postmsg "$jlogfile" "$msg"
   
    # Alert the forecasters that the forecast length was truncated
    echo "Sending alert message to the forecasters"  | tee -a ${LOGfile}
    SendAWIPSMessage ${VARdir} "ESTOFS DATA IS TOO OLD" \
	"HAVE IT OR SOO CHECK THE ESTOFS DOWNLOAD FROM LDM or from NCEP" \
	"THE SWAN WILL NOT INCLUDE ANY WATER LEVEL INTERACTION" | tee -a ${LOGfile} 2>&1
    #RemoveLockFile
    #export err=1; err_chk
    touch ${RUNdir}/noestofs
    #Non-fatal exit
    exit 0
fi

maxhours="${ESTOFSHOURS}"
let maxhours*=3600
let maxhours-=timecheck

if [ $lencheck -gt $maxhours ]
    then 
    echo "WARNING: The forecast length has exceeded the max hours of waterlevel data" | tee -a ${LOGfile}
    lencheck=$maxhours
    let lencheck/=3600
    echo "WARNING: Truncating the forecast length from $FCSTLENGTH to $lencheck" | tee -a ${LOGfile}
    let lencheck*=3600

    #########XXX FCSTLENGTH=`echo $lencheck`
   # echo "WARNING - THIS NOT THE CASE ANYMORE FCSTLENGTH = ${FCSTLENGTH} " | tee -a ${LOGfile}
    #echo "Changing the forecast length in ${RUNdir}/ConfigSwan.pm to match the current data" | tee -a ${LOGfile}

    #export RUNLEN=`grep "use constant SWANFCSTLENGTH =>" ${RUNdir}/ConfigSwan.pm`
    #sed -i s/"$RUNLEN"/"use constant SWANFCSTLENGTH => '${FCSTLENGTH}';"/g ${RUNdir}/ConfigSwan.pm
    
      # Alert the forecasters that the forecast length was truncated
    #echo "Sending alert message to the forecasters"  | tee -a ${LOGfile}
#    SendAWIPSMessage ${VARdir} "THE FORECAST LENGTH HAS EXCEEDED THE MAX HOURS OF WATERLEVEL DATA" \
#	"TRUNCATING THE FORECAST LENGTH FROM $FCSTLENGTH TO $lencheck" | tee -a ${LOGfile} 2>&1
    #"THE FORECAST LENGTH HAS EXCEEDED THE MAX HOURS OF WATERLEVEL DATA" | tee -a ${LOGfile} 2>&1
#echo "RUNLEN ${FCSTLENGTH} exceeded the max hours of  data $lencheck " | tee -a ${RUNdir}/Warn_Forecaster.txt

    echo "WARNING: Run length of ${FCSTLENGTH} h exceeds the max hours of available ESTOFS water level data. No water level variations will be included after ${lencheck} h." | tee -a ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt
    msg="WARNING: Run length of ${FCSTLENGTH} h exceeds the max hours of available ESTOFS water level data. No water level variations will be included after ${lencheck} h."
    postmsg "$jlogfile" "$msg"
fi

# Generate the waterlevel data for SWAN and update all inputCG files
SWANPARMS=`perl -I${PMnwps} -I${RUNdir} ${BINdir}/estofs_match.pl`
for parm in ${SWANPARMS}
  do
  echo "Processing SWAN parameters: ${parm}" | tee -a ${LOGfile}
  CG=`echo ${parm} | awk -F, '{ print $1 }'`
  TIMESTEP=`echo ${parm} | awk -F, '{ print $2 }'`
  # Rather use the ESTOFSTIMESTEP set in nwps_config.sh
  TIMESTEP=${ESTOFSTIMESTEP}
  FCSTLENGTH=`echo ${parm} | awk -F, '{ print $3 }'`
  echo "CG=${CG} TIMESTEP=${TIMESTEP} FCSTLENGTH=${FCSTLENGTH}" | tee -a ${LOGfile}

  inputCG="${RUNdir}/input${CG}"
  if [ ! -e ${inputCG} ]
      then
      echo "ERROR - Missing input file: ${inputCG}" | tee -a ${LOGfile}
      #RemoveLockFile
      export err=1; err_chk
  fi

  end=0
  let t0=start
  outfile="${RUNdir}/${YYYYMMDDHH}_${CG}.wlev"
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

  infile="${INPUTdir}/wave_estofs_waterlevel_${estofs_waterlevel_start_time}_${estofs_date_str}_${estofs_model_cycle}_f${FF}.dat"
  echo "SWAN input file for $t0: ${infile}" | tee -a ${LOGfile}
  if [ ! -s ${infile} ]
  then
      echo "ERROR - Missing input file: ${infile}" | tee -a ${LOGfile}
      #RemoveLockFile
      #export err=1; err_chk
      echo "WARNING: Missing input file: ${infile}. Omitting water level variations for this run." | tee -a ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt
      msg="WARNING: Missing input file: ${infile}. Omitting water level variations for this run."
      postmsg "$jlogfile" "$msg"
      exit 0
  fi
  cat ${infile} > ${VARdir}/wlevel_temp.$$

  until [ $end -ge $FCSTLENGTH ]; do
      let end+=$TIMESTEP
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

      infile="${INPUTdir}/wave_estofs_waterlevel_${estofs_waterlevel_start_time}_${estofs_date_str}_${estofs_model_cycle}_f${FF}.dat"
      echo "SWAN input file for $tstep: ${infile}" | tee -a ${LOGfile}  
      if [ ! -s ${infile} ]
	then
	  echo "ERROR - Missing input file: ${infile}" | tee -a ${LOGfile}
	  rm -f ${VARdir}/wlevel_temp.$$
	  #RemoveLockFile
	  #export err=1; err_chk
          echo "WARNING: Missing input file: ${infile}. Omitting water level variations for this run." | tee -a ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt
          msg="WARNING: Missing input file: ${infile}. Omitting water level variations for this run."
          postmsg "$jlogfile" "$msg"
          exit 0
      fi
      cat ${infile} >> ${VARdir}/wlevel_temp.$$
  done
  
  # Put the waterlevel file for each CG in the SWAN processing directory
  cat ${VARdir}/wlevel_temp.$$ > ${outfile}
  rm -f ${VARdir}/wlevel_temp.$$

  # Generate lines for INPUTCG files
  model_end_time=$model_start_time
#  let secs=$FCSTLENGTH*3600
  let secs=$lencheck
  let model_end_time+=$secs
  model_end_time_str=`echo ${model_end_time} | awk '{ print strftime("%Y%m%d.%H00", $1) }'`

  Psurge_End_Time="${RUNdir}/Psurge_End_Time"

  if [ ! -e ${Psurge_End_Time} ]
     then
     cat /dev/null > ${tmpfile}
     while read line; do
        echo "${line}" >> ${tmpfile}
        if [ "${line}" == "\$ WLEVEL STARTS HERE" ]
        then
	  echo "INPGRID WLEV ${ESTOFSDOMAIN} NONSTAT ${YYYY}${MM}${DD}.${HH}00 ${TIMESTEP}.0 HR ${model_end_time_str}" >> ${tmpfile}
	  echo "READINP WLEV 1.0 '${YYYYMMDDHH}_${CG}.wlev' 3 0 FREE" >> ${tmpfile}
        fi
     done < ${inputCG}

     cat ${tmpfile} > ${inputCG}
     rm -f ${tmpfile}
  else 
     Estofs_Lines="${RUNdir}/Estofs_Linesinput${CG}"
     if [ -e ${Estofs_Lines} ]
     then
        rm -f ${Estofs_Lines}
     fi
     cat /dev/null > ${Estofs_Lines}
     echo  "INPGRID WLEV ${ESTOFSDOMAIN} NONSTAT ${YYYY}${MM}${DD}.${HH}00 ${TIMESTEP}.0 HR ${model_end_time_str}" >> ${Estofs_Lines}
     echo "READINP WLEV 1.0 '${YYYYMMDDHH}_${CG}.wlev' 3 0 FREE" >> ${Estofs_Lines}
  fi
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

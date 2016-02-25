#!/bin/bash
set -xa
# -----------------------------------------------------------
# UNIX Shell Script
# Tested Operating System(s): RHEL 5
# Tested Run Level(s): 3, 5, 6
# Shell Used: BASH shell
# Original Author(s): Douglas.Gaer@noaa.gov
# File Creation Date: 09/29/2009
# Date Last Modified: 07/29/2014
#
# Version control: 1.38
#
# Support Team:
#
# Contributors:
# -----------------------------------------------------------
# ------------- Program Description and Details -------------
# -----------------------------------------------------------
#
# Script used to create current files for SWAN
# using hi-res RTOFS data.
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
#source ${USHnwps}/ush/bin/alert_messages.sh

# Script variables
# ===========================================================
BINdir="${USHnwps}/rtofs/bin"
LOGfile="${LOGdir}/gen_current.log"

# Set our data processing DIRS
LDMdir="${LDMdir}/rtofs"
INPUTdir="${INPUTdir}/rtofs"

# Set our locking variables
PROGRAMname="$0"
LOCKfile="$VARdir/gen_current.lck"
MINold="15"

#source ${USHnwps}/process_lock.sh

# Make any of the following directories if needed
mkdir -p ${INPUTdir}
mkdir -p ${VARdir}
mkdir -p ${LOGdir}

cat /dev/null > ${LOGfile}

echo "Generating current files for NWPS model" | tee -a ${LOGfile}
#echo "Checking for lock files" | tee -a ${LOGfile}
#LockFileCheck $MINold

datetime=`date -u`
echo "Starting processing at at $datetime UTC" | tee -a ${LOGfile}

##CreateLockFile

echo $$ > /${TMPdir}/${USERNAME}/nwps/8890_gen_current_sh.pid

myPWD=`pwd`

if [ ! -e ${INPUTdir}/rtofs_current_start_time.txt ] || [ ! -e ${INPUTdir}/rtofs_current_domain.txt ]
    then
    echo "INFO - No RTOFS data to process in ${INPUTdir}" | tee -a ${LOGfile}
    echo "INFO - Will try to copy files from ${LDMdir}" | tee -a ${LOGfile}
    rsync -av --force --stats --progress ${LDMdir}/*rtofs_current* ${INPUTdir}/.
    rsync -av --force --stats --progress ${LDMdir}/*_rtofs_uv* ${INPUTdir}/.
fi

if [ ! -e ${INPUTdir}/rtofs_current_start_time.txt ]
    then
    echo "ERROR - No RTOFS data to process" | tee -a ${LOGfile}
    echo "ERROR - Missing RTOF start time file ${INPUTdir}/rtofs_current_start_time.txt" | tee -a ${LOGfile}
    ##RemoveLockFile
    export err=1; err_chk
fi

input_dir_start=$(cat ${INPUTdir}/rtofs_current_start_time.txt)

if [ -e ${LDMdir}/rtofs_current_start_time.txt ]
    then 
    ingest_dir_start=$(cat ${LDMdir}/rtofs_current_start_time.txt)
    
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
	echo "INFO - New RTOFS data to process in ingest DIR" | tee -a ${LOGfile}
	echo "INFO - Will copy files from ${LDMdir}" | tee -a ${LOGfile}
	rsync -av --force --stats --progress ${LDMdir}/*rtofs_current* ${INPUTdir}/.
	rsync -av --force --stats --progress ${LDMdir}/*_rtofs_uv* ${INPUTdir}/.
    fi
    
    if [ ! -e ${INPUTdir}/rtofs_current_domain.txt ]
    then 
	echo "ERROR - No domain info found with this data set"
	echo "ERROR - Missing ${INPUTdir}/rtofs_current_domain.txt"
	##RemoveLockFile
	export err=1; err_chk
    fi
fi

# This file must contain a line in the following format
# RTOFSDOMAIN:LON LAT NX NY EW-RESOLUTION NS-RESOLUTION 
# for example:
#
# RTOFSDOMAIN:254.97 16.5 0. 1001 670 0.05000 0.050000"
#
RTOFSDOMAIN=$(grep ^RTOFSDOMAIN ${INPUTdir}/rtofs_current_domain.txt | awk -F: '{ print $2 }')

cd ${myPWD}

echo "Cleaning up any previous ${RUNdir}/*.cur files" | tee -a ${LOGfile}
files=`ls -1rat ${RUNdir}/*.cur`
for file in ${files}
  do
  echo "Removing ${file}" | tee -a ${LOGfile}
  # NOTE: The RM command does not like globbing with an underscore in the
  # NOTE: file name in our SHELL env. So we will delete the files one by one.
  rm -f ${file}
done

echo "Purging any old model ingest" | tee -a ${LOGfile}
last_hour="${RTOFSHOURS}"
${BINdir}/purge_rtofs.sh  ${INPUTdir} ${last_hour}

rtofs_current_start_time=`cat ${INPUTdir}/rtofs_current_start_time.txt`
rtofs_date_str=`echo ${rtofs_current_start_time} | awk '{ print strftime("%Y%m%d", $1) }'`
# We only have the 00z cycle for all NCEP production runs
## rtofs_model_cycle=`echo ${rtofs_current_start_time} | awk '{ print strftime("%H", $1) }'`
rtofs_model_cycle="00"

if [ "$1" != "" ]
    then 
    YYYYMMDDHH=${1}
else
    YYYYMMDDHH=`echo ${rtofs_current_start_time} | awk '{ print strftime("%Y%m%d%H", $1) }'`
fi

PROCESS_CURRENT="TRUE"
if [ "$2" != "" ]
    then
    if [ "$2" == "No" ]; then PROCESS_CURRENT="FALSE"; fi
fi

echo "Our YYYYMMDDHH is ${YYYYMMDDHH}" | tee -a ${LOGfile}

YYYY=`echo ${YYYYMMDDHH} | cut -b1-4`
MM=`echo ${YYYYMMDDHH} | cut -b5-6`
DD=`echo ${YYYYMMDDHH} | cut -b7-8`
HH=`echo ${YYYYMMDDHH} | cut -b9-10`

time_str="${YYYY} ${MM} ${DD} ${HH} 00 00"
model_start_time=`echo ${time_str} | awk -F: '{ print mktime($1 $2 $3 $4 $5 $6) }'`

echo "RTOFS start UNIX time: ${rtofs_current_start_time}" | tee -a ${LOGfile}
echo "Model start UNIX time: ${model_start_time}" | tee -a ${LOGfile}

# Calculate our start time for the RTOFS data set
# Start with the SWAN RUN time input by the user
start=$model_start_time
# Subtract the RTOFS start time and convert seconds to hours
let start-=rtofs_current_start_time
let start/=3600

# Lets clean the current data from all inputCG files
SWANPARMS=`perl -I${PMnwps} -I${RUNdir} ${BINdir}/rtofs_match.pl`
for parm in ${SWANPARMS}
  do
  CG=`echo ${parm} | awk -F, '{ print $1 }'`
  inputCG="${RUNdir}/input${CG}"

  echo "Removing any old current lines from ${inputCG}" | tee -a ${LOGfile}
  if [ ! -e ${inputCG} ]
      then
      echo "ERROR - Missing input file: ${inputCG}" | tee -a ${LOGfile}
  else
      tmpfile="${VARdir}/input${CG}.$$"
      grep -v "INPGRID CUR " ${inputCG} > ${tmpfile} 
      grep -v "READINP CUR " ${tmpfile} > ${inputCG} 
      rm -f ${tmpfile}
  fi
done

if [ "${PROCESS_CURRENT}"  == "FALSE" ]
    then 
    echo "WARNING - The caller of this script has disabled current data" | tee -a ${LOGfile}
    echo "WARNING - Argument 2 is set: ${2}" | tee -a ${LOGfile}
    echo "WARNING - To enable again re-run without argument 2 set to NO" | tee -a ${LOGfile}
    echo "WARNING - This SWAN run will not have any current interaction" | tee -a ${LOGfile}
    ##RemoveLockFile
    export err=1; err_chk
fi

# Lets check our forecast length and compare it against the hours we have for 
# the current data. If the forecaster has exceeded the number number of hours
# we will truncate the forecast hours to match the current data.
SWANPARMS=`perl -I${PMnwps} -I${RUNdir} ${BINdir}/rtofs_match.pl`
FCSTLENGTH=`echo ${parm} | awk -F, '{ print $3 }'`
lencheck=$FCSTLENGTH
let lencheck*=3600
timecheck=model_start_time
let timecheck-=rtofs_current_start_time

# Max hours old our current data can be
maxage=60
let maxage*=3600

if [ $timecheck -gt $maxage ]
    then
    echo "WARNING: RTOFS data is too old - check the RTOFS download from NCEP" | tee -a ${LOGfile}
    echo "WARNING: The SWAN will not include any current interaction" | tee -a ${LOGfile}

    echo "WARNING: RTOFS data is too old or absent. Run will not include any RTOFS surface currents." | tee -a ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt
    msg="WARNING: RTOFS data is too old or absent. Run will not include any RTOFS surface currents."
    postmsg "$jlogfile" "$msg"
    
    # Alert the forecasters that the forecast length was truncated
    echo "Sending alert message to the forecasters"  | tee -a ${LOGfile}
    SendAWIPSMessage ${VARdir} "RTOFS DATA IS TOO OLD" \
	"HAVE IT OR SOO CHECK THE RTOFS DOWNLOAD FROM LDM OR NCEP" \
	"THE SWAN WILL NOT INCLUDE ANY CURRENT INTERACTION" | tee -a ${LOGfile} 2>&1
    ##RemoveLockFile
    #export err=1; err_chk
    touch ${RUNdir}/nortofs
    #Non-fatal exit
    exit 0
fi

maxhours=140
let maxhours*=3600
let maxhours-=timecheck
if [ $lencheck -gt $maxhours ]
    then 
    echo "WARNING - The forecast length has exceeded the max hours of RTOFS current data" | tee -a ${LOGfile}
    lencheck=$maxhours
    let lencheck/=3600
    echo "WARNING - Truncating the forecast length from $FCSTLENGTH to $lencheck" | tee -a ${LOGfile}
    echo "WARNING - THIS NOT THE CASE ANYMORE FCSTLENGTH = ${FCSTLENGTH} " | tee -a ${LOGfile}
    #echo "Changing the forecast length in ${RUNdir}/ConfigSwan.pm to match the current data" | tee -a ${LOGfile}

    echo "WARNING: Run length of ${FCSTLENGTH} h exceeds the max hours of available RTOFS current data. Persistence will be applied after $lencheck h." | tee -a ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt
    msg="WARNING: Run length of ${FCSTLENGTH} h exceeds the max hours of available RTOFS current data. Persistence will be applied after $lencheck h."
    postmsg "$jlogfile" "$msg"
    let lencheck*=3600
    # FCSTLENGTH=`echo $lencheck`
    export RUNLEN=`grep "use constant SWANFCSTLENGTH =>" ${RUNdir}/ConfigSwan.pm`
    sed -i s/"$RUNLEN"/"use constant SWANFCSTLENGTH => '${FCSTLENGTH}';"/g ${RUNdir}/ConfigSwan.pm
    
      # Alert the forecasters that the forecast length exceed hours of current data
      #echo "Sending alert message to the forecasters"  | tee -a ${LOGfile}
      #SendAWIPSMessage ${VARdir} "THE FORECAST LENGTH HAS EXCEEDED THE MAX HOURS OF CURRENT DATA" \
      #" " | tee -a ${LOGfile} 2>&1
fi

# Generate the current data for SWAN and update all inputCG files
SWANPARMS=`perl -I${PMnwps} -I${RUNdir} ${BINdir}/rtofs_match.pl`
for parm in ${SWANPARMS}
  do
  echo "Processing SWAM parameters: ${parm}" | tee -a ${LOGfile}
  CG=`echo ${parm} | awk -F, '{ print $1 }'`
  TIMESTEP=`echo ${parm} | awk -F, '{ print $2 }'`
  FCSTLENGTH=`echo ${parm} | awk -F, '{ print $3 }'`
  echo "CG=${CG} TIMESTEP=${TIMESTEP} FCSTLENGTH=${FCSTLENGTH}" | tee -a ${LOGfile}

  inputCG="${RUNdir}/input${CG}"
  if [ ! -e ${inputCG} ]
      then
      echo "ERROR - Missing input file: ${inputCG}" | tee -a ${LOGfile}
      ##RemoveLockFile
      export err=1; err_chk
  fi

  # Check our time step compared to our init time
  ADJTIME="FALSE"
  if [ $HH -gt 0 ]
  then
      HHnum=$(echo $HH | sed 's/0*//')
      mod=$(($HHnum % $RTOFSTIMESTEP))
      if [ $mod -ne 0 ]
      then
	  echo "We have a $TIMESTEP timestep starting on $HH hour" | tee -a ${LOGfile}
	  echo "Need to adjust our model start time to match our RTOFS timestep of $RTOFSTIMESTEP" | tee -a ${LOGfile}
	  ADJTIME="TRUE"
	  if [ $mod -le 1 ]
	  then
	      let newHH=$HHnum-1 
	  elif [ $mod -eq 2 ] && [ $RTOFSTIMESTEP -eq 3 ] 
	  then
	      let newHH=$HHnum+1
	  else
	      let newTS=$RTOFSTIMESTEP-$mod
	      let newHH=$HHnum+$newTS
	  fi
	  if [ $newHH -gt 24 ]; then let newHH=24; fi
	  
	  if [ $newHH -le 9 ]
	  then
	      HH="0${newHH}"
	  else
	      HH="${newHH}"
	  fi
	  echo "Our new start hour is ${HH}"
	  YYYYMMDDHH="${YYYY}${MM}${DD}${HH}"
      fi
  fi
  
  if [ "${ADJTIME}" == "TRUE" ]
  then
      echo "Our model start time is ${YYYYMMDDHH}" | tee -a ${LOGfile}
      time_str="${YYYY} ${MM} ${DD} ${HH} 00 00"
      model_start_time=`echo ${time_str} | awk -F: '{ print mktime($1 $2 $3 $4 $5 $6) }'`
      start=$model_start_time
      let start-=rtofs_current_start_time
      let start/=3600
  fi
  
  end=0
  let t0=start
  outfile="${RUNdir}/${YYYYMMDDHH}_${CG}.cur"
  echo "SWAN current file: ${outfile}" | tee -a ${LOGfile}

  FF=`echo $t0`
  if [ $t0 -le 99 ]
      then
      FF=`echo 0$t0`
  fi
  if [ $t0 -le 9 ]
      then
      FF=`echo 00$t0`
  fi

  infile="${INPUTdir}/wave_rtofs_uv_${rtofs_current_start_time}_${rtofs_date_str}_${rtofs_model_cycle}_f${FF}.dat"
  echo "SWAN input file for $t0: ${infile}" | tee -a ${LOGfile}
  if [ ! -s ${infile} ]
  then
      echo "ERROR - Missing input file: ${infile}" | tee -a ${LOGfile}
      ##RemoveLockFile
      #export err=1; err_chk
      echo "WARNING: Missing input file: ${infile}. Omitting surface currents for this run." | tee -a ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt
      msg="WARNING: Missing input file: ${infile}. Omitting surface currents for this run."
      postmsg "$jlogfile" "$msg"
      exit 0
  fi
  cat ${infile} > ${VARdir}/curr_temp.$$

  until [ $end -ge $FCSTLENGTH ]; do
      let end+=$RTOFSTIMESTEP
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

      infile="${INPUTdir}/wave_rtofs_uv_${rtofs_current_start_time}_${rtofs_date_str}_${rtofs_model_cycle}_f${FF}.dat"
      echo "SWAN input file for $tstep: ${infile}" | tee -a ${LOGfile}  
      if [ ! -s ${infile} ]
      then
	  echo "ERROR - Missing input file: ${infile}" | tee -a ${LOGfile}
	  rm -f ${VARdir}/curr_temp.$$
	  ##RemoveLockFile
	  #export err=1; err_chk
          echo "WARNING: Missing input file: ${infile}. Omitting surface currents for this run." | tee -a ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt
          msg="WARNING: Missing input file: ${infile}. Omitting surface currents for this run."
          postmsg "$jlogfile" "$msg"
          exit 0
      fi
      cat ${infile} >> ${VARdir}/curr_temp.$$
  done
  
  # Put the current file for each CG in the SWAN processing directory
  cat ${VARdir}/curr_temp.$$ > ${outfile}
  rm -f ${VARdir}/curr_temp.$$

  # Generate lines for INPUTCG files
  model_end_time=$model_start_time
#
# let secs=${FCSTLENGTH}*3600
 let secs=$lencheck
#
  let model_end_time+=$secs
  model_end_time_str=`echo ${model_end_time} | awk '{ print strftime("%Y%m%d.%H00", $1) }'`

  cat /dev/null > ${tmpfile}
  while read line; do
      echo "${line}" >> ${tmpfile}
      if [ "${line}" == "\$ CURR STARTS HERE" ]
	  then
	  echo "INPGRID CUR ${RTOFSDOMAIN} NONSTAT ${YYYY}${MM}${DD}.${HH}00 ${RTOFSTIMESTEP}.0 HR ${model_end_time_str}" >> ${tmpfile}
	  echo "READINP CUR 1.0 '${YYYYMMDDHH}_${CG}.cur' 3 0 0 0 FREE" >> ${tmpfile}
      fi
  done < ${inputCG}

  cat ${tmpfile} > ${inputCG}
  rm -f ${tmpfile}
done

echo "Processing complete" | tee -a ${LOGfile}

cd ${myPWD}
echo "Exiting..." | tee -a ${LOGfile}
##RemoveLockFile

exit 0
# -----------------------------------------------------------
# *******************************
# ********* End of File *********
# *******************************

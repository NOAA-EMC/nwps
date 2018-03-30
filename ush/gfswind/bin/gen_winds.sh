#!/bin/bash
# -----------------------------------------------------------
# UNIX Shell Script
# Tested Operating System(s): RHEL 5, 6, 7
# Tested Run Level(s): 3, 5
# Shell Used: BASH shell
# Original Author(s): Douglas.Gaer@noaa.gov
# File Creation Date: 01/17/2013
# Date Last Modified: 12/05/2016
#
# Version control: 1.11
#
# Support Team:
#
# Contributors:
# -----------------------------------------------------------
# ------------- Program Description and Details -------------
# -----------------------------------------------------------
#
# Script used to create wind files for SWAN
# using GFS data.
#
# WCOSS version
# -----------------------------------------------------------

# Check to see if our SITEID is set
if [ "${SITEID}" == "" ]
    then
    echo "ERROR - Your SITEID variable is not set"
    export err=1; err_chk
    exit 1
fi

if [ "${USHnwps}" == "" ]
    then 
    echo "ERROR - Your USHnwps variable is not set"
    export err=1; err_chk
    exit 1
fi

if [ -e ${USHnwps}/nwps_config.sh ]
then
    source ${USHnwps}/nwps_config.sh
else
    echo "ERROR - Cannot find ${USHnwps}/nwps_config.sh"
    export err=1; err_chk
    exit 1
fi

# NOTE: Data is processed on the server in UTC
export TZ="UTC"

# Script variables
# ===========================================================
BINdir="${USHnwps}/gfswind/bin"
LOGfile="${LOGdir}/gen_gfswind.log"

# Set our data processing directory
LDMdir="${LDMdir}/gfswind"
WINDINFODIR="${INPUTdir}"
INPUTdir="${INPUTdir}/gfswind"
RSYNC="/usr/bin/rsync"
RSYNCargs="-av --force --stats --progress"

# Make any of the following directories if needed
mkdir -p ${INPUTdir}
mkdir -p ${VARdir}
mkdir -p ${LOGdir}
mkdir -p ${WINDINFODIR}/wind

cat /dev/null > ${LOGfile}

echo "Generating wind files for NWPS model" | tee -a ${LOGfile}

datetime=`date -u`
echo "Starting processing at at $datetime UTC" | tee -a ${LOGfile}

myPWD=`pwd`
if [ ! -e ${INPUTdir}/gfswind_start_time.txt ]
    then
    echo "INFO - No GFSWIND data to process" | tee -a ${LOGfile}
    echo "INFO - Will copy files from ${LDMdir}" | tee -a ${LOGfile}
    ${RSYNC} ${RSYNCargs} --delete ${LDMdir}/*wind* ${INPUTdir}/.
fi

ingest_dir_start=$(cat ${LDMdir}/gfswind_start_time.txt)
input_dir_start=$(cat ${INPUTdir}/gfswind_start_time.txt)

cd ${LDMdir}
ingest_filehours=$(ls -1rat --color=none *.dat)
cd ${INPUTdir} 
input_filehours=$(ls -1rat --color=none *.dat)

for h in ${ingest_filehours} 
do 
    ingest_lasthour=$(echo "${h}" | awk -F_ '{ print $5 }' | sed s/.dat//g | sed s/f//g) 
done

for h in ${input_filehours} 
do 
    input_lasthour=$(echo "${h}" | awk -F_ '{ print $5 }' | sed s/.dat//g | sed s/f//g) 
done

if [ $ingest_dir_start -gt $input_dir_start ] || [ $ingest_lasthour -gt $input_lasthour ]
then
    echo "INFO - New GFSWIND data to process in ingest DIR" | tee -a ${LOGfile}
    echo "INFO - Will copy files from ${LDMdir}" | tee -a ${LOGfile}
    ${RSYNC} ${RSYNCargs} --delete ${LDMdir}/*wind* ${INPUTdir}/.
fi

if [ ! -e ${INPUTdir}/gfswind_start_time.txt ]
    then
    echo "ERROR - No GFSWIND data to process" | tee -a ${LOGfile}
    echo "ERROR - Missing GFSWIND start time file ${INPUTdir}/gfswind_start_time.txt" | tee -a ${LOGfile}
    export err=1; err_chk
    exit 1
fi

if [ ! -e ${INPUTdir}/gfswind_domain.txt ]
then 
    echo "ERROR - No domain info found with this data set"
    echo "ERROR - Missing ${INPUTdir}/gfswind_domain.txt"
    export err=1; err_chk
    exit 1
fi

# This file must contain a line in the following format
# GFSWINDDOMAIN:LON LAT NX NY EW-RESOLUTION NS-RESOLUTION 
# for example:
#
# GFSWINDDOMAIN:254.97 16.5 0. 1001 670 0.05000 0.050000"
#
GFSWINDDOMAIN=$(grep ^GFSWINDDOMAIN ${INPUTdir}/gfswind_domain.txt | awk -F: '{ print $2 }')

echo "Cleaning up any previous ${RUNdir}/*.wnd files" | tee -a ${LOGfile}
files=`ls -1rat ${RUNdir}/*.wnd`
if [ "$files" == "" ]; then
    echo "No wind files to remove"
else
    for file in ${files}
      do
      echo "Removing ${file}" | tee -a ${LOGfile}
      rm -f ${file}
    done
fi

if [ "${GFSHOURS}" == "" ]; then export GFSHOURS="192"; fi
echo "Purging any old model ingest" | tee -a ${LOGfile}
last_hour="${GFSHOURS}"
${BINdir}/purge_gfswind.sh ${INPUTdir} ${last_hour}

gfswind_start_time=`cat ${INPUTdir}/gfswind_start_time.txt`
gfswind_date_str=`echo ${gfswind_start_time} | awk '{ print strftime("%Y%m%d", $1) }'`
gfswind_model_cycle=`echo ${gfswind_start_time} | awk '{ print strftime("%H", $1) }'`

#AW # Default to our current date
#AW YYYYMMDDHH=$(date -u +%Y%m%d%H)

if [ "$1" != "" ]; then YYYYMMDDHH=${1}; fi
if [ "$1" == "--model" ]; then YYYYMMDDHH=$(echo ${gfswind_start_time} | awk '{ print strftime("%Y%m%d%H", $1) }'); fi

YYYY=$(echo $PDY|cut -c1-4)
MM=$(echo $PDY|cut -c5-6)
DD=$(echo $PDY|cut -c7-8)
#AW HH=`echo ${YYYYMMDDHH} | cut -b9-10`

#AW
# Use the HH on the GFE tarball as the analysis time of the failover run
NewestWind=$(basename $(ls -t ${VARdir}/gfe_grids_test/NWPSWINDGRID_${siteid}* | head -1))
if [ "$NewestWind" != "" ]; then
   HH=$(echo $NewestWind|cut -c26-27)
else
   HH=$(date -u +%H)
fi
YYYYMMDDHH="${YYYY}${MM}${DD}${HH}"
#AW

SWANPARMS=`perl -I${RUNdir} -I${PMnwps} ${BINdir}/gfswind_match.pl`
for parm in ${SWANPARMS}
do
    FCSTLENGTH=`echo ${parm} | awk -F, '{ print $3 }'`
    TIMESTEP=`echo ${parm} | awk -F, '{ print $2 }'`
    CG=`echo ${parm} | awk -F, '{ print $1 }'`
    if [ "${CG}" == 1 ] ; then break; fi
done

if [ -z ${FCSTLENGTH} ]; then FCSTLENGTH=${GFSHOURS}; fi
if [ -z ${TIMESTEP} ]; then TIMESTEP=${GFSTIMESTEP}; fi
if [ -z ${CG} ]; then CG=1; fi
 
echo "SWAN FCSTLENGTH = ${FCSTLENGTH}" | tee -a ${LOGfile}
echo "SWAN TIMESTEP = ${TIMESTEP}" | tee -a ${LOGfile}

# Check our time step compared to our init time
if [ $HH -gt 0 ]
then
    HHnum=$(echo $HH | sed 's/0*//')
    mod=$(($HHnum % $GFSTIMESTEP))
    if [ $mod -ne 0 ]
    then
	echo "We have a $TIMESTEP timestep starting on $HH hour" | tee -a ${LOGfile}
	echo "Need to adjust our model start time to match our GFS timestep of $GFSTIMESTEP" | tee -a ${LOGfile}
	if [ $mod -le 1 ]
	then
	    let newHH=$HHnum-1 
	elif [ $mod -eq 2 ] && [ $GFSTIMESTEP -eq 3 ] 
	then
	    let newHH=$HHnum+1
	else
	    let newTS=$GFSTIMESTEP-$mod
	    let newHH=$HHnum+$newTS
	fi
	if [ $newHH -ge 24 ]; then let newHH=21; fi
	
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

echo "Our model start time is ${YYYYMMDDHH}" | tee -a ${LOGfile}

time_str="${YYYY} ${MM} ${DD} ${HH} 00 00"
model_start_time=`echo ${time_str} | awk -F: '{ print mktime($1 $2 $3 $4 $5 $6) }'`

echo "GFS wind domain: ${GFSWINDDOMAIN}" | tee -a ${LOGfile}
echo "GFSWIND start UNIX time: ${gfswind_start_time}" | tee -a ${LOGfile}
echo "Model start UNIX time: ${model_start_time}" | tee -a ${LOGfile}

# Calculate our start time for the GFSWIND data set
# Start with the SWAN RUN time input by the user
start=$model_start_time
# Subtract the GFSWIND start time and convert seconds to hours
let start-=gfswind_start_time
let start/=3600

# Lets check our forecast length and compare it against the hours we have for 
# the wind data. If the forecaster has exceeded the number number of hours
# we will truncate the forecast hours to match the wind data.
lencheck=$FCSTLENGTH
let lencheck*=3600
timecheck=model_start_time
let timecheck-=gfswind_start_time

# Max hours old our wind data can be
maxage=60
let maxage*=3600

if [ $timecheck -gt $maxage ]
    then
    echo "ERROR - GFSWIND data is too old" | tee -a ${LOGfile}
    echo "ERROR - Check the GFSWIND download from NCEP" | tee -a ${LOGfile}
    echo "ERROR - The SWAN will fail due to no input winds" | tee -a ${LOGfile}
    export err=1; err_chk
    exit 1
fi

maxhours=${GFSHOURS}
let maxhours*=3600
let maxhours-=timecheck
if [ $lencheck -gt $maxhours ]
    then 
    echo "ERROR - The forecast length has exceeded the max hours of wind data" | tee -a ${LOGfile}
    export err=1; err_chk
    exit 1
fi

# Generate the wind data for SWAN 
end=0
let t0=start
outfile="${RUNdir}/${YYYYMMDDHH}.wnd"
echo "SWAN wind file: ${outfile}" | tee -a ${LOGfile}

FF=`echo $t0`
if [ $t0 -le 99 ]
then
    FF=`echo 0$t0`
fi
if [ $t0 -le 9 ]
then
    FF=`echo 00$t0`
fi

infile="${INPUTdir}/gfswind_${gfswind_start_time}_${gfswind_date_str}_${gfswind_model_cycle}_f${FF}.dat"
echo "SWAN input file for $t0: ${infile}" | tee -a ${LOGfile}
if [ ! -e ${infile} ]
then
    echo "ERROR - Missing input file: ${infile}" | tee -a ${LOGfile}
    echo "ERROR - The SWAN will fail due to no input winds" | tee -a ${LOGfile}
    export err=1; err_chk
    exit 1
fi
cat ${infile} > ${VARdir}/wind_temp.$$

until [ $end -ge $GFSHOURS ]; do
    let end+=$GFSTIMESTEP
    if [ $end -gt $GFSHOURS ]; then break; fi

    let tstep=start+end
    FF=`echo $tstep`
    if [ $FF -gt $GFSHOURS ]; then break; fi
    if [ $tstep -le 99 ]
    then
	FF=`echo 0$tstep`
    fi
    if [ $tstep -le 9 ]
    then
	FF=`echo 00$tstep`
    fi
    
    infile="${INPUTdir}/gfswind_${gfswind_start_time}_${gfswind_date_str}_${gfswind_model_cycle}_f${FF}.dat"
    echo "SWAN input file for $tstep: ${infile}" | tee -a ${LOGfile}  
    if [ ! -e ${infile} ]
    then
	echo "ERROR - Missing input file: ${infile}" | tee -a ${LOGfile}
	echo "ERROR - The SWAN will fail due to no input winds" | tee -a ${LOGfile}
	rm -f ${VARdir}/wind_temp.$$
	export err=1; err_chk
	exit 1
    fi
    cat ${infile} >> ${VARdir}/wind_temp.$$
done
  
# Put the WIND file in the SWAN processing directory
cat ${VARdir}/wind_temp.$$ > ${outfile}
rm -f ${VARdir}/wind_temp.$$

# Generate lines for INPUTCG files
model_end_time=$model_start_time
let secs=$GFSHOURS*3600
let model_end_time+=$secs
model_end_time_str=`echo ${model_end_time} | awk '{ print strftime("%Y%m%d.%H00", $1) }'`

appfile="${WINDINFODIR}/wind/inputCG.app.txt"
cat /dev/null > ${appfile}
echo "INPGRID WIND ${GFSWINDDOMAIN} NONSTAT ${YYYY}${MM}${DD}.${HH}00 ${GFSTIMESTEP}.0 HR ${model_end_time_str}" >> ${appfile}
echo "READINP WIND 1.0 '${YYYYMMDDHH}.wnd' 3 0 0 0 FREE" >> ${appfile}

perlfile="${WINDINFODIR}/wind/perl_input.txt"
cat /dev/null > ${perlfile}
echo "DATE:${YYYY}${MM}${DD}${HH}" >> ${perlfile}
echo "INPUTGRID:INPGRID WIND ${GFSWINDDOMAIN} NONSTAT ${YYYY}${MM}${DD}.${HH}00 ${GFSTIMESTEP}.0 HR ${model_end_time_str}" >> ${perlfile}
echo "FILENAME:${YYYYMMDDHH}.wnd" >> ${perlfile}

perlscriptflag="${WINDINFODIR}/wind/gfswindinput.txt"
cat /dev/null > ${perlscriptflag}
echo "TRUE" >> ${perlscriptflag}

echo "Processing complete" | tee -a ${LOGfile}

cd ${myPWD}
echo "Exiting..." | tee -a ${LOGfile}

exit 0
# -----------------------------------------------------------
# *******************************
# ********* End of File *********
# *******************************

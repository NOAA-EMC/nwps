#!/bin/bash
# -----------------------------------------------------------
# UNIX Shell Script
# Tested Operating System(s): RHEL 5, 6, 7
# Tested Run Level(s): 3, 5
# Shell Used: BASH shell
# Original Author(s): Douglas.Gaer@noaa.gov
# File Creation Date: 01/15/2013
# Date Last Modified: 12/05/2016
#
# Version control: 1.13
#
# Support Team:
#
# Contributors:
#               
# -----------------------------------------------------------
# ------------- Program Description and Details -------------
# -----------------------------------------------------------
#
# Script used to process .25 degree GFS 10m U/V winds
#
# NOTE: This script is modified for use with WCOSS versions 
#
# -----------------------------------------------------------

# Check to see if our SITEID is set
if [ "${SITEID}" == "" ]
    then
    echo "ERROR - Your SITEID variable is not set"
    export err=1; err_chk
    exit 1
fi

if [ "${HOMEnwps}" == "" ]
    then 
    echo "ERROR - Your HOMEnwps variable is not set"
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
export TZ=UTC

# Script variables
# ===========================================================
BINdir="${USHnwps}/gfswind/bin"
LOGfile="${LOGdir}/get_gfswind.log"
myPWD=$(pwd)

# Setup our Regional domain here based on our NWPS site's region
REGION=$(echo "${REGION^^}")
region=$(echo "${REGION,,}")

# Set our data processing directory
DATAdir="${DATAdir}/gfswind"

# Set our output DIR for processed data
OUTPUTdir="${DATAdir}/${REGION}_output"

# Set the DIRs to download (mirror) the NCEP data
PRODUCTdir="${DATAdir}/ncep_hourly"
SPOOLdir="${DATAdir}/ncep_hourly.spool"
CLIPdir="${DATAdir}/${REGION}_hourly"

# Set our final output DIR for SWAN input files
SWANINPUTfiles="${INPUTdir}/gfswind"

# Set our data ingest DIR 
INGESTdir="${LDMdir}/gfswind"

# Set our purging varaibles
GFSWINDPURGEdays="1"
RSYNC="/usr/bin/rsync"
RSYNCargs="-av --force --stats --progress"

if [ "$1" == "--help" ]
then 
    echo ""
    echo "Script used to get GFS 10m U/V winds from NCEP"
    echo "Usage: "
    echo '$USHnwps/gfswind/bin/get_gfswind.sh CYCLE HOURS TIMESTEP [YYYYMMDD]'
    echo ""
    echo "Example to download current run out to 180 hours, hourly" 
    echo '$USHnwps/gfswind/bin/get_gfswind.sh 00 180 3'
    echo ""
    echo "Example to download previous GFS run out 180 hours, 3 hour timestep" 
    echo '$USHnwps/gfswind/bin/get_gfswind.sh 00 180 3 20130117'
    echo ""
    exit 2
fi

# Read our WFO config
if [ ! -e ${FIXnwps}/configs/${siteid}_ncep_config.sh ]
then
    echo "ERROR - No config file found for ${SITEID}"
    echo "ERROR - Missing ${FIXnwps}/configs/${siteid}_ncep_config.sh"
    export err=1; err_chk
    exit 1
fi

unset GFSWINDDOMAIN
unset GFSWINDNX
unset GFSWINDNY

source ${FIXnwps}/configs/${siteid}_ncep_config.sh

if [ "${GFSWINDDOMAIN}" == "" ] || [ "${GFSWINDNX}" == "" ] || [ "${GFSWINDNY}" == "" ]
then
    echo "ERROR - Your GFSWIND domain is not set"
    echo "ERROR - Need to set GFSWINDDOMAIN, GFSWINDNX, and GFSWINDNY vars"
    echo "ERROR - Check your ${FIXnwps}/configs/${siteid}_ncep_config.sh config"
    export err=1; err_chk
    exit 1
fi

if [ "${GFSHOURS}" == "" ]; then export GFSHOURS="192"; fi
if [ "${GFSTIMESTEP}" == "" ]; then export GFSTIMESTEP="3"; fi

if [ -z ${WGRIB2} ]; then
    echo "ERROR - WGRIB2 var is not defined"
    export err=1; err_chk
    exit 1
fi

# The forecast cycle, default to 00
CYCLE="00"	

# Check for command line CYCLE
if [ $# -ge 1 ]; then CYCLE="$1"; fi

#AW # Adjust to the correct cycle if the user has not specified a date for arg 4
#AW if [ $# -lt 4 ]
#AW then
#AW     curhour=$(date -u +%H)
#AW     if [ $curhour -lt 12 ]; then CYCLE="00"; fi
#AW     if [ $curhour -ge 12 ] && [ $curhour -lt 18 ]; then CYCLE="06"; fi
#AW     if [ $curhour -ge 18 ] && [ $curhour -lt 22 ]; then CYCLE="12"; fi
#AW     if [ $curhour -ge 22 ]; then CYCLE="18"; fi
#AW     echo ""
#AW     echo "INFO - Current hour is ${curhour}, setting model cycle to ${CYCLE}"
#AW fi

HOURS="${GFSHOURS}"
if [ $# -ge 2 ]; then HOURS="$2"; fi

TIMESTEP="${GFSTIMESTEP}"
if [ $# -ge 3 ]; then TIMESTEP="$3"; fi

if [ -z ${PDY} ]; then export PDY=$(date +%Y%m%d); fi

# Set the date stamp using the system Z time
YYYY=$(echo $PDY|cut -c1-4)
MM=$(echo $PDY|cut -c5-6)
DD=$(echo $PDY|cut -c7-8)
YYYYMMDD="${YYYY}${MM}${DD}"

# Optional ARGS used to override the default settings
if [ $# -ge 4 ]
    then 
    YYYYMMDD="$4"
    # Override the auto cycle if user has specifed a date
    if [ $# -ge 1 ]; then CYCLE="$1"; fi
fi

# Use the current date
if [ "${YYYYMMDD}" == "DEFAULT" ]; then YYYYMMDD="${YYYY}${MM}${DD}"; fi

# If available, use the HH on the GFE tarball to find recent GFS input
NewestWind=$(basename $(ls -t ${VARdir}/gfe_grids_test/NWPSWINDGRID_${siteid}* | head -1))
if [ "$NewestWind" != "" ]; then
   windhour=$(echo $NewestWind|cut -c26-27)
   if [ $windhour -lt 12 ]; then gfeCYCLE="00"; fi
   if [ $windhour -ge 12 ] && [ $windhour -lt 18 ]; then gfeCYCLE="06"; fi
   if [ $windhour -ge 18 ] && [ $windhour -lt 22 ]; then gfeCYCLE="12"; fi
   if [ $windhour -ge 22 ]; then gfeCYCLE="18"; fi
   echo ""
   echo "INFO - GFE wind hour is ${windhour}, setting wind cycle to ${gfeCYCLE}"
fi

# Set our script variables from the global config
NX=${GFSWINDNX}
NY=${GFSWINDNY}
LL_LON=$(echo ${GFSWINDDOMAIN} | awk '{ print $1}')
LL_LAT=$(echo ${GFSWINDDOMAIN} | awk '{ print $2}')
DX=$(echo ${GFSWINDDOMAIN} | awk '{ print $6}')
DY=$(echo ${GFSWINDDOMAIN} | awk '{ print $7}')

echo "GFSHOURS = ${GFSHOURS}"
echo "GFSTIMESTEP = ${GFSTIMESTEP}"
echo "GFSWINDDOMAIN = ${GFSWINDDOMAIN}"
echo "NX = ${GFSWINDNX}"
echo "NY = ${GFSWINDNY}"
echo "LL_LON = ${LL_LON}"
echo "LL_LAT = ${LL_LAT}"
echo "DX = ${DX}"
echo "DY = ${DY}"

echo "Starting GFSWIND data processing"

# Make any of the following directories if needed
mkdir -pv ${PRODUCTdir}
mkdir -pv ${OUTPUTdir}
mkdir -pv ${SPOOLdir}
mkdir -pv ${VARdir}
mkdir -pv ${LOGdir}
mkdir -pv ${CLIPdir}
mkdir -pv ${INGESTdir}
mkdir -pv ${SWANINPUTfiles}

# Starting processing logging here
cat /dev/null > ${LOGfile}

# Starting purging here
echo "Purging any GFSWIND data older than ${GFSWINDPURGEdays} days old" | tee -a ${LOGfile}
find ${OUTPUTdir} -type f -mtime +${GFSWINDPURGEdays} | xargs rm -f
find ${SPOOLdir} -type f -mtime +${GFSWINDPURGEdays} | xargs rm -f
find ${CLIPdir} -type f -mtime +${GFSWINDPURGEdays} | xargs rm -f
find ${INGESTdir} -type f -mtime +${GFSWINDPURGEdays} | xargs rm -f
find ${PRODUCTdir} -type f -mtime +${GFSWINDPURGEdays} | xargs rm -f

function MakeClip() {

    DIR=${1}
    FILE=${2}
    HOUR=${3}

    FFHOUR=`echo $HOUR`
    if [ $HOUR -le 9 ]
	then
	FFHOUR=`echo 00$HOUR`
    fi

    clip_file="${REGION}SWAN_gfswind.t${CYCLE}z.f${FFHOUR}.grib2"
    echo "Clip and reproject to LAT/LON grid" | tee -a ${LOGfile} 2>&1

    ${WGRIB2} ${DIR}/${FILE} -match "UGRD:10 m above ground" -grib ${DIR}/u.g2
    ${WGRIB2} ${DIR}/${FILE} -match "VGRD:10 m above ground" -grib ${DIR}/v.g2
    cat ${DIR}/u.g2 > ${DIR}/uv.g2
    cat ${DIR}/v.g2 >> ${DIR}/uv.g2
    ${WGRIB2} ${DIR}/uv.g2 -new_grid latlon ${LL_LON}:${NX}:${DX} ${LL_LAT}:${NY}:${DY} ${CLIPdir}/${clip_file}
    rm -f  ${DIR}/u.g2  ${DIR}/v.g2  ${DIR}/uv.g2

    FF=`echo $HOUR`
    if [ $HOUR -le 99 ]
	then
	FF=`echo 0$HOUR`
    fi
    if [ $HOUR -le 9 ]
	then
	FF=`echo 00$HOUR`
    fi

    swan_uv_ofile_fname="gfswind_${epoc_time}_${date_str}_${CYCLE}_f${FF}.dat"
    swan_uv_ofile="${OUTPUTdir}/${swan_uv_ofile_fname}"

    PARMS="UGRD VGRD"
    for PARM in ${PARMS}
    do
	echo "Extracting ${PARM} data" | tee -a ${LOGfile} 2>&1
	echo "${WGRIB2} -no_header -match ${PARM} -text ${CLIPdir}/${PARM}.dat ${CLIPdir}/${clip_file}" | tee -a ${LOGfile} 2>&1
	${WGRIB2} -no_header -match ${PARM} -text ${CLIPdir}/${PARM}.dat ${CLIPdir}/${clip_file}
    done
    
    cat ${CLIPdir}/UGRD.dat > ${CLIPdir}/UV.dat
    cat ${CLIPdir}/VGRD.dat >> ${CLIPdir}/UV.dat
    
    echo "Writing DAT file" | tee -a ${LOGfile} 2>&1    
    ${EXECnwps}/fix_ascii_point_data ${CLIPdir}/UV.dat 9.999e+20 0.0 ${swan_uv_ofile}
    
    echo "Copying SWAN input files ${INGESTdir}" | tee -a ${LOGfile}
    cp -pfv ${swan_uv_ofile} ${INGESTdir}/. | tee -a ${LOGfile}

    # Clean-up the GRIB2 files to conserve disk space
    if [ -e ${PRODUCTdir}/${file} ]; then rm -f ${PRODUCTdir}/${file}; fi
}

# Get the first forecast cycle
cd ${SPOOLdir}
echo "Our spool DIR for FTP data is: ${SPOOLdir}" | tee -a ${LOGfile}  
echo "Our GFS input drectory: ${COMINgfs}"
echo "Current PDY: ${PDY}"
echo "Previous PDY: ${PDYm1}"

if [ "${COMINgfs}" == "" ]
then
    echo "ERROR - COMINgfs env var not set, exiting"
    export err=1; err_chk
    exit 1
fi

GFSdir=${COMINgfs} 
echo "GFS directory: ${GFSdir}"
if [ "${gfeCYCLE}" -eq 18 ]; then
   CYCLES="18 12 06 00"
elif [ "${gfeCYCLE}" -eq 12 ]; then
   CYCLES="12 06 00"
elif [ "${gfeCYCLE}" -eq 06 ]; then
   CYCLES="06 00"
else
   CYCLES="00"
fi

echo "Checking GFSdir: ${GFSdir}"
for CYCLE in ${CYCLES}
do
    echo "CYCLE = ${CYCLE}"
    firstfile="${CYCLE}/atmos/gfs.t${CYCLE}z.pgrb2.0p25.f000"
    lastfile="${CYCLE}/atmos/gfs.t${CYCLE}z.pgrb2.0p25.f${GFSHOURS}"
    if [ -e ${GFSdir}/${firstfile} ] && [ -e ${GFSdir}/${lastfile} ]
    then
	echo "INFO - We have ${GFSHOURS} for the ${CYCLE} on ${PDY}"
	break
    fi
done

CYCLES="18 12 06 00"
if [ ! -e ${GFSdir}/${firstfile} ] || [ ! -e ${GFSdir}/${lastfile} ]
then
    echo "WARNING- We do not have current day ${GFSHOURS} for the ${CYCLE} on ${PDY}"
    echo "${PDY} GFS not avalible, checking for prevous GFS run"
    GFSdir=$(echo ${GFSdir} | sed s/${PDY}/${PDYm1}/g)

    for CYCLE in ${CYCLES}
    do
	echo "CYCLE = ${CYCLE}"
	firstfile="${CYCLE}/atmos/gfs.t${CYCLE}z.pgrb2.0p25.f000"
	lastfile="${CYCLE}/atmos/gfs.t${CYCLE}z.pgrb2.0p25.f${GFSHOURS}"
	if [ -e ${GFSdir}/${firstfile} ] && [ -e ${GFSdir}/${lastfile} ]
	then
	    echo "INFO - We have ${GFSHOURS} for the ${CYCLE} on ${PDYm1}"
	    break
	fi
    done

    if [ ! -e ${GFSdir}/${firstfile} ] || [ ! -e ${GFSdir}/${lastfile} ]
    then
	echo "ERROR - We do not have prev day ${GFSHOURS} for the ${CYCLE} on ${PDYm1}"
	echo "${PDY} GFS not avalible, checking for prevous GFS run"
	echo "${PDYm1} GFS not avalible"
	echo "ERROR - No GFS winds available"
	export err=1; err_chk
	exit 1
    fi
fi

FF="000"
file="gfs.t${CYCLE}z.pgrb2.0p25.f${FF}"

echo "Copying ${GFSdir}/${CYCLE}/atmos/${file}" | tee -a ${LOGfile}
if [ ! -e ${GFSdir}/${CYCLE}/atmos/${file} ]
then
    echo "INFO - ${GFSdir}/${CYCLE}/atmos/${file} not available yet"
    echo "Exiting"
    export err=1; err_chk
    exit 1
fi

${RSYNC} ${RSYNCargs} ${GFSdir}/${CYCLE}/atmos/${file} ${SPOOLdir}/${file}
if [ "$?" != "0" ] 
then
    echo "ERROR - copying file ${GFSdir}/atmos/${CYCLE}/${file}"
    if [ -e ${SPOOLdir}/${file} ]; then rm -fv ${SPOOLdir}/${file}; fi
    export err=1; err_chk
    exit 1
fi

epoc_time=$(${WGRIB2} -d 1 -unix_time ${SPOOLdir}/${file} | grep "1:0:unix" | awk -F= '{ print $3 }')
date_str=$(echo ${epoc_time} | awk '{ print strftime("%Y%m%d", $1) }')
swan_uv_ofile_fname="gfswind_${epoc_time}_${date_str}_${CYCLE}_f000.dat"
swan_uv_ofile="${OUTPUTdir}/${swan_uv_ofile_fname}"
echo ${epoc_time} > ${OUTPUTdir}/gfswind_start_time.txt
echo "GFSWINDDOMAIN:${GFSWINDDOMAIN}" > ${OUTPUTdir}/gfswind_domain.txt
swan_uv_ofile_fname="gfswind_${epoc_time}_${date_str}_${CYCLE}_f${FF}.dat"
swan_uv_ofile="${OUTPUTdir}/${swan_uv_ofile_fname}"

if [ ! -e ${swan_uv_ofile} ] 
then
    MakeClip ${SPOOLdir} ${file} 0    
else
    echo "Already created ${swan_uv_ofile}"
    echo "Skipping this file"
fi

end=${TIMESTEP}

cd ${SPOOLdir}
until [ $end -gt $HOURS ]; do

    FHOUR=`echo $end`
    if [ $end -le 9 ]
	then
	FHOUR=`echo 00$end`
    fi
    
    FF=`echo $end`
    if [ $end -le 99 ]
	then
	FF=`echo 0$end`
    fi
    if [ $end -le 9 ]
	then
	FF=`echo 00$end`
    fi

    swan_uv_ofile_fname="gfswind_${epoc_time}_${date_str}_${CYCLE}_f${FF}.dat"
    swan_uv_ofile="${OUTPUTdir}/${swan_uv_ofile_fname}"

    if [ -e ${swan_uv_ofile} ] 
    then
	echo "Already created ${swan_uv_ofile}"
	echo "Skipping this file"
	let end+=$TIMESTEP
	continue
    fi

    file="gfs.t${CYCLE}z.pgrb2.0p25.f${FF}"
    outfile="${file}"
    cd ${PRODUCTdir}
    echo "Copying ${GFSdir}/${CYCLE}/atmos/${file}" | tee -a ${LOGfile}

    if [ ! -e ${GFSdir}/${CYCLE}/atmos/${file} ]
    then
	echo "INFO - ${GFSdir}/${CYCLE}/atmos/${file} not available yet"
	echo "Exiting"
	export err=1; err_chk
	exit 1
    fi

    ${RSYNC} ${RSYNCargs} ${GFSdir}/${CYCLE}/atmos/${file} ${PRODUCTdir}/${file}
    if [ "$?" != "0" ] 
    then
	echo "ERROR - copying file ${GFSdir}/atmos/${CYCLE}/${file}"
	if [ -e ${PRODUCTdir}/${file} ]; then rm -fv ${PRODUCTdir}/${file}; fi
	export err=1; err_chk
	exit 1
    fi
    MakeClip ${PRODUCTdir} ${file} ${end}
    let end+=$TIMESTEP
done

datetime=`date -u`
echo "Ending download at $datetime UTC" | tee -a ${LOGfile}

echo "Purging previous run from ${OUTPUTdir}" | tee -a ${LOGfile} 2>&1
${BINdir}/purge_gfswind.sh ${OUTPUTdir} ${GFSHOURS} | tee -a ${LOGfile}

if [ $end -ge $HOURS ]
then 
    echo "We completed the download out to ${HOURS} and will update INGEST directory" | tee -a ${LOGfile} 2>&1
    echo ${epoc_time} > ${INGESTdir}/gfswind_start_time.txt
    echo "GFSWINDDOMAIN:${GFSWINDDOMAIN}" > ${INGESTdir}/gfswind_domain.txt
    echo "Purging previous run from ${INGESTdir}" | tee -a ${LOGfile} 2>&1
    ${BINdir}/purge_gfswind.sh ${INGESTdir} ${GFSHOURS} | tee -a ${LOGfile}
    echo "${RSYNC} ${RSYNCargs} ${OUTPUTdir}/*.dat ${INGESTdir}/." | tee -a ${LOGfile} 2>&1
    ${RSYNC} ${RSYNCargs} ${OUTPUTdir}/*.dat ${INGESTdir}/.  | tee -a ${LOGfile} 2>&1
fi

echo "Processing complete" | tee -a ${LOGfile}

cd ${myPWD}
echo "Exiting..." | tee -a ${LOGfile}

exit 0
# -----------------------------------------------------------
# *******************************
# ********* End of File *********
# *******************************

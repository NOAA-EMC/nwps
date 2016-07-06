#!/bin/bash
set -xa
# -----------------------------------------------------------
# UNIX Shell Script
# Tested Operating System(s): RHEL 5, 6
# Tested Run Level(s): 3, 5
# Shell Used: BASH shell
# Original Author(s): Douglas.Gaer@noaa.gov
# File Creation Date: 01/15/2013
# Date Last Modified: 07/29/2014
#
# Version control: 1.07
#
# Support Team:
#
# Contributors:
#               
# -----------------------------------------------------------
# ------------- Program Description and Details -------------
# -----------------------------------------------------------
#
# Script used to download .5 degree GFS 10m U/V winds from NCEP.
#
# NOTE: This script is used on standalone workstations
#
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

if [ -e ${USHnwps}/nwps_config.sh ]
then
    source ${USHnwps}/nwps_config.sh
else
    echo "ERROR - Cannot find ${USHnwps}/nwps_config.sh"
    export err=1; err_chk
fi

# NOTE: Data is processed on the server in UTC
export TZ=UTC

# Script variables
# ===========================================================
BINdir="${USHnwps}/gfswind/bin"
LOGfile="${LOGdir}/gfswind_download.log"
myPWD=$(pwd)

# Setup our Regional domain here based on our NWPS site's region
REGION=$(echo "${REGIONID}" | tr [:lower:] [:upper:])
region=$(echo "${regionid}" | tr [:upper:] [:lower:])

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
GFSWINDPURGEdays="8"

# Set our locking variables
PROGRAMname="$0"
LOCKfile="$VARdir/get_gfswind.lck"
MINold="60"

if [ "$1" == "--help" ]
then 
    echo ""
    echo "Script used to get GFS 10m U/V winds from NCEP"
    echo "Usage: "
    echo '$USHnwps/get_gfswind.sh CYCLE HOURS TIMESTEP [YYYYMMDD]'
    echo ""
    echo "Example to download current run out to 180 hours, hourly" 
    echo '$USHnwps/get_gfswind.sh 00 180 3'
    echo ""
    echo "Example to download previous GFS run out 180 hours, 3 hour timestep" 
    echo '$USHnwps/get_gfswind.sh 00 180 3 20130117'
    echo ""
    exit 2
fi

# The forecast cycle, default to 00
CYCLE="00"	
# Check for command line CYCLE
if [ "$1" != "" ]; then CYCLE="$1"; fi

# Adjust to the correct cycle if the user has not specified a date for arg 4
if [ "$4" == "" ]
then
    curhour=$(date -u +%H)
    if [ $curhour -lt 12 ]; then CYCLE="00"; fi
    if [ $curhour -ge 12 ] && [ $curhour -lt 18 ]; then CYCLE="06"; fi
    if [ $curhour -ge 18 ] && [ $curhour -lt 22 ]; then CYCLE="12"; fi
    if [ $curhour -ge 22 ]; then CYCLE="18"; fi
    echo ""
    echo "INFO - Current hour is ${curhour}, setting model cycle to ${CYCLE}"
fi

HOURS="${GFSHOURS}"
if [ "$2" != "" ]; then HOURS="$2"; fi

TIMESTEP="${GFSTIMESTEP}"
if [ "$3" != "" ]; then TIMESTEP="$3"; fi

# Set the date stamp using the system Z time
YYYY=$(echo $PDY|cut -c1-4)
MM=$(echo $PDY|cut -c5-6)
DD=$(echo $PDY|cut -c7-8)

# Optional ARGS used to override the default settings
YYYYMMDD="${YYYY}${MM}${DD}"
if [ "$4" != "" ]
    then 
    YYYYMMDD="$4"
    # Override the auto cycle if user has specifed a date
    if [ "$1" != "" ]; then CYCLE="$1"; fi
fi

# Use the current date
if [ "${YYYYMMDD}" == "DEFAULT" ]; then YYYYMMDD="${YYYY}${MM}${DD}"; fi

# Read our NWPS config
if [ -e ${USHnwps}/${region}_nwps_config.sh ]
then
    HAS_REGIONAL_CONFIG="TRUE"
else
    echo "WARNING - ${USHnwps}/${region}_nwps_config.sh file does not exist"
    echo "WARNING - will use ${USHnwps}/nwps_config.sh default setting for GFSWIND data"
    HAS_REGIONAL_CONFIG="FALSE"
fi

if [ "${GFSWINDDOMAIN}" == "" ] || [ "${GFSWINDNX}" == "" ] || [ "${GFSWINDNY}" == "" ]
then
    echo "ERROR - Your GFSWIND domain is not set"
    echo "ERROR - Need to set GFSWINDDOMAIN, GFSWINDNX, and GFSWINDNY vars"
    echo "ERROR - Check your ${USHnwps}/${region}_nwps_config.sh config"
    export err=1; err_chk
fi

if [ "${HAS_REGIONAL_CONFIG}" == "TRUE" ]
then
    echo "GFSWIND domain set by NWPS ${USHnwps}/${region}_nwps_config.sh"
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
echo "GFSWIND_REGION = ${GFSWIND_REGION}"
echo "GFSWINDDOMAIN = ${GFSWINDDOMAIN}"
echo "NX = ${GFSWINDNX}"
echo "NY = ${GFSWINDNY}"
echo "LL_LON= ${LL_LON}"
echo "LL_LAT= ${LL_LAT}"
echo "DX = ${DX}"
echo "DY = ${DY}"

#source ${USHnwps}/process_lock.sh

echo "Starting GFSWIND data processing"
#echo "Checking for lock files"
#LockFileCheck $MINold
#CreateLockFile

# Make any of the following directories if needed
mkdir -p ${PRODUCTdir}
mkdir -p ${OUTPUTdir}
mkdir -p ${SPOOLdir}
mkdir -p ${VARdir}
mkdir -p ${LOGdir}
mkdir -p ${CLIPdir}
mkdir -p ${INGESTdir}
mkdir -p ${SWANINPUTfiles}

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
    echo "${WGRIB2} ${DIR}/${FILE} -new_grid latlon ${LL_LON}:${NX}:${DX} ${LL_LAT}:${NY}:${DY} ${CLIPdir}/${clip_file}" | tee -a ${LOGfile} 
    ${WGRIB2} ${DIR}/${FILE} -new_grid latlon ${LL_LON}:${NX}:${DX} ${LL_LAT}:${NY}:${DY} ${CLIPdir}/${clip_file} | tee -a ${LOGfile} 2>&1


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

FF="000"
file="gfs.t${CYCLE}z.master.grbf${FF}.10m.uv.grib2"
echo "Copying $COMINgfs/$file " | tee -a ${LOGfile}

cp -pr $COMINgfs/$file ./

if [ "$?" != "0" ] 
then
    echo "ERROR - copying file ${COMINgfs}/${file}"
    rm -f ${file}
    #RemoveLockFile
    export err=1; err_chk
fi
if [ ! -e ${outfile} ]
then
    echo "INFO - ${COMINgfs}/${file} not available for copy yet"
    echo "Exiting"
    #RemoveLockFile
    export err=1; err_chk
fi

epoc_time=`${WGRIB2} -unix_time ${SPOOLdir}/${file} | grep "1:0:unix" | awk -F= '{ print $3 }'`
date_str=`echo ${epoc_time} | awk '{ print strftime("%Y%m%d", $1) }'`
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

    file="gfs.t${CYCLE}z.master.grbf${FF}.10m.uv.grib2"
    outfile="${file}"
    cd ${PRODUCTdir}
    echo "Copying $COMINgfs/$file " | tee -a ${LOGfile}

    cp -pr $COMINgfs/$file ./

    if [ "$?" != "0" ] 
    then
	echo "ERROR - copying file ${COMINgfs}/${file}"
	rm -f ${file}
	#RemoveLockFile
	export err=1; err_chk
    fi
    if [ ! -e ${outfile} ]
    then
	echo "INFO - ${COMINgfs}/${file} not available for copy yet"
	echo "Exiting"
	#RemoveLockFile
	export err=1; err_chk
    fi

    MakeClip ${PRODUCTdir} ${file} ${end}

    let end+=$TIMESTEP

done

datetime=`date -u`
echo "Ending download at $datetime UTC" | tee -a ${LOGfile}

echo "Purging previous run from ${OUTPUTdir}" | tee -a ${LOGfile} 2>&1
${BINdir}/purge_gfswind.sh ${OUTPUTdir} ${GFSHOURS} | tee -a ${LOGfile}
export err=$?; err_chk

if [ $end -ge $HOURS ]
then 
    echo "We completed the download out to ${HOURS} and will update INGEST directory" | tee -a ${LOGfile} 2>&1
    echo ${epoc_time} > ${INGESTdir}/gfswind_start_time.txt
    echo "GFSWINDDOMAIN:${GFSWINDDOMAIN}" > ${INGESTdir}/gfswind_domain.txt
    echo "Purging previous run from ${INGESTdir}" | tee -a ${LOGfile} 2>&1
    ${BINdir}/purge_gfswind.sh ${INGESTdir} ${GFSHOURS} | tee -a ${LOGfile}
    export err=$?; err_chk
    echo "$RSYNC -av --force ${OUTPUTdir}/*.dat ${INGESTdir}/." | tee -a ${LOGfile} 2>&1
    $RSYNC -av --force ${OUTPUTdir}/*.dat ${INGESTdir}/.  | tee -a ${LOGfile} 2>&1
fi

echo "Processing complete" | tee -a ${LOGfile}

cd ${myPWD}
echo "Exiting..." | tee -a ${LOGfile}

#RemoveLockFile
exit 0
# -----------------------------------------------------------
# *******************************
# ********* End of File *********
# *******************************

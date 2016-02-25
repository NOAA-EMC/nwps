#!/bin/bash
# -----------------------------------------------------------
# UNIX Shell Script
# Tested Operating System(s): RHEL 5, 6
# Tested Run Level(s): 3, 5
# Shell Used: BASH shell
# Original Author(s): Douglas.Gaer@noaa.gov
# File Creation Date: 12/01/2012
# Date Last Modified: 07/29/2014
#
# Version control: 1.10
#
# Support Team:
#
# Contributors:
#               
# -----------------------------------------------------------
# ------------- Program Description and Details -------------
# -----------------------------------------------------------
#
# Script used to download ESTOFS grib2 files. 
#
# NOTE: This script is used on standalone workstations
# NOTE: that are not fed by SBN or regional LDM. This script was
# NOTE: designed for use on LDM server, DEV systems or other
# NOTE: workstations.   
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

# Check to see if this an LDM server
source ${NWPSdir}/utils/ldm/ldm_server/set_ldm_server.sh

if [ "${IS_LDMSERVER}" == "TRUE" ]
then
    if [ "${USERNAME}" != "${LDMUSER}" ] 
    then
	echo "ERROR - Invalid user trying to run this script"
	echo "ERROR - Username must be ${LDMUSER}"
	export err=1; err_chk
    fi
fi

# NOTE: Data is processed on the server in UTC
export TZ=UTC

# Script variables
# ===========================================================
BINdir="${USHnwps}/estofs/bin"
LOGfile="${LOGdir}/estofs_download.log"
myPWD=$(pwd)

# Setup our Regional domain here based on our NWPS site's region
REGION=$(echo "${REGIONID}" | tr [:lower:] [:upper:])
region=$(echo "${regionid}" | tr [:upper:] [:lower:])

if [ "${IS_LDMSERVER}" == "TRUE" ]
then
    # Set our LDM server scripts and utils
    ldm_server_script="${NWPSdir}/utils/ldm/ldm_server/${region}_ldm_server_inc.sh"
    ldm_cluster_script="${NWPSdir}/utils/ldm/ldm_server/${region}_ldm_cluster_inc.sh"
    LDMSEND="${LDMHOME}/bin/ldmsend"
fi

# Set our data processing directory
DATAdir="${DATAdir}/estofs"
# Set our output DIR for processed data
OUTPUTdir="${DATAdir}/${REGION}_output"
# Set the DIRs to download (mirror) the NCEP data
PRODUCTdir="${DATAdir}/ncep_hourly"
SPOOLdir="${DATAdir}/ncep_hourly.spool"
CLIPdir="${DATAdir}/${REGION}_hourly"

# Set our data ingest DIR 
INGESTdir="${LDMdir}/estofs"

# Set our final output DIR for SWAN input files
SWANINPUTfiles="${INPUTdir}/estofs"

# Set our purging varaibles
ESTOFSPURGEdays="5"

# Set our locking variables
PROGRAMname="$0"
LOCKfile="$VARdir/get_estofs.lck"
MINold="60"

# NOTE: Add WGET --no-remove-listing option for FTP downloads
RSYNC="/usr/bin/rsync"
DOWNLOADRETRIES="5"
if [ "$6" != "" ]; then DOWNLOADRETRIES="$6"; fi 
WGETargs="-N -nv --tries=${DOWNLOADRETRIES} --no-remove-listing --append-output=${LOGfile}"
WGET="/usr/bin/wget"

# The forecast cycle, default to 00
CYCLE="00"	
# Check for command line CYCLE
if [ "$1" != "" ]; then CYCLE="$1"; fi

# Adjust to the correct cycle
curhour=$(date -u +%H)
if [ $curhour -lt 12 ]; then CYCLE="00"; fi
if [ $curhour -ge 12 ] && [ $curhour -lt 18 ]; then CYCLE="06"; fi
if [ $curhour -ge 18 ] && [ $curhour -lt 22 ]; then CYCLE="12"; fi
if [ $curhour -ge 22 ]; then CYCLE="18"; fi
echo ""
echo "INFO - Current hour is ${curhour}, setting model cycle to ${CYCLE}"

HOURS="${ESTOFSHOURS}"
if [ "$2" != "" ]; then HOURS="$2"; fi

TIMESTEP="${ESTOFSTIMESTEP}"
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

if [ "${ESTOFS_REGION}" == "" ]; then ESTOFS_REGION="conus"; fi
if [ "$5" != "" ]; then ESTOFS_REGION="$5"; fi

if [ "${ESTOFSDOMAIN}" == "" ] || [ "${ESTOFSNX}" == "" ] || [ "${ESTOFSNY}" == "" ]  || [ "${ESTOFS_REGION}" == "" ]
then
    echo "ERROR - Your ESTOFS domain is not set"
    echo "ERROR - Need to set ESTOFSDOMAIN, ESTOFSNX, ESTOFSNY, and ESTOFS_REGION vars"
    echo "ERROR - Check your ${USHnwps}/${region}_nwps_config.sh config"
    export err=1; err_chk
fi

# Set our script variables from the global config
NX=${ESTOFSNX}
NY=${ESTOFSNY}
LL_LON=$(echo ${ESTOFSDOMAIN} | awk '{ print $1}')
LL_LAT=$(echo ${ESTOFSDOMAIN} | awk '{ print $2}')
DX=$(echo ${ESTOFSDOMAIN} | awk '{ print $6}')
DY=$(echo ${ESTOFSDOMAIN} | awk '{ print $7}')

echo "ESTOFSHOURS = ${ESTOFSHOURS}"
echo "ESTOFSTIMESTEP = ${ESTOFSTIMESTEP}"
echo "ESTOFS_REGION = ${ESTOFS_REGION}"
echo "ESTOFSDOMAIN = ${ESTOFSDOMAIN}"
echo "NX = ${ESTOFSNX}"
echo "NY = ${ESTOFSNY}"
echo "LL_LON= ${LL_LON}"
echo "LL_LAT= ${LL_LAT}"
echo "DX = ${DX}"
echo "DY = ${DY}"

#source ${USHnwps}/process_lock.sh

echo "Starting ESTOFS data processing"
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
mkdir -p ${SWANINPUTfiles}
mkdir -p ${INGESTdir}

function MakeClip() {

    DIR=${1}
    FILE=${2}
    HOUR=${3}

    FF=`echo $HOUR`
    if [ $HOUR -le 99 ]
	then
	FF=`echo 0$HOUR`
    fi
    if [ $HOUR -le 9 ]
	then
	FF=`echo 00$HOUR`
    fi

    clip_file="${REGION}SWAN_estofs.atl.t${CYCLE}z.conus.f${FF}.grib2"
    datfile="${REGION}SWAN_estofs.atl.t${CYCLE}z.conus.f${FF}.dat"

    if [ ! -e ${CLIPdir}/${clip_file} ]
    then
	echo "Clip and reproject to LAT/LON grid" | tee -a ${LOGfile} 2>&1
	echo "${WGRIB2} ${DIR}/${FILE} -new_grid latlon ${LL_LON}:${NX}:${DX} ${LL_LAT}:${NY}:${DY} ${CLIPdir}/${clip_file}" | tee -a ${LOGfile} 
	${WGRIB2} ${DIR}/${FILE} -new_grid latlon ${LL_LON}:${NX}:${DX} ${LL_LAT}:${NY}:${DY} ${CLIPdir}/${clip_file} | tee -a ${LOGfile} 2>&1
    fi

    swan_wl_ofile_fname="wave_estofs_waterlevel_${epoc_time}_${date_str}_${CYCLE}_f${FF}.dat"
    swan_wl_ofile="${OUTPUTdir}/${swan_wl_ofile_fname}"

    if [ ! -e ${swan_wl_ofile} ]
    then
	PARM="var"
	echo "Extract ${PARM} data" | tee -a ${LOGfile} 2>&1
	echo "${WGRIB2} -no_header -match ${PARM} -text ${CLIPdir}/${PARM}.dat ${CLIPdir}/${clip_file}" | tee -a ${LOGfile} 2>&1
	${WGRIB2} -no_header -match ${PARM} -text ${CLIPdir}/${PARM}.dat ${CLIPdir}/${clip_file}
	echo "Writing final DAT file" | tee -a ${LOGfile} 2>&1    
	${EXECnwps}/fix_ascii_point_data ${CLIPdir}/${PARM}.dat 9.999e+20 0.0 ${swan_wl_ofile}
	rm -f ${CLIPdir}/${PARM}.dat
    fi

    if [ "${IS_LDMSERVER}" == "TRUE" ]
    then
	cd ${OUTPUTdir}
	swan_dist_file="${OUTPUTdir}/estofs_swan_${epoc_time}_${date_str}_t${CYCLE}z_f${FF}_${REGION}.tar.gz" 
	if [ ! -e ${swan_dist_file} ]
	then 
	    echo "Creating SWAN distrib file ${swan_dist_file}" | tee -a ${LOGfile}
	    cd ${OUTPUTdir}
	    tar cvfz ${swan_dist_file} ${swan_wl_ofile_fname} estofs_waterlevel_start_time.txt estofs_waterlevel_domain.txt 
	    cd ${CLIPdir}
	    if [ -e ${ldm_server_script} ]; then source ${ldm_server_script}; fi 
	fi
    else
	echo "Copying SWAN input files ${INGESTdir}" | tee -a ${LOGfile}
	cp -pfv ${swan_wl_ofile} ${INGESTdir}/. | tee -a ${LOGfile}
    fi

    # Clean-up the GRIB2 files to conserve disk space
    if [ -e ${PRODUCTdir}/${file} ]; then rm -f ${PRODUCTdir}/${file}; fi
}

# Starting processing logging here
cat /dev/null > ${LOGfile}

# Starting purging here
echo "Purging any ESTOFS data older than ${ESTOFSPURGEdays} days old" | tee -a ${LOGfile}
find ${OUTPUTdir} -type f -mtime +${ESTOFSPURGEdays} | xargs rm -f
find ${SPOOLdir} -type f -mtime +${ESTOFSPURGEdays} | xargs rm -f
find ${CLIPdir} -type f -mtime +${ESTOFSPURGEdays} | xargs rm -f
find ${INGESTdir} -type f -mtime +${ESTOFSPURGEdays} | xargs rm -f
find ${PRODUCTdir} -type f -mtime +${ESTOFSPURGEdays} | xargs rm -f

# Set our download URL
url="ftp://ftp.ncep.noaa.gov/pub/data/nccf/com/estofs/prod/estofs.${YYYYMMDD}"

echo "Our spool DIR for FTP data is: ${SPOOLdir}" | tee -a ${LOGfile}  

# Get the first forecast cycle
FF="000"
file="estofs.atl.t${CYCLE}z.${ESTOFS_REGION}.f${FF}.grib2"
outfile="${file}"
cd ${SPOOLdir}
echo "Downloading $url/$file to $outfile" | tee -a ${LOGfile}
echo "$WGET ${WGETargs} ${url}/${file}" | tee -a ${LOGfile} 2>&1
$WGET ${WGETargs} ${url}/${file} | tee -a ${LOGfile} 2>&1
if [ "$?" != "0" ] 
then
    echo "ERROR - downling file ${url}/${file}"
    rm -f ${file}
    #RemoveLockFile
    export err=1; err_chk
fi
if [ ! -e ${outfile} ]
then
    echo "INFO - $url/${file} not available for download yet"
    echo "Exiting"
    #RemoveLockFile
    export err=1; err_chk
fi
epoc_time=`${WGRIB2} -unix_time ${SPOOLdir}/${file} | grep "1:4:unix" | awk -F= '{ print $3 }'`
date_str=`echo ${epoc_time} | awk '{ print strftime("%Y%m%d", $1) }'`
echo ${epoc_time} > ${OUTPUTdir}/estofs_waterlevel_start_time.txt
echo "ESTOFSDOMAIN:${ESTOFSDOMAIN}" > ${OUTPUTdir}/estofs_waterlevel_domain.txt
swan_wl_ofile_fname="wave_estofs_waterlevel_${epoc_time}_${date_str}_${CYCLE}_f${FF}.dat"
swan_wl_ofile="${OUTPUTdir}/${swan_wl_ofile_fname}"

if [ ! -e ${swan_wl_ofile} ]
then
    MakeClip ${SPOOLdir} ${file} 0    
else
    echo "Already created ${swan_wl_ofile}"
    echo "Skipping this file"
fi

end=$TIMESTEP
cd ${SPOOLdir}
until [ $end -gt $HOURS ]; do

    FF=`echo $end`
    if [ $end -le 99 ]
	then
	FF=`echo 0$end`
    fi
    if [ $end -le 9 ]
	then
	FF=`echo 00$end`
    fi

    swan_wl_ofile_fname="wave_estofs_waterlevel_${epoc_time}_${date_str}_${CYCLE}_f${FF}.dat"
    swan_wl_ofile="${OUTPUTdir}/${swan_wl_ofile_fname}"
    if [ -e ${swan_wl_ofile} ] 
    then
	echo "Already created ${swan_wl_ofile}"
	echo "Skipping this file"
	let end+=$TIMESTEP
	continue
    fi

    file="estofs.atl.t${CYCLE}z.${ESTOFS_REGION}.f${FF}.grib2"
    outfile="${file}"
    cd ${SPOOLdir}
    echo "Downloading $url/$file to $outfile" | tee -a ${LOGfile}
    echo "$WGET ${WGETargs} ${url}/${file}" | tee -a ${LOGfile} 2>&1
    $WGET ${WGETargs} ${url}/${file} | tee -a ${LOGfile} 2>&1
    if [ "$?" != "0" ] 
    then
	echo "ERROR - downling file ${url}/${file}"
	rm -f ${file}
	#RemoveLockFile
	export err=1; err_chk
    fi
    if [ ! -e ${outfile} ]
    then
	echo "INFO - $url/${file} not available for download yet"
	echo "Exiting"
	#RemoveLockFile
	export err=1; err_chk
    fi

    file="estofs.atl.t${CYCLE}z.${ESTOFS_REGION}.f${FF}.grib2"
    outfile="${file}"
    cd ${PRODUCTdir}
    echo "Downloading $url/$file to $outfile" | tee -a ${LOGfile}
    echo "$WGET ${WGETargs} ${url}/${file}" | tee -a ${LOGfile} 2>&1
    $WGET ${WGETargs} ${url}/${file} | tee -a ${LOGfile} 2>&1
    if [ "$?" != "0" ] 
    then
	echo "ERROR - downling file ${url}/${file}"
	rm -f ${file}
	#RemoveLockFile
	export err=1; err_chk
    fi
    if [ ! -e ${outfile} ]
    then
	echo "INFO - $url/${file} not available for download yet"
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
${BINdir}/purge_estofs.sh ${OUTPUTdir} ${ESTOFSHOURS} | tee -a ${LOGfile}

if [ $end -ge $HOURS ] && [ "${IS_LDMSERVER}" == "FALSE" ]
then 
    echo "We completed the download out to ${HOURS}" | tee -a ${LOGfile} 2>&1
    echo ${epoc_time} > ${INGESTdir}/estofs_waterlevel_start_time.txt
    echo "ESTOFSDOMAIN:${ESTOFSDOMAIN}" > ${INGESTdir}/estofs_waterlevel_domain.txt
    echo "Purging previous run from ${INGESTdir}" | tee -a ${LOGfile} 2>&1
    ${BINdir}/purge_estofs.sh ${INGESTdir} ${ESTOFSHOURS} | tee -a ${LOGfile}
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

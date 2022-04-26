#!/bin/bash
set -xa
# -----------------------------------------------------------
# UNIX Shell Script
# Tested Operating System(s): RHEL 5, 6
# Tested Run Level(s): 3, 5
# Shell Used: BASH shell
# Original Author(s): Douglas.Gaer@noaa.gov
# File Creation Date: 06/12/2015
# Date Last Modified: 08/13/2015
#
# Version control: 3.23
#
# Support Team:
#
# Contributors: Roberto Padilla-Hernandez
#               
# -----------------------------------------------------------
# ------------- Program Description and Details -------------
# -----------------------------------------------------------
#
# Script used to download RTOFS grib2 files and make WFO clips. 
#
# NOTE: This script is an adaptation of the standalone workstation version
#
# -----------------------------------------------------------

if [ "${HOMEnwps}" == "" ]
    then 
    echo "ERROR - Your HOMEnwps variable is not set"
    export err=1; err_chk
fi

if [ -e ${USHnwps}/rtofs/bin/nwps_config.sh ]
then
    source ${USHnwps}/rtofs/bin/nwps_config.sh
else
    echo "ERROR - Cannot find ${USHnwps}/nwps_config.sh"
    export err=1; err_chk
fi

# NOTE: Data is processed on the server in UTC
export TZ=UTC

# Script variables
# ===========================================================
#BINdir="${UShnwps}/rtofs/bin"
LOGfile="${LOGdir}/make_rtofs_sector.log"
myPWD=$(pwd)

# Set top level our data processing directory
PRODUCTdir="${RUNdir}/ncep_hourly"
SPOOLdir="${RUNdir}/ncep_hourly.spool"
CLIPdir="${VARdir}/rtofs"

# Set our purging varaibles
RTOFSPURGEdays="5"

# Set our locking variables
PROGRAMname="$0"
LOCKfile="$VARdir/get_rtofs_sector.lck"
MINold="120"

# NOTE: Add WGET --no-remove-listing option for FTP downloads
RSYNC="/usr/bin/rsync"
DOWNLOADRETRIES="5"
if [ "$5" != "" ]; then DOWNLOADRETRIES="$5"; fi 
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

# NOTE: There is only the 00z cycle for RTOFS
CYCLE="00"
echo ""
echo "INFO - Current hour is ${curhour}, setting model cycle to ${CYCLE}"

HOURS="${RTOFSHOURS}"
if [ "$2" != "" ]; then HOURS="$2"; fi

TIMESTEP="${RTOFSTIMESTEP}"
if [ "$3" != "" ]; then TIMESTEP="$3"; fi

# Set the date stamp using the system Z time
#YYYY=`date +%Y`
#MM=`date +%m`
#DD=`date +%d`

# Optional ARGS used to override the default settings
# Optional ARGS used to override the default settings
#YYYYMMDD="${YYYY}${MM}${DD}"
YYYYMMDD="${PDY}"
if [ "$4" != "" ]
    then 
    YYYYMMDD="$4"
    # Override the auto cycle if user has specifed a date
    if [ "$1" != "" ]; then CYCLE="$1"; fi
fi

# Use the current date
if [ "${YYYYMMDD}" == "DEFAULT" ]; then YYYYMMDD="${PDY}"; fi

# NOTE: 07/17/2015: At this time there is only the 00z cycle for RTOFS
CYCLE="00"
echo ""

# Set paths to RTOFS utils need to create NWPS output files
WRITEDAT="${EXECnwps}/writedat"
READDAT="${EXECnwps}/readdat"
FIX_ASCII_POINT_DATA="${EXECnwps}/fix_ascii_point_data"
#NCDUMP="${NWPSdir}/lib${ARCHBITS}/netcdf/bin/ncdump"
#GRADS="${NWPSdir}/lib${ARCHBITS}/grads/bin/grads"

#source $NWPSdir/bin/process_lock.sh

echo "Starting RTOFS data processing"
#echo "Checking for lock files"
#LockFileCheck $MINold
#CreateLockFile

# Starting processing logging here
cat /dev/null > ${LOGfile}

# Make any of the following directories if needed
mkdir -p ${PRODUCTdir}
mkdir -p ${SPOOLdir}
mkdir -p ${VARdir}
mkdir -p ${LOGdir}
mkdir -p ${CLIPdir}
mkdir -p ${RUNdir}
mkdir -p ${COMOUT}/rtofs/

## Starting purging here
#echo "Purging any RTOFS data older than ${RTOFSPURGEdays} days old" | tee -a ${LOGfile}
#find ${DATAdir} -type f -mtime +${RTOFSPURGEdays} | xargs rm -f
#find ${VARdir} -name "hasrtofsdownload*" -print | xargs rm -f
#find ${SPOOLdir} -type f -mtime +${RTOFSPURGEdays} | xargs rm -f
#find ${CLIPdir} -type f -mtime +${RTOFSPURGEdays} | xargs rm -f
#find ${PRODUCTdir} -type f -mtime +${RTOFSPURGEdays} | xargs rm -f

function MakeClip() {

    end=${1}

    FF=`echo $end`
    if [ $end -le 99 ]
	then
	FF=`echo 0$end`
    fi
    if [ $end -le 9 ]
	then
	FF=`echo 00$end`
    fi

    # Nowcast hour 24 is forecast hour 0
    if [ $end -eq 0 ]; then end=24; fi

    swan_cur_ofile_fname="wave_rtofs_current_${epoc_time}_${date_str}_${CYCLE}_f${FF}.dat"
    swan_cur_ofile="${OUTPUTdir}/${swan_cur_ofile_fname}"
    file="${G2CLIPPED}"
    
    swan_cur_ofile_fname="wave_rtofs_uv_${epoc_time}_${date_str}_${CYCLE}_f${FF}.dat"
    swan_cur_ofile="${OUTPUTdir}/${swan_cur_ofile_fname}"
    ${WGRIB2} -no_header -match "UOGRD:0 m below sea level:${end} hour fcst" -text ${CLIPdir}/UOGRD.dat ${G2CLIPPED}
    ${HOMEnwps}/exec/fix_ascii_point_data ${CLIPdir}/UOGRD.dat 9.999e+20 0.0 ${swan_cur_ofile}
    ${WGRIB2} -no_header -match "VOGRD:0 m below sea level:${end} hour fcst" -text ${CLIPdir}/VOGRD.dat ${G2CLIPPED}
    cat ${CLIPdir}/UOGRD.dat > ${CLIPdir}/cur.dat
    cat ${CLIPdir}/VOGRD.dat >> ${CLIPdir}/cur.dat
    ${HOMEnwps}/exec/fix_ascii_point_data ${CLIPdir}/cur.dat 9.999e+20 0.0 ${swan_cur_ofile}
    
    #if [ "${IS_LDMSERVER}" == "TRUE" ]
    #then
    #	cd ${OUTPUTdir}
    #   swan_dist_file="${OUTPUTdir}/rtofs_swan_${epoc_time}_${date_str}_t${CYCLE}z_f${FF}_${REGION}.tar.gz" 
    #   if [ ! -e ${swan_dist_file} ]
    #   then
    #       echo "Creating SWAN distrib file ${swan_dist_file}" | tee -a ${LOGfile}
    #       cd ${OUTPUTdir}
    #       tar cvfz ${swan_dist_file} ${swan_cur_ofile_fname} rtofs_current_start_time.txt rtofs_current_domain.txt 
    #       cd ${CLIPdir}
    #       if [ -e ${ldm_server_script} ]; then source ${ldm_server_script}; fi 
    #   fi
    #fi
}

datetime=`date -u`
echo "Starting download at at $datetime UTC" | tee -a ${LOGfile}
echo "Our spool DIR for FTP data is: ${SPOOLdir}" | tee -a ${LOGfile}  
echo "Our spool DIR for FTP forecast data is: ${PRODUCTdir}" | tee -a ${LOGfile}  
echo "RTOFSHOURS = ${RTOFSHOURS}" | tee -a ${LOGfile}
echo "RTOFSTIMESTEP = ${RTOFSTIMESTEP}" | tee -a ${LOGfile}
CLIPdir_org="${CLIPdir}"

# Create WFO list to make init files for
export USHdir=$USHnwps
${USHdir}/make_wfolist.sh RTOFS
#source ${HOMEnwps}/fix/wfolist_rtofs.sh
source ${VARdir}/wfolist_rtofs.sh

if [ "${WFOLIST}" == "" ] 
then
    echo "ERROR - Our WFOLIST is empty" | tee -a ${LOGfile}
    echo "ERROR - Check the ${HOMEnwps}/fix/wfolist.dat file" | tee -a ${LOGfile}
    export err=1; err_chk
fi

source $USHdir/rtofs/bin/rtofs_grib2_sector_list.sh
if [ "${RTOFS_SECTOR_LIST}" == "" ]
then
    echo "ERROR - Our RTOFS SECTOR LIST is empty" | tee -a ${LOGfile}
    echo "ERROR - Check the ${USHdir}/rtofs/bin/rtofs_grib2_sector_list.sh file" | tee -a ${LOGfile}
    export err=1; err_chk
fi

# Set our download URL for our forecast hours for nowcast n024, where hour F024 is F000
# ftp://ftp.ncep.noaa.gov/pub/data/nccf/com/rtofs/prod/rtofs.YYYYMMDD/rtofs_glo.t00z.n024_${RTOFSSECTOR}_std.grb2
#url="ftp://ftp.ncep.noaa.gov/pub/data/nccf/com/rtofs/prod/rtofs.${YYYYMMDD}"

echo "RTOFS_SECTOR_LIST = ${RTOFS_SECTOR_LIST}" | tee -a ${LOGfile} 

for RTOFSSECTOR in ${RTOFS_SECTOR_LIST}
do
    file="rtofs_glo.t${CYCLE}z.n024_${RTOFSSECTOR}_std.grb2"
    outfile="${file}"
    cd ${SPOOLdir}
    echo "Downloading ${COMINrtofs}/$file to $outfile" | tee -a ${LOGfile}
    #echo "$WGET ${WGETargs} ${url}/${file}" | tee -a ${LOGfile} 2>&1
    #$WGET ${WGETargs} ${url}/${file} | tee -a ${LOGfile} 2>&1
    cp -rp ${COMINrtofs}/${file} .
    if [ "$?" != "0" ] 
    then
	echo "ERROR - downling file ${COMINrtofs}/${file}"
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
done

prevdownloads=0
totalwfo=0

for site in ${WFOLIST}
do
    let totalwfo=totalwfo+1
    WFO=$(echo ${site} | tr [:lower:] [:upper:])
    wfo=$(echo ${site} | tr [:upper:] [:lower:])
    source ${FIXnwps}/configs/${wfo}_ncep_config.sh    
    OUTPUTdir="${RUNdir}/${wfo}_output"
    CLIPdir="${CLIPdir_org}/${wfo}"
    if [ ! -e ${OUTPUTdir} ]; then mkdir -p ${OUTPUTdir}; fi
    if [ ! -e ${CLIPdir} ]; then mkdir -p ${CLIPdir}; fi

    #echo 'Invoking touch. File is:'
    #echo ${OUTPUTdir}/LOCKFILE
    #touch ${OUTPUTdir}/LOCKFILE

    if [ "${RTOFSDOMAIN}" == "" ] || [ "${RTOFSNX}" == "" ] || [ "${RTOFSNY}" == "" ]
    then
	echo "ERROR - Your RTOFS domain is not set for ${WFO}"
	echo "ERROR - Need to set RTOFSDOMAIN, RTOFSNX, and  RTOFSNY vars for ${WFO}"
	echo "ERROR - Check your ${FIXnwps}/configs/${wfo}_ncep_config.sh config"
	continue
    fi
    RTOFSSECTOR=$(echo ${RTOFSSECTOR} | tr [:upper:] [:lower:])
    if [ "${RTOFSSECTOR}" == "" ]
    then
	echo "ERROR - Your RTOFS SECTOR is not set for ${WFO}"
	echo "ERROR - Need to set RTOFSSECTOR vars for ${WFO}"
	echo "ERROR - Check your ${FIXnwps}/configs/${wfo}_ncep_config.sh config"
	continue
    fi

    epoc_time=""
    while [ "${epoc_time}" == "" ] || [ "${epoc_time}" == "-1" ]; do
       epoc_time=$(${WGRIB2} -d 1 -unix_time ${SPOOLdir}/rtofs_glo.t${CYCLE}z.n024_${RTOFSSECTOR}_std.grb2 | grep "1:0" | grep "unix" | awk -F= '{ print $3 }')
    done
    epoc_time=$(echo "$epoc_time - 3600" | bc)
    date_str=`echo ${epoc_time} | awk '{ print strftime("%Y%m%d", $1) }'`
    if [ -e  ${OUTPUTdir}/wave_rtofs_uv_${epoc_time}_${date_str}_${CYCLE}_f000.dat ] &&
	[ -e ${OUTPUTdir}/rtofs_current_start_time.txt  ] &&
	[ -e ${OUTPUTdir}/rtofs_current_domain.txt ]
    then
	file_etime=$(cat ${OUTPUTdir}/rtofs_current_start_time.txt )
	if [ "${file_etime}" == "${epoc_time}" ]
	then 
	    echo "INTO - ${OUTPUTdir}/wave_rtofs_uv_${epoc_time}_${date_str}_${CYCLE}_f000.dat clip already exists" | tee -a ${LOGfile}
	    if [ -e  ${OUTPUTdir}/wave_rtofs_uv_${epoc_time}_${date_str}_${CYCLE}_f144.dat ]; then  let prevdownloads=prevdownloads+1; fi
	    continue
	fi
    fi

    echo ${epoc_time} > ${OUTPUTdir}/rtofs_current_start_time.txt
    echo "RTOFSDOMAIN:${RTOFSDOMAIN}" > ${OUTPUTdir}/rtofs_current_domain.txt

    # Set our script variables from the WFO config
    NX=${RTOFSNX}
    NY=${RTOFSNY}
    LL_LON=$(echo ${RTOFSDOMAIN} | awk '{ print $1}')
    LL_LAT=$(echo ${RTOFSDOMAIN} | awk '{ print $2}')
    DX=$(echo ${RTOFSDOMAIN} | awk '{ print $6}')
    DY=$(echo ${RTOFSDOMAIN} | awk '{ print $7}')

    echo "${WFO} RTOFS parms:"
    echo "RTOFSHOURS = ${RTOFSHOURS}"
    echo "RTOFSTIMESTEP = ${RTOFSTIMESTEP}"
    echo "RTOFSSECTOR = ${RTOFSSECTOR}"
    echo "RTOFSDOMAIN = ${RTOFSDOMAIN}"
    echo "NX = ${RTOFSNX}"
    echo "NY = ${RTOFSNY}"
    echo "LL_LON= ${LL_LON}"
    echo "LL_LAT= ${LL_LAT}"
    echo "DX = ${DX}"
    echo "DY = ${DY}"

    G2OUT=rtofs_${RTOFSSECTOR}.grb2
    G2CLIPPED=rtofs_${RTOFSSECTOR}_clipped.grb2
    cat rtofs_glo.t${CYCLE}z.n024_${RTOFSSECTOR}_std.grb2 > ${G2OUT}
    echo "Clip and reproject to LAT/LON grid" | tee -a ${LOGfile} 2>&1
    echo "${WGRIB2} ${G2OUT} -new_grid latlon ${LL_LON}:${NX}:${DX} ${LL_LAT}:${NY}:${DY} ${G2CLIPPED}" | tee -a ${LOGfile}
    ${WGRIB2} ${G2OUT} -new_grid latlon ${LL_LON}:${NX}:${DX} ${LL_LAT}:${NY}:${DY} ${G2CLIPPED} | tee -a ${LOGfile} 2>&1
    MakeClip 0

done

echo "INTO - Total WFOs ${totalwfo}" | tee -a ${LOGfile}  
echo "INTO - Total previous downloads ${prevdownloads}" | tee -a ${LOGfile}  

if [ $totalwfo -eq $prevdownloads ]
then
    echo "INFO - All files for all WFOs were downloaded for ${date_str} ${CYCLE} cycle" | tee -a ${LOGfile}
    #RemoveLockFile
    exit 0
fi

# Set our download URL for our forecast hours
# ftp://ftp.ncep.noaa.gov/pub/data/nccf/com/rtofs/prod/rtofs.YYYYMMDD
# rtofs_glo.t00z.f024_${RTOFSSECTOR}_std.grb2 (hourly, 1-24h)
# rtofs_glo.t00z.f048_${RTOFSSECTOR}_std.grb2 (hourly, 25-48h)
# rtofs_glo.t00z.f072_${RTOFSSECTOR}_std.grb2 (hourly, 47-72h)
# rtofs_glo.t00z.f144_${RTOFSSECTOR}_std.grb2 (3-hourly 75-144h)
#url="ftp://ftp.ncep.noaa.gov/pub/data/nccf/com/rtofs/prod/rtofs.${YYYYMMDD}"

FHOURS="024 048 072 144"

for RTOFSSECTOR in ${RTOFS_SECTOR_LIST}
do
    for FF in ${FHOURS}
    do
	file="rtofs_glo.t${CYCLE}z.f${FF}_${RTOFSSECTOR}_std.grb2"
	outfile="${file}"
	cd ${SPOOLdir}
	echo "Downloading $url/$file to $outfile" | tee -a ${LOGfile}
	#echo "$WGET ${WGETargs} ${url}/${file}" | tee -a ${LOGfile} 2>&1
	#$WGET ${WGETargs} ${url}/${file} | tee -a ${LOGfile} 2>&1
	cp -rp ${COMINrtofs}/${file} .
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
    done
done

datetime=`date -u`
echo "Ending download at $datetime UTC" | tee -a ${LOGfile}

for site in ${WFOLIST}
do
    WFO=$(echo ${site} | tr [:lower:] [:upper:])
    wfo=$(echo ${site} | tr [:upper:] [:lower:])
    source ${FIXnwps}/configs/${wfo}_ncep_config.sh    
    RTOFSSECTOR=$(echo ${RTOFSSECTOR} | tr [:upper:] [:lower:])
    OUTPUTdir="${RUNdir}/${wfo}_output"
    CLIPdir="${CLIPdir_org}/${wfo}"

    # Set our script variables from the WFO config
    NX=${RTOFSNX}
    NY=${RTOFSNY}
    LL_LON=$(echo ${RTOFSDOMAIN} | awk '{ print $1}')
    LL_LAT=$(echo ${RTOFSDOMAIN} | awk '{ print $2}')
    DX=$(echo ${RTOFSDOMAIN} | awk '{ print $6}')
    DY=$(echo ${RTOFSDOMAIN} | awk '{ print $7}')

    echo "${WFO} RTOFS parms:"
    echo "RTOFSHOURS = ${RTOFSHOURS}"
    echo "RTOFSTIMESTEP = ${RTOFSTIMESTEP}"
    echo "RTOFSSECTOR = ${RTOFSSECTOR}"
    echo "RTOFSDOMAIN = ${RTOFSDOMAIN}"
    echo "NX = ${RTOFSNX}"
    echo "NY = ${RTOFSNY}"
    echo "LL_LON= ${LL_LON}"
    echo "LL_LAT= ${LL_LAT}"
    echo "DX = ${DX}"
    echo "DY = ${DY}"

    cd ${SPOOLdir}
    G2OUT=rtofs_${RTOFSSECTOR}.grb2
    G2CLIPPED=rtofs_${RTOFSSECTOR}_clipped.grb2
    cat rtofs_glo.t${CYCLE}z.f024_${RTOFSSECTOR}_std.grb2 > ${G2OUT}
    cat rtofs_glo.t${CYCLE}z.f048_${RTOFSSECTOR}_std.grb2 >> ${G2OUT}
    cat rtofs_glo.t${CYCLE}z.f072_${RTOFSSECTOR}_std.grb2 >> ${G2OUT}
    cat rtofs_glo.t${CYCLE}z.f144_${RTOFSSECTOR}_std.grb2 >> ${G2OUT}

    echo "Clip and reproject to LAT/LON grid for ${WFO}" | tee -a ${LOGfile} 2>&1
    echo "${WGRIB2} ${G2OUT} -new_grid latlon ${LL_LON}:${NX}:${DX} ${LL_LAT}:${NY}:${DY} ${G2CLIPPED}" | tee -a ${LOGfile}
    ${WGRIB2} ${G2OUT} -new_grid latlon ${LL_LON}:${NX}:${DX} ${LL_LAT}:${NY}:${DY} ${G2CLIPPED} | tee -a ${LOGfile} 2>&1
    
    end=$TIMESTEP
    cd ${SPOOLdir}
    until [ $end -gt $HOURS ]; do
	MakeClip ${end}
	let end+=$TIMESTEP
    done

    #rm ${OUTPUTdir}/LOCKFILE
    #--- Copy WFO output to COMOUT
    mkdir -p ${COMOUT}/rtofs/${wfo}_output
    cp ${OUTPUTdir}/wave_rtofs_uv_${epoc_time}_${date_str}_${CYCLE}_f*.dat ${COMOUT}/rtofs/${wfo}_output/
    cp ${OUTPUTdir}/rtofs_current_domain.txt ${COMOUT}/rtofs/${wfo}_output/
    cp ${OUTPUTdir}/rtofs_current_start_time.txt ${COMOUT}/rtofs/${wfo}_output/
done

cd ${SPOOLdir}
rm -fv ${SPOOLdir}/.listing
find ${SPOOLdir} -name "*.grb2" -print | xargs rm -fv
find ${SPOOLdir} -name "*.out" -print | xargs rm -fv

datetime=`date -u`
echo "Ending RTOFS make clips at $datetime UTC" | tee -a ${LOGfile}

#for site in ${WFOLIST}
#do
#    WFO=$(echo ${site} | tr [:lower:] [:upper:])
#    wfo=$(echo ${site} | tr [:upper:] [:lower:])
#    source ${FIXnwps}/configs/${wfo}_ncep_config.sh    
#    OUTPUTdir="${RUNdir}/${wfo}_output"
#    echo "Purging previous run from ${OUTPUTdir}" | tee -a ${LOGfile} 2>&1
#    ${BINdir}/purge_rtofs.sh ${OUTPUTdir} ${RTOFSHOURS} | tee -a ${LOGfile}
#done
 
if [ $end -ge ${RTOFSHOURS} ]
then 
    echo "We completed the download out to ${HOURS}" | tee -a ${LOGfile} 2>&1
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

#!/bin/bash
set -xa
# -----------------------------------------------------------
# UNIX Shell Script
# Tested Operating System(s): RHEL 5, 6
# Tested Run Level(s): 3, 5
# Shell Used: BASH shell
# Original Author(s): Douglas.Gaer@noaa.gov
# File Creation Date: 03/05/2013
# Date Last Modified: 03/19/2013
# Comment:
#
# Version control: 1.03
#
# Support Team:
#
# Contributors: Roberto Padilla
#
# -----------------------------------------------------------
# ------------- Program Description and Details -------------
# -----------------------------------------------------------
#
# Script used to make STOFS SWAN init files all WFOs.
#
#
# -----------------------------------------------------------
set -xa

# NOTE: Data is processed on the server in UTC
export TZ=UTC

# Script variables
# ===========================================================
# Set our top level data processing directory
PRODUCTdir="${RUNdir}/ncep_hourly"
SPOOLdir="${RUNdir}/ncep_hourly.spool"

# NOTE: This is our final out DIR
# NOTE: Change this to the FTP/HTTP server download path
INGESTdir="${COMOUT}"
YYYYMMDD=${PDY}
CYCLE=${cyc}
NCHOURS=6  # 5 hindcast hours plus 1 nowcast hour
HOURS="${STOFSHOURS}"
TIMESTEP="${STOFSTIMESTEP}"

#mkdir -p ${RUNdir}/eka_output_cur
#python ${USHnwps}/stofs/bin/get_stofs_currents.py -124.300 -124.150 40.700 40.850 ${HOURS} ${RUNdir}/eka_output_cur /gpfs/dell1/nco/ops/#com/stofs/prod/stofs.20210806/stofs.t00z.fields.cwl.vel.forecast.nc

#mkdir -p ${RUNdir}/pqr_output_cur
#python ${USHnwps}/stofs/bin/get_stofs_currents.py -126.28 -123.30 43.50 47.15 ${HOURS} ${RUNdir}/pqr_output_cur /gpfs/dell1/nco/ops/com/stofs/prod/stofs.20210806/stofs.t00z.fields.cwl.vel.forecast.nc

#exit 0

if [ "${STOFSCUR_REGION}" == "" ]; then STOFSCUR_REGION="conus.east"; fi

check_bad_nc_file() {
    f="${1}"

    if [ ! -e "${f}" ]; then
        return 1
    fi

    if [ ! -s "${f}" ]; then
        return 1
    fi

    return 0
}

warn_and_disable_stofscur_nc() {
    msg="${1}"
    echo "WARNING: ${msg}" | tee -a ${LOGfile}
}

function process_wfolist() {
    WFO=$(echo ${site} | tr [:lower:] [:upper:])
    wfo=$(echo ${site} | tr [:upper:] [:lower:])
    echo "Creating STOFS init files for ${WFO}"
    source ${FIXnwps}/configs/${wfo}_ncep_config.sh
    export err=$?; err_chk
    STOFSCUR_REGION=$(echo ${STOFSCUR_REGION} | tr [:upper:] [:lower:])
#..........................................
    OUTPUTdir="${RUNdir}/${wfo}_output"
    CLIPdir="${RUNdir}/${wfo}_hourly"
    INGESTdir="${INGESTdir_org}/${wfo}"
    if [ ! -e ${OUTPUTdir} ]; then mkdir -p ${OUTPUTdir}; fi
    if [ ! -e ${CLIPdir} ]; then mkdir -p ${CLIPdir}; fi
#    if [ ! -e ${INGESTdir} ]; then mkdir -p ${INGESTdir}; fi

    if [ "${STOFSCUR_REGION}" == "none" ];then
        echo "ERROR - No STOFS region for ${WFO}"
        echo "ERROR - Skipping init files for ${WFO}"
    	continue
    fi

    NX=${STOFSCURNX}
    NY=${STOFSCURNY}
    LL_LON=$(echo ${STOFSCURDOMAIN} | awk '{ print $1}')
    LL_LAT=$(echo ${STOFSCURDOMAIN} | awk '{ print $2}')
    DX=$(echo ${STOFSCURDOMAIN} | awk '{ print $6}')
    DY=$(echo ${STOFSCURDOMAIN} | awk '{ print $7}')

    echo "STOFSCUR_REGION = ${STOFSCUR_REGION}"
    echo "STOFSCURDOMAIN = ${STOFSCURDOMAIN}"
    echo "NX = ${NX}"
    echo "NY = ${NY}"
    echo "LL_LON= ${LL_LON}"
    echo "LL_LAT= ${LL_LAT}"
    echo "DX = ${DX}"
    echo "DY = ${DY}"

    # Get the first forecast cycle
    touch ${OUTPUTdir}/LOCKFILE
    FF="000"

    file="${STOFSCUR_BASIN}.t${CYCLE}z.fields.cwl.vel.nc"

    echo "Checking source NetCDF file ${COMINstofs}/${file}"

    if ! check_bad_nc_file "${COMINstofs}/${file}"; then
       warn_and_disable_stofscur_nc "STOFS current file ${COMINstofs}/${file} is missing or 0-byte. Run will continue without STOFS current fields for ${WFO}."
       rm -f ${OUTPUTdir}/LOCKFILE
       return
    fi

    echo "Copying ${COMINstofs}/${file} to ${CLIPdir}/${file}"
    cp -rp "${COMINstofs}/${file}" "${CLIPdir}/${file}"
    rc=$?
    sleep 10

    if [ "${rc}" != "0" ] && [ ! -e "${CLIPdir}/${file}" ];then
       sleep 2
       echo "Retrying copy of ${CLIPdir}/${file}"
       cp -rp "${COMINstofs}/${file}" "${CLIPdir}/${file}"
       rc=$?
       sleep 10

       if [ "${rc}" != "0" ] && [ ! -e "${CLIPdir}/${file}" ];then
          echo "ERROR - copying file ${CLIPdir}/${file}"
          export err=1
          err_chk
       fi
    fi

    #while [ "${epoc_time}" == "" ]; do
    #   echo "Extracting epoc time for ${wfo}"
    #   epoc_time=`${WGRIB2} -unix_time ${SPOOLdir}/${file} | grep "1:4:unix" | awk -F= '{ print $3 }'`
    #done
    #epoc_time=`${WGRIB2} -unix_time ${SPOOLdir}/${file} | grep "1:4:unix" | awk -F= '{ print $3 }'`
    #date_str=`echo ${epoc_time} | awk '{ print strftime("%Y%m%d", $1) }'`
    #echo ${epoc_time} > ${OUTPUTdir}/stofs_waterlevel_start_time.txt
    echo "STOFSCURDOMAIN:${STOFSCURDOMAIN}" > ${OUTPUTdir}/stofs_current_domain.txt
    swan_time_ofile="${OUTPUTdir}/stofs_current_start_time.txt"
    touch ${swan_time_ofile}

    swan_wl_ofile_fname="wave_stofs_uv_${epoc_time}_${date_str}_${CYCLE}_f${FF}.dat"
    swan_wl_ofile="${OUTPUTdir}"

    #if [ ! -e ${swan_wl_ofile} ];then
    if [ -e ${swan_wl_ofile} ];then
        lonmin=$(echo "$LL_LON - 360." | bc)
        lonmax=$(echo "$lonmin + $DX * $NX" | bc)
        latmin=${LL_LAT}
        latmax=$(echo "$latmin + $DY * $NY" | bc)
        echo "Calling get_stofs_currents.py:"
        echo "lonmin = ${lonmin}"
        echo "lonmax = ${lonmax}"
        echo "latmin = ${latmin}"
        echo "latmax = ${latmax}"
        echo "NCHOURS = ${NCHOURS}"
        echo "HOURS = ${HOURS}"
        echo "CLIPdir/file = ${CLIPdir}/${file}"
	echo "swan_wl_ofile = ${swan_wl_ofile}"
        echo "swan_time_ofile = ${swan_time_ofile}"
        #AW ${USHnwps}/stofs/bin/get_stofs_currents.py ${lonmin} ${lonmax} ${latmin} ${latmax} ${NCHOURS} ${CLIPdir}/${file1} ${swan_wl_ofile} ${swan_time_ofile} nowcast
    	#AW export err=$?; err_chk
        ${USHnwps}/stofs/bin/get_stofs_currents.py ${lonmin} ${lonmax} ${latmin} ${latmax} ${HOURS} ${CLIPdir}/${file} ${swan_wl_ofile} ${swan_time_ofile} forecast
	export err=$?; err_chk
        #------------------------------------------------------------
    else
        echo "Already created ${swan_wl_ofile}"
        echo "Skipping this file"
    fi

    rm ${OUTPUTdir}/LOCKFILE
    #--- Copy WFO output to COMOUT
    mkdir -p ${COMOUT}/stofs/${wfo}_output
    cp ${OUTPUTdir}/wave_stofs_uv_*_${CYCLE}_f*.dat ${COMOUT}/stofs/${wfo}_output/
    cp ${OUTPUTdir}/stofs_current_domain.txt ${COMOUT}/stofs/${wfo}_output/
    cp ${OUTPUTdir}/stofs_current_start_time.txt ${COMOUT}/stofs/${wfo}_output/
}

# Make any of the following directories if needed
mkdir -p ${PRODUCTdir}
mkdir -p ${SPOOLdir}
mkdir -p ${VARdir}
mkdir -p ${COMOUT}/stofs/

# Cleanup
echo "Clean up working directory ${VARdir}..."
files=(${VARdir}/hasstofsdownload_${CYCLE}z*)
files_exit=false
for f_file in "${files[@]}"; do
  # Check if any file actually exists
  [ -e "$f_file" ] && files_exist=true && break
done
if [ "$files_exist" = true ]; then
  rm ${VARdir}/hasstofsdownload_${CYCLE}z*
fi
if [ -e "${VARdir}/wfolist.dat" ]; then
  rm ${VARdir}/wfolist.dat
fi
if [ -e "${VARdir}/wfolist_sorted_stofscur.dat" ]; then
  rm ${VARdir}/wfolist_sorted_stofscur.dat
fi
if [ -e "${VARdir}/wfolist_stofscur.sh" ]; then
  rm ${VARdir}/wfolist_stofscur.sh
fi

echo "Our spool DIR for FTP n000 data is: ${SPOOLdir}"
echo "Our spool DIR for FTP forecast data is: ${PRODUCTdir}"

# Create WFO list to make init files for
#${USHnwps}/make_wfolist.sh STOFS
#export err=$?; err_chk
echo -n 'export WFOLIST="EKA PQR SEW AER"' >> ${VARdir}/wfolist_stofscur.sh
source ${VARdir}/wfolist_stofscur.sh

if [ "${WFOLIST}" == "" ];then
    echo "ERROR - Our WFOLIST is empty"
    echo "ERROR - Check the ${FIXnwps}/wfolist.dat file"
    export err=1; err_chk
fi

# Set our script variables from the global config
echo "STOFSHOURS = ${STOFSHOURS}"
echo "STOFSTIMESTEP = ${STOFSTIMESTEP}"
INGESTdir_org="${INGESTdir}"

if [ -e ${RUNdir}/cgn_cmdfile ];then
    rm ${RUNdir}/cgn_cmdfile
fi
for site in ${WFOLIST};do
    echo "export site=${site}; process_wfolist " >> ${RUNdir}/cgn_cmdfile
    #export site=${site}; process_wfolist
done

#aprun -n36 -N18 -j1 -d1 cfp ${RUNdir}/cgn_cmdfile
mpiexec -np 36 --cpu-bind verbose,core cfp ${RUNdir}/cgn_cmdfile
#export site=EKA; process_wfolist
#export site=PQR; process_wfolist
#export site=SEW; process_wfolist
#export site=AER; process_wfolist

export err=$?; err_chk

echo "Ending download at $($MDATE) UTC"
echo "Processing complete"
echo "Exiting..."
exit 0
# -----------------------------------------------------------
# *******************************
# ********* End of File *********
# *******************************

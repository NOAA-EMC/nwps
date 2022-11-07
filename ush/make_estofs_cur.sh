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
# Script used to make ESTOFS SWAN init files all WFOs. 
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
HOURS="${ESTOFSHOURS}"
TIMESTEP="${ESTOFSTIMESTEP}"

#mkdir -p ${RUNdir}/eka_output_cur
#python ${USHnwps}/estofs/bin/get_estofs_currents.py -124.300 -124.150 40.700 40.850 ${HOURS} ${RUNdir}/eka_output_cur /gpfs/dell1/nco/ops/#com/estofs/prod/estofs.20210806/estofs.t00z.fields.cwl.vel.forecast.nc

#mkdir -p ${RUNdir}/pqr_output_cur
#python ${USHnwps}/estofs/bin/get_estofs_currents.py -126.28 -123.30 43.50 47.15 ${HOURS} ${RUNdir}/pqr_output_cur /gpfs/dell1/nco/ops/com/estofs/prod/estofs.20210806/estofs.t00z.fields.cwl.vel.forecast.nc

#exit 0

if [ "${ESTOFSCUR_REGION}" == "" ]; then ESTOFSCUR_REGION="conus.east"; fi

function process_wfolist() {
    WFO=$(echo ${site} | tr [:lower:] [:upper:])
    wfo=$(echo ${site} | tr [:upper:] [:lower:])
    echo "Creating ESTOFS init files for ${WFO}" 
    source ${FIXnwps}/configs/${wfo}_ncep_config.sh    
    export err=$?; err_chk
    ESTOFSCUR_REGION=$(echo ${ESTOFSCUR_REGION} | tr [:upper:] [:lower:])
#..........................................
     if [ "${ESTOFSCUR_BASIN}" == "stofs_2d_glo" ] && [ "${ESTOFSCUR_REGION}" == "conus.east" ]
     then
       hasdownload_000=${hasDL[1]}
     elif [ "${ESTOFSCUR_BASIN}" == "stofs_2d_glo" ] && [ "${ESTOFSCUR_REGION}" == "puertori" ]
     then
       hasdownload_000=${hasDL[2]}
     elif [ "${ESTOFSCUR_BASIN}" == "stofs_2d_glo" ] && [ "${ESTOFSCUR_REGION}" == "conus.west" ]
     then
       hasdownload_000=${hasDL[3]}
     elif [ "${ESTOFSCUR_BASIN}" == "stofs_2d_glo" ] && [ "${ESTOFSCUR_REGION}" == "hawaii" ]
     then
       hasdownload_000=${hasDL[4]}
     elif [ "${ESTOFSCUR_BASIN}" == "stofs_2d_glo" ] && [ "${ESTOFSCUR_REGION}" == "alaska" ]
     then
       hasdownload_000=${hasDL[5]}
     elif [ "${ESTOFSCUR_BASIN}" == "stofs_2d_glo" ] && [ "${ESTOFSCUR_REGION}" == "guam" ]
     then
       hasdownload_000=${hasDL[6]}
     fi
#................................................
    OUTPUTdir="${RUNdir}/${wfo}_output"
    CLIPdir="${RUNdir}/${wfo}_hourly"
    INGESTdir="${INGESTdir_org}/${wfo}"
    if [ ! -e ${OUTPUTdir} ]; then mkdir -p ${OUTPUTdir}; fi
    if [ ! -e ${CLIPdir} ]; then mkdir -p ${CLIPdir}; fi
#    if [ ! -e ${INGESTdir} ]; then mkdir -p ${INGESTdir}; fi

    if [ "${ESTOFSCUR_REGION}" == "none" ];then
    	echo "ERROR - No ESTOFS region for ${WFO}" 
    	echo "ERROR - Skipping init files for ${WFO}" 
    	continue
    fi

    NX=${ESTOFSCURNX}
    NY=${ESTOFSCURNY}
    LL_LON=$(echo ${ESTOFSCURDOMAIN} | awk '{ print $1}')
    LL_LAT=$(echo ${ESTOFSCURDOMAIN} | awk '{ print $2}')
    DX=$(echo ${ESTOFSCURDOMAIN} | awk '{ print $6}')
    DY=$(echo ${ESTOFSCURDOMAIN} | awk '{ print $7}')
    
    echo "ESTOFSCUR_REGION = ${ESTOFSCUR_REGION}"
    echo "ESTOFSCURDOMAIN = ${ESTOFSCURDOMAIN}"
    echo "NX = ${NX}"
    echo "NY = ${NY}"
    echo "LL_LON= ${LL_LON}"
    echo "LL_LAT= ${LL_LAT}"
    echo "DX = ${DX}"
    echo "DY = ${DY}"

    # Get the first forecast cycle
    touch ${OUTPUTdir}/LOCKFILE
    FF="000"
    file1="${ESTOFSCUR_BASIN}.t${CYCLE}z.fields.cwl.vel.nc"
    file2="${ESTOFSCUR_BASIN}.t${CYCLE}z.fields.cwl.vel.nc"
    outfile1="${file1}"
    outfile2="${file2}"
    cd ${SPOOLdir}

    if [ "${hasdownload_000}" == "" ]; then hasdownload_000="false"; fi
    
    if [ "${hasdownload_000}" == "false" ];then
        if [ "${ESTOFSCUR_BASIN}" == "stofs_2d_glo" ] && [ "${ESTOFSCUR_REGION}" == "conus.east" ];then
           hasDL[1]="true"
        elif [ "${ESTOFSCUR_BASIN}" == "stofs_2d_glo" ] && [ "${ESTOFSCUR_REGION}" == "puertori" ];then
           hasDL[2]="true"
        elif [ "${ESTOFSCUR_BASIN}" == "stofs_2d_glo" ] && [ "${ESTOFSCUR_REGION}" == "conus.west" ];then
           hasDL[3]="true"
        elif [ "${ESTOFSCUR_BASIN}" == "stofs_2d_glo" ] && [ "${ESTOFSCUR_REGION}" == "hawaii" ];then
           hasDL[4]="true"
        elif [ "${ESTOFSCUR_BASIN}" == "stofs_2d_glo" ] && [ "${ESTOFSCUR_REGION}" == "alaska" ];then
           hasDL[5]="true"
        elif [ "${ESTOFSCUR_BASIN}" == "stofs_2d_glo" ] && [ "${ESTOFSCUR_REGION}" == "guam" ];then
           hasDL[6]="true"
        fi

        # Copy ESTOFS nowcast output
        echo "Downloading ${SPOOLdir}/$file1 to $outfile1" 
        echo "cp -p ${COMINestofscur}/${file1} ."
        cp -rp ${COMINestofscur}/${file1} .
        sleep 10
        if [ "$?" != "0" ] && [ ! -e ${file1} ];then
           sleep 2
           echo "ERROR - downling file ${PRODUCTdir}/${file1}" 
        fi
        cp -rp ${COMINestofscur}/${file1} .
        sleep 10
        if [ "$?" != "0" ] && [ ! -e ${file1} ];then
           echo "ERROR - downling file ${PRODUCTdir}/${file1}" 
           export err=1; err_chk
        fi

        # Copy ESTOFS forecast output
        echo "Downloading ${SPOOLdir}/$file2 to $outfile2" 
        echo "cp -p ${COMINestofscur}/${file2} ."
        cp -rp ${COMINestofscur}/${file2} .
        sleep 10
        if [ "$?" != "0" ] && [ ! -e ${file2} ];then
           sleep 2
           echo "ERROR - downling file ${PRODUCTdir}/${file2}" 
        fi
        cp -rp ${COMINestofscur}/${file2} .
        sleep 10
        if [ "$?" != "0" ] && [ ! -e ${file2} ];then
           echo "ERROR - downling file ${PRODUCTdir}/${file2}" 
           export err=1; err_chk
        fi

    fi
    
    hasdownload_000="true"

    #while [ "${epoc_time}" == "" ]; do
    #   echo "Extracting epoc time for ${wfo}"
    #   epoc_time=`${WGRIB2} -unix_time ${SPOOLdir}/${file} | grep "1:4:unix" | awk -F= '{ print $3 }'`
    #done
    #epoc_time=`${WGRIB2} -unix_time ${SPOOLdir}/${file} | grep "1:4:unix" | awk -F= '{ print $3 }'`
    #date_str=`echo ${epoc_time} | awk '{ print strftime("%Y%m%d", $1) }'`
    #echo ${epoc_time} > ${OUTPUTdir}/estofs_waterlevel_start_time.txt
    echo "ESTOFSCURDOMAIN:${ESTOFSCURDOMAIN}" > ${OUTPUTdir}/estofs_current_domain.txt
    swan_time_ofile="${OUTPUTdir}/estofs_current_start_time.txt"
    touch ${swan_time_ofile}

    swan_wl_ofile_fname="wave_estofs_uv_${epoc_time}_${date_str}_${CYCLE}_f${FF}.dat"
    swan_wl_ofile="${OUTPUTdir}"

    #if [ ! -e ${swan_wl_ofile} ];then
    if [ -e ${swan_wl_ofile} ];then
        #MakeClip ${SPOOLdir} ${file} 0 ${WFO}
        #--- Make local copy of input file --------------------------
        cp -p ${SPOOLdir}/${file1} ${CLIPdir}/${file1}
        sleep 10
        cp -p ${SPOOLdir}/${file2} ${CLIPdir}/${file2}
        sleep 10
        lonmin=$(echo "$LL_LON - 360." | bc)
        lonmax=$(echo "$lonmin + $DX * $NX" | bc)
        latmin=${LL_LAT}
        latmax=$(echo "$latmin + $DY * $NY" | bc)
        echo "Calling get_estofs_currents.py:"
        echo "lonmin = ${lonmin}"
        echo "lonmax = ${lonmax}"
        echo "latmin = ${latmin}"
        echo "latmax = ${latmax}"
        echo "NCHOURS = ${NCHOURS}"
        echo "HOURS = ${HOURS}"
        echo "CLIPdir/file1 = ${CLIPdir}/${file1}"
        echo "CLIPdir/file2 = ${CLIPdir}/${file2}"
	echo "swan_wl_ofile = ${swan_wl_ofile}"
        echo "swan_time_ofile = ${swan_time_ofile}"
        #AW ${USHnwps}/estofs/bin/get_estofs_currents.py ${lonmin} ${lonmax} ${latmin} ${latmax} ${NCHOURS} ${CLIPdir}/${file1} ${swan_wl_ofile} ${swan_time_ofile} nowcast
    	#AW export err=$?; err_chk
        ${USHnwps}/estofs/bin/get_estofs_currents.py ${lonmin} ${lonmax} ${latmin} ${latmax} ${HOURS} ${CLIPdir}/${file2} ${swan_wl_ofile} ${swan_time_ofile} forecast
	export err=$?; err_chk
        #------------------------------------------------------------
    else
    	echo "Already created ${swan_wl_ofile}" 
    	echo "Skipping this file" 
    fi

    rm ${OUTPUTdir}/LOCKFILE
    #--- Copy WFO output to COMOUT
    mkdir -p ${COMOUT}/estofs/${wfo}_output
    cp ${OUTPUTdir}/wave_estofs_uv_*_${CYCLE}_f*.dat ${COMOUT}/estofs/${wfo}_output/
    cp ${OUTPUTdir}/estofs_current_domain.txt ${COMOUT}/estofs/${wfo}_output/
    cp ${OUTPUTdir}/estofs_current_start_time.txt ${COMOUT}/estofs/${wfo}_output/
}

# Make any of the following directories if needed
mkdir -p ${PRODUCTdir}
mkdir -p ${SPOOLdir}
mkdir -p ${VARdir}
mkdir -p ${COMOUT}/estofs/

# Cleanup
echo "Clean up working directory ${VARdir}..."
rm ${VARdir}/hasestofsdownload_${CYCLE}z*
rm ${VARdir}/wfolist.dat
rm ${VARdir}/wfolist_sorted_estofscur.dat
rm ${VARdir}/wfolist_estofscur.sh

echo "Our spool DIR for FTP n000 data is: ${SPOOLdir}" 
echo "Our spool DIR for FTP forecast data is: ${PRODUCTdir}" 

# Create WFO list to make init files for
#${USHnwps}/make_wfolist.sh ESTOFS
#export err=$?; err_chk
echo -n 'export WFOLIST="EKA PQR SEW AER"' >> ${VARdir}/wfolist_estofscur.sh
source ${VARdir}/wfolist_estofscur.sh

if [ "${WFOLIST}" == "" ];then
    echo "ERROR - Our WFOLIST is empty" 
    echo "ERROR - Check the ${FIXnwps}/wfolist.dat file" 
    export err=1; err_chk
fi

# Set our script variables from the global config
echo "ESTOFSHOURS = ${ESTOFSHOURS}" 
echo "ESTOFSTIMESTEP = ${ESTOFSTIMESTEP}" 
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

export err=$?; err_check

datetime=`date -u`
echo "Ending download at $datetime UTC" 
echo "Processing complete" 
echo "Exiting..." 
exit 0
# -----------------------------------------------------------
# *******************************
# ********* End of File *********
# *******************************

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
HOURS="${ESTOFSHOURS}"
TIMESTEP="${ESTOFSTIMESTEP}"

if [ "${ESTOFS_REGION}" == "" ]; then ESTOFS_REGION="conus.east"; fi

function MakeClip() {
    DIR=${1}
    FILE=${2}
    HOUR=${3}
    WFO=${4}

    FF=`echo $HOUR`
    if [ $HOUR -le 99 ]; then
	    FF=`echo 0$HOUR`
    fi
    if [ $HOUR -le 9 ];then
	    FF=`echo 00$HOUR`
    fi

    clip_file="${WFO}SWAN_estofs.t${CYCLE}z.f${FF}.grib2"
    datfile="${WFO}SWAN_estofs.t${CYCLE}z.f${FF}.dat"

    if [ ! -e ${CLIPdir}/${clip_file} ];then
	    echo "Clip and reproject to LAT/LON grid" 
	    echo "${WGRIB2} ${DIR}/${FILE} -new_grid latlon ${LL_LON}:${NX}:${DX} ${LL_LAT}:${NY}:${DY} ${CLIPdir}/${clip_file}" 
	    ${WGRIB2} ${DIR}/${FILE} -new_grid latlon ${LL_LON}:${NX}:${DX} ${LL_LAT}:${NY}:${DY} ${CLIPdir}/${clip_file}
    fi

    swan_wl_ofile_fname="wave_estofs_waterlevel_${epoc_time}_${date_str}_${CYCLE}_f${FF}.dat"
    swan_wl_ofile="${OUTPUTdir}/${swan_wl_ofile_fname}"

    if [ ! -e ${swan_wl_ofile} ];then
	PARM="var"
	echo "Extract ${PARM} data"
	if [ "${ESTOFSUSEICEMASK}" == "TRUE" ]
	then
	    echo "Using sea ice to mask ESTOFS area with high ice density" | tee -a ${LOGfile}
	    echo "${WGRIB2} -no_header -match ${PARM} -bin ${CLIPdir}/${PARM}.bin ${CLIPdir}/${clip_file}"
	    ${WGRIB2} -no_header -match ${PARM} -bin ${CLIPdir}/${PARM}.bin ${CLIPdir}/${clip_file}
	    echo "Writing final DAT file with ice mask"  
	    ${EXECnwps}/seaice_mask -m${SEAICEBLOCKDENS} ${CLIPdir}/${PARM}.bin ${CLIPdir}/ice.bin > ${swan_wl_ofile}
	    rm -f ${CLIPdir}/${PARM}.bin
	else
	    echo "${WGRIB2} -no_header -match ${PARM} -text ${CLIPdir}/${PARM}.dat ${CLIPdir}/${clip_file}"
	    ${WGRIB2} -no_header -match ${PARM} -text ${CLIPdir}/${PARM}.dat ${CLIPdir}/${clip_file}
	    echo "Writing final DAT file"
	    ${EXECnwps}/fix_ascii_point_data ${CLIPdir}/${PARM}.dat 9.999e+20 0.0 ${swan_wl_ofile}
	    rm -f ${CLIPdir}/${PARM}.dat
	fi
    fi
}

function process_wfolist() {
    WFO=$(echo ${site} | tr [:lower:] [:upper:])
    wfo=$(echo ${site} | tr [:upper:] [:lower:])
    echo "Creating ESTOFS init files for ${WFO}" 
    source ${FIXnwps}/configs/${wfo}_ncep_config.sh    
    export err=$?; err_chk
    ESTOFS_REGION=$(echo ${ESTOFS_REGION} | tr [:upper:] [:lower:])
#..........................................
     if [ "${ESTOFS_BASIN}" == "estofs" ] && [ "${ESTOFS_REGION}" == "conus.east" ]
     then
       hasdownload_000=${hasDL[1]}
     elif [ "${ESTOFS_BASIN}" == "estofs" ] && [ "${ESTOFS_REGION}" == "puertori" ]
     then
       hasdownload_000=${hasDL[2]}
     elif [ "${ESTOFS_BASIN}" == "estofs" ] && [ "${ESTOFS_REGION}" == "conus.west" ]
     then
       hasdownload_000=${hasDL[3]}
     elif [ "${ESTOFS_BASIN}" == "estofs" ] && [ "${ESTOFS_REGION}" == "hawaii" ]
     then
       hasdownload_000=${hasDL[4]}
     elif [ "${ESTOFS_BASIN}" == "estofs" ] && [ "${ESTOFS_REGION}" == "alaska" ]
     then
       hasdownload_000=${hasDL[5]}
     elif [ "${ESTOFS_BASIN}" == "estofs" ] && [ "${ESTOFS_REGION}" == "guam" ]
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

    if [ "${ESTOFS_REGION}" == "none" ];then
    	echo "ERROR - No ESTOFS region for ${WFO}" 
    	echo "ERROR - Skipping init files for ${WFO}" 
    	continue
    fi

    NX=${ESTOFSNX}
    NY=${ESTOFSNY}
    LL_LON=$(echo ${ESTOFSDOMAIN} | awk '{ print $1}')
    LL_LAT=$(echo ${ESTOFSDOMAIN} | awk '{ print $2}')
    DX=$(echo ${ESTOFSDOMAIN} | awk '{ print $6}')
    DY=$(echo ${ESTOFSDOMAIN} | awk '{ print $7}')
    
    echo "ESTOFS_REGION = ${ESTOFS_REGION}"
    echo "ESTOFSDOMAIN = ${ESTOFSDOMAIN}"
    echo "NX = ${ESTOFSNX}"
    echo "NY = ${ESTOFSNY}"
    echo "LL_LON= ${LL_LON}"
    echo "LL_LAT= ${LL_LAT}"
    echo "DX = ${DX}"
    echo "DY = ${DY}"

    # Get the first forecast cycle
    touch ${OUTPUTdir}/LOCKFILE
    FF="000"
    file="${ESTOFS_BASIN}.t${CYCLE}z.${ESTOFS_REGION}.f${FF}.grib2"
    icefile="seaice.t00z.5min.grb.grib2"
    outfile="${file}"
    cd ${SPOOLdir}

    if [ "${hasdownload_000}" == "" ]; then hasdownload_000="false"; fi
    
    if [ "${hasdownload_000}" == "false" ];then
        if [ "${ESTOFS_BASIN}" == "estofs" ] && [ "${ESTOFS_REGION}" == "conus.east" ];then
           hasDL[1]="true"
        elif [ "${ESTOFS_BASIN}" == "estofs" ] && [ "${ESTOFS_REGION}" == "puertori" ];then
           hasDL[2]="true"
        elif [ "${ESTOFS_BASIN}" == "estofs" ] && [ "${ESTOFS_REGION}" == "conus.west" ];then
           hasDL[3]="true"
        elif [ "${ESTOFS_BASIN}" == "estofs" ] && [ "${ESTOFS_REGION}" == "hawaii" ];then
           hasDL[4]="true"
        elif [ "${ESTOFS_BASIN}" == "estofs" ] && [ "${ESTOFS_REGION}" == "alaska" ];then
           hasDL[5]="true"
        elif [ "${ESTOFS_BASIN}" == "estofs" ] && [ "${ESTOFS_REGION}" == "guam" ];then
           hasDL[6]="true"
        fi

        echo "Downloading ${SPOOLdir}/$file to $outfile" 
        echo "cp -rp ${COMINestofs}/${file} ."
        cp -rp ${COMINestofs}/${file} .
        if [ "$?" != "0" ] && [ ! -e ${file} ];then
           sleep 2
           echo "ERROR - downling file ${PRODUCTdir}/${file}" 
        fi
        cp -rp ${COMINestofs}/${file} .
        if [ "$?" != "0" ] && [ ! -e ${file} ];then
           echo "ERROR - downling file ${PRODUCTdir}/${file}" 
           export err=1; err_chk
        fi

        if [ "${ESTOFSUSEICEMASK}" == "TRUE" ]
        then
            echo "Using sea ice to mask ESTOFS area with high ice density"

            echo "Downloading ${SPOOLdir}/$icefile"
            if [ -e ${COMINsice}/${icefile} ];then
               echo "cp -rp ${COMINsice}/${icefile} ."
               cp -rp ${COMINsice}/${icefile} .

               if [ "$?" != "0" ] && [ ! -e ${icefile} ];then
                   sleep 2
                   echo "ERROR - downling file ${PRODUCTdir}/${icefile}" 
               fi
               cp -rp ${COMINsice}/${icefile} .
               if [ "$?" != "0" ] && [ ! -e ${icefile} ];then
                   echo "ERROR - downling file ${PRODUCTdir}/${icefile}"
                   export err=1; err_chk
               fi

            elif [ -e ${COMINsicem1}/${icefile} ];then
               echo "Today's ice concentration file not yet available. Downloading yesterday's file."
               echo "cp -rp ${COMINsicem1}/${icefile} ."
               cp -rp ${COMINsicem1}/${icefile} .

               if [ "$?" != "0" ] && [ ! -e ${icefile} ];then
                   sleep 2
                   echo "ERROR - downling file ${PRODUCTdir}/${icefile}" 
               fi
               cp -rp ${COMINsicem1}/${icefile} .
               if [ "$?" != "0" ] && [ ! -e ${icefile} ];then
                   echo "ERROR - downling file ${PRODUCTdir}/${icefile}"
                   export err=1; err_chk
               fi
            else
                echo "FATAL ERROR - Sea ice file ${PRODUCTdir}/${icefile} not available today or yesterday."
                ls -l ${COMINsicem1}/${icefile} ${COMINsice}/${icefile}
                export err=1; err_chk
            fi
        fi

    fi
    
    hasdownload_000="true"

    if [ "${ESTOFSUSEICEMASK}" == "TRUE" ]
    then
       echo "Using sea ice to mask ESTOFS area with high ice density"
       echo "Clip and reproject to sea ice grid"
       #--- Make local copy of input file and check size -----------
       cp ${SPOOLdir}/${icefile} ${CLIPdir}/${icefile}
       $WGRIB2 -count ${CLIPdir}/${icefile} > ${CLIPdir}/filechk
       nrecords=`wc -l ${CLIPdir}/filechk | cut -c1`
       while [ ${nrecords} -ne 1 ]; do
          echo "Repeating GRIB2 ice file copy for ${wfo}"
          cp ${SPOOLdir}/${icefile} ${CLIPdir}/${icefile}
          $WGRIB2 -count ${CLIPdir}/${icefile} > ${CLIPdir}/filechk
          nrecords=`wc -l ${CLIPdir}/filechk | cut -c1`
       done
       #------------------------------------------------------------
       echo "${WGRIB2} ${CLIPdir}/${icefile} -new_grid latlon ${LL_LON}:${NX}:${DX} ${LL_LAT}:${NY}:${DY} ${CLIPdir}/ice.grib2"
       ${WGRIB2} ${CLIPdir}/${icefile} -new_grid latlon ${LL_LON}:${NX}:${DX} ${LL_LAT}:${NY}:${DY} ${CLIPdir}/ice.grib2
       PARM="ICEC"
       echo "Extract ${PARM} data"
       echo "${WGRIB2} -no_header -match ${PARM} -bin ${CLIPdir}/ice.bin ${CLIPdir}/ice.grib2"
       ${WGRIB2} -no_header -match ${PARM} -bin ${CLIPdir}/ice.bin ${CLIPdir}/ice.grib2
    fi
  
    while [ "${epoc_time}" == "" ] || [ "${epoc_time}" == "-1" ]; do
       echo "Extracting epoc time for ${wfo}"
       epoc_time=`${WGRIB2} -unix_time ${SPOOLdir}/${file} | grep "1:4:unix" | awk -F= '{ print $3 }'`
    done
    #epoc_time=`${WGRIB2} -unix_time ${SPOOLdir}/${file} | grep "1:4:unix" | awk -F= '{ print $3 }'`
    date_str=`echo ${epoc_time} | awk '{ print strftime("%Y%m%d", $1) }'`
    echo ${epoc_time} > ${OUTPUTdir}/estofs_waterlevel_start_time.txt
    echo "ESTOFSDOMAIN:${ESTOFSDOMAIN}" > ${OUTPUTdir}/estofs_waterlevel_domain.txt

#    if [ $SENDDBN = YES ]; then
#      $DBNROOT/bin/dbn_alert MODEL NWPS_ASCII_PARA $job ${OUTPUTdir}/estofs_waterlevel_start_time.txt
#    fi
#    if [ $SENDDBN = YES ]; then
#      $DBNROOT/bin/dbn_alert MODEL NWPS_ASCII_PARA $job ${OUTPUTdir}/estofs_waterlevel_domain.txt
#    fi
    swan_wl_ofile_fname="wave_estofs_waterlevel_${epoc_time}_${date_str}_${CYCLE}_f${FF}.dat"
    swan_wl_ofile="${OUTPUTdir}/${swan_wl_ofile_fname}"

    if [ ! -e ${swan_wl_ofile} ];then
        #MakeClip ${SPOOLdir} ${file} 0 ${WFO}
        #--- Make local copy of input file and check size -----------
        while [ ! -s ${CLIPdir}/${file} ]; do
           cp ${SPOOLdir}/${file} ${CLIPdir}/${file}
        done
        $WGRIB2 -count ${CLIPdir}/${file} > ${CLIPdir}/filechk
        nrecords=`wc -l ${CLIPdir}/filechk | cut -c1`
        while [ ${nrecords} -ne 3 ]; do
           echo "Repeating GRIB2 file copy for ${wfo} f000"
           cp ${SPOOLdir}/${file} ${CLIPdir}/${file}
           $WGRIB2 -count ${CLIPdir}/${file} > ${CLIPdir}/filechk
           nrecords=`wc -l ${CLIPdir}/filechk | cut -c1`
        done
        MakeClip ${CLIPdir} ${file} 0 ${WFO}
        #------------------------------------------------------------
    	export err=$?; err_chk
        swan_wl_ifname="wave_estofs_waterlevel_${epoc_time}_${date_str}_${CYCLE}_f${FF}.dat"
        if [ ${WFO} != "NHC" -a ${WFO} != "OPC" ]
        then
            cd ${OUTPUTdir}
            ${USHnwps}/estofs/bin/estofs_extend.py  ${swan_wl_ifname}
            export err=$?; err_chk
            mv -f extend_${swan_wl_ifname} ${swan_wl_ifname}
        fi
#        if [ $SENDDBN = YES ]; then
#            $DBNROOT/bin/dbn_alert MODEL NWPS_ASCII_PARA $job ${swan_wl_ofile}
#        fi
    else
    	echo "Already created ${swan_wl_ofile}" 
    	echo "Skipping this file" 
    fi

    end=$TIMESTEP

    cd ${SPOOLdir}
    until [ $end -gt $HOURS ]; do
    	FF=`echo $end`
    	if [ $end -le 99 ];then
    	    FF=`echo 0$end`
    	fi
    	if [ $end -le 9 ];then
    	    FF=`echo 00$end`
    	fi
    	
    	swan_wl_ofile_fname="wave_estofs_waterlevel_${epoc_time}_${date_str}_${CYCLE}_f${FF}.dat"
    	swan_wl_ofile="${OUTPUTdir}/${swan_wl_ofile_fname}"
    	if [ -e ${swan_wl_ofile} ];then
    	    echo "Already created ${swan_wl_ofile}" 
    	    echo "Skipping this file" 
    	    let end+=$TIMESTEP
    	    continue
    	fi
    	
        file="${ESTOFS_BASIN}.t${CYCLE}z.${ESTOFS_REGION}.f${FF}.grib2"
    	outfile="${file}"
    	cd ${PRODUCTdir}
    	if [ ! -e ${VARdir}/hasestofsdownload_${CYCLE}z.${ESTOFS_BASIN}.${ESTOFS_REGION}.f${FF} ];then
	        echo "Copying ${COMINestofs}/${file} ${PRODUCTdir}/${file}"
	        echo "cp -rp ${COMINestofs}/${file} ."
	        cp -rp ${COMINestofs}/${file} .
	        if [ "$?" != "0" ] && [ ! -e ${file} ];then
                sleep 2
	            echo "ERROR - downling file ${PRODUCTdir}/${file}" 
	        fi
 	        cp -rp ${COMINestofs}/${file} .
	        if [ "$?" != "0" ] && [ ! -e ${file} ];then
	            echo "ERROR - downling file ${PRODUCTdir}/${file}" 
                export err=1; err_chk
	        fi
            echo " "
	        echo "++++++++++++++++++++++++++++++++++++++++++++"
            ls -l ${PRODUCTdir}/${file}
    	    if [ ! -e ${outfile} ];then
		        echo "INFO - ${PRODUCTdir}/${file} not available for copy" 
        		echo "Exiting" 
        		export err=1; err_chk
    	    fi
    	fi
    	touch ${VARdir}/hasestofsdownload_${CYCLE}z.${ESTOFS_BASIN}.${ESTOFS_REGION}.f${FF}

        #--- Make local copy of input file and check size -----------
        cp ${PRODUCTdir}/${file} ${CLIPdir}/${file}
        $WGRIB2 -count ${CLIPdir}/${file} > ${CLIPdir}/filechk
        nrecords=`wc -l ${CLIPdir}/filechk | cut -c1`
        while [ ${nrecords} -ne 3 ]; do
           echo "Repeating GRIB2 file copy for ${wfo} f${FF}"
           cp ${PRODUCTdir}/${file} ${CLIPdir}/${file}
           $WGRIB2 -count ${CLIPdir}/${file} > ${CLIPdir}/filechk
           nrecords=`wc -l ${CLIPdir}/filechk | cut -c1`
        done
        MakeClip ${CLIPdir} ${file} ${end} ${WFO}
        #------------------------------------------------------------
    	#MakeClip ${PRODUCTdir} ${file} ${end} ${WFO}
    	export err=$?; err_chk
        swan_wl_ifname="wave_estofs_waterlevel_${epoc_time}_${date_str}_${CYCLE}_f${FF}.dat"
        if [ ${WFO} != "NHC" -a ${WFO} != "OPC" ]
        then
            cd ${OUTPUTdir}
            ${USHnwps}/estofs/bin/estofs_extend.py  ${swan_wl_ifname}
            export err=$?; err_chk
            mv -f extend_${swan_wl_ifname} ${swan_wl_ifname}
        fi
    	let end+=$TIMESTEP
#        if [ $SENDDBN = YES ]; then
#            $DBNROOT/bin/dbn_alert MODEL NWPS_ASCII_PARA $job ${swan_wl_ofile}
#        fi
    done
    rm ${OUTPUTdir}/LOCKFILE
    #--- Copy WFO output to COMOUT
    mkdir -p ${COMOUT}/estofs/${wfo}_output
    cp ${OUTPUTdir}/wave_estofs_waterlevel_${epoc_time}_${date_str}_${CYCLE}_f*.dat ${COMOUT}/estofs/${wfo}_output/
    cp ${OUTPUTdir}/estofs_waterlevel_domain.txt ${COMOUT}/estofs/${wfo}_output/
    cp ${OUTPUTdir}/estofs_waterlevel_start_time.txt ${COMOUT}/estofs/${wfo}_output/
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
rm ${VARdir}/wfolist_sorted_estofs.dat
rm ${VARdir}/wfolist_estofs.sh

echo "Our spool DIR for FTP n000 data is: ${SPOOLdir}" 
echo "Our spool DIR for FTP forecast data is: ${PRODUCTdir}" 

# Create WFO list to make init files for
${USHnwps}/make_wfolist.sh ESTOFS
export err=$?; err_chk
source ${VARdir}/wfolist_estofs.sh

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

export err=$?; err_chk

datetime=`date -u`
echo "Ending download at $datetime UTC" 
echo "Processing complete" 
echo "Exiting..." 
exit 0
# -----------------------------------------------------------
# *******************************
# ********* End of File *********
# *******************************

#!/bin/bash
# ----------------------------------------------------------- 
# UNIX Shell Script
# Tested Operating System(s): RHEL 5
# Tested Run Level(s): 3, 5
# Shell Used: BASH shell
# Original Author(s):  Roberto.Padilla@noaa.gov
# File Creation Date: 12/10/2009
# Date Last Modified: 06/26/2014
#
# Version control: 1.44
#
# Support Team:
#
# Contributors: Douglas.Gaer@noaa.gov
# ----------------------------------------------------------- 
# ------------- Program Description and Details ------------- 
# ----------------------------------------------------------- 
#
# GRADS processing script used to create output images
# for spectra-1d plots.
#
# ----------------------------------------------------------- 

# LAT/LON Arrays
declare -a LON_ARR
declare -a LAT_ARR

# Setup our NWPS environment                                                    
if [ "${USHnwps}" == "" ]
    then 
    echo "ERROR - Your USHnwps variable is not set"
    export err=1; err_chk
fi

if [ -e ${USHnwps}/nwps_config.sh ]
then
    source ${USHnwps}/nwps_config.sh
else
    "ERROR - Cannot find ${USHnwps}/nwps_config.sh"
    export err=1; err_chk
fi

# The SITE ID is set in NWPS config but can be specified on the command line
if [ "$1" != "" ]; then CGNUMB="$1"; fi

if [ "${SITEID}" == "" ]
    then
    SITEID="default"
fi
SITEID=$(echo ${SITEID} | tr [:upper:] [:lower:])

# Check for hotstart
HASHOTSTART=$(cat ${RUNdir}/hotstart.flag)
if [ "${HASHOTSTART}" == "" ]; then HASHOTSTART="FALSE"; fi

echo "Starting GRAD plotting script for spectra-1d output"
if [ "${HASHOTSTART}" == "TRUE" ] 
    then
    echo "HOTSTART was used for this run, will include hours 0-12"
else
    echo "HOTSTART was not used for this run, will skip hours 0-12"
fi

echo "This script is ran following successful run during Graphics post-processing"
echo "SITE ID: ${SITEID}"

PYTHdir="${USHnwps}/python"
ETCdir="${USHnwps}/python/etc"
FIGSOUTPUTdir="${OUTPUTdir}/figures"
export USHlocal=${USHnwps}
#rm -fr ${FIGSOUTPUTdir}/${SITEID}/spectra

if [ ! -e ${FIGSOUTPUTdir} ]; then mkdir -p ${FIGSOUTPUTdir}; fi


echo $$ > ${TMPdir}/${USERNAME}/nwps/7787_postprocess_plot_specta_sh.pid

# Read our SWAN configuration for this run
export NESTS="NO"
hasnest=$(cat ${RUNdir}/nests.flag)
if [ "${hasnest}" == "TRUE" ]; then export NESTS="YES"; fi
SWANPARMS=`perl -I${USHnwps} -I${RUNdir} ${PYTHdir}/get_specta_parms.pl`
echo ${SWANPARMS}
# Process all CGs
for parm in ${SWANPARMS}
do
    CGNUM=$(echo ${parm} | awk -F, '{ print $1 }' | cut -b3)
    echo " In plot_specta.sh"
    echo "CGNUM: ${CGNUM}  CGNUMB: ${CGNUMB}"
    if [ "${CGNUM}" == "${CGNUMB}" ]
    then
    LENGTHTIMESTEP=$(echo ${parm} | awk -F, '{ print $2 }')
    SWANFCSTLENGTH=$(echo ${parm} | awk -F, '{ print $3 }')
    FREQARRAY=$(echo ${parm} | awk -F, '{ print $14 }' | sed s'/|/ /'g)
    NUMFREQUENCIES=$(echo ${parm} | awk -F, '{ print $15 }')
    NUMOUTPUTSPC1D=$(echo ${parm} | awk -F, '{ print $16 }')
    SPECTRANAMES=$(echo ${parm} | awk -F, '{ print $17 }' | sed s'/|/ /'g)
    PARTITIONLONS=$(echo ${parm} | awk -F, '{ print $18 }' | sed s'/|/ /'g)
    PARTITIONLATS=$(echo ${parm} | awk -F, '{ print $19 }' | sed s'/|/ /'g)
    SPECTRADIR="${OUTPUTdir}/spectra/CG${CGNUM}"

    echo "Processing spectra for CG${CGNUM}"
    echo "Spectra output dir = ${SPECTRADIR}"

    if [ ! -e ${SPECTRADIR} ]
	then 
	echo "ERROR - No specrta-1d output DIR ${SPECTRADIR}"
	echo "ERROR - Not creating any spectra-1d plots"
	export err=1; err_chk
    fi

    echo "LENGTHTIMESTEP = ${LENGTHTIMESTEP}"
    echo "SWANFCSTLENGTH = ${SWANFCSTLENGTH}"
    echo "NUMOUTPUTSPC1D = $NUMOUTPUTSPC1D"
    echo "FREQARRAY = $FREQARRAY"
    echo "NUMFREQUENCIES = $NUMFREQUENCIES"
    echo "SPECTRANAMES = $SPECTRANAMES"
    echo "PRTLOCLONS = $PARTITIONLONS"
    echo "PRTLOCLATS = $PARTITIONLATS"
    LON_ARR=(`echo $PARTITIONLONS | awk 'BEGIN{FS=" "}{for (i=1; i<=NF; i++) print $i}'`)
    LAT_ARR=(`echo $PARTITIONLATS | awk 'BEGIN{FS=" "}{for (i=1; i<=NF; i++) print $i}'`)
    TEMPDIR=${VARdir}/${SITEID}.tmp/CG${CGNUM}/spectra
    mkdir -p ${TEMPDIR}

    GRAPHICSdir="${FIGSOUTPUTdir}/${SITEID}/spectra/CG${CGNUM}"
    mkdir -p ${GRAPHICSdir}
    
    # Lets clean any old graphics
    rm -vf ${TEMPDIR}/swan*hr[0-9][0-9][0-9].png
    rm -vf ${GRAPHICSdir}/swan*hr[0-9][0-9][0-9].png
    echo "Writing all temp files to ${TEMPDIR}"
    echo "Copying LOGO from ${ETCdir}/*.gif files"
    cp -f ${ETCdir}/default/*.gif ${TEMPDIR}/.
    cp -f ${ETCdir}/default/*.png ${TEMPDIR}/.
    cp -f ${USHlocal}/python/spc1d.py ${TEMPDIR}/.

    
    cd ${SPECTRADIR}
    files=$(ls -1 --color=none *.bin)

    cd ${TEMPDIR}
    for file in ${files}
    do
	echo "Plotting spectra-1d for ${file}"
	LOCATION=$(echo ${file} | awk -F. '{ print $2 }')
        #Matching the file names found in the directory with their coordinates
        np=0
        for name in ${SPECTRANAMES[@]}
        do
           if [ ${name} == ${LOCATION} ];then
              LONGITUDE=${LON_ARR[$np]}
              LATITUDE=${LAT_ARR[$np]}
	     echo "LOCATION FOUND  : ${LOCATION}"
             echo "LONGITUDE FOUND : ${LONGITUDE}"
             echo "LATITUDE FOUND  : ${LATITUDE}"
             #break
           fi
           np=$(( $np + 1 ))
        done
	YY=$(echo ${file} | awk -F. '{ print $4 }' | cut -b3-4)
	MO=$(echo ${file} | awk -F. '{ print $5 }' | cut -b3-4)
	DD=$(echo ${file} | awk -F. '{ print $6 }' | cut -b3-4)
	HH=$(echo ${file} | awk -F. '{ print $7 }' | cut -b3-4)
	MIN="00"
	YPREFIX=$(date +%Y | cut -b1-2)
	YYYY=$(echo "${YPREFIX}${YY}")
	time_str="${YYYY} ${MO} ${DD} ${HH} ${MIN} 00"
	epoch_time=$(echo ${time_str} | awk -F: '{ print mktime($1 $2 $3 $4 $5 $6) }')
	month=$(echo ${epoch_time} | awk '{ print strftime("%b", $1) }' | tr [:upper:] [:lower:])
	TDEF=$(echo "${TDEF} linear ${HH}z${DD}${month}${YYYY} ${LENGTHTIMESTEP}hr")
	echo "LOCATION = ${LOCATION}"
        echo "LONGITUDE: ${LONGITUDE}"
        echo "LATITUDE: ${LATITUDE}"
	echo "DATE = ${HH}z${DD}${month}${YYYY}"
	cp -fpv ${SPECTRADIR}/${file} ${TEMPDIR}/spec.bin

	DSET="spec.bin"
	TITLE="SWANSPC1D CG${CGNUM} Control File"
	UNDEF="-0.9900E+02"
	XDEF=$(echo "$NUMFREQUENCIES linear $FREQARRAY") 
	YDEF=$(echo "1 levels 1") 
	ZDEF="1 levels 1"
	TDEF=$(echo "scale=0; (${SWANFCSTLENGTH}/${LENGTHTIMESTEP})+1" | bc)
	TDEF=$(echo "${TDEF} linear ${HH}z${DD}${month}${YYYY} ${LENGTHTIMESTEP}hr")

	echo "Creating GRADS control file"
	cat /dev/null > ${TEMPDIR}/swanspc1d.ctl
	echo "DSET ${DSET}" >> ${TEMPDIR}/swanspc1d.ctl
	echo "TITLE ${TITLE}" >> ${TEMPDIR}/swanspc1d.ctl
	echo "UNDEF ${UNDEF}" >> ${TEMPDIR}/swanspc1d.ctl
	echo "XDEF ${XDEF}" >> ${TEMPDIR}/swanspc1d.ctl
	echo "YDEF ${YDEF}" >> ${TEMPDIR}/swanspc1d.ctl
	echo "ZDEF ${ZDEF}" >> ${TEMPDIR}/swanspc1d.ctl
	echo "TDEF ${TDEF}" >> ${TEMPDIR}/swanspc1d.ctl
	echo "VARS 1" >> ${TEMPDIR}/swanspc1d.ctl
	echo "${LOCATION}=>location 0 t,z,y,x spec1d" >> ${TEMPDIR}/swanspc1d.ctl 
	echo "ENDVARS" >> ${TEMPDIR}/swanspc1d.ctl
        cd ${TEMPDIR}
	echo "Plotting specta-1d images"
        #------------------------ PYTHON SCRIPT CODE ---------------------------------------------
        python spc1d.py ${LOCATION} ${LONGITUDE} ${LATITUDE} # Added by E. Rodriguez on 5/5/2015
        #-----------------------------------------------------------------------------------------
	# NOTE: We must clean up the PNG files before they are copied to ${GRAPHICSdir} 
	echo "Copying PNG images to ${GRAPHICSdir}"
	if [ "${HASHOTSTART}" == "TRUE" ]
	then 
	    echo "HOTSTART was used for this run, keeping hours 0-9 for CG${CGNUM}"
	else
	    echo "No HOTSTART was used for this run, removing hours 0-9 for CG${CGNUM}."
	    rm -vf *hr00[0-9].png
	fi
	cp -vpf swan*.png ${GRAPHICSdir}/.
	chmod 777 ${GRAPHICSdir}/*.png
    done
    fi
done

echo "NWPS Specta-1d output plots can be viewed at: ${GRAPHICSdir}"
   
exit 0
# ----------------------------------------------------------- 
# ******************************* 
# ********* End of File ********* 
# ******************************* 

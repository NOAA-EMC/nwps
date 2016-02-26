#!/bin/bash
# -----------------------------------------------------------
# UNIX Shell Script
# Tested Operating System(s): RHEL 5, 6
# Tested Run Level(s): 3, 5
# Shell Used: BASH shell
# Original Author(s): Douglas.Gaer@noaa.gov
# File Creation Date: 09/29/2009
# Date Last Modified: 07/29/2014
#
# Version control: 1.24
#
# Support Team:
#
# Contributors:
# -----------------------------------------------------------
# ------------- Program Description and Details -------------
# -----------------------------------------------------------
#
# Script used to plot RTOFS input ASCII point files
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
    "ERROR - Cannot find ${USHnwps}/nwps_config.sh"
    export err=1; err_chk
fi

# The SITE ID is set in NWPS config but can be specified on the command line
if [ "$1" != "" ]; then SITEID="$1"; fi

if [ "${SITEID}" == "" ]
    then
    SITEID="default"
fi
SITEID=$(echo ${SITEID} | tr [:upper:] [:lower:])

RUNdir="${USHnwps}/rtofs"
INPUTdir="${INPUTdir}/rtofs"
BINdir="${RUNdir}/bin"
ETCdir="${RUNdir}/grads/etc"
GRADSOUTPUTdir="${OUTPUTdir}/grads"
WRITEDAT="${EXECnwps}/writedat"

if [ ! -e ${VARdir} ]; then mkdir -p ${VARdir}; fi
if [ ! -e ${LOGdir} ]; then mkdir -p ${LOGdir}; fi
if [ ! -e ${GRADSOUTPUTdir} ]; then mkdir -p ${GRADSOUTPUTdir}; fi

TEMPDIR=${VARdir}/${SITEID}.tmp/current
mkdir -p ${TEMPDIR}
echo "Writing all temp files to ${TEMPDIR}"

GRAPHICSdir="${GRADSOUTPUTdir}/${SITEID}/current"
mkdir -p ${GRAPHICSdir} 
echo "Cleaning any previous plot images"
find ${TEMPDIR} -name "*.png" -print | xargs rm -f
find ${GRAPHICSdir} -name "*.png" -print | xargs rm -f

#echo "Updating the GRADS control files"
#if [ ! -e "${ETCdir}/${SITEID}" ]
#then
#    if [ ! -e "${ETCdir}/default" ]
#    then
#	echo "ERROR - Missing ${ETCdir}/default directory"
#	echo "Will not be able to create graphics"
#	export err=1; err_chk
#    fi
#    echo "WARNING - No GRADS plotting templates found for ${SITEID}"
#    echo "Building a default set for ${SITEID}"
#    mkdir -p ${ETCdir}/${SITEID}
#    cp -f ${ETCdir}/default/*.* ${ETCdir}/${SITEID}/.
#fi

if [ ! -e ${INPUTdir}/rtofs_current_domain.txt ]
then
    echo "ERROR - Missing domain file in input DIR"
    echo "ERROR - Can't find ${INPUTdir}/rtofs_current_domain.txt"
    export err=1; err_chk
fi

if [ ! -e ${INPUTdir}/rtofs_current_start_time.txt ]
then
    echo "ERROR - Missing model start time file in input DIR"
    echo "ERROR - Can't find ${INPUTdir}/rtofs_current_start_time.txt"
    export err=1; err_chk
fi

epoc_time=$(cat ${INPUTdir}/rtofs_current_start_time.txt)

DOMAIN=$(cat ${INPUTdir}/rtofs_current_domain.txt | awk -F: '{ print $2 }')
LON=$(echo ${DOMAIN} | awk '{ print $1 }')
NX=$(echo ${DOMAIN} | awk '{ print $4 }')
NX=$(echo "${NX} + 1" | bc)
XRES=$(echo ${DOMAIN} | awk '{ print $6 }')
LAT=$(echo ${DOMAIN} | awk '{ print $2 }')
NY=$(echo ${DOMAIN} | awk '{ print $5 }')
NY=$(echo "${NY} + 1" | bc)
YRES=$(echo ${DOMAIN} | awk '{ print $7 }')

# Generate the XDEF and YDEF lines in the following format"
# xdef 683  linear -98.00 0.029326
# ydef 371  linear  23.00 0.027027
#
XDEF=$(echo "xdef ${NX}   linear ${LON} ${XRES}")
YDEF=$(echo "ydef ${NY}   linear ${LAT} ${YRES}")

echo "RTOFSDOMAIN = ${DOMAIN}"
echo "RTOFSNX = ${NX}"
echo "RTOFSNY = ${NY}"

# Set our script variables from the global config
echo "Plotting RTOFS ocean current images"

cd ${INPUTdir}
files=`ls --color=none -1rat wave*_uv_*.dat`

cd ${TEMPDIR}
cp ${ETCdir}/${SITEID}/* ${TEMPDIR}/.
# Set and default template values
sed -i "s/<!-- SET XDEF HERE -->/${XDEF}/g" ${TEMPDIR}/*.ctl
sed -i "s/<!-- SET YDEF HERE -->/${YDEF}/g" ${TEMPDIR}/*.ctl

echo "Creating GRADS plots for Current as PNG images"
for file in $files
do
    echo "Processing ${file}"
    ${WRITEDAT} ${INPUTdir}/${file} ${TEMPDIR}/cur.bin
    FHOUR=$(echo "${file}" | sed s/.dat//g | awk -F_ '{ print $7 }' | sed s/f//g)
    FSECS=$(echo "${FHOUR} * (60*60)" | bc)
    fepoc_time=$(echo "${epoc_time} + ${FSECS}" | bc)
    date_label=$(echo ${fepoc_time} | awk '{ print strftime("%b %d, %Y %H:%M", $1) }')
    label=$(echo "Hour ${FHOUR} ${date_label}")
    echo "$label" > ${TEMPDIR}/datelab.txt
    ${GRADS} -b -l -c cur_global.gs
    mv cur.png ${GRAPHICSdir}/rtofs_current_f${FHOUR}.png
done

# NOTE: In NWPS we have a send to Web option in the global configuration
if [ "${WEB}" == "YES" ]
then
    echo "Running send to Web script"
    ${USHnwps}/grads/bin/send_to_web.sh ${SITEID}
fi

echo "Ploting Script complete"
exit 0
# -----------------------------------------------------------
# *******************************
# ********* End of File *********
# *******************************

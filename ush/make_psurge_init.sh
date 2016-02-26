#!/bin/bash
# -----------------------------------------------------------
# UNIX Shell Script
# Tested Operating System(s): RHEL 5, 6
# Tested Run Level(s): 3, 5
# Shell Used: BASH shell
# Original Author(s): Roberto.Padilla@noaa.gov
# File Creation Date: 05/05/2015
# Date Last Modified: 0
#
# Version control: 1.0
#
# Support Team:
#
# Contributors: 
#               
# -----------------------------------------------------------
# ------------- Program Description and Details -------------
# -----------------------------------------------------------
#
# Script used to extract PSURGE water level fields for NWPS 
#
#
# -----------------------------------------------------------

if [ "${HOMEnwps}" == "" ]
    then 
    echo "ERROR - Your HOMEnwps variable is not set"
    exit 1
fi

source ${USHnwps}/psurge_config.sh

# NOTE: Data is processed on the server in UTC
export TZ=UTC

# Script variables
# ===========================================================
LOGfile="${LOGdir}/make_psurge.log"
myPWD=$(pwd)

#Time step for Psurge fields in seconds
#   TS_f

# Set our purging varaibles
PSURGEPURGEdays="5"
export DEGRIB=${EXECnwps}/degrib
#export DEGRIB=/nwprod2/grib_util.v1.0.0/exec/degrib2
PSURGE2NWPS=${EXECnwps}/exec/psurge2nwps_64


# NOTE: Add WGET --no-remove-listing option for FTP downloads
RSYNC="/usr/bin/rsync"
DOWNLOADRETRIES="5"
if [ "$6" != "" ]; then DOWNLOADRETRIES="$6"; fi 
WGETargs="-N -nv --tries=${DOWNLOADRETRIES} --no-remove-listing --append-output=${LOGfile}"
WGET="/usr/bin/wget"

# The forecast cycle, default to 00
CYCLE="00"	
# Check for command line CYCLE

if [ "$1" != "" ]
then 
   CYCLE="$1"
else
   # Adjust to the correct cycle
   curhour=$(date -u +%H)
   if [ $curhour -lt 12 ]; then CYCLE="00"; fi
   if [ $curhour -ge 12 ] && [ $curhour -lt 18 ]; then CYCLE="06"; fi
   if [ $curhour -ge 18 ] && [ $curhour -lt 22 ]; then CYCLE="12"; fi
   if [ $curhour -ge 22 ]; then CYCLE="18"; fi
fi
echo ""
echo "INFO - Current hour is ${curhour}, setting model cycle to ${CYCLE}"



HOURS="${PSURGEHOURS}"
if [ "$2" != "" ]; then HOURS="$2"; fi

TIMESTEP="${PSURGETIMESTEP}"
if [ "$3" != "" ]; then TIMESTEP="$3"; fi

# Set the date stamp using the system Z time
YYYY=`date +%Y`
MM=`date +%m`
DD=`date +%d`

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



echo "Starting PSURGE data processing for ${YYYYMMDD} "

# Starting processing logging here
cat /dev/null > ${LOGfile}

# Starting purging here
echo "Purging any PSURGE data older than ${PSURGEPURGEdays} days old" | tee -a ${LOGfile}
find ${DATAdir} -type f -mtime +${PSURGEPURGEdays} | xargs rm -f
find ${INGESTdir} -type f -mtime +${PSURGEPURGEdays} | xargs rm -f

#-----------------------------------------
# THIS  TEST 1
#YYYYMMDD="20121029"
#PSurge_latest="${COMpsurge}/psurge.${YYYYMMDD}"
#PSurge_latest="${COMINpsurge}"
#ls -lt ${PSurge_latest}/psurge.${YYYYMMDD}/psurge.t*_e10_inc_agl*.grib2
#cp ${PSurge_latest}/psurge.20121029/psurge.t*_e10_inc_agl*.grib2 ${RUNdir} 
#------------------------------------------------------------
# Production?
workdir=$(echo `pwd`)
PSurge_latest=${COMINpsurge}
cd ${PSurge_latest}
NewD=$(basename `ls -t * | head -1`)
NewestDir=$(echo "${NewD%?}")
cd ${NewestDir}
NewestPsurge=$(basename `ls -t *e??_inc_dat.conus_625m.grib2 | head -1`)

if [ "${NewestPsurge}" == "" ]
    then 
    echo "ERROR - No Psurge fields to process"
    export err=1; err_chk
fi

#psurge.t2004091418z.al822004_e10_inc_dat.conus_625m.grib2
split=(${NewestPsurge//_/ })
for part in ${split[@]} ; do echo $part; done
#split[0] must be something like:  psurge.t2004091418z.al822004
cp ${split[0]}_e??_inc_dat.conus_625m.grib2 ${RUNdir} 
cd $workdir
#--------------------------------------------------------------

if [ $? != 0 ] ; then echo "ERROR - No files to process " >&2 ; export err=1; err_chk ; fi
echo "P-Surge files from : ${PSurge_latest}"
#
cd ${RUNdir}
cat /dev/null > ${RUNdir}/exceedances
cat /dev/null > ${RUNdir}//degrib_cmdfile
cat /dev/null > ${RUNdir}/wfo_cmdfile

#Initial cleaning 
rm ${RUNdir}/*.flt
rm ${RUNdir}/*.txt
rm ${RUNdir}/*.dat

echo ""
echo "Find GRIB2 files for data extraction, starting with 10% exceedance..."
for file in *.grib2
do
   if [ -f "$file" ];then
      echo "FILE FOUND: $file"
      pwd
      #ls -lt 
      split=(${file//_/ })
      for part in ${split[@]} ; do echo $part; done
      eXCEED="${split[1]}"
      EXCEED=$(echo ${eXCEED:1:2})
      echo "EXCEEDANCE: ${EXCEED}"
      echo " ${EXCEED} " >> ${RUNdir}/exceedances
      echo " "

      #echo " DEGRIBING ${file}   EXCEED: ${EXCEED}"
      #${DEGRIB} ${file} -C -Flt -msg all -nameStyle "%e_%lv_%p_e${EXCEED}.txt" -Unit none
      #echo "${DEGRIB} ${file} -C -Flt -msg all -nameStyle "%e_%lv_%p_e${EXCEED}.txt" -Unit none" >> ${RUNdir}/degrib_cmdfile

      #---- First identify which WFO domains have data to extract (at the operational res.), 
      #---- based on a quick scan low-resolution extraction of their contents. Assume 
      #---- the worst-case scenario of 10% exceedance for this (largest footprint).
      rm -f *.ave *.hdr 
      if [[ ${EXCEED} == "10" ]]; then
         echo "DEGRIBING ${file}   EXCEED: ${EXCEED}"
         echo "This might take a while..."
         echo ""
         ${DEGRIB} ${file} -C -Flt -msg all -nameStyle "%e_%lv_%p_e${EXCEED}.txt" -Unit none
         ${USHnwps}//make_psurge_identify.sh ${file} ${EXCEED}
         echo ""
         echo "Now find GRIB2 files with remaining exceedances for final extraction..."
      else
         echo "${DEGRIB} ${file} -C -Flt -msg all -nameStyle "%e_%lv_%p_e${EXCEED}.txt" -Unit none" >> ${RUNdir}/degrib_cmdfile
      fi

   fi
done

echo ""
echo "DEGRIB these GRIB2 files, using multi-core processing..."
mpirun.lsf cfp ${RUNdir}/degrib_cmdfile

echo ""
echo "Prepare wfo_cmdfile to process the final WFOs in ${RUNdir}/wfolist_psurge_final.dat..."
while read line
do
   DOMAIN=`echo $line | awk -F" " '{print $1}'`
   #Npx=`echo $line | awk -F" " '{print $2}'`
   #Npy=`echo $line | awk -F" " '{print $3}'`
   echo "Domain: $DOMAIN  Nx: $Npx   Ny: $Npy  ADVnum: ${ADVnum}"
   echo "Clipping P-Surge data for:  ${DOMAIN} $Npx $Npy ${TS_f}" | tee -a ${LOGfile}
   echo "${USHnwps}/make_psurge_final.sh  ${DOMAIN} ${TS_f}" >> ${RUNdir}/wfo_cmdfile
done < wfolist_psurge_final.dat
#Cleanning run directory

echo "Intial processing complete" | tee -a ${LOGfile}
echo "Exiting make_psurge_init.sh" | tee -a ${LOGfile}
date
echo ""
exit 0
# -----------------------------------------------------------
# *******************************
# ********* End of File *********
# *******************************

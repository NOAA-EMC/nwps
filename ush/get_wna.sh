#!/bin/bash
set -xa
# -----------------------------------------------------------
# UNIX Shell Script
# Tested Operating System(s): RHEL 5, 6
# Tested Run Level(s): 3, 5
# Shell Used: BASH shell
# Original Author(s): Douglas.Gaer@noaa.gov
# File Creation Date: 08/19/2013
# Date Last Modified: 11/15/2014
#
# Version control: 1.06
#
# Support Team:
#
# Contributors:
#               
# -----------------------------------------------------------
# ------------- Program Description and Details -------------
# -----------------------------------------------------------
#
# Script used to download WNA (WW3) boundary conditions 
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
BINdir="${USHnwps}"
LOGfile="${LOGdir}/wna_download.log"
myPWD=$(pwd)

# Set our data ingest DIR 
INGESTdir="${LDMdir}/wna"

# Set our final output DIR for SWAN input files
SWANINPUTfiles="${INPUTdir}/wave"

# Set our purging varaibles
WNAPURGEdays="1"

# Set our locking variables
PROGRAMname="$0"
LOCKfile="$VARdir/get_wna.lck"
MINold="60"

# NOTE: Add WGET --no-remove-listing option for FTP downloads
RSYNC="rsync"
WGET="wget"

# The forecast cycle, default to 00
bcCYCLE="00"	
# Check for command line bcCYCLE
if [ "$1" != "" ]; then bcCYCLE="$1"; fi

#AW # Set the date stamp using the system Z time
#AW YYYY=$(echo $PDY|cut -c1-4)
#AW MM=$(echo $PDY|cut -c5-6)
#AW DD=$(echo $PDY|cut -c7-8)

windsource=`cat ${RUNdir}/windsource.flag`
if [ "$windsource" == "FORECASTWINDGRIDS" ]; then
   export model_start_time=`grep Wind_Mag_SFC:validTimes ${INPUTdir}/wind/*WIND.txt | cut -c29-38 | tail -1`
   YYYY=$(date -d @$model_start_time +"%Y")
   MM=$(date -d @$model_start_time +"%m")
   DD=$(date -d @$model_start_time +"%d")
   windhour=$(date -d @$model_start_time +"%H")
elif [ "$windsource" == "GFS" ]; then
   #export model_start_time=`cat ${LDMdir}/gfswind/gfswind_start_time.txt`
   NewestWind=$(basename $(ls -t ${VARdir}/gfe_grids_test/NWPSWINDGRID_${siteid}* | head -1))
   if [ "$NewestWind" != "" ]; then
      YYYY=$(echo $NewestWind|cut -c18-21)
      MM=$(echo $NewestWind|cut -c22-23)
      DD=$(echo $NewestWind|cut -c24-25)
      windhour=$(echo $NewestWind|cut -c26-27)
      time_str="${YYYY} ${MM} ${DD} ${windhour} 00 00"
      model_start_time=`echo ${time_str} | awk -F: '{ print mktime($1 $2 $3 $4 $5 $6) }'`
   fi
fi

# Adjust to the correct cycle
if [ $windhour -ge  5 ] && [ $windhour -lt 11 ]; then bcCYCLE="00"; fi
if [ $windhour -ge 11 ] && [ $windhour -lt 17 ]; then bcCYCLE="06"; fi
if [ $windhour -ge 17 ] && [ $windhour -lt 23 ]; then bcCYCLE="12"; fi
if [ $windhour -ge 23 ]; then bcCYCLE="18"; fi

bcYYYYMMDD="${YYYY}${MM}${DD}"
if [ $windhour -ge 0 ] && [ $windhour -lt 5 ] 
then 
  #AW date=`date +%Y%m%d --date=yesterday`
  #AW YYYYMMDD="$date"
  let model_start_time_m1=$model_start_time-3600*24
  bcYYYYMMDD=$(date -d @$model_start_time_m1 +"%Y%m%d")
  bcCYCLE="18" 
fi

# Set another date stamp of one cycle (6h) ago, for in case current BC are not available
#AW curhour=$(date -u +%H)
if [ $windhour -ge 11 ] && [ $windhour -lt 17 ]; then bcOLDCYCLE="00"; fi
if [ $windhour -ge 17 ] && [ $windhour -lt 23 ]; then bcOLDCYCLE="06"; fi
if [ $windhour -ge 23 ]; then bcOLDCYCLE="12"; fi
bcOLDYYYYMMDD=$bcYYYYMMDD
if [ $windhour -ge  0 ] && [ $windhour -lt 5 ]
then
   #AW date=`date +%Y%m%d --date=yesterday`
   #AW OLDYYYYMMDD="$date"
   let model_start_time_m1=$model_start_time-3600*24
   bcOLDYYYYMMDD=$(date -d @$model_start_time_m1 +"%Y%m%d")
   bcOLDCYCLE="12" 
fi
if [ $windhour -ge  5 ] && [ $windhour -lt 11 ]
then
   #AW date=`date +%Y%m%d --date=yesterday`
   #AW OLDYYYYMMDD="$date"
   let model_start_time_m1=$model_start_time-3600*24
   bcOLDYYYYMMDD=$(date -d @$model_start_time_m1 +"%Y%m%d")
   bcOLDCYCLE="18" 
fi

echo ""
echo "INFO - Wind source hour is ${windhour}, setting wave BC cycle to ${bcCYCLE} ON ${bcYYYYMMDD}"
echo "INFO - Wind source hour is ${windhour}, setting previous wave BC cycle to ${bcOLDCYCLE} ON ${bcOLDYYYYMMDD}"

# Optional ARGS used to override the default settings
if [ "$2" != "" ]
    then 
    bcYYYYMMDD="$2"
    # Override the auto cycle if user has specifed a date
    if [ "$1" != "" ]; then bcCYCLE="$1"; fi
fi

#source ${USHnwps}/process_lock.sh

echo "Starting WNA download processing"
#echo "Checking for lock files"
#LockFileCheck $MINold
##CreateLockFile

# Make any of the following directories if needed
mkdir -p ${VARdir}
mkdir -p ${LOGdir}
mkdir -p ${SWANINPUTfiles}
mkdir -p ${INGESTdir}

cat /dev/null > ${LOGfile}

datetime=`date -u`
echo "Starting download at $datetime UTC" | tee -a ${LOGfile}

# Starting purging here
echo "Purging any WNA data older than ${WNAPURGEdays} days old" | tee -a ${LOGfile}
find ${INGESTdir} -type f -mtime +${WNAPURGEdays} | xargs rm -f
find ${SWANINPUTfiles} -type f -mtime +${WNAPURGEdays} | xargs rm -f

##url="ftp://ftp.ncep.noaa.gov/pub/data/nccf/com/wave/prod/wave.${bcYYYYMMDD}/bulls.t${bcCYCLE}z"

wna_config="${DATA}/parm/templates/${siteid}/wna_input.cfg"

# Set our download URL
echo "Our ingest DIR for FTP data is: ${INGESTdir}" | tee -a ${LOGfile}  

echo "NWPS Site ID = ${siteid}" | tee -a ${LOGfile}
echo "bcCYCLE = ${bcCYCLE}" | tee -a ${LOGfile}
echo "Download URL: ${url}" | tee -a ${LOGfile}

if [ ! -e ${wna_config} ]
then
    echo "ERROR - Missing WNA config file" | tee -a ${LOGfile}
    echo "ERROR - Cannot open ${wna_config}" | tee -a ${LOGfile}
    #RemoveLockFile
    export err=1; err_chk
fi

echo "WNA config: ${wna_config}" | tee -a ${LOGfile}

FTPPAT2="NOTSET"
NFTPATTEMPTS="3"

while read line
do
    WNALINE=$(echo $line | sed s/' '//g | grep -v "^#")
    if [ "${WNALINE}" != "" ] 
       then
	parm=$(echo "${WNALINE}" | awk -F':' '{ print $1 }')
	value=$(echo "${WNALINE}" | awk -F':' '{ print $2 }')
	if [ "${parm}" == "FTPPAT2" ]; then FTPPAT2="${value}"; fi
	if [ "${parm}" == "NFTPATTEMPTS" ]; then NFTPATTEMPTS="${value}"; fi
    fi
done < ${wna_config}

#WGETargs="-N -nv --tries=${NFTPATTEMPTS} --no-remove-listing --append-output=${LOGfile}"

if [ "${FTPPAT2}" == "" ] || [ "${FTPPAT2}" == "NOTSET" ]
then
    echo "ERROR -  FTPPAT2 parm not set in WNA config file" | tee -a ${LOGfile}
    #RemoveLockFile
    export err=1; err_chk
fi

echo "WNA site ID: ${FTPPAT2}" | tee -a ${LOGfile}
echo "FTP retries: ${NFTPATTEMPTS}" | tee -a ${LOGfile}


echo "******************* In get_wna.sh  ******************"

echo "FTPPAT1:   ${FTPPAT1}"
echo "FTPPAT2:   ${FTPPAT2}"
echo "WNA:      ${WNA}"
if [ "${WNA^^}" = "WNAWAVE" ]
then
   bc_option="multi_1" 
   bctarfile="${bc_option}.t${bcCYCLE}z.spec_tar.gz"
   url="${COMINwave}/${bc_option}.${bcYYYYMMDD}"

elif [ "${WNA^^}" = "HURWAVE" ]
   then
   bc_option="multi_2"
   bctarfile="${bc_option}.t${bcCYCLE}z.spec_tar.gz"
   url="${COMINwave}/${bc_option}.${bcYYYYMMDD}"

elif [ "${WNA^^}" = "TAFB-NWPS" ]
   then
   #bc_$WFO_$YYYYMMDDHH.tar.xz
   #/dcom/us007003/YYYYMMDD/wtxtbul/nhc_nwps_bc/
   #bc_option="tafb"
   #bctarfile="bc_${SITEID}_${PDY}.tar.gz"
   #url="$dcom/$PDY/wtxtbul/nhc_nwps_bc/"

   bc_option="multi_2"
   bctarfile="${bc_option}.t${bcCYCLE}z.spec_tar.gz"
   url="${COMINwave}/${bc_option}.${bcYYYYMMDD}"

elif [ "${WNA^^}" = "NO" ]
   then
   echo " NOT BOUNDARY CONDITIONS"
   bc_option="NO"
   exit 0
fi

 if [ "${WNA}" != "" ] && [ "${url}" == "" ]
then
   msg="FATAL ERROR: URL for boundary condition is not set. Please CANCEL the downstream jobs for ${SITEID}."
   postmsg "$jlogfile" "$msg"
   export err=1; err_chk
fi

echo "Bound Cond Option: ${WNA}"

cd ${DATA}


if [ -e "${url}/${bctarfile}" ];then
    DATABCdir="${GESOUT}/databc/${bc_option}.${bcYYYYMMDD}_t${bcCYCLE}z"
    file="${bc_option}.${FTPPAT2}"
    if [ ! -e ${DATABCdir}/${bctarfile} ]
    then
       echo " We do not have the lattest Boundary Conditions"
       echo " They will be copied to ${DATABCdir} and untar"
    
       echo "DATABCdir: ${DATABCdir}"
       mkdir -p ${DATABCdir}
       cd ${DATABCdir}
       pwd
       echo " ************COPYING BC from WWIII ************"
       cp -pr ${url}/${bctarfile} .
    else
       # Checking if the file is "old enough" to access it. Otherwise an error 
       # can occur if the file is still being copied by another site run and 
       # this run tries to untar its boundary conditions.
       time_now=$(date +%s)
       echo "time now: ${time_now}"
       time_bondcond=$(stat -c %Y ${DATABCdir}/${bctarfile} | awk '{printf $1 "\n"}')
       echo "Bound Cond time : ${time_bondcond}"
       time_diff=$(echo "${time_now} - ${time_bondcond}" | bc | tr -d "-")
       echo "Diff in sec: ${time_diff}"

       if [[ ${time_diff} -lt 30 ]]
       then
          echo "File being copied"
          echo "I'll wait for a 30 secs"
          date
          sleep 30
          date
       else
          echo "Bound Conditions ready"
          echo "Start untarring my BC and cp to the workdir"
       fi

    fi
    cd ${DATABCdir}
    tar -xvf ${bctarfile}  --wildcards --no-anchored "${file}*.spec"
    if [ "$?" != "0" ]
    then
       echo "FATAL ERROR: Unable to copy boundary condition file ${url}/${file}*.spec" | tee -a ${LOGfile}
       msg="FATAL ERROR: Unable to copy boundary condition file ${url}/${file}*.spec"
       postmsg "$jlogfile" "$msg"
       #RemoveLockFile
       export err=1; err_chk
    fi
    echo " ************BC ${file}*.spec  UNTARRED ************"
    
    cd ${INGESTdir}
    
    echo "Copying ${DATABCdir}/${file}*.spec" to ${INGESTdir} | tee -a ${LOGfile}
    cp -pr ${DATABCdir}/${file}*.spec ./
    if [ "$?" != "0" ]
    then
        echo "FATAL ERROR: Unable to copy boundary condition file ${url}/${file}*.spec" | tee -a ${LOGfile}
        msg="FATAL ERROR: Unable to copy boundary condition file ${url}/${file}*.spec"
        postmsg "$jlogfile" "$msg"
        rm -f "${file}*"
        #RemoveLockFile
        export err=1; err_chk
    fi
elif [ -e "${COMINwave}/${bc_option}.${bcOLDYYYYMMDD}/${bc_option}.t${bcOLDCYCLE}z.spec_tar.gz" ];then
    # Use BCs from one cycle ago (e.g. WW3_multi_2/HURwave is a late run)
    bctarfile="${bc_option}.t${bcOLDCYCLE}z.spec_tar.gz"
    url="${COMINwave}/${bc_option}.${bcOLDYYYYMMDD}"
    DATABCdir="${GESOUT}/databc/${bc_option}.${bcOLDYYYYMMDD}_t${bcOLDCYCLE}z"
    file="${bc_option}.${FTPPAT2}"

    echo "WARNING: Using wave boundary conditions from previous cycle (${bcOLDYYYYMMDD}_${bcOLDCYCLE}z)." | tee -a ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt

    if [ ! -e ${DATABCdir}/${bctarfile} ]
    then
       echo " We do not have the lattest Boundary Conditions"
       echo " They will be copied to ${DATABCdir} and untar"
    
       echo "DATABCdir: ${DATABCdir}"
       mkdir -p ${DATABCdir}
       cd ${DATABCdir}
       pwd
       echo " ************COPYING BC from WWIII ************"
       cp -pr ${url}/${bctarfile} .
    fi

    cd ${DATABCdir}
    tar -xvf ${bctarfile}  --wildcards --no-anchored "${file}*.spec"
    if [ "$?" != "0" ]
    then
       echo "FATAL ERROR: Unable to copy boundary condition file ${url}/${file}*.spec" | tee -a ${LOGfile}
       msg="FATAL ERROR: Unable to copy boundary condition file ${url}/${file}*.spec"
       postmsg "$jlogfile" "$msg"
       #RemoveLockFile
       export err=1; err_chk
    fi
    echo " ************BC ${file}*.spec  UNTARRED ************"
    
    cd ${INGESTdir}
    
    echo "Copying ${DATABCdir}/${file}*.spec" to ${INGESTdir} | tee -a ${LOGfile}
    cp -pr ${DATABCdir}/${file}*.spec ./
    if [ "$?" != "0" ]
    then
        echo "FATAL ERROR: Unable to copy boundary condition file ${url}/${file}*.spec" | tee -a ${LOGfile}
        msg="FATAL ERROR: Unable to copy boundary condition file ${url}/${file}*.spec"
        postmsg "$jlogfile" "$msg"
        rm -f "${file}*"
        #RemoveLockFile
        export err=1; err_chk
    fi
else
    msg="FATAL ERROR: The file ${url}/${bctarfile} does not exist. Wave boundary conditions will not be set."
    postmsg $jlogfile "$msg"
    #RemoveLockFile
    export err=1; err_chk
fi

datetime=`date -u`
echo "Ending download at $datetime UTC" | tee -a ${LOGfile}

echo "Processing complete" | tee -a ${LOGfile}
cd ${myPWD}
echo "Exiting..." | tee -a ${LOGfile}

#RemoveLockFile
exit 0
# -----------------------------------------------------------
# *******************************
# ********* End of File *********
# *******************************

#!/bin/bash
# -----------------------------------------------------------
# UNIX Shell Script
# Tested Operating System(s): RHEL 5/6
# Shell Used: BASH shell
# Original Author(s): WFO MHX: Donnie King, Greg Dusek and Scott Kennedy
# File Creation Date: 7/1/2013
# Date Last Modified: 06/18/2016
#
# Version control: 1.10
#
# Support Team:
#
# Contributors: andre.vanderwesthuysen@noaa.gov, alex.gibbs@noaa.gov, Roberto.Padilla@noaa.gov
#
# -----------------------------------------------------------
# ------------- Program Description and Details -------------
# -----------------------------------------------------------
#
# This program assumes the contour fields within NWPS 
# have been installed in the $NWPSdir/bin/RunSwan.pm. If not, view 
# the online documentation for further instructions at:
# 
# innovation.srh.noaa.gov/nwps/nwpsmanual.php/rip_current_program
#
# To execute:                                ARG1 ARG2
# $NWPSdir/ush/run_ripcurrent.sh CG2 5
#
# Arguments=2:
#
# 1. Grid that you are extracting data along contours from. (ie CG2)
# 2. contour: 5 (for 5m contour)
# -----------------------------------------------------------


if [ "${SITEID}" == "" ]
    then
    echo "ERROR - Your SITEID variable is not set"
    export err=1; err_chk
fi

if [ "${NWPSdir}" == "" ]
    then 
    echo "ERROR - Your NWPSdir variable is not set"
    export err=1; err_chk
fi

if [ -e ${USHnwps}/nwps_config.sh ]
then
    source ${USHnwps}/nwps_config.sh
else
    echo "ERROR - Cannot find ${USHnwps}/nwps_config.sh"
    export err=1; err_chk
fi

ndata=1
while read p; do
  echo ${ndata} $p
   if [ ${ndata} -eq 1 ]; then
    NWPSdir=$p;
   fi
   if [ ${ndata} -eq 2 ]; then
     ISPRODUCTIO=$p;
   fi
   if [ ${ndata} -eq 3 ]; then
     DEBUGGING=$p;
   fi
   if [ ${ndata} -eq 4 ]; then
     DEBUG_LEVEL=$p;
   fi
   if [ ${ndata} -eq 5 ]; then
     BATHYdb=$p;
   fi
   if [ ${ndata} -eq 6 ]; then
     SHAPEFILEdb=$p;
   fi
   if [ ${ndata} -eq 7 ]; then
     ARCHdir=$p;
   fi
   if [ ${ndata} -eq 8 ]; then
    DATAdir=$p;
   fi
   if [ ${ndata} -eq 9 ]; then
    INPUTdir=$p;
   fi
   if [ ${ndata} -eq 10 ]; then
     LOGdir=$p;
   fi
   if [ ${ndata} -eq 11 ]; then
     VARdir=$p;
   fi
   if [ ${ndata} -eq 12 ]; then
     OUTPUTdir=$p;
   fi
   if [ ${ndata} -eq 13 ]; then
     RUNdir=$p;
   fi
   if [ ${ndata} -eq 14 ]; then
     TMPdir=$p;
   fi
   if [ ${ndata} -eq 15 ]; then
     RUNLEN=$p;
   fi
   if [ ${ndata} -eq 16 ]; then
     WNA=$p;
   fi
   if [ ${ndata} -eq 17 ]; then
     NEST=$p;
   fi
   if [ ${ndata} -eq 18 ]; then
     RTOFS=$p;
   fi
   if [ ${ndata} -eq 19 ]; then
     ESTOFS=$p;
   fi
   if [ ${ndata} -eq 20 ]; then
     WINDS=$p;
   fi
   if [ ${ndata} -eq 21 ]; then
     WEB=$p;
   fi
   if [ ${ndata} -eq 22 ]; then
     export PLOT=$p;
   fi
   if [ ${ndata} -eq 23 ]; then
     SITEID=$p;
   fi
   if [ ${ndata} -eq 24 ]; then
    MODELCORE=$p;
   fi
  ndata=$(( $ndata + 1 ))
done < ${RUNdir}/info_to_nwps_coremodel.txt

if [ "$1" != "" ]; then CGnumber="$1"; fi

if [ "${CGnumber}" == "" ]
    then
    msg="FATAL ERROR: Rip current program: No CGNUM was specified. Minimum usage is run_ripcurrent.sh [CGnumber] [Contour]"
    postmsg $jlogfile "$msg"
    export err=1; err_chk
fi
echo "++++++++++++ IN RUN_RIPCURRENT.SH++++++++++++++++++"
echo "CGnumber: ${CGnumber}"
echo "++++++++++++++++++++++++++++++++++++++++++++"

CGnumber=$(echo ${CGnumber} | tr [:lower:] [:upper:])

if [ "$2" != "" ]; then contour="$2"; fi

if [ "${contour}" == "" ]
    then
    msg="FATAL ERROR: Rip current program: No contour was specified. Minimum usage is run_nos.sh [CGnumber] [Contour]"
    postmsg $jlogfile "$msg"
    export err=1; err_chk
fi

echo "Platform is: $NWPSplatform"

if [ $NWPSplatform == "SRSWAN" ]
then
  NWPSDATA="${NWPSSRSWANDATA}"
elif [ $NWPSplatform == "DEV" ]
then
  NWPSDATA="${NWPSDEVDATA}"
elif [ $NWPSplatform == "IFPSWAN" ]
then
  NWPSDATA="${NWPSIFPSWANDATA}"
elif [ $NWPSplatform == "WCOSS" ] || [ $NWPSplatform == "DEVWCOSS" ]
then
  NWPSDATA="${DATA}"
fi

echo "NWPSDATA is: $NWPSDATA"

if [ -e ${NWPSDATA}/logs/runrip.log ]
   then
   rm -f ${NWPSDATA}/logs/runrip.log
fi

cat /dev/null > ${NWPSDATA}/logs/runrip.log

#____________________________________________________________________

# Find newest GRIB2 output file to process
ls -lt ${NWPSDATA}/output/grib2/${CGnumber}
gribfile=$(ls ${NWPSDATA}/output/grib2/${CGnumber}/*${CGnumber}*grib2 | xargs -n 1 basename | tail -n 1)
cycle=`echo $gribfile | cut -c23-26`
CYCLE=`echo $gribfile | cut -c23-24`
DATE=`echo $gribfile | cut -c14-21`
fullname=`echo $gribfile | cut -c14-26`

#CG=${contour}m_${CGnumber}_"$CYCLE"_"$DATE"_prob.txt_${SITEID}
CGCONT=${contour}m_contour_${CGnumber}."$fullname"_${SITEID}

echo "" 
echo "_________________________________________________________________"
echo "                           Rip Current Program                   "
echo "                                                                 "
echo "SITE:     ${SITEID}"
echo "DOMAIN:   ${CGnumber}"
echo "CONTOUR:  ${contour}m"
echo "CYCLE:    ${fullname}"
echo ""
echo "_________________________________________________________________"

######################################################
# Create Working Directory and configure program within NWPS

RIPDATA="${NWPSDATA}/output/rip_current/data/${contour}m"
if [ ! -e ${RIPDATA} ]; then mkdir -vp ${RIPDATA}; fi
cd ${RIPDATA}
pwd

# Run the Rip Current Model
echo "RIP CURRENT WORKING ON ${CGnumber}"
export INIT_DATE=${DATE}_$(printf %02d $CYCLE)00
siteid="${SITEID,,}"

# ======================================================================
# Set up the following Fortran Unit Number files for ripforecast.exe
#
# fort.20 = Current NWPS Output (ASCII)
# fort.21 = Shoreline direction data file (ASCII)
# fort.22 = Previous NWPS Output -- past 72 hours of Hs (ASCII)
# fort.23 = Output Probabilities (ASCII) (Appends)
# ======================================================================

# Copy required input data: (1) Wave model output along contour, (2) Beach orientation file
cp ${NWPSDATA}/run/${contour}m_contour_${CGnumber} ${RIPDATA}/${contour}m_contour_${CGnumber}"."${DATE}"_"$cycle"_${SITEID}"
cp ${FIXnwps}/beach_orient_db/${contour}m_RipForecastShoreline_${SITEID}.txt .

# Loop through contours and computational grids
for CONT in $contour; do
for CG in $CGnumber; do

# If the model file doesn't exist, move on to the next one
if [[ ! -f ${RIPDATA}/${CONT}m_contour_${CG}.${INIT_DATE}_${SITEID} ]]; then
   continue
fi

cp ${RIPDATA}/${contour}m_RipForecastShoreline_${SITEID}.txt ${RIPDATA}/fort.21

# ======================================================================
# Copy the data from the previous 72 hrs
# ======================================================================
cp -f $GESINm1/riphist/${SITEID}/${contour}*${CGnumber}*${SITEID} ${RIPDATA}
cp -f $GESINm2/riphist/${SITEID}/${contour}*${CGnumber}*${SITEID} ${RIPDATA}
cp -f $GESINm3/riphist/${SITEID}/${contour}*${CGnumber}*${SITEID} ${RIPDATA}

# ======================================================================
# Create output file and add header
# ======================================================================
echo "% " > fort.23
echo "% " >> fort.23
grep SWAN ${RIPDATA}/${CONT}m_contour_${CG}.${INIT_DATE}_${SITEID} >> fort.23
echo "% Rip Current Code Version:1.0" >> fort.23
echo "% " >> fort.23
echo "%DATE             Xp           Yp         Prob     Hs         pp        mwdsn      tide  event" >> fort.23

# ======================================================================
# Loop over the stations
# ======================================================================
while read line; do
   echo $line | grep -q "%"
   #if [[ $? == 0 ]]; then
   #  continue
   #fi
   export LAT=`echo $line | awk '{print $1}'`
   export LON=`echo $line | awk '{print $2}'`
   if [[ -z $LAT || -z $LON ]]; then
      continue
   fi
   # ======================================================================
   # Set up the input files
   # ======================================================================
   if [ -f fort.20 ]; then
      rm -f fort.20
   fi
   # Get the current model data
   if [[ -f ${RIPDATA}/${CONT}m_contour_${CG}.${INIT_DATE}_${SITEID} ]]; then
      let ntimes=${RUNLEN}+1
      cat ${RIPDATA}/${CONT}m_contour_${CG}.${INIT_DATE}_${SITEID} | \
      awk "/${LAT}/ && /${LON}/" | \
      head -${ntimes} >> fort.20
   fi
   # Get the data for the previous three days (just the first 24h for each run)
   if [ -f fort.22 ]; then
      rm -f fort.22
   fi
   export found="FALSE"
   for DAT in ${PDYm3} ${PDYm2} ${PDYm1} $DATE
   do
      let CYC=0
      while (( $CYC <= 21 )) && [ "${found}" == "FALSE" ]; do
         # JY if [[ $DAT == $DATE && $(printf %02d $CYC) == $(printf %02d $CYCLE) ]]; then
         if [[ $DAT == $DATE && $(printf %02d $CYC) == $(printf %02d ${CYCLE#0}) ]]; then
            break
         fi
         DAT_CYC="${DAT}_$(printf %02d $CYC)00"
         if [[ -f ${RIPDATA}/${CONT}m_contour_${CG}.${DAT_CYC}_${SITEID} ]]; then
            cat ${RIPDATA}/${CONT}m_contour_${CG}.${DAT_CYC}_${SITEID} | \
            awk "/${LAT}/ && /${LON}/" > rawout
            # Clip the raw output to only the start and end 72 hours needed
            startline=$(grep -n ${PDYm3}.${CYCLE}0000 rawout | cut -f1 -d: | tail -1)
            endline=$(grep -n ${DATE}.${CYCLE}0000 rawout | cut -f1 -d: | tail -1)
            if [ ! -z "$startline" ];
            then
               tail -n +$startline rawout | head -n $((endline-startline)) > fort.22
               export found="TRUE"
            else
               head -n $((endline-1)) rawout > fort.22
               export found="TRUE"
            fi
         fi
         let CYC=$CYC+3
      done
   done
   rm rawout
   # ======================================================================
   # Execute the program
   # ======================================================================
   if [[ -s fort.20 && -s fort.22 ]]; then
       ${NWPSdir}/exec/ripforecast.exe
       export err=$?;
       echo "Exit Code: ${err}" | tee -a ${LOGdir}/runrip.log
       if [ "${err}" != "0" ];then
          msg="FATAL ERROR: Rip current executable ripforecast.exe failed."
          postmsg "$jlogfile" "$msg"
       fi
       err_chk
   elif [[ -s fort.20 && ! -s fort.22 ]]; then
       echo "WARNING: Only the current model data was found."
       echo "WARNING: Not possible to compute event from the previous 72 hours."
       ${NWPSdir}/exec/ripforecast.exe
       export err=$?;
       echo "Exit Code: ${err}" | tee -a ${LOGdir}/runrip.log
       if [ "${err}" != "0" ];then
          msg="FATAL ERROR: Rip current executable ripforecast.exe failed."
          postmsg "$jlogfile" "$msg"
       fi
       err_chk
   fi  
   
done <  fort.21
#READ
done 
#CG
done 
#CONT

FORT23="${WFO}_${NET}_${contour}m_${CGnumber}_ripprob.${fullname}"
cp ${RIPDATA}/fort.23 ${RIPDATA}/${FORT23}

#exit 0

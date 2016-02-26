#!/bin/bash
#
### Modified by Donnie  King    12/3/2013 to mark variable changes  #########
### Modified by Roberto Padilla 07/22/2015 for WCOSS implementation #########
# ======================================================================
# Define initialization date
# ======================================================================
# Check to see if our SITEID is set

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

{
if [[ $# == 2 ]]; then
   export CYCLE=$1
   export DATE=$2
elif [[ $# == 1 ]]; then
   export CYCLE=$1
   export DATE=`date +%Y%m%d`
elif [[ $# == 3 ]]; then
   export CYCLE=$1
   export DATE=$2
   export CGS=$3
else
   echo "Correct usage:  run_rip.sh <CYCLE> <DATE> <CGNUM>"
   export err=1; err_chk
fi
##### Set your data directory##############
export RIPDATA="${DATA}/output/rip_current/data/5m"
##### Set Your Contours ###############
export CONTOURS="5m"
##### Set CG's ########################
#export CGS="CG2"
echo "RIP CURRENT WORKING ON $CGS"
pwd
export INIT_DATE=${DATE}_$(printf %02d $CYCLE)00
siteid="${SITEID,,}"
#
cp ${RIPDATA}/RipForecastShoreline.txt ${RIPDATA}/fort.21
pwd
cd ${RIPDATA}
for CONTOUR in $CONTOURS; do
for CG in $CGS; do
#
# If the model file doesn't exist, move on to the next one
if [[ ! -f ${RIPDATA}/${CONTOUR}_contour_${CG}.${INIT_DATE}_${SITEID} ]]; then
   continue
fi
#
# ======================================================================
# Define Fortran Unit Number filenames
#
# FORT20 = Current NWPS Output (ASCII)
# FORT21 = Shorline direction data file (ASCII)
# FORT22 = Previous NWPS Output -- past 72 hours of Hs (ASCII)
# FORT23 = Output Probabilities (ASCII)
# ======================================================================
export FORT20="${RIPDATA}/${WFO}_${NET}_${CONTOUR}_${CG}_data.${2}_${1}00"
export FORT21="${RIPDATA}/RipForecastShoreline.txt"
export FORT22="${RIPDATA}/${WFO}_${NET}_${CONTOUR}_${CG}_past72.${2}_${1}00"
export FORT23="${RIPDATA}/${WFO}_${NET}_${CONTOUR}_${CG}_ripprob.${2}_${1}00"
#
#
echo "% " > $FORT23
echo "% " >> $FORT23
grep SWAN ${RIPDATA}/${CONTOUR}_contour_${CG}.${INIT_DATE}_${SITEID} >> $FORT23
echo "% Rip Current Code Version:1.0" >> $FORT23
echo "% " >> $FORT23
echo "%DATE             Xp           Yp         Prob     Hs         pp        mwdsn      tide  event" >> $FORT23
cp $FORT23  fort.23

# ======================================================================
# Get the dates of the previous three days
# ======================================================================
#export PREVDATES=`${RIPDATA}/finddate.sh $DATE s-3`
#export DATE3=`echo $PREVDATES | cut -c19-26`
#export DATE2=`echo $PREVDATES | cut -c10-17`
#export DATE1=`echo $PREVDATES | cut -c1-8`

# ======================================================================
# cp the data from the previous 72 hrs.
# ======================================================================

  cp -f $GESINm1/riphist/${SITEID}/${contour}*${CGnumber}*${SITEID} ${RIPdir}
  cp -f $GESINm2/riphist/${SITEID}/${contour}*${CGnumber}*${SITEID} ${RIPdir}
  cp -f $GESINm3/riphist/${SITEID}/${contour}*${CGnumber}*${SITEID} ${RIPdir}

# ======================================================================
# Loop over the stations
# ======================================================================
while read line; do
   echo $line | grep -q "%"
   if [[ $? == 0 ]]; then
     continue
   fi
   export LAT=`echo $line | awk '{print $1}'`
   export LON=`echo $line | awk '{print $2}'`
   if [[ -z $LAT || -z $LON ]]; then
      continue
   fi
# ======================================================================
# Set up the input files
# ======================================================================
   if [ -f $FORT20 ]; then
      rm -f $FORT20
   fi
# Get the current model data
   if [[ -f ${RIPDATA}/${CONTOUR}_contour_${CG}.${INIT_DATE}_${SITEID} ]]; then
      cat ${RIPDATA}/${CONTOUR}_contour_${CG}.${INIT_DATE}_${SITEID} | \
      awk "/${LAT}/ && /${LON}/" | \
      head -103 >> $FORT20
   fi
# Get the data for the previous three days (just the first 24h for each run)
   if [ -f $FORT22 ]; then
      rm -f $FORT22
   fi
   export found="FALSE"
   for DAT in ${PDYm3} ${PDYm2} ${PDYm1} $DATE
   do
      let CYC=0
      while (( $CYC <= 21 )) && [ "${found}" == "FALSE" ]; do
         if [[ $DAT == $DATE && $(printf %02d $CYC) == $(printf %02d $CYCLE) ]]; then
            break
         fi
         DAT_CYC="${DAT}_$(printf %02d $CYC)00"
         if [[ -f ${RIPDATA}/${CONTOUR}_contour_${CG}.${DAT_CYC}_${SITEID} ]]; then
            cat ${RIPDATA}/${CONTOUR}_contour_${CG}.${DAT_CYC}_${SITEID} | \
            awk "/${LAT}/ && /${LON}/" > rawout
            # Clip the raw output to only the start and end 72 hours needed
            startline=$(grep -n ${PDYm3}.${CYCLE}0000 rawout | cut -f1 -d: | tail -1)
            endline=$(grep -n ${DATE}.${CYCLE}0000 rawout | cut -f1 -d: | tail -1)
            if [ ! -z "$startline" ];
            then
               tail -n +$startline rawout | head -n $((endline-startline)) > $FORT22
               export found="TRUE"
            else
               head -n $((endline-1)) rawout > $FORT22
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
#####  Make sure to set the location of the ripforecast.x program ######
   if [[ -s $FORT20 && -s $FORT22 ]]; then
       cp $FORT20  fort.20
       cp $FORT22  fort.22
       ${NWPSdir}/exec/ripforecast.x
   elif [[ -s $FORT20 && ! -s $FORT22 ]]; then
       echo "Only the current model data was found."
       echo "Some model data from the previous 72 hours is required to run"
   fi  
   
done <  fort.21
#READ
done 
#CG
done 
#CONTOUR
cp -f fort.20 $FORT20
cp -f fort.21 $FORT21
cp -f fort.22 $FORT22
cp -f fort.23 $FORT23

} >> ${NWPSDATA}/logs/runrip.log
exit 0

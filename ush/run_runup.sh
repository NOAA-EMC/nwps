#!/bin/bash
#
# ======================================================================
# Define initialization date
# ======================================================================
CYCLE="${1}"
DATE="${2}"
echo "LOGdir: $LOGdir" | tee -a logrunup
logrunp=${LOGdir}/run_runup.log
source ${DATA}/parm/templates/${siteid}/${SITEID}
SLOPEDATADIR="${TEMPDIRrunup}"
OUTDIR="${TEMPDIRrunup}"
CONTOURS="${RUNUPCONT}"
CGS="${RUNUPDOMAIN}"
#export INIT_DATE=${DATE}_$(printf %02d $CYCLE)00
INIT_DATE=${DATE}_${CYCLE}

#
echo "TEMPDIRrunup in run_runup.sh: ${TEMPDIRrunup}" | tee -a logrunup
echo " ${DATA}  ${siteid}/${SITEID} ${SLOPEDATADIR} ${CONTOURS} ${CGS}"  | tee -a logrunup
echo " ${TEMPDIRrunup} ${RUNUPDOMAIN}"  | tee -a logrunup
for CONTOUR in $CONTOURS; do
for CG in $CGS; do
echo "LOOKING FOR FILE :  ${CONTOUR}_contour_${CG}.${INIT_DATE}_${SITEID}" | tee -a logrunup
#
# If the model file doesn't exist, move on to the next one
if [[ ! -f ${CONTOUR}_contour_${CG}.${INIT_DATE}_${SITEID} ]]; then
echo "Cant find ${CONTOUR}_contour_${CG}.${INIT_DATE}_${SITEID}" | tee -a logrunup
   continue
fi
#
# ======================================================================
# Define Fortran Unit Number filenames
#
# FORT20 = Current NWPS Output (ASCII)
# FORT21 = Slope data file (ASCII)
# FORT22 = Output Runup (ASCII)

# ======================================================================
export FORT20="${CONTOUR}_${CG}_data.txt"
export FORT21="${CG}.${SITEID}_slopes.txt"
export FORT22="${WFO}_${NET}_${CONTOUR}_${CG}_runup.${DATE}_${CYCLE}"
#
# ======================================================================
# Set up the output file
# ======================================================================
echo "% " > $FORT22
echo "% " >> $FORT22
grep SWAN ${CONTOUR}_contour_${CG}.${INIT_DATE}_${SITEID} >> $FORT22
echo "% Runup Code Version:1.0" >> $FORT22
echo "% NOTE:  X,Y locations refer to shoreline location projected from the 20m contour" >> $FORT22
echo "% NOTE:  twl, twl95, twl05, dune crest and dune toe elevations all relative to MSL" >> $FORT22
echo "%DATE              Xp [m]        Yp [m]    Hs [m]     pp [s]      slope     twl [m]     twl95 [m]    twl05 [m]     runup [m]     runup95 [m]     runup05 [m]     setup [m]     swash [m]     inc. swash [m]     infrag. swash [m]     dune crest [m]    dune toe [m]   50% overwash [m]  50% erosion [m]   owash excd [%]   erosion excd [%]   rf2use2 [-]" >> $FORT22

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
   echo " LAT, LON: ${LAT}, ${LON}"  | tee -a logrunup

   if [[ -z $LAT || -z $LON ]]; then
      continue	  
   fi
# ======================================================================
# Set up the input file - doing a 72 hour forecast for now.
# ======================================================================
   if [ -f $FORT20 ]; then
      rm -f $FORT20
   fi
## Get the current model data
  if [[ -f ${CONTOUR}_contour_${CG}.${INIT_DATE}_${SITEID} ]]; then
#      cat ${TEMPDIRrunup}/${CONTOUR}_contour_${CG}.${INIT_DATE}_MHX | \
#      awk "/${LAT}/ && /${LON}/" | \
#      head -24 >> $FORT20
#   fi
      cat ${CONTOUR}_contour_${CG}.${INIT_DATE}_${SITEID} | \
      awk "/${LAT}/ && /${LON}/" >> $FORT20
    fi
# ======================================================================
# Execute the program
# ======================================================================
   if [ -s $FORT20 ]; then
        if [ "${SITEID}" == "SGX" ] || [ "${SITEID}" == "LOX" ] || [ "${SITEID}" == "MTR" ] \
        || [ "${SITEID}" == "EKA" ] || [ "${SITEID}" == "MFR" ] || [ "${SITEID}" == "PQR" ] \
        || [ "${SITEID}" == "SEW" ]
        then
           ${NWPSdir}/exec/runupforecast_wr.exe
           export err=$?;
        else
           ${NWPSdir}/exec/runupforecast.exe
           export err=$?;
        fi
        echo "Exit Code: ${err}" | tee -a ${LOGdir}/runup.log
        if [ "${err}" != "0" ];then
           msg="FATAL ERROR: Wave runup executable runupforecast.exe failed."
           postmsg "$jlogfile" "$msg"
        fi
        err_chk
   fi  

done < $FORT21
#READ
done 
#CG
done 
#CONTOUR

#rm $FORT20


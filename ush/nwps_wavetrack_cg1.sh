#!/bin/bash
set -xa

# Halt this script it the model or Perl interface crashes
#if [ -e ${OUTPUTdir}/netCdf/not_completed ]
#    then
#    echo "SWAN Run failed!"                                  | tee -a $logfile
#    echo "Exiting ${PROGRAMname} with no further processing" | tee -a $logfile
#    export err=1; err_chk
#fi

echo " "                                            | tee -a $logfile
echo -n "SWAN Run Finished: "                       | tee -a $logfile
date                                                | tee -a $logfile
echo " " | tee -a $logfile


#Running Wave Tracking
hastracking=$(cat ${RUNdir}/Tracking.flag)
if [ "${hastracking}" == "TRUE" ] 
   then
   echo "Wave Tracking Started: "                      | tee -a $logfile
   date -u                                             | tee -a $logfile
   cd ${RUNdir}
   pwd                                                 | tee -a $logfile

   # ----- Convert partition file to Python scikit learn format ----
   mv swan_part.CG1.raw partition.raw
   ${EXECnwps}/ww3_sysprep.exe

   # ----- Call script to perform cluster-based wave tracking ----
   cd ${RUNdir}
   #perl -I${PMnwps} -I${RUNdir} ${USHnwps}/waveTracking.pl | tee -a $logfile
   ${USHnwps}/waveTracking.pl | tee -a $logfile

   # ----- Copy outputs to COMOUT ----
   inputparm="${RUNdir}/inputCG1"
   if [ ! -e ${inputparm} ]
   then
      msg="FATAL ERROR: Runup program: Missing inputCG1 file. Cannot open ${inputparm}"
      postmsg $jlogfile "$msg"
      export err=1; err_chk
   fi


   # 1) Parse YYYY MM DD HH MM from the INPGRID WIND line
   init="$(awk '/^INPGRID[[:space:]]+WIND/{print $11; exit}' "$inputparm")"  # e.g., 20250911.1800
   ts="${init//[^0-9]/}"
   yyyy="${ts:0:4}"; mon="${ts:4:2}"; dd="${ts:6:2}"; hh="${ts:8:2}"; mm="${ts:10:2}"

   # Sanity check
   if [ -z "$yyyy$mon$dd$hh$mm" ]; then
     echo "ERROR: could not parse INPGRID WIND time from $inputparm" >&2
     export err=1; err_chk
   fi

   # 2) Build PDY and cycle
   export PDY_INPUT="${yyyy}${mon}${dd}"

   # Prefer workflow cycle file; fallback to parsed hour
   cycle="$(awk 'NR==1{print $1}' "${RUNdir}/CYCLE" 2>/dev/null || true)"
   [ -z "${cycle}" ] && cycle="${hh}"
   cycle="$(printf '%02d' "${cycle#0}")"
   export cycle

   # 3) Rebuild COMOUT for the correct day from the existing COMOUT path
   COMOUT_WFO="$(basename -- "$COMOUT")"            # -> <WFO> (site folder, e.g., box)
   COMOUT_PARENT="$(dirname -- "$COMOUT")"          # -> .../<REGION>.<PDY>
   REGION_DOT_PDY="$(basename -- "$COMOUT_PARENT")" # -> <REGION>.<PDY> (e.g., er.20250911)
   REGION_ONLY="${REGION_DOT_PDY%%.*}"              # -> <REGION> (e.g., er)
   export COMOUT_ROOT="$(dirname -- "$COMOUT_PARENT")"     # -> .../nwps/v1.5.0

   export COMOUT_CORRECT="${COMOUT_ROOT}/${REGION_ONLY}.${PDY_INPUT}/${COMOUT_WFO}"
   
   cycle=$(awk '{print $1;}' ${RUNdir}/CYCLE)
   COMOUTCYC="${COMOUT_CORRECT}/${cycle}/CG0"
   tar -czvf mapplots_CG0_${PDY_INPUT}${cycle}.tar.gz swan_systrk1_hr???.png
   cp -fv ${RUNdir}/mapplots_CG0_${PDY_INPUT}${cycle}.tar.gz $COMOUTCYC/
   cp -fv ${RUNdir}/${siteid}_nwps_CG0_Trkng_${PDY_INPUT}_${cycle}00.bull $COMOUTCYC/
   rm ${RUNdir}/swan_systrk1_hr???.png
fi

#########################################################################

echo " "                                            | tee -a $logfile
echo -n "Wave Tracking Run Finished: "              | tee -a $logfile
date                                                | tee -a $logfile
echo " " | tee -a $logfile

################################################################### 
echo " "                                            | tee -a $logfile
echo "===================================="         | tee -a $logfile
echo "Done running Wave Tracking"                            | tee -a $logfile
date "+%D  %H:%M:%S"                                | tee -a $logfile
echo "===================================="         | tee -a $logfile
echo " "                                            | tee -a $logfile

cd ${DATAROOT}
exit 0

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
   cycle=$(awk '{print $1;}' ${RUNdir}/CYCLE)
   COMOUTCYC="${COMOUT}/${cycle}/CG0"
   tar -czvf mapplots_CG0_${PDY}${cycle}.tar.gz swan_systrk1_hr???.png
   cp -fv ${RUNdir}/mapplots_CG0_${PDY}${cycle}.tar.gz $COMOUTCYC/
   cp -fv ${RUNdir}/${siteid}_nwps_CG0_Trkng_${PDY}_${cycle}00.bull $COMOUTCYC/
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

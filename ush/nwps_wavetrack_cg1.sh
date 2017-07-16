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
#Next line if a test then ww3_systrk.inp from the test directory
#TESTYoN 
hastracking=$(cat ${RUNdir}/Tracking.flag)
if [ "${hastracking}" == "TRUE" ] 
   then
   echo "Wave Tracking Started: "                      | tee -a $logfile
   date -u                                             | tee -a $logfile
   cd ${RUNdir}
   pwd                                                 | tee -a $logfile
   #AW echo 'Removing empty lines in partition.raw file...'
   #AW sed -i.bak '/ 0.0  0.0 270.0  0.0   0.0/,+1d' ${RUNdir}/swan_part.CG1.raw
   echo "perl -I${PMnwps} -I${RUNdir} ${USHnwps}/waveTracking.pl" | tee -a $logfile    
   perl -I${PMnwps} -I${RUNdir} ${USHnwps}/waveTracking.pl | tee -a $logfile
   export err=$?; err_chk
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

#!/bin/bash
set -xa
echo "============================================================="
echo "=                                                           ="
echo "=         RUNNING NWPS-WCOSS FOR SITE: ${SITEID}                  ="
echo "=                                                           ="
echo "============================================================="
#
###############################################################################
# THE VALUE OF THE FOLLOWING PARAMETERS ARE FIXED IN ~/ush/run_nwps_wcoss.sh  #
###############################################################################
export DELTAC=${DELTAC:-600}
export RUNLEN=${RUNLEN:-102}
export WAVEMODEL=${WAVEMODEL:-swan}
export WINDS=${WINDS:-FORECASTER}
export DOMAINSET=${DOMAINSET:-${FIXnwps}/domains/${SITEID}}

# Copy all required data from run archive
mkdir ${INPUTdir}/estofs/ ${INPUTdir}/psurge/ ${INPUTdir}/rtofs/
cd ${RUNdir}
for CG in CG1 CG0 CG2 CG3 CG4 CG5
do
   echo 'Searching for archived data from '${HPSSARCHdir}/${REGION}.${PDY}/${siteid}/${cyc}/${CG}
   if [ -d "${HPSSARCHdir}/${REGION}.${PDY}/${siteid}/${cyc}/${CG}" ]; then
      echo 'Data found. Copying to '${RUNdir}
      cp -pv ${HPSSARCHdir}/${REGION}.${PDY}/${siteid}/${cyc}/${CG}/* ${RUNdir}
      cp -pv ${HPSSARCHdir}/${REGION}.${PDY}/${siteid}/${cyc}/${CG}/*${CG}.cur ${INPUTdir}/rtofs/
      if [ $CG == CG1 ]; then
         #tar -xf ${RUNdir}/*.spec.swan.tar
         mv NWPSWINDGRID_${siteid}* ${INPUTdir}/
         if [ -e wave_estofs_waterlevel_*.tar ]; then
            mv wave_estofs_waterlevel_*.tar ${INPUTdir}/estofs/
            cd ${INPUTdir}/estofs/
            tar -xf ${INPUTdir}/estofs/*.tar
            cd ${RUNdir}
         fi
         if [ -e wave_psurge_waterlevel_*.tar ]; then
            mv wave_psurge_waterlevel_*.tar ${INPUTdir}/psurge/
            cd ${INPUTdir}/psurge/
            tar -xf ${INPUTdir}/psurge/*.tar
            cd ${RUNdir}
         fi
         if [ -e wave_rtofs_current_*.tar ]; then
            mv wave_rtofs_current_*.tar ${INPUTdir}/rtofs/
            cd ${INPUTdir}/rtofs/
            tar -xf ${INPUTdir}/rtofs/*.tar
            cd ${RUNdir}
         fi
         cd ${RUNdir}
         #-------- Optional: Copy hotstart files ---------------------------
         # NOTE: Don't use this option for a long-term retrospective
         #       because you'll overwrite the newly-computed hotstart files
         #mkdir -p ${GESIN}/hotstart/${SITEID}/${cyc}
         #mv ${RUNdir}/${PDY}.${cyc}00* ${GESIN}/hotstart/${SITEID}/${cyc}/
         #------------------------------------------------------------------
      fi
   fi
   mv input${CG} input${CG}.org
done

${USHnwps}/run_nwps_wcoss.sh --sitename ${SITEID} --runlen ${RUNLEN}  --wna --nest --waterlevels ESTOFS --rtofs --winds ${WINDS} --domainsetup ${DOMAINSET} --deltac ${DELTAC} --plot --wavemodel ${WAVEMODEL}
export err=$?; err_chk

echo "Pre-process completed"
exit 0


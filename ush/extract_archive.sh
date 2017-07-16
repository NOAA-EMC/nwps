#!/bin/bash

# Copy all required data from run archive

cd ${RUNdir}
for CG in CG1 CG0 CG2 CG3 CG4 CG5
do
   echo 'Searching for archived data from '${HPSSARCHdir}/${REGION}.${PDY}/${siteid}/${cyc}/${CG}
   if [ -d "${HPSSARCHdir}/${REGION}.${PDY}/${siteid}/${cyc}/${CG}" ]; then
      echo 'Data found. Copying to '${RUNdir}
      cp -pv ${HPSSARCHdir}/${REGION}.${PDY}/${siteid}/${cyc}/${CG}/* ${RUNdir}
      if [ $CG == CG1 ]; then
         # NOTE: Take only newest wave spec and GFE wind files from archive, in case of reruns by WFO
         specfile=`ls ${RUNdir}/*.spec.swan.tar | tail -1`
         tar -xf ${specfile}
         rm ${INPUTdir}/NWPSWINDGRID*
         rm ${INPUTdir}/*WIND.txt
         windfile=`ls ${RUNdir}/NWPSWINDGRID* | tail -1`
         mv ${windfile} ${INPUTdir}/
         rm ${RUNdir}/NWPSWINDGRID*
         rm ${RUNdir}/*.wnd
         mkdir ${INPUTdir}/estofs/ ${INPUTdir}/psurge/ ${INPUTdir}/rtofs/
         wlevfile=`ls ${RUNdir}/wave_estofs_waterlevel_*.tar | tail -1`
         if [ ${wlevfile} != "" ]; then
            mv wave_estofs_waterlevel_*.tar ${INPUTdir}/estofs/
            cd ${INPUTdir}/estofs/
            wlevfile=`ls ${INPUTdir}/estofs/*.tar | tail -1`
            tar -xf ${wlevfile}
            cd ${RUNdir}
         fi
         wlevfile=`ls ${RUNdir}/wave_psurge_waterlevel_*.tar | tail -1`
         if [ ${wlevfile} != "" ]; then
            mv wave_psurge_waterlevel_*.tar ${INPUTdir}/psurge/
            cd ${INPUTdir}/psurge/
            wlevfile=`ls ${INPUTdir}/psurge/*.tar | tail -1`
            tar -xf ${wlevfile}
            cd ${RUNdir}
         fi
         curfile=`ls ${RUNdir}/wave_rtofs_current_*.tar | tail -1`
         if [ ${curfile} != "" ]; then
            mv wave_rtofs_current_*.tar ${INPUTdir}/rtofs/
            cd ${INPUTdir}/rtofs/
            curfile=`ls ${INPUTdir}/rtofs/*.tar | tail -1`
            tar -xf ${curfile}
            cd ${RUNdir}
         fi
         cd ${RUNdir}
         #-------- Optional: Copy hotstart files ---------------------------
         # NOTE: Don't use this option for a long-term retrospective
         #       because you'll overwrite the newly-computed hotstart files
         mkdir -p ${GESIN}/hotstart/${SITEID}/${cyc}
         mv ${RUNdir}/${PDY}.${cyc}00* ${GESIN}/hotstart/${SITEID}/${cyc}/
         #------------------------------------------------------------------
      fi
   fi
   cp input${CG} input${CG}.org
done

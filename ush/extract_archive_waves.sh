#!/bin/bash

# Copy required wave boundary data from run archive

cd ${RUNdir}
for CG in CG1
do
   echo 'Searching for archived data from '${HPSSARCHdir}/${REGION}.${PDY}/${siteid}/${cyc}/${CG}
   if [ -d "${HPSSARCHdir}/${REGION}.${PDY}/${siteid}/${cyc}/${CG}" ]; then
      echo 'Data found. Copying to '${RUNdir}
      cp -pv ${HPSSARCHdir}/${REGION}.${PDY}/${siteid}/${cyc}/${CG}/*.spec.swan.tar ${RUNdir}
      if [ $CG == CG1 ]; then
         # NOTE: Take only newest wave spec and GFE wind files from archive, in case of reruns by WFO
         specfile=`ls ${RUNdir}/*.spec.swan.tar | tail -1`
         tar -xf ${specfile}
      fi
   fi
done

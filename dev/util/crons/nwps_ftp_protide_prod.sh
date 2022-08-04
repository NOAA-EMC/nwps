#!/bin/bash
# --------------------------------------------------------------------------- #
#                                                                             #
# nwps_val.cron : Script manages the running of the NWPS validation script    #
#             ${workdir}/nwps_webgraph.sh                                     #
#                                                                             #
# Remarks   - Can be run interactively, or from LL.                           #
#                                                                             #
# Last Changed : 06-20-2016                                        June 2016  #
# --------------------------------------------------------------------------- #

regions="sr er wr pr ar"

PDY=$(date +%Y%m%d)
PDYm1=$(date +%Y%m%d -d "1 day ago")
PDYm5=$(date -d "5 days ago" +%Y%m%d)

for region in $regions
do
   workdir=/lfs/h1/ops/prod/com/nwps/v1.4/${region}.${PDY}

   #Copy Protide data at LOX
   if [ $region = 'wr' ]
   then
      wfo='lox'
      if [ -d ${workdir}'/'${wfo} ]
      then
         cd ${workdir}/${wfo}
         cycles="00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23"
         for cycle in $cycles
         do
            if [ -d ${workdir}'/'${wfo}'/'${cycle} ]
            then
               cd ${workdir}/${wfo}/${cycle}
               pwd
               cgnum='CG1'
               ssh waves@emcrzdm 'mkdir -p /home/www/polar/nwps/protide_data/'${region}'.'${PDY}'/'${wfo}'/'${cycle}'/'${cgnum}
               scp ${workdir}/${wfo}/${cycle}/${cgnum}/SPC2D.*.HH${cycle} waves@emcrzdm:/home/www/polar/nwps/protide_data/${region}.${PDY}/${wfo}/${cycle}/${cgnum}/
               cgnum='CG2'
               ssh waves@emcrzdm 'mkdir -p /home/www/polar/nwps/protide_data/'${region}'.'${PDY}'/'${wfo}'/'${cycle}'/'${cgnum}
               scp ${workdir}/${wfo}/${cycle}/${cgnum}/SPC2D.*.HH${cycle} waves@emcrzdm:/home/www/polar/nwps/protide_data/${region}.${PDY}/${wfo}/${cycle}/${cgnum}/
            fi
         done
      fi
   fi
done

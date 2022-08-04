#!/bin/bash
# --------------------------------------------------------------------------- #
#                                                                             #
# nwps_val.cron : Script manages the running of the NWPS validation script    #
#             ${workdir}/nwps_webgraph.sh                                     #
#                                                                             #
# Remarks   - Can be run interactively, or from LL.                           #
#                                                                             #
# Last Changed : 10-26-2015                                     October 2015  #
# --------------------------------------------------------------------------- #

region="sr"
wfos="bro crp hgx lch lix mob tae tbw key mfl mlb jax sju"
cgnums="CG1 CG0"
# Cycles in reverse order to use the newest results
#cycles="23 22 21 20 19 18 17 16 15 14 13 12 11 10 09 08 07 06 05 04 03 02 01 00"

PDY=$(date +%Y%m%d)

for wfo in $wfos
do
   #datafound='false'
   #for cycle in $cycles
   #do
   workdir=/lfs/h1/ops/prod/com/nwps/v1.4/${region}.${PDY}/${wfo}
   echo ${workdir}
   cd ${workdir}
   cycle=$(ls -t | head -1)
      #if [ ${datafound} == 'false' ]
      #then
         for cgnum in $cgnums
         do
            echo 'Searching' ${wfo} ${cgnum}
            if [ -f ${workdir}/${cycle}/${cgnum}/plots*.tar.gz ]
            then
               echo 'Copying from' ${workdir}/${cycle}
               cd ${workdir}/${cycle}/${cgnum}/

               scp ${workdir}/${cycle}/${cgnum}/plots*.tar.gz waves@emcrzdm:/home/www/polar/nwps/images/rtimages/${wfo}/nwps/${cgnum}/
               scp ${workdir}/${cycle}/${cgnum}/shiproute_plots*.tar.gz waves@emcrzdm:/home/www/polar/nwps/images/rtimages/${wfo}/nwps/${cgnum}/
               ssh waves@emcrzdm 'cd /home/www/polar/nwps/images/rtimages/'${wfo}'/nwps/'${cgnum}'/; tar -xf plots*.tar.gz'
               ssh waves@emcrzdm 'cd /home/www/polar/nwps/images/rtimages/'${wfo}'/nwps/'${cgnum}'/; rm plots*.tar.gz'
               ssh waves@emcrzdm 'cd /home/www/polar/nwps/images/rtimages/'${wfo}'/nwps/'${cgnum}'/; tar -xf shiproute_plots*.tar.gz'
               ssh waves@emcrzdm 'cd /home/www/polar/nwps/images/rtimages/'${wfo}'/nwps/'${cgnum}'/; rm shiproute_plots*.tar.gz'
               # In case of MFL copy also shiproute plots to prod
               if [ ${wfo} == 'mfl' ]
               then
                  scp ${workdir}/${cycle}/${cgnum}/shiproute_plots*.tar.gz waves@emcrzdm:/home/www/polar/nwps/images/rtimages/${wfo}/nwps/${cgnum}/ 
                  ssh waves@emcrzdm 'cd /home/www/polar/nwps/images/rtimages/'${wfo}'/nwps/'${cgnum}'/; tar -xf shiproute_plots*.tar.gz'
                  ssh waves@emcrzdm 'cd /home/www/polar/nwps/images/rtimages/'${wfo}'/nwps/'${cgnum}'/; rm shiproute_plots*.tar.gz'
               fi

               # Copy new clustering-based wave tracking results
               #if [ ${cgnum} == 'CG0' ]
               #then
                  echo 'Copying cluster data...'
                  scp ${workdir}/${cycle}/${cgnum}/mapplots*.tar.gz waves@emcrzdm:/home/www/polar/nwps/images/rtimages/${wfo}/nwps/CG1/
                  ssh waves@emcrzdm 'cd /home/www/polar/nwps/images/rtimages/'${wfo}'/nwps/CG1/; tar -xf mapplots*.tar.gz'
                  ssh waves@emcrzdm 'cd /home/www/polar/nwps/images/rtimages/'${wfo}'/nwps/CG1/; rm mapplots*.tar.gz'
               #fi

               #datafound='true'
            fi
         done
      #fi
   #done
done


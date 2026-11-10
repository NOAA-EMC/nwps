#!/bin/bash
set -xa
# --------------------------------------------------------------------------- #
#                                                                             #
# nwps_val.cron : Script manages the running of the NWPS validation script    #
#             ${workdir}/nwps_webgraph.sh                                     #
#                                                                             #
# Remarks   - Can be run interactively, or from LL.                           #
#                                                                             #
# Last Changed : 10-26-2015                                     October 2015  #
# --------------------------------------------------------------------------- #

region="er"
wfos="chs ilm mhx akq lwx phi okx box gyx car"
cgnums="CG1 CG0"
# Cycles in reverse order to use the newest results
cycles="23 22 21 20 19 18 17 16 15 14 13 12 11 10 09 08 07 06 05 04 03 02 01 00"

PDY=$(date +%Y%m%d)

for wfo in $wfos
do
   datafound='false'
   for cycle in $cycles
   do
      if [ ${datafound} == 'false' ]
      then
         workdir=/lfs/h1/ops/prod/com/nwps/v1.5/${region}.${PDY}/${wfo}/${cycle}
         echo ${workdir}
         for cgnum in $cgnums
         do
            echo 'Searching' ${wfo} ${cgnum}
            if [ -f ${workdir}/${cgnum}/nwps.t*z.plots*.tar.gz ]
            then
               echo 'Copying from' ${workdir}
               cd ${workdir}/${cgnum}/

               scp ${workdir}/${cgnum}/nwps.t*z.plots*.tar.gz waves@emcrzdm:/home/www/polar/nwps/images/rtimages/${wfo}/nwps/${cgnum}/
               scp ${workdir}/${cgnum}/nwps.t*z.shiproute_plots*.tar.gz waves@emcrzdm:/home/www/polar/nwps/images/rtimages/${wfo}/nwps/${cgnum}/
               # Clean out old figures first
               #ssh waves@emcrzdm 'cd /home/www/polar/nwps/images/rtimages/'${wfo}'/nwps/'${cgnum}'/; rm *.png'
               ssh waves@emcrzdm 'cd /home/www/polar/nwps/images/rtimages/'${wfo}'/nwps/'${cgnum}'/; tar -xf nwps.t*z.plots*.tar.gz'
               ssh waves@emcrzdm 'cd /home/www/polar/nwps/images/rtimages/'${wfo}'/nwps/'${cgnum}'/; rm nwps.t*z.plots*.tar.gz'
               ssh waves@emcrzdm 'cd /home/www/polar/nwps/images/rtimages/'${wfo}'/nwps/'${cgnum}'/; tar -xf nwps.t*z.shiproute_plots*.tar.gz'
               ssh waves@emcrzdm 'cd /home/www/polar/nwps/images/rtimages/'${wfo}'/nwps/'${cgnum}'/; rm nwps.t*z.shiproute_plots*.tar.gz'
               #rm ${workdir}/${cgnum}/*.png

               # Copy new clustering-based wave tracking results
               #if [ ${cgnum} == 'CG0' ]
               #then
                  echo 'Copying cluster data...'
                  scp ${workdir}/${cgnum}/nwps.t*z.mapplots*.tar.gz waves@emcrzdm:/home/www/polar/nwps/images/rtimages/${wfo}/nwps/CG1/
                  ssh waves@emcrzdm 'cd /home/www/polar/nwps/images/rtimages/'${wfo}'/nwps/CG1/; tar -xf nwps.t*z.mapplots*.tar.gz'
                  ssh waves@emcrzdm 'cd /home/www/polar/nwps/images/rtimages/'${wfo}'/nwps/CG1/; rm nwps.t*z.mapplots*.tar.gz'
               #fi

               datafound='true'
            fi
         done
      fi
   done
done


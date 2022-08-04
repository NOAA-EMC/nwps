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

region="ar"
wfos="aer alu afg ajk"
cgnums="CG1 CG0"

PDY=$(date +%Y%m%d)
PDYm1=$(date +%Y%m%d -d "1 day ago")

#Check for yesterday's runs completed (shortly) after midnight.
for wfo in $wfos
do
   wfodir=/lfs/h2/emc/ptmp/andre.vanderwesthuysen/com/nwps/v1.5.0/${region}.${PDYm1}/${wfo}
   cd ${wfodir}
   #Find most recent cycle
   export cycle=$(ls -t | head -1)
   #datafound='false'
   #for cycle in $cycles
   #do
      if [ ${cycle} != '' ]
      then
         workdir=${wfodir}/${cycle}
         echo ${workdir}
         for cgnum in $cgnums
         do
            echo 'Searching' ${wfo} ${cgnum}
            if [ -f ${workdir}/${cgnum}/plots*.tar.gz ]
            then
               echo 'Copying from' ${workdir}
               cd ${workdir}/${cgnum}/

               scp ${workdir}/${cgnum}/plots*.tar.gz waves@emcrzdm:/home/www/polar/nwps/para/images/rtimages/${wfo}/nwps/${cgnum}/
               scp ${workdir}/${cgnum}/shiproute_plots*.tar.gz waves@emcrzdm:/home/www/polar/nwps/para/images/rtimages/${wfo}/nwps/${cgnum}/
               # Clean out old figures first
               #ssh waves@emcrzdm 'cd /home/www/polar/nwps/para/images/rtimages/'${wfo}'/nwps/'${cgnum}'/; rm *.png'
               ssh waves@emcrzdm 'cd /home/www/polar/nwps/para/images/rtimages/'${wfo}'/nwps/'${cgnum}'/; tar -xf --overwrite plots*.tar.gz'
               ssh waves@emcrzdm 'cd /home/www/polar/nwps/para/images/rtimages/'${wfo}'/nwps/'${cgnum}'/; cp  Hansonplot_buoy028.png Hansonplot_46028.png'
               ssh waves@emcrzdm 'cd /home/www/polar/nwps/para/images/rtimages/'${wfo}'/nwps/'${cgnum}'/; cp  Hansonplot_buoy219.png Hansonplot_46219.png'
               ssh waves@emcrzdm 'cd /home/www/polar/nwps/para/images/rtimages/'${wfo}'/nwps/'${cgnum}'/; cp  Hansonplot_buoy069.png Hansonplot_46069.png'
               ssh waves@emcrzdm 'cd /home/www/polar/nwps/para/images/rtimages/'${wfo}'/nwps/'${cgnum}'/; cp  Hansonplot_buoy221.png Hansonplot_46221.png'
               ssh waves@emcrzdm 'cd /home/www/polar/nwps/para/images/rtimages/'${wfo}'/nwps/'${cgnum}'/; cp  Hansonplot_buoy222.png Hansonplot_46222.png'
               ssh waves@emcrzdm 'cd /home/www/polar/nwps/para/images/rtimages/'${wfo}'/nwps/'${cgnum}'/; cp  Hansonplot_buoy253.png Hansonplot_46253.png'
               ssh waves@emcrzdm 'cd /home/www/polar/nwps/para/images/rtimages/'${wfo}'/nwps/'${cgnum}'/; cp  Hansonplot_buoy256.png Hansonplot_46256.png'
               ssh waves@emcrzdm 'cd /home/www/polar/nwps/para/images/rtimages/'${wfo}'/nwps/'${cgnum}'/; rm plots*.tar.gz'
               ssh waves@emcrzdm 'cd /home/www/polar/nwps/para/images/rtimages/'${wfo}'/nwps/'${cgnum}'/; tar -xf shiproute_plots*.tar.gz'
               ssh waves@emcrzdm 'cd /home/www/polar/nwps/para/images/rtimages/'${wfo}'/nwps/'${cgnum}'/; rm shiproute_plots*.tar.gz'
               #rm ${workdir}/${cgnum}/*.png

               # Copy new clustering-based wave tracking results
               #if [ ${cgnum} == 'CG0' ]
               #then
                  echo 'Copying cluster data...'
                  scp ${workdir}/${cgnum}/mapplots*.tar.gz waves@emcrzdm:/home/www/polar/nwps/para/images/rtimages/${wfo}/nwps/CG1/
                  ssh waves@emcrzdm 'cd /home/www/polar/nwps/para/images/rtimages/'${wfo}'/nwps/CG1/; tar -xf mapplots*.tar.gz'
                  ssh waves@emcrzdm 'cd /home/www/polar/nwps/para/images/rtimages/'${wfo}'/nwps/CG1/; rm mapplots*.tar.gz'
               #fi

               #datafound='true'
            fi
         done
      fi
   #done
done

#Check for today's runs
for wfo in $wfos
do
   wfodir=/lfs/h2/emc/ptmp/andre.vanderwesthuysen/com/nwps/v1.5.0/${region}.${PDY}/${wfo}
   cd ${wfodir}
   #Find most recent cycle
   export cycle=$(ls -t | head -1)
   #datafound='false'
   #for cycle in $cycles
   #do
      if [ ${cycle} != '' ]
      then
         workdir=${wfodir}/${cycle}
         echo ${workdir}
         for cgnum in $cgnums
         do
            echo 'Searching' ${wfo} ${cgnum}
            if [ -f ${workdir}/${cgnum}/plots*.tar.gz ]
            then
               echo 'Copying from' ${workdir}
               cd ${workdir}/${cgnum}/

               scp ${workdir}/${cgnum}/plots*.tar.gz waves@emcrzdm:/home/www/polar/nwps/para/images/rtimages/${wfo}/nwps/${cgnum}/
               scp ${workdir}/${cgnum}/shiproute_plots*.tar.gz waves@emcrzdm:/home/www/polar/nwps/para/images/rtimages/${wfo}/nwps/${cgnum}/
               # Clean out old figures first
               #ssh waves@emcrzdm 'cd /home/www/polar/nwps/para/images/rtimages/'${wfo}'/nwps/'${cgnum}'/; rm *.png'
               ssh waves@emcrzdm 'cd /home/www/polar/nwps/para/images/rtimages/'${wfo}'/nwps/'${cgnum}'/; tar -xf plots*.tar.gz'
               ssh waves@emcrzdm 'cd /home/www/polar/nwps/para/images/rtimages/'${wfo}'/nwps/'${cgnum}'/; cp  Hansonplot_buoy028.png Hansonplot_46028.png'
               ssh waves@emcrzdm 'cd /home/www/polar/nwps/para/images/rtimages/'${wfo}'/nwps/'${cgnum}'/; cp  Hansonplot_buoy219.png Hansonplot_46219.png'
               ssh waves@emcrzdm 'cd /home/www/polar/nwps/para/images/rtimages/'${wfo}'/nwps/'${cgnum}'/; cp  Hansonplot_buoy069.png Hansonplot_46069.png'
               ssh waves@emcrzdm 'cd /home/www/polar/nwps/para/images/rtimages/'${wfo}'/nwps/'${cgnum}'/; cp  Hansonplot_buoy221.png Hansonplot_46221.png'
               ssh waves@emcrzdm 'cd /home/www/polar/nwps/para/images/rtimages/'${wfo}'/nwps/'${cgnum}'/; cp  Hansonplot_buoy222.png Hansonplot_46222.png'
               ssh waves@emcrzdm 'cd /home/www/polar/nwps/para/images/rtimages/'${wfo}'/nwps/'${cgnum}'/; cp  Hansonplot_buoy253.png Hansonplot_46253.png'
               ssh waves@emcrzdm 'cd /home/www/polar/nwps/para/images/rtimages/'${wfo}'/nwps/'${cgnum}'/; cp  Hansonplot_buoy256.png Hansonplot_46256.png'
               ssh waves@emcrzdm 'cd /home/www/polar/nwps/para/images/rtimages/'${wfo}'/nwps/'${cgnum}'/; rm plots*.tar.gz'
               ssh waves@emcrzdm 'cd /home/www/polar/nwps/para/images/rtimages/'${wfo}'/nwps/'${cgnum}'/; tar -xf shiproute_plots*.tar.gz'
               ssh waves@emcrzdm 'cd /home/www/polar/nwps/para/images/rtimages/'${wfo}'/nwps/'${cgnum}'/; rm shiproute_plots*.tar.gz'
               #rm ${workdir}/${cgnum}/*.png

               # Copy new clustering-based wave tracking results
               #if [ ${cgnum} == 'CG0' ]
               #then
                  echo 'Copying cluster data...'
                  scp ${workdir}/${cgnum}/mapplots*.tar.gz waves@emcrzdm:/home/www/polar/nwps/para/images/rtimages/${wfo}/nwps/CG1/
                  ssh waves@emcrzdm 'cd /home/www/polar/nwps/para/images/rtimages/'${wfo}'/nwps/CG1/; tar -xf mapplots*.tar.gz'
                  ssh waves@emcrzdm 'cd /home/www/polar/nwps/para/images/rtimages/'${wfo}'/nwps/CG1/; rm mapplots*.tar.gz'
               #fi

               #datafound='true'
            fi
         done
      fi
   #done
done


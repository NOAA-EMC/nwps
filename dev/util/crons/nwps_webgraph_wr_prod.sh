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

region="wr"
wfos="sew pqr mfr eka mtr lox sgx"
cgnums="CG1 CG0"

PDY=$(date +%Y%m%d)
PDYm1=$(date +%Y%m%d -d "1 day ago")

#Check for yesterday's runs completed (shortly) after midnight.
for wfo in $wfos
do
   wfodir=/lfs/h1/ops/prod/com/nwps/v1.4/${region}.${PDYm1}/${wfo}
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

               scp ${workdir}/${cgnum}/plots*.tar.gz waves@emcrzdm:/home/www/polar/nwps/images/rtimages/${wfo}/nwps/${cgnum}/
               scp ${workdir}/${cgnum}/shiproute_plots*.tar.gz waves@emcrzdm:/home/www/polar/nwps/images/rtimages/${wfo}/nwps/${cgnum}/
               # Clean out old figures first
               #ssh waves@emcrzdm 'cd /home/www/polar/nwps/images/rtimages/'${wfo}'/nwps/'${cgnum}'/; rm *.png'
               ssh waves@emcrzdm 'cd /home/www/polar/nwps/images/rtimages/'${wfo}'/nwps/'${cgnum}'/; tar -xf plots*.tar.gz'
               ssh waves@emcrzdm 'cd /home/www/polar/nwps/images/rtimages/'${wfo}'/nwps/'${cgnum}'/; cp  Hansonplot_buoy028.png Hansonplot_46028.png'
               ssh waves@emcrzdm 'cd /home/www/polar/nwps/images/rtimages/'${wfo}'/nwps/'${cgnum}'/; cp  Hansonplot_buoy219.png Hansonplot_46219.png'
               ssh waves@emcrzdm 'cd /home/www/polar/nwps/images/rtimages/'${wfo}'/nwps/'${cgnum}'/; cp  Hansonplot_buoy069.png Hansonplot_46069.png'
               ssh waves@emcrzdm 'cd /home/www/polar/nwps/images/rtimages/'${wfo}'/nwps/'${cgnum}'/; cp  Hansonplot_buoy221.png Hansonplot_46221.png'
               ssh waves@emcrzdm 'cd /home/www/polar/nwps/images/rtimages/'${wfo}'/nwps/'${cgnum}'/; cp  Hansonplot_buoy222.png Hansonplot_46222.png'
               ssh waves@emcrzdm 'cd /home/www/polar/nwps/images/rtimages/'${wfo}'/nwps/'${cgnum}'/; cp  Hansonplot_buoy253.png Hansonplot_46253.png'
               ssh waves@emcrzdm 'cd /home/www/polar/nwps/images/rtimages/'${wfo}'/nwps/'${cgnum}'/; cp  Hansonplot_buoy256.png Hansonplot_46256.png'
               ssh waves@emcrzdm 'cd /home/www/polar/nwps/images/rtimages/'${wfo}'/nwps/'${cgnum}'/; rm plots*.tar.gz'
               ssh waves@emcrzdm 'cd /home/www/polar/nwps/images/rtimages/'${wfo}'/nwps/'${cgnum}'/; tar -xf shiproute_plots*.tar.gz'
               ssh waves@emcrzdm 'cd /home/www/polar/nwps/images/rtimages/'${wfo}'/nwps/'${cgnum}'/; rm shiproute_plots*.tar.gz'
               #rm ${workdir}/${cgnum}/*.png

               # Copy new clustering-based wave tracking results
               #if [ ${cgnum} == 'CG0' ]
               #then
                  echo 'Copying cluster data...'
                  scp ${workdir}/${cgnum}/mapplots*.tar.gz waves@emcrzdm:/home/www/polar/nwps/images/rtimages/${wfo}/nwps/CG1/
                  ssh waves@emcrzdm 'cd /home/www/polar/nwps/images/rtimages/'${wfo}'/nwps/CG1/; tar -xf mapplots*.tar.gz'
                  ssh waves@emcrzdm 'cd /home/www/polar/nwps/images/rtimages/'${wfo}'/nwps/CG1/; rm mapplots*.tar.gz'
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
   wfodir=/lfs/h1/ops/prod/com/nwps/v1.4/${region}.${PDY}/${wfo}
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
               #tar -xf ${workdir}/${cgnum}/plots_${cgnum}_${PDY}${cycle}.tar.gz
               #tar -xf ${workdir}/${cgnum}/plots*.tar.gz

               # Copy the field files, first separating them to a temp directory
               #mkdir -p ${workdir}/${cgnum}/tempmove
               #mv ${workdir}/${cgnum}/swan_sigwaveheight_hr???.png ${workdir}/${cgnum}/tempmove/
               #mv ${workdir}/${cgnum}/swan_waveperiod_hr???.png ${workdir}/${cgnum}/tempmove/
               #mv ${workdir}/${cgnum}/swan_wavelength_hr???.png ${workdir}/${cgnum}/tempmove/
               #mv ${workdir}/${cgnum}/swan_swell_hr???.png ${workdir}/${cgnum}/tempmove/
               #mv ${workdir}/${cgnum}/swan_depth_hr???.png ${workdir}/${cgnum}/tempmove/
               #mv ${workdir}/${cgnum}/swan_wind_hr???.png ${workdir}/${cgnum}/tempmove/
               #mv ${workdir}/${cgnum}/swan_wlev_hr???.png ${workdir}/${cgnum}/tempmove/
               #mv ${workdir}/${cgnum}/swan_cur_hr???.png ${workdir}/${cgnum}/tempmove/

               #scp ${workdir}/${cgnum}/tempmove/swan_sigwaveheight_hr???.png waves@emcrzdm:/home/www/polar/develop/nwps/para/images/rtimages/${wfo}/nwps/${cgnum}/
               #scp ${workdir}/${cgnum}/tempmove/swan_waveperiod_hr???.png waves@emcrzdm:/home/www/polar/develop/nwps/para/images/rtimages/${wfo}/nwps/${cgnum}/
               #scp ${workdir}/${cgnum}/tempmove/swan_wavelength_hr???.png waves@emcrzdm:/home/www/polar/develop/nwps/para/images/rtimages/${wfo}/nwps/${cgnum}/
               #scp ${workdir}/${cgnum}/tempmove/swan_swell_hr???.png waves@emcrzdm:/home/www/polar/develop/nwps/para/images/rtimages/${wfo}/nwps/${cgnum}/
               #scp ${workdir}/${cgnum}/tempmove/swan_depth_hr???.png waves@emcrzdm:/home/www/polar/develop/nwps/para/images/rtimages/${wfo}/nwps/${cgnum}/
               #scp ${workdir}/${cgnum}/tempmove/swan_wind_hr???.png waves@emcrzdm:/home/www/polar/develop/nwps/para/images/rtimages/${wfo}/nwps/${cgnum}/
               #scp ${workdir}/${cgnum}/tempmove/swan_wlev_hr???.png waves@emcrzdm:/home/www/polar/develop/nwps/para/images/rtimages/${wfo}/nwps/${cgnum}/
               #scp ${workdir}/${cgnum}/tempmove/swan_cur_hr???.png waves@emcrzdm:/home/www/polar/develop/nwps/para/images/rtimages/${wfo}/nwps/${cgnum}/
               #rm ${workdir}/${cgnum}/tempmove/*.png

               # Copy the spectra files (all the *.png files remaining in the base directory of CG1)
               #if [ ${cgnum} == 'CG1' ]
               #then
               #   scp ${workdir}/${cgnum}/swan_*_hr???.png waves@emcrzdm:/home/www/polar/develop/nwps/para/images/rtimages/${wfo}/nwps/spectra/
               #   #rm ${workdir}/${cgnum}/*.png
               #fi

               scp ${workdir}/${cgnum}/plots*.tar.gz waves@emcrzdm:/home/www/polar/nwps/images/rtimages/${wfo}/nwps/${cgnum}/
               scp ${workdir}/${cgnum}/shiproute_plots*.tar.gz waves@emcrzdm:/home/www/polar/nwps/images/rtimages/${wfo}/nwps/${cgnum}/
               # Clean out old figures first
               #ssh waves@emcrzdm 'cd /home/www/polar/nwps/images/rtimages/'${wfo}'/nwps/'${cgnum}'/; rm *.png'
               ssh waves@emcrzdm 'cd /home/www/polar/nwps/images/rtimages/'${wfo}'/nwps/'${cgnum}'/; tar -xf plots*.tar.gz'
               ssh waves@emcrzdm 'cd /home/www/polar/nwps/images/rtimages/'${wfo}'/nwps/'${cgnum}'/; cp  Hansonplot_buoy028.png Hansonplot_46028.png'
               ssh waves@emcrzdm 'cd /home/www/polar/nwps/images/rtimages/'${wfo}'/nwps/'${cgnum}'/; cp  Hansonplot_buoy219.png Hansonplot_46219.png'
               ssh waves@emcrzdm 'cd /home/www/polar/nwps/images/rtimages/'${wfo}'/nwps/'${cgnum}'/; cp  Hansonplot_buoy069.png Hansonplot_46069.png'
               ssh waves@emcrzdm 'cd /home/www/polar/nwps/images/rtimages/'${wfo}'/nwps/'${cgnum}'/; cp  Hansonplot_buoy221.png Hansonplot_46221.png'
               ssh waves@emcrzdm 'cd /home/www/polar/nwps/images/rtimages/'${wfo}'/nwps/'${cgnum}'/; cp  Hansonplot_buoy222.png Hansonplot_46222.png'
               ssh waves@emcrzdm 'cd /home/www/polar/nwps/images/rtimages/'${wfo}'/nwps/'${cgnum}'/; cp  Hansonplot_buoy253.png Hansonplot_46253.png'
               ssh waves@emcrzdm 'cd /home/www/polar/nwps/images/rtimages/'${wfo}'/nwps/'${cgnum}'/; cp  Hansonplot_buoy256.png Hansonplot_46256.png'
               ssh waves@emcrzdm 'cd /home/www/polar/nwps/images/rtimages/'${wfo}'/nwps/'${cgnum}'/; rm plots*.tar.gz'
               ssh waves@emcrzdm 'cd /home/www/polar/nwps/images/rtimages/'${wfo}'/nwps/'${cgnum}'/; tar -xf shiproute_plots*.tar.gz'
               ssh waves@emcrzdm 'cd /home/www/polar/nwps/images/rtimages/'${wfo}'/nwps/'${cgnum}'/; rm shiproute_plots*.tar.gz'
               #rm ${workdir}/${cgnum}/*.png

               # Copy new clustering-based wave tracking results
               #if [ ${cgnum} == 'CG0' ]
               #then
                  echo 'Copying cluster data...'
                  scp ${workdir}/${cgnum}/mapplots*.tar.gz waves@emcrzdm:/home/www/polar/nwps/images/rtimages/${wfo}/nwps/CG1/
                  ssh waves@emcrzdm 'cd /home/www/polar/nwps/images/rtimages/'${wfo}'/nwps/CG1/; tar -xf mapplots*.tar.gz'
                  ssh waves@emcrzdm 'cd /home/www/polar/nwps/images/rtimages/'${wfo}'/nwps/CG1/; rm mapplots*.tar.gz'
               #fi

               #datafound='true'
            fi
         done
      fi
   #done
done



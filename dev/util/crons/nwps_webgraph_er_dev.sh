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
         workdir=/lfs/h2/emc/ptmp/andre.vanderwesthuysen/com/nwps/v1.5.0/${region}.${PDY}/${wfo}/${cycle}
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

               scp ${workdir}/${cgnum}/plots*.tar.gz waves@emcrzdm:/home/www/polar/nwps/para/images/rtimages/${wfo}/nwps/${cgnum}/
               scp ${workdir}/${cgnum}/shiproute_plots*.tar.gz waves@emcrzdm:/home/www/polar/nwps/para/images/rtimages/${wfo}/nwps/${cgnum}/
               # Clean out old figures first
               #ssh waves@emcrzdm 'cd /home/www/polar/nwps/para/images/rtimages/'${wfo}'/nwps/'${cgnum}'/; rm *.png'
               ssh waves@emcrzdm 'cd /home/www/polar/nwps/para/images/rtimages/'${wfo}'/nwps/'${cgnum}'/; tar -xf plots*.tar.gz'
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

               datafound='true'
            fi
         done
      fi
   done
done


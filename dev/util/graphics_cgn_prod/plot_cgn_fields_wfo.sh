#!/bin/bash 
set -x

#region="sr"
#wfos="bro crp hgx lch lix mob tae tbw key mfl mlb jax sju"
region=${1}
wfos=${2}
cgnums="CG2 CG3 CG4 CG5"

PDY=$(date +%Y%m%d)
logfile=${workdir}/plot_cgn_${PDY}.log
if [ ! -f ${logfile} ]
then
   touch ${logfile}
fi

for wfo in $wfos
do
   datafound='false'
   wfodir=${comroot}/${region}.${PDY}/${wfo}
   cd ${wfodir}
   cycles=$(ls -td ?? | head -1)
   for cycle in $cycles
   do
      if [ ${datafound} == 'false' ]
      then
         outdir=${wfodir}/${cycle}
         echo ${outdir}
         for cgnum in $cgnums
         do
            echo 'Searching' ${wfo} ${cgnum}
            #dset=${outdir}/${cgnum}/${wfo}_nwps_${cgnum}_${PDY}_${cycle}00.grib2
            # Check if there is new data than has not yet been plotted
            if [ -f ${outdir}/${cgnum}/${wfo}_nwps_${cgnum}_*.grib2 ]
            then 
               dset=$(ls ${outdir}/${cgnum}/${wfo}_nwps_${cgnum}_*.grib2)
               if ! grep -q "${dset}" ${logfile}
               then
                  # Copy the data
                  echo 'Copying from' ${outdir}
                  cp -p ${dset} ${workdir}/${wfo}/${cgnum}/swan.grib2
                  cp -p ${workdir}/*.py ${workdir}/${wfo}/${cgnum}/
                  cp -p ${workdir}/*.png ${workdir}/${wfo}/${cgnum}/
                  datafound='true'

                  # Create the plots
                  export SITEID=${wfo}
                  export CGNUMPLOT=$(echo ${cgnum} | cut -c 3)
                  echo 'Plotting' ${SITEID} ${CGNUMPLOT}
                  cd ${workdir}/${wfo}/${cgnum}/
                  python htsgw.py 1 49
                  python period.py 1 49
                  python wind.py 1 49
                  python swell.py 1 49
                  python wlev.py 1 49
                  python cur.py 1 49
                  tar -czvf plots_${wfo}_${cgnum}.tar.gz swan*.png

                  # Push the completed plots to RZDM
                  scp plots_${wfo}_${cgnum}.tar.gz waves@emcrzdm:/home/www/polar/nwps/images/rtimages/${wfo}/nwps/${cgnum}/
                  ssh waves@emcrzdm 'cd /home/www/polar/nwps/images/rtimages/'${wfo}'/nwps/'${cgnum}'/; tar -xf plots*.tar.gz'
                  ssh waves@emcrzdm 'cd /home/www/polar/nwps/images/rtimages/'${wfo}'/nwps/'${cgnum}'/; rm plots*.tar.gz'

                  echo 'Completed' ${wfo} ${cgnum}
                  echo "${dset} at $(date -u "+%Y%m%d%H%M")" >> ${logfile}
               fi
            fi
         done
      fi
   done
done

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

#regions="sr er wr pr ar"
regions="sr er"

#PDY=$(date +%Y%m%d)
#PDYm1=$(date +%Y%m%d -d "1 day ago")
#PDYm5=$(date -d "5 days ago" +%Y%m%d)

#PDY=20190604

input_start=2019-4-1
input_end=2019-5-1

startdate=$(date -I -d "$input_start") || exit -1
enddate=$(date -I -d "$input_end")     || exit -1

d="$startdate"
while [ "$d" != $enddate ]; do 
   PDY=$(date -d "$d" +%Y%m%d)
   echo $PDY

   for region in $regions
   do
      #Clean up old directories
      #echo 'Scrubbing /home/ftp/polar/nwps/dev/'${region}'.'${PDYm5}
      #ssh andre.westhuysen@emcrzdm 'cd /home/ftp/polar/nwps/dev/; rm -r '${region}'.'${PDYm5}

      #Check for today's runs
      workdir=/gpfs/hps3/ptmp/Andre.VanderWesthuysen/data/retro/com/nwps/para/${region}.${PDY}
      echo ${workdir}
      if [ -d ${workdir} ]
      then
         rsync -rav --include=*/ --include='Warn*' --include='*rip*' --include='5m_contour*' --exclude='*' --exclude='PE[0-9][0-9][0-9][0-9]/' ${workdir} andre.westhuysen@vm-lnx-emcrzdm02:/home/ftp/polar/nwps/retro/
      fi
   done

   d=$(date -I -d "$d + 1 day")
done

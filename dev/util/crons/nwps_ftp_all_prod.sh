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
   #Clean up old directories
   echo 'Scrubbing /home/ftp/polar/nwps/'${region}'.'${PDYm5}
   ssh waves@emcrzdm 'cd /home/ftp/polar/nwps/; rm -r '${region}'.'${PDYm5}

   #Check for yesterday's runs completed (shortly) after midnight
   workdir=/lfs/h1/ops/prod/com/nwps/v1.4/${region}.${PDYm1}
   echo ${workdir}
   if [ -d ${workdir} ]
   then
      ssh waves@emcrzdm 'mkdir -p /home/ftp/polar/nwps/'
      rsync -rav --include=*/ --include='Warn*' --include='*.grib2' --include='*.bull' --include='SPC2D*' --include='*runup*' --include='*rip*' --include='*contour*' --exclude='*' --exclude='PE*' ${workdir} waves@emcrzdm:/home/ftp/polar/nwps/
   fi

   #Check for today's runs
   workdir=/lfs/h1/ops/prod/com/nwps/v1.4/${region}.${PDY}
   echo ${workdir}
   if [ -d ${workdir} ]
   then
      ssh waves@emcrzdm 'mkdir -p /home/ftp/polar/nwps/' 
      rsync -rav --include=*/ --include='Warn*' --include='*.grib2' --include='*.bull' --include='SPC2D*' --include='*runup*' --include='*rip*' --include='*contour*' --exclude='*' --exclude='PE*' ${workdir} waves@emcrzdm:/home/ftp/polar/nwps/
   fi
done

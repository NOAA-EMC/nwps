#!/bin/bash  
# ----------------------------------------------------------- 
# UNIX Shell Script File
# Tested Operating System(s): RHEL 5,6
# Tested Run Level(s): 3, 5
# Shell Used: BASH shell
# Original Author(s): Saeideh Banihashemi
# File Creation Date: 10/02/2015
# Date Last Modified:
#
# Version control:
#
# Support Team:
#
# Contributors:
#
# ----------------------------------------------------------- 
# ------------- Program Description and Details ------------- 
# ----------------------------------------------------------- 
#
# rzdm transfer job
#
# ----------------------------------------------------------- 

echo 'Running rzdm_transfer_validation_ts_6day.sh...'

cd $workdir
pwd

#----- Set start and end dates of real-time analysis -----
export STARTDATE=$(date +%Y%m%d)

scp ${workdir}/nwps_??_scatter.png waves@emcrzdm:/home/www/polar/nwps/images/rtimages/val_monthly/
scp ${workdir}/nwps_????_scatter.png waves@emcrzdm:/home/www/polar/nwps/images/rtimages/val_monthly/
scp ${workdir}/nwps_stats_??_ts.png waves@emcrzdm:/home/www/polar/nwps/images/rtimages/val_monthly/
scp ${workdir}/nwps_stats_????_ts.png waves@emcrzdm:/home/www/polar/nwps/images/rtimages/val_monthly/
scp ${workdir}/nwps_???_?????_scatter.png waves@emcrzdm:/home/www/polar/nwps/images/rtimages/validation/
scp ${workdir}/nwps_???_????_scatter.png waves@emcrzdm:/home/www/polar/nwps/images/rtimages/validation/

#rm ${workdir}/nwps_??_scatter.png
#rm ${workdir}/nwps_stats_??_ts.png

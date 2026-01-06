#!/bin/bash 
# ----------------------------------------------------------- 
# UNIX Shell Script File
# Tested Operating System(s): RHEL 5,6
# Tested Run Level(s): 3, 5
# Shell Used: BASH shell
# Original Author(s): Andre van der Westhuysen
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
# rsync script for data backup
#
# ----------------------------------------------------------- 

export daily_dir=${workdir}/daily_plots/$(date +%Y%m%d)
cd $daily_dir
pwd

scp ${daily_dir}/nwps_*_ripprob_stat?.png waves@emcrzdm:/home/www/polar/nwps/images/rtimages/validation/
scp ${daily_dir}/nwps_*_ripprob_stat??.png waves@emcrzdm:/home/www/polar/nwps/images/rtimages/validation/
scp ${daily_dir}/nwps_*_ripprob_stat???.png waves@emcrzdm:/home/www/polar/nwps/images/rtimages/validation/
scp ${daily_dir}/*1.rip waves@emcrzdm:/home/www/polar/nwps/images/rtimages/validation/


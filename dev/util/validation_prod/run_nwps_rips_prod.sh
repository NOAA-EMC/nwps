#!/bin/bash --login
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

echo 'Running run_nwps_validation.sh...'

workdir='/lfs/h2/emc/couple/noscrub/andre.vanderwesthuysen/nwps_para/validation_prod'

cd $workdir
pwd

#----- Set start and end dates of real-time analysis -----
export STARTDATE=$(date +%Y%m%d)
export STARTDATEm1=$(date -d "-1 days" +%Y%m%d)
export STARTDATEm2=$(date -d "-2 days" +%Y%m%d)
#export STARTDATE=$(date -d "-1 days" +%Y%m%d)
export ENDDATE=$(date -d "+7 days" +%Y%m%d)

export COMOUT='/lfs/h1/ops/prod/com/nwps/v1.4/'

echo ''
echo 'Analysing real-time data for:'
echo 'STARTDATE = '${STARTDATE}
echo 'ENDDATE = '${ENDDATE}
echo ''
echo 'COMOUT='${COMOUT}
echo 'COMOUTm1='${COMOUTm1}
echo 'COMOUTm2='${COMOUTm2}
echo 'workdir='${workdir}
echo ''

# Run Python validation scripts
echo "Running nwps_plot_rips_6day.py for:"
echo ${1}
echo ${2}
echo ${3}
python ${workdir}/nwps_plot_rips_6day.py ${1} ${2} ${3}

echo "Copying: nwps_"${2}"_ripprob_stat???.png..."
echo "Copying: "${2^^}"1.rip..."
scp ${workdir}/nwps_${2}_ripprob_stat?.png waves@emcrzdm:/home/www/polar/nwps/images/rtimages/validation/
scp ${workdir}/nwps_${2}_ripprob_stat??.png waves@emcrzdm:/home/www/polar/nwps/images/rtimages/validation/
scp ${workdir}/nwps_${2}_ripprob_stat???.png waves@emcrzdm:/home/www/polar/nwps/images/rtimages/validation/
scp ${workdir}/${2^^}1.rip waves@emcrzdm:/home/www/polar/nwps/images/rtimages/validation/

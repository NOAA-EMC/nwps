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

echo 'Running run_nwps_validation_dev.sh...'

export COMOUT='/lfs/h2/emc/couple/noscrub/andre.vanderwesthuysen/nwps_para/com/nwps/v1.5.0/'
export COMOUTm1='/lfs/h2/emc/couple/noscrub/andre.vanderwesthuysen/nwps_para/com/nwps/v1.5.0/'

cd $workdir
pwd

# Cleanup
rm ${workdir}/nwps_??_scatter.png
rm ${workdir}/nwps_stats_??_ts.png
rm ${workdir}/nwps_???_?????_scatter.png

#----- Set start and end dates of 30-day analysis -----
export STARTDATE=$(date -d "-36 days" +%Y%m%d)
#export STARTDATE='20170101'
export ENDDATE=$(date -d "-7 days" +%Y%m%d)
#export ENDDATE='20170620'
echo ''
echo 'Analysing 30-day scatter data for:'
echo 'STARTDATE = '${STARTDATE}
echo 'ENDDATE = '${ENDDATE}
echo ''

# Run Python validation scripts
python ${workdir}/nwps_stats_sr_rt30day_6day.py
python ${workdir}/nwps_stats_er_rt30day_6day.py
#
#cat nwps_val_stats_sr_${ENDDATE}.dat >> nwps_val_stats_sr.dat
#cat nwps_val_stats_er_${ENDDATE}.dat >> nwps_val_stats_er.dat
#
#python ${workdir}/nwps_val_stats_sr_monthly_ts.py
#python ${workdir}/nwps_val_stats_er_monthly_ts.py

python ${workdir}/nwps_stats_buoy_rt30day_6day.py '42020' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '42019' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '42035' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '42040' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '42012' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '42039' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '42036' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '42023' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '41114' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '42023' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '41009' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '41113' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '41112' 'CG3'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '41008' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '41012' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '41053' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '41115' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '42085' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '41056' 'CG1'

python ${workdir}/nwps_stats_buoy_rt30day_6day.py '41008' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '41029' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '41033' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '41004' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '41065' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '41076' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '41013' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '44095' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '41159' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '41025' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '44056' 'CG2'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '44100' 'CG2'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '44014' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '44093' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '44096' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '44009' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '44091' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '44065' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '44094' 'CG3'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '44025' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '44040' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '44039' 'CG4'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '44060' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '44069' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '44017' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '44020' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '44013' 'CG2'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '44018' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '44029' 'CG2'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '44090' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '44098' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '44033' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '44007' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '44032' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '44034' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '44027' 'CG1'

#python ${workdir}/nwps_stats_wfo_rt30day.py 'bro'
#python ${workdir}/nwps_stats_wfo_rt30day.py 'crp'
#python ${workdir}/nwps_stats_wfo_rt30day.py 'hgx'
#python ${workdir}/nwps_stats_wfo_rt30day.py 'lch'
#python ${workdir}/nwps_stats_wfo_rt30day.py 'lix'
#python ${workdir}/nwps_stats_wfo_rt30day.py 'mob'
#python ${workdir}/nwps_stats_wfo_rt30day.py 'tae'
#python ${workdir}/nwps_stats_wfo_rt30day.py 'tbw'
#python ${workdir}/nwps_stats_wfo_rt30day.py 'key'
#python ${workdir}/nwps_stats_wfo_rt30day.py 'mfl'
#python ${workdir}/nwps_stats_wfo_rt30day.py 'mlb'
#python ${workdir}/nwps_stats_wfo_rt30day.py 'jax'
#python ${workdir}/nwps_stats_wfo_rt30day.py 'sju'
#python ${workdir}/nwps_stats_wfo_rt30day.py 'chs'
#python ${workdir}/nwps_stats_wfo_rt30day.py 'ilm'
#python ${workdir}/nwps_stats_wfo_rt30day.py 'mhx'
#python ${workdir}/nwps_stats_wfo_rt30day.py 'akq'
#python ${workdir}/nwps_stats_wfo_rt30day.py 'lwx'
#python ${workdir}/nwps_stats_wfo_rt30day.py 'phi'
#python ${workdir}/nwps_stats_wfo_rt30day.py 'okx'
#python ${workdir}/nwps_stats_wfo_rt30day.py 'box'
#python ${workdir}/nwps_stats_wfo_rt30day.py 'gyx'
#python ${workdir}/nwps_stats_wfo_rt30day.py 'car'

# Copy the validation results to polar:
cp ${workdir}/nwps_${ENDDATE}_sr_scatter.png ${workdir}/nwps_sr_scatter.png
cp ${workdir}/nwps_${ENDDATE}_er_scatter.png ${workdir}/nwps_er_scatter.png

cp ${workdir}/nwps_${ENDDATE}_bro_42020_scatter.png ${workdir}/nwps_bro_42020_scatter.png
cp ${workdir}/nwps_${ENDDATE}_hgx_42019_scatter.png ${workdir}/nwps_hgx_42019_scatter.png
cp ${workdir}/nwps_${ENDDATE}_lch_42035_scatter.png ${workdir}/nwps_lch_42035_scatter.png
cp ${workdir}/nwps_${ENDDATE}_lix_42040_scatter.png ${workdir}/nwps_lix_42040_scatter.png
cp ${workdir}/nwps_${ENDDATE}_mob_42012_scatter.png ${workdir}/nwps_mob_42012_scatter.png
cp ${workdir}/nwps_${ENDDATE}_tae_42039_scatter.png ${workdir}/nwps_tae_42039_scatter.png
cp ${workdir}/nwps_${ENDDATE}_tae_42036_scatter.png ${workdir}/nwps_tae_42036_scatter.png
cp ${workdir}/nwps_${ENDDATE}_mfl_41114_scatter.png ${workdir}/nwps_mfl_41114_scatter.png
cp ${workdir}/nwps_${ENDDATE}_mfl_42023_scatter.png ${workdir}/nwps_mfl_42023_scatter.png
cp ${workdir}/nwps_${ENDDATE}_mlb_41113_scatter.png ${workdir}/nwps_mlb_41113_scatter.png
cp ${workdir}/nwps_${ENDDATE}_mlb_41009_scatter.png ${workdir}/nwps_mlb_41009_scatter.png
cp ${workdir}/nwps_${ENDDATE}_jax_41112_scatter.png ${workdir}/nwps_jax_41112_scatter.png
cp ${workdir}/nwps_${ENDDATE}_jax_41008_scatter.png ${workdir}/nwps_jax_41008_scatter.png
#cp ${workdir}/nwps_${ENDDATE}_jax_41012_scatter.png ${workdir}/nwps_jax_41012_scatter.png
cp ${workdir}/nwps_${ENDDATE}_sju_41115_scatter.png ${workdir}/nwps_sju_41115_scatter.png
cp ${workdir}/nwps_${ENDDATE}_sju_42085_scatter.png ${workdir}/nwps_sju_42085_scatter.png
cp ${workdir}/nwps_${ENDDATE}_sju_41056_scatter.png ${workdir}/nwps_sju_41056_scatter.png
cp ${workdir}/nwps_${ENDDATE}_sju_41053_scatter.png ${workdir}/nwps_sju_41053_scatter.png

cp ${workdir}/nwps_${ENDDATE}_chs_41008_scatter.png ${workdir}/nwps_chs_41008_scatter.png
cp ${workdir}/nwps_${ENDDATE}_chs_41029_scatter.png ${workdir}/nwps_chs_41029_scatter.png
cp ${workdir}/nwps_${ENDDATE}_chs_41033_scatter.png ${workdir}/nwps_chs_41033_scatter.png
cp ${workdir}/nwps_${ENDDATE}_chs_41004_scatter.png ${workdir}/nwps_chs_41004_scatter.png
cp ${workdir}/nwps_${ENDDATE}_chs_41065_scatter.png ${workdir}/nwps_chs_41065_scatter.png
cp ${workdir}/nwps_${ENDDATE}_chs_41076_scatter.png ${workdir}/nwps_chs_41076_scatter.png
cp ${workdir}/nwps_${ENDDATE}_ilm_41013_scatter.png ${workdir}/nwps_ilm_41013_scatter.png
cp ${workdir}/nwps_${ENDDATE}_mhx_44095_scatter.png ${workdir}/nwps_mhx_44095_scatter.png
cp ${workdir}/nwps_${ENDDATE}_mhx_41159_scatter.png ${workdir}/nwps_mhx_41159_scatter.png
cp ${workdir}/nwps_${ENDDATE}_mhx_41025_scatter.png ${workdir}/nwps_mhx_41025_scatter.png
cp ${workdir}/nwps_${ENDDATE}_mhx_44056_scatter.png ${workdir}/nwps_mhx_44056_scatter.png
cp ${workdir}/nwps_${ENDDATE}_mhx_44100_scatter.png ${workdir}/nwps_mhx_44100_scatter.png
cp ${workdir}/nwps_${ENDDATE}_akq_44014_scatter.png ${workdir}/nwps_akq_44014_scatter.png
cp ${workdir}/nwps_${ENDDATE}_akq_44093_scatter.png ${workdir}/nwps_akq_44093_scatter.png
cp ${workdir}/nwps_${ENDDATE}_akq_44096_scatter.png ${workdir}/nwps_akq_44096_scatter.png
cp ${workdir}/nwps_${ENDDATE}_phi_44009_scatter.png ${workdir}/nwps_phi_44009_scatter.png
cp ${workdir}/nwps_${ENDDATE}_phi_44091_scatter.png ${workdir}/nwps_phi_44091_scatter.png
cp ${workdir}/nwps_${ENDDATE}_okx_44065_scatter.png ${workdir}/nwps_okx_44065_scatter.png
cp ${workdir}/nwps_${ENDDATE}_okx_44094_scatter.png ${workdir}/nwps_okx_44094_scatter.png
cp ${workdir}/nwps_${ENDDATE}_okx_44025_scatter.png ${workdir}/nwps_okx_44025_scatter.png
cp ${workdir}/nwps_${ENDDATE}_okx_44040_scatter.png ${workdir}/nwps_okx_44040_scatter.png
cp ${workdir}/nwps_${ENDDATE}_okx_44039_scatter.png ${workdir}/nwps_okx_44039_scatter.png
cp ${workdir}/nwps_${ENDDATE}_okx_44060_scatter.png ${workdir}/nwps_okx_44060_scatter.png
cp ${workdir}/nwps_${ENDDATE}_okx_44069_scatter.png ${workdir}/nwps_okx_44069_scatter.png
cp ${workdir}/nwps_${ENDDATE}_box_44017_scatter.png ${workdir}/nwps_box_44017_scatter.png
cp ${workdir}/nwps_${ENDDATE}_box_44020_scatter.png ${workdir}/nwps_box_44020_scatter.png
cp ${workdir}/nwps_${ENDDATE}_box_44013_scatter.png ${workdir}/nwps_box_44013_scatter.png
cp ${workdir}/nwps_${ENDDATE}_box_44018_scatter.png ${workdir}/nwps_box_44018_scatter.png
cp ${workdir}/nwps_${ENDDATE}_box_44029_scatter.png ${workdir}/nwps_box_44029_scatter.png
cp ${workdir}/nwps_${ENDDATE}_box_44090_scatter.png ${workdir}/nwps_box_44090_scatter.png
cp ${workdir}/nwps_${ENDDATE}_box_44098_scatter.png ${workdir}/nwps_box_44098_scatter.png
cp ${workdir}/nwps_${ENDDATE}_gyx_44033_scatter.png ${workdir}/nwps_gyx_44033_scatter.png
cp ${workdir}/nwps_${ENDDATE}_gyx_44007_scatter.png ${workdir}/nwps_gyx_44007_scatter.png
cp ${workdir}/nwps_${ENDDATE}_gyx_44032_scatter.png ${workdir}/nwps_gyx_44032_scatter.png
cp ${workdir}/nwps_${ENDDATE}_car_44034_scatter.png ${workdir}/nwps_car_44034_scatter.png
cp ${workdir}/nwps_${ENDDATE}_car_44027_scatter.png ${workdir}/nwps_car_44027_scatter.png

scp ${workdir}/nwps_??_scatter.png waves@emcrzdm:/home/www/polar/nwps/images/rtimages/val_monthly/
scp ${workdir}/nwps_????_scatter.png waves@emcrzdm:/home/www/polar/nwps/images/rtimages/val_monthly/
scp ${workdir}/nwps_stats_??_ts.png waves@emcrzdm:/home/www/polar/nwps/images/rtimages/val_monthly/
scp ${workdir}/nwps_stats_????_ts.png waves@emcrzdm:/home/www/polar/nwps/images/rtimages/val_monthly/
scp ${workdir}/nwps_???_?????_scatter.png waves@emcrzdm:/home/www/polar/nwps/images/rtimages/validation/
scp ${workdir}/nwps_???_????_scatter.png waves@emcrzdm:/home/www/polar/nwps/images/rtimages/validation/


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

echo 'Running run_nwps_validation_devwr.sh...'

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
python ${workdir}/nwps_stats_wr_rt30day_6day.py
python ${workdir}/nwps_stats_prar_rt30day_6day.py
#
#cat nwps_val_stats_wr_????????.dat > nwps_val_stats_wr.dat
#cat nwps_val_stats_prar_????????.dat > nwps_val_stats_prar.dat
#
#python ${workdir}/nwps_val_stats_wr_monthly_ts.py
#python ${workdir}/nwps_val_stats_prar_monthly_ts.py

python ${workdir}/nwps_stats_buoy_rt30day_6day.py '46206' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '46041' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '46087' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '46088' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '46211' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '46243' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '46248' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '46029' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '46050' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '46015' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '46027' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '46229' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '46213' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '46212' 'CG1'
#python ${workdir}/nwps_stats_buoy_rt30day_6day.py '46027' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '46014' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '46042' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '46028' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '46239' 'CG3'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '46236' 'CG3'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '46240' 'CG3'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '46214' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '46013' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '46012' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '46026' 'CG2'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '46237' 'CG2'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '46028' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '46219' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '46069' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '46221' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '46222' 'CG2'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '46253' 'CG2'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '46256' 'CG2'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '46011' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '46053' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '46054' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '46025' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '46086' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '46224' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '46232' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '46231' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '46258' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '46225' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '46242' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '46254' 'CG2'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py 'LJPC1' 'CG2'

python ${workdir}/nwps_stats_buoy_rt30day_6day.py '51208' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '51207' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '51206' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '51205' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '51204' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '51203' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '51202' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '51201' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '51003' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py 'Kona' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py 'Isaac' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '52200' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '52211' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py 'APRP7' 'CG1'

python ${workdir}/nwps_stats_buoy_rt30day_6day.py '46001' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '46080' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '46082' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '46108' 'CG2'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '46061' 'CG3'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '46060' 'CG3'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '46076' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '46066' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '46085' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '46083' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '48114' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '48012' 'CG1'
python ${workdir}/nwps_stats_buoy_rt30day_6day.py '48212' 'CG1'

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
cp ${workdir}/nwps_${ENDDATE}_wr_scatter.png ${workdir}/nwps_wr_scatter.png
cp ${workdir}/nwps_${ENDDATE}_prar_scatter.png ${workdir}/nwps_prar_scatter.png

cp ${workdir}/nwps_${ENDDATE}_sew_46206_scatter.png ${workdir}/nwps_sew_46206_scatter.png
cp ${workdir}/nwps_${ENDDATE}_sew_46041_scatter.png ${workdir}/nwps_sew_46041_scatter.png
cp ${workdir}/nwps_${ENDDATE}_sew_46087_scatter.png ${workdir}/nwps_sew_46087_scatter.png
cp ${workdir}/nwps_${ENDDATE}_sew_46088_scatter.png ${workdir}/nwps_sew_46088_scatter.png
cp ${workdir}/nwps_${ENDDATE}_pqr_46211_scatter.png ${workdir}/nwps_pqr_46211_scatter.png
cp ${workdir}/nwps_${ENDDATE}_pqr_46243_scatter.png ${workdir}/nwps_pqr_46243_scatter.png
cp ${workdir}/nwps_${ENDDATE}_pqr_46248_scatter.png ${workdir}/nwps_pqr_46248_scatter.png
cp ${workdir}/nwps_${ENDDATE}_pqr_46029_scatter.png ${workdir}/nwps_pqr_46029_scatter.png
cp ${workdir}/nwps_${ENDDATE}_pqr_46050_scatter.png ${workdir}/nwps_pqr_46050_scatter.png
cp ${workdir}/nwps_${ENDDATE}_mfr_46015_scatter.png ${workdir}/nwps_mfr_46015_scatter.png
cp ${workdir}/nwps_${ENDDATE}_mfr_46027_scatter.png ${workdir}/nwps_mfr_46027_scatter.png
cp ${workdir}/nwps_${ENDDATE}_mfr_46229_scatter.png ${workdir}/nwps_mfr_46229_scatter.png
cp ${workdir}/nwps_${ENDDATE}_eka_46213_scatter.png ${workdir}/nwps_eka_46213_scatter.png
cp ${workdir}/nwps_${ENDDATE}_eka_46212_scatter.png ${workdir}/nwps_eka_46212_scatter.png
#cp ${workdir}/nwps_${ENDDATE}_eka_46027_scatter.png ${workdir}/nwps_eka_46027_scatter.png
cp ${workdir}/nwps_${ENDDATE}_eka_46014_scatter.png ${workdir}/nwps_eka_46014_scatter.png
cp ${workdir}/nwps_${ENDDATE}_mtr_46042_scatter.png ${workdir}/nwps_mtr_46042_scatter.png
cp ${workdir}/nwps_${ENDDATE}_mtr_46028_scatter.png ${workdir}/nwps_mtr_46028_scatter.png
cp ${workdir}/nwps_${ENDDATE}_mtr_46239_scatter.png ${workdir}/nwps_mtr_46239_scatter.png
cp ${workdir}/nwps_${ENDDATE}_mtr_46236_scatter.png ${workdir}/nwps_mtr_46236_scatter.png
cp ${workdir}/nwps_${ENDDATE}_mtr_46240_scatter.png ${workdir}/nwps_mtr_46240_scatter.png
cp ${workdir}/nwps_${ENDDATE}_mtr_46214_scatter.png ${workdir}/nwps_mtr_46214_scatter.png
cp ${workdir}/nwps_${ENDDATE}_mtr_46013_scatter.png ${workdir}/nwps_mtr_46013_scatter.png
cp ${workdir}/nwps_${ENDDATE}_mtr_46012_scatter.png ${workdir}/nwps_mtr_46012_scatter.png
cp ${workdir}/nwps_${ENDDATE}_mtr_46026_scatter.png ${workdir}/nwps_mtr_46026_scatter.png
cp ${workdir}/nwps_${ENDDATE}_mtr_46237_scatter.png ${workdir}/nwps_mtr_46237_scatter.png
cp ${workdir}/nwps_${ENDDATE}_lox_46028_scatter.png ${workdir}/nwps_lox_46028_scatter.png
cp ${workdir}/nwps_${ENDDATE}_lox_46219_scatter.png ${workdir}/nwps_lox_46219_scatter.png
cp ${workdir}/nwps_${ENDDATE}_lox_46069_scatter.png ${workdir}/nwps_lox_46069_scatter.png
cp ${workdir}/nwps_${ENDDATE}_lox_46221_scatter.png ${workdir}/nwps_lox_46221_scatter.png
cp ${workdir}/nwps_${ENDDATE}_lox_46222_scatter.png ${workdir}/nwps_lox_46222_scatter.png
cp ${workdir}/nwps_${ENDDATE}_lox_46253_scatter.png ${workdir}/nwps_lox_46253_scatter.png
cp ${workdir}/nwps_${ENDDATE}_lox_46256_scatter.png ${workdir}/nwps_lox_46256_scatter.png
cp ${workdir}/nwps_${ENDDATE}_lox_46011_scatter.png ${workdir}/nwps_lox_46011_scatter.png
cp ${workdir}/nwps_${ENDDATE}_lox_46053_scatter.png ${workdir}/nwps_lox_46053_scatter.png
cp ${workdir}/nwps_${ENDDATE}_lox_46054_scatter.png ${workdir}/nwps_lox_46054_scatter.png
cp ${workdir}/nwps_${ENDDATE}_lox_46025_scatter.png ${workdir}/nwps_lox_46025_scatter.png
cp ${workdir}/nwps_${ENDDATE}_sgx_46086_scatter.png ${workdir}/nwps_sgx_46086_scatter.png
cp ${workdir}/nwps_${ENDDATE}_sgx_46224_scatter.png ${workdir}/nwps_sgx_46224_scatter.png
cp ${workdir}/nwps_${ENDDATE}_sgx_46232_scatter.png ${workdir}/nwps_sgx_46232_scatter.png
cp ${workdir}/nwps_${ENDDATE}_sgx_46231_scatter.png ${workdir}/nwps_sgx_46231_scatter.png
cp ${workdir}/nwps_${ENDDATE}_sgx_46258_scatter.png ${workdir}/nwps_sgx_46258_scatter.png
cp ${workdir}/nwps_${ENDDATE}_sgx_46225_scatter.png ${workdir}/nwps_sgx_46225_scatter.png
cp ${workdir}/nwps_${ENDDATE}_sgx_46242_scatter.png ${workdir}/nwps_sgx_46242_scatter.png
cp ${workdir}/nwps_${ENDDATE}_sgx_46254_scatter.png ${workdir}/nwps_sgx_46254_scatter.png
cp ${workdir}/nwps_${ENDDATE}_sgx_LJPC1_scatter.png ${workdir}/nwps_sgx_LJPC1_scatter.png

cp ${workdir}/nwps_${ENDDATE}_hfo_51208_scatter.png ${workdir}/nwps_hfo_51208_scatter.png
cp ${workdir}/nwps_${ENDDATE}_hfo_51207_scatter.png ${workdir}/nwps_hfo_51207_scatter.png
cp ${workdir}/nwps_${ENDDATE}_hfo_51206_scatter.png ${workdir}/nwps_hfo_51206_scatter.png
cp ${workdir}/nwps_${ENDDATE}_hfo_51205_scatter.png ${workdir}/nwps_hfo_51205_scatter.png
cp ${workdir}/nwps_${ENDDATE}_hfo_51204_scatter.png ${workdir}/nwps_hfo_51204_scatter.png
cp ${workdir}/nwps_${ENDDATE}_hfo_51203_scatter.png ${workdir}/nwps_hfo_51203_scatter.png
cp ${workdir}/nwps_${ENDDATE}_hfo_51202_scatter.png ${workdir}/nwps_hfo_51202_scatter.png
cp ${workdir}/nwps_${ENDDATE}_hfo_51201_scatter.png ${workdir}/nwps_hfo_51201_scatter.png
cp ${workdir}/nwps_${ENDDATE}_hfo_51003_scatter.png ${workdir}/nwps_hfo_51003_scatter.png
cp ${workdir}/nwps_${ENDDATE}_hfo_Kona_scatter.png ${workdir}/nwps_hfo_Kona_scatter.png
cp ${workdir}/nwps_${ENDDATE}_hfo_Isaac_scatter.png ${workdir}/nwps_hfo_Isaac_scatter.png
cp ${workdir}/nwps_${ENDDATE}_gum_52200_scatter.png ${workdir}/nwps_gum_52200_scatter.png
cp ${workdir}/nwps_${ENDDATE}_gum_52211_scatter.png ${workdir}/nwps_gum_52211_scatter.png
cp ${workdir}/nwps_${ENDDATE}_gum_APRP7_scatter.png ${workdir}/nwps_gum_APRP7_scatter.png

cp ${workdir}/nwps_${ENDDATE}_aer_46001_scatter.png ${workdir}/nwps_aer_46001_scatter.png
cp ${workdir}/nwps_${ENDDATE}_aer_46080_scatter.png ${workdir}/nwps_aer_46080_scatter.png
cp ${workdir}/nwps_${ENDDATE}_aer_46082_scatter.png ${workdir}/nwps_aer_46082_scatter.png
cp ${workdir}/nwps_${ENDDATE}_aer_46108_scatter.png ${workdir}/nwps_aer_46108_scatter.png
cp ${workdir}/nwps_${ENDDATE}_aer_46061_scatter.png ${workdir}/nwps_aer_46061_scatter.png
cp ${workdir}/nwps_${ENDDATE}_aer_46060_scatter.png ${workdir}/nwps_aer_46060_scatter.png
cp ${workdir}/nwps_${ENDDATE}_aer_46076_scatter.png ${workdir}/nwps_aer_46076_scatter.png
cp ${workdir}/nwps_${ENDDATE}_alu_46066_scatter.png ${workdir}/nwps_alu_46066_scatter.png
cp ${workdir}/nwps_${ENDDATE}_ajk_46085_scatter.png ${workdir}/nwps_ajk_46085_scatter.png
cp ${workdir}/nwps_${ENDDATE}_ajk_46083_scatter.png ${workdir}/nwps_ajk_46083_scatter.png
cp ${workdir}/nwps_${ENDDATE}_afg_48114_scatter.png ${workdir}/nwps_afg_48114_scatter.png
cp ${workdir}/nwps_${ENDDATE}_afg_48012_scatter.png ${workdir}/nwps_afg_48012_scatter.png
cp ${workdir}/nwps_${ENDDATE}_afg_48212_scatter.png ${workdir}/nwps_afg_48212_scatter.png

scp ${workdir}/nwps_??_scatter.png waves@emcrzdm:/home/www/polar/nwps/para/images/rtimages/val_monthly/
scp ${workdir}/nwps_????_scatter.png waves@emcrzdm:/home/www/polar/nwps/para/images/rtimages/val_monthly/
scp ${workdir}/nwps_stats_??_ts.png waves@emcrzdm:/home/www/polar/nwps/para/images/rtimages/val_monthly/
scp ${workdir}/nwps_stats_????_ts.png waves@emcrzdm:/home/www/polar/nwps/para/images/rtimages/val_monthly/
scp ${workdir}/nwps_???_?????_scatter.png waves@emcrzdm:/home/www/polar/nwps/para/images/rtimages/validation/
scp ${workdir}/nwps_???_????_scatter.png waves@emcrzdm:/home/www/polar/nwps/para/images/rtimages/validation/


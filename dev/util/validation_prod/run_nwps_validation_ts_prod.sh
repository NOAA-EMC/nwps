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

export workdir='/lfs/h2/emc/couple/noscrub/andre.vanderwesthuysen/nwps_para/validation_prod/'

cd $workdir
pwd

# Cleanup
rm ${workdir}/nwps_???_?????_ts.png

#----- Set start and end dates of real-time analysis -----
export STARTDATE=$(date +%Y%m%d)
export STARTDATEm1=$(date -d "-1 days" +%Y%m%d)
export STARTDATEm2=$(date -d "-2 days" +%Y%m%d)
#export STARTDATE=$(date -d "-2 days" +%Y%m%d)
export ENDDATE=$(date -d "+6 days" +%Y%m%d)

export COMOUT='/lfs/h1/ops/prod/com/nwps/v1.4/'
export COMOUTm1='/lfs/h1/ops/prod/com/nwps/v1.4/'
export COMOUTm2='/lfs/h1/ops/prod/com/nwps/v1.4/'
export COMOUTww1='/lfs/h1/ops/prod/com/gfs/v16.2/'
export COMOUTww1_m1='/lfs/h1/ops/prod/com/gfs/v16.2/'
export COMOUTww1_m2='/lfs/h1/ops/prod/com/gfs/v16.2/'

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

echo 'Copying WW3 GRIB2 data...'
cycle='00'
declare -a fhours=('000' '003' '006' '009' '012' '015' '018' '021' '024' '027' '030' '033'
                   '036' '039' '042' '045' '048' '051' '054' '057' '060' '063' '066' '069'
                   '072' '075' '078' '081' '084' '087' '090' '093' '096' '099' '102')
#ww1_infile='multi_1.at_4m.t'${cycle}'z.f'
ww1_infile='gfswave.t'${cycle}'z.atlocn.0p16.f'

for hhh in "${fhours[@]}"
do
#   cp ${COMOUTww1}'multi_1.'${STARTDATE}'/'${ww1_infile}${hhh}'.grib2' ${workdir}/${STARTDATE}.${ww1_infile}${hhh}'.grib2'
   cp ${COMOUTww1}'gfs.'${STARTDATE}'/'${cycle}'/wave/gridded/'${ww1_infile}${hhh}'.grib2' ${workdir}/${STARTDATE}.${ww1_infile}${hhh}'.grib2'
done
for hhh in "${fhours[@]}"
do
#   cp ${COMOUTww1_m1}'multi_1.'${STARTDATEm1}'/'${ww1_infile}${hhh}'.grib2' ${workdir}/${STARTDATEm1}.${ww1_infile}${hhh}'.grib2'
   cp ${COMOUTww1_m1}'gfs.'${STARTDATEm1}'/'${cycle}'/wave/gridded/'${ww1_infile}${hhh}'.grib2' ${workdir}/${STARTDATEm1}.${ww1_infile}${hhh}'.grib2'
done
for hhh in "${fhours[@]}"
do
#   cp ${COMOUTww1_m2}'multi_1.'${STARTDATEm2}'/'${ww1_infile}${hhh}'.grib2' ${workdir}/${STARTDATEm2}.${ww1_infile}${hhh}'.grib2'
   cp ${COMOUTww1_m2}'gfs.'${STARTDATEm2}'/'${cycle}'/wave/gridded/'${ww1_infile}${hhh}'.grib2' ${workdir}/${STARTDATEm2}.${ww1_infile}${hhh}'.grib2'
done

# Run Python validation scripts
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '42020' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '42019' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '42035' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '42040' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '42012' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '42039' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '42036' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '42023' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py 'GSTRM' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '41114' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '41009' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '41113' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '41112' 'CG3'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '41008' 'CG1'
#python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '41012' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '41053' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '41115' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '42085' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '41056' 'CG1'

python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '41008' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '41029' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '41033' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '41004' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '41065' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '41076' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '41013' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '44095' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '41159' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '41025' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '44056' 'CG2'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '44100' 'CG2'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '44014' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '44093' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '44096' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '44064' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '44072' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '44099' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '44089' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '44058' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '44043' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py 'TPLM2' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '44062' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '44042' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '44009' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '44091' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '44065' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '44094' 'CG3'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '44025' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '44040' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '44039' 'CG4'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '44060' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '44069' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '44017' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '44020' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '44013' 'CG2'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '44018' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '44029' 'CG2'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '44090' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '44098' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '44033' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '44007' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '44032' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '44034' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '44027' 'CG1'

for hhh in "${fhours[@]}"
do
   rm ${STARTDATE}.${ww1_infile}${hhh}'.grib2'
   rm ${STARTDATEm1}.${ww1_infile}${hhh}'.grib2'
   rm ${STARTDATEm2}.${ww1_infile}${hhh}'.grib2'
done

# Copy the validation results to polar:
cp ${workdir}/nwps_${STARTDATE}_bro_42020_ts.png ${workdir}/nwps_bro_42020_ts.png
cp ${workdir}/nwps_${STARTDATE}_hgx_42019_ts.png ${workdir}/nwps_hgx_42019_ts.png
cp ${workdir}/nwps_${STARTDATE}_lch_42035_ts.png ${workdir}/nwps_lch_42035_ts.png
cp ${workdir}/nwps_${STARTDATE}_lix_42040_ts.png ${workdir}/nwps_lix_42040_ts.png
cp ${workdir}/nwps_${STARTDATE}_mob_42012_ts.png ${workdir}/nwps_mob_42012_ts.png
cp ${workdir}/nwps_${STARTDATE}_tae_42039_ts.png ${workdir}/nwps_tae_42039_ts.png
cp ${workdir}/nwps_${STARTDATE}_tae_42036_ts.png ${workdir}/nwps_tae_42036_ts.png
cp ${workdir}/nwps_${STARTDATE}_mfl_42023_ts.png ${workdir}/nwps_mfl_42023_ts.png
cp ${workdir}/nwps_${STARTDATE}_mfl_GSTRM_ts.png ${workdir}/nwps_mfl_GSTRM_ts.png
cp ${workdir}/nwps_${STARTDATE}_mfl_41114_ts.png ${workdir}/nwps_mfl_41114_ts.png
cp ${workdir}/nwps_${STARTDATE}_mlb_41113_ts.png ${workdir}/nwps_mlb_41113_ts.png
cp ${workdir}/nwps_${STARTDATE}_mlb_41009_ts.png ${workdir}/nwps_mlb_41009_ts.png
cp ${workdir}/nwps_${STARTDATE}_jax_41112_ts.png ${workdir}/nwps_jax_41112_ts.png
cp ${workdir}/nwps_${STARTDATE}_jax_41008_ts.png ${workdir}/nwps_jax_41008_ts.png
#cp ${workdir}/nwps_${STARTDATE}_jax_41012_ts.png ${workdir}/nwps_jax_41012_ts.png
cp ${workdir}/nwps_${STARTDATE}_sju_41115_ts.png ${workdir}/nwps_sju_41115_ts.png
cp ${workdir}/nwps_${STARTDATE}_sju_42085_ts.png ${workdir}/nwps_sju_42085_ts.png
cp ${workdir}/nwps_${STARTDATE}_sju_41056_ts.png ${workdir}/nwps_sju_41056_ts.png
cp ${workdir}/nwps_${STARTDATE}_sju_41053_ts.png ${workdir}/nwps_sju_41053_ts.png

cp ${workdir}/nwps_${STARTDATE}_chs_41008_ts.png ${workdir}/nwps_chs_41008_ts.png
cp ${workdir}/nwps_${STARTDATE}_chs_41029_ts.png ${workdir}/nwps_chs_41029_ts.png
cp ${workdir}/nwps_${STARTDATE}_chs_41033_ts.png ${workdir}/nwps_chs_41033_ts.png
cp ${workdir}/nwps_${STARTDATE}_chs_41004_ts.png ${workdir}/nwps_chs_41004_ts.png
cp ${workdir}/nwps_${STARTDATE}_chs_41065_ts.png ${workdir}/nwps_chs_41065_ts.png
cp ${workdir}/nwps_${STARTDATE}_chs_41076_ts.png ${workdir}/nwps_chs_41076_ts.png
cp ${workdir}/nwps_${STARTDATE}_ilm_41013_ts.png ${workdir}/nwps_ilm_41013_ts.png
cp ${workdir}/nwps_${STARTDATE}_mhx_44095_ts.png ${workdir}/nwps_mhx_44095_ts.png
cp ${workdir}/nwps_${STARTDATE}_mhx_41159_ts.png ${workdir}/nwps_mhx_41159_ts.png
cp ${workdir}/nwps_${STARTDATE}_mhx_41025_ts.png ${workdir}/nwps_mhx_41025_ts.png
cp ${workdir}/nwps_${STARTDATE}_mhx_44056_ts.png ${workdir}/nwps_mhx_44056_ts.png
cp ${workdir}/nwps_${STARTDATE}_mhx_44100_ts.png ${workdir}/nwps_mhx_44100_ts.png
cp ${workdir}/nwps_${STARTDATE}_akq_44014_ts.png ${workdir}/nwps_akq_44014_ts.png
cp ${workdir}/nwps_${STARTDATE}_akq_44093_ts.png ${workdir}/nwps_akq_44093_ts.png
cp ${workdir}/nwps_${STARTDATE}_akq_44096_ts.png ${workdir}/nwps_akq_44096_ts.png
cp ${workdir}/nwps_${STARTDATE}_akq_44064_ts.png ${workdir}/nwps_akq_44064_ts.png
cp ${workdir}/nwps_${STARTDATE}_akq_44072_ts.png ${workdir}/nwps_akq_44072_ts.png
cp ${workdir}/nwps_${STARTDATE}_akq_44099_ts.png ${workdir}/nwps_akq_44099_ts.png
cp ${workdir}/nwps_${STARTDATE}_akq_44089_ts.png ${workdir}/nwps_akq_44089_ts.png
cp ${workdir}/nwps_${STARTDATE}_akq_44058_ts.png ${workdir}/nwps_akq_44058_ts.png
cp ${workdir}/nwps_${STARTDATE}_lwx_44043_ts.png ${workdir}/nwps_lwx_44043_ts.png
cp ${workdir}/nwps_${STARTDATE}_lwx_TPLM2_ts.png ${workdir}/nwps_lwx_TPLM2_ts.png
cp ${workdir}/nwps_${STARTDATE}_lwx_44062_ts.png ${workdir}/nwps_lwx_44062_ts.png
cp ${workdir}/nwps_${STARTDATE}_lwx_44042_ts.png ${workdir}/nwps_lwx_44042_ts.png
cp ${workdir}/nwps_${STARTDATE}_phi_44009_ts.png ${workdir}/nwps_phi_44009_ts.png
cp ${workdir}/nwps_${STARTDATE}_phi_44091_ts.png ${workdir}/nwps_phi_44091_ts.png
cp ${workdir}/nwps_${STARTDATE}_okx_44065_ts.png ${workdir}/nwps_okx_44065_ts.png
cp ${workdir}/nwps_${STARTDATE}_okx_44094_ts.png ${workdir}/nwps_okx_44094_ts.png
cp ${workdir}/nwps_${STARTDATE}_okx_44025_ts.png ${workdir}/nwps_okx_44025_ts.png
cp ${workdir}/nwps_${STARTDATE}_okx_44040_ts.png ${workdir}/nwps_okx_44040_ts.png
cp ${workdir}/nwps_${STARTDATE}_okx_44039_ts.png ${workdir}/nwps_okx_44039_ts.png
cp ${workdir}/nwps_${STARTDATE}_okx_44060_ts.png ${workdir}/nwps_okx_44060_ts.png
cp ${workdir}/nwps_${STARTDATE}_okx_44069_ts.png ${workdir}/nwps_okx_44069_ts.png
cp ${workdir}/nwps_${STARTDATE}_box_44017_ts.png ${workdir}/nwps_box_44017_ts.png
cp ${workdir}/nwps_${STARTDATE}_box_44020_ts.png ${workdir}/nwps_box_44020_ts.png
cp ${workdir}/nwps_${STARTDATE}_box_44013_ts.png ${workdir}/nwps_box_44013_ts.png
cp ${workdir}/nwps_${STARTDATE}_box_44018_ts.png ${workdir}/nwps_box_44018_ts.png
cp ${workdir}/nwps_${STARTDATE}_box_44029_ts.png ${workdir}/nwps_box_44029_ts.png
cp ${workdir}/nwps_${STARTDATE}_box_44090_ts.png ${workdir}/nwps_box_44090_ts.png
cp ${workdir}/nwps_${STARTDATE}_box_44098_ts.png ${workdir}/nwps_box_44098_ts.png
cp ${workdir}/nwps_${STARTDATE}_gyx_44033_ts.png ${workdir}/nwps_gyx_44033_ts.png
cp ${workdir}/nwps_${STARTDATE}_gyx_44007_ts.png ${workdir}/nwps_gyx_44007_ts.png
cp ${workdir}/nwps_${STARTDATE}_gyx_44032_ts.png ${workdir}/nwps_gyx_44032_ts.png
cp ${workdir}/nwps_${STARTDATE}_car_44034_ts.png ${workdir}/nwps_car_44034_ts.png
cp ${workdir}/nwps_${STARTDATE}_car_44027_ts.png ${workdir}/nwps_car_44027_ts.png

scp ${workdir}/nwps_???_?????_ts.png waves@emcrzdm:/home/www/polar/nwps/images/rtimages/validation/


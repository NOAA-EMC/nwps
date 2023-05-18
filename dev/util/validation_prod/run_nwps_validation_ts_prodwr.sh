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

echo 'Running run_nwps_validation.sh...'

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
#ww1_infile='multi_1.wc_4m.t'${cycle}'z.f'
ww1_infile='gfswave.t'${cycle}'z.wcoast.0p16.f'

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
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '46206' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '46041' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '46087' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '46088' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '46211' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '46243' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '46248' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '46029' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '46050' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '46015' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '46027' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '46229' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '46213' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '46212' 'CG1'
#python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '46027' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '46014' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '46042' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '46028' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '46239' 'CG3'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '46236' 'CG3'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '46240' 'CG3'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '46214' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '46013' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '46012' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '46026' 'CG2'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '46237' 'CG2'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '46028' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '46219' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '46069' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '46221' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '46222' 'CG2'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '46253' 'CG2'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '46256' 'CG2'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '46011' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '46053' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '46054' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '46025' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '46218' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '46086' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '46224' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '46232' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '46231' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '46258' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '46225' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '46242' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '46254' 'CG2'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py 'LJPC1' 'CG2'

python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '51208' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '51207' 'CG3'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '51206' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '51205' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '51204' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '51203' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '51202' 'CG3'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '51201' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '51003' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py '51211' 'CG3'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py 'Kona' 'CG1'
python ${workdir}/nwps_stats_buoy_ts_multipar_multimod_6day.py 'Isaac' 'CG1'

for hhh in "${fhours[@]}"
do
   rm ${STARTDATE}.${ww1_infile}${hhh}'.grib2'
   rm ${STARTDATEm1}.${ww1_infile}${hhh}'.grib2'
   rm ${STARTDATEm2}.${ww1_infile}${hhh}'.grib2'
done

# Copy the validation results to polar:
cp ${workdir}/nwps_${STARTDATE}_sew_46206_ts.png ${workdir}/nwps_sew_46206_ts.png
cp ${workdir}/nwps_${STARTDATE}_sew_46041_ts.png ${workdir}/nwps_sew_46041_ts.png
cp ${workdir}/nwps_${STARTDATE}_sew_46087_ts.png ${workdir}/nwps_sew_46087_ts.png
cp ${workdir}/nwps_${STARTDATE}_sew_46088_ts.png ${workdir}/nwps_sew_46088_ts.png
cp ${workdir}/nwps_${STARTDATE}_pqr_46211_ts.png ${workdir}/nwps_pqr_46211_ts.png
cp ${workdir}/nwps_${STARTDATE}_pqr_46243_ts.png ${workdir}/nwps_pqr_46243_ts.png
cp ${workdir}/nwps_${STARTDATE}_pqr_46248_ts.png ${workdir}/nwps_pqr_46248_ts.png
cp ${workdir}/nwps_${STARTDATE}_pqr_46029_ts.png ${workdir}/nwps_pqr_46029_ts.png
cp ${workdir}/nwps_${STARTDATE}_pqr_46050_ts.png ${workdir}/nwps_pqr_46050_ts.png
cp ${workdir}/nwps_${STARTDATE}_mfr_46015_ts.png ${workdir}/nwps_mfr_46015_ts.png
cp ${workdir}/nwps_${STARTDATE}_mfr_46027_ts.png ${workdir}/nwps_mfr_46027_ts.png
cp ${workdir}/nwps_${STARTDATE}_mfr_46229_ts.png ${workdir}/nwps_mfr_46229_ts.png
cp ${workdir}/nwps_${STARTDATE}_eka_46213_ts.png ${workdir}/nwps_eka_46213_ts.png
cp ${workdir}/nwps_${STARTDATE}_eka_46212_ts.png ${workdir}/nwps_eka_46212_ts.png
#cp ${workdir}/nwps_${STARTDATE}_eka_46027_ts.png ${workdir}/nwps_eka_46027_ts.png
cp ${workdir}/nwps_${STARTDATE}_eka_46014_ts.png ${workdir}/nwps_eka_46014_ts.png
cp ${workdir}/nwps_${STARTDATE}_mtr_46042_ts.png ${workdir}/nwps_mtr_46042_ts.png
cp ${workdir}/nwps_${STARTDATE}_mtr_46028_ts.png ${workdir}/nwps_mtr_46028_ts.png
cp ${workdir}/nwps_${STARTDATE}_mtr_46239_ts.png ${workdir}/nwps_mtr_46239_ts.png
cp ${workdir}/nwps_${STARTDATE}_mtr_46236_ts.png ${workdir}/nwps_mtr_46236_ts.png
cp ${workdir}/nwps_${STARTDATE}_mtr_46240_ts.png ${workdir}/nwps_mtr_46240_ts.png
cp ${workdir}/nwps_${STARTDATE}_mtr_46214_ts.png ${workdir}/nwps_mtr_46214_ts.png
cp ${workdir}/nwps_${STARTDATE}_mtr_46013_ts.png ${workdir}/nwps_mtr_46013_ts.png
cp ${workdir}/nwps_${STARTDATE}_mtr_46012_ts.png ${workdir}/nwps_mtr_46012_ts.png
cp ${workdir}/nwps_${STARTDATE}_mtr_46026_ts.png ${workdir}/nwps_mtr_46026_ts.png
cp ${workdir}/nwps_${STARTDATE}_mtr_46237_ts.png ${workdir}/nwps_mtr_46237_ts.png
cp ${workdir}/nwps_${STARTDATE}_lox_46028_ts.png ${workdir}/nwps_lox_46028_ts.png
cp ${workdir}/nwps_${STARTDATE}_lox_46219_ts.png ${workdir}/nwps_lox_46219_ts.png
cp ${workdir}/nwps_${STARTDATE}_lox_46069_ts.png ${workdir}/nwps_lox_46069_ts.png
cp ${workdir}/nwps_${STARTDATE}_lox_46221_ts.png ${workdir}/nwps_lox_46221_ts.png
cp ${workdir}/nwps_${STARTDATE}_lox_46222_ts.png ${workdir}/nwps_lox_46222_ts.png
cp ${workdir}/nwps_${STARTDATE}_lox_46253_ts.png ${workdir}/nwps_lox_46253_ts.png
cp ${workdir}/nwps_${STARTDATE}_lox_46256_ts.png ${workdir}/nwps_lox_46256_ts.png
cp ${workdir}/nwps_${STARTDATE}_lox_46011_ts.png ${workdir}/nwps_lox_46011_ts.png
cp ${workdir}/nwps_${STARTDATE}_lox_46053_ts.png ${workdir}/nwps_lox_46053_ts.png
cp ${workdir}/nwps_${STARTDATE}_lox_46054_ts.png ${workdir}/nwps_lox_46054_ts.png
cp ${workdir}/nwps_${STARTDATE}_lox_46025_ts.png ${workdir}/nwps_lox_46025_ts.png
cp ${workdir}/nwps_${STARTDATE}_lox_46218_ts.png ${workdir}/nwps_lox_46218_ts.png
cp ${workdir}/nwps_${STARTDATE}_sgx_46086_ts.png ${workdir}/nwps_sgx_46086_ts.png
cp ${workdir}/nwps_${STARTDATE}_sgx_46224_ts.png ${workdir}/nwps_sgx_46224_ts.png
cp ${workdir}/nwps_${STARTDATE}_sgx_46232_ts.png ${workdir}/nwps_sgx_46232_ts.png
cp ${workdir}/nwps_${STARTDATE}_sgx_46231_ts.png ${workdir}/nwps_sgx_46231_ts.png
cp ${workdir}/nwps_${STARTDATE}_sgx_46258_ts.png ${workdir}/nwps_sgx_46258_ts.png
cp ${workdir}/nwps_${STARTDATE}_sgx_46225_ts.png ${workdir}/nwps_sgx_46225_ts.png
cp ${workdir}/nwps_${STARTDATE}_sgx_46242_ts.png ${workdir}/nwps_sgx_46242_ts.png
cp ${workdir}/nwps_${STARTDATE}_sgx_46254_ts.png ${workdir}/nwps_sgx_46254_ts.png
cp ${workdir}/nwps_${STARTDATE}_sgx_LJPC1_ts.png ${workdir}/nwps_sgx_LJPC1_ts.png

cp ${workdir}/nwps_${STARTDATE}_hfo_51208_ts.png ${workdir}/nwps_hfo_51208_ts.png
cp ${workdir}/nwps_${STARTDATE}_hfo_51207_ts.png ${workdir}/nwps_hfo_51207_ts.png
cp ${workdir}/nwps_${STARTDATE}_hfo_51206_ts.png ${workdir}/nwps_hfo_51206_ts.png
cp ${workdir}/nwps_${STARTDATE}_hfo_51205_ts.png ${workdir}/nwps_hfo_51205_ts.png
cp ${workdir}/nwps_${STARTDATE}_hfo_51204_ts.png ${workdir}/nwps_hfo_51204_ts.png
cp ${workdir}/nwps_${STARTDATE}_hfo_51203_ts.png ${workdir}/nwps_hfo_51203_ts.png
cp ${workdir}/nwps_${STARTDATE}_hfo_51202_ts.png ${workdir}/nwps_hfo_51202_ts.png
cp ${workdir}/nwps_${STARTDATE}_hfo_51201_ts.png ${workdir}/nwps_hfo_51201_ts.png
cp ${workdir}/nwps_${STARTDATE}_hfo_51003_ts.png ${workdir}/nwps_hfo_51003_ts.png
cp ${workdir}/nwps_${STARTDATE}_hfo_51211_ts.png ${workdir}/nwps_hfo_51211_ts.png
cp ${workdir}/nwps_${STARTDATE}_hfo_Kona_ts.png ${workdir}/nwps_hfo_Kona_ts.png
cp ${workdir}/nwps_${STARTDATE}_hfo_Isaac_ts.png ${workdir}/nwps_hfo_Isaac_ts.png

scp ${workdir}/nwps_???_?????_ts.png waves@emcrzdm:/home/www/polar/nwps/images/rtimages/validation/
scp ${workdir}/nwps_???_????_ts.png waves@emcrzdm:/home/www/polar/nwps/images/rtimages/validation/


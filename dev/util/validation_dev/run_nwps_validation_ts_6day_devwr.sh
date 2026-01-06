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

#----- Set start and end dates of real-time analysis -----
export STARTDATE=$(date +%Y%m%d)
export STARTDATEm1=$(date -d "-1 days" +%Y%m%d)
export STARTDATEm5=$(date -d "-6 days" +%Y%m%d)
export ENDDATE=$(date -d "-1 days" +%Y%m%d)

export COMOUT='/lfs/h2/emc/ptmp/ali.salimi/com/nwps/v1.5.0/'
export COMOUTm1='/lfs/h2/emc/ptmp/ali.salimi/com/nwps/v1.5.0/'
export COMOUTm5='/lfs/h2/emc/couple/noscrub/ali.salimi/nwps_para/prod/com/nwps/v1.4/'
export COMOUTm5_dev='/lfs/h2/emc/ptmp/ali.salimi/com/nwps/v1.5.0/'
export COMOUTww1='/lfs/h1/ops/prod/com/gfs/v16.3/'
export COMOUTww1_m1='/lfs/h1/ops/prod/com/gfs/v16.3/'
export COMOUTww1_m2='/lfs/h1/ops/prod/com/gfs/v16.3/'

echo ''
echo 'Analysing real-time data for:'
echo 'STARTDATE = '${STARTDATE}
echo 'ENDDATE = '${ENDDATE}
echo ''
echo 'COMOUT='${COMOUT}
echo 'COMOUTm1='${COMOUTm1}
echo 'workdir='${workdir}
echo ''

echo 'Copying WW3 GRIB2 data...'
cycle='00'
declare -a fhours=('000' '003' '006' '009' '012' '015' '018' '021' '024' '027' '030' '033'
                   '036' '039' '042' '045' '048' '051' '054' '057' '060' '063' '066' '069'
                   '072' '075' '078' '081' '084' '087' '090' '093' '096' '099' '102' '105'
                   '108' '111' '114' '117' '120' '123' '126' '129' '132' '135' '138' '141' '144')
#ww1_infile='multi_1.wc_4m.t'${cycle}'z.f'
ww1_infile='gfswave.t'${cycle}'z.wcoast.0p16.f'

for hhh in "${fhours[@]}"
do
#   cp ${COMOUTww1_m2}'multi_1.'${STARTDATEm5}'/'${ww1_infile}${hhh}'.grib2' ${workdir}/${STARTDATEm5}.${ww1_infile}${hhh}'.grib2'
   cp ${COMOUTww1_m2}'gfs.'${STARTDATEm5}'/'${cycle}'/wave/gridded/'${ww1_infile}${hhh}'.grib2' ${workdir}/${STARTDATEm5}.${ww1_infile}${hhh}'.grib2'
done


export copydir=${workdir}/${STARTDATEm5}
mkdir -p ${copydir}

# Run Python validation scripts
python ${workdir}/nwps_stats_ts_6day.py '46206' 'CG1'
python ${workdir}/nwps_stats_ts_6day.py '46041' 'CG1'
python ${workdir}/nwps_stats_ts_6day.py '46087' 'CG1'
python ${workdir}/nwps_stats_ts_6day.py '46088' 'CG1'
python ${workdir}/nwps_stats_ts_6day.py '46211' 'CG1'
python ${workdir}/nwps_stats_ts_6day.py '46243' 'CG1'
python ${workdir}/nwps_stats_ts_6day.py '46248' 'CG1'
python ${workdir}/nwps_stats_ts_6day.py '46029' 'CG1'
python ${workdir}/nwps_stats_ts_6day.py '46050' 'CG1'
python ${workdir}/nwps_stats_ts_6day.py '46015' 'CG1'
python ${workdir}/nwps_stats_ts_6day.py '46027' 'CG1'
python ${workdir}/nwps_stats_ts_6day.py '46229' 'CG1'
python ${workdir}/nwps_stats_ts_6day.py '46213' 'CG1'
python ${workdir}/nwps_stats_ts_6day.py '46212' 'CG1'
#python ${workdir}/nwps_stats_ts_6day.py '46027' 'CG1'
python ${workdir}/nwps_stats_ts_6day.py '46014' 'CG1'
python ${workdir}/nwps_stats_ts_6day.py '46042' 'CG1'
python ${workdir}/nwps_stats_ts_6day.py '46028' 'CG1'
python ${workdir}/nwps_stats_ts_6day.py '46239' 'CG3'
python ${workdir}/nwps_stats_ts_6day.py '46236' 'CG3'
python ${workdir}/nwps_stats_ts_6day.py '46240' 'CG3'
python ${workdir}/nwps_stats_ts_6day.py '46214' 'CG1'
python ${workdir}/nwps_stats_ts_6day.py '46013' 'CG1'
python ${workdir}/nwps_stats_ts_6day.py '46012' 'CG1'
python ${workdir}/nwps_stats_ts_6day.py '46026' 'CG2'
python ${workdir}/nwps_stats_ts_6day.py '46237' 'CG2'
python ${workdir}/nwps_stats_ts_6day.py '46028' 'CG1'
python ${workdir}/nwps_stats_ts_6day.py '46219' 'CG1'
python ${workdir}/nwps_stats_ts_6day.py '46069' 'CG1'
python ${workdir}/nwps_stats_ts_6day.py '46221' 'CG1'
python ${workdir}/nwps_stats_ts_6day.py '46222' 'CG2'
python ${workdir}/nwps_stats_ts_6day.py '46253' 'CG2'
python ${workdir}/nwps_stats_ts_6day.py '46256' 'CG2'
python ${workdir}/nwps_stats_ts_6day.py '46011' 'CG1'
python ${workdir}/nwps_stats_ts_6day.py '46053' 'CG1'
python ${workdir}/nwps_stats_ts_6day.py '46054' 'CG1'
python ${workdir}/nwps_stats_ts_6day.py '46025' 'CG1'
python ${workdir}/nwps_stats_ts_6day.py '46218' 'CG1'
python ${workdir}/nwps_stats_ts_6day.py '46086' 'CG1'
python ${workdir}/nwps_stats_ts_6day.py '46224' 'CG1'
python ${workdir}/nwps_stats_ts_6day.py '46232' 'CG1'
python ${workdir}/nwps_stats_ts_6day.py '46231' 'CG1'
python ${workdir}/nwps_stats_ts_6day.py '46258' 'CG1'
python ${workdir}/nwps_stats_ts_6day.py '46225' 'CG1'
python ${workdir}/nwps_stats_ts_6day.py '46242' 'CG1'
python ${workdir}/nwps_stats_ts_6day.py '46254' 'CG2'
python ${workdir}/nwps_stats_ts_6day.py 'LJPC1' 'CG2'

python ${workdir}/nwps_stats_ts_6day.py '51208' 'CG1'
python ${workdir}/nwps_stats_ts_6day.py '51207' 'CG3'
python ${workdir}/nwps_stats_ts_6day.py '51206' 'CG1'
python ${workdir}/nwps_stats_ts_6day.py '51205' 'CG1'
python ${workdir}/nwps_stats_ts_6day.py '51204' 'CG1'
python ${workdir}/nwps_stats_ts_6day.py '51203' 'CG1'
python ${workdir}/nwps_stats_ts_6day.py '51202' 'CG3'
python ${workdir}/nwps_stats_ts_6day.py '51201' 'CG1'
python ${workdir}/nwps_stats_ts_6day.py '51003' 'CG1'
python ${workdir}/nwps_stats_ts_6day.py '51211' 'CG3'
python ${workdir}/nwps_stats_ts_6day.py 'Kona' 'CG1'
python ${workdir}/nwps_stats_ts_6day.py 'Isaac' 'CG1'

for hhh in "${fhours[@]}"
do
   rm ${STARTDATE}.${ww1_infile}${hhh}'.grib2'
   rm ${STARTDATEm1}.${ww1_infile}${hhh}'.grib2'
   rm ${STARTDATEm5}.${ww1_infile}${hhh}'.grib2'
done

# Copy the validation results to polar:
mv ${workdir}/nwps_${STARTDATEm5}_sew_46206_ts_6day.png ${copydir}/nwps_sew_46206_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_sew_46041_ts_6day.png ${copydir}/nwps_sew_46041_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_sew_46087_ts_6day.png ${copydir}/nwps_sew_46087_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_sew_46088_ts_6day.png ${copydir}/nwps_sew_46088_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_pqr_46211_ts_6day.png ${copydir}/nwps_pqr_46211_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_pqr_46243_ts_6day.png ${copydir}/nwps_pqr_46243_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_pqr_46248_ts_6day.png ${copydir}/nwps_pqr_46248_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_pqr_46029_ts_6day.png ${copydir}/nwps_pqr_46029_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_pqr_46050_ts_6day.png ${copydir}/nwps_pqr_46050_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_mfr_46015_ts_6day.png ${copydir}/nwps_mfr_46015_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_mfr_46027_ts_6day.png ${copydir}/nwps_mfr_46027_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_mfr_46229_ts_6day.png ${copydir}/nwps_mfr_46229_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_eka_46213_ts_6day.png ${copydir}/nwps_eka_46213_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_eka_46212_ts_6day.png ${copydir}/nwps_eka_46212_ts_6day.png
#mv ${workdir}/nwps_${STARTDATEm5}_eka_46027_ts_6day.png ${copydir}/nwps_eka_46027_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_eka_46014_ts_6day.png ${copydir}/nwps_eka_46014_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_mtr_46042_ts_6day.png ${copydir}/nwps_mtr_46042_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_mtr_46028_ts_6day.png ${copydir}/nwps_mtr_46028_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_mtr_46239_ts_6day.png ${copydir}/nwps_mtr_46239_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_mtr_46236_ts_6day.png ${copydir}/nwps_mtr_46236_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_mtr_46240_ts_6day.png ${copydir}/nwps_mtr_46240_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_mtr_46214_ts_6day.png ${copydir}/nwps_mtr_46214_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_mtr_46013_ts_6day.png ${copydir}/nwps_mtr_46013_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_mtr_46012_ts_6day.png ${copydir}/nwps_mtr_46012_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_mtr_46026_ts_6day.png ${copydir}/nwps_mtr_46026_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_mtr_46237_ts_6day.png ${copydir}/nwps_mtr_46237_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_lox_46028_ts_6day.png ${copydir}/nwps_lox_46028_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_lox_46219_ts_6day.png ${copydir}/nwps_lox_46219_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_lox_46069_ts_6day.png ${copydir}/nwps_lox_46069_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_lox_46221_ts_6day.png ${copydir}/nwps_lox_46221_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_lox_46222_ts_6day.png ${copydir}/nwps_lox_46222_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_lox_46253_ts_6day.png ${copydir}/nwps_lox_46253_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_lox_46256_ts_6day.png ${copydir}/nwps_lox_46256_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_lox_46011_ts_6day.png ${copydir}/nwps_lox_46011_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_lox_46053_ts_6day.png ${copydir}/nwps_lox_46053_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_lox_46054_ts_6day.png ${copydir}/nwps_lox_46054_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_lox_46025_ts_6day.png ${copydir}/nwps_lox_46025_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_lox_46218_ts_6day.png ${copydir}/nwps_lox_46218_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_sgx_46086_ts_6day.png ${copydir}/nwps_sgx_46086_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_sgx_46224_ts_6day.png ${copydir}/nwps_sgx_46224_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_sgx_46232_ts_6day.png ${copydir}/nwps_sgx_46232_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_sgx_46231_ts_6day.png ${copydir}/nwps_sgx_46231_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_sgx_46258_ts_6day.png ${copydir}/nwps_sgx_46258_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_sgx_46225_ts_6day.png ${copydir}/nwps_sgx_46225_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_sgx_46242_ts_6day.png ${copydir}/nwps_sgx_46242_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_sgx_46254_ts_6day.png ${copydir}/nwps_sgx_46254_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_sgx_LJPC1_ts_6day.png ${copydir}/nwps_sgx_LJPC1_ts_6day.png

mv ${workdir}/nwps_${STARTDATEm5}_hfo_51208_ts_6day.png ${copydir}/nwps_hfo_51208_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_hfo_51207_ts_6day.png ${copydir}/nwps_hfo_51207_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_hfo_51206_ts_6day.png ${copydir}/nwps_hfo_51206_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_hfo_51205_ts_6day.png ${copydir}/nwps_hfo_51205_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_hfo_51204_ts_6day.png ${copydir}/nwps_hfo_51204_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_hfo_51203_ts_6day.png ${copydir}/nwps_hfo_51203_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_hfo_51202_ts_6day.png ${copydir}/nwps_hfo_51202_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_hfo_51201_ts_6day.png ${copydir}/nwps_hfo_51201_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_hfo_51003_ts_6day.png ${copydir}/nwps_hfo_51003_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_hfo_51211_ts_6day.png ${copydir}/nwps_hfo_51211_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_hfo_Kona_ts_6day.png ${copydir}/nwps_hfo_Kona_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_hfo_Isaac_ts_6day.png ${copydir}/nwps_hfo_Isaac_ts_6day.png



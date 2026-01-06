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
echo 'COMOUTm5='${COMOUTm5}
echo 'workdir='${workdir}
echo ''

export copydir=${workdir}/${STARTDATEm5}
mkdir -p ${copydir}

echo 'Copying WW3 GRIB2 data...'
cycle='00'
declare -a fhours=('000' '003' '006' '009' '012' '015' '018' '021' '024' '027' '030' '033'
                   '036' '039' '042' '045' '048' '051' '054' '057' '060' '063' '066' '069'
                   '072' '075' '078' '081' '084' '087' '090' '093' '096' '099' '102' '105'
                   '108' '111' '114' '117' '120' '123' '126' '129' '132' '135' '138' '141' '144')
#ww1_infile='multi_1.ep_10m.t'${cycle}'z.f'
#ww1_infile2='multi_1.ak_4m.t'${cycle}'z.f'
ww1_infile='gfswave.t'${cycle}'z.global.0p16.f'
ww1_infile2='gfswave.t'${cycle}'z.global.0p25.f'

for hhh in "${fhours[@]}"
do
#   cp ${COMOUTww1}'multi_1.'${STARTDATE}'/'${ww1_infile}${hhh}'.grib2' ${workdir}/${STARTDATE}.${ww1_infile}${hhh}'.grib2'
#   cp ${COMOUTww1}'multi_1.'${STARTDATE}'/'${ww1_infile2}${hhh}'.grib2' ${workdir}/${STARTDATE}.${ww1_infile2}${hhh}'.grib2'
   cp ${COMOUTww1}'gfs.'${STARTDATE}'/'${cycle}'/wave/gridded/'${ww1_infile}${hhh}'.grib2' ${workdir}/${STARTDATE}.${ww1_infile}${hhh}'.grib2'
   cp ${COMOUTww1}'gfs.'${STARTDATE}'/'${cycle}'/wave/gridded/'${ww1_infile2}${hhh}'.grib2' ${workdir}/${STARTDATE}.${ww1_infile2}${hhh}'.grib2'
done
for hhh in "${fhours[@]}"
do
#   cp ${COMOUTww1_m1}'multi_1.'${STARTDATEm1}'/'${ww1_infile}${hhh}'.grib2' ${workdir}/${STARTDATEm1}.${ww1_infile}${hhh}'.grib2'
#   cp ${COMOUTww1_m1}'multi_1.'${STARTDATEm1}'/'${ww1_infile2}${hhh}'.grib2' ${workdir}/${STARTDATEm1}.${ww1_infile2}${hhh}'.grib2'
   cp ${COMOUTww1_m1}'gfs.'${STARTDATEm1}'/'${cycle}'/wave/gridded/'${ww1_infile}${hhh}'.grib2' ${workdir}/${STARTDATEm1}.${ww1_infile}${hhh}'.grib2'
   cp ${COMOUTww1_m1}'gfs.'${STARTDATEm1}'/'${cycle}'/wave/gridded/'${ww1_infile2}${hhh}'.grib2' ${workdir}/${STARTDATEm1}.${ww1_infile2}${hhh}'.grib2'
done
for hhh in "${fhours[@]}"
do
#   cp ${COMOUTww1_m2}'multi_1.'${STARTDATEm5}'/'${ww1_infile}${hhh}'.grib2' ${workdir}/${STARTDATEm5}.${ww1_infile}${hhh}'.grib2'
#   cp ${COMOUTww1_m2}'multi_1.'${STARTDATEm5}'/'${ww1_infile2}${hhh}'.grib2' ${workdir}/${STARTDATEm5}.${ww1_infile2}${hhh}'.grib2'
   cp ${COMOUTww1_m2}'gfs.'${STARTDATEm5}'/'${cycle}'/wave/gridded/'${ww1_infile}${hhh}'.grib2' ${workdir}/${STARTDATEm5}.${ww1_infile}${hhh}'.grib2'
   cp ${COMOUTww1_m2}'gfs.'${STARTDATEm5}'/'${cycle}'/wave/gridded/'${ww1_infile2}${hhh}'.grib2' ${workdir}/${STARTDATEm5}.${ww1_infile2}${hhh}'.grib2'
done

# Run Python validation scripts
python ${workdir}/nwps_stats_ts_6day.py '52200' 'CG1'
python ${workdir}/nwps_stats_ts_6day.py '52211' 'CG1'
python ${workdir}/nwps_stats_ts_6day.py 'APRP7' 'CG1'
python ${workdir}/nwps_stats_ts_6day.py '52202' 'CG1'

# Copy the validation results to polar:
mv ${workdir}/nwps_${STARTDATEm5}_gum_52200_ts_6day.png ${copydir}/nwps_gum_52200_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_gum_52211_ts_6day.png ${copydir}/nwps_gum_52211_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_gum_APRP7_ts_6day.png ${copydir}/nwps_gum_APRP7_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_gum_52202_ts_6day.png ${copydir}/nwps_gum_52202_ts_6day.png

# Run Python validation scripts
python ${workdir}/nwps_stats_ts_6day.py '46001' 'CG1'
python ${workdir}/nwps_stats_ts_6day.py '46080' 'CG1'
python ${workdir}/nwps_stats_ts_6day.py '46076' 'CG1'
python ${workdir}/nwps_stats_ts_6day.py '46082' 'CG1'
python ${workdir}/nwps_stats_ts_6day.py '46061' 'CG1'
python ${workdir}/nwps_stats_ts_6day.py '46060' 'CG1'
python ${workdir}/nwps_stats_ts_6day.py '46108' 'CG1'
python ${workdir}/nwps_stats_ts_6day.py '46081' 'CG3'
python ${workdir}/nwps_stats_ts_6day.py '46077' 'CG1'

# Copy the validation results to polar:
mv ${workdir}/nwps_${STARTDATEm5}_aer_46001_ts_6day.png ${copydir}/nwps_aer_46001_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_aer_46080_ts_6day.png ${copydir}/nwps_aer_46080_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_aer_46076_ts_6day.png ${copydir}/nwps_aer_46076_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_aer_46082_ts_6day.png ${copydir}/nwps_aer_46082_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_aer_46061_ts_6day.png ${copydir}/nwps_aer_46061_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_aer_46060_ts_6day.png ${copydir}/nwps_aer_46060_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_aer_46108_ts_6day.png ${copydir}/nwps_aer_46108_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_aer_46081_ts_6day.png ${copydir}/nwps_aer_46081_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_aer_46077_ts_6day.png ${copydir}/nwps_aer_46077_ts_6day.png

# Run Python validation scripts
python ${workdir}/nwps_stats_ts_6day.py '46066' 'CG1'
python ${workdir}/nwps_stats_ts_6day.py '46073' 'CG1'
python ${workdir}/nwps_stats_ts_6day.py '46075' 'CG1'

# Copy the validation results to polar:
mv ${workdir}/nwps_${STARTDATEm5}_alu_46066_ts_6day.png ${copydir}/nwps_alu_46066_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_alu_46073_ts_6day.png ${copydir}/nwps_alu_46073_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_alu_46075_ts_6day.png ${copydir}/nwps_alu_46075_ts_6day.png

# Run Python validation scripts
python ${workdir}/nwps_stats_ts_6day.py '46085' 'CG1'
python ${workdir}/nwps_stats_ts_6day.py '46083' 'CG1'
python ${workdir}/nwps_stats_ts_6day.py 'FFIA2' 'CG1'

# Copy the validation results to polar:
mv ${workdir}/nwps_${STARTDATEm5}_ajk_46085_ts_6day.png ${copydir}/nwps_ajk_46085_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_ajk_46083_ts_6day.png ${copydir}/nwps_ajk_46083_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_ajk_FFIA2_ts_6day.png ${copydir}/nwps_ajk_FFIA2_ts_6day.png

# Run Python validation scripts
python ${workdir}/nwps_stats_ts_6day.py '48114' 'CG1'
python ${workdir}/nwps_stats_ts_6day.py '48012' 'CG1'
python ${workdir}/nwps_stats_ts_6day.py '48212' 'CG1'

# Copy the validation results to polar:
mv ${workdir}/nwps_${STARTDATEm5}_afg_48114_ts_6day.png ${copydir}/nwps_afg_48114_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_afg_48012_ts_6day.png ${copydir}/nwps_afg_48012_ts_6day.png
mv ${workdir}/nwps_${STARTDATEm5}_afg_48212_ts_6day.png ${copydir}/nwps_afg_48212_ts_6day.png

for hhh in "${fhours[@]}"
do
   rm ${STARTDATE}.${ww1_infile}${hhh}'.grib2'
   rm ${STARTDATEm1}.${ww1_infile}${hhh}'.grib2'
   rm ${STARTDATEm5}.${ww1_infile}${hhh}'.grib2'
   rm ${STARTDATE}.${ww1_infile2}${hhh}'.grib2'
   rm ${STARTDATEm1}.${ww1_infile2}${hhh}'.grib2'
   rm ${STARTDATEm5}.${ww1_infile2}${hhh}'.grib2'
done


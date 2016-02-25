#!/bin/bash
# -----------------------------------------------------------
# UNIX Shell Script
# Tested Operating System(s): RHEL 5
# Shell Used: BASH shell
# Original Author(s): alex.gibbs@noaa.gov
# File Creation Date: 11/25/2011
# Date Last Modified: 06/26/2014
#
# Version control: 1.04
#
# Support Team:
#
# Contributors: Douglas.Gaer@noaa.gov
# -----------------------------------------------------------
# ------------- Program Description and Details -------------
# -----------------------------------------------------------
#
# This script will dynamically adjust the NWPS colors scales 
# according to the data for each parameter within the grads 
# scripts.
#
# ----------------------------------------------------------- 

# Setup our NWPS environment                                                    
if [ "${USHnwps}" == "" ]
    then 
    echo "ERROR - Your USHnwps variable is not set"
    export err=1; err_chk
fi

if [ -e ${USHnwps}/nwps_config.sh ]
then
    source ${USHnwps}/nwps_config.sh
else
    "ERROR - Cannot find ${USHnwps}/nwps_config.sh"
    export err=1; err_chk
fi

# The CG number must be set when this script is called
CGNUM="$1"
if [ "${CGNUM}" == "" ]
then 
    echo "ERROR - You must specify the current CG number"
    export err=1; err_chk
fi

if [ "${siteid}" == "" ]
    then
    siteid="default"
fi

BINdir="${USHnwps}/grads/bin"
ETCdir="${USHnwps}/grads/etc/${siteid}"

if [ ! -e ${VARdir} ]; then mkdir -p ${VARdir}; fi
if [ ! -e ${LOGdir} ]; then mkdir -p ${LOGdir}; fi

BINdir="${USHnwps}/grads/etc/${1}"


TEMPDIR=${VARdir}/${siteid}.tmp/CG${CGNUM}
mkdir -p ${TEMPDIR}
echo "Writing all temp files to ${TEMPDIR}"

DATAgrb="${TEMPDIR}/swan.grib2"
if [ ! -e ${DATAgrb} ]
then
    echo "ERROR - Missing GRIB2 file"
    echo "ERROR - Cannot open ${DATAgrb}"
    export err=1; err_chk
fi

echo ""
echo ""
echo "Start extracting model parameters to get maximum values through the model run for SITE ${1}"
echo ""
echo ""

# -----------------------------------------------------------

echo "HTSGW - Total Signficant Wave Height"

${WGRIB2} ${DATAgrb} -s | grep ":HTSGW:" | ${WGRIB2} -i ${DATAgrb} -spread ${TEMPDIR}/mxhtsgw.txt
sed -e 's/,/, /g' ${TEMPDIR}/mxhtsgw.txt  > ${TEMPDIR}/mxhtsgw1.txt
awk '{print $3;}' ${TEMPDIR}/mxhtsgw1.txt > ${TEMPDIR}/mxhtsgw2.txt
sort -n ${TEMPDIR}/mxhtsgw2.txt | tail -1 > ${TEMPDIR}/mxhtsgw

htsgw=$(cat ${TEMPDIR}/mxhtsgw)
htsgw1=$(echo "$htsgw*3.280839" | bc)
hs_low=15
hs_extreme=36
hs_int=`echo ${htsgw1} '*1' | bc -l | awk -F '.' '{ print $1; exit; }'` # round the value to be compared

# Define the conditions to establish colorscale max & interval.

if [ ${hs_int} -le ${hs_low} ]
then

    hs_max_scale=15 # feet
    hs_incr=1 # scale interval

elif [ ${hs_int} -ge ${hs_extreme} ]
then

    hs_max_scale=56 # feet
    hs_incr=3 # scale interval   

else
    hs_max_scale=$hs_int # keep maximum value from data
    hs_incr=2 
fi

echo ""
echo "Hs Max value of ${htsgw1} gives a scale hgt to: ${hs_max_scale}"
echo "Hs Scale Interval: ${hs_incr}"
echo ""
echo ""
 
rm ${TEMPDIR}/mxhtsgw2.txt ${TEMPDIR}/mxhtsgw1.txt ${TEMPDIR}/mxhtsgw.txt

# -----------------------------------------------------------

echo "SWELL - Total Significant Swell Height"

${WGRIB2} ${DATAgrb} -s | grep ":SWELL:" | ${WGRIB2} -i ${DATAgrb} -spread ${TEMPDIR}/mxswell.txt
sed -e 's/,/, /g' ${TEMPDIR}/mxswell.txt  > ${TEMPDIR}/mxswell1.txt
awk '{print $3;}' ${TEMPDIR}/mxswell1.txt > ${TEMPDIR}/mxswell2.txt
sort -n ${TEMPDIR}/mxswell2.txt | tail -1 > ${TEMPDIR}/mxswell

swell=$(cat ${TEMPDIR}/mxswell)
swell1=$(echo "$swell*3.280839" | bc)
swell_low=15
swell_extreme=36
swell_int=`echo $swell1 '*1' | bc -l | awk -F '.' '{ print $1; exit; }'` # round the value to be compared
if [ "${swell_int}" == "" ]; then swell_int=0; fi 

# Define the conditions to establish colorscale max & interval.
if [ ${swell_int} -le ${swell_low} ]
then

    swell_max_scale=15 # feet
    swell_incr=1 # scale interval

elif [ ${swell_int} -ge ${swell_extreme} ]
then

    swell_max_scale=56 # feet
    swell_incr=3 # scale interval

else
    swell_max_scale=$swell_int # keep maximum value from data
    swell_incr=2
fi

echo ""
echo "Swell Max value of ${swell1} gives a scale hgt to: ${swell_max_scale}"
echo "Swell Scale Interval: ${swell_incr}"
echo ""
echo ""

rm ${TEMPDIR}/mxswell2.txt ${TEMPDIR}/mxswell1.txt ${TEMPDIR}/mxswell.txt

# -----------------------------------------------------------

echo "WIND - Wind Speed"

${WGRIB2} ${DATAgrb} -s | grep ":WIND:" | ${WGRIB2} -i ${DATAgrb} -spread ${TEMPDIR}/mxwind.txt
sed -e 's/,/, /g' ${TEMPDIR}/mxwind.txt  > ${TEMPDIR}/mxwind1.txt
awk '{print $3;}' ${TEMPDIR}/mxwind1.txt > ${TEMPDIR}/mxwind2.txt
sort -n ${TEMPDIR}/mxwind2.txt | tail -1 > ${TEMPDIR}/mxwind

wndspd=$(cat ${TEMPDIR}/mxwind)
wndspd1=$(echo "$wndspd*1.94384449244" | bc)
wndspd_low=33 
wndspd_mod=75
wndspd_high=105
wndspd_int=`echo $wndspd1 '*1' | bc -l | awk -F '.' '{ print $1; exit; }'`

# Define the conditions to establish colorscale max & interval.

if [ ${wndspd_int} -le ${wndspd_low} ]
then

    wndspd_max_scale=34 # knots
    wndspd_incr=2 # scale interval

elif [ ${wndspd_int} -gt ${wndspd_low} ] && [ ${wndspd_int} -lt ${wndspd_mod} ] # TS winds 
then

    wndspd_max_scale=75 # knots
    wndspd_incr=5 # scale interval

elif [ ${wndspd_int} -ge ${wndspd_mod} ] && [ ${wndspd_int} -lt ${wndspd_high} ] # strong TS/cat1 winds 
then

    wndspd_max_scale=105 # knots
    wndspd_incr=7 # scale interval
   
else
    wndspd_max_scale=${wndspd_int} # keep maximum value from data
    wndspd_incr=10
fi

echo ""
echo "Wndspd Max value of ${wndspd1} gives a scale up to: ${wndspd_max_scale}"
echo "Scale Interval: ${wndspd_incr}"
echo ""

rm ${TEMPDIR}/mxwind2.txt ${TEMPDIR}/mxwind1.txt ${TEMPDIR}/mxwind.txt

# -----------------------------------------------------------

echo "PERPW - Dominant Wave Period"

${WGRIB2} ${DATAgrb} -s | grep ":PERPW:" | ${WGRIB2} -i ${DATAgrb} -spread ${TEMPDIR}/mxper.txt
sed -e 's/,/, /g' ${TEMPDIR}/mxper.txt  > ${TEMPDIR}/mxper1.txt
awk '{print $3;}' ${TEMPDIR}/mxper1.txt > ${TEMPDIR}/mxper2.txt
sort -n ${TEMPDIR}/mxper2.txt | tail -1 > ${TEMPDIR}/mxperiod

period1=$(cat ${TEMPDIR}/mxperiod)

echo ""
echo "Dominant Wave Period max value =  $period1"
echo ""


rm ${TEMPDIR}/mxper2.txt ${TEMPDIR}/mxper1.txt ${TEMPDIR}/mxper.txt

# -----------------------------------------------------------

echo "DSLM - Water Level"

${WGRIB2} ${DATAgrb} -s | grep ":DSLM:" | ${WGRIB2} -i ${DATAgrb} -spread ${TEMPDIR}/mxdslm.txt
sed -e 's/,/, /g' ${TEMPDIR}/mxdslm.txt  > ${TEMPDIR}/mxdslm1.txt
awk '{print $3;}' ${TEMPDIR}/mxdslm1.txt > ${TEMPDIR}/mxdslm2.txt
sort -n ${TEMPDIR}/mxdslm2.txt | tail -1 > ${TEMPDIR}/mxdslm

dslm=$(cat ${TEMPDIR}/mxdslm)
dslm1=$(echo "$dslm*3.280839" | bc)

echo ""
echo "RTOFS Water Level max value =  $dslm1"
echo ""


rm ${TEMPDIR}/mxdslm2.txt ${TEMPDIR}/mxdslm1.txt ${TEMPDIR}/mxdslm.txt

# -----------------------------------------------------------

echo "SPC - Current Speed"

${WGRIB2} ${DATAgrb} -s | grep ":SPC:" | ${WGRIB2} -i ${DATAgrb} -spread ${TEMPDIR}/mxspc.txt
sed -e 's/,/, /g' ${TEMPDIR}/mxspc.txt  > ${TEMPDIR}/mxspc1.txt
awk '{print $3;}' ${TEMPDIR}/mxspc1.txt > ${TEMPDIR}/mxspc2.txt
sort -n ${TEMPDIR}/mxspc2.txt | tail -1 > ${TEMPDIR}/mxspc

spc=$(cat ${TEMPDIR}/mxspc)
spc1=$(echo "$spc*1.94384449244" | bc)

echo ""
echo "RTOFS Current Speed max value =  $spc1"
echo ""

rm ${TEMPDIR}/mxspc2.txt ${TEMPDIR}/mxspc1.txt ${TEMPDIR}/mxspc.txt

# -----------------------------------------------------------

# WLEN not in GRIB2 var list. Wating for offical WMO table updates for WGRIB2
#echo "var10255255 - Wavelength"
#${WGRIB2} ${DATAgrb} -s | grep ":var10255255:" | ${WGRIB2} -i ${DATAgrb} -spread ${TEMPDIR}/mxwlen.txt
#sed -e 's/,/, /g' ${TEMPDIR}/mxwlen.txt  > ${TEMPDIR}/mxwlen1.txt
#awk '{print $3;}' ${TEMPDIR}/mxwlen1.txt > ${TEMPDIR}/mxwlen2.txt
#wlen1=$(sort -n ${TEMPDIR}/mxwlen2.txt | tail -1 > ${TEMPDIR}/mxwlen)
#wlen=$(cat ${TEMPDIR}/mxwlen)
#wlen1=$(echo "$wlen*3.280839" | bc)
#rm ${TEMPDIR}/mxwlen2.txt ${TEMPDIR}/mxwlen1.txt ${TEMPDIR}/mxwlen.txt

# -----------------------------------------------------------
#
# Place final maximum values into one file.

echo "Maximum Hs: $htsgw1" > ${TEMPDIR}/colorscale_range.txt
echo "Maximum Swell Hgt: $swell1" >> ${TEMPDIR}/colorscale_range.txt
echo "Maximum Wave Period: $period1" >> ${TEMPDIR}/colorscale_range.txt
echo "Maximum Wind Speed: ${wndpsd1}" >> ${TEMPDIR}/colorscale_range.txt
echo "Maximum Current Speed: $spc1" >> ${TEMPDIR}/colorscale_range.txt
echo "Maximum Water Level: $dslm1" >> ${TEMPDIR}/colorscale_range.txt
#echo "Maximum Wavelength: $wlen1" >> ${TEMPDIR}/colorscale_range.txt

echo ""
echo "Maximum values for this run have been extracted and can be viewed in ${USHnwps}/grads/etc/${1}/colorscale_range.txt"
echo ""

# ------------------------------------------------------------------------------------------------------------
#
# Adjust GrADS script colorscales based on the lastest model run.

sed -e "s/##MAX_WLEV_FT##/${dslm1}/g" ${TEMPDIR}/wlev_template.gs > ${TEMPDIR}/wlev.gs

sed -e "s/##MAX_HTSGW_FT##/${hs_max_scale}/g" ${TEMPDIR}/htsgw_template.gs > ${TEMPDIR}/htsgw.gs
sed -e "s/##HTSGW_INCR##/${hs_incr}/g" ${TEMPDIR}/htsgw.gs > ${TEMPDIR}/htsgw1.gs
mv ${TEMPDIR}/htsgw1.gs ${TEMPDIR}/htsgw.gs

sed -e "s/##MAX_SWELL_FT##/${swell_max_scale}/g" ${TEMPDIR}/swell_template.gs > ${TEMPDIR}/swell.gs
sed -e "s/##SWELL_INCR##/${swell_incr}/g" ${TEMPDIR}/swell.gs > ${TEMPDIR}/swell1.gs
mv ${TEMPDIR}/swell1.gs ${TEMPDIR}/swell.gs

sed -e "s/##MAX_WNDSPD_KTS##/${wndspd_max_scale}/g" ${TEMPDIR}/wind_template.gs > ${TEMPDIR}/wind.gs
sed -e "s/##WNDSPD_INCR##/${wndspd_incr}/g" ${TEMPDIR}/wind.gs > ${TEMPDIR}/wind1.gs
mv ${TEMPDIR}/wind1.gs ${TEMPDIR}/wind.gs

sed -e "s/##MAX_WNDSPD_KTS##/${wndspd_max_scale}/g" ${TEMPDIR}/wind_template_grib2.gs > ${TEMPDIR}/wind_grib2.gs
sed -e "s/##WNDSPD_INCR##/${wndspd_incr}/g" ${TEMPDIR}/wind_grib2.gs > ${TEMPDIR}/wind1_grib2.gs
mv ${TEMPDIR}/wind1_grib2.gs ${TEMPDIR}/wind_grib2.gs

sed -e "s/##MAX_CUR_KTS##/${spc1}/g" ${TEMPDIR}/cur_template.gs > ${TEMPDIR}/cur.gs
sed -e "s/##MAX_CUR_KTS##/${spc1}/g" ${TEMPDIR}/cur_template_grib2.gs > ${TEMPDIR}/cur_grib2.gs

# ------------------------------------------------------------------------------------------------------------
# 6panel

sed -e "s/##MAX_CUR_KTS##/${spc1}/g" ${TEMPDIR}/6panel_template_grib2.gs > ${TEMPDIR}/6panel_grib2.gs
sed -e "s/##MAX_WNDSPD_KTS##/${wndspd_max_scale}/g" ${TEMPDIR}/6panel_grib2.gs > ${TEMPDIR}/6panel1_grib2.gs
sed -e "s/##MAX_WLEV_FT##/${dslm1}/g" ${TEMPDIR}/6panel1_grib2.gs > ${TEMPDIR}/6panel2_grib2.gs
sed -e "s/##MAX_HTSGW_FT##/${hs_max_scale}/g" ${TEMPDIR}/6panel2_grib2.gs > ${TEMPDIR}/6panel3_grib2.gs
sed -e "s/##MAX_SWELL_FT##/${swell_max_scale}/g" ${TEMPDIR}/6panel3_grib2.gs > ${TEMPDIR}/6panel4_grib2.gs

sed -e "s/##WNDSPD_INCR##/${wndspd_incr}/g" ${TEMPDIR}/6panel4_grib2.gs > ${TEMPDIR}/6panel5_grib2.gs
sed -e "s/##HTSGW_INCR##/${hs_incr}/g" ${TEMPDIR}/6panel5_grib2.gs > ${TEMPDIR}/6panel6_grib2.gs
sed -e "s/##SWELL_INCR##/${swell_incr}/g" ${TEMPDIR}/6panel6_grib2.gs > ${TEMPDIR}/6panel7_grib2.gs

mv ${TEMPDIR}/6panel7_grib2.gs ${TEMPDIR}/6panel_grib2.gs
rm ${TEMPDIR}/6panel6_grib2.gs ${TEMPDIR}/6panel5_grib2.gs  ${TEMPDIR}/6panel4_grib2.gs ${TEMPDIR}/6panel3_grib2.gs ${TEMPDIR}/6panel2_grib2.gs ${TEMPDIR}/6panel1_grib2.gs

sed -e "s/##MAX_CUR_KTS##/${spc1}/g" ${TEMPDIR}/6panel_template.gs > ${TEMPDIR}/6panel.gs
sed -e "s/##MAX_WNDSPD_KTS##/${wndspd_max_scale}/g" ${TEMPDIR}/6panel.gs > ${TEMPDIR}/6panel1.gs
sed -e "s/##MAX_WLEV_FT##/${dslm1}/g" ${TEMPDIR}/6panel1.gs > ${TEMPDIR}/6panel2.gs
sed -e "s/##MAX_HTSGW_FT##/${hs_max_scale}/g" ${TEMPDIR}/6panel2.gs > ${TEMPDIR}/6panel3.gs
sed -e "s/##MAX_SWELL_FT##/${swell_max_scale}/g" ${TEMPDIR}/6panel3.gs > ${TEMPDIR}/6panel4.gs

sed -e "s/##WNDSPD_INCR##/${wndspd_incr}/g" ${TEMPDIR}/6panel4.gs > ${TEMPDIR}/6panel5.gs
sed -e "s/##HTSGW_INCR##/${hs_incr}/g" ${TEMPDIR}/6panel5.gs > ${TEMPDIR}/6panel6.gs
sed -e "s/##SWELL_INCR##/${swell_incr}/g" ${TEMPDIR}/6panel6.gs > ${TEMPDIR}/6panel7.gs

mv ${TEMPDIR}/6panel7.gs ${TEMPDIR}/6panel.gs
rm ${TEMPDIR}/6panel6.gs ${TEMPDIR}/6panel5.gs ${TEMPDIR}/6panel4.gs ${TEMPDIR}/6panel3.gs ${TEMPDIR}/6panel2.gs ${TEMPDIR}/6panel1.gs

#-------------------------------------------------------------------------------------------------------------
# 4 panel

sed -e "s/##MAX_WNDSPD_KTS##/${wndspd_max_scale}/g" ${TEMPDIR}/4panel_template_grib2.gs > ${TEMPDIR}/4panel_grib2.gs
sed -e "s/##MAX_HTSGW_FT##/${hs_max_scale}/g" ${TEMPDIR}/4panel_grib2.gs > ${TEMPDIR}/4panel1_grib2.gs
sed -e "s/##MAX_SWELL_FT##/${swell_max_scale}/g" ${TEMPDIR}/4panel1_grib2.gs > ${TEMPDIR}/4panel2_grib2.gs

sed -e "s/##WNDSPD_INCR##/${wndspd_incr}/g" ${TEMPDIR}/4panel2_grib2.gs > ${TEMPDIR}/4panel3_grib2.gs
sed -e "s/##HTSGW_INCR##/${hs_incr}/g" ${TEMPDIR}/4panel3_grib2.gs > ${TEMPDIR}/4panel4_grib2.gs
sed -e "s/##SWELL_INCR##/${swell_incr}/g" ${TEMPDIR}/4panel4_grib2.gs > ${TEMPDIR}/4panel5_grib2.gs

mv ${TEMPDIR}/4panel5_grib2.gs ${TEMPDIR}/4panel_grib2.gs
rm ${TEMPDIR}/4panel4_grib2.gs ${TEMPDIR}/4panel3_grib2.gs  ${TEMPDIR}/4panel2_grib2.gs ${TEMPDIR}/4panel1_grib2.gs 

sed -e "s/##MAX_WNDSPD_KTS##/${wndspd_max_scale}/g" ${TEMPDIR}/4panel_template.gs > ${TEMPDIR}/4panel.gs
sed -e "s/##MAX_HTSGW_FT##/${hs_max_scale}/g" ${TEMPDIR}/4panel.gs > ${TEMPDIR}/4panel1.gs
sed -e "s/##MAX_SWELL_FT##/${swell_max_scale}/g" ${TEMPDIR}/4panel1.gs > ${TEMPDIR}/4panel2.gs

sed -e "s/##WNDSPD_INCR##/${wndspd_incr}/g" ${TEMPDIR}/4panel2.gs > ${TEMPDIR}/4panel3.gs
sed -e "s/##HTSGW_INCR##/${hs_incr}/g" ${TEMPDIR}/4panel3.gs > ${TEMPDIR}/4panel4.gs
sed -e "s/##SWELL_INCR##/${swell_incr}/g" ${TEMPDIR}/4panel4.gs > ${TEMPDIR}/4panel5.gs

mv ${TEMPDIR}/4panel5.gs ${TEMPDIR}/4panel.gs
rm ${TEMPDIR}/4panel4.gs ${TEMPDIR}/4panel3.gs  ${TEMPDIR}/4panel2.gs ${TEMPDIR}/4panel1.gs

# ------------------------------------------------------------------------------------------------------------

echo "GrADS .gs scripts have been adjusted in ${TEMPDIR}: wlev.gs, htsgw.gs, swell.gs, period.gs, wind.gs, wind_grib2.gs,cur_grib2.gs, 6/4panel_grib2.gs and cur.gs"
echo ""
echo ""

exit 0
# ----------------------------------------------------------- 
# ******************************* 
# ********* End of File ********* 
# ******************************* 

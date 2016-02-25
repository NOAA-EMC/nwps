#!/bin/bash
# -----------------------------------------------------------
# UNIX Shell Script
# Tested Operating System(s): RHEL 5/6
# Shell Used: BASH shell
# Original Author(s): Alex Gibbs 
# File Creation Date: 12/10/2013
# Date Last Modified: 12/10/2013
#
# Version control: 1.00
#
# Support Team:
#
# Contributors:
#
# -----------------------------------------------------------
# ------------- Program Description and Details -------------
# -----------------------------------------------------------
#
# This program assumes the rip current program has been installed
# and run. The probability files from the rip current model should
# be in place before running this plotting script. If not, view
# the online documentation for further instructions at:
#
# innovation.srh.noaa.gov/nwps/nwpsmanual.php/rip_current_program
#
# To execute:                         ARG1 ARG2 ARG3 ARG4
# $RUNdir/plot_rip_probs.sh MFL CG2 5 18
#
# Arguments=4:
#
# 1. SITEID: MFL, MHX, EKA etc.
# 2. Domain you would like to plot: CG2, CG3, CG4 etc.
# 3. contour: 5m # for 5m contour
# 4. Cycle: 18 or 06 (model cycle time)
# -----------------------------------------------------------

#strip file
sid=${1}
CGnumber=${2}
contour=${3}
cycle=${4}

#change to working dir...
cd ${DATAdir}/output/netCdf/rip_current/data/${contour}

grep "^INPGRID WIND" ${DATAdir}/run/input${CGnumber} > ${TMPdir}/datetime_ripprob
awk '{print $11;}' ${TMPdir}/datetime_ripprob > ${TMPdir}/init_ripprob

cut -c 1-4 ${TMPdir}/init_ripprob > ${TMPdir}/year
cut -c 5-6 ${TMPdir}/init_ripprob > ${TMPdir}/mon
cut -c 7-8 ${TMPdir}/init_ripprob > ${TMPdir}/day
cut -c 10-11 ${TMPdir}/init_ripprob > ${TMPdir}/hh
cut -c 12-13 ${TMPdir}/init_ripprob > ${TMPdir}/mm

yyyy=$(cat ${TMPdir}/year)
mon=$(cat ${TMPdir}/mon)
dd=$(cat ${TMPdir}/day)
hh=$(cat ${TMPdir}/hh)
mm=$(cat ${TMPdir}/mm)


time_stamp="${yyyy}${mon}${dd}"
echo ${time_stamp}
echo ${contour}_${CGnumber}_${cycle}_${time_stamp}_prob.txt_${sid}

if [ -e ${contour}_${CGnumber}_${cycle}_${time_stamp}_prob.txt_${sid} ]
then

    sed -e "1,6 d" ${contour}_${CGnumber}_${cycle}_${time_stamp}_prob.txt_${sid} > ${TMPdir}/noheader_ripprob
    prob=$(awk '{print $4;}' ${TMPdir}/noheader_ripprob > ${TMPdir}/prob_ripprob)
    hs=$(awk '{print $5;}' ${TMPdir}/noheader_ripprob > ${TMPdir}/hs_ripprob)
    period=$(awk '{print $6;}' ${TMPdir}/noheader_ripprob > ${TMPdir}/tp_ripprob)
    tide=$(awk '{print $8;}' ${TMPdir}/noheader_ripprob > ${TMPdir}/tide_ripprob)

    
    sed -i 's/$/,/g' ${TMPdir}/prob_ripprob
    sed -i '$s/,$/;/' ${TMPdir}/prob_ripprob
    sed -i 's/$/,/g' ${TMPdir}/hs_ripprob
    sed -i '$s/,$/;/' ${TMPdir}/hs_ripprob
    sed -i 's/$/,/g' ${TMPdir}/tp_ripprob
    sed -i '$s/,$/;/' ${TMPdir}/tp_ripprob
    sed -i 's/$/,/g' ${TMPdir}/tide_ripprob
    sed -i '$s/,$/;/' ${TMPdir}/tide_ripprob

    echo "prob =" >> final_netcdf_template
    cat  ${TMPdir}/prob_ripprob >> final_netcdf_template
  
    echo "hsig =" >> final_netcdf_template
    cat  ${TMPdir}/hs_ripprob >> final_netcdf_template

    echo "period =" >> final_netcdf_template
    cat  ${TMPdir}/tp_ripprob >> final_netcdf_template

    echo "tide =" >> final_netcdf_template
    cat  ${TMPdir}/tide_ripprob >> final_netcdf_template

    echo "}" >> final_netcdf_template

    /usr/local/nwps/lib64/netcdf/bin/ncgen -o rip.nc final_netcdf_template

    time_str="${yyyy}${mon}${dd}_${hh}${mm}"
    epoch_time=$(echo ${time_str} | awk -F: '{ print mktime($1 $2 $3 $4 $5 $6) }')
    month=$(echo ${epoch_time} | awk '{ print strftime("%b", $1) }' | tr [:upper:] [:lower:])

    echo "DSET rip.nc" > ripprob.ctl
    echo "DTYPE netcdf" >> ripprob.ctl
    echo "TITLE Rip Current Control File" >> ripprob.ctl
    echo "UNDEF -9.99e+08f" >> ripprob.ctl
    echo "XDEF 1 levels 1" >> ripprob.ctl
    echo "YDEF 1 levels 1" >> ripprob.ctl
    echo "ZDEF 1 levels 1" >> ripprob.ctl
    echo "TDEF 35 linear ${cycle}z${dd}${month}${yyyy} 3hr" >> ripprob.ctl
    echo "VARS 4" >> ripprob.ctl
    echo "prob=>prob 0 t,z,y,x rip current prob (%)" >> ripprob.ctl
    echo "hsig=>hsig 0 t,z,y,x total hsig (m)" >> ripprob.ctl
    echo "period=>period 0 t,z,y,x total dominant wave period (s)" >> ripprob.ctl
    echo "tide=>tide 0 t,z,y,x total water level (m)" >> ripprob.ctl
    echo "ENDVARS" >> ripprob.ctl

else
    echo "The ${contour}_${CGnumber}_${cycle}_${time_stamp}_prob.txt_${sid} does not exist" > ${LOGdir}/rip_plotting.log
fi

exit 0

# *******************************
# ********* End of File *********
# *******************************


#!/bin/bash
# -----------------------------------------------------------
# UNIX Shell Script
# Tested Operating System(s): RHEL 5, 6
# Tested Run Level(s): 3, 5
# Shell Used: BASH shell
# Original Author(s): Roberto.Padilla@noaa.gov
# Base on make_estofs from Douglas Gaer
# File Creation Date: 12/15/2013
# Date Last Modified: 
#
# Version control: 1.00
#
# Support Team:
#
# Contributors:
#               
# -----------------------------------------------------------
# ------------- Program Description and Details -------------
#
# Script used to make P-Surge init files all WFOs. 
# This is done by identifying which WFO domains from the bulk list 
#
#    ${NWPSdir}/fix/configs_psurge/wfolist_psurge.dat
#
# have P-Surge data to extract (at the operational resolution), 
# based on a quick scan low-resolution extraction of their contents. 
# Assume the worst-case scenario of 10% exceedance for this (largest 
# footprint).
#
# Data is first extracted to ascii at a low resolution using PSURGE2NWPS,
# and atfer which the program ${NWPSdir}/exec/psurge_identify.exe 
# analyses the content and outputs the selected domains in:
#
#    wfolist_psurge_final.dat
#
# -----------------------------------------------------------
if [ "${USHnwps}" == "" ]
    then 
    echo "ERROR - Your USHnwps variable is not set"
    exit 1
fi
PSURGE2NWPS=${EXECnwps}/psurge2nwps_64
echo "====== Running make_psurge_identify.sh ======================="
echo "A low-resolution quick-scan to identify WFO domains to extract"
echo "=============================================================="
echo "P-Surge extraction domains: ${FIXnwps}/configs_psurge/wfolist_psurge.dat"
cat ${FIXnwps}/configs_psurge/wfolist_psurge.dat

echo ""
echo "Running PSURGE2NWPS to do a coarse ASCII (*.dat) extraction from *.flt files..."
rm -f wfolist_psurge_final.dat
touch wfolist_psurge_final.dat
date
pwd

# Process WFOs from the list ${FIXnwps}/configs_psurge/wfolist_psurge.dat
while read line
do
   DOMAIN=`echo $line | awk -F" " '{print $1}'`
   #Npx=`echo $line | awk -F" " '{print $2}'`
   #Npy=`echo $line | awk -F" " '{print $3}'`
   #echo "Domain: $DOMAIN  Nx: $Npx   Ny: $Npy"
   echo ""
   echo "Domain: $DOMAIN"
   if [ "${DOMAIN}" != "" ] 
   then
      WFO=$(echo ${DOMAIN} | tr [:lower:] [:upper:])
      wfo=$(echo ${DOMAIN} | tr [:upper:] [:lower:])
   fi

   mkdir -p ${RUNdir}/${DOMAIN}_hourly
   cp *.flt *.ave *.txt *.hdr ${RUNdir}/${DOMAIN}_hourly/
   cd ${RUNdir}/${DOMAIN}_hourly/
   ##echo "========  RUNNING PSURGE2NWPS.C ======="
   x=1
   for file in `ls *.flt` ; do
     echo "Processing ${file}"
      if [[ $x == "1" ]]; then
        #echo $file
        #dateinname=$(echo $file | egrep -o '[[:digit:]]{10}' | head -n1)  this also works
        dateinname=${file:8:10}
        #Npx=${file:22:3}
        #Npy=${file:31:3}
        echo dateinname: $dateinname
        #fileout="psurge_${dateinname}_${wfo}_e${EXCEED}.wlev"
        #${RM} ${fileout}
        ##echo $fileout
      fi
      x=$(( $x + 1 ))
     #---- Call PSURGE2NWPS executable to do coarse data extraction --------
     # 
     # ${PSURGE2NWPS} $file -w $DOMAIN -d ../data -o 2 -s 0.1
     # 
     # Options used:
     # * ( ) Nearest neighbor (quickest); (-o 2) ASCII file (.dat) with z values.
     # * With "-s 0.1" spacing of 0.1 deg is specified this is low resolution
     #   only to identify which wfos has valid surge data. This gave the values 
     #   for nx and ny in the file "wfolist_psurge.dat", though they are not used.
     #----------------------------------------------------------------------
     #${PSURGE2NWPS} $file -w $DOMAIN -d ../data -o 2 -s 0.1
     ${PSURGE2NWPS} $file -w $DOMAIN -d ${FIXnwps}/configs_psurge -o 2 -s 0.1

     # Diagnostic method (nearest neighbor, feet, output format is CSV)
     # ${PSURGE2NWPS} $file -w PHI -d ../data -o 3
     # Diagnostic method (bi-linear interpolation, feet, output format is CSV)
     # ${PSURGE2NWPS} $file -w PHI -d ../data -o 3 -i
   done

   echo ""
   echo "Running psurge_identify.exe to select domains for final extraction..."
   #Reading Npx, Npy from filename.
   pickOne=$(basename `ls -t psurge*$wfo*e10.dat | head -1`)
   #psurge_2004091800_wfo_Npx-10118_Npy-2521_135_f078_e10.dat
   split=(${pickOne//_/ })
   findx=${split[3]}
   splitx=(${findx//-/ })
   Npx=${splitx[0]}
   findy=${split[4]}
   splity=(${findy//-/ })
   Npy=${splity[0]}
   echo " WFO: $wfo,     Npx: $Npx   ,   Npy: $Npy"

   ${EXECnwps}/psurge_identify.exe ${wfo} ${Npx} ${Npy}
   rm  -f ${RUNdir}/*${wfo}*.dat

done < ${FIXnwps}/configs_psurge/wfolist_psurge.dat

#    An alternate form for the degrib call.
#    Less efficient, but we have the message number.
#for (( c=0; c<13; c++ )) ; do
#  ${DEGRIB} Sandy_Adv27_2012102900_e${EXCEED}_incr.agl.grb -C -Flt -msg ${c} -nameStyle "%e_%lv_%p_e${EXCEED}.txt"
#  ${RM} *.ave *.hdr
#done
echo ""
echo "Preprocessing complete" | tee -a ${LOGfile}
echo "WFO domains selected for final detailed extraction, from ${RUNdir}/wfolist_psurge_final.dat:"
cat ../wfolist_psurge_final.dat
cd ${myPWD}
echo "====== Exiting make_psurge_identify.sh =======================" | tee -a ${LOGfile}
date
echo ""
exit 0
# -----------------------------------------------------------
# *******************************
# ********* End of File *********
# *******************************

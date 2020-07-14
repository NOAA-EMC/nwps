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
# -----------------------------------------------------------
#
# Script used to extract high-res P-Surge water level fields 
# for a given WFO using Psurge2Nwps, which has the following 
# functionality: 
#
#$ ./psurge2nwps -H
#
#Please provide a list of wfo's and/or the wfo directory
#usage: ./psurge2nwps <flt file> [options]
#
# -H       = Prints this help
# -V       = Version of the program
#
# -d [arg] = Directory containing [wfo]_ncep_config.sh files
# -i       = [Optional] Use bi-linear interpolation (vs nearest neighbor)
# -m       = [Optional] Output meters (vs feet)
# -o [arg] = [Optional] Output format (default 1)
#           [1] = Binary 4 byte float file (.dat) with z values.
#            2 = ASCII file (.dat) with z values.
#            3 = ASCII file (.csv) with lon, lat, z values.
#            4 = ASCII file (.csv) with lon, lat, x, y, z values.
# -s [arg] = [Optional] spacing for the wfo grid (default = 0.0045 degree)
# -w [arg] = WFO(s) to convert.sh file(s) containing the NWPS extents
#
#Assumptions:
#  1) mapfile is same as .flt except with a .txt extension.
#  2) Name of .flt file is of form *_[asof]_[proj. time]_[exceed].*
#     e.g. SURGE10_asof_006_e10.flt
#
#Example: ./psurge2nwps foo.flt -w mfl,mlb -d ./wfoFiles
#
# -----------------------------------------------------------
#!/bin/bash
# NOTE: Data is processed on the server in UTC
export TZ=UTC
set -xa
if [ "${USHnwps}" == "" ]
    then 
    echo "ERROR - Your USHnwps variable is not set"
    exit 1
fi

echo "------- Running make_psurge_final.sh -------"
export DEGRIB=${EXECnwps}/degrib
#export DEGRIB=/nwprod2/grib_util.v1.0.0/exec/degrib2
PSURGE2NWPS=${EXECnwps}/psurge2nwps

DOMAIN="${1}"
####Npx="${2}"
####Npy="${3}"
TS_f="${2}"

cd ${RUNdir}
#mkdir -p ${RUNdir}/${DOMAIN}
#cp exceedances ${RUNdir}/${DOMAIN}/
#cp *.flt ${RUNdir}/${DOMAIN}/
#cp *${DOMAIN}*.dat ${RUNdir}/${DOMAIN}/
#cd ${RUNdir}/${DOMAIN}

echo "======== Start PSURGE2NWPS.C ======="
WFOLIST=()
##while read line
##do
##   DOMAIN=`echo $line | awk -F" " '{print $1}'`
##   Npx=`echo $line | awk -F" " '{print $2}'`
##   Npy=`echo $line | awk -F" " '{print $3}'`

   if [ "${DOMAIN}" != "" ] 
   then
      WFO=$(echo ${DOMAIN} | tr [:lower:] [:upper:])
      wfo=$(echo ${DOMAIN} | tr [:upper:] [:lower:])
   fi

# Commented out so that domains are not processed in subdirectories
#   mkdir -p ${RUNdir}/${DOMAIN}_hourly
#   cp *.flt *.ave *.txt *.hdr ${RUNdir}/${DOMAIN}_hourly/
#   cd ${RUNdir}/${DOMAIN}_hourly/

   source ${FIXnwps}/configs_psurge/${wfo}_ncep_config.sh
   ESTO=${ESTOFSDOMAIN}
   OIFS=$IFS                   # store old IFS in buffer
   #IFS='-'                     # set IFS to '-'
   i=0

   for dati in ${ESTO[@]}    # traverse through elements
   do
     #echo $dati
     DOM[i]="$dati"
     echo "DOM[$i]:${DOM[$i]}"
     i=$(( $i + 1 ))
   done

   IFS=$OIFS                   # reset IFS to default (whitespace)
#   PS[0]="${Npx}"
#   PS[1]="${Npy}"
#   Mshx=$((${Npx}-1))
#   Mshy=$((${Npy}-1))
##   PS[2]="0.0045"
##   PS[3]="0.0045"
#   PS[2]="0.0135"
#   PS[3]="0.0135"
#   echo "Points x,y: ${PS[0]} ${PS[1]}"
#   PSURGEDOMAIN="${DOM[0]} ${DOM[1]} ${DOM[2]} $Mshx $Mshy ${PS[2]} ${PS[3]}"
#   echo "PSURGEDOMAIN:${PSURGEDOMAIN}"
#   echo "PSURGEDOMAIN:${PSURGEDOMAIN}" > psurge_waterlevel_domain_${wfo}.txt

   WFOLIST+=" "
   WFOLIST+="${wfo}"

   xx=1
while read line
do
   EXCEED=`echo $line | awk -F" " '{print $1}'`
   #ls -lt *e${EXCEED}*.flt
   for file in `ls *e${EXCEED}*.flt` ; do
      echo "Processing ${file} for ${wfo} for ${EXCEED}"
      #dateinname=$(echo $file | egrep -o '[[:digit:]]{10}' | head -n1)  this also works
      dateinname=${file:8:10}
      #hourinname=${file:8:10}
     if [[ $xx == "1" ]]; then
        #dateinname=$(echo $file | egrep -o '[[:digit:]]{10}' | head -n1)  this also works
        dateinname_t=${file:8:10}
        yyyymmdd_t=$(echo ${dateinname_t:0:8})
        HH_t=$(echo ${dateinname_t:8:2})
        space=" "
        DATE3="${yyyymmdd_t}${space}${HH_t}"
        epoc_time_t=$(date -d "$DATE3" +%s)
#       the fields are produce one time step later, we want to produce a field for the 
#       validate date (initial date), that is one time step before
        epoc_time_ini=$(echo "${epoc_time_t} - ${TS_f}" | bc )
        dateinname_t=$(date -d @${epoc_time_ini} +"%Y%m%d%T" )
        dateinname_ini=${dateinname_t:0:8}
        yyyymmdd_ini=${dateinname_t:0:8}
        HH_ini=${dateinname_t:8:2}

        echo ${epoc_time_ini} > psurge_waterlevel_start_time.txt
        xx=$(( $xx + 1 ))
     fi
     # (-i) Bi-Linear Interpolation (-i);  (-o 2) ASCII file (.dat) with z values.
     #${PSURGE2NWPS} $file -w $DOMAIN -d ../data -i -o 2

     # ( ) Nearest neighbor ;  (-o 2) ASCII file (.dat) with z values.
     #${PSURGE2NWPS} $file -w $DOMAIN -d ../data -o 2 
     ${PSURGE2NWPS} $file -w $DOMAIN -d ${FIXnwps}/configs_psurge  -o 2 -s 0.0135

     #${PSURGE2NWPS} $file -w $DOMAIN -d ${FIXnwps} -o 2 -s 0.0135
     # Diagnostic method (nearest neighbor, feet, output format is CSV)
     # ${PSURGE2NWPS} $file -w PHI -d ../data -o 3
  
     # Diagnostic method (bi-linear interpolation, feet, output format is CSV)
     # ${PSURGE2NWPS} $file -w PHI -d ../data -o 3 -i

     #   in the fortran progam psoutTOnwps_ver03.f surge levels are converted from feet to meters
     yyyymmdd=$(echo ${dateinname:0:8})
     hh=$(echo ${dateinname:8:2})
     space=" "
     DATE3="${yyyymmdd}${space}${hh}"
     epoc_time=$(date -d "$DATE3" +%s)
     #echo "The UNIX time for ${dateinname} is  epoc_time: ${epoc_time}"
     
     #Reading the vdatum to change the one from Psurge
     grep "$WFO" ${FIXnwps}/configs_psurge/vdatum.txt > $WFO.datum
     Vcorrection=$(awk '{print $3;}' ${WFO}.datum)
     echo "Correction for $WFO : ${Vcorrection} m"
        echo " =========== Do we have the dimensions for the WFO at this step? ============="
     #ls -lt psurge*${wfo}*e${EXCEED}.dat
     # finding the WFO dimensions from Psurge files generated by  exec/psurge2nwps
     pickOne=$(basename `ls -t psurge*$wfo*e${EXCEED}.dat | head -1`)
     #psurge_2004091800_wfo_Npx-10118_Npy-2521_135_f078_e10.dat
     split=(${pickOne//_/ })
     findx=${split[3]}
     splitx=(${findx//-/ })
     NPX=${splitx[0]}
     findy=${split[4]}
     splity=(${findy//-/ })
     NPY=${splity[0]}
     echo " WFO: $wfo,  NPX: $NPX   ,   NPY: $NPY"
     echo "             Npx: $Npx   ,   Npy: $Npy"
     Npx=$NPX
     Npy=$NPY
     if [[ $xx == "2" ]]; then
        PS[0]="${Npx}"
        PS[1]="${Npy}"
        Mshx=$((${Npx}-1))
        Mshy=$((${Npy}-1))
#       PS[2]="0.0045"
#       PS[3]="0.0045"
        PS[2]="0.0135"
        PS[3]="0.0135"
        echo "Points x,y: ${PS[0]} ${PS[1]}"
        PSURGEDOMAIN="${DOM[0]} ${DOM[1]} ${DOM[2]} $Mshx $Mshy ${PS[2]} ${PS[3]}"
        echo "PSURGEDOMAIN:${PSURGEDOMAIN}"
        echo "PSURGEDOMAIN:${PSURGEDOMAIN}" > psurge_waterlevel_domain_${wfo}.txt
        xx=$(( $xx + 1 ))
     fi
     echo "psoutTOnwps.exe ${wfo} ${Npx} ${Npy} ${dateinname_ini} ${EXCEED} ${HH_ini} ${epoc_time_ini}"
     ${EXECnwps}/psoutTOnwps.exe ${wfo} ${Npx} ${Npy} ${dateinname_ini} ${EXCEED} ${HH_ini} ${epoc_time_ini} ${Vcorrection}
     #mv psurge*${wfo}*e${EXCEED}.dat ${COMOUT}/${OFSTYPE}
     rm psurge*${wfo}*e${EXCEED}.dat
   done
done < ${RUNdir}/exceedances

# Since there is no f000 field, we copy the f001 field to create f000.
while read line
do
   EXCEED=`echo $line | awk -F" " '{print $1}'`

   file="wave_psurge_waterlevel_${epoc_time_ini}_${yyyymmdd_ini}_${HH_ini}_${wfo}_e${EXCEED}_f001.dat"
   xfile="wave_psurge_waterlevel_${epoc_time_ini}_${yyyymmdd_ini}_${HH_ini}_${wfo}_e${EXCEED}_f000.dat"
   echo "COPYING"
   echo "${file}"
   echo "copied to"
   echo "${xfile}"
   cp ${file} ${xfile}
done < ${RUNdir}/exceedances

while read line
do
   EXCEED=`echo $line | awk -F" " '{print $1}'`

   #echo "The UNIX time for ${yyyymmddhh} is epoc_time: ${epoc_time}"
   file="wave_psurge_waterlevel_${epoc_time_ini}_${yyyymmdd_ini}_${HH_ini}_${wfo}_e${EXCEED}_f*.dat"
   filetar="wave_psurge_waterlevel_${epoc_time_ini}_${yyyymmdd_ini}_${HH_ini}_${wfo}_e${EXCEED}.dat.tar.gz"
   if [ -e "${filetar}" ]
   then
     echo "Deleting file ${filetar}"
     rm  ${filetar}
   fi

   echo "Creating tar file..."
   tar cvfz ${filetar} ${file} psurge_waterlevel_domain_${wfo}.txt psurge_waterlevel_start_time.txt

   echo "Moving the PSurge files to ${COMOUT}/${OFSTYPE}..."
   mkdir -p ${COMOUT}/${OFSTYPE}/${wfo}_output/
   cp psurge_waterlevel_domain_${wfo}.txt ${COMOUT}/${OFSTYPE}/${wfo}_output/
   cp psurge_waterlevel_start_time.txt ${COMOUT}/${OFSTYPE}/${wfo}_output/
   mv ${file} ${COMOUT}/${OFSTYPE}/${wfo}_output/
   mv ${filetar} ${COMOUT}/${OFSTYPE}/${wfo}_output/

   #sh ${USHnwps}/scp_psurge_out_to_polar.sh ${wfo} ${yyyymmdd_ini}
   #rm ${file}

done < ${RUNdir}/exceedances
cd ${RUNdir}

echo "Clipping of PSurge fields for NWPS completed" | tee -a ${LOGfile}
date
echo "Exiting..." | tee -a ${LOGfile}
exit 0
# -----------------------------------------------------------
# *******************************
# ********* End of File *********
# *******************************

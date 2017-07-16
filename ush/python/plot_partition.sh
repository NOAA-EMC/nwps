#!/bin/bash
# ----------------------------------------------------------- 
# UNIX Shell Script
# Tested Operating System(s): RHEL 5
# Tested Run Level(s): 3, 5
# Shell Used: BASH shell
# Original Author(s): Roberto.Padilla@noaa.gov
#                  
# File Creation Date: 07/15/2009
# Date Last Modified: 06/26/2014
#
# Version control: 1.38
#
# Support Team:
#
# Contributors: Douglas.Gaer@noaa.gov
# ----------------------------------------------------------- 
# ------------- Program Description and Details ------------- 
# ----------------------------------------------------------- 
# GRADS processing script used to create output images
# for wave-partition plots.
#
# ----------------------------------------------------------- 
declare -a LON_ARR
declare -a LAT_ARR

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

# The SITE ID is set in NWPS config but can be specified on the command line
if [ "$1" != "" ]; then SITEID="$1"; fi

if [ "${SITEID}" == "" ]
    then
    SITEID="default"
fi
SITEID=$(echo ${SITEID} | tr [:upper:] [:lower:])
REGION=$(echo ${REGION} | tr [:upper:] [:lower:])

DimTpArray=51    # Elements in Tp array: 51 from 0.0 to 25 s
DeltaTp=0.5      # Delta Tp:0.5
NUMPART=10       # There are 10 partitions

# Check for hotstart
HASHOTSTART=$(cat ${RUNdir}/hotstart.flag)
if [ "${HASHOTSTART}" == "" ]; then HASHOTSTART="FALSE"; fi

echo "Starting GRAD plotting script for partitioning output"
if [ "${HASHOTSTART}" == "TRUE" ] 
    then
    echo "HOTSTART was used for this run, will include hours 0-12"
else
    echo "HOTSTART was not used for this run, will skip hours 0-12"
fi

echo "This script is ran following successful run during Graphics post-processing"
echo "SITE ID: ${SITEID}"

PYTHdir="${USHnwps}/python"
ETCdir="${USHnwps}/python/etc"
GRADSOUTPUTdir="${OUTPUTdir}/figures"
export USHlocal=${USHnwps}
if [ ! -e ${GRADSOUTPUTdir} ]; then mkdir -p ${GRADSOUTPUTdir}; fi

echo $$ > ${TMPdir}/${USERNAME}/nwps/7785_plot_partition_sh.pid

# Read our SWAN configuration for this run
export NESTS="NO"
hasnest=$(cat ${RUNdir}/nests.flag)
if [ "${hasnest}" == "TRUE" ]; then export NESTS="YES"; fi
SWANPARMS=`perl -I${USHnwps} -I${RUNdir} ${PYTHdir}/get_partition_parms.pl`
echo ${SWANPARMS}
# Process all CGs
for parm in ${SWANPARMS}
do
   CGNUM=$(echo ${parm} | awk -F, '{ print $1 }' | cut -b3)
   LENGTHTIMESTEP=$(echo ${parm} | awk -F, '{ print $2 }')
   SWANFCSTLENGTH=$(echo ${parm} | awk -F, '{ print $3 }')
   NUMOUTPUTPRT=$(echo ${parm} | awk -F, '{ print $4 }')
   PARTITIONNAMES=$(echo ${parm} | awk -F, '{ print $5 }' | sed s'/|/ /'g)
   PARTITIONLONS=$(echo ${parm} | awk -F, '{ print $6 }' | sed s'/|/ /'g)
   PARTITIONLATS=$(echo ${parm} | awk -F, '{ print $7 }' | sed s'/|/ /'g)
   PRTDIR="${OUTPUTdir}/partition/CG${CGNUM}"
   echo "Processing partition for CG${CGNUM}"
   echo "Partition output dir = ${PRTDIR}"
   if [ ! -e ${PRTDIR} ]
   then 
      echo "ERROR - No PARTITION output DIR ${PRTDIR}"
      echo "ERROR - Not creating any partition plots"
      export err=1; err_chk
   fi
   echo "CG Number = ${CGNUM}"
   echo "LENGTHTIMESTEP = ${LENGTHTIMESTEP}"
   echo "SWANFCSTLENGTH = ${SWANFCSTLENGTH}"
   echo "NUMOFOUTPUTPART = $NUMOUTPUTPRT"
   echo "PARTITIONNAMES = $PARTITIONNAMES"
   echo "PRTLOCLONS = $PARTITIONLONS"
   echo "PRTLOCLATS = $PARTITIONLATS"
   LON_ARR=(`echo $PARTITIONLONS | awk 'BEGIN{FS=" "}{for (i=1; i<=NF; i++) print $i}'`)
   LAT_ARR=(`echo $PARTITIONLATS | awk 'BEGIN{FS=" "}{for (i=1; i<=NF; i++) print $i}'`)
   OUTPUTDT=$(echo "${LENGTHTIMESTEP}")
   TEMPDIR=${VARdir}/${SITEID}.tmp/CG${CGNUM}/partition
   mkdir -p ${TEMPDIR}
   echo "Writing all temp files to ${TEMPDIR}"
   GRAPHICSdir="${GRADSOUTPUTdir}/${SITEID}/partition/CG${CGNUM}"
   mkdir -p ${GRAPHICSdir}
    cp -f ${USHnwps}/python/partition.py ${TEMPDIR}/.
   # Cleaning any old graphics
   #find ${TEMPDIR} -name "*.png" -print | xargs rm -f
   #find ${GRAPHICSdir} -name "*.png" -print | xargs rm -f  

   echo "Copying LOGO from ${ETCdir}/*.gif files"
   cp -f ${ETCdir}/default/*.gif ${TEMPDIR}/.
   cp -f ${ETCdir}/default/*.png ${TEMPDIR}/.

   cd ${PRTDIR}
   files=$(ls -1 --color=none *.bin)
   ls -1 --color=none *.bin
   cd ${TEMPDIR}
   ls -lt
   for file in ${files}
   do
      echo "Plotting partition for ${file}"
      LOCATION=$(echo ${file} | awk -F. '{ print $2 }')
      np=0
      set -- $PARTITIONLONS
      for name in ${PARTITIONNAMES[@]}
      do
         if [ ${name} == ${LOCATION} ];then
            LONGITUDE=${LON_ARR[$np]}
            LATITUDE=${LAT_ARR[$np]}
         fi
         np=$(( $np + 1 ))
      done
      YY=$(echo ${file} | awk -F. '{ print $5 }' | cut -b3-4)
      MM=$(echo ${file} | awk -F. '{ print $6 }' | cut -b3-4)
      DD=$(echo ${file} | awk -F. '{ print $7 }' | cut -b3-4)
      HH=$(echo ${file} | awk -F. '{ print $8 }' | cut -b3-4)
      MIN="00"
      YPREFIX=$(date +%Y | cut -b1-2)
      CC=$(echo "${YPREFIX}")
      YYYY=$(echo "${YPREFIX}${YY}")
      time_str="${YYYY} ${MM} ${DD} ${HH} ${MIN} 00"
      epoch_time=$(echo ${time_str} | awk -F: '{ print mktime($1 $2 $3 $4 $5 $6) }')
      month=$(echo ${epoch_time} | awk '{ print strftime("%b", $1) }' | tr [:upper:] [:lower:])
      cp -fpv ${PRTDIR}/${file} ${TEMPDIR}/partition.bin
      DSET="partition.bin"
      TITLE="PRT CG${CGNUM} Control File"
      UNDEF="-99.99"
      NUMTIMES=$(echo "scale=0; (${SWANFCSTLENGTH}/${LENGTHTIMESTEP})+1" | bc)
      TDEF=$(echo "scale=0; (${SWANFCSTLENGTH}/${LENGTHTIMESTEP})+1" | bc)
      XDEF=$(echo "${TDEF} linear 0 ${LENGTHTIMESTEP}") 
      #There are 51 {DimTpArray} periods
      YDEF=$(echo "${DimTpArray} linear 0 ${DeltaTp}") 
      ZDEF=$(echo "${NUMPART} linear 1 1")
      U_COMP=$(echo "${NUMPART} ${NUMTIMES}  ${DimTpArray}  u_Partition ")
      V_COMP=$(echo "${NUMPART} ${NUMTIMES}  ${DimTpArray}  v_Partition")
      TDEF=$(echo "${TDEF} linear ${HH}z${DD}${month}${YYYY} ${LENGTHTIMESTEP}hr ${YYYY} ${MM} ${DD} ${HH}")
      HHINI=$(echo "HHINI=${HH}")
      DDINI=$(echo "DDINI=${DD}")
      MMINI=$(echo "MMINI=${MM}")
      YYINI=$(echo "YYINI=${YYYY}")
      CCINI=$(echo "CC=${CC}")
      OUTDT=$(echo "OUTPUTDT=${OUTPUTDT}")
      echo "Creating GRADS control file"
      cat /dev/null > ${TEMPDIR}/swanpartition.ctl
      echo "DSET ${DSET}" >> ${TEMPDIR}/swanpartition.ctl
      echo "TITLE ${TITLE}" >> ${TEMPDIR}/swanpartition.ctl
      echo "UNDEF ${UNDEF}" >> ${TEMPDIR}/swanpartition.ctl
      echo "XDEF ${XDEF}" >> ${TEMPDIR}/swanpartition.ctl
      echo "YDEF ${YDEF}" >> ${TEMPDIR}/swanpartition.ctl
      echo "ZDEF ${ZDEF}" >> ${TEMPDIR}/swanpartition.ctl
      echo "TDEF ${TDEF}" >> ${TEMPDIR}/swanpartition.ctl
      echo "VARS 2" >> ${TEMPDIR}/swanpartition.ctl
      echo "u ${U_COMP}" >> ${TEMPDIR}/swanpartition.ctl
      echo "v ${V_COMP}" >> ${TEMPDIR}/swanpartition.ctl
      echo "ENDVARS" >> ${TEMPDIR}/swanpartition.ctl

#  #####################  FOR WIND  #######################
      cp -fpv ${PRTDIR}/${file}_wind ${TEMPDIR}/part.bin_wind
      DSET="part.bin_wind"
      TITLE="WND CG${CGNUM} Control File"
      UNDEF="-99.99"
      NUMTIMES=$(echo "scale=0; (${SWANFCSTLENGTH}/${LENGTHTIMESTEP})+1" | bc)
      TDEF=$(echo "scale=0; (${SWANFCSTLENGTH}/${LENGTHTIMESTEP})+1" | bc)
      XDEF=$(echo "${TDEF} linear 0 ${LENGTHTIMESTEP}") 
      YDEF=$(echo "3 linear -30 30") 
      ZDEF=$(echo "1 levels 1")
      U_COMP=$(echo "1 ${NUMTIMES} 3  u_wind ")
      V_COMP=$(echo "1 ${NUMTIMES} 3  v_wind")
      TDEF=$(echo "${NUMTIMES} linear ${HH}z${DD}${month}${YYYY} ${LENGTHTIMESTEP}hr ${YYYY} ${MM} ${DD} ${HH}")
      HHINI=$(echo "HHINI=${HH}")
      DDINI=$(echo "DDINI=${DD}")
      MMINI=$(echo "MMINI=${MM}")
      YYINI=$(echo "YYINI=${YYYY}")
      CCINI=$(echo "CC=${CC}")
      OUTDT=$(echo "OUTPUTDT=${OUTPUTDT}")
      echo "Creating control file for wind barbs"
      cat /dev/null > ${TEMPDIR}/windforhansonplots.ctl
      echo "DSET ${DSET}"   >> ${TEMPDIR}/windforhansonplots.ctl
#      echo " options byteswapped" >> ${TEMPDIR}/windforhansonplots.ctl
      echo "TITLE ${TITLE}" >> ${TEMPDIR}/windforhansonplots.ctl
      echo "UNDEF ${UNDEF}" >> ${TEMPDIR}/windforhansonplots.ctl
      echo "XDEF ${XDEF}"   >> ${TEMPDIR}/windforhansonplots.ctl
      echo "YDEF ${YDEF}"   >> ${TEMPDIR}/windforhansonplots.ctl
      echo "ZDEF ${ZDEF}"   >> ${TEMPDIR}/windforhansonplots.ctl
      echo "TDEF ${TDEF}"   >> ${TEMPDIR}/windforhansonplots.ctl
      echo "VARS 2"         >> ${TEMPDIR}/windforhansonplots.ctl
      echo "wu ${U_COMP}"   >> ${TEMPDIR}/windforhansonplots.ctl
      echo "wv ${V_COMP}"   >> ${TEMPDIR}/windforhansonplots.ctl
      echo "ENDVARS"        >> ${TEMPDIR}/windforhansonplots.ctl


      
      # NOTE: This is where we set our wind source for this plot
      windsource=$(cat ${RUNdir}/windsource.flag)
      if [ "${windsource}" == "" ]; then windsource="forecast"; fi
      windsource=$(echo ${windsource} | tr [:upper:] [:lower:])

      #------------------------------------- RUN PYTHON SCRIPT --------------------------------------------------
      echo "Plotting partition images"
      python partition.py ${LOCATION} ${LONGITUDE} ${LATITUDE} ${windsource} ${REGION} # Added by E. Rodriguez on 5/18/2015
      #----------------------------------------------------------------------------------------------------------

	# NOTE: We must clean up the PNG files before they are copied to ${GRAPHICSdir} 
      echo "Copying PNG images to ${GRAPHICSdir}"
      if [ "${HASHOTSTART}" == "TRUE" ]
      then 
	  echo "HOTSTART was used for this run, keeping hours 0-9 for CG${CGNUM}"
      else
	  echo "No HOTSTART was used for this run, removing hours 0-9 for CG${CGNUM}."
	  rm -vf *hr00[0-9].png
      fi
      cp -vpf Hanson*.png ${GRAPHICSdir}/.
      chmod 777 ${GRAPHICSdir}/*.png
   done
  cd ${GRAPHICSdir}

  figsTarFile="plots_CG0_${YYYY}${MM}${DD}${HH}.tar.gz"
  tar cvfz ${figsTarFile} *.png
  cycleout=$(awk '{print $1;}' ${RUNdir}/CYCLE)
#  tarbal with plots send to CG0
  COMOUTCYCold="${COMOUTold}/${cycleout}/CG0"
  mkdir -p $COMOUTCYCold
  cp ${figsTarFile} $COMOUTCYCold/${figsTarFile}
  COMOUTCYC="${COMOUT}/${cycleout}/CG0"
  mkdir -p $COMOUTCYC
  cp ${figsTarFile} $COMOUTCYC/${figsTarFile}
done

echo "NWPS partition output plots can be viewed at: ${GRAPHICSdir}"

# ----------------------------------------------------------- 
# ******************************* 
# ********* End of File ********* 
# ******************************* 

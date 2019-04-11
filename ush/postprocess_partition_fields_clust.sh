#!/bin/bash
# -----------------------------------------------------------
# UNIX Shell Script
# Tested Operating System(s): RHEL 5,6,7
# Shell Used: BASH shell
# Original Author(s): Alex.Gibbs@noaa.gov
# File Creation Date: 7/28/2012
# Date Last Modified: 06/13/2016
#
# Version control: 2.03
#
# Support Team:
#
# Contributors: Pablo Santos, Roberto.Padilla@noaa.gov
#
# -----------------------------------------------------------
# ------------- Program Description and Details -------------
# -----------------------------------------------------------
#
# This is the post-processing script for the partitioned
# wave fields. This includes assembling all wave systems
# (heights,directions & periods) into one final grib2 file.
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

# The SITE ID is set in NWPS config but can be specified on the command line
if [ "$1" != "" ]; then SITEID="$1"; fi

if [ "${SITEID}" == "" ]
    then
    SITEID="default"
fi
SITEID=$(echo ${SITEID} | tr [:upper:] [:lower:])

echo "$SITEID"

if [ "$2" != "" ]; then CGnumber="$2"; fi

if [ "${CGnumber}" == "" ]
    then
    CGnumber="CG1"
    echo "NO CGNUM WAS SPECIFIED...SO ONLY PROCESSING CG1 PARTITIONED FIELDS"
fi
CGnumber=$(echo ${CGnumber} | tr [:lower:] [:upper:])

echo "NWPSDATA is: $NWPSDATA"

grib2dir="${NWPSDATA}/output/grib2"
RUNwvtrck="${NWPSDATA}/output/partition/${CGnumber}"
SYSCOORD="${RUNwvtrck}/SYS_COORD.OUT"
HSIGpartition="${RUNwvtrck}/SYS_HSIGN.OUT"
DIRpartition="${RUNwvtrck}/SYS_DIR.OUT"
TPpartition="${RUNwvtrck}/SYS_TP.OUT"
inputCG="${NWPSDATA}/run/input${CGnumber}"

export WTVARdir=${VARdir}/wavetracking
mkdir -pv ${grib2dir} ${WTVARdir}

if [ ! -e ${HSIGpartition} ]
then
    msg="FATAL ERROR: Missing SYS_HSIGN.OUT file. Cannot open ${HSIGpartition}"
    postmsg "$jlogfile" "$msg"
    export err=1; err_chk
    exit 1
fi

cp -fv ${HSIGpartition} ${WTVARdir}/SYS_HSIGN.OUT

#Check for number number of wave systems
cat ${HSIGpartition} | grep -m 1 'Tot number of systems' > blah
awk '{print $1;}' blah > blah1
systems=$(cat blah1)

#Send the number of systems to a file, this is used when including WMO headers
echo "Saving the number of wave systems in ${RUNdir}/NumWaveSystems.txt" 
cat /dev/null > ${RUNdir}/NumWaveSystems.txt
echo "${systems}" | tee -a ${RUNdir}/NumWaveSystems.txt

if [ $systems -eq 0 ]
then
   echo "WARNING: No wave systems identified. Not producing wave tracking CG0 GRIB2 file for this run." | tee -a ${RUNdir}/Warn_Forecaster_${SITEID^^}.${PDY}.txt
   cycle=$(awk '{print $1;}' ${RUNdir}/CYCLE)
   COMOUTCYC="${COMOUT}/${cycle}"
   if [ "${SENDCOM}" == "YES" ]; then
      mkdir -p $COMOUTCYC $GESOUT/warnings
      cp -fv  ${RUNdir}/Warn_Forecaster_${SITEID^^}.${PDY}.txt ${COMOUTCYC}/Warn_Forecaster_${SITEID^^}.${PDY}.txt
      cp -fv  ${RUNdir}/Warn_Forecaster_${SITEID^^}.${PDY}.txt ${GESOUT}/warnings/Warn_Forecaster_${SITEID^^}.${PDY}.txt
   fi
   msg="WARNING: No wave systems identified. Not producing wave tracking CG0 GRIB2 file for this run."
   postmsg "$jlogfile" "$msg"
   exit 0
fi

if [ ! -e ${SYSCOORD} ]
then
    msg="FATAL ERROR: Missing SYS_COORD.OUT file. Cannot open ${SYSCOORD}"
    postmsg "$jlogfile" "$msg"
    export err=1; err_chk
    exit 1
fi
  
cp -fv ${SYSCOORD} ${WTVARdir}/.

if [ ! -e ${DIRpartition} ]
then
    msg="FATAL ERROR: Missing SYS_DIR.OUT file. Cannot open ${DIRpartition}"
    postmsg "$jlogfile" "$msg"
    export err=1; err_chk
    exit 1
fi

cp -fv ${DIRpartition} ${WTVARdir}/SYS_DIR.OUT

if [ ! -e ${TPpartition} ]
then
    msg="FATAL ERROR: Missing SYS_TP.OUT file. Cannot open ${TPpartition}"
    postmsg "$jlogfile" "$msg"
    export err=1; err_chk
    exit 1
fi
  
cp -fv ${TPpartition} ${WTVARdir}/SYS_TP.OUT

if [ ! -e ${NWPSDATA}/run/partition.raw ]
then
    msg="FATAL ERROR: Missing partition.raw file. SYSTRK was not executed from the last run"
    postmsg "$jlogfile" "$msg"
    export err=1; err_chk
    exit 1
fi

if [ ! -e ${inputCG} ]
then
    msg="FATAL ERROR: Missing input${CGnumber} file. Cannot open ${inputCG}"
    postmsg "$jlogfile" "$msg"
    export err=1; err_chk
    exit 1
fi

cp -fv ${inputCG} ${WTVARdir}/.

step=$(grep "^BLOCK 'RAWGRID' HEADER" ${inputCG} | awk '{print $10;}' | awk -F. '{ print $1 }')
tdef=$(grep -c "Time" ${WTVARdir}/SYS_HSIGN.OUT)
runlen=$(echo "($tdef * $step) - $step" | bc)

echo "step and run length are: $step $runlen"

# init time example: 20160421.0000
init=$(grep "^INPGRID WIND" ${inputCG} | awk '{print $11;}')
yyyy=$(echo "${init}" | cut -c 1-4) 
mon=$(echo "${init}" | cut -c 5-6) 
dd=$(echo "${init}" | cut -c 7-8) 
hh=$(echo "${init}" | cut -c 10-11) 
mm=$(echo "${init}" | cut -c 12-13) 
time_stamp="${yyyy}${mon}${dd}_${hh}${mm}"

echo "time_stamp = ${time_stamp}"

cp -fv ${NWPSDATA}/parm/templates/${siteid}/partition.meta ${WTVARdir}/.

# NOTE: The following are set by the swan_wavetrack_to_bin program
# NOTE: The values below do not need to be set to real values here	
sed -i "s/<< SET START YEAR >>/0000/g" ${WTVARdir}/partition.meta
sed -i "s/<< SET START MONTH >>/00/g" ${WTVARdir}/partition.meta
sed -i "s/<< SET START DAY >>/00/g" ${WTVARdir}/partition.meta
sed -i "s/<< SET START HOUR >>/00/g" ${WTVARdir}/partition.meta
sed -i "s/<< SET START MINUTE >>/00/g" ${WTVARdir}/partition.meta
sed -i "s/<< SET START SECOND >>/00/g" ${WTVARdir}/partition.meta
sed -i "s/<< SET NUM POINTS >>/00/g" ${WTVARdir}/partition.meta
sed -i "s/<< SET FORECAST HOUR >>/00/g" ${WTVARdir}/partition.meta
sed -i "s/<< SET WAVE NUMBER >>/0/g" ${WTVARdir}/partition.meta
sed -i "s/<< SET WAVE TYPE >>/0/g" ${WTVARdir}/partition.meta
sed -i "s/<< SET NX >>/0/g" ${WTVARdir}/partition.meta
sed -i "s/<< SET NY >>/0/g" ${WTVARdir}/partition.meta
sed -i "s/<< SET DX >>/0.0/g" ${WTVARdir}/partition.meta
sed -i "s/<< SET DY >>/0.0/g" ${WTVARdir}/partition.meta
sed -i "s/<< SET LA1 >>/0.00/g" ${WTVARdir}/partition.meta
sed -i "s/<< SET LO1 >>/0.00/g" ${WTVARdir}/partition.meta
sed -i "s/<< SET LA2 >>/0.00/g" ${WTVARdir}/partition.meta
sed -i "s/<< SET LO2 >>/0.00/g" ${WTVARdir}/partition.meta

cd ${WTVARdir}
for TYPE in HSIGN DIR TP
do
    echo "Processing ${TYPE}"

    # Since IDLA=1 (NW to SE)  is currently used...we need to flip the grid points
    # so that the pattern reflects IDLA=3 (SW to NE)
    # The next version of systrak will be changing to IDLA=3.
    # Set IDLA with -i1 or -i3 option
    ${EXECnwps}/swan_wavetrack_to_bin -c"SYS_COORD.OUT" -r${runlen} -n"9999" -t${step} -i1 SYS_${TYPE}.OUT ${TYPE}_points.bin partition.meta ${TYPE}_templates.grib2 ${TYPE}
    if [ $? -ne 0 ]
    then
	echo "ERROR - swan_wavetrack_to_bin program reported errors, exiting"
	msg="ERROR - swan_wavetrack_to_bin program reported errors, exiting"
	postmsg "$jlogfile" "$msg"
	export err=1; err_chk
	exit 1
    fi
    ${WGRIB2} ${TYPE}_templates.grib2 -no_header -import_bin ${TYPE}_points.bin -grib_out ${TYPE}_final.grib2
done

if [ ! -e ${grib2dir}/tracking/CG0 ]; then mkdir -p ${grib2dir}/tracking/CG0; fi

cd ${grib2dir}/tracking/CG0
cat /dev/null > ${grib2dir}/tracking/CG0/${siteid}_nwps_CG0_Trkng_${time_stamp}.clust.grib2

echo "Creating final grib2 file: ${grib2dir}/tracking/CG0/${siteid}_nwps_CG0_Trkng_${time_stamp}.grib2"
for TYPE in HSIGN DIR TP
do
    cat ${WTVARdir}/${TYPE}_final.grib2 >> ${grib2dir}/tracking/CG0/${siteid}_nwps_CG0_Trkng_${time_stamp}.clust.grib2
done

echo "Cleaning var files"
if [ -e ${WTVARdir} ]
then
    # NOTE: Keep files for testing new encoder    
    if [ -e ${WTVARdir}/${siteid}_tracking_raw_files_${time_stamp}.tar.gz ]
    then
	rm -fv ${WTVARdir}/${siteid}_tracking_raw_files_${time_stamp}.tar.gz 
    fi
    cd ${WTVARdir}
    tar cvfz ${WTVARdir}/${siteid}_tracking_raw_files_${time_stamp}.tar.gz *

    rm -fv ${WTVARdir}/*.grib2
    rm -fv ${WTVARdir}/partition.meta
    rm -fv ${WTVARdir}/*DIR*
    rm -fv ${WTVARdir}/*HSIGN*
    rm -fv ${WTVARdir}/*TP*
    rm -fv ${WTVARdir}/inputCG1
    rm -fv ${WTVARdir}/SYS_COORD.OUT
fi

cycle=$(awk '{print $1;}' ${RUNdir}/CYCLE)
COMOUTCYC="${COMOUT}/${cycle}/CG0"
if [ "${SENDCOM}" == "YES" ]; then
   mkdir -p $COMOUTCYC
   cp -fv  ${grib2dir}/tracking/CG0/${siteid}_nwps_CG0_Trkng_${time_stamp}.clust.grib2 $COMOUTCYC/
   if [ "${SENDDBN}" == "YES" ]; then
       ${DBNROOT}/bin/dbn_alert MODEL NWPS_GRIB $job  ${COMOUTCYC}/${siteid}_nwps_CG0_Trkng_${time_stamp}.clust.grib2
   fi
fi

echo ""
echo "NOTICE - If any encoding bugs are reported please send the following file to the developers:"
echo "${WTVARdir}/${siteid}_tracking_raw_files_${time_stamp}.tar.gz"
echo ""

echo ""
echo "COMPLETE"
date=$(date "+%D  %H:%M:%S")
echo "$date"
echo "=============================================================================="

#!/bin/bash
set -xa
# ----------------------------------------------------------- 
# UNIX Shell Script File
# Tested Operating System(s): RHEL 5,6
# Tested Run Level(s): 3, 5
# Shell Used: BASH shell
# Original Author(s): Alex Gibbs, Tony Freeman, Pablo Santos, Douglas Gaer
#                     Roberto Padilla-Hernandez
# File Creation Date: 06/01/2009
# Date Last Modified: 11/15/2014
#
# Version control: 1.31
#
# Support Team:
#
# Contributors:
# ----------------------------------------------------------- 
# ------------- Program Description and Details ------------- 
# ----------------------------------------------------------- 
#
# Put this script on a cron to run every minute as ifps user.
# 
# This script checks every if a new wind file has arrived
# from operational GFE and triggers the SWAN model run.
#
# ----------------------------------------------------------- 

# Check to see if our SITEID is set
if [ "${SITEID}" == "" ]
    then
    echo "ERROR - Your SITEID variable is not set"
    export err=1; err_chk
fi

# Check to see if our NWPS directory is set
if [ "${USHnwps}" == "" ]
    then 
    echo "ERROR - Your NWPSdir variable is not set"
    export err=1; err_chk
fi

# Check to see if our NWPS env is set
if [ -e ${USHnwps}/nwps_config.sh ]
then
    source ${USHnwps}/nwps_config.sh
else
    "ERROR - Cannot find ${USHnwps}/nwps_config.sh"
    export err=1; err_chk
fi
 
# Source and BASH includes
source ${USHnwps}/calc_runtime.sh
export err=$?; err_chk
#source ${USHnwps}/process_lock.sh

# Setup process locking
PROGRAMname="$0"
if [ ! -e ${VARdir} ]; then mkdir -p ${VARdir}; fi
#LOCKfile="${VARdir}/runSwan.lck"
#MINold="0"
#LockFileCheck $MINold
#CreateLockFile

# Setup up logging DIR and log file
if [ ! -e ${LOGdir} ]; then mkdir -vp ${LOGdir}; fi
logfile=${LOGdir}/runSwan.log 

################################################################### 
### COMMAND LINE OPTIONS:
RUNLEN=${1}
export RUNLEN
WNA=${2}
export WNA
NESTS=${3}
NESTS=$(echo ${NESTS} | tr [:lower:] [:upper:])
export NESTS
RTOFS=${4}
RTOFS=$(echo ${RTOFS} | tr [:lower:] [:upper:])
export RTOFS
WINDS=${5}
WINDS=$(echo ${WINDS} | tr [:lower:] [:upper:])
export WINDS

# Our WEB default is no
WEB="NO"
if [ "${6}" != "" ]
then
    WEB=${6}
    WEB=$(echo ${WEB} | tr [:lower:] [:upper:])
    export WEB
fi

# Our PLOT default is no
PLOT="NO"
if [ "${7}" != "" ]
then
    PLOT=${7}
    PLOT=$(echo ${PLOT} | tr [:lower:] [:upper:])
    export PLOT
fi
# rph added
    export PLOT
# Added custom DELTAC setting if specified by the user
# NOTE: This is number value or NO if using default value of 600s
USERDELTAC="NO"
if [ "${8}" != "" ]; then USERDELTAC=${8}; fi
export USERDELTAC;

# NOTE: The default variable is defined in master config $NWPSdir/etc/nwps_config.sh
# NOTE: This must TRUE or FALSE to work with RunSwan.pm module
if [ "${9}" != "" ];
then
    HOTSTART=${9}
    HOTSTART=$(echo ${HOTSTART} | tr [:lower:] [:upper:])
    export HOTSTART
fi
#rph

# Added to support WATERLEVELS input
if [ "${10}" != "" ]
then
    WATERLEVELS=${10}
    WATERLEVELS=$(echo ${WATERLEVELS} | tr [:lower:] [:upper:])
    export WATERLEVELS
    export ESTOFS="NO"
    export PSURGE="NO"
    if [ "${WATERLEVELS}" == "ESTOFS" ]; then export ESTOFS="YES"; fi
    if [ "${WATERLEVELS}" == "PSURGE" ]; then export PSURGE="YES"; fi
fi

## Added to support ESTOFS input
#if [ "${10}" != "" ]
#then
#    ESTOFS=${10}
#    ESTOFS=$(echo ${ESTOFS} | tr [:lower:] [:upper:])
#    export ESTOFS
#fi

# Added to support model CORE specification
if [ "${11}" != "" ]
then
    MODELCORE=${11}
    MODELCORE=$(echo ${MODELCORE} | tr [:lower:] [:upper:])
    export MODELCORE
fi

# Added to support specification of PSURGE %Exc to be used
if [ "${12}" != "" ]
then
    EXCD=${12}
    EXCD=$(echo ${EXCD} | tr [:lower:] [:upper:])
    if [ "${WATERLEVELS}" == "PSURGE" ]; then 
      echo "export EXCD=${EXCD}" > ${RUNdir}/PEXCD
      chmod +x ${RUNdir}/PEXCD
      export EXCD
    fi
fi

export SITEID

function SetBottomGrid()
{
    CG="${1}"
    cd ${RUNdir}
    LINE1=$(cat ${RUNdir}/input${CG}.app | grep ^LINE1:)
    CGBOTTOM=$( echo "${LINE1}" | awk -F: '{ print $2 }')
    if [ "${CGBOTTOM}" == "" ] 
    then 
	echo "ERROR - Missing input${CG} bottom grid information"
	echo "Exiting with errors"
	export err=1; err_chk
    fi
    echo "Setting bottom grid for input${CG}"
    sed -i "s/<< PUT INPGRID BOTTOM HERE >>/${CGBOTTOM}/g" ${RUNdir}/input${CG}
    sed -i "s/^INPGRID BOTTOM.*/${CGBOTTOM}/g" ${RUNdir}/input${CG}
}

################################################################### 
#if [ "${WINDS}" == "FORECASTER" ]
if [ "${WINDS}" == "FORECASTWINDGRIDS" ]
then
    if [ -f ${INPUTdir}/SWANflag ]
    then
	echo " "                                           > $logfile
	echo "====================================" | tee -a $logfile
	echo "Forecaster wind file has arrived"     | tee -a $logfile 
	echo -n ": "                                | tee -a $logfile
	date "+%D  %H:%M:%S"                        | tee -a $logfile
	echo "====================================" | tee -a $logfile
	rm -vf ${INPUTdir}/SWANflag                 | tee -a $logfile
    else
	echo "INFO - No forecaster wind file has arrived to start model run" | tee -a $logfile 
	echo "SWAN run was not started!" | tee -a $logfile
	echo "Exiting ${PROGRAMname} with no further processing" | tee -a $logfile
	#RemoveLockFile
	export err=1; err_chk
    fi
fi

echo " " | tee -a $logfile
################################################################### 
echo "CLEAN OUT OLD SWAN PROCESSES:" | tee -a $logfile
echo ": Checking process DIRs ... " | tee -a $logfile
if [ ! -e ${TMPdir}/${USERNAME}/nwps ]; then mkdir -vp ${TMPdir}/${USERNAME}/nwps | tee -a $logfile; fi
#AW: stopSwan.sh not used in WCOSS version of system (runs via a queue on compute nodes)
#${USHnwps}/stopSwan.sh ${siteid} | tee -a $logfile

if [ ! -e ${VARdir} ]; then mkdir -vp ${VARdir} | tee -a $logfile; fi
if [ ! -e ${OUTPUTdir} ]; then mkdir -vp ${OUTPUTdir} | tee -a $logfile; fi

echo ": Cleaning and old process files ... " | tee -a $logfile
if [ -e ${OUTPUTdir}/netCdf/not_completed ]; then rm -fv ${OUTPUTdir}/netCdf/not_completed; fi
if [ -e ${OUTPUTdir}/netCdf/completed ]; then rm -fv ${OUTPUTdir}/netCdf/completed; fi
rm -f ${VARdir}/*secs.txt &> /dev/null
date +%s > ${VARdir}/total_start_secs.txt

if [ ! -e ${ARCHdir} ]; then mkdir -vp ${ARCHdir} | tee -a $logfile; fi
if [ ! -e ${ARCHdir}/pen ]; then mkdir -vp ${ARCHdir}/pen | tee -a $logfile; fi
if [ ! -e ${ARCHdir}/extract ]; then mkdir -vp ${ARCHdir}/extract | tee -a $logfile; fi
if [ ! -e ${DATAdir} ]; then mkdir -vp ${DATAdir} | tee -a $logfile; fi
if [ ! -e ${INPUTdir} ]; then mkdir -vp ${INPUTdir} | tee -a $logfile; fi
if [ ! -e ${INPUTdir}/ndbc ]; then mkdir -vp ${INPUTdir}/ndbc | tee -a $logfile; fi
if [ ! -e ${INPUTdir}/wave ]; then mkdir -vp ${INPUTdir}/wave | tee -a $logfile; fi
if [ ! -e ${INPUTdir}/wind ]; then mkdir -vp ${INPUTdir}/wind | tee -a $logfile; fi
if [ ! -e ${INPUTdir}/rtofs ]; then mkdir -vp ${INPUTdir}/rtofs | tee -a $logfile; fi
if [ ! -e ${INPUTdir}/estofs ]; then mkdir -vp ${INPUTdir}/estofs | tee -a $logfile; fi
if [ ! -e ${INPUTdir}/gfswind ]; then mkdir -vp ${INPUTdir}/gfswind | tee -a $logfile; fi
if [ ! -e ${INPUTdir}/hotstart ]; then mkdir -vp ${INPUTdir}/hotstart | tee -a $logfile; fi
if [ ! -e ${LDMdir}/rtofs ]; then mkdir -vp ${LDMdir}/rtofs | tee -a $logfile; fi
if [ ! -e ${LDMdir}/estofs ]; then mkdir -vp ${LDMdir}/estofs | tee -a $logfile; fi
if [ ! -e ${LDMdir}/gfswind ]; then mkdir -vp ${LDMdir}/gfswind | tee -a $logfile; fi
if [ ! -e ${OUTPUTdir}/grib2 ]; then mkdir -vp ${OUTPUTdir}/grib2 | tee -a $logfile; fi
if [ ! -e ${OUTPUTdir}/grid ]; then mkdir -vp ${OUTPUTdir}/grid | tee -a $logfile; fi
if [ ! -e ${OUTPUTdir}/hdf5 ]; then mkdir -vp ${OUTPUTdir}/hdf5 | tee -a $logfile; fi
if [ ! -e ${OUTPUTdir}/netCdf ]; then mkdir -vp ${OUTPUTdir}/netCdf | tee -a $logfile; fi
if [ ! -e ${OUTPUTdir}/netCdf/cdl ]; then mkdir -vp ${OUTPUTdir}/netCdf/cdl | tee -a $logfile; fi
if [ ! -e ${OUTPUTdir}/spectra ]; then mkdir -vp ${OUTPUTdir}/spectra | tee -a $logfile; fi
if [ ! -e ${OUTPUTdir}/partition ]; then mkdir -vp ${OUTPUTdir}/partition | tee -a $logfile; fi
if [ ! -e ${OUTPUTdir}/vector/images ]; then mkdir -vp ${OUTPUTdir}/vector/images | tee -a $logfile; fi
if [ ! -e ${OUTPUTdir}/validation ]; then mkdir -vp ${OUTPUTdir}/validation | tee -a $logfile; fi
if [ ! -e ${INPUTdir}/latestWNAFiles ]; then mkdir -vp ${INPUTdir}/latestWNAFiles | tee -a $logfile; fi
if [ ! -e ${INPUTdir}/webGet/data ]; then mkdir -vp ${INPUTdir}/webGet/data | tee -a $logfile; fi

echo $$ > ${TMPdir}/${USERNAME}/nwps/9991_runSwan_sh.pid

echo " " | tee -a $logfile
###################################################################
echo "CONFIGURE THE SWAN RUN: "                      | tee -a $logfile
cd ${DATA}

# Record our wind source 
echo ${WINDS} > ${RUNdir}/windsource.flag

# Copy netCDF CDL templates for netCDF and HDF5 encoding 
cp -vfp ${DATA}/parm/templates/${siteid}/cdlHeader* ${OUTPUTdir}/grid/. | tee -a $logfile

#Copy ww3_systrk.inp file for wave systems tracking  
cp -vfp ${DATA}/parm/templates/${siteid}/ww3_systrk.inp ${RUNdir}/. | tee -a $logfile
#
#NOTE: Eventhough the user can choose to include boundary conditions from the
#      domain file ({$NWPSdir}/fix/domains/FILE,  this can be overridden
#      by the input information from the GUI.
#
#Following lines will delete the  BOUN SEG command lines in inputCG1
if [ "${WNA}" == "No" ] || [ "${WNA}" == "NO" ] || [ "${WNA}" == "TAFB-NWPS" ]
   then
   a='$BOUNDARY COMMAND LINES'
   b='$END BOUNSEG'
   sed -i "/$a/,/$b/d" "${DATA}/parm/templates/${siteid}/inputCG1"
fi
#
if [ "${WNA}" == "TAFB-NWPS" ]
   then
   export WNA="TAFB-NWPS"
   echo "INFO - TAFB-NWPS boundary conditions has been chosen" | tee -a $logfile
fi

export WNAconfigfile="wna_input.cfg"
if [ "${WNA}" == "HURWave" ]
    then
    export WNA="HURWave"
    echo "INFO - WW3 boundary conditions will use ww3_multi2 spec files" | tee -a $logfile
fi

if [ "${WNA}" == "WNAWave" ]
    then
    export WNA="WNAWave"
    echo "INFO - WW3 boundary conditions will use ww3_multi1 spec files" | tee -a $logfile
fi

if [ ! -e ${DATA}/parm/templates/${siteid}/${WNAconfigfile} ]; then 
    if [ "${WNA}" == "WNAWave" ] || [ "${WNA}" == "HURWave" ]; then
	echo "ERROR - Request for WW3 boundary conditions but no config found" | tee -a $logfile
	echo "ERROR - ${DATA}/parm/templates/${siteid}/${WNAconfigfile}" | tee -a $logfile
	echo "INFO - Will continue run without WW3 boundary conditions " | tee -a $logfile
	export WNA="NO"
    fi
fi

# In the case where the CG2-5 domains are not nested inside CG1, remove the BOUN NEST line
# to avoid an error in SWAN. This occurs for example at WFO-GYX.
echo NESTINCG1:
echo $NESTINCG1
if [ "${NESTS}" == "YES" ] && [ "${NESTINCG1}" == "NO" ]
   then
   sed -i '/NGRID/d' ${DATA}/parm/templates/${siteid}/inputCG1
   sed -i '/NESTOUT/d' ${DATA}/parm/templates/${siteid}/inputCG1
   sed -i '/BOUN NEST/d' ${DATA}/parm/templates/${siteid}/inputCG2
   sed -i '/BOUN NEST/d' ${DATA}/parm/templates/${siteid}/inputCG3
   sed -i '/BOUN NEST/d' ${DATA}/parm/templates/${siteid}/inputCG4
   sed -i '/BOUN NEST/d' ${DATA}/parm/templates/${siteid}/inputCG5
fi
if [ "${NESTS}" == "YES" ] && [ "${NEST1INCG1}" == "NO" ]
   then
   sed -i '/BOUN NEST/d' ${DATA}/parm/templates/${siteid}/inputCG2
fi
if [ "${NESTS}" == "YES" ] && [ "${NEST2INCG1}" == "NO" ]
   then
   sed -i '/BOUN NEST/d' ${DATA}/parm/templates/${siteid}/inputCG3
fi
if [ "${NESTS}" == "YES" ] && [ "${NEST3INCG1}" == "NO" ]
   then
   sed -i '/BOUN NEST/d' ${DATA}/parm/templates/${siteid}/inputCG4
fi
if [ "${NESTS}" == "YES" ] && [ "${NEST4INCG1}" == "NO" ]
   then
   sed -i '/BOUN NEST/d' ${DATA}/parm/templates/${siteid}/inputCG5
fi

cp -vfp ${DATA}/parm/templates/${siteid}/inputCG1 ${RUNdir}/inputCG1 | tee -a $logfile

### Initialize with WNAwaves/HURWave/TAFB-NWPS:
if [ "${WNA}" == "WNAWave" ] || [ "${WNA}" == "HURWave" ] || [ "${WNA}" == "TAFB-NWPS" ]
then
    echo "Setting up WW3 boundary conditions for this run" | tee -a $logfile
###     cp -vfp ${DATA}/parm/templates/${siteid}/inputCG1.wna_on ${RUNdir}/inputCG1 | tee -a $logfile
    cp -vfp ${DATA}/parm/templates/${siteid}/${WNAconfigfile} ${RUNdir}/wna_input.cfg | tee -a $logfile
    if [ "${WNA}" == "HURWave" ]
    then
	echo "Changing multi_1 to multi_2 in ${RUNdir}/wna_input.cfg" | tee -a $logfile
	sed -i s/multi_1/multi_2/g ${RUNdir}/wna_input.cfg
	echo "Changing multi_1 to multi_2 in ${RUNdir}/inputCG1" | tee -a $logfile
	sed -i s/multi_1/multi_2/g ${RUNdir}/inputCG1
    fi
    if [ "${RETROSPECTIVE}" == "FALSE" ]; then     #RETROSPECTIVE
        echo "==============================================="
        echo " In nwps_preproc  get_wna.sh added !!!  "
        ${USHnwps}/get_wna.sh
        export err=$?; err_chk
        echo "==============================================="
    fi     #RETROSPECTIVE
else
    export WNA="NO"
    echo "FATAL ERROR: Wave boundary conditions are not set. Please CANCEL the downstream jobs for ${siteid}." | tee -a $logfile
    msg="FATAL ERROR: Wave boundary conditions are not set. Please CANCEL the downstream jobs for ${siteid}."
    postmsg "$jlogfile" "$msg"
    export err=1; err_chk
###    cp -vfp ${DATA}/parm/templates/${siteid}/inputCG1.wna_off ${RUNdir}/inputCG1 | tee -a $logfile
fi

if [ "${WNA}" == "TAFB-NWPS" ]
   then
   export WNA="TAFB-NWPS"
   rm ${RUNdir}/bc_*
   echo "INFO - TAFB-NWPS boundary conditions has been chosen" | tee -a $logfile
fi

if [ "${RETROSPECTIVE}" == "FALSE" ]; then     #RETROSPECTIVE

#====================================================================================
# Initialize ESTOFS:
echo " Initializing WATERLEVELS "
echo "WATERLEVELS: ${WATERLEVELS},  ESTOFS: ${ESTOFS}" 
if [ "${ESTOFS}" == "YES" ] 
then
   echo "Setting up water levels from ESTOFS" | tee -a $logfile 
   source ${USHnwps}/get_ncep_initfiles.sh ESTOFS
   export err=$?; err_chk
else
   export ESTOFS="NO"
   echo "ESTOFS Water Levels will NOT be used" | tee -a $logfile
fi
#====================================================================================
# Initialize RTOFS:
RTOFS=$(echo ${RTOFS} | tr [:lower:] [:upper:])
echo "RTOFS: ${RTOFS}" 
echo " Initializing RTOFS "
if [ "${RTOFS}" == "YES" ] 
then
   echo "Setting up Currents from RTOFS" | tee -a $logfile
   source ${USHnwps}/get_ncep_initfiles.sh RTOFS
   export err=$?; err_chk
else
   export RTOFS="NO"
   echo "RTOFS Currents will NOT be used" | tee -a $logfile
fi
#====================================================================================
# Initialize PSURGE:
PSURGE=$(echo ${PSURGE} | tr [:lower:] [:upper:])
echo "PSURGE: ${PSURGE}" 
echo " Initializing PSURGE "
if [ "${PSURGE}" == "YES" ] 
then
   echo "Setting up water levels from PSURGE" | tee -a $logfile
   source ${USHnwps}/get_ncep_initfiles.sh PSURGE
   export err=$?; err_chk
    
   #if [ -e ${RUNdir}/nopsurge ] && [ ! -e ${RUNdir}/noestofs ]
   #then
   #   export WATERLEVELS="ESTOFS"
   #   export ESTOFS="YES"
   #   export PSURGE="NO"
   #   echo " Initializing WATERLEVELS from ESTOFS"
   #   echo "WATERLEVELS: ${WATERLEVELS},  ESTOFS: ${ESTOFS}" 
      echo "Setting up Waterlevels from ESTOFS to be added after Psurge" | tee -a $logfile 
      ${USHnwps}/get_ncep_initfiles.sh ESTOFS 
   #fi
   # To complete the 102 hrs run including water levels it is necessary to add
   #estofswater levels, for Psurge covers only 78 hrs.

   if [ "${ESTOFS}" == "YES" ] && [ ! -e ${RUNdir}/noestofs ]
      then
      echo "PSURGE data not found. Initializing WATERLEVELS from ESTOFS instead"
      echo "WATERLEVELS: ${WATERLEVELS},  ESTOFS: ${ESTOFS}"
      source ${USHnwps}/get_ncep_initfiles.sh ESTOFS
      export err=$?; err_chk
   fi
else
   export PSURGE="NO"
   echo "PSURGE Water levels will NOT be used" | tee -a $logfile
fi
#==========================================================================================

fi   #RETROSPECTIVE

echo "Setting up BATHY data for ${REGIONID} region or ${SITEID} site"
HASBATHY="FALSE"
BATHYdir=""

if [ "${MODELCORE}" == "SWAN" ] || [ "${MODELCORE}" == "UNSWAN" ]
   then
# Look for regional BATHY file
   if [ -e ${BATHYdb}/${regionid}/bathyCG1 ]
     then
     HASBATHY="TRUE"
#     BATHYFILE="${BATHYdb}/${regionid}.tar.gz"
     BATHYdir="${BATHYdb}/${regionid}"
   fi
# Look for site BATHY file, override regional if exists
   if [ -e ${BATHYdb}/${siteid}/bathyCG1 ]
     then
     HASBATHY="TRUE"
#     BATHYFILE="${BATHYdb}/${siteid}.tar.gz"
     BATHYdir="${BATHYdb}/${siteid}"
   fi
fi

if [ "${HASBATHY}" != "TRUE" ]
    then
    echo "ERROR - Cannot find BATHY file in ${BATHYdb}"
    echo "ERROR - Exiting NWPS run"
    export err=1; err_chk
fi
echo "Using BATHY file ${BATHYFILE}"
currPWD=$(pwd)
cd ${RUNdir}
cp -r ${BATHYdir}/* .
SetBottomGrid CG1

## CONFIGURE NEST:
# NOTE: In NWPS our ${RUNdir}/ConfigSwan.pm is not modified here, CG1 - CG5 now configured in include file
# NOTE: 06/26/2014: Changed to multi-site mode and move include to ${RUNdir}
cp -vfp ${DATA}/parm/templates/${siteid}/CGinclude.pm ${RUNdir}/CGinclude.pm  | tee -a $logfile
if [ "${NESTS}" == "YES" ]
then
    export NESTS="YES"
    if [ ! -e ${DATA}/parm/templates/${siteid}/inputCG2 ] 
    then
	echo "ERROR - Nested run was specified but site has template -e ${DATA}/parm/templates/${siteid}/inputCG2"
	echo "Exiting with errors"
	export err=1; err_chk
    fi
    echo "INFO - Copying inputCG2 through 5 for nested run"
    echo "INFO - Assuming ${BATHYdb}/${siteid}.tar.gz has pre-compiled BATHY files for CG2 through 5"
    echo "INFO - Assuming ${BATHYdb}/${siteid}.tar.gz has bottom grid append files for CG2 through 5"
    cp -vfp ${DATA}/parm/templates/${siteid}/inputCG2 ${RUNdir}/. | tee -a $logfile
    SetBottomGrid CG2
    ##if [ -e ${DATA}/parm/templates/${siteid}/inputCG3 ] 
if [ -e ${RUNdir}/inputCG3.app ]
    then 
	cp -vfp ${DATA}/parm/templates/${siteid}/inputCG3 ${RUNdir}/. | tee -a $logfile
	SetBottomGrid CG3
    fi
##    if [ -e ${DATA}/parm/templates/${siteid}/inputCG4 ]
if [ -e ${RUNdir}/inputCG4.app ]
    then 
	cp -vfp ${DATA}/parm/templates/${siteid}/inputCG4 ${RUNdir}/. | tee -a $logfile
	SetBottomGrid CG4
    fi
##    if [ -e ${DATA}/parm/templates/${siteid}/inputCG5 ]
if [ -e ${RUNdir}/inputCG5.app ]
    then 
	cp -vfp ${DATA}/parm/templates/${siteid}/inputCG5 ${RUNdir}/. | tee -a $logfile
	SetBottomGrid CG5
    fi
else
    echo "INFO - No inner nests selected for this model run"
    export NESTS="NO"
fi

    #LINE1=$(cat ${RUNdir}/input${CG}.app | grep ^LINE1:)
    #CGBOTTOM=$( echo "${LINE1}" | awk -F: '{ print $2 }')


#The following line is changed from the run_xxx.sh where xxx is the test case.
# For stationary initializatioin
#ADD STATIONARY COMMAND LINE
### CONFIGURE RUNLEN:
if [[ ${RUNLEN} -lt 6 ]]
then
    echo "ALERT:  Invalid Run Length Specified On Command Line ( ${RUNLEN} ) ..." | tee -a $logfile
    echo "ALERT:  Setting RUNLEN to 6" | tee -a $logfile
    export RUNLEN=6
fi

export RUNLEN

# NOTE: This step will modify ConfigSwan.pm
cat ${USHnwps}/pm/ConfigSwan_master_template.pm > ${RUNdir}/ConfigSwan.pm
sed -r -i "s/^(use constant SWANFCSTLENGTH => ')([0-9]+)(';)/\1${RUNLEN}\3/g" ${RUNdir}/ConfigSwan.pm

echo -n "Run length will be: "                       | tee -a $logfile
grep "use constant SWANFCSTLENGTH =>" ${RUNdir}/ConfigSwan.pm  | tee -a $logfile
echo " " | tee -a $logfile

# Clear the hot start log here
cat /dev/null > ${LOGdir}/hotstart.log

rm -f ${INPUTdir}/input/wave/*

if [ "${HOTSTART}" == "FALSE" ]; then rm -f ${INPUTdir}/hotstart/*; fi
#
#The "WNA-test" comment is used when running a test. 
#It is used to avoid downloading Bond. Cond. but using the stored ones
#DO NOT DELETE it or Modified
#WNA-test
#
#Write parameters to a file
cat /dev/null > ${RUNdir}/info_to_nwps_coremodel.txt
# Setup our NWPS env
echo "$NWPSdir" >> ${RUNdir}/info_to_nwps_coremodel.txt
echo "$ISPRODUCTION" >> ${RUNdir}/info_to_nwps_coremodel.txt
echo "$DEBUGGING" >> ${RUNdir}/info_to_nwps_coremodel.txt
echo "$DEBUG_LEVEL" >> ${RUNdir}/info_to_nwps_coremodel.txt
# Setup our processing DIRs
echo "$BATHYdb" >> ${RUNdir}/info_to_nwps_coremodel.txt
echo "$SHAPEFILEdb" >> ${RUNdir}/info_to_nwps_coremodel.txt
echo "$ARCHdir" >> ${RUNdir}/info_to_nwps_coremodel.txt
echo "$DATAdir" >> ${RUNdir}/info_to_nwps_coremodel.txt
echo "$INPUTdir" >> ${RUNdir}/info_to_nwps_coremodel.txt
echo "$LOGdir" >> ${RUNdir}/info_to_nwps_coremodel.txt
echo "$VARdir" >> ${RUNdir}/info_to_nwps_coremodel.txt
echo "$OUTPUTdir" >> ${RUNdir}/info_to_nwps_coremodel.txt
echo "$RUNdir" >> ${RUNdir}/info_to_nwps_coremodel.txt
echo "$TMPdir" >> ${RUNdir}/info_to_nwps_coremodel.txt
# Setup our model run environment
echo "$RUNLEN" >> ${RUNdir}/info_to_nwps_coremodel.txt
echo "$WNA" >> ${RUNdir}/info_to_nwps_coremodel.txt
echo "$NESTS" >> ${RUNdir}/info_to_nwps_coremodel.txt
echo "$RTOFS" >> ${RUNdir}/info_to_nwps_coremodel.txt
echo "$ESTOFS" >> ${RUNdir}/info_to_nwps_coremodel.txt
echo "$WINDS" >> ${RUNdir}/info_to_nwps_coremodel.txt
echo "$WEB" >> ${RUNdir}/info_to_nwps_coremodel.txt
echo "$PLOT" >> ${RUNdir}/info_to_nwps_coremodel.txt
echo "$SITEID" >> ${RUNdir}/info_to_nwps_coremodel.txt
echo "$MODELCORE" >> ${RUNdir}/info_to_nwps_coremodel.txt
echo "$GEN_NETCDF" >> ${RUNdir}/info_to_nwps_coremodel.txt
echo "$USERDELTAC" >> ${RUNdir}/info_to_nwps_coremodel.txt
################################################################### 
echo "SWAN Run Started: "                           | tee -a $logfile
date -u                                             | tee -a $logfile
echo "WNA: $WNA" | tee -a $logfile
if [ "${DEBUGGING}" == "TRUE" ]
then
    echo "perl -w ${USHnwps}/nwps_preproc.pl" | tee -a $logfile    
    perl -w ${USHnwps}/nwps_preproc.pl | tee -a $logfile
    export err=$?; err_chk
else
    echo "perl ${USHnwps}/nwps_preproc.pl" | tee -a $logfile    
    perl ${USHnwps}/nwps_preproc.pl | tee -a $logfile
    export err=$?; err_chk
fi
#for WCOSS
#Break here for WCOSS_preproc_01

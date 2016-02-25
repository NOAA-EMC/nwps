#!/bin/bash
set -xa
# ----------------------------------------------------------- 
# UNIX Shell Script File
# Tested Operating System(s): RHEL 5,6
# Tested Run Level(s): 3, 5
# Shell Used: BASH shell
# Original Author(s): Douglas.Gaer@noaa.gov, Roberto.Padilla@noaa.gov
# File Creation Date: 08/22/2011
# Date Last Modified: 04/06/2015
#
# Version control: 1.17
#
# Support Team:
#
# Contributors:
# ----------------------------------------------------------- 
# ------------- Program Description and Details ------------- 
# ----------------------------------------------------------- 
#
# Script used to run the NWPS model from the command line
#
# ----------------------------------------------------------- 

# Setup our NWPS environment                                                    
if [ "${USHnwps}" == "" ]
    then 
    echo "FATAL ERROR: Your USHnwps variable is not set"
    export err=1; err_chk
fi
    
if [ ! -e ${USHnwps}/nwps_config.sh ]
then
    "FATAL ERROR: Cannot find ${USHnwps}/nwps_config.sh"
    export err=1; err_chk
fi

VERSION=$(cat ${HOMEnwps}/version.txt)
NODOWNLOAD="TRUE"
export DEBUGGING="FALSE"

function HelpMessage()
{
    echo ""
    echo "NWPS manual run program version ${VERSION}"
    echo "INFO - You must specify a site ID with the --sitename argument"
    echo "INFO - You must specify a run length with the --runlen argument"
    echo ""
    echo "Minimum usage: ${0} --sitename TXX --runlen 24"
    echo ""
    echo "Optional arguments:"
    echo " --wna                    Enable WaveWatch 3 (WW3) boundary conditions"
    echo " --wna2                   Use WW3 multi2 spec files during hurricanes"
    echo " --nests                  Enable nests for CG2 through CG5"
    echo " --rtofs                  Enable RTOFS ocean current"
    echo " --web                    Enable send to Web for output plots"
    echo " --plot                   Plot output without send to Web option"
    echo " --winds source           Set input wind source for this run"
    echo "                          choices: forecaster, gfs, nam, custom"
    echo " --nohotstart             Disables hotstart"
    echo " --nodownload             Do not re-download Regional, NDFD, or GFS winds"
    echo ""
    echo "Advanced options:"
    echo " --waterlevels XXXXXX     Specify ESTOFS or PSURGE. If not specified default is No."
    echo " --excd nn                Specify if you want to use 10, 20, 30, 40, or 50 exceedance. If not specified, default is 10."
    echo " --deltac nnnn            Specify DELTAC value in seconds"
    echo " --windfile filename.txt  Start model run using archived wind file" 
    echo " --sitename XXX           Run as this site, assuming we have templates"
    echo " --domainsetup filename   Setup new domain and run model"
    echo " --wavemodel WaveModel   Specify the wave model to be used, SWAN or WW3"
    echo ""
    echo "Debug options:"
    echo " -d                       Enable verbose debugging"
    echo ""
    export err=1; err_chk
}
echo ": Cleaning and old process files ... " | tee -a $logfile
if [ -e ${OUTPUTdir}/netCdf/not_completed ]; then rm -fv ${OUTPUTdir}/netCdf/not_completed; fi
if [ -e ${OUTPUTdir}/netCdf/completed ]; then rm -fv ${OUTPUTdir}/netCdf/completed; fi
rm -f ${VARdir}/*secs.txt &> /dev/null

if [ "${1}" == "" ]; then HelpMessage; fi
if [ "${2}" == "" ]; then HelpMessage; fi

TEMP=$(getopt -o vdh --long help,runlen:,winds:,wna,wna2,nests,rtofs,waterlevels:,excd:,plot,web,nodownload,nohotstart,sitename:,domainsetup:,windfile:,deltac:,wavemodel: -- "$@")
if [ $? != 0 ] ; then echo "FATAL ERROR: Problem processing command line args" >&2 ; export err=1; err_chk ; fi
eval set -- "$TEMP"

while true 
do
    case "$1" in
	-v) echo ""; echo "NWPS version ${VERSION}"; echo ""; exit 2; shift;;
	-d) export DEBUGGING="TRUE"; shift;;
	-h) HelpMessage ; shift;;
	--help) HelpMessage ; shift;;
	--runlen) RUNLEN="${2}" ; shift 2 ;;
	--winds) WINDS="${2}" ; shift 2 ;;
	--wna) WNA="WNAWave" ; shift ;;
	--wna2) WNA="HURWave" ; shift ;;
	--nests) NESTS="Yes" ; shift ;;
	--rtofs) RTOFS="Yes" ; shift ;;
	--waterlevels) WATERLEVELS="${2}" ; shift 2 ;;
	--excd) EXCD="${2}" ; shift 2 ;;
	--plot) PLOT="Yes" ; shift ;;
	--web) WEB="Yes" ; shift ;;
        --nohotstart) HOTSTART="FALSE" ; shift ;;
	--nodownload) NODOWNLOAD="TRUE"  ; shift;;
	--sitename) SITENAME="${2}" ; shift 2 ;;
	--domainsetup) DOMAINSETUP="${2}" ; shift 2 ;;
	--windfile) WINDFILE="${2}" ; export CommandLineWindFileName="${2}"; shift 2 ;;
	--deltac) USERDELTAC="${2}" ; shift 2 ;;
	--wavemodel) MODELCORE="${2}" ; shift 2 ;;
	--) shift ; break ;;
	*) echo echo "$0: FATAL ERROR: Unrecognized option $1" 1>&2; export err=1; err_chk;;
    esac
done

if [ "${SITENAME}" == "" ]; then HelpMessage; fi
if [ "${RUNLEN}" == "" ]; then HelpMessage; fi

# Create a restore point for our primary site ID
export SITEID=$(echo "${SITENAME}" | tr [:lower:] [:upper:])
export siteid=$(echo "${SITENAME}" | tr [:upper:] [:lower:])
export primarySITEID=${SITEID}
export primarysiteid=${siteid}

# Check to see if our SITEID is set
if [ "${SITEID}" == "" ]
    then
    echo "FATAL ERROR: Your SITEID variable is not set"
    export err=1; err_chk
fi
#Do not call nwps_config.sh here as siteid.sh has not been created
## source ${USHnwps}/nwps_config.sh

#------------------------------------------------------------
#-----  SELECT WIND FILES WITH WHICH TO FORCE THE MODEL -----
#------------------------------------------------------------
WINDS=$(echo ${WINDS} | tr [:upper:] [:lower:])
if [ "${WINDS}" == "gfs" ] || [ "${WINDS}" == "nam" ]
then
    echo "User has requested external wind source ${WINDS}" | tee -a ${LOGdir}/run_nwps.log 
    echo "Starting model with ${WINDS} wind source" | tee -a ${LOGdir}/run_nwps.log 
#    if [ "${NODOWNLOAD}" == "TRUE" ]
#    then
#	echo "Skipping forcing winds download from ${WINDS}" | tee -a ${LOGdir}/run_nwps.log 
     ${USHnwps}/get_${WINDS}_winds.sh 
#    else
#	${USHnwps}/get_${WINDS}_winds.sh ${NODOWNLOAD}
	if [ "$?" != "0" ] 
	then
	    echo "FATAL ERROR: Could not locate wind source" | tee -a ${LOGdir}/run_nwps.log
	    echo "Exiting model run with fatal error" | tee -a ${LOGdir}/run_nwps.log 
	    export err=1; err_chk
	fi
#    fi
elif [ "${WINDS}" == "custom" ]
then
    echo "User has requested external wind source ${WINDS}" | tee -a ${LOGdir}/run_nwps.log 
    echo "Starting model with ${WINDS} user defined wind source" | tee -a ${LOGdir}/run_nwps.log 
    if [ ! -e ${PARMnwps}/templates/${siteid}/gen_${WINDS}_winds.sh ]
	then 
	echo "FATAL ERROR: Missing custom generate script ${PARMnwps}/templates/${siteid}/gen_${WINDS}_winds.sh" | tee -a ${LOGdir}/run_nwps.log 
	echo "Exiting model run with fatal error" | tee -a ${LOGdir}/run_nwps.log 
	export err=1; err_chk
    fi
    if [ "${NODOWNLOAD}" == "TRUE" ]
    then
	echo "Skipping forcing winds download from ${WINDS}" | tee -a ${LOGdir}/run_nwps.log 
    else
	if [ ! -e ${PARMnwps}/templates/${siteid}/get_${WINDS}_winds.sh ]
	then 
	    echo "FATAL ERROR: Missing custom download script ${PARMnwps}/templates/${siteid}/get_${WINDS}_winds.sh" | tee -a ${LOGdir}/run_nwps.log 
	    echo "Exiting model run with fatal error" | tee -a ${LOGdir}/run_nwps.log 
	    export err=1; err_chk
	fi
	${PARMnwps}/templates/${siteid}/get_${WINDS}_winds.sh
	if [ "$?" != "0" ] 
	then
	    echo "FATAL ERROR: Could not locate wind source" | tee -a ${LOGdir}/run_nwps.log
	    echo "Exiting model run with fatal error" | tee -a ${LOGdir}/run_nwps.log 
	    export err=1; err_chk
	fi
    fi
else
    echo "Starting model run with forecaster winds from GFE" | tee -a ${LOGdir}/run_nwps.log 
    WINDS="forecaster"
    . ${DATA}/PDY

    # Forecaster warning log file
    cat /dev/null > ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt
    date_hh_mm_ss=$(date)
    echo "NWPS run started on ${date_hh_mm_ss}" | tee -a ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt

    echo "Checking for input forecaster winds" | tee -a ${LOGdir}/run_nwps.log 
    ls -lt ${FORECASTWINDdir}/*tar*
    NewestWind="Empty"
    NewestWind=$(basename `ls -t ${FORECASTWINDdir}/NWPSWINDGRID_${siteid}* | head -1`)
    ecflow_client --label=DCOM "${NewestWind}"

    if [  -e ${FORECASTWINDdir}/${NewestWind} ]
    then
	echo "Forecaster wind file has arrived from ${SITEID}"     | tee -a $logfile 
        touch ${INPUTdir}/SWANflag
        echo "Most Recent wind file for ${SITEID}: ${NewestWind}"
        cd ${INPUTdir}/

        #Delete previous wind files, and copy newest input file
        rm *.tar.gz ${siteid}*WIND.txt
        cp ${FORECASTWINDdir}/${NewestWind} ${INPUTdir}/
        tar xvfz ${INPUTdir}/${NewestWind}
        rm ${NewestWind}

        WindFileName=`ls -t ${siteid}*WIND.txt | head -1`

        if [ ! -f "${WindFileName}" ]
        then
           warnings="YES"
           echo "FATAL ERROR: Wind file ${WindFileName} not transmitted. NWPS will not be executed. Please resend wind file." | tee -a ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt
           msg="FATAL ERROR: NWPS will not be executed due to absent forecast wind file."
           postmsg "$jlogfile" "$msg"
           mkdir -p $COMOUTCYC $GESOUT/warnings
           cp -fv  ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt ${COMOUTCYC}/Warn_Forecaster_${SITEID}.${PDY}.txt
           cp -fv  ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt ${GESOUT}/warnings/Warn_Forecaster_${SITEID}.${PDY}.txt
           echo "ABORTED $FORECASTWINDdir/${NewestWind} AT $(date -u "+%Y%m%d%H%M")" >> ${dcom_hist}
           export err=1; err_chk
        fi

        arr=$(echo ${WindFileName} | tr "_" "\n")
        x=0
        for xa in $arr
        do
          part[$x]=$xa
          echo "> ${part[$x]}"
           x=$(( $x + 1 ))
        done
        WindNewName="${part[1]}_${part[2]}"
        echo "WindNewName : ${WindNewName}"
        mv ${WindFileName} ${WindNewName}

        echo "${SITEID} wind file: ${WindNewName}" | tee -a ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt

        #Num_wind_fields=`grep "Wind_Mag_SFC:validTimes" ${WindNewName} |awk -F"=" '{print $NF}'|sed -e 's/,/ /g' -e 's/;/ /g'|wc -w`
        Num_wind_fields=$(grep -i 'Wind_Mag_SFC(DIM_' ${WindNewName} | awk -F'(' '{ print $2 }' | awk -F',' '{ print $1 }' | awk -F'_' '{ print $2 }')
        if [ "$Num_wind_fields" == "" ]
        then
           warnings="YES"
           echo "FATAL ERROR: Wind file ${WindNewName} is empty. NWPS will not be executed. Please resend wind file." | tee -a ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt
           msg="FATAL ERROR: NWPS will not be executed due to empty forecast wind file."
           postmsg "$jlogfile" "$msg"
           mkdir -p $COMOUTCYC $GESOUT/warnings
           cp -fv  ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt ${COMOUTCYC}/Warn_Forecaster_${SITEID}.${PDY}.txt
           cp -fv  ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt ${GESOUT}/warnings/Warn_Forecaster_${SITEID}.${PDY}.txt
           echo "ABORTED $FORECASTWINDdir/${NewestWind} AT $(date -u "+%Y%m%d%H%M")" >> ${dcom_hist}
           export err=1; err_chk
        fi
        if [ "$Num_wind_fields" -lt "103" ]
        then
           warnings="YES"
           echo "FATAL ERROR: Number of wind fields received is $Num_wind_fields, must be at least 103. NWPS will not be executed." | tee -a ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt
           msg="FATAL ERROR: Number of wind fields received is $Num_wind_fields, must be at least 103. NWPS will not be executed."
           postmsg "$jlogfile" "$msg"
           mkdir -p $COMOUTCYC $GESOUT/warnings
           cp -fv  ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt ${COMOUTCYC}/Warn_Forecaster_${SITEID}.${PDY}.txt
           cp -fv  ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt ${GESOUT}/warnings/Warn_Forecaster_${SITEID}.${PDY}.txt
           echo "ABORTED $FORECASTWINDdir/${NewestWind} AT $(date -u "+%Y%m%d%H%M")" >> ${dcom_hist}
           export err=1; err_chk
        else
           echo "Number of wind fields on file: $Num_wind_fields"
        fi

        mkdir -p ${INPUTdir}/wind
        rm ${INPUTdir}/wind/*
        ls -l ${INPUTdir}/
        cp -fp ${WindNewName} ${INPUTdir}/wind/${WindNewName}
        ln -sf ${INPUTdir}/wind/${WindNewName} ${INPUTdir}/${WindNewName}
        ls -l ${INPUTdir}/wind/
        yyyymmdd=`ls ${WindNewName} | cut -c1-8`
        hh=`ls ${WindNewName} | cut -c9-10`

        #----- Model to be run with forecaster settings:                -----
        #----- Read and process *.ctl control file from AWIPS2 NWPS GUI -----
        #----- NOTE: We do not use the *.cfg domain file coming from    -----
        #-----       WFOs, but rather the one stored in fix/domains/    -----
        #mv -f ${siteid}_domain_setup.cfg ${DATA}/parm/templates/${siteid}/${SITEID}

        # Source domain setup to get the setting for NESTGRIDS
        # (i.e. whether nests have been defined for this domain or not)
        source ${DOMAINSETUP}

        warnings="NO"
        while read line
        do
          p=$line
        done <${INPUTdir}/${siteid}_inp_args.ctl

        echo "line p=$p"
        arr=$(echo $p | tr ":" "\n")
        x=0
        for xa in $arr
        do
          fromgui[$x]=$xa
           x=$(( $x + 1 ))
        done
        # Assign run variables from AWIPS GUI, adjusting string formats 
        # to ensure uniformity despite input from different AWIPS releases.
        export RUNLEN="${fromgui[0]}"
        export WNA="${fromgui[1]}"
        export NESTS="${fromgui[2],,}"
        export NESTS="${NESTS^}"
        export RTOFS="${fromgui[3],,}"
        export RTOFS="${RTOFS^}"
        export WINDS="${fromgui[4]}"
        export WEB="${fromgui[5],,}"
        export WEB="${WEB^}"
        export PLOT="${fromgui[6],,}"
        export PLOT="${PLOT^}"
        export USERDELTAC="${fromgui[7]}"
               hotstart="${fromgui[8]}"
        export HOTSTART=${hotstart^^}
        export WATERLEVELS="${fromgui[9]}"
        export CORE="${fromgui[10]}"
        export EXCD="${fromgui[11]}"
       
# Checking if default values are different from the forecaster values
        Default_RUNLEN="102"       
        Default_USERDELTAC="600"
        Default_WAVEMODEL="swan"
        Default_WINDS="FORECASTER"
        Default_NESTS="Yes"
        Default_PLOT="Yes"

        if [ "${RUNLEN}" -ne "${Default_RUNLEN}" ] || [ "${USERDELTAC}" -ne "${Default_USERDELTAC}" ] || \
           [ "${WNA}" = "TAFB-NWPS" ] || [ "${WAVEMODEL}" != "${Default_WAVEMODEL}" ] || \
           [ "${PLOT}" != "${Default_PLOT}" ] || \
           [ [ "${NESTS^^}" != "${Default_NESTS^^}" ] && [ ${NESTGRIDS} -ne 0 ] ] \
           [ [ "${NESTS^^}" == "${Default_NESTS^^}" ] && [ ${NESTGRIDS} -eq 0 ] ]
        then
           echo "WARNING: Some forecaster settings overwritten by WCOSS defaults:" | tee -a ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt
        fi

        if [ "${RUNLEN}" -ne "${Default_RUNLEN}" ]
        then
           echo "WARNING: User input RUNLEN=${RUNLEN} not equal to Default_RUNLEN=${Default_RUNLEN}. Default run length of -${Default_RUNLEN} hrs- will be used." | tee -a ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt
           warnings="YES"
        fi
        if [ "${USERDELTAC}" -ne "${Default_USERDELTAC}" ]
        then
           echo "WARNING: User input USERDELTAC=${USERDELTAC} not equal to Default_USERDELTAC=${Default_USERDELTAC}. Default computational time step of -${Default_USERDELTAC} s- will be used." | tee -a ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt
           warnings="YES"
        fi
        if [ "${WNA}" = "TAFB-NWPS" ]
        then
            echo "WARNING: NWPS-WCOSS is not ready to ingest TAFB boundary conditions. Will use boundary conditions from WW3_multi2 (HURWave)." | tee -a ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt
            export WNA="HURWave"
           warnings="YES"
        fi
        if [ "${WAVEMODEL}" != "${Default_WAVEMODEL}" ]
        then
           echo "WARNING: User input WAVEMODEL=${WAVEMODEL} not equal to Default_WAVEMODEL=${Default_WAVEMODEL}. Will run using the wave model ${Default_WAVEMODEL}." | tee -a ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt
           warnings="YES"
        fi
        if [ "${PLOT}" != "${Default_PLOT}" ]
        then
           echo "WARNING: User input PLOT=${PLOT} not equal to Default_PLOT=${Default_PLOT}. Will run with figure plotting activited." | tee -a ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt
           warnings="YES"
        fi
        if [ "${NESTS^^}" != "${Default_NESTS^^}" ] && [ ${NESTGRIDS} -ne 0 ]
        then
           echo "WARNING: User input NESTS=${NESTS} not equal to Default_NESTS=${Default_NESTS}. Default nesting option ${Default_NESTS} will be used." | tee -a ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt
           export NESTS=${Default_NESTS}
           warnings="YES"
        fi
        if [ "${NESTS^^}" == "${Default_NESTS^^}" ] && [ ${NESTGRIDS} -eq 0 ]
        then
           echo "WARNING: User input is NESTS=${NESTS}, but no nests are defined in the stored domain file. Nesting option will be set to No." | tee -a ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt
           export NESTS="No"
           warnings="YES"
        fi

        if [ "${warnings}" == "NO" ]
        then
           echo "Run was configured with forecaster settings" | tee -a ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt
        fi

#.......FIXED DEFAULT VALUES DISREGARDING THE VALUES FROM THE FORECASTER
        export RUNLEN=${Default_RUNLEN}
        export USERDELTAC=${Default_USERDELTAC}
        export WAVEMODEL=${Default_WAVEMODEL}
        export WINDS=${Default_WINDS}
        export PLOT=${Default_PLOT}
        export DOMAINSET="${FIXnwps}/domains/${SITEID}"
#.......
        echo "RUNLEN=$RUNLEN"
        echo "WNA=$WNA"
        echo "NESTS=$NESTS"
        echo "RTOFS=$RTOFS"
        echo "WINDS=$WINDS"
        echo "WEB=$WEB"
        echo "PLOT=$PLOT"
        echo "USERDELTAC=$USERDELTAC"
        echo "HOTSTART=$HOTSTART"
        echo "WATERLEVELS=$WATERLEVELS"
        echo "CORE=$CORE"
        echo "EXCD=$EXCD"
    else
	echo "INFO - Our input wind file has not arrived" | tee -a ${LOGdir}/run_nwps.log 
	echo "INFO - Will not start run until wind file has arrived" | tee -a ${LOGdir}/run_nwps.log 
	echo "Exiting..."
	exit 2
    fi
fi

# NOTE: The following do not require default values
# SITENAME
# DOMAINSETUP
# WINDFILE

#
# NOTE: The default variable is defined in master config $USHnwps/nwps_config.sh
# NOTE: This must TRUE or FALSE to work with RunSwan.pm module
HOTSTART="TRUE"

# NOTE: In this release we only have the SWAN model core.
# NOTE: The MODELCORE variable will not be used when the WW3 core is added.
MODELCORE="SWAN"

cat /dev/null > ${LOGdir}/run_nwps.log
echo "NWPS-WCOSS run program version ${VERSION}" | tee -a ${LOGdir}/run_nwps.log 

if [ "${DEBUGGING}" == "TRUE" ]
then
    echo "" | tee -a ${LOGdir}/run_nwps.log 
    echo "INFO - Debugging is enabled" | tee -a ${LOGdir}/run_nwps.log 
    echo "" | tee -a ${LOGdir}/run_nwps.log 
    echo "Command line inputs:" | tee -a ${LOGdir}/run_nwps.log 
    echo "Run length = ${RUNLEN}" | tee -a ${LOGdir}/run_nwps.log 
    echo "Winds = ${WINDS}" | tee -a ${LOGdir}/run_nwps.log 
    echo "wna = ${WNA}" | tee -a ${LOGdir}/run_nwps.log 
    echo "nests = ${NESTS}" | tee -a ${LOGdir}/run_nwps.log 
    echo "rtofs = ${RTOFS}" | tee -a ${LOGdir}/run_nwps.log 
    echo "waterlevels = ${WATERLEVELS}" | tee -a ${LOGdir}/run_nwps.log 
    echo "excd = ${EXCD}" | tee -a ${LOGdir}/run_nwps.log
    echo "plot = ${PLOT}" | tee -a ${LOGdir}/run_nwps.log 
    echo "web = ${WEB}" | tee -a ${LOGdir}/run_nwps.log 
    echo "hotstart = ${HOTSTART}" | tee -a ${LOGdir}/run_nwps.log
    echo "nodownload = ${NODOWNLOAD}" | tee -a ${LOGdir}/run_nwps.log 
    echo "Custom DELTAC = ${USERDELTAC}" | tee -a ${LOGdir}/run_nwps.log
    echo "Wave model = ${MODELCORE}" | tee -a ${LOGdir}/run_nwps.log
    echo "Primary site ID = ${siteid}" | tee -a ${LOGdir}/run_nwps.log
    if [ "${SITENAME}" != "" ]; then echo "Run as backup site ID = ${SITENAME}" | tee -a ${LOGdir}/run_nwps.log; fi
    if [ "${DOMAINSETUP}" != "" ];  then echo "Domain setup = ${DOMAINSETUP}" | tee -a ${LOGdir}/run_nwps.log; fi 
    if [ "${WINDFILE}" != "" ]; then echo "User defined windfile = ${WINDFILE}" | tee -a ${LOGdir}/run_nwps.log; fi
    echo "" | tee -a ${LOGdir}/run_nwps.log 
fi

if [ "${SITENAME}" != "" ]
then
    echo "Running as the following site: ${SITENAME}" | tee -a ${LOGdir}/run_nwps.log 
    export SITEID=$(echo ${SITENAME} | tr [:lower:] [:upper:])
    export siteid=$(echo ${SITENAME} | tr [:upper:] [:lower:])
    if [ "${DOMAINSETUP}" == "" ] && [ ! -e ${PARMnwps}/templates/${siteid} ]
    then 
	echo "FATAL ERROR: We have no templates for this site" | tee -a ${LOGdir}/run_nwps.log 
	echo "You must run the domain setup or supply a domain with --domainsetup argument" | tee -a ${LOGdir}/run_nwps.log 
	echo "Exiting model run with fatal error" | tee -a ${LOGdir}/run_nwps.log 
	source ${USHnwps}/nwps_config.sh &> /dev/null
	export err=1; err_chk
    fi

    if [ "${DOMAINSETUP}" == "" ] &&  [ ! -e ${PARMnwps}/templates/${siteid}/siteid.sh ]
    then
	echo "FATAL ERROR: We have no siteid.sh template file for this site" | tee -a ${LOGdir}/run_nwps.log 
	echo "FATAL ERROR: Missing site id config ${PARMnwps}/templates/${siteid}/siteid.sh" | tee -a ${LOGdir}/run_nwps.log 
	echo "Exiting model run with fatal error" | tee -a ${LOGdir}/run_nwps.log 
	###source ${USHnwps}/nwps_config.sh &> /dev/null
	export err=1; err_chk
    fi
    ## source ${PARMnwps}/templates/${siteid}/siteid.sh
    ## source ${USHnwps}/nwps_config.sh &> /dev/null
fi

if [ "${DOMAINSETUP}" != "" ]
    then
    echo "Configuring new NWPS domain for this run" | tee -a ${LOGdir}/run_nwps.log 
    echo "Domain setup file: ${DOMAINSETUP}" | tee -a ${LOGdir}/run_nwps.log 
    if [ ! -e ${DOMAINSETUP} ]
	then
	echo "FATAL ERROR: Cannot find domain file ${DOMAINSETUP}" | tee -a ${LOGdir}/run_nwps.log 
	echo "Exiting model run" | tee -a ${LOGdir}/run_nwps.log 
	export err=1; err_chk
    fi
    ${USHnwps}/setup.sh ${DOMAINSETUP} ${NESTS} ${MODELCORE}
    
    if [ "$?" != "0" ]
	then
	echo "FATAL ERROR: Domain setup program failed" | tee -a ${LOGdir}/run_nwps.log 
	echo "Exiting model run" | tee -a ${LOGdir}/run_nwps.log 
	export err=1; err_chk
    fi
    source ${USHnwps}/nwps_config.sh
fi

if [ "${CommandLineWindFileName}" != "" ]
    then
    echo "User has set archived wind file ${CommandLineWindFileName}" | tee -a ${LOGdir}/run_nwps.log 
    touch ${INPUTdir}/SWANflag;
fi

#GET previous hotstart files
#if [ -d "${GESINm1}/hotstart" ]
#  then 
#  cp -f ${GESINm1}/hotstart/*  ${INPUTdir}/hotstart/. >> ${LOGdir}/hotstart.log 2>&1
#else
#  echo "NO previous Hotstart files" 
#fi

#Copying the Hotstart files from GESIN
if [ -e $GESIN/hotstart/${SITEID} ]
   then 
   Prev_HOTdir="$GESIN/hotstart/${SITEID}"
elif [ -e $GESINm1/hotstart/${SITEID} ]
   then
   Prev_HOTdir="$GESINm1/hotstart/${SITEID}"
elif [ -e $GESINm2/hotstart/${SITEID} ]
   then
   Prev_HOTdir="$GESINm2/hotstart/${SITEID}"
else
   echo " NO HOTSTART FILES FOR THIS RUN "| tee -a ${LOGdir}/run_nwps.log
   echo "WARNING: No HOTSTART file available from previous model run. Will instead initialize with stationary model run at first time step." | tee -a ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt
fi

if [ ${Prev_HOTdir} != "" ]
then
   echo " Hotstart files are from ${Prev_HOTdir}"
   cd ${Prev_HOTdir}
   #list the hotstart directories and choose the most recent
   hotfiles_dir=`ls -t -d */ | head -1`
   echo ${hotfiles_dir}
   files=`ls ${hotfiles_dir}`
   cd ${hotfiles_dir}
   
   HOTdir="${INPUTdir}/hotstart"    
   if [ ! -e ${HOTdir} ]; then mkdir -p ${HOTdir}; fi
   cp $files ${HOTdir}/.
fi

#export ${WINDS}
if [ "${MODELCORE}" == "" ]
then 
    MODELCORE=$MODELTYPE
fi

if [ "${WATERLEVELS}" == "" ]
then
    WATERLEVELS="NO"
fi

if [ "${EXCD}" == "" ]
then
    EXCD="10"
fi

#Cleanup
rm ${RUNdir}/Psurge_End_Time
rm ${RUNdir}/nortofs
rm ${RUNdir}/noestofs
rm ${RUNdir}/nopsurge

export MODELCORE=$(echo ${MODELCORE} | tr [:lower:] [:upper:])
export modelcore=$(echo ${MODELCORE} | tr [:upper:] [:lower:])
echo "WAVE MODEL CORE:  ${MODELCORE}" 
echo "Wave model core:  ${modelcore}" | tee -a ${LOGdir}/run_nwps.log
echo "Starting model run" | tee -a ${LOGdir}/run_nwps.log 
echo -n "Start time: "
date -u | tee -a ${LOGdir}/run_nwps.log 

echo "${USHnwps}/nwps_preproc.sh" | tee -a ${LOGdir}/run_nwps.log
echo "RUNLEN=${RUNLEN} WNA=${WNA} NESTS=${NESTS} RTOFS=${RTOFS} WINDS=${WINDS} WEB=${WEB} PLOT=${PLOT} USERDELTAC=${USERDELTAC} HOTSTART=${HOTSTART} WATERLEVELS=${WATERLEVELS} MODELCORE=${MODELCORE} EXCD=${EXCD}" | tee -a ${LOGdir}/run_nwps.log

if [ "${WATERLEVELS}" == "PSURGE" ]
then
   # Include exceedance variable EXCD in forecaster message
   echo "Run settings: RUNLEN=${RUNLEN} WNA=${WNA} NESTS=${NESTS} RTOFS=${RTOFS} WINDS=${WINDS} WEB=${WEB} PLOT=${PLOT} USERDELTAC=${USERDELTAC} HOTSTART=${HOTSTART} WATERLEVELS=${WATERLEVELS} EXCD=${EXCD} MODELCORE=${MODELCORE}" | tee -a ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt
else
   echo "Run settings: RUNLEN=${RUNLEN} WNA=${WNA} NESTS=${NESTS} RTOFS=${RTOFS} WINDS=${WINDS} WEB=${WEB} PLOT=${PLOT} USERDELTAC=${USERDELTAC} HOTSTART=${HOTSTART} WATERLEVELS=${WATERLEVELS} MODELCORE=${MODELCORE}" | tee -a ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt
fi

${USHnwps}/nwps_preproc.sh ${RUNLEN} ${WNA} ${NESTS} ${RTOFS} ${WINDS} ${WEB} ${PLOT} ${USERDELTAC} ${HOTSTART} ${WATERLEVELS} ${MODELCORE} ${EXCD} | tee -a ${LOGdir}/run_nwps.log 
cd ${RUNdir}
hh=`ls *.wnd | cut -c9-10`
COMOUTCYC="${COMOUT}/${hh}"
echo ${hh} > ${RUNdir}/CYCLE

fcstday=`ls *.wnd | cut -c1-8`
echo "Forecast analysis time: ${fcstday} ${hh}Z" | tee -a ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt

mkdir -p $COMOUTCYC $GESOUT/warnings
cp -fv  ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt ${COMOUTCYC}/Warn_Forecaster_${SITEID}.${PDY}.txt
cp -fv  ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt ${GESOUT}/warnings/Warn_Forecaster_${SITEID}.${PDY}.txt

if [ -e ${OUTPUTdir}/netCdf/not_completed ]
    then
    echo "FATAL ERROR: Model run failed" | tee -a ${LOGdir}/run_nwps.log 
    echo "Exiting model run with fatal error" | tee -a ${LOGdir}/run_nwps.log 
    export err=1; err_chk
fi

if [ "${PLOT}" == "YES" ]
then
    echo "NWPS development model run and plotting complete" | tee -a ${LOGdir}/run_nwps.log 
else
    echo "NWPS development model run complete" | tee -a ${LOGdir}/run_nwps.log 
fi

echo -n "End time: "
date -u | tee -a ${LOGdir}/run_nwps.log 
exit 0
# ----------------------------------------------------------- 
# ******************************* 
# ********* End of File ********* 
# ******************************* 

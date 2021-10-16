#!/bin/bash
set -xa
# ----------------------------------------------------------- 
# UNIX Shell Script File
# Tested Operating System(s): RHEL 5,6,7
# Tested Run Level(s): 3, 5
# Shell Used: BASH shell
# Original Author(s): Douglas.Gaer@noaa.gov, Roberto.Padilla@noaa.gov
# File Creation Date: 08/22/2011
# Date Last Modified: 05/26/2017
#
# Version control: 1.30
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
# 05/2017 - Added GFS wind fail over
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
    echo "                          choices: forecaster or gfs"
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
    echo " --wavemodel WaveModel   Specify the wave model to be used, SWAN, UNSWAN or WW3"
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

# Source domain setup to get the setting for NESTGRIDS
# (i.e. whether nests have been defined for this domain or not)
if [ -z "${DOMAINSETUP}" ]; then export DOMAINSETUP="${FIXnwps}/domains/${SITEID}"; fi
source ${DOMAINSETUP}

warnings="NO"

# NOTE: Default variables are defined in master config $USHnwps/nwps_config.sh
# NOTE: The following do not require default values:
#       - SITENAME
#       - DOMAINSETUP
#       - WINDFILE

# Set our default values that will always override forecaster values
Default_RUNLEN="144"       
Default_USERDELTAC="600"
Default_WAVEMODEL="swan"
Default_NESTS="Yes"
Default_PLOT="Yes"

# Set all other default values
Default_WINDS="forecaster"
Default_SWELLS="WNAWave"
Default_RTOFS="Yes"
Default_WEB="NO"
# WW 20201016 set COLDSTART in ecFlow_ui if necessary
# Default_HOTSTART="TRUE"
[ ${COLDSTART} == "YES" ] && Default_HOTSTART="FALSE" || Default_HOTSTART="TRUE"
#
Default_WATERLEVELS="ESTOFS"
Default_EXCD="10"

# Check for unset ENV vars
if [ -z "${RETROSPECTIVE}" ]; then RETROSPECTIVE="FALSE"; fi

# Forecaster warning log file
. ${DATA}/PDY
cat /dev/null > ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt
date_hh_mm_ss=$(date)
echo "NWPS run started on ${date_hh_mm_ss}" | tee -a ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt

# Do any cleanup from previous run here
if [ -e ${INPUTdir}/${siteid}_inp_args.ctl ]; then rm -f ${INPUTdir}/${siteid}_inp_args.ctl; fi

if [ "${RETROSPECTIVE}" == "TRUE" ]; then
    echo "Using forecaster wind file from archive" >> ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt
    echo "Using forecaster wind file from archive" | tee -a ${LOGdir}/run_nwps.log 
    echo "GFS wind forcing will be disabled" | tee -a ${LOGdir}/run_nwps.log  
    WINDS="forecaster"
fi

#------------------------------------------------------------
#-----  SET WIND SOURCE WITH WHICH TO FORCE THE MODEL -----
#------------------------------------------------------------
WINDS=$(echo ${WINDS} | tr [:upper:] [:lower:])
if [ "${WINDS,,}" != "gfs" ] || [ "${WINDS,,}" != "forecaster" ]; then WINDS="forecaster"; fi
 
# 05/19/2017: Added to check GFE winds from forecast office
if [ "${WINDS,,}" == "forecaster" ]; then
    if [ "${RETROSPECTIVE^^}" != "TRUE" ]; then
	echo "Wind forcing setup to forecaster" | tee -a ${LOGdir}/run_nwps.log 
	echo "RETROSPECTIVE mode is set to ${RETROSPECTIVE}" | tee -a ${LOGdir}/run_nwps.log 
	echo "Checking the GFE wind file sent by forecast office" | tee -a ${LOGdir}/run_nwps.log 
	NewestWind=$(basename $(ls -t ${FORECASTWINDdir}/NWPSWINDGRID_${siteid}* | head -1))
	if [ "${NewestWind}" == "" ]; then
	    warnings="YES"
	    echo "WARNING - Cannot find any current GFE wind files, switching to GFS" | tee -a ${LOGdir}/run_nwps.log
	    echo "WARNING: Cannot find any current GFE wind files, switching to GFS" >>  ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt
	    WINDS="gfs"
	else
	    echo "Testing the GFE forecaster grid inputs" | tee -a ${LOGdir}/run_nwps.log
	    # NOTE: Future builds will include GFE wind grids and GFE water levels
	    # NOTE: This build will only use GFE wind grids
	    if [ -d ${VARdir}/gfe_grids_test ]; then rm -f ${VARdir}/gfe_grids_test/*; fi
	    mkdir -pv ${VARdir}/gfe_grids_test
            #AW
            cp -fv ${FORECASTWINDdir}/${NewestWind} ${VARdir}/gfe_grids_test/.
            #AW
	    tar xvfz ${FORECASTWINDdir}/${NewestWind} -C ${VARdir}/gfe_grids_test
	    windfile=$(ls -1t --color=none ${VARdir}/gfe_grids_test/${siteid}*WIND.txt | head -1)
	    # We still need a copy of our CTL file, even if we fail over to GFS wind init. First test whether present, then check contents, then copy.
	    ctlfile=$(ls -1t --color=none ${VARdir}/gfe_grids_test/${siteid}_inp_args.ctl | head -1)
            if [ "${ctlfile}" == "" ]; then
               echo "FATAL ERROR: CTL file missing in AWIPS submission. NWPS will not be executed." | tee -a ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt
               msg="FATAL ERROR: CTL file missing in AWIPS submission. NWPS will not be executed."
               postmsg "$jlogfile" "$msg"
               cp -fv  ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt ${GESOUT}/warnings/Warn_Forecaster_${SITEID}.${PDY}.txt
               echo "ABORTED $FORECASTWINDdir/${NewestWind} AT $(date -u "+%Y%m%d%H%M")" >> ${dcom_hist}
               export err=1; err_chk
            else
               numlines=$(cat ${ctlfile} | wc -l)
               numchars=$(cat ${ctlfile} | wc -c)
               if [ "$numlines" -ne 1 ] || [ "$numchars" -lt 51 ] || [ "$numchars" -gt 76 ]
               then
                  echo "FATAL ERROR: CTL file from AWIPS is corrupt. NWPS will not be executed." | tee -a ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt
                  msg="FATAL ERROR: CTL file from AWIPS is corrupt. NWPS will not be executed."
                  postmsg "$jlogfile" "$msg"
                  cp -fv  ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt ${GESOUT}/warnings/Warn_Forecaster_${SITEID}.${PDY}.txt
                  echo "ABORTED $FORECASTWINDdir/${NewestWind} AT $(date -u "+%Y%m%d%H%M")" >> ${dcom_hist}
                  export err=1; err_chk
               else
	          cp -fpv ${ctlfile} ${INPUTdir}/${siteid}_inp_args.ctl
               fi
            fi
	    let minwindhours=${Default_RUNLEN}+1 # NOTE: We need to have the 1 extra hour to nested grids
	    #AW ${EXECnwps}/check_awips_windfile --max-speed 199. --verbose --debug ${windfile} > ${LOGdir}/gfe_wind_file_check.log
	    ${EXECnwps}/check_awips_windfile --verbose --debug ${windfile} > ${LOGdir}/gfe_wind_file_check.log
	    if [ $? -ne 0 ]; then
		warnings="YES"
		echo "WARNING - We received bad GFE wind file, forecaster wind file has bad values. Will fail over to GFS data." | tee -a ${LOGdir}/run_nwps.log
		echo "WARNING: We received bad GFE wind file, forecaster wind file has bad values. Will fail over to GFS data." >> ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt
		WINDS="gfs"
	    else
		echo "GFE wind grid passed wind file check" | tee -a ${LOGdir}/run_nwps.log
		echo "Checking number of GFE wind fields" | tee -a ${LOGdir}/run_nwps.log
	    	Num_wind_fields=$(grep -i 'Wind_Mag_SFC(DIM_' ${windfile} | awk -F'(' '{ print $2 }' | awk -F',' '{ print $1 }' | awk -F'_' '{ print $2 }')
		echo "Number of wind fields on file: ${Num_wind_fields}" | tee -a ${LOGdir}/run_nwps.log
		if [ "$Num_wind_fields" == "" ]
		then
		    echo "WARNING - Wind file ${NewestWind} is empty. Will fail over to GFS data." | tee -a ${LOGdir}/run_nwps.log
		    echo "WARNING: Wind file ${NewestWind} is empty. Will fail over to GFS data." >> ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt
		    warnings="YES"
		    WINDS="gfs"
		else 
		    if [ ${Num_wind_fields} -lt ${minwindhours} ]; then
			echo "WARNING - Wind fields = ${Num_wind_fields}, must be >= ${minwindhours}. Will fail over to GFS data." | tee -a ${LOGdir}/run_nwps.log
			echo "WARNING: Wind fields = ${Num_wind_fields}, must be >= ${minwindhours}. Will fail over to GFS data." >> ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt
			warnings="YES"
			WINDS="gfs"
		    else
			echo "GFE wind grid has ${Num_wind_fields} wind fields" | tee -a ${LOGdir}/run_nwps.log
		    fi
		fi
	    fi
	fi
    fi
fi

# Check to ensure that we can unpack the GFE wind file in our ${INPUTdir}
if [ "${WINDS,,}" == "forecaster" ]; then
    NewestWind=$(basename `ls -t ${FORECASTWINDdir}/NWPSWINDGRID_${siteid}* | head -1`)
    echo "Most Recent wind file for ${SITEID}: ${NewestWind}" | tee -a ${LOGdir}/run_nwps.log
    cd ${INPUTdir}/
    # Delete previous wind files, and copy newest input file
    if [ "${RETROSPECTIVE^^}" != "TRUE" ]; then
        rm -fv *.tar.gz ${siteid}*WIND.txt
        cp -fv ${FORECASTWINDdir}/${NewestWind} ${INPUTdir}/.
	tar xvfz ${INPUTdir}/${NewestWind}
	WindFileName=`ls -t ${siteid}*WIND.txt | head -1`
	if [ ! -f "${WindFileName}" ]
	then
	    echo "WARNING - Wind file ${WindFileName} not transmitted. Will fail over to GFS data." | tee -a ${LOGdir}/run_nwps.log
	    echo "WARNING: Wind file ${WindFileName} not transmitted. Will fail over to GFS data." >> ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt
	    warnings="YES"
	    WINDS="gfs"
        else
            # Check that the initialization time in the GFE wind file is not more than 6 h in the future
            init_epoch=`grep Wind_Mag_SFC:validTimes ${WindFileName} | cut -c29-38 | tail -1`
            pdy_epoch=`date +%s`
            init_str=`date -d @${init_epoch} +'%Y%m%d %HZ'`
            init_win1_str=`date -d "-72 hours" +'%Y%m%d %HZ'`
            init_win2_str=`date -d "+6 hours" +'%Y%m%d %HZ'`
            if [ "$(( ${init_epoch} - ${pdy_epoch} ))" -gt 21600 ]; then
               echo "FATAL ERROR: Forecast analysis time ${init_str} is too far in the future. NWPS will not be executed. Resubmit with an analysis time between ${init_win1_str} and ${init_win2_str}." >> ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt
               msg="FATAL ERROR: Forecast analysis time ${init_str} is too far in the future. NWPS will not be executed. Resubmit with an analysis time between ${init_win1_str} and ${init_win2_str}."
               postmsg "$jlogfile" "$msg"
               cp -fv  ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt ${GESOUT}/warnings/Warn_Forecaster_${SITEID}.${PDY}.txt
               echo "ABORTED $FORECASTWINDdir/${NewestWind} AT $(date -u "+%Y%m%d%H%M")" >> ${dcom_hist}
               export err=1; err_chk
            fi
	fi 
    fi
fi

# Set the Wind file name for archive case runs
if [ "${WINDS,,}" == "forecaster" ] && [ "${RETROSPECTIVE^^}" == "TRUE" ]; then
    # Use wind file from Archive
    rm ${RUNdir}/*.wnd
    NewestWind=$(basename `ls -t ${INPUTdir}/NWPSWINDGRID_${siteid}* | head -1`)
    if [ -f ${INPUTdir}/${NewestWind} ]; then tar xvfz ${INPUTdir}/${NewestWind}; fi
fi

# Read our contol file here
if [ ! -e ${INPUTdir}/${siteid}_inp_args.ctl ]
then
    if [ "${RUNLEN}" == "" ]; then export RUNLEN="${Default_RUNLEN}"; fi
    if [ "${SWELLS}" == "" ]; then export SWELLS="${Default_SWELLS}"; fi
    if [ "${NESTS}" == "" ]; then export NESTS="${Default_NESTS}"; fi
    if [ "${RTOFS}" == "" ]; then export RTOFS="NO"; fi
    if [ "${WINDS}" == "" ]; then export WINDS="${WINDS}"; fi
    if [ "${WEB}" == "" ]; then export WEB="${Default_WEB}"; fi
    if [ "${PLOT}" == "" ]; then export PLOT="${Default_PLOT}"; fi
    if [ "${USERDELTAC}" == "" ]; then export USERDELTAC="${Default_USERDELTAC}"; fi
    if [ "${HOTSTART}" == "" ]; then export HOTSTART="${Default_HOTSTART}"; fi
    if [ "${WATERLEVELS}" == "" ]; then export WATERLEVELS="NO"; fi
    if [ "${WAVEMODEL}" == "" ]; then export WAVEMODEL="${Default_WAVEMODEL}"; fi
    if [ "${EXCD}" == "" ]; then export EXCD="${Default_EXCD}"; fi
    INPARGS="${RUNLEN}:${SWELLS}:${NESTS}:${RTOFS}:${WINDS}:${WEB}:${PLOT}:${USERDELTAC}:${HOTSTART}:${WATERLEVELS}:${WAVEMODEL}:${EXCD}"
    echo "INFO - Creating default ${INPUTdir}/${siteid}_inp_args.ctl" | tee -a ${LOGdir}/run_nwps.log 
    echo "INPUTARGS->${INPARGS}" | tee -a ${LOGdir}/run_nwps.log 
    echo "${INPARGS}" > ${INPUTdir}/${siteid}_inp_args.ctl
fi

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
# NOTE: Only use the GUI wind input if we passed our GFE wind file checks
if [ "${WINDS,,}" == "forecaster" ]; then export WINDS="${fromgui[4]}"; fi
# NOTE: The GUI will use ForecastWindGrids string for forecaster grids
if [ "${WINDS}" == "ForecastWindGrids" ]; then WINDS="forecaster"; fi
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

if [ "${WINDS,,}" == "gfs" ]
then
    echo "Starting model run with ${WINDS} winds" | tee -a ${LOGdir}/run_nwps.log 
    echo "Starting model run with ${WINDS} winds" >> ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt

    # Check for today's GFS run, if not available use yesterday's run
    if [ ! -d ${COMINgfs} ]
    then
	export COMINgfs=${COMINgfsm1}
    fi

    # Get our latest GFS wind files
    ${USHnwps}/gfswind/bin/get_gfswind.sh
    if [ "$?" != "0" ] 
    then
	echo "FATAL ERROR: Could not init ${WINDS} winds" | tee -a ${LOGdir}/run_nwps.log
	echo "Exiting model run with fatal error" | tee -a ${LOGdir}/run_nwps.log 
	export err=1; err_chk
    fi
else
    echo "Starting model run with forecaster winds from GFE" | tee -a ${LOGdir}/run_nwps.log 
    echo "Starting model run with forecaster winds from GFE" >> ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt
    WINDS="forecaster"

    cd ${INPUTdir}/
    WindFileName=`ls -t ${siteid}*WIND.txt | head -1`

    if [ "${RETROSPECTIVE^^}" == "TRUE" ]; then
	echo "Using archived forecaster wind file for ${SITEID}" | tee -a ${LOGdir}/run_nwps.log
	if [ ! -f "${WindFileName}" ]; then
            warnings="YES"
            echo "FATAL ERROR: Missing archive file ${INPUTdir}/${WindFileName}." | tee -a ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt
            msg="FATAL ERROR: NWPS will not be executed due to absent archived wind file."
            postmsg "$jlogfile" "$msg"
            mkdir -p $GESOUT/warnings
            cp -fv  ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt ${GESOUT}/warnings/Warn_Forecaster_${SITEID}.${PDY}.txt
            echo "ABORTED $FORECASTWINDdir/${NewestWind} AT $(date -u "+%Y%m%d%H%M")" >> ${dcom_hist}
            export err=1; err_chk
	fi
    else
	echo "Forecaster wind file has arrived from ${SITEID}" | tee -a ${LOGdir}/run_nwps.log 
    fi
    touch ${INPUTdir}/SWANflag

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

    mkdir -p ${INPUTdir}/wind
    if [ -e ${INPUTdir}/wind/* ]; then rm ${INPUTdir}/wind/*; fi
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

fi

# Post run checks after wind init
if [ "${RUNLEN}" -ne "${Default_RUNLEN}" ] || [ "${USERDELTAC}" -ne "${Default_USERDELTAC}" ] || \
    [ "${WNA}" == "TAFB-NWPS" ] || [ "${WNA}" == "HURWave" ] || [ "${WAVEMODEL^^}" != "${Default_WAVEMODEL^^}" ] || \
    [ "${PLOT^^}" != "${Default_PLOT^^}" ] || \
    [ "${NESTS^^}" != "${Default_NESTS^^}" -a "${NESTGRIDS}" -ne 0 ] || \
    [ "${NESTS^^}" == "${Default_NESTS^^}" -a "${NESTGRIDS}" -eq 0 ]
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
if [ "${WNA}" == "TAFB-NWPS" ]
then
    echo "WARNING: NWPS-WCOSS is not ready to ingest TAFB boundary conditions. Will use boundary conditions from WW3_multi1 (WNAWave)." | tee -a ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt
    export WNA="WNAWave"
    warnings="YES"
fi
if [ "${WNA}" == "HURWave" ]
then
    echo "WARNING: WW3_multi2 (HURWave) boundary condition option is no longer supported. Will use boundary conditions from WW3_multi1 (WNAWave)." | tee -a ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt
    export WNA="WNAWave"
    warnings="YES"
fi
if [ "${WAVEMODEL^^}" != "${Default_WAVEMODEL^^}" ]
then
    echo "WARNING: User input WAVEMODEL=${WAVEMODEL} not equal to Default_WAVEMODEL=${Default_WAVEMODEL}. Will run using the wave model ${Default_WAVEMODEL}." | tee -a ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt
    warnings="YES"
fi
if [ "${PLOT^^}" != "${Default_PLOT^^}" ]
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

# Set WINDS to GFS or FORECASTER
if [ "${WINDS,,}" == "forecaster" ]; then WINDS="ForecastWindGrids"; fi
export WINDS=${WINDS^^}

#.......FIXED DEFAULT VALUES DISREGARDING THE VALUES FROM THE FORECASTER
export RUNLEN=${Default_RUNLEN}
export USERDELTAC=${Default_USERDELTAC}
export WAVEMODEL=${Default_WAVEMODEL}
export PLOT=${Default_PLOT}
export DOMAINSET="${FIXnwps}/domains/${SITEID}"
export HOTSTART=${Default_HOTSTART}
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

# Set periodic stationary start to suppress hotspot build-up
if ( [ "${SITEID}" == "KEY" ] || [ "${SITEID}" == "MFL" ] || \
     [ "${SITEID}" == "MLB" ] || [ "${SITEID}" == "JAX" ] || \
     [ "${SITEID}" == "CHS" ] || [ "${SITEID}" == "ILM" ] ) && \
     [ $(date -d "$D" '+%d') == '01' ]
then
  echo "Setting periodic stationary start to suppress hotspot build-up due to Gulf Stream currents"
  HOTSTART="FALSE" 
fi

# Set the model core: Regular grid SWAN or unstructured mesh UNSWAN
if [ "${SITEID}" == "MHX" ] || [ "${SITEID}" == "TBW" ] || [ "${SITEID}" == "MFL" ] \
   || [ "${SITEID}" == "BOX" ] || [ "${SITEID}" == "OKX" ] || [ "${SITEID}" == "SGX" ] \
   || [ "${SITEID}" == "CAR" ] || [ "${SITEID}" == "HFO" ] || [ "${SITEID}" == "AKQ" ] \
   || [ "${SITEID}" == "SJU" ] || [ "${SITEID}" == "GUM" ] || [ "${SITEID}" == "ALU" ] \
   || [ "${SITEID}" == "GUA" ] || [ "${SITEID}" == "MLB" ] || [ "${SITEID}" == "JAX" ] \
   || [ "${SITEID}" == "CHS" ] || [ "${SITEID}" == "ILM" ] || [ "${SITEID}" == "PHI" ] \
   || [ "${SITEID}" == "GYX" ] || [ "${SITEID}" == "KEY" ] || [ "${SITEID}" == "TAE" ] \
   || [ "${SITEID}" == "MOB" ] || [ "${SITEID}" == "HGX" ]
then
   export MODELCORE="UNSWAN"
else
   export MODELCORE="SWAN"
fi

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

#Get previous hotstart files
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

##Copy the Hotstart files from GESIN based on the wind start time
#if [ "${Prev_HOTdir}" != "" ]
#then
#   echo " Hotstart files are from ${Prev_HOTdir}"
#   cd ${Prev_HOTdir}
#   #List the cycles in the hotstart directory and choose the most recent one
#   hotfiles_dir=`ls -t -d * | head -1`
#   echo ${hotfiles_dir}
#   cd ${hotfiles_dir}
#   if [ ${MODELCORE} == "SWAN" ]; then
#      files=${fcstday}.${hh}*
#   elif [ ${MODELCORE} == "UNSWAN" ]; then
#      files=PE*/${fcstday}.${hh}00
#   fi
#   HOTdir="${INPUTdir}/hotstart"    
#   if [ ! -e ${HOTdir} ]; then mkdir -p ${HOTdir}; fi
#   cp --parents $files ${HOTdir}/.
#fi

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

#AW # 05/25/2017: If using RTOFS or water levels, check to see if we have init files
#AW if [ "${RTOFS^^}" == "YES" ]; then
#AW     export RTOFS="YES" # Signal pre-processing script to get NCEP init files
#AW     if [ ! -d ${COMINrtofs} ]; then
#AW 	if [ ! -d ${COMINrtofsm1} ]; then
#AW 	    export RTOFS="NO" # Signal pre-processing skip this init
#AW 	    echo "WARNING: RTOFS input selected but we have no input files, disabling RTOFS" | tee -a ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt
#AW 	fi
#AW     fi
#AW fi
#AW 
#AW 
#AW if [ "${WATERLEVELS^^}" == "YES" ] || [ "${WATERLEVELS^^}" == "ESTOFS" ]; then
#AW     export WATERLEVELS="ESTOFS"
#AW     export ESTOFS="YES" # Signal pre-processing script to get NCEP init files
#AW     if [ ! -d ${COMINestofs} ]; then
#AW 	if [ ! -d ${COMINestofsm1} ]; then
#AW 	    export WATERLEVELS="NO"
#AW 	    export ESTOFS="NO" # Signal pre-processing skip this init
#AW 	    echo "WARNING: ESTOFS input selected but we have no input files, disabling ESTOFS" | tee -a ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt
#AW 	fi
#AW     fi
#AW fi
#AW 
#AW if [ "${WATERLEVELS^^}" == "PSURGE" ]; then
#AW     export WATERLEVELS="PSURGE"
#AW     export PSURGE="YES" # Signal pre-processing script to get NCEP init files
#AW     if [ ! -d ${COMINpsurge} ]; then
#AW 	if [ ! -d ${COMINpsurgem1} ]; then
#AW 	    export WATERLEVELS="NO"
#AW 	    export PSURGE="NO" # Signal pre-processing skip this init
#AW 	    echo "WARNING: PSURGE input selected but we have no input files, disabling PSURGE" | tee -a ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt
#AW 	fi
#AW     fi
#AW fi

#Cleanup
if [ -e ${RUNdir}/Psurge_End_Time ]; then rm ${RUNdir}/Psurge_End_Time; fi
if [ -e ${RUNdir}/nortofs ]; then rm ${RUNdir}/nortofs; fi
if [ -e ${RUNdir}/noestofs ]; then rm ${RUNdir}/noestofs; fi
if [ -e ${RUNdir}/nopsurge ]; then rm ${RUNdir}/nopsurge; fi

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

echo "${USHnwps}/nwps_preproc.sh ${RUNLEN} ${WNA} ${NESTS} ${RTOFS} ${WINDS} ${WEB} ${PLOT} ${USERDELTAC} ${HOTSTART} ${WATERLEVELS} ${MODELCORE} ${EXCD}" | tee -a ${LOGdir}/run_nwps.log
${USHnwps}/nwps_preproc.sh ${RUNLEN} ${WNA} ${NESTS} ${RTOFS} ${WINDS} ${WEB} ${PLOT} ${USERDELTAC} ${HOTSTART} ${WATERLEVELS} ${MODELCORE} ${EXCD} | tee -a ${LOGdir}/run_nwps.log 
export err=$?; err_chk

cd ${RUNdir}
hh=`ls *.wnd | cut -c9-10`
export COMOUTCYC="${COMOUT}/${hh}"
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

# Added the label here - JY 01/18/2019
ecflow_client --alter change label DCOM "`echo $NewestWind`" $ECF_NAME

echo -n "End time: "
date -u | tee -a ${LOGdir}/run_nwps.log 
exit 0
# ----------------------------------------------------------- 
# ******************************* 
# ********* End of File ********* 
# ******************************* 

#!/bin/bash
set -xa
# ----------------------------------------------------------- 
# UNIX Shell Script File
# Tested Operating System(s): RHEL 5,6
# Tested Run Level(s): 3, 5
# Shell Used: BASH shell
# Original Author(s): Douglas.Gaer@noaa.gov
# File Creation Date: 01/29/2013
# Date Last Modified: 11/18/2014
#
# Version control: 1.06
#
# Support Team:
#
# Contributors: Douglas Gaer, Pablo Santos
# ----------------------------------------------------------- 
# ------------- Program Description and Details ------------- 
# ----------------------------------------------------------- 
#
# Script used to download RTOFS, STOFS, init files 
# from NCEP by site. 
#
# ----------------------------------------------------------- 

# Check to see if our SITEID is set
if [ "${SITEID}" == "" ]
    then
    echo "ERROR - Your SITEID variable is not set"
    export err=1; err_chk
fi

# Setup our NWPS environment                                                    
if [ "${USHnwps}" == "" ]
    then 
    echo "ERROR - Your USHnwps variable is not set"
    export err=1; err_chk
fi

if [ -e ${USHnwps}/psurge_config.sh ]
then
    source ${USHnwps}/psurge_config.sh
else
    echo "ERROR - Cannot find ${USHnwps}/psurge_config.sh"
    export err=1; err_chk
fi

if [ -e ${USHnwps}/nwps_config.sh ]
then
    source ${USHnwps}/nwps_config.sh
else
    echo "ERROR - Cannot find ${USHnwps}/nwps_config.sh"
    export err=1; err_chk
fi

#Cleanup (AW 11-01-15: Moved to run_nwps_wcoss.sh)
#rm ${RUNdir}/Psurge_End_Time
#rm ${RUNdir}/nortofs
#rm ${RUNdir}/nostofs
#rm ${RUNdir}/nopsurge

#SITE="polar.ncep.noaa.gov"
#SITE="www.ftp.ncep.noaa.gov"
#ES_RTOFS_PSurgedir="${COMROOT}/${NET}/${envir}"
#export ES_RTOFS_PSurgedir="/com/${model}/${envir}"
echo " ========== IN GET_NCEP_INITFILES.SH ==================="
echo "Copying ${1} fields for SITE: ${siteid}"

if [ $# -eq 1 ]
then
  date=`date +%Y%m%d`
  datey=`date +%Y%m%d --date=yesterday`
  #RTOFSPATH="ofs.${PDY}/rtofs/${siteid}_output"
  #RTOFSPATHY="ofs.${PDYm1}/rtofs/${siteid}_output"
  #STOFSPATH="ofs.${PDY}/stofs/${siteid}_output"
  #STOFSPATHY="ofs.${PDYm1}/stofs/${siteid}_output"
  #PSURGEPATH="ofs.${PDY}/psurge/${siteid}_output"
  #PSURGEPATHY="ofs.${PDYm1}/psurge/${siteid}_output"
else
  date=${2}
  #RTOFSPATH="ofs.${PDY}/rtofs/${siteid}_output"
  #STOFSPATH="ofs.${PDY}/stofs/${siteid}_output"
  #PSURGEPATH="ofs.${PDY}/psurge/${siteid}_output"
fi

WGETargs="--mirror -nv --tries=5 --no-parent --timeout=60 --no-directories --level=1"
WGET="/usr/bin/wget"

echo "Downloading NCEP init files for NWPS"
/bin/date -u

/bin/mkdir -p ${LDMdir}/rtofs ${LDMdir}/stofs ${LDMdir}/psurge


list_zerobyte_files_in_dir () {
  # $1 = directory
  # $2 = filename glob (e.g. "wave_rtofs_uv_*.dat")
  local d="$1"
  local g="$2"
  [ -d "$d" ] || return 0
  find "$d" -maxdepth 1 -type f -name "$g" -size 0 -print | sort
}

warn_and_disable_forcing () {
  # $1 = tag (RTOFS/STOFS/PSURGE)
  # $2 = full warning message
  # $3 = flag file to touch (e.g. ${RUNdir}/nortofs)
  # $4 = optional list of 0-byte files (full paths), may be empty
  local tag="$1"
  local msg="$2"
  local flag="$3"
  local files="$4"
  local warnfile="${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt"

  mkdir -p "$COMOUTCYC" "$GESOUT/warnings"

  echo "WARNING: ${msg}" | tee -a "${LOGfile}" "${warnfile}"
  cp -fv "${warnfile}" "${COMOUTCYC}/Warn_Forecaster_${SITEID}.${PDY}.txt" >/dev/null 2>&1 || true
  cp -fv "${warnfile}" "${GESOUT}/warnings/Warn_Forecaster_${SITEID}.${PDY}.txt" >/dev/null 2>&1 || true
  postmsg "$jlogfile" "WARNING: ${msg}"

  # put file list detail in LOG only
  if [ -n "$files" ]; then
    {
      echo "WARNING: ${tag}: 0-byte forcing files detected:"
      echo "$files"
    } >> "${LOGfile}"
  fi

  touch "$flag"
}


if [ $1 == "RTOFS" ]
then
   cd ${LDMdir}/rtofs
   pwd
   if [ $# -eq 1 ]
   then
      echo "Downloading RTOFS Data. Checking Yesterday First."
      if [ -e ${COMIN_OFS_rtofsm1}/LOCKFILE ]; then sleep 600; fi
      if [ -e ${COMIN_OFS_rtofsm1}/rtofs_current_start_time.txt ]
      then
         zfiles=$(list_zerobyte_files_in_dir "${COMIN_OFS_rtofsm1}" "wave_rtofs_uv_*.dat")
         if [ -n "$zfiles" ]; then
            warn_and_disable_forcing \
              "RTOFS" \
              "There are invalid RTOFS data in ${COMIN_OFS_rtofsm1} (0-byte *.dat files). Run will try Today's data." \
              "${RUNdir}/nortofs" \
              "$zfiles"
         else
            cp -pfv ${COMIN_OFS_rtofsm1}/* .
            rm -fr index.* robots.*
         fi
      else
         echo "WARNING: Optional RTOFS data not available for Yesterday."
      fi
   fi

   #Check whether wind file initialization time (=run start time) falls within yesterday. 
   # If it does, we shouldn't download today's RTOFS data. 
   YYYY=`echo ${PDY} | cut -b1-4`
   MM=`echo ${PDY} | cut -b5-6`
   DD=`echo ${PDY} | cut -b7-8`
   time_str="${YYYY} ${MM} ${DD} 00 00 00"
   pdy_time=`echo ${time_str} | awk -F: '{ print mktime($1 $2 $3 $4 $5 $6) }'`
   #AW model_start_time=`grep Wind_Mag_SFC:validTimes ${INPUTdir}/wind/*WIND.txt | cut -c29-38 | tail -1`
   windsource=`cat ${RUNdir}/windsource.flag`
   if [ "$windsource" == "FORECASTWINDGRIDS" ]; then
      model_start_time=`grep Wind_Mag_SFC:validTimes ${INPUTdir}/wind/*WIND.txt | cut -c29-38 | tail -1`
   elif [ "$windsource" == "GFS" ]; then
      NewestWind=$(basename $(ls -t ${VARdir}/gfe_grids_test/NWPSWINDGRID_${siteid}* | head -1))
      if [ "$NewestWind" != "" ]; then
         YYYY=$(echo $NewestWind|cut -c18-21)
         MM=$(echo $NewestWind|cut -c22-23)
         DD=$(echo $NewestWind|cut -c24-25)
         windhour=$(echo $NewestWind|cut -c26-27)
         time_str="${YYYY} ${MM} ${DD} ${windhour} 00 00"
         model_start_time=`echo ${time_str} | awk -F: '{ print mktime($1 $2 $3 $4 $5 $6) }'`
      fi
   fi
   echo "PDY in UNIX time: ${pdy_time}" | tee -a ${LOGfile}
   echo "Model start UNIX time: ${model_start_time}" | tee -a ${LOGfile}

   if [ $model_start_time -ge $pdy_time ]
   then
      echo "Downloading RTOFS Data. Checking Today."
      #${WGET} ${WGETargs} http://${SITE}/${RTOFSPATH}
      if [ -e ${COMIN_OFS_rtofs}/LOCKFILE ]; then sleep 600; fi
      if [ -e ${COMIN_OFS_rtofs}/rtofs_current_start_time.txt ]
      then
         zfiles=$(list_zerobyte_files_in_dir "${COMIN_OFS_rtofs}" "wave_rtofs_uv_*.dat")
	 if [ -n "$zfiles" ]; then
            warn_and_disable_forcing \
              "RTOFS" \
              "There are invalid RTOFS data in ${COMIN_OFS_rtofs} (0-byte *.dat files). Run will continue without surface current fields." \
              "${RUNdir}/nortofs" \
              "$zfiles"
         else
            cp -pfv ${COMIN_OFS_rtofs}/* .
	    rm -fr index.* robots.*
	 fi
      else
         echo "WARNING: Optional RTOFS data not available for Today."
      fi
   else
      echo "Wind initialization time is yesterday. Don't need today's RTOFS data."
   fi 

   echo "Cleaning OLD data from RTOFS Directory"
   if [ -e rtofs_current_start_time.txt ]
   then
      start_time=`cat rtofs_current_start_time.txt`
      file=`ls wave_rtofs_uv_${start_time}_*_f000.dat`
      cycle=`echo $file | cut -c26-36`
      for i in $(ls wave_rtofs_uv*.dat)
      do
         init_time=`echo $i | cut -c15-24`
         fhour=`echo $i | cut -c39-41`
         echo "Processing $i $init_time $start_time $fhour $cycle"
         if [ $init_time -lt $start_time ]  && [ -e wave_rtofs_uv_${start_time}_${cycle}_f144.dat ]
         then
            echo "Removing $i"
            rm -f $i
         fi
      done
   else
      mkdir -p $COMOUTCYC $GESOUT/warnings
      echo "WARNING: There are no RTOFS data available (neither today nor yesterday). Run will continue without surface current fields." | tee -a ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt
      cp -fv  ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt ${COMOUTCYC}/Warn_Forecaster_${SITEID}.${PDY}.txt
      cp -fv  ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt ${GESOUT}/warnings/Warn_Forecaster_${SITEID}.${PDY}.txt
      msg="WARNING: There are no RTOFS data available (neither today nor yesterday). Run will continue without surface current fields."
      postmsg "$jlogfile" "$msg"
      touch ${RUNdir}/nortofs
   fi

elif [ $1 == "STOFSCUR" ]
then
   cd ${LDMdir}/stofs
   pwd
   if [ $# -eq 1 ]
   then
      echo "Downloading STOFS current Data. Checking Yesterday First."
      #${WGET} ${WGETargs} http://${SITE}/${STOFSPATHY}
      if [ -e ${COMIN_OFS_stofsm1}/LOCKFILE ]; then sleep 600; fi 
      if [ -e ${COMIN_OFS_stofsm1}/stofs_current_start_time.txt ]
      then
         zfiles=$(list_zerobyte_files_in_dir "${COMIN_OFS_stofsm1}" "wave_stofs_uv*.dat")
	 if [ -n "$zfiles" ]; then
	    warn_and_disable_forcing \
              "STOFS" \
              "There are invalid STOFS current data in ${COMIN_OFS_stofsm1} (0-byte *.dat files). Run will continue without current." \
              "${RUNdir}/nostofs_cur" \
              "$zfiles"
         else
	    cp -pfv ${COMIN_OFS_stofsm1}/wave_stofs_uv* .
	    cp -pfv ${COMIN_OFS_stofsm1}/stofs_current_domain.txt .
	    cp -pfv ${COMIN_OFS_stofsm1}/stofs_current_start_time.txt .
	    rm -fr index.* robots.*
	 fi
      else
         echo "WARNING: Optional STOFS current data not available for Yesterday."
      fi
   fi
   echo "Downloading STOFS current data for Today"
   ##${WGET} ${WGETargs} http://${SITE}/${STOFSPATH}
   if [ -e ${COMIN_OFS_stofs}/LOCKFILE ]; then sleep 600; fi
   if [ -e ${COMIN_OFS_stofs}/stofs_current_start_time.txt ]
   then
      zfiles=$(list_zerobyte_files_in_dir "${COMIN_OFS_stofs}" "wave_stofs_uv*.dat")
      if [ -n "$zfiles" ]; then
	 warn_and_disable_forcing \
           "STOFS" \
           "There are invalid STOFS current data in ${COMIN_OFS_stofs} (0-byte *.dat files). Run will continue without current." \
           "${RUNdir}/nostofs_cur" \
	   "$zfiles"
      else
         cp -pfv ${COMIN_OFS_stofs}/wave_stofs_uv* .
         cp -pfv ${COMIN_OFS_stofs}/stofs_current_domain.txt .
         cp -pfv ${COMIN_OFS_stofs}/stofs_current_start_time.txt .
         rm -fr index.* robots.*
      fi
   else
      echo "WARNING: Optional STOFS current data not available for Today."
   fi
   echo "Cleaning OLD data from STOFS Directory"
   if [ -e stofs_current_start_time.txt ]
   then
      start_time=`cat stofs_current_start_time.txt`
      file=`ls wave_stofs_uv_${start_time}_*_f000.dat`
      #XXXXXXXXXXXcycle=`echo $file | cut -c35-45`
      #send inside the next for
      for i in $(ls wave_stofs_uv*.dat)
      do
         init_time=`echo $i | cut -c24-33`
         fhour=`echo $i | cut -c48-50`
         cycle=`echo $i | cut -c44-45`
         echo "Processing $i $init_time $start_time $fhour $cycle"
         if [ $init_time -lt $start_time ]  && [ -e wave_stofs_uv_${start_time}_${cycle}_f144.dat ]
         then
            echo "Removing $i"
            rm -f $i
         fi
      done
   else
      echo "WARNING: There are no STOFS current data available (neither today nor yesterday). Run will continue without wave-current interaction." | tee -a ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt
      msg="WARNING: There are no STOFS current data available (neither today nor yesterday). Run will continue without wave-current interaction."
      postmsg "$jlogfile" "$msg"
      #AW touch ${RUNdir}/nostofs
   fi
   # Remove any erroneous files from the extraction script
   #rm ${LDMdir}/stofs/wave_stofs_waterlevel__19700101_??_f???.dat

elif [ $1 == "STOFS" ]
then
   cd ${LDMdir}/stofs
   pwd
   if [ $# -eq 1 ]
   then
      echo "Downloading STOFS Data. Checking Yesterday First."
      #${WGET} ${WGETargs} http://${SITE}/${STOFSPATHY}
      if [ -e ${COMIN_OFS_stofsm1}/LOCKFILE ]; then sleep 600; fi 
      if [ -e ${COMIN_OFS_stofsm1}/stofs_waterlevel_start_time.txt ]
      then
         zfiles=$(list_zerobyte_files_in_dir "${COMIN_OFS_stofsm1}" "wave_stofs_waterlevel*.dat")
	 if [ -n "$zfiles" ]; then
            warn_and_disable_forcing \
              "STOFS" \
              "There are invalid STOFS/Sea Ice data in ${COMIN_OFS_stofsm1} (0-byte *.dat files). Run will continue without water level variation and ice blocking." \
              "${RUNdir}/nostofs" \
              "$zfiles"
         else
            cp -pfv ${COMIN_OFS_stofsm1}/wave_stofs_waterlevel* .
            cp -pfv ${COMIN_OFS_stofsm1}/stofs_waterlevel_domain.txt .
            cp -pfv ${COMIN_OFS_stofsm1}/stofs_waterlevel_start_time.txt .
            rm -fr index.* robots.*
	 fi
      else
         echo "WARNING: Optional STOFS data not available for Yesterday."
      fi
   fi
   echo "Downloading STOFS data for Today"
   ##${WGET} ${WGETargs} http://${SITE}/${STOFSPATH}
   if [ -e ${COMIN_OFS_stofs}/LOCKFILE ]; then sleep 600; fi
   if [ -e ${COMIN_OFS_stofs}/stofs_waterlevel_start_time.txt ]
   then
      zfiles=$(list_zerobyte_files_in_dir "${COMIN_OFS_stofs}" "wave_stofs_waterlevel*.dat")
      if [ -n "$zfiles" ]; then
         warn_and_disable_forcing \
           "STOFS" \
           "There are invalid STOFS/Sea Ice data in ${COMIN_OFS_stofs} (0-byte *.dat files). Run will continue without water level variation and ice blocking." \
           "${RUNdir}/nostofs" \
           "$zfiles"
      else
         cp -pfv ${COMIN_OFS_stofs}/wave_stofs_waterlevel* .
         cp -pfv ${COMIN_OFS_stofs}/stofs_waterlevel_domain.txt .
         cp -pfv ${COMIN_OFS_stofs}/stofs_waterlevel_start_time.txt .
         rm -fr index.* robots.*
      fi
   else
      echo "WARNING: Optional STOFS data not available for Today."
   fi
   echo "Cleaning OLD data from STOFS Directory"
   if [ -e stofs_waterlevel_start_time.txt ]
   then
      start_time=`cat stofs_waterlevel_start_time.txt`
      file=`ls wave_stofs_waterlevel_${start_time}_*_f000.dat`
      #XXXXXXXXXXXcycle=`echo $file | cut -c35-45`
      #send inside the next for
      for i in $(ls wave_stofs_waterlevel*.dat)
      do
         init_time=`echo $i | cut -c24-33`
         fhour=`echo $i | cut -c48-50`
         cycle=`echo $i | cut -c44-45`
         echo "Processing $i $init_time $start_time $fhour $cycle"
         if [ $init_time -lt $start_time ]  && [ -e wave_stofs_waterlevel_${start_time}_${cycle}_f144.dat ]
         then
            echo "Removing $i"
            rm -f $i
         fi
      done
   else
      echo "WARNING: There are no STOFS/Sea Ice data available (neither today nor yesterday). Run will continue without water level variation and ice blocking." | tee -a ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt
      msg="WARNING: There are no STOFS/Sea Ice data available (neither today nor yesterday). Run will continue without water level variation and ice blocking."
      postmsg "$jlogfile" "$msg"
      touch ${RUNdir}/nostofs
   fi
   # Remove any erroneous files from the extraction script
   #rm ${LDMdir}/stofs/wave_stofs_waterlevel__19700101_??_f???.dat

elif [ $1 == "PSURGE" ]
then
   #PSfiles_exist="FALSE"
   cd ${LDMdir}/psurge
   if [ $# -eq 1 ]
   then
      pwd
      echo "Downloading PSURGE Data. Checking Yesterday First."
      #${WGET} ${WGETargs} http://${SITE}/${PSURGEPATHY}
      #cp -pfv ${ES_RTOFS_PSurgedir}/${PSURGEPATHY}/wave_psurge_*_${siteid}_e${EXCD}.dat.tar.gz .
      if [ -e ${COMIN_OFS_psurgem1}/psurge_waterlevel_start_time.txt ]
      then
         zfiles=$(list_zerobyte_files_in_dir "${COMIN_OFS_psurgem1}" "wave_combnd_*_${siteid}_e${EXCD}_f*.dat")
	 if [ -n "$zfiles" ]; then
            warn_and_disable_forcing \
              "PSURGE" \
              "There are invalid PSURGE fields in ${COMIN_OFS_psurgem1} (0-byte *.dat files). PSURGE will not be used; fallback will follow original logic." \
              "${RUNdir}/nopsurge" \
              "$zfiles"
         else
            #cp -pfv ${COMIN_OFS_psurgem1}/wave_psurge_*_${siteid}_e${EXCD}_f*.dat .
            cp -pfv ${COMIN_OFS_psurgem1}/wave_combnd_*_${siteid}_e${EXCD}_f*.dat .
            cp -pfv ${COMIN_OFS_psurgem1}/psurge_waterlevel_domain_${siteid}.txt .
            cp -pfv ${COMIN_OFS_psurgem1}/psurge_waterlevel_start_time.txt .
            rm -fr index.* robots.*
            PSfiles_exist="TRUE"
            chmod 664 *.dat
	 fi
      else
         echo "WARNING: Optional PSURGE data not available for Yesterday."
      fi
   fi
   echo "Downloading PSURGE data"
   #${WGET} ${WGETargs} http://${SITE}/${PSURGEPATH}
   #cp -pfv ${ES_RTOFS_PSurgedir}/${PSURGEPATH}/* .
   # SET THIS PROPERLY XXX
   #PSurgeFiles="/ptmpp1/Roberto.Padilla/data/Psurge2NWPS/output"
   #cp -pfv ${ES_RTOFS_PSurgedir}/${PSURGEPATH}/wave_psurge_*_${siteid}_e${EXCD}.dat.tar.gz .
   if [ -e ${COMIN_OFS_psurge}/psurge_waterlevel_start_time.txt ]
   then
      zfiles=$(list_zerobyte_files_in_dir "${COMIN_OFS_psurge}" "wave_combnd_*_${siteid}_e${EXCD}_f*.dat")
      if [ -n "$zfiles" ]; then
         warn_and_disable_forcing \
           "PSURGE" \
           "There are invalid PSURGE fields in ${COMIN_OFS_psurge} (0-byte *.dat files). PSURGE will not be used; fallback will follow original logic." \
           "${RUNdir}/nopsurge" \
           "$zfiles"
      else
         #cp -pfv ${COMIN_OFS_psurge}/wave_psurge_*_${siteid}_e${EXCD}_f*.dat .
         cp -pfv ${COMIN_OFS_psurge}/wave_combnd_*_${siteid}_e${EXCD}_f*.dat .
         cp -pfv ${COMIN_OFS_psurge}/psurge_waterlevel_domain_${siteid}.txt .
         cp -pfv ${COMIN_OFS_psurge}/psurge_waterlevel_start_time.txt .
         rm -fr index.* robots.*
         #PSfiles_exist="TRUE"
         chmod 664 *.dat
      fi
   else
      echo "WARNING: Optional PSURGE data not available for Today."
   fi

   echo "Finding model init time"
   windsource=`cat ${RUNdir}/windsource.flag`
   if [ "$windsource" == "FORECASTWINDGRIDS" ]; then
      model_start_time=`grep Wind_Mag_SFC:validTimes ${INPUTdir}/wind/*WIND.txt | cut -c29-38 | tail -1`
   elif [ "$windsource" == "GFS" ]; then
      NewestWind=$(basename $(ls -t ${VARdir}/gfe_grids_test/NWPSWINDGRID_${siteid}* | head -1))
      if [ "$NewestWind" != "" ]; then
         YYYY=$(echo $NewestWind|cut -c18-21)
         MM=$(echo $NewestWind|cut -c22-23)
         DD=$(echo $NewestWind|cut -c24-25)
         windhour=$(echo $NewestWind|cut -c26-27)
         time_str="${YYYY} ${MM} ${DD} ${windhour} 00 00"
         model_start_time=`echo ${time_str} | awk -F: '{ print mktime($1 $2 $3 $4 $5 $6) }'`
      fi
   fi
   echo "Model start UNIX time: ${model_start_time}" | tee -a ${LOGfile}

   echo "Checking age of PSURGE data relative to model init time"
   echo "If PSURGE data is absent, or newer than the model init time, fail over to STOFS"
   if [ -e psurge_waterlevel_start_time.txt ]
   then
      psurge_waterlevel_start_time=`ls wave_combnd_waterlevel* | xargs -n1 basename | cut -b24-33 | sort | uniq | awk -v thresh=$model_start_time '$1 <= thresh' | tail -1`

      if [ "$psurge_waterlevel_start_time" == "" ]
      then
         touch ${RUNdir}/nopsurge
         if [ ! -e ${RUNdir}/nostofs ]
         then
            echo "WARNING: PSURGE fields all newer than run init time. STOFS fields will be used instead." | tee -a ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt
            msg="WARNING: PSURGE fields all newer than run init time. STOFS fields will be used instead."
            postmsg "$jlogfile" "$msg"
            export WATERLEVELS="STOFS"
            export STOFS="YES"
            export PSURGE="NO"
         else
            echo "WARNING: PSURGE fields all newer than run init time. Run will continue without water level variation." | tee -a ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt
            msg="WARNING: PSURGE fields all newer than run init time. Run will continue without water level variation."
            postmsg "$jlogfile" "$msg"
            export WATERLEVELS="NO"
            export STOFS="NO"
            export PSURGE="NO"
         fi
      fi
   else    
      touch ${RUNdir}/nopsurge
      if [ ! -e ${RUNdir}/nostofs ]
      then
         echo "WARNING: There are no PSURGE fields available. STOFS fields will be used instead." | tee -a ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt
         msg="WARNING: There are no PSURGE fields available. STOFS fields will be used instead."
         postmsg "$jlogfile" "$msg"
         export WATERLEVELS="STOFS"
         export STOFS="YES"
         export PSURGE="NO"
      else
         echo "WARNING: There are no PSURGE fields available. Run will continue without water level variation." | tee -a ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt
         msg="WARNING: There are no PSURGE fields available. Run will continue without water level variation."
         postmsg "$jlogfile" "$msg"
         export WATERLEVELS="NO"
         export STOFS="NO"
         export PSURGE="NO"
      fi
   fi

fi

echo "Download script complete"
/bin/date -u

#exit 0
# ----------------------------------------------------------- 
# ******************************* 
# ********* End of File ********* 
# ******************************* 

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
# Script used to download RTOFS, ESTOFS, init files 
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
#rm ${RUNdir}/noestofs
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
  #ESTOFSPATH="ofs.${PDY}/estofs/${siteid}_output"
  #ESTOFSPATHY="ofs.${PDYm1}/estofs/${siteid}_output"
  #PSURGEPATH="ofs.${PDY}/psurge/${siteid}_output"
  #PSURGEPATHY="ofs.${PDYm1}/psurge/${siteid}_output"
else
  date=${2}
  #RTOFSPATH="ofs.${PDY}/rtofs/${siteid}_output"
  #ESTOFSPATH="ofs.${PDY}/estofs/${siteid}_output"
  #PSURGEPATH="ofs.${PDY}/psurge/${siteid}_output"
fi

WGETargs="--mirror -nv --tries=5 --no-parent --timeout=60 --no-directories --level=1"
WGET="/usr/bin/wget"

echo "Downloading NCEP init files for NWPS"
/bin/date -u

/bin/mkdir -p ${LDMdir}/rtofs ${LDMdir}/estofs ${LDMdir}/psurge

if [ $1 == "RTOFS" ]
then
   cd ${LDMdir}/rtofs
   pwd
   if [ $# -eq 1 ]
   then
      echo "Downloading RTOFS Data. Checking Yesterday First."
      #${WGET} ${WGETargs} http://${SITE}/${RTOFSPATHY}
      if [ -e ${COMINrtofsm1}/LOCKFILE ]; then sleep 600; fi 
      if [ -e ${COMINrtofsm1}/rtofs_current_start_time.txt ]
      then
         cp -pfv ${COMINrtofsm1}/* .
         rm -fr index.* robots.*
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
      if [ -e ${COMINrtofs}/LOCKFILE ]; then sleep 600; fi
      if [ -e ${COMINrtofs}/rtofs_current_start_time.txt ]
      then
         cp -pfv ${COMINrtofs}/* .
         rm -fr index.* robots.*
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

elif [ $1 == "ESTOFSCUR" ]
then
   cd ${LDMdir}/estofs
   pwd
   if [ $# -eq 1 ]
   then
      echo "Downloading ESTOFS current Data. Checking Yesterday First."
      #${WGET} ${WGETargs} http://${SITE}/${ESTOFSPATHY}
      if [ -e ${COMINestofsm1}/LOCKFILE ]; then sleep 600; fi 
      if [ -e ${COMINestofsm1}/estofs_current_start_time.txt ]
      then
         cp -pfv ${COMINestofsm1}/wave_estofs_uv* .
         cp -pfv ${COMINestofsm1}/estofs_current_domain.txt .
         cp -pfv ${COMINestofsm1}/estofs_current_start_time.txt .
         rm -fr index.* robots.*
      else
         echo "WARNING: Optional ESTOFS current data not available for Yesterday."
      fi
   fi
   echo "Downloading ESTOFS current data for Today"
   ##${WGET} ${WGETargs} http://${SITE}/${ESTOFSPATH}
   if [ -e ${COMINestofs}/LOCKFILE ]; then sleep 600; fi
   if [ -e ${COMINestofs}/estofs_current_start_time.txt ]
   then
      cp -pfv ${COMINestofs}/wave_estofs_uv* .
      cp -pfv ${COMINestofs}/estofs_current_domain.txt .
      cp -pfv ${COMINestofs}/estofs_current_start_time.txt .
      rm -fr index.* robots.*
   else
      echo "WARNING: Optional ESTOFS current data not available for Today."
   fi
   echo "Cleaning OLD data from ESTOFS Directory"
   if [ -e estofs_current_start_time.txt ]
   then
      start_time=`cat estofs_current_start_time.txt`
      file=`ls wave_estofs_uv_${start_time}_*_f000.dat`
      #XXXXXXXXXXXcycle=`echo $file | cut -c35-45`
      #send inside the next for
      for i in $(ls wave_estofs_uv*.dat)
      do
         init_time=`echo $i | cut -c24-33`
         fhour=`echo $i | cut -c48-50`
         cycle=`echo $i | cut -c44-45`
         echo "Processing $i $init_time $start_time $fhour $cycle"
         if [ $init_time -lt $start_time ]  && [ -e wave_estofs_uv_${start_time}_${cycle}_f144.dat ]
         then
            echo "Removing $i"
            rm -f $i
         fi
      done
   else
      echo "WARNING: There are no ESTOFS current data available (neither today nor yesterday). Run will continue without wave-current interaction." | tee -a ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt
      msg="WARNING: There are no ESTOFS current data available (neither today nor yesterday). Run will continue without wave-current interaction."
      postmsg "$jlogfile" "$msg"
      #AW touch ${RUNdir}/noestofs
   fi
   # Remove any erroneous files from the extraction script
   #rm ${LDMdir}/estofs/wave_estofs_waterlevel__19700101_??_f???.dat

elif [ $1 == "ESTOFS" ]
then
   cd ${LDMdir}/estofs
   pwd
   if [ $# -eq 1 ]
   then
      echo "Downloading ESTOFS Data. Checking Yesterday First."
      #${WGET} ${WGETargs} http://${SITE}/${ESTOFSPATHY}
      if [ -e ${COMINestofsm1}/LOCKFILE ]; then sleep 600; fi 
      if [ -e ${COMINestofsm1}/estofs_waterlevel_start_time.txt ]
      then
         cp -pfv ${COMINestofsm1}/wave_estofs_waterlevel* .
         cp -pfv ${COMINestofsm1}/estofs_waterlevel_domain.txt .
         cp -pfv ${COMINestofsm1}/estofs_waterlevel_start_time.txt .
         rm -fr index.* robots.*
      else
         echo "WARNING: Optional ESTOFS data not available for Yesterday."
      fi
   fi
   echo "Downloading ESTOFS data for Today"
   ##${WGET} ${WGETargs} http://${SITE}/${ESTOFSPATH}
   if [ -e ${COMINestofs}/LOCKFILE ]; then sleep 600; fi
   if [ -e ${COMINestofs}/estofs_waterlevel_start_time.txt ]
   then
      cp -pfv ${COMINestofs}/wave_estofs_waterlevel* .
      cp -pfv ${COMINestofs}/estofs_waterlevel_domain.txt .
      cp -pfv ${COMINestofs}/estofs_waterlevel_start_time.txt .
      rm -fr index.* robots.*
   else
      echo "WARNING: Optional ESTOFS data not available for Today."
   fi
   echo "Cleaning OLD data from ESTOFS Directory"
   if [ -e estofs_waterlevel_start_time.txt ]
   then
      start_time=`cat estofs_waterlevel_start_time.txt`
      file=`ls wave_estofs_waterlevel_${start_time}_*_f000.dat`
      #XXXXXXXXXXXcycle=`echo $file | cut -c35-45`
      #send inside the next for
      for i in $(ls wave_estofs_waterlevel*.dat)
      do
         init_time=`echo $i | cut -c24-33`
         fhour=`echo $i | cut -c48-50`
         cycle=`echo $i | cut -c44-45`
         echo "Processing $i $init_time $start_time $fhour $cycle"
         if [ $init_time -lt $start_time ]  && [ -e wave_estofs_waterlevel_${start_time}_${cycle}_f144.dat ]
         then
            echo "Removing $i"
            rm -f $i
         fi
      done
   else
      echo "WARNING: There are no ESTOFS/Sea Ice data available (neither today nor yesterday). Run will continue without water level variation and ice blocking." | tee -a ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt
      msg="WARNING: There are no ESTOFS/Sea Ice data available (neither today nor yesterday). Run will continue without water level variation and ice blocking."
      postmsg "$jlogfile" "$msg"
      touch ${RUNdir}/noestofs
   fi
   # Remove any erroneous files from the extraction script
   #rm ${LDMdir}/estofs/wave_estofs_waterlevel__19700101_??_f???.dat

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
      if [ -e ${COMINpsurgem1}/psurge_waterlevel_start_time.txt ]
      then
         #cp -pfv ${COMINpsurgem1}/wave_psurge_*_${siteid}_e${EXCD}_f*.dat .
         cp -pfv ${COMINpsurgem1}/wave_combnd_*_${siteid}_e${EXCD}_f*.dat .
         cp -pfv ${COMINpsurgem1}/psurge_waterlevel_domain_${siteid}.txt .
         cp -pfv ${COMINpsurgem1}/psurge_waterlevel_start_time.txt .
         rm -fr index.* robots.*
         PSfiles_exist="TRUE"
         chmod 664 *.dat
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
   if [ -e ${COMINpsurge}/psurge_waterlevel_start_time.txt ]
   then
      #cp -pfv ${COMINpsurge}/wave_psurge_*_${siteid}_e${EXCD}_f*.dat .
      cp -pfv ${COMINpsurge}/wave_combnd_*_${siteid}_e${EXCD}_f*.dat .
      cp -pfv ${COMINpsurge}/psurge_waterlevel_domain_${siteid}.txt .
      cp -pfv ${COMINpsurge}/psurge_waterlevel_start_time.txt .
      rm -fr index.* robots.*
      #PSfiles_exist="TRUE"
      chmod 664 *.dat
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
   echo "If PSURGE data is absent, or newer than the model init time, fail over to ESTOFS"
   if [ -e psurge_waterlevel_start_time.txt ]
   then
      psurge_waterlevel_start_time=`ls wave_combnd_waterlevel* | xargs -n1 basename | cut -b24-33 | sort | uniq | awk -v thresh=$model_start_time '$1 <= thresh' | tail -1`

      if [ "$psurge_waterlevel_start_time" == "" ]
      then
         touch ${RUNdir}/nopsurge
         if [ ! -e ${RUNdir}/noestofs ]
         then
            echo "WARNING: PSURGE fields all newer than run init time. ESTOFS fields will be used instead." | tee -a ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt
            msg="WARNING: PSURGE fields all newer than run init time. ESTOFS fields will be used instead."
            postmsg "$jlogfile" "$msg"
            export WATERLEVELS="ESTOFS"
            export ESTOFS="YES"
            export PSURGE="NO"
         else
            echo "WARNING: PSURGE fields all newer than run init time. Run will continue without water level variation." | tee -a ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt
            msg="WARNING: PSURGE fields all newer than run init time. Run will continue without water level variation."
            postmsg "$jlogfile" "$msg"
            export WATERLEVELS="NO"
            export ESTOFS="NO"
            export PSURGE="NO"
         fi
      fi
   else    
      touch ${RUNdir}/nopsurge
      if [ ! -e ${RUNdir}/noestofs ]
      then
         echo "WARNING: There are no PSURGE fields available. ESTOFS fields will be used instead." | tee -a ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt
         msg="WARNING: There are no PSURGE fields available. ESTOFS fields will be used instead."
         postmsg "$jlogfile" "$msg"
         export WATERLEVELS="ESTOFS"
         export ESTOFS="YES"
         export PSURGE="NO"
      else
         echo "WARNING: There are no PSURGE fields available. Run will continue without water level variation." | tee -a ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt
         msg="WARNING: There are no PSURGE fields available. Run will continue without water level variation."
         postmsg "$jlogfile" "$msg"
         export WATERLEVELS="NO"
         export ESTOFS="NO"
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

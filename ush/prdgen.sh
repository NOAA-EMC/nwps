#!/bin/bash
set -xa
# ----------------------------------------------------------- 
# UNIX Shell Script File
# Tested Operating System(s): RHEL 5,6
# Tested Run Level(s): 3, 5
# Shell Used: BASH shell
# Original Author(s):  Roberto.Padilla@noaa.gov
# File Creation Date: 08/22/2011
# Date Last Modified: 04/06/2015
#
# Version control: 1.17
#
# Support Team:
#
# Contributors: Andre Van Der Westhuijsen
# ----------------------------------------------------------- 
# ------------- Program Description and Details ------------- 
# ----------------------------------------------------------- 
#
# Script used to introduce the WMO headers 
# into CG0, CG1 to CGn grib2 files
#
# ----------------------------------------------------------- 



# Setup our NWPS environment                                                    
if [ "${USHnwps}" == "" ]
    then 
    echo "ERROR - Your USHnwps variable is not set"
    export err=1; err_chk
fi
    
if [ ! -e ${USHnwps}/nwps_config.sh ]
then
    "ERROR - Cannot find ${USHnwps}/nwps_config.sh"
    export err=1; err_chk
fi
echo "" | tee -a ${LOGdir}/prdgen_cgn.log 
#Defining the siteid
parmKSITE="K${SITEID}"
echo "prdgen_cgn .sh HAS BEGUN "
echo "COARSE OR NESTED GRID(S): ${N}"

echo "Starting NWPS PRODUCTS SCRIPT" | tee -a ${LOGdir}/prdgen_cgn.log 

PARMwmo=${PARMnwps}/wmo_headers

# Here some variables are defined if the run is for CG0 to CG5
# For CG0 (the output of wave tracking) we need the number of wave systems

if [ "${N}" == "1" ]
then 
   # For CG1
   cxini="0"
   NumCGs="1"
elif [ "${N}" == "0" ]
   then
   #For CG0
   hastracking="FALSE"
   hastracking=$(cat ${RUNdir}/Tracking.flag)
   if [ "${hastracking}" == "FALSE" ] 
   then
      echo "WARNING: Wave tracking not activated. Not producing CG0 GRIB2 file for this run." | tee -a ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt
      msg="WARNING: Wave tracking not activated. Not producing CG0 GRIB2 file for this run."
      postmsg "$jlogfile" "$msg"      
      exit 0
   fi
   cxini="-1"
   NumCGs="1"
   GRIB2dir="${GRIB2dir}/tracking"
   NumSystems=$(cat ${RUNdir}/NumWaveSystems.txt)
   if [ $NumSystems -eq 0 ]
   then
      echo "WARNING: No wave systems identified. Not producing CG0 GRIB2 file for this run." | tee -a ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt
      msg="WARNING: No wave systems identified. Not producing CG0 GRIB2 file for this run."
      postmsg "$jlogfile" "$msg"      
      exit 0
   fi
else
   #If nest is true then the number of lines in ${RUNdir}/cgn_cmdfile 
   # equals the number of CG's in nesting
   cxini="1"
   if [ -e ${RUNdir}/cgn_cmdfile ]
   then
      NumCGs=$(wc -l < "${RUNdir}/cgn_cmdfile")
        echo "Number of nested grids : ${NumCGs}"  | tee -a ${LOGdir}/prdgen_cgn.log 
   else
        echo "********************************"  | tee -a ${LOGdir}/prdgen_cgn.log 
        echo "** NO NESTED GRIDS IN THIS RUN *"  | tee -a ${LOGdir}/prdgen_cgn.log 
        echo "********************************"  | tee -a ${LOGdir}/prdgen_cgn.log 
   fi
fi



#  grids='CG1 CG2 CG3 CG4 CG5 CG0'
  awipsgrib='yes'
  awipsbull='no'

# 0.b Date and time stuff

date=$PDY
YMDH=${PDY}

  set +x
  echo ' '
  echo '                         ****************************'
  echo '                         *** NWPS PRODUCTS SCRIPT ***'
  echo '                         ****************************'
  echo "                                       $date $cycle"
  echo ' '
  echo "Starting at : `date`"
  echo ' '
  echo "   AWIPS grib fields : $awipsgrib"
  echo "   Wave  Grids       : $grids"
  echo ' '
  [[ "$LOUD" = YES ]] && set -x

# --------------------------------------------------------------------------- #
# 1.  Get necessary files

  set +x
  echo ' '
  echo 'Preparing input files :'
  echo '-----------------------'
  [[ "$LOUD" = YES ]] && set -x

# 1.a Grib file (AWIPS and FAX charts)

  if [ "$awipsgrib" = 'yes' ]
  then
    cx=${cxini}
    for (( i = 0 ; i < ${NumCGs} ; i++ ))
    do
      cx=$(( $cx + 1 ))
      grdID="CG${cx}"
      echo "Preparing input file for: ${grdID}"
      if [ ! -f gribfile.$grdID ]
      then
        set +x
        echo "   Copying grib2 from ${GRIB2dir}/${grdID}/"
        [[ "$LOUD" = YES ]] && set -x
        cd ${GRIB2dir}/${grdID}
        #subfix="*${grdID}*grib2"
        #file=`ls ${subfix}`
        #file=$(ls ${GRIB2dir}/${grdID}/*${grdID}*grib2 | xargs -n 1 basename | tail -n 1)
        cycle=$(awk '{print $1;}' ${RUNdir}/CYCLE)
        if [ "${N}" == "0" ]
        then
           #cycle=${file:28:2}
           grep "^INPGRID WIND" ${RUNdir}/inputCG1 > blah1
           init=$(awk '{print $11;}' blah1)
           echo "$init" > datetime
           cut -c 1-4 datetime > year
           cut -c 5-6 datetime > mon
           cut -c 7-8 datetime > day
           yyyy=$(cat year)
           mon=$(cat mon)
           dd=$(cat day)
           file="${WFO}_${NET}_${grdID}_Trkng_${yyyy}${mon}${dd}_${cycle}00.grib2"
        else 
           #cycle=${file:22:2}
           grep "^INPGRID WIND" ${RUNdir}/input${grdID} > blah1
           init=$(awk '{print $11;}' blah1)
           echo "$init" > datetime
           cut -c 1-4 datetime > year
           cut -c 5-6 datetime > mon
           cut -c 7-8 datetime > day
           yyyy=$(cat year)
           mon=$(cat mon)
           dd=$(cat day)
           file="${WFO}_${NET}_${grdID}_${yyyy}${mon}${dd}_${cycle}00.grib2"
        fi
        cp ${GRIB2dir}/${grdID}/$file ${RUNdir}/gribfile.$grdID
        export err=$?; err_chk
      fi
      cd ${RUNdir}
      if [ -f gribfile.$grdID ]
      then
        set +x
        echo "   gribfile.$grdID exists."
        [[ "$LOUD" = YES ]] && set -x
      else
        echo "FATAL ERROR: NO GRIB FILE FOR GRID $grdID"  | tee -a ${LOGdir}/prdgen_cgn.log 
        msg="FATAL ERROR: NO GRIB FILE FOR GRID $grdID"
        postmsg "$jlogfile" "$msg"
        export err=1; err_chk
        
        set +x
        echo ' '
        echo '**************************** '
        echo '*** ERROR : NO GRIB FILE *** '
        echo '**************************** '
        echo ' '
        exit
        [[ "$LOUD" = YES ]] && set -x
        echo "$siteid $grdID prdgen_cgn  : GRIB file missing."| tee -a ${LOGdir}/prdgen_cgn.log 
        awipsgrib='no'
        export err=1; err_chk
      fi
    done
  fi
  
# 1.g Input template files

  if [ "$awipsgrib" = 'yes' ]
  then

#    for grdID in $grids
#    do
    cx=${cxini}
    for (( i = 0 ; i < ${NumCGs} ; i++ ))
    do
      cx=$(( $cx + 1 ))
      grdID="CG${cx}"
      echo "Processing template file for: ${grdID}"
      if [ "${grdID}" == "CG0" ]
      then
         header="$PARMwmo/grib2_${siteid}_nwps_${grdID}_Trkng_${NumSystems}_Sys"
         cp ${header} awipsgrb.$grdID
        export err=$?; err_chk

      else 
        cp $PARMwmo/grib2_${siteid}_nwps_$grdID awipsgrb.$grdID
        export err=$?; err_chk

      fi
      if [ -f awipsgrb.$grdID ]
      then
        set +x
        echo "   awipsgrb.$grdID copied."
      else
        echo "ABNORMAL EXIT: NO AWIPS GRIB FOR GRID $grdID"  | tee -a ${LOGdir}/prdgen_cgn.log 
        set +x
        echo ' '
        echo '*************************************** '
        echo '*** ERROR : NO AWIPS GRIB DATA FILE *** '
        echo '*************************************** '
        echo ' '
        awipsgrib='no'
        export err=1; err_chk
      fi
 
    done

  fi

# 1.h Data summary
  echo ' '
  echo '   All data files accounted for.'
  echo ' '
  echo "                 AWIPSGRIB? : $awipsgrib"
  echo ' '

# --------------------------------------------------------------------------- #
# 2.  AWIPS product generation
# 2.a AWIPS GRIB file with headers

  if [ "$awipsgrib" = 'yes' ]
  then
    cx=${cxini}
    for (( i = 0 ; i < ${NumCGs} ; i++ ))
    do
      cx=$(( $cx + 1 ))
      grdID="CG${cx}"

      echo '------------------------------'
      echo "AWIPS headers to GRIB file: ${grdID} "
      echo '------------------------------'

# 2.a.1 Set up for tocgrib2

      echo "   Do set up for tocgrib2."

      rm -f AWIPSGRIB

# 2.a.2 Make GRIB index
      echo "   Make GRIB index for tocgrib2."
      $utilexec/grb2index gribfile.$grdID gribindex.$grdID
      OK=$?

      if [ "$OK" != '0' ]
      then
        echo "ABNORMAL EXIT: ERROR IN grb2index NWPS_K${SITEID} for grid $grdID" | tee -a ${LOGdir}/prdgen_cgn.log 
        echo ' '
        echo '******************************************** '
        echo '*** FATAL ERROR : ERROR IN grb2index NWPS_K$SITEID} *** '
        echo '******************************************** '
        echo ' '
        export err=1; err_chk
      fi

# 2.a.3 Run AWIPS GRIB packing program tocgrib2
      echo "   Run tocgrib2"
      export pgm=tocgrib2
      export pgmout="tocgrib2_${grdID}.out"
      . ./prep_step

      export FORT11="gribfile.$grdID"
      export FORT31="gribindex.$grdID"
      export FORT51="AWIPSGRIB"

#      $utilexec/tocgrib2 < awipsgrb.$grdID parm='KMFL' > "tocgrib2_${grdID}.out" 2>&1
      $utilexec/tocgrib2 < awipsgrb.$grdID parm='${parmKSITE}' > "tocgrib2_${grdID}.out" 2>&1
      OK=$?

      if [ "$OK" != '0' ]
      then
        cat "tocgrib2_${grdID}.out"
        echo "ABNORMAL EXIT: ERROR IN tocgrib2"| tee -a ${LOGdir}/prdgen_cgn.log 
#        postmsg "$jlogfile" "$msg"
        echo ' '
        echo '*************************************** '
        echo '*** FATAL ERROR : ERROR IN tocgrib2 *** '
        echo '*************************************** '
        echo ' '
        export err=1; err_chk
      fi

# 2.a.7 Get the AWIPS grib bulletin out ...
      echo "   Get awips GRIB bulletins out ..."

      if [ "$SENDCOM" = 'YES' ]
      then
        set +x
        echo "      Saving AWIPSGRIB as grib2.$cycle.awipsnwps_${siteid}_${grdID}"
        echo "          in $PCOM"
        [[ "$LOUD" = YES ]] && set -x
        cp AWIPSGRIB $PCOM/grib2.$cycle.awipsnwps_${siteid}_${grdID}
        export err=$?; err_chk
      fi

      if [ "$SENDDBN" = 'YES' ]
      then
        echo "      Sending grib2.$cycle.awipsnwps_${siteid}_${grdID} to DBNET."
        $DBNROOT/bin/dbn_alert GRIB_LOW $NET $job $PCOM/grib2.$cycle.awipsnwps_${siteid}_${grdID}
      fi

      ##rm -f "tocgrib2_${grdID}.out"

    done

  fi

# --------------------------------------------------------------------------- #
# 5.  Clean up

  set +x; [[ "$LOUD" = YES ]] && set -v
  rm -f gribfile gribindex.* awipsgrb.*
  set +v

# --------------------------------------------------------------------------- #
# 6.  Ending output

  set +x
  echo ' '
  echo ' '
  echo "Ending at : `date`"
  echo ' '
  echo '                *** End of NWPS product generation ***'
  echo ' '
  [[ "$LOUD" = YES ]] && set -x

echo "$job completed normally" | tee -a ${LOGdir}/prdgen_cgn.log 

date -u | tee -a ${LOGdir}/prdgen_cgn.log 
exit 0
# End of NWPS product generation script -------------------------------------- #

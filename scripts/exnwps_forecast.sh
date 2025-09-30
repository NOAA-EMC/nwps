#!/bin/bash
###############################################################################
#                                                                             #
# This is the actual forcast script for the NWPS                              #
# It uses only a single ush script                                            #
#                                                                             #
#  multiwavestart.sh   : get initial time of most recent restart file(s)      #
#                                                                             #
#  Original Author(s): Roberto Padilla-Henandez                               # 
# File Creation Date: 04/20/2004                                              #
#                                                                             #
#                                                                             #
# Contributors:                                                               #
#                                                                             #
# Remarks :                                                                   #
# -                                                                           #
#                                                                             #
#  Update record :                                                            #
#                                                                             #
# - File Creation Date:     22_July-2014                                      #
#                                                                             #
# - Date Last Modified: 07/10/2013                                            #
#                                                                             #
#                                                                             #
###############################################################################
# --------------------------------------------------------------------------- #

  # Use LOUD variable to turn on/off trace.  Defaults to YES (on).
  export LOUD=${LOUD:-YES}; [[ $LOUD = yes ]] && export LOUD=YES
  echo ' '
  echo '                      ******************************'
  echo '                      ****** NWPSYSTEM SCRIPT ******'
  echo '                      ******************************'
  echo ' '
  echo "Starting at : `date`"
  [[ "$LOUD" = YES ]] && set -x

source ${USHnwps}/nwps_config.sh
export err=$?; err_chk
${USHnwps}/nwps_coremodel_cg${N,,}.pl
export err=$?; err_chk

# Copy any final forecaster warnings out to COMOUT and GESOUT
hh=`cat ${RUNdir}/CYCLE`

inputparm="${RUNdir}/inputCG1"
if [ ! -e ${inputparm} ]
then
   msg="FATAL ERROR:Missing inputCG1 file. Cannot open ${inputparm}"
   postmsg $jlogfile "$msg"
   export err=1; err_chk
fi


# 1) Parse YYYY MM DD HH MM from the INPGRID WIND line (11th field)
init="$(awk '/^INPGRID[[:space:]]+WIND/{print $11; exit}' "$inputparm")"
ts="${init//[^0-9]/}"
yyyy="${ts:0:4}"; mon="${ts:4:2}"; dd="${ts:6:2}"; hh="${ts:8:2}"; mm="${ts:10:2}"

# Sanity check
if [ -z "$yyyy$mon$dd$hh$mm" ]; then
  echo "ERROR: could not parse INPGRID WIND time from $inputparm" >&2
  export err=1; err_chk
fi

# 2) Build PDY and cycle
export PDY_INPUT="${yyyy}${mon}${dd}"

# Prefer workflow cycle file; fallback to parsed hour
cycle="$(awk 'NR==1{print $1}' "${RUNdir}/CYCLE" 2>/dev/null || true)"
[ -z "${cycle}" ] && cycle="${hh}"
cycle="$(printf '%02d' "${cycle#0}")"
export cycle

# 3) Rebuild COMOUT for the correct day from the existing COMOUT path
COMOUT_WFO="$(basename -- "$COMOUT")"            # -> <WFO> (site folder, e.g., box)
COMOUT_PARENT="$(dirname -- "$COMOUT")"          # -> .../<REGION>.<PDY>
REGION_DOT_PDY="$(basename -- "$COMOUT_PARENT")" # -> <REGION>.<PDY> (e.g., er.20250911)
REGION_ONLY="${REGION_DOT_PDY%%.*}"              # -> <REGION> (e.g., er)
export COMOUT_ROOT="$(dirname -- "$COMOUT_PARENT")"     # -> .../nwps/v1.5.0

export COMOUT_CORRECT="${COMOUT_ROOT}/${REGION_ONLY}.${PDY_INPUT}/${COMOUT_WFO}"

export COMOUTCYC="${COMOUT_CORRECT}/${hh}"
mkdir -p $COMOUTCYC $GESOUT/warnings
cp -fv  ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt ${COMOUTCYC}/Warn_Forecaster_${SITEID}.${PDY}.txt
cp -fv  ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt ${GESOUT}/warnings/Warn_Forecaster_${SITEID}.${PDY}.txt

echo "Forecast complete"
exit 0
# End of script ------------------------------------------------------------- #

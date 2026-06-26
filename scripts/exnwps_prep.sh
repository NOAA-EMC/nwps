#!/bin/bash
echo "============================================================="
echo "=                                                           ="
echo "=         RUNNING NWPS-WCOSS FOR SITE: ${SITEID}                  ="
echo "=                                                           ="
echo "============================================================="
#
###############################################################################
# THE VALUE OF THE FOLLOWING PARAMETERS ARE FIXED IN ~/ush/run_nwps_wcoss.sh  #
###############################################################################
export DELTAC=${DELTAC:-600}
export RUNLEN=${RUNLEN:-144}
export WAVEMODEL=${WAVEMODEL:-swan}
export WINDS=${WINDS:-FORECASTER}
export DOMAINSET=${DOMAINSET:-${FIXnwps}/domains/${SITEID}}

${USHnwps}/run_nwps_wcoss.sh --sitename ${SITEID} --runlen ${RUNLEN}  --wna --nest --waterlevels ESTOFS --rtofs --winds ${WINDS} --domainsetup ${DOMAINSET} --deltac ${DELTAC} --plot --wavemodel ${WAVEMODEL}
export err=$?; err_chk

echo "Pre-process completed"
exit 0

#!/bin/bash
set -xa
#
export CGNUMPLOT=${1}

echo "= = = =  = = =   IN RUN_POSPROC_CG2.SH  = =  = = =  = = ="
echo " CGNUMPLOT= ${CGNUMPLOT}"
echo "================== STARTING NWPS_POSPROC_CGN_PARALLEL.PL ====================="
${USHnwps}/nwps_posproc_cgn_parallel.pl ${CGNUMPLOT}
echo "================== STARTING NWPS_POSPROC_CGN_PARALLEL.SH ====================="
${USHnwps}/nwps_posproc_cgn_parallel.sh ${CGNUMPLOT}

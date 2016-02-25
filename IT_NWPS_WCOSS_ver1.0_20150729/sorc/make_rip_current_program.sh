#!/bin/bash
export pwd=`pwd`
export NWPSdir=${pwd%/*}

if [ "${NWPSdir}" == "" ]
    then 
    echo "ERROR - Your NWPSdir variable is not set"
    exit 1
fi
#if [ ! -e ${NWPSdir}/utils/etc/nwps_config.sh ]
#then
#    "ERROR - Cannot find ${NWPSdir}/utils/etc/nwps_config.sh"
#    exit 1
#fi
#
#unset LD_LIBRARY_PATH
#source ${NWPSdir}/utils/etc/nwps_config.sh
#
## Setup our build environment
#source ${NWPSdir}/sorc/set_compiler.sh

${NWPSdir}/sorc/rip_current_program/make_rip_current_program.sh



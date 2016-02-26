#!/bin/bash

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

cd ${NWPSdir}/sorc/rip_current_program

echo "Building RIP current program"

mkdir -p ${NWPSdir}/exec

gfortran -O2 -g -traceback -v -o ripforecast.x bulkmodel.f eventcalc.f read_nwps.f read_shore.f ripforecast.f
mv -v ripforecast.x ${NWPSdir}/exec/ripforecast.x

echo "Build complete"
exit 0


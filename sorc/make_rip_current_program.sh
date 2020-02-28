#!/bin/bash
export pwd=`pwd`
export NWPSdir=${pwd%/*}

if [ "${NWPSdir}" == "" ]
    then 
    echo "ERROR - Your NWPSdir variable is not set"
    exit 1
fi

## Setup our build environment
#source ${NWPSdir}/sorc/set_compiler.sh

#module purge
#module load ncep
#module load ../modulefiles/NWPS/v1.3.0
#module list

cd ${NWPSdir}/sorc/rip_current_program/
make ripforecast | tee ./ripcurrent_build.log
rm *.o
mv -v ripforecast.exe ${NWPSdir}/exec/ripforecast.exe

echo "Build complete"
exit 0

#!/bin/bash
set -xa

export pwd=`pwd`
export HOMEnwps=${pwd%/*}

if [ "${HOMEnwps}" == "" ]
    then 
    echo "ERROR - Your HOMEnwps variable is not set"
    exit 1
fi

## Setup our build environment
#source ${HOMEnwps}/sorc/set_compiler.sh

#module purge
#module load ncep
#module load ../modulefiles/NWPS/v1.3.0
#module list

cd ${HOMEnwps}/sorc/ripforecast.fd/
make ripforecast | tee ./ripcurrent_build.log
rm *.o
mv -v ripforecast.exe ${HOMEnwps}/exec/ripforecast.exe

echo "Build complete"
exit 0

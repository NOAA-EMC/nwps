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

cd ${NWPSdir}/sorc/ww3_sysprep.fd
make ww3_sysprep | tee ./sysprep_build.log
rm *.o
mv -v ww3_sysprep.exe ${NWPSdir}/exec/ww3_sysprep.exe

echo "Build complete"
exit 0

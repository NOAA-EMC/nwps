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

cd ${HOMEnwps}/sorc/ww3_sysprep.fd
make \
  FFLAGS="${FFLAGS:-}" \
  FCFLAGS="${FCFLAGS:-}" \
  ww3_sysprep | tee ./sysprep_build.log

rm -f *.o
mv -v ww3_sysprep.exe ${HOMEnwps}/exec/ww3_sysprep.exe
echo "Build complete"
exit 0

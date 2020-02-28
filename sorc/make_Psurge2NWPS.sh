#!/bin/bash

if [ "${NWPSdir}" == "" ]
    then 
    echo "ERROR - Your NWPSdir variable is not set"
    exit 1
fi

#loading the necessary modules 
module purge
module load ncep
module load ../modulefiles/NWPS/v1.2.0
module list

echo "Building psoutTOnwps"  | tee ${NWPSdir}/sorc/make_Psurge/psoutTOnwps_build.log
cd ${NWPSdir}/sorc/emapf-c
./configure --prefix=${NWPSdir}/sorc/emapf-c | tee -a ${NWPSdir}/sorc/make_Psurge/psoutTOnwps_build.log
make clean | tee -a ${NWPSdir}/sorc/make_Psurge/psoutTOnwps_build.log
make | tee -a ${NWPSdir}/sorc/make_Psurge/psoutTOnwps_build.log

cd ${NWPSdir}/sorc/make_Psurge
#ifort -O2 -g -traceback -v -o -o psoutTOnwps.exe psoutTOnwps_ver04.f
ftn -o psoutTOnwps.exe psoutTOnwps.f | tee -a ${NWPSdir}/sorc/make_Psurge/psoutTOnwps_build.log
mv -v psoutTOnwps.exe ${NWPSdir}/exec/psoutTOnwps.exe
echo "Build complete" | tee -a ${NWPSdir}/sorc/make_Psurge/psoutTOnwps_build.log

echo "Building psurge_identify"  | tee ${NWPSdir}/sorc/make_Psurge/psurge_identify_build.log
ftn -o psurge_identify.exe psurge_identify.f | tee -a ${NWPSdir}/sorc/make_Psurge/psurge_identify_build.log
mv -v psurge_identify.exe ${NWPSdir}/exec/psurge_identify.exe
echo "Build complete" | tee -a ${NWPSdir}/sorc/make_Psurge/psurge_identify_build.log

echo "Building psurge2nwps"  | tee ${NWPSdir}/sorc/psurge2nwps/psurge2nwps_build.log
cd ${NWPSdir}/sorc/psurge2nwps
make clean | tee -a ${NWPSdir}/sorc/psurge2nwps/psurge2nwps_build.log
make  | tee -a ${NWPSdir}/sorc/psurge2nwps/psurge2nwps_build.log
mv -v psurge2nwps_64 ${NWPSdir}/exec
echo "Build complete" | tee -a ${NWPSdir}/sorc/psurge2nwps/psurge2nwps_build.log

exit 0


#!/bin/bash

if [ "${NWPSdir}" == "" ]
    then 
    echo "ERROR - Your NWPSdir variable is not set"
    exit 1
fi


###${NWPSdir}/sorc/make_Psurge/make_psurge2nwps.sh


echo "Building Psurge2nwps"

cd ${NWPSdir}/sorc/emapf-c
./configure --prefix=${NWPSdir}/sorc/emapf-c
make clean
make

cd ${NWPSdir}/sorc/make_Psurge
#ifort -O2 -g -traceback -v -o -o psoutTOnwps.exe psoutTOnwps_ver04.f
gfortran -o psoutTOnwps.exe psoutTOnwps.f
mv -v psoutTOnwps.exe ${NWPSdir}/exec/psoutTOnwps.exe

gfortran -o psurge_identify.exe psurge_identify.f
mv -v psurge_identify.exe ${NWPSdir}/exec/psurge_identify.exe


cd ${NWPSdir}/sorc/psurge2nwps
make clean
make 
mv -v psurge2nwps_64 ${NWPSdir}/exec

echo "Build complete"
exit 0


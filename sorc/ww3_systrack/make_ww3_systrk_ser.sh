#!/bin/bash

if [ "${NWPSdir}" == "" ]
    then 
    echo "ERROR - Your NWPSdir variable is not set"
    exit 1
fi
#if [ ! -e ${NWPSdir}/etc/nwps_config.sh ]
#then
#    "ERROR - Cannot find ${NWPSdir}/etc/nwps_config.sh"
#    exit 1
#fi
#source ${NWPSdir}/etc/nwps_config.sh

cd ${NWPSdir}/sorc/ww3_systrack

cp ww3_systrk.ftn temp1
cp w3strkmd.ftn temp2

sed 's/!\/SER//g' temp1 > ww3_systrk_compile.f90
sed 's/!\/SER//g' temp2 > w3strkmd_compile.f90

#gfortran -v -o ww3_systrk_ser w3strkmd_compile.f90 ww3_systrk_compile.f90
ifort -g -traceback -O2 -v -o ww3_systrk_ser w3strkmd_compile.f90 ww3_systrk_compile.f90


mkdir -p ${NWPSdir}/exec
mv -v ww3_systrk_ser ${NWPSdir}/exec/ww3_systrk_ser
rm -fv temp1 temp2 ww3_systrk_compile.f90 w3strkmd_compile.f90 w3strkmd.mod

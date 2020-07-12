#!/bin/bash
#
# ----------------------------------------------------------- 
# Original Author(s):Andre Van Der Westhuysen, Roberto.Padilla@noaa.gov
# File Creation Date: 04/06/2015
# Date Last Modified: 06/24/2015
#
# Version control: 1.17
#
# Support Team:
#
# Contributors:Carolyn Pasti cpasti@redlineperf.com
# ----------------------------------------------------------- 
# ------------- Program Description and Details ------------- 
# ----------------------------------------------------------- 

if [ "${NWPSdir}" == "" ]
    then 
    echo "ERROR - Your NWPSdir variable is not set"
    exit 1
fi

cd ${NWPSdir}/sorc/ww3_systrack

cp -fpv ww3_systrk.ftn temp1
cp -fpv w3strkmd.ftn temp2

sed 's/!\/MPI//g' temp1 > ww3_systrk_compile.f90
sed 's/!\/MPI//g' temp2 > w3strkmd_compile.f90

#From Carolyn: compiling MPI with -g and -O2 options so that it is optimized
#and you can analyze any coredumps you get in production.  
#mpfort -g -O2 -v -o ww3_systrk_mpi w3strkmd_compile.f90 ww3_systrk_compile.f90
#20160331 AW: Updated for Cray machines
ftn -c -g -O2 -v w3strkmd_compile.f90 ww3_systrk_compile.f90
ftn w3strkmd_compile.o ww3_systrk_compile.o -o ww3_systrk_mpi 

mkdir -p ${NWPSdir}/exec
mv -v ww3_systrk_mpi ${NWPSdir}/exec/ww3_systrk_mpi 
rm -fv temp1 temp2 ww3_systrk_compile.f90 w3strkmd_compile.f90 w3strkmd.mod


#!/bin/bash
# ----------------------------------------------------------- 
# UNIX Shell Script File
# Original Author(s): Roberto.Padilla@noaa.gov
# File Creation Date: 03/25/2015
# Date Last Modified: 
#
# Version control: 1.14
#
# Support Team:
#
# Contributors: Andre.VanderWesthuysen@noaa.gov
# ------------- Program Description and Details ------------- 
# ----------------------------------------------------------- 
#  This script produce all executables (as described bellow)
#  for NWPS
#
# ----------------------------------------------------------- 
set -xa
export pwd=`pwd`
export NWPSdir=${pwd%/*}

if [ "${NWPSdir}" == "" ]
    then 
    echo "ERROR - Your NWPSdir variable is not set"
    exit 1
fi

#Fetching external fix and binary files from rzdm
cd ${NWPSdir}/sorc
./get_externals.sh

export CONFIG_SITE=/tmp/dummy

# Detect machine (sets MACHINE_ID)
source $NWPSdir/env/detect_machine.sh  #ALI SALIMI 2/5/23 start

# Load modules
#source $NWPSdir/env/module-setup.sh
module use $NWPSdir/modulefiles
module load nwps_$MACHINE_ID
module list                            #ALI SALIMI 2/5/23 end

if [[ $MACHINE_ID = hera* ]] ; then
  source ../versions/build_hera.ver
  export optFlag="-O3"
  export COMP=ifort
  export COMPC=icc
  export C_COMP=icc

elif [[ $MACHINE_ID = wcoss2 ]]; then
    source ../versions/build_wcoss2.ver
    export optFlag="-O3"
    export COMP=ftn
    export COMPC=cc
    export C_COMP=cc

else
    echo WARNING: UNKNOWN PLATFORM 1>&2
fi

##module reset
#source ../modulefiles/build_nwps.modules
##module use ../modulefiles
##module load build_nwps.modules.lua
##module list

mkdir -p ${NWPSdir}/exec

#FOR NETCDF
echo "================== FOR NETCDF : make_netcdf-4.2.sh =================="
cd ${NWPSdir}/lib
./make_netcdf-4.2.sh | tee ./netcdf-4.2_build.log

export NETCDF=${NWPSdir}/lib/netcdf/${netcdf_ver}
export NETCDF_ROOT=${NWPSdir}/lib/netcdf/${netcdf_ver}
export HDF5_ROOT=${NWPSdir}/lib/hdf5/${hdf5_ver}
export NETCDF_INC=${NWPSdir}/lib/netcdf/${netcdf_ver}/include
export HDF5_INC=${NWPSdir}/lib/hdf5/${hdf5_ver}/include
export NETCDF_INCLUDES=${NWPSdir}/lib/netcdf/${netcdf_ver}/include
export NETCDF_LIBRARIES=${NWPSdir}/lib/netcdf/${netcdf_ver}/lib
export HDF5_LIBRARIES=${NWPSdir}/lib/hdf5/${hdf5_ver}/lib
export Z_INC=${NWPSdir}/lib/zlib/1.2.8/include
export Z_LIB=${NWPSdir}/lib/zlib/1.2.8/lib
export ZLIB_LIBDIR=${NWPSdir}/lib/zlib/1.2.8/lib
#FOR DEGRIB
echo "================== FOR DEGRIB : make_degrib-2.15.sh =================="
cd ${NWPSdir}/sorc
./make_degrib-2.15.sh
rc=$?
if [[ $rc -ne 0 ]] ; then
    echo "Fatal error in building degrib-2.15."
    echo "The log file is in sorc/degrib-2.15.cd/degrib_build.log"
fi

#FOR SWAN (REGULAR GRID)
echo "================== FOR SWAN (REGULAR GRID) : make_swan.sh  =================="
cd ${NWPSdir}/sorc
./make_swan.sh
rc=$?
if [[ $rc -ne 0 ]] ; then
    echo "Fatal error in building swan."
    echo "The log file is in sorc/swan.fd/swan_build.log"
fi

#FOR WAVE TRACKING
#The executable is ww3_sysprep.exe
echo "================== FOR WAVE TRACKING : make_sysprep.sh =================="
cd ${NWPSdir}/sorc
./make_ww3_sysprep.sh
rc=$?
if [[ $rc -ne 0 ]] ; then
    echo "Fatal error in building ww3_sysprep."
    echo "The log file is in sorc/ww3_sysprep.fd/sysprep_build.log"
fi

#FOR SWAN (UNSTRUCTURED MESH, incl. parallel libraries in estofs_padcirc.fd/work/odir4/)
echo "================== FOR SWAN (UNSTRUCTURED MESH,..) : make_padcirc.sh make_swan4110.sh =================="
cd ${NWPSdir}/sorc
./make_padcirc.sh
rc=$?
if [[ $rc -ne 0 ]] ; then
    echo "Fatal error in building padcirc."
    echo "The log file is in sorc/estofs_padcirc.fd/padcirc_build.log"
fi

./make_punswan4110.sh
rc=$?
if [[ $rc -ne 0 ]] ; then
    echo "Fatal error in building punswan4110."
    echo "The log file is in sorc/punswan4110.fd/punswan_build.log"
fi

#FOR RIP CURRENTS
#The executable is ripforecast.exe
echo "================== FOR RIP CURRENTS : make_ripforecast.sh =================="
./make_ripforecast.sh
rc=$?
if [[ $rc -ne 0 ]] ; then
    echo "Fatal error in building ripforecast."
    echo "The log file is in sorc/ripforecast.fd/ripcurrent_build.log"
fi

#FOR RUNUP
#The executable is runupforecast.exe
echo "================== FOR RUNUP : make_runupforecast.sh =================="
./make_runupforecast.sh
rc=$?
if [[ $rc -ne 0 ]] ; then
    echo "Fatal error in building runupforecast."
    echo "The log file is in sorc/runupforecast.fd/runup_build.log"
fi

#FOR PSURGE2NWPS
#The following will generate the executables: psurge2nwps_64, psurge_identify.exe and  psoutTOnwps.exe.
echo "================== FOR PSURGE2NWPS : make_psurge2nwps.sh =================="
./make_psurge2nwps.sh
rc=$?
if [[ $rc -ne 0 ]] ; then
    echo "Fatal error in building psurge2nwps."
    echo "Various log files are in sorc/psurge2nwps.cd/"
fi

#FOR UTILITY PROGRAMS
echo "================== FOR UTILITY PROGRAMS : make_nwps_utils.sh =================="
./make_nwps_utils.sh
rc=$?
if [[ $rc -ne 0 ]] ; then
    echo "Fatal error in building nwps_utils."
    echo "The log file is in sorc/nwps_utils.cd/nwps_utils_build.log"
fi

echo "NWPS Build complete"
exit 0


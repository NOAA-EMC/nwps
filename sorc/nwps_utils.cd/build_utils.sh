#!/bin/bash
# ----------------------------------------------------------- 
# UNIX Shell Script File
# Tested Operating System(s): RHEL 5,6,7
# Tested Run Level(s): 3, 5
# Shell Used: BASH shell
# Original Author(s): Douglas.Gaer@noaa.gov
# File Creation Date: 06/25/2011
# Date Last Modified: 05/19/2017
#
# Version control: 4.07
#
# Support Team:
#
# Contributors:
# ----------------------------------------------------------- 
# ------------- Program Description and Details ------------- 
# ----------------------------------------------------------- 
#
# Script used to build NWPS utils
#
# ----------------------------------------------------------- 

echo "Building NWPS utils for WCOSS Cray"

export NODETYPE="LOGIN"
#AW122816 export USE_IOBUF="NO"
export BUILD="intel"
export COMPILER="intel"

source $NWPSdir/env/detect_machine.sh  #ALI SALIMI 2/5/23 start


# NOTE: Do not invoke the Intel compilers directly through the 
# NOTE: icc, icpc, or ifort commands. The resulting executable 
# NOTE: will not run on the Cray XT series system.
# NOTE: Do not invoke the Intel compilers directly through the 
# NOTE: icc, icpc, or ifort commands. The resulting executable 
# NOTE: will not run on the Cray XT series system.
# Set make vars for all builds
# https://www.gnu.org/software/make/manual/html_node/Implicit-Variables.html

if [[ $MACHINE_ID = wcoss2 ]] ; then
export CC="cc"
export CXX="CC"
export CPP="${CC} -E"
export F90="ftn"
export F77="ftn"
export FC="ftn"

elif [[ $MACHINE_ID = wcoss2 ]]; then
export CC="icc"
export CXX="icc"
export CPP="${CC} -E"
export F90="ifort"
export F77="ifort"
export FC="ifort"
else
    echo WARNING: UNKNOWN PLATFORM 1>&2
fi

# removed "-axCore-AVX2" from following:
export CFLAGS="-v -Wall -O2"
export CXXFLAGS="-v -Wall -O2"
export FFLAGS="-v -warn all -O2 -mp1 -assume buffered_io"
export FCFLAGS="-v -warn all -O2 -mp1 -assume buffered_io"
export FFLAGS90="-v -warn all -O2 -mp1 -assume buffered_io"

# Set addtional variables for builds
export NUMCPUS=$(cat /proc/cpuinfo | grep processor | wc -l | tr -d " ")
export OMP_NUM_THREADS=${NUMCPUS}
export KMP_AFFINITY=disabled

#> module list |& grep -- PrgEnv-intel &>/dev/null
#> if [ $? -ne 0 ]; then module load PrgEnv-intel; fi

module list |& grep -- craype-haswell &>/dev/null
if [ $? -eq 0 ]; then module swap craype-haswell craype-sandybridge; fi

#AW122816 module list |& grep -- iobuf &>/dev/null
#AW122816 if [ $? -eq 0 ]; then module unload iobuf; fi
#AW122816 unset IOBUF_PARAMS
#AW122816 echo "IOBUF is disabled for this build"
echo "Build using Intel Cray-CE for haswell and sandybridge nodes, with haswell optimizations"
echo "Starting build"
date -u

export CLEAN="TRUE"
export INSTALL="TRUE"
export WORKDIR=$(pwd)
if [ ! -z ${1} ]; then export CLEAN="FALSE"; fi
if [ ! -z ${2} ]; then export INSTALL="FALSE"; fi

if [ "${CLEAN^^}" == "TRUE" ]; then 
    echo "We will clean all build DIRs following build"; 
    echo "To build with no clean:"
    echo "${0} NOCLEAN"
fi
if [ "${INSTALL^^}" == "TRUE" ]; then 
    echo "We will install new binaries following build"; 
    echo "To build with no clean and no install:"
    echo "${0} NOCLEAN NOINSTALL"
fi

cd check_awips_wind_file
make
if [ "${INSTALL^^}" == "TRUE" ]; then make install; fi
if [ "${CLEAN^^}" == "TRUE" ]; then make clean; fi
cd ${WORKDIR}

cd wave_runup_to_bin
make
if [ "${INSTALL^^}" == "TRUE" ]; then make install; fi
if [ "${CLEAN^^}" == "TRUE" ]; then make clean; fi
cd ${WORKDIR}

cd rip_current_to_bin
make
if [ "${INSTALL^^}" == "TRUE" ]; then make install; fi
if [ "${CLEAN^^}" == "TRUE" ]; then make clean; fi
cd ${WORKDIR}

cd fix_ascii_point_data
make
if [ "${INSTALL^^}" == "TRUE" ]; then make install; fi
if [ "${CLEAN^^}" == "TRUE" ]; then make clean; fi
cd ${WORKDIR}

cd read_awips_windfile
make
if [ "${INSTALL^^}" == "TRUE" ]; then make install; fi
if [ "${CLEAN^^}" == "TRUE" ]; then make clean; fi
cd ${WORKDIR}

cd readdat_util
make
if [ "${INSTALL^^}" == "TRUE" ]; then make install; fi
if [ "${CLEAN^^}" == "TRUE" ]; then make clean; fi
cd ${WORKDIR}

cd seaice_mask
make
if [ "${INSTALL^^}" == "TRUE" ]; then make install; fi
if [ "${CLEAN^^}" == "TRUE" ]; then make clean; fi
cd ${WORKDIR}

cd swan_out_to_bin
make
if [ "${INSTALL^^}" == "TRUE" ]; then make install; fi
if [ "${CLEAN^^}" == "TRUE" ]; then make clean; fi
cd ${WORKDIR}

cd swan_wavetrack_to_bin
make
if [ "${INSTALL^^}" == "TRUE" ]; then make install; fi
if [ "${CLEAN^^}" == "TRUE" ]; then make clean; fi
cd ${WORKDIR}

cd writedat_util
make
if [ "${INSTALL^^}" == "TRUE" ]; then make install; fi
if [ "${CLEAN^^}" == "TRUE" ]; then make clean; fi
cd ${WORKDIR}

cd g2_write_template
make
if [ "${INSTALL^^}" == "TRUE" ]; then make install; fi
if [ "${CLEAN^^}" == "TRUE" ]; then make clean; fi
cd ${WORKDIR}

cd shiproute_to_bin
make
if [ "${INSTALL^^}" == "TRUE" ]; then make install; fi
if [ "${CLEAN^^}" == "TRUE" ]; then make clean; fi
cd ${WORKDIR}

echo "NWPS utils build complete"
date -u
# ----------------------------------------------------------- 
# ******************************* 
# ********* End of File ********* 
# ******************************* 

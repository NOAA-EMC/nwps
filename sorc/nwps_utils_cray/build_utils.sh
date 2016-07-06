#!/bin/bash
# ----------------------------------------------------------- 
# UNIX Shell Script File
# Tested Operating System(s): RHEL 5,6,7
# Tested Run Level(s): 3, 5
# Shell Used: BASH shell
# Original Author(s): Douglas.Gaer@noaa.gov
# File Creation Date: 06/25/2011
# Date Last Modified: 06/03/2016
#
# Version control: 4.01
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
export USE_IOBUF="NO"
export BUILD="intel"
export COMPILER="intel"

# NOTE: Do not invoke the Intel compilers directly through the 
# NOTE: icc, icpc, or ifort commands. The resulting executable 
# NOTE: will not run on the Cray XT series system.
# NOTE: Do not invoke the Intel compilers directly through the 
# NOTE: icc, icpc, or ifort commands. The resulting executable 
# NOTE: will not run on the Cray XT series system.
# Set make vars for all builds
# https://www.gnu.org/software/make/manual/html_node/Implicit-Variables.html
export CC="cc"
export CXX="CC"
export CPP="${CC} -E"
export F90="ftn"
export F77="ftn"
export FC="ftn"
export CFLAGS="-v -Wall -O2 -axCore-AVX2"
export CXXFLAGS="-v -Wall -O2 -axCore-AVX2"
export FFLAGS="-v -warn all -O2 -mp1 -assume buffered_io -axCore-AVX2"
export FCFLAGS="-v -warn all -O2 -mp1 -assume buffered_io -axCore-AVX2"
export FFLAGS90="-v -warn all -O2 -mp1 -assume buffered_io -axCore-AVX2"

# Set addtional variables for builds
export NUMCPUS=$(cat /proc/cpuinfo | grep processor | wc -l | tr -d " ")
export OMP_NUM_THREADS=${NUMCPUS}
export KMP_AFFINITY=disabled

#> module list |& grep -- PrgEnv-intel &>/dev/null
#> if [ $? -ne 0 ]; then module load PrgEnv-intel; fi

module list |& grep -- craype-haswell &>/dev/null
if [ $? -eq 0 ]; then module swap craype-haswell craype-sandybridge; fi

module list |& grep -- iobuf &>/dev/null
if [ $? -eq 0 ]; then module unload iobuf; fi
unset IOBUF_PARAMS
echo "IOBUF is disabled for this build"
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

cd write_template
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

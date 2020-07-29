#!/bin/bash
# source this script to setup compiler ENV

export BUILD="gnu"
export COMPILER="gnu"

echo "Using GCC, G++, and GFORTRAN compilers for all binary builds"

if [ ! -z ${1} ]; then NODETYPE="${1^^}"; fi

if [ -z ${NODETYPE} ]
then
    echo "WARNING - NODETYPE is not set, defaulting to WS, workstation"
    export NODETYPE="WS"
fi

echo "INFO - Our node type is ${NODETYPE}"

if [ "${NODETYPE}" == "COMPUTE" ] || [ "${NODETYPE}" == "LOGIN" ]
then  
    if [ -z ${USE_IOBUF} ]
    then
	echo "INFO - USE_IOBUF is not set, defaulting to NO"
	export USE_IOBUF="NO"
    fi
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
    export CFLAGS="-v -Wall -O2"
    export CXXFLAGS="-v -Wall -O2"
    export FFLAGS="-v -Wall -O2"
    export FCFLAGS="-v -Wall -O2"
    export FFLAGS90="-v -Wall -O2"
    
    # Set addtional variables for builds
    export NUMCPUS=$(cat /proc/cpuinfo | grep processor | wc -l | tr -d " ")
    export OMP_NUM_THREADS=${NUMCPUS}
    export KMP_AFFINITY=disabled

    module list |& grep -- PrgEnv-intel &>/dev/null
    if [ $? -eq 0 ]; then module swap PrgEnv-intel PrgEnv-gnu; fi
    module list |& grep -- PrgEnv-cray &>/dev/null
    if [ $? -eq 0 ]; then module swap PrgEnv-cray PrgEnv-gnu; fi
    module list |& grep -- PrgEnv-gnu &>/dev/null
    if [ $? -ne 0 ]; then module load PrgEnv-gnu; fi

    if [ "${NODETYPE}" == "LOGIN" ]
    then 
	module list |& grep -- craype-haswell &>/dev/null
	if [ $? -eq 0 ]; then module swap craype-haswell craype-sandybridge; fi
	module list |& grep -- craype-sandybridge &>/dev/null
	if [ $? -ne 0 ]; then module load craype-sandybridge; fi
    fi

    if [ "${NODETYPE}" == "COMPUTE" ] 
    then 
	module list |& grep -- craype-sandybridge &>/dev/null
	if [ $? -eq 0 ]; then module swap craype-sandybridge craype-haswell; fi
	module list |& grep -- craype-haswell &>/dev/null
	if [ $? -ne 0 ]; then module load craype-haswell; fi
    fi

    if [ "${USE_IOBUF^^}" != "YES" ]; then
	module list |& grep -- iobuf &>/dev/null
	if [ $? -eq 0 ]; then module unload ifobuf; fi
	unset IOBUF_PARAMS
	echo "IOBUF is disabled for this build"
    else
	module list |& grep -- iobuf &>/dev/null
	if [ $? -ne 0 ]; then module load iobuf; fi
	export IOBUF_PARAMS="*:verbose:size=32M:count=4"
	echo "IOBUF is enabled for this build"
    fi
    echo "Using Cray wrappers for GCC, G++, and GFORTRAN"
fi

if [ "${NODETYPE}" == "WS" ]
then
    export CC="gcc"
    export CXX="g++"
    export F90="gfortran"
    export F77="gfortran"
    export FC="gfortran"
    export CFLAGS="-O2 -Wall -v"
    export CXXFLAGS="-O2 -Wall -v"
    export FFLAGS="-O2 -Wall -v"
    export FCFLAGS="-O2 -Wall -v"
    export FFLAGS90="-O2 -Wall -v"
    export NUMCPUS=$(cat /proc/cpuinfo | grep processor | wc -l | tr -d " ")
    export OMP_NUM_THREADS=${NUMCPUS}
    export OMP_PROC_BIND="true"
    export FORT_BUFFERED="true"
    export KMP_AFFINITY="granularity=fine,compact,1,0,verbose"
fi

echo "INFO - Setup env for GNU build on ${NODETYPE} node" 


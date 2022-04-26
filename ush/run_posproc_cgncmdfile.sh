#!/bin/bash

export ARCHBITS="64"
export MPIEXEC="mpiexec"
export OPAL_PREFIX="${LSF_BINDIR}/.."
export NCDUMP="ncdump"
export NCGEN="ncgen"
export PATH=$PATH:${EXECnwps}
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${HOMEnwps}/lib"

if [ "${N}" = 1 ]; then
	${NWPSdir}/ush/bin/nwps_posproc_CG1.pl
        export err=$?; err_chk
	${NWPSdir}/ush/bin/nwps_posproc_CG1.sh 1
        export err=$?; err_chk
else
        mpiexec -np 4 --cpu-bind verbose,core cfp ${RUNdir}/cgn_cmdfile
	export err=$?; err_chk
fi

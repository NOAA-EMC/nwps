#!/bin/bash

export ARCHBITS="64"
export MPIEXEC="mpirun.lsf"
export OPAL_PREFIX="${LSF_BINDIR}/.."
export PATH=$PATH:${EXECnwps}/grads
export GADDIR="${HOMEnwps}/lib/grads"
export GRIBMAP="${EXECnwps}/grads/"
export NCDUMP="ncdump"
export NCGEN="ncgen"
export GRADS="${EXECnwps}/grads/grads"
export WGRIB2="${EXECnwps}/wgrib2"
export DEGRIB="${EXECnwps}/degrib"
export PATH=$PATH:${EXECnwps}
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${HOMEnwps}/lib"

if [ "${N}" = 1 ]; then
	${NWPSdir}/ush/bin/nwps_posproc_CG1.pl
	${NWPSdir}/ush/bin/nwps_posproc_CG1.sh 1
else
	mpirun.lsf cfp ${RUNdir}/cgn_cmdfile
fi

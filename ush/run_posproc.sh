#!/bin/bash
set -xa

export ARCHBITS="64"
export PATH=$PATH:${EXECnwps}

if [ "${N}" = 1 ]; then
	${USHnwps}/nwps_posproc_cg1.pl
        export err=$?; err_chk
	${USHnwps}/nwps_posproc_cg1.sh 1
        export err=$?; err_chk
else
        mpiexec -np 4 --cpu-bind verbose,core cfp ${RUNdir}/cgn_cmdfile
	export err=$?; err_chk
fi

#!/bin/bash
set -xa

export ARCHBITS="64"
export WGRIB2="${EXECnwps}/wgrib2"
export PATH=$PATH:${EXECnwps}

if [ "${N}" = 1 ]; then
	${USHnwps}/nwps_posproc_cg1.pl
	${USHnwps}/nwps_posproc_cg1.sh 1
else
	mpirun.lsf cfp ${RUNdir}/cgn_cmdfile
fi

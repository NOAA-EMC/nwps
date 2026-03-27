#!/bin/bash
set -xa

export ARCHBITS="64"
export PATH=$PATH:${EXECnwps}


if [ "${N}" = 1 ]; then
    ${USHnwps}/nwps_posproc_cg1.pl
    export err=$?; err_chk
    if [ $err -ne 0 ]; then exit $err; fi

    ${USHnwps}/nwps_posproc_cg1.sh 1
    export err=$?; err_chk
    if [ $err -ne 0 ]; then exit $err; fi
else
    CGN_CMDFILE="${RUNdir}/cgn_cmdfile"
    while IFS= read -r command; do
        eval $command
        export err=$?; err_chk
        if [ $err -ne 0 ]; then exit $err; fi
    done < "$CGN_CMDFILE"
fi


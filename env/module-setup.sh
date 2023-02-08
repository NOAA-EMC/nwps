#!/bin/bash
set -u

if [[ $MACHINE_ID = hera* ]] ; then
    # We are on NOAA Hera
    if ( ! eval module help > /dev/null 2>&1 ) ; then
        source /apps/lmod/lmod/init/bash
    fi
    export LMOD_SYSTEM_DEFAULT_MODULES=contrib
    module reset

elif [[ $MACHINE_ID = orion* ]] ; then
    # We are on Orion
    if ( ! eval module help > /dev/null 2>&1 ) ; then
        source /apps/lmod/init/bash
    fi
    export LMOD_SYSTEM_DEFAULT_MODULES=contrib
    module reset

elif [[ $MACHINE_ID = wcoss2 ]]; then
    # We are on WCOSS2
    module reset

else
    echo WARNING: UNKNOWN PLATFORM 1>&2
fi

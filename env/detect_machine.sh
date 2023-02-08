#!/bin/bash

case $(hostname -f) in

  adecflow0[12].acorn.wcoss2.ncep.noaa.gov)  MACHINE_ID=wcoss2 ;; ### acorn
  alogin0[12].acorn.wcoss2.ncep.noaa.gov)    MACHINE_ID=wcoss2 ;; ### acorn
  clogin0[1-9].cactus.wcoss2.ncep.noaa.gov)  MACHINE_ID=wcoss2 ;; ### cactus01-9
  clogin10.cactus.wcoss2.ncep.noaa.gov)      MACHINE_ID=wcoss2 ;; ### cactus10
  dlogin0[1-9].dogwood.wcoss2.ncep.noaa.gov) MACHINE_ID=wcoss2 ;; ### dogwood01-9
  dlogin10.dogwood.wcoss2.ncep.noaa.gov)     MACHINE_ID=wcoss2 ;; ### dogwood10

  hfe0[1-9]) MACHINE_ID=hera ;; ### hera01-9
  hfe1[0-2]) MACHINE_ID=hera ;; ### hera10-12
  hecflow01) MACHINE_ID=hera ;; ### heraecflow01
esac

# Overwrite auto-detect with MACHINE if set
MACHINE_ID=${MACHINE:-${MACHINE_ID}}

# Append compiler (only on machines that have multiple compilers)
#if [ $MACHINE_ID = hera ] || [ $MACHINE_ID = cheyenne ]; then
#    MACHINE_ID=${MACHINE_ID}.${COMPILER}
#fi

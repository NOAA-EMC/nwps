#!/bin/bash
# NWPS DEV configuration
# Last Modified: 08/25/2011

# Add all NWPS default overrides here
# This config is only for NWPS DEV workstations

# Set our DEV data DIR
export NWPSDEVDATA="${HOME}/data/nwps"
if [ ! -e ${NWPSDEVDATA} ]; then mkdir -vp ${NWPSDEVDATA}; fi
if [ ! -e ${NWPSDEVDATA} ] 
then 
    echo "ERROR - Error creating DEV data DIR ${NWPSDEVDATA}" 
    exit 1
fi

# Set database DIRs here
export BATHYdb=${NWPSdir}/bathy_db
export SHAPEFILEdb=${NWPSdir}/shapefile_db

# Set processing DIRs here
export ARCHdir=${NWPSDEVDATA}/archive
export DATAdir=${NWPSDEVDATA}/data
export INPUTdir=${NWPSDEVDATA}/input
export VARdir=${NWPSDEVDATA}/var
export OUTPUTdir=${NWPSDEVDATA}/output
export RUNdir=${NWPSDEVDATA}/run
export TMPdir=${NWPSDEVDATA}/tmp
export LDMdir=${NWPSDEVDATA}/ldm

# Set log DIRs here
export LOGdir=${NWPSDEVDATA}/logs

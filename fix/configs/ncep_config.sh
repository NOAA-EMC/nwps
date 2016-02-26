#!/bin/bash
# NWPS NCEP configuration
# Last Modified: 03/05/2013

# Add all NWPS default overrides here
# This config is maintained by NCEP team and is our baseline config for NCEP workstations

# Set our NCEP data dir
export NWPSNCEPDATA=/export/emc-lw-rpadilla/wd20rp1/NewEsRtofs/data/nwps
if [ ! -e ${NWPSNCEPDATA} ]; then mkdir -vp ${NWPSNCEPDATA}; fi
if [ ! -e ${NWPSNCEPDATA} ] 
then 
    echo "ERROR - Error creating NCEP data DIR ${NWPSNCEPDATA}" 
    exit 1
fi

# Set database DIRs here
export BATHYdb=${NWPSdir}/bathy_db
export SHAPEFILEdb=${NWPSdir}/shapefile_db

# Set processing DIRs here
export ARCHdir=${NWPSNCEPDATA}/archive
export DATAdir=${NWPSNCEPDATA}/data
export INPUTdir=${NWPSNCEPDATA}/input
export VARdir=${NWPSNCEPDATA}/var
export OUTPUTdir=${NWPSNCEPDATA}/output
export RUNdir=${NWPSNCEPDATA}/run
export TMPdir=${NWPSNCEPDATA}/tmp
export LDMdir=${NWPSNCEPDATA}/ldm

# Set log DIRs here
export LOGdir=${NWPSNCEPDATA}/logs

# Set our regional baseline here
export DEBUGGING="FALSE"
export ISPRODUCTION="TRUE"
export SITETYPE="EMC"

# NOTE: This should only be set once your verify your IFPS account
# NOTE: can SSH to LDAD using keyed authentication. Move this export
# NOTE: to your site config: ${NWPSdir}/etc/${siteid}_config.sh
export SENDLDADALERTS="FALSE"

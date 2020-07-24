#!/bin/bash
# --------------------------------------------------------------------------- #
#                                                                             #
# Copy external fix files and binaries needed for build process and running   #
#                                                                             #
# Last Changed : 03-14-2019                                       March 2019  #
# --------------------------------------------------------------------------- #

if [ "${NWPSdir}" == "" ]
    then 
    echo "ERROR - Your NWPSdir variable is not set"
    exit 1
fi

echo 'Fetching externals...'
wget ftp://polar.ncep.noaa.gov/tempor/nwps_v1-3_ftp/fix/bathy_db.tar -P ${NWPSdir}/fix/
tar -C ${NWPSdir}/fix/ -xvf ${NWPSdir}/fix/bathy_db.tar
rm ${NWPSdir}/fix/bathy_db.tar
wget ftp://polar.ncep.noaa.gov/tempor/nwps_v1-3_ftp/fix/pdef_ncep_global -P ${NWPSdir}/fix/
wget ftp://polar.ncep.noaa.gov/tempor/nwps_v1-3_ftp/ush/rtofs/datfiles/pdef_ncep_global.gz -P ${NWPSdir}/ush/rtofs/datfiles/
wget ftp://polar.ncep.noaa.gov/tempor/nwps_v1-3_ftp/ush/rtofs/datfiles/pdef_ncep_reg1.gz -P ${NWPSdir}/ush/rtofs/datfiles/
wget ftp://polar.ncep.noaa.gov/tempor/nwps_v1-3_ftp/ush/rtofs/datfiles/pdef_ncep_reg2.gz -P ${NWPSdir}/ush/rtofs/datfiles/
wget ftp://polar.ncep.noaa.gov/tempor/nwps_v1-3_ftp/ush/rtofs/datfiles/pdef_ncep_reg3.gz -P ${NWPSdir}/ush/rtofs/datfiles/
wget ftp://polar.ncep.noaa.gov/tempor/nwps_v1-3_ftp/ush/python/etc/default/rdat.tar -P ${NWPSdir}/ush/python/etc/default/
tar -C ${NWPSdir}/ush/python/etc/default/ -xvf ${NWPSdir}/ush/python/etc/default/rdat.tar
rm ${NWPSdir}/ush/python/etc/default/rdat.tar

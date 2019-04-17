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
scp andre.westhuysen@emcrzdm:/home/www/polar/nwps/EMC_nwps_external/fix/bathy_db.tar ${NWPSdir}/fix/
tar -C ${NWPSdir}/fix/ -xvf ${NWPSdir}/fix/bathy_db.tar
rm ${NWPSdir}/fix/bathy_db.tar
scp andre.westhuysen@emcrzdm:/home/www/polar/nwps/EMC_nwps_external/fix/pdef_ncep_global ${NWPSdir}/fix/
#scp andre.westhuysen@emcrzdm:/home/www/polar/nwps/EMC_nwps_external/sorc/python_modules/basemap-1.0.7.tar.gz ${NWPSdir}/sorc/python_modules/
#scp andre.westhuysen@emcrzdm:/home/www/polar/nwps/EMC_nwps_external/sorc/python_modules/matplotlib-1.5.1.tar.gz ${NWPSdir}/sorc/python_modules/
scp andre.westhuysen@emcrzdm:/home/www/polar/nwps/EMC_nwps_external/ush/rtofs/datfiles/pdef_ncep_global.gz ${NWPSdir}/ush/rtofs/datfiles/
scp andre.westhuysen@emcrzdm:/home/www/polar/nwps/EMC_nwps_external/ush/rtofs/datfiles/pdef_ncep_reg1.gz ${NWPSdir}/ush/rtofs/datfiles/
scp andre.westhuysen@emcrzdm:/home/www/polar/nwps/EMC_nwps_external/ush/rtofs/datfiles/pdef_ncep_reg2.gz ${NWPSdir}/ush/rtofs/datfiles/
scp andre.westhuysen@emcrzdm:/home/www/polar/nwps/EMC_nwps_external/ush/rtofs/datfiles/pdef_ncep_reg3.gz ${NWPSdir}/ush/rtofs/datfiles/
scp andre.westhuysen@emcrzdm:/home/www/polar/nwps/EMC_nwps_external/ush/python/etc/default/rdat.tar ${NWPSdir}/ush/python/etc/default
tar -C ${NWPSdir}/ush/python/etc/default/ -xvf ${NWPSdir}/ush/python/etc/default/rdat.tar
rm ${NWPSdir}/ush/python/etc/default/rdat.tar

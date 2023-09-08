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
scp /lfs/h2/emc/couple/noscrub/ali.salimi/git/fv3gfs/fix/fix_nwps/v_1-3/fix/bathy_db.tar ${NWPSdir}/fix/
if [ -d "${NWPSdir}/fix/bathy_db" ]; then rm -Rf "${NWPSdir}/fix/bathy_db"; fi
mkdir -p ${NWPSdir}/fix/bathy_db/
tar -C ${NWPSdir}/fix/bathy_db/ -xvf ${NWPSdir}/fix/bathy_db.tar
rm ${NWPSdir}/fix/bathy_db.tar
scp /lfs/h2/emc/couple/noscrub/ali.salimi/git/fv3gfs/fix/fix_nwps/v_1-3/fix/pdef_ncep_global ${NWPSdir}/fix/
scp /lfs/h2/emc/couple/noscrub/ali.salimi/git/fv3gfs/fix/fix_nwps/v_1-3/ush/rtofs/datfiles/pdef_ncep_global.gz ${NWPSdir}/ush/rtofs/datfiles/
scp /lfs/h2/emc/couple/noscrub/ali.salimi/git/fv3gfs/fix/fix_nwps/v_1-3/ush/rtofs/datfiles/pdef_ncep_reg1.gz ${NWPSdir}/ush/rtofs/datfiles/
scp /lfs/h2/emc/couple/noscrub/ali.salimi/git/fv3gfs/fix/fix_nwps/v_1-3/ush/rtofs/datfiles/pdef_ncep_reg2.gz ${NWPSdir}/ush/rtofs/datfiles/
scp /lfs/h2/emc/couple/noscrub/ali.salimi/git/fv3gfs/fix/fix_nwps/v_1-3/ush/rtofs/datfiles/pdef_ncep_reg3.gz ${NWPSdir}/ush/rtofs/datfiles/
scp /lfs/h2/emc/couple/noscrub/ali.salimi/git/fv3gfs/fix/fix_nwps/v_1-3/ush/python/etc/default/rdat.tar ${NWPSdir}/ush/python/etc/default
tar -C ${NWPSdir}/ush/python/etc/default/ -xvf ${NWPSdir}/ush/python/etc/default/rdat.tar
rm ${NWPSdir}/ush/python/etc/default/rdat.tar
scp /lfs/h2/emc/couple/noscrub/ali.salimi/git/fv3gfs/fix/fix_nwps/v_1-3/lib/cartopy_shapefiles.tgz ${NWPSdir}/lib/cartopy_shapefiles.tgz
tar -C ${NWPSdir}/lib/ -xvf ${NWPSdir}/lib/cartopy_shapefiles.tgz
rm ${NWPSdir}/lib/cartopy_shapefiles.tgz

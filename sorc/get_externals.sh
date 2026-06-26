#!/bin/bash
set -xa
# --------------------------------------------------------------------------- #
#                                                                             #
# Copy external fix files and binaries needed for build process and running   #
#                                                                             #
# Last Changed : 03-14-2019                                       March 2019  #
# --------------------------------------------------------------------------- #

if [ "${HOMEnwps}" == "" ]
    then 
    echo "ERROR - Your HOMEnwps variable is not set"
    exit 1
fi

echo 'Fetching externals...'
scp /lfs/h2/emc/couple/noscrub/saeideh.banihashemi/git/fv3gfs/fix/fix_nwps/v_1-5/fix/bathy_db_v1-5.tar ${HOMEnwps}/fix/
if [ -d "${HOMEnwps}/fix/bathy_db" ]; then rm -Rf "${HOMEnwps}/fix/bathy_db"; fi
mkdir -p ${HOMEnwps}/fix/bathy_db/
tar -C ${HOMEnwps}/fix/bathy_db/ -xvf ${HOMEnwps}/fix/bathy_db_v1-5.tar
rm ${HOMEnwps}/fix/bathy_db_v1-5.tar

rm -rf ${HOMEnwps}/fix/bathy_db/sew
rm -rf ${HOMEnwps}/fix/bathy_db/crp
scp /lfs/h2/emc/couple/noscrub/saeideh.banihashemi/git/fv3gfs/fix/fix_nwps/v_1p5/fix/bathy_db_v1p5.tar ${HOMEnwps}/fix/
tar -C ${HOMEnwps}/fix/bathy_db/ -xvf ${HOMEnwps}/fix/bathy_db_v1p5.tar
rm ${HOMEnwps}/fix/bathy_db_v1p5.tar

scp /lfs/h2/emc/couple/noscrub/saeideh.banihashemi/git/fv3gfs/fix/fix_nwps/v_1-5/fix/pdef_ncep_global ${HOMEnwps}/fix/
scp /lfs/h2/emc/couple/noscrub/saeideh.banihashemi/git/fv3gfs/fix/fix_nwps/v_1-5/ush/rtofs/datfiles/pdef_ncep_global.gz ${HOMEnwps}/ush/rtofs/datfiles/
scp /lfs/h2/emc/couple/noscrub/saeideh.banihashemi/git/fv3gfs/fix/fix_nwps/v_1-5/ush/rtofs/datfiles/pdef_ncep_reg1.gz ${HOMEnwps}/ush/rtofs/datfiles/
scp /lfs/h2/emc/couple/noscrub/saeideh.banihashemi/git/fv3gfs/fix/fix_nwps/v_1-5/ush/rtofs/datfiles/pdef_ncep_reg2.gz ${HOMEnwps}/ush/rtofs/datfiles/
scp /lfs/h2/emc/couple/noscrub/saeideh.banihashemi/git/fv3gfs/fix/fix_nwps/v_1-5/ush/rtofs/datfiles/pdef_ncep_reg3.gz ${HOMEnwps}/ush/rtofs/datfiles/
scp /lfs/h2/emc/couple/noscrub/saeideh.banihashemi/git/fv3gfs/fix/fix_nwps/v_1-5/ush/python/etc/default/rdat.tar ${HOMEnwps}/ush/python/etc/default
tar -C ${HOMEnwps}/ush/python/etc/default/ -xvf ${HOMEnwps}/ush/python/etc/default/rdat.tar
rm ${HOMEnwps}/ush/python/etc/default/rdat.tar
scp /lfs/h2/emc/couple/noscrub/saeideh.banihashemi/git/fv3gfs/fix/fix_nwps/v_1-5/lib/cartopy_shapefiles.tgz ${HOMEnwps}/lib/cartopy_shapefiles.tgz
tar -C ${HOMEnwps}/lib/ -xvf ${HOMEnwps}/lib/cartopy_shapefiles.tgz
rm ${HOMEnwps}/lib/cartopy_shapefiles.tgz

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

source $NWPSdir/env/detect_machine.sh #Ali Salimi 2/8/2023 

if [[ $MACHINE_ID = hera* ]] ; then
  echo 'Fetching externals...'
  scp /scratch2/NCEPDEV/marine/alisalimi/NWPS/nwps-dev/fix/fix_nwps/v_1-5/fix/bathy_db_v1-5.tar ${NWPSdir}/fix/
  if [ -d "${NWPSdir}/fix/bathy_db_v1-5.tar" ]; then rm -Rf "${NWPSdir}/fix/bathy_db_v1-5.tar"; fi
  mkdir -p ${NWPSdir}/fix/bathy_db/
  tar -C ${NWPSdir}/fix/bathy_db/ -xvf ${NWPSdir}/fix/bathy_db_v1-5.tar
  rm ${NWPSdir}/fix/bathy_db.tar
  scp /scratch2/NCEPDEV/marine/alisalimi/NWPS/nwps-dev/fix/fix_nwps/v_1-5/fix/pdef_ncep_global ${NWPSdir}/fix/
  scp /scratch2/NCEPDEV/marine/alisalimi/NWPS/nwps-dev/fix/fix_nwps/v_1-5/ush/rtofs/datfiles/pdef_ncep_global.gz ${NWPSdir}/ush/rtofs/datfiles/
  scp /scratch2/NCEPDEV/marine/alisalimi/NWPS/nwps-dev/fix/fix_nwps/v_1-5/ush/rtofs/datfiles/pdef_ncep_reg1.gz ${NWPSdir}/ush/rtofs/datfiles/
  scp /scratch2/NCEPDEV/marine/alisalimi/NWPS/nwps-dev/fix/fix_nwps/v_1-5/ush/rtofs/datfiles/pdef_ncep_reg2.gz ${NWPSdir}/ush/rtofs/datfiles/
  scp /scratch2/NCEPDEV/marine/alisalimi/NWPS/nwps-dev/fix/fix_nwps/v_1-5/ush/rtofs/datfiles/pdef_ncep_reg3.gz ${NWPSdir}/ush/rtofs/datfiles/
  scp /scratch2/NCEPDEV/marine/alisalimi/NWPS/nwps-dev/fix/fix_nwps/v_1-5/ush/python/etc/default/rdat.tar ${NWPSdir}/ush/python/etc/default
  tar -C ${NWPSdir}/ush/python/etc/default/ -xvf ${NWPSdir}/ush/python/etc/default/rdat.tar
  rm ${NWPSdir}/ush/python/etc/default/rdat.tar
  scp /scratch2/NCEPDEV/marine/alisalimi/NWPS/nwps-dev/fix/fix_nwps/v_1-5/lib/cartopy_shapefiles.tgz ${NWPSdir}/lib/cartopy_shapefiles.tgz
  tar -C ${NWPSdir}/lib/ -xvf ${NWPSdir}/lib/cartopy_shapefiles.tgz
  rm ${NWPSdir}/lib/cartopy_shapefiles.tgz


elif [[ $MACHINE_ID = wcoss2 ]]; then
    echo 'Fetching externals...'
    scp /lfs/h2/emc/couple/noscrub/andre.vanderwesthuysen/git/fv3gfs/fix/fix_nwps/v_1-5/fix/bathy_db_v1-5.tar ${NWPSdir}/fix/
    if [ -d "${NWPSdir}/fix/bathy_db" ]; then rm -Rf "${NWPSdir}/fix/bathy_db"; fi
    mkdir -p ${NWPSdir}/fix/bathy_db/
    tar -C ${NWPSdir}/fix/bathy_db/ -xvf ${NWPSdir}/fix/bathy_db_v1-5.tar
    rm ${NWPSdir}/fix/bathy_db_v1-5.tar
    scp /lfsi/h2/emc/couple/noscrub/andre.vanderwesthuysen/git/fv3gfs/fix/fix_nwps/v_1-5/fix/pdef_ncep_global ${NWPSdir}/fix/
    scp /lfs/h2/emc/couple/noscrub/andre.vanderwesthuysen/git/fv3gfs/fix/fix_nwps/v_1-5/ush/rtofs/datfiles/pdef_ncep_global.gz ${NWPSdir}/ush/rtofs/datfiles/
    scp /lfs/h2/emc/couple/noscrub/andre.vanderwesthuysen/git/fv3gfs/fix/fix_nwps/v_1-5/ush/rtofs/datfiles/pdef_ncep_reg1.gz ${NWPSdir}/ush/rtofs/datfiles/
    scp /lfs/h2/emc/couple/noscrub/andre.vanderwesthuysen/git/fv3gfs/fix/fix_nwps/v_1-5/ush/rtofs/datfiles/pdef_ncep_reg2.gz ${NWPSdir}/ush/rtofs/datfiles/
    scp /lfs/h2/emc/couple/noscrub/andre.vanderwesthuysen/git/fv3gfs/fix/fix_nwps/v_1-5/ush/rtofs/datfiles/pdef_ncep_reg3.gz ${NWPSdir}/ush/rtofs/datfiles/
    scp /lfs/h2/emc/couple/noscrub/andre.vanderwesthuysen/git/fv3gfs/fix/fix_nwps/v_1-5/ush/python/etc/default/rdat.tar ${NWPSdir}/ush/python/etc/default
    tar -C ${NWPSdir}/ush/python/etc/default/ -xvf ${NWPSdir}/ush/python/etc/default/rdat.tar
    rm ${NWPSdir}/ush/python/etc/default/rdat.tar
    scp /lfs/h2/emc/couple/noscrub/andre.vanderwesthuysen/git/fv3gfs/fix/fix_nwps/v_1-5/lib/cartopy_shapefiles.tgz ${NWPSdir}/lib/cartopy_shapefiles.tgz
    tar -C ${NWPSdir}/lib/ -xvf ${NWPSdir}/lib/cartopy_shapefiles.tgz
    rm ${NWPSdir}/lib/cartopy_shapefiles.tgz


else
    echo WARNING: UNKNOWN PLATFORM 1>&2
fi


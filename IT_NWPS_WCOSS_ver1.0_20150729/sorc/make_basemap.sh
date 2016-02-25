#!/bin/sh
export pwd=`pwd`
export HOMEnwps=${pwd%/*}
#Make GEOS first
if $(cd $HOMEnwps/sorc); then
    cd ${HOMEnwps}/sorc
    tar xf basemap-1.0.7.tgz
    if $(cd $HOMEnwps/sorc/basemap-1.0.7/geos-3.3.3); then
        cd ${HOMEnwps}/sorc/basemap-1.0.7/geos-3.3.3
        make clean
        ./configure --prefix=${HOMEnwps}/lib/basemap --libexecdir=${HOMEnwps}/lib/basemap --libdir=${HOMEnwps}/lib/basemap --includedir=${HOMEnwps}/lib/basemap --bindir=${HOMEnwps}/lib/basemap
        make
        make install
        export GEOS_DIR=${HOMEnwps}/lib/basemap
        ln -sf ${HOMEnwps}/lib/basemap ${HOMEnwps}/lib/basemap/lib
        ln -sf ${HOMEnwps}/lib/basemap ${HOMEnwps}/lib/basemap/include
        make clean
        
        #Make BASEMAP
        python setup.py clean -a
        cd $HOMEnwps/sorc/basemap-1.0.7
        python setup.py install -f --prefix=${GEOS_DIR} --install-lib=${GEOS_DIR}
    fi
else
    echo "\$HOMEnwps is not defined"
fi

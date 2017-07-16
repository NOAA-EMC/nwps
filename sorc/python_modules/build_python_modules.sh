#!/bin/ksh

# build script for NWPS python modules: 
#   matplotlib
#   basemap

if [ "${NWPSdir}" == "" ]; then
    echo "ERROR - Your NWPSdir variable is not set"
    exit 1
fi

# change these to point to source and destination (build)
SORC_DIR=$PWD  # assumes that the build script is in the source packages dir
BUILD_ROOT=${NWPSdir}
#BUILD_DIR=$BUILD_ROOT/lib/python/
BUILD_DIR=$BUILD_ROOT/lib64/python/

# version numbers for the components (just to keep track of things)
#MPL_VERSION='1.2.0'
MPL_VERSION='1.5.1'
BASEMAP_VERSION='1.0.7'

# sanity check first.  Check for non-system pythons.
if [[ `which python` != '/usr/bin/python' ]]; then
  echo 'Oh noes!  You have a non-system python in your path.  I am quitting now.'
  exit
fi

# make sure that the build directory exists
if [ -d ${BUILD_DIR} ]; then
    echo "Removing Python module build directory "${BUILD_DIR}
    rm -rf ${BUILD_DIR}
fi
echo "Creating Python module build directory "${BUILD_DIR}
mkdir -p ${BUILD_DIR}
mkdir -p ${BUILD_DIR}/python_modules/lib64/python2.6/site-packages/
export PYTHONPATH=${BUILD_DIR}/python_modules/lib64/python2.6/site-packages/:${PYTHONPATH}

# matplotlib build
cd $SORC_DIR
tar -zxvf matplotlib-${MPL_VERSION}.tar.gz
cd matplotlib-${MPL_VERSION}
python setup.py build
python setup.py install --prefix=$BUILD_DIR/python_modules

# basemap build
# begin with geos sub-build
cd $SORC_DIR
tar -zxvf basemap-${BASEMAP_VERSION}.tar.gz
cd basemap-${BASEMAP_VERSION}
cd geos-3.3.3
./configure --prefix=$BUILD_DIR/basemap-${BASEMAP_VERSION}/geos-3.3.3
make clean
make 
make install
cd $SORC_DIR/basemap-${BASEMAP_VERSION}
export GEOS_DIR=$BUILD_DIR/basemap-${BASEMAP_VERSION}/geos-3.3.3
python setup.py build
python setup.py install --prefix=$BUILD_DIR/python_modules

# set up the modulefile
mkdir -p $BUILD_DIR/modulefiles/nwps_python
cat > $BUILD_DIR/modulefiles/nwps_python/1.0.0 << EOF
#%Module######################################################################
##
##      NWPS Python modulefile
##
proc ModulesHelp { } {
        puts stderr "Sets up supplemental python packages for NWPS"
	}
set base $BUILD_DIR/python_modules/lib64/python2.6/site-packages

prepend-path PYTHONPATH \$base

EOF

echo '**************** build complete *********************'
echo 'use these commands to add the modules to the system python:'
echo "> module use $BUILD_DIR/modulefiles"
echo '> module load nwps_python'


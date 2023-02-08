#!/bin/bash

set -eux

install_prefix=${NWPSdir}/lib

# Detect machine (sets MACHINE_ID)
source $NWPSdir/env/detect_machine.sh  #ALI SALIMI 2/5/23 start

if [[ $MACHINE_ID = hera* ]] ; then
  export CC=icc
  export FC=ifort
  export CXX=icc

elif [[ $MACHINE_ID = wcoss2 ]]; then
    export CC=cc
    export FC=ftn
    export CXX=CC
else
    echo WARNING: UNKNOWN PLATFORM 1>&2
fi


cd ${NWPSdir}/lib/sorc
# Ali Salimi
git clone https://github.com/fmrico/zlib-1.2.8.git zlib-1.2.8
chmod -R 777 .*
cd zlib-1.2.8

./configure \
--prefix=$install_prefix/zlib/1.2.8
make
make check
make install

#Ali Salimi

cd ${NWPSdir}/lib/sorc

rm -rf hdf5-1_8_9 netcdf-4.2 netcdf-fortran-4.2

git clone -b hdf5-1_8_9 https://github.com/HDFGroup/hdf5.git hdf5-1_8_9
cd hdf5-1_8_9
#./configure --prefix=$install_prefix/hdf5 --enable-hl --enable-shared=no
./configure \
--prefix=$install_prefix/hdf5/1.8.9 \
--disable-parallel \
--disable-shared \
--enable-fortran \
--enable-fortran2003 \
--enable-cxx \
--with-zlib=${NWPSdir}/lib/zlib/1.2.8/lib
make -j6
make install

cd ${NWPSdir}/lib/sorc

export HDF5_ROOT=${install_prefix}/hdf5/1.8.9
export NETCDF_ROOT=${install_prefix}/netcdf/4.2
export ZLIB_LIBDIR=${install_prefix}/zlib/1.2.8/lib
export CPPFLAGS="-I${HDF5_ROOT}/include"
export LDFLAGS="-L${HDF5_ROOT}/lib -L${ZLIB_LIBDIR}"
export LIBS="-lhdf5_hl -lhdf5 -lz"

git clone -b netcdf-4.2 https://github.com/Unidata/netcdf-c.git netcdf-4.2
cd netcdf-4.2
autoreconf -i
./configure --prefix=${install_prefix}/netcdf/4.2 --enable-cdf5 --disable-dap --enable-netcdf-4 --disable-doxygen --disable-shared
make -j6
make install

cd ${NWPSdir}/lib/sorc

export CPPFLAGS="-I${NETCDF_ROOT}/include -I${HDF5_ROOT}/include -DpgiFortran"
export LDFLAGS="-L${NETCDF_ROOT}/lib -L${HDF5_ROOT}/lib -L${ZLIB_LIBDIR}"
export LIBS="-lnetcdf -lhdf5_hl -lhdf5 -lz"

git clone https://github.com/Unidata/netcdf-fortran.git -b netcdf-fortran-4.2 netcdf-fortran-4.2
cd netcdf-fortran-4.2

# Makeinfo is not installed, which is only used to build documentation
# But no option to disable so modify build to remove references to man4 build dir
rm -rf man4
sed -i "s: man4::" Makefile.am
sed -i '/man4\/Makefile/d' ./configure.ac
sed -i '79,80d' fortran/Makefile.am

autoreconf -i
./configure --prefix=${install_prefix}/netcdf/4.2 --enable-shared=no
make -j6
make install

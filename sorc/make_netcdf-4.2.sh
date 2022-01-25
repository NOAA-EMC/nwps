#!/bin/bash

set -eux

mkdir -p ${NWPSdir}/lib
install_prefix=${NWPSdir}/lib

module load PrgEnv-intel/8.1.0
module load intel/19.1.3.304
module load craype/2.7.10
module load cray-mpich/8.1.7
module load zlib/1.2.11
module load curl/7.72.0

export CC=cc
export FC=ftn
export CXX=CC

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
--with-zlib=${ZLIB_LIBDIR}
make -j6
make install

cd ..

export HDF5_ROOT=${install_prefix}/hdf5/1.8.9
export NETCDF_ROOT=${install_prefix}/netcdf/4.2

export CPPFLAGS="-I${HDF5_ROOT}/include"
export LDFLAGS="-L${HDF5_ROOT}/lib -L${ZLIB_LIBDIR}"
export LIBS="-lhdf5_hl -lhdf5 -lz"

git clone -b netcdf-4.2 https://github.com/Unidata/netcdf-c.git netcdf-4.2
cd netcdf-4.2
autoreconf -i
./configure --prefix=${install_prefix}/netcdf/4.2 --enable-cdf5 --disable-dap --enable-netcdf-4 --disable-doxygen --disable-shared
make -j6
make install

cd ..

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

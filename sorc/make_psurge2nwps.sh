#!/bin/bash

if [ "${NWPSdir}" == "" ]
    then
    echo "ERROR - Your NWPSdir variable is not set"
    exit 1
fi

FC=${COMP:-ftn}
F77FLAGS="${FFLAGS:-}"
F90FLAGS="${FCFLAGS:-${FFLAGS:-}}"

echo "Building psoutTOnwps"  | tee ${NWPSdir}/sorc/psurge2nwps.cd/psoutTOnwps_build.log

cd ${NWPSdir}/sorc/libaat
./configure \
  --prefix=${NWPSdir}/sorc/libaat \
  CC=cc \
  FC="${FC}" \
  FFLAGS="${F77FLAGS}" \
  FCFLAGS="${F90FLAGS}" | tee -a ${NWPSdir}/sorc/psurge2nwps.cd/psoutTOnwps_build.log
make clean | tee -a ${NWPSdir}/sorc/psurge2nwps.cd/psoutTOnwps_build.log
make \
  FC="${FC}" \
  FFLAGS="${F77FLAGS}" \
  FCFLAGS="${F90FLAGS}" | tee -a ${NWPSdir}/sorc/psurge2nwps.cd/psoutTOnwps_build.log

cd ${NWPSdir}/sorc/psurge2nwps.cd
${FC} ${F77FLAGS} -o psoutTOnwps.exe psoutTOnwps.f | tee -a ${NWPSdir}/sorc/psurge2nwps.cd/psoutTOnwps_build.log
mv -v psoutTOnwps.exe ${NWPSdir}/exec/psurge2nwps_psoutTOnwps.exe
echo "Build complete" | tee -a ${NWPSdir}/sorc/psurge2nwps.cd/psoutTOnwps_build.log

echo "Building psurge_identify"  | tee ${NWPSdir}/sorc/psurge2nwps.cd/psurge_identify_build.log
${FC} ${F77FLAGS} -o psurge_identify.exe psurge_identify.f | tee -a ${NWPSdir}/sorc/psurge2nwps.cd/psurge_identify_build.log
mv -v psurge_identify.exe ${NWPSdir}/exec/psurge2nwps_identify.exe
echo "Build complete" | tee -a ${NWPSdir}/sorc/psurge2nwps.cd/psurge_identify_build.log

echo "Building psurge_combine" | tee ${NWPSdir}/sorc/psurge2nwps.cd/psurge_combine_build.log
rm -f ${NWPSdir}/lib/r8lib.o | tee -a ${NWPSdir}/sorc/psurge2nwps.cd/psurge_combine_build.log

cd ${NWPSdir}/lib/sorc/r8lib/
${FC} ${F90FLAGS} -c r8lib.f90 | tee -a ${NWPSdir}/sorc/psurge2nwps.cd/psurge_combine_build.log
mv -v r8lib.o ${NWPSdir}/lib/r8lib.o

cd ${NWPSdir}/sorc/psurge2nwps.cd/
rm -f psurge_combine.o pwl_interp_2d.o | tee -a ${NWPSdir}/sorc/psurge2nwps.cd/psurge_combine_build.log
${FC} ${F90FLAGS} -c pwl_interp_2d.f90 | tee -a ${NWPSdir}/sorc/psurge2nwps.cd/psurge_combine_build.log
${FC} ${F90FLAGS} -c psurge_combine.f90 | tee -a ${NWPSdir}/sorc/psurge2nwps.cd/psurge_combine_build.log
${FC} ${F90FLAGS} -o psurge_combine.exe psurge_combine.o pwl_interp_2d.o ${NWPSdir}/lib/r8lib.o | tee -a ${NWPSdir}/sorc/psurge2nwps.cd/psurge_combine_build.log
mv -v psurge_combine.exe ${NWPSdir}/exec/psurge2nwps_combine.exe
echo "Build complete" | tee -a ${NWPSdir}/sorc/psurge2nwps.cd/psurge_combine_build.log

echo "Building psurge2nwps"  | tee ${NWPSdir}/sorc/psurge2nwps.cd/psurge2nwps_build.log
cd ${NWPSdir}/sorc/psurge2nwps.cd
make clean | tee -a ${NWPSdir}/sorc/psurge2nwps.cd/psurge2nwps_build.log
make \
  FC="${FC}" \
  FFLAGS="${F77FLAGS}" \
  FCFLAGS="${F90FLAGS}" | tee -a ${NWPSdir}/sorc/psurge2nwps.cd/psurge2nwps_build.log
mv -v psurge2nwps_64 ${NWPSdir}/exec/psurge2nwps
echo "Build complete" | tee -a ${NWPSdir}/sorc/psurge2nwps.cd/psurge2nwps_build.log

exit 0

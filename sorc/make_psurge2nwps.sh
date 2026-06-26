#!/bin/bash
set -xa

if [ "${HOMEnwps}" == "" ]
    then
    echo "ERROR - Your HOMEnwps variable is not set"
    exit 1
fi

FC=${COMP:-ftn}
F77FLAGS="${FFLAGS:-}"
F90FLAGS="${FCFLAGS:-${FFLAGS:-}}"

echo "Building psoutTOnwps"  | tee ${HOMEnwps}/sorc/psurge2nwps.cd/psoutTOnwps_build.log

cd ${HOMEnwps}/sorc/libaat
./configure \
  --prefix=${HOMEnwps}/sorc/libaat \
  CC=cc \
  FC="${FC}" \
  FFLAGS="${F77FLAGS}" \
  FCFLAGS="${F90FLAGS}" | tee -a ${HOMEnwps}/sorc/psurge2nwps.cd/psoutTOnwps_build.log
make clean | tee -a ${HOMEnwps}/sorc/psurge2nwps.cd/psoutTOnwps_build.log
make \
  FC="${FC}" \
  FFLAGS="${F77FLAGS}" \
  FCFLAGS="${F90FLAGS}" | tee -a ${HOMEnwps}/sorc/psurge2nwps.cd/psoutTOnwps_build.log

cd ${HOMEnwps}/sorc/psurge2nwps.cd
${FC} ${F77FLAGS} -o psoutTOnwps.exe psoutTOnwps.f | tee -a ${HOMEnwps}/sorc/psurge2nwps.cd/psoutTOnwps_build.log
mv -v psoutTOnwps.exe ${HOMEnwps}/exec/psurge2nwps_psoutTOnwps.exe
echo "Build complete" | tee -a ${HOMEnwps}/sorc/psurge2nwps.cd/psoutTOnwps_build.log

echo "Building psurge_identify"  | tee ${HOMEnwps}/sorc/psurge2nwps.cd/psurge_identify_build.log
${FC} ${F77FLAGS} -o psurge_identify.exe psurge_identify.f | tee -a ${HOMEnwps}/sorc/psurge2nwps.cd/psurge_identify_build.log
mv -v psurge_identify.exe ${HOMEnwps}/exec/psurge2nwps_identify.exe
echo "Build complete" | tee -a ${HOMEnwps}/sorc/psurge2nwps.cd/psurge_identify_build.log

echo "Building psurge_combine" | tee ${HOMEnwps}/sorc/psurge2nwps.cd/psurge_combine_build.log
rm -f ${HOMEnwps}/lib/r8lib.o | tee -a ${HOMEnwps}/sorc/psurge2nwps.cd/psurge_combine_build.log

cd ${HOMEnwps}/lib/sorc/r8lib/
${FC} ${F90FLAGS} -c r8lib.f90 | tee -a ${HOMEnwps}/sorc/psurge2nwps.cd/psurge_combine_build.log
mv -v r8lib.o ${HOMEnwps}/lib/r8lib.o

cd ${HOMEnwps}/sorc/psurge2nwps.cd/
rm -f psurge_combine.o pwl_interp_2d.o | tee -a ${HOMEnwps}/sorc/psurge2nwps.cd/psurge_combine_build.log
${FC} ${F90FLAGS} -c pwl_interp_2d.f90 | tee -a ${HOMEnwps}/sorc/psurge2nwps.cd/psurge_combine_build.log
${FC} ${F90FLAGS} -c psurge_combine.f90 | tee -a ${HOMEnwps}/sorc/psurge2nwps.cd/psurge_combine_build.log
${FC} ${F90FLAGS} -o psurge_combine.exe psurge_combine.o pwl_interp_2d.o ${HOMEnwps}/lib/r8lib.o | tee -a ${HOMEnwps}/sorc/psurge2nwps.cd/psurge_combine_build.log
mv -v psurge_combine.exe ${HOMEnwps}/exec/psurge2nwps_combine.exe
echo "Build complete" | tee -a ${HOMEnwps}/sorc/psurge2nwps.cd/psurge_combine_build.log

echo "Building psurge2nwps"  | tee ${HOMEnwps}/sorc/psurge2nwps.cd/psurge2nwps_build.log
cd ${HOMEnwps}/sorc/psurge2nwps.cd
make clean | tee -a ${HOMEnwps}/sorc/psurge2nwps.cd/psurge2nwps_build.log
make \
  FC="${FC}" \
  FFLAGS="${F77FLAGS}" \
  FCFLAGS="${F90FLAGS}" | tee -a ${HOMEnwps}/sorc/psurge2nwps.cd/psurge2nwps_build.log
mv -v psurge2nwps_64 ${HOMEnwps}/exec/psurge2nwps
echo "Build complete" | tee -a ${HOMEnwps}/sorc/psurge2nwps.cd/psurge2nwps_build.log

exit 0

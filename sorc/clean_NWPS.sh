#!/bin/bash
# -----------------------------------------------------------
# NWPS Master Clean Script
# Author: Ali Salimi-Tarazouj
#
# Cleans ALL NWPS build products, external libs, FIX caches,
# work directories, and generated executables.
#
# Usage:
#   cd sorc
#   ./clean_NWPS.sh
# -----------------------------------------------------------

set -euo pipefail
set -x

PWD=$(pwd)
HOMEnwps=${PWD%/*}

if [[ -z "${HOMEnwps}" || ! -d "${HOMEnwps}/sorc" ]]; then
  echo "ERROR: Unable to determine HOMEnwps"
  exit 1
fi

echo "============================================"
echo " NWPS FULL CLEAN"
echo " HOMEnwps = ${HOMEnwps}"
echo "============================================"

cd "${HOMEnwps}/sorc"

# -----------------------------------------------------------
# 1. Run make clean in known components (best effort)
# -----------------------------------------------------------
echo "== Cleaning component Makefiles =="

for d in \
  libaat \
  emapf-c \
  swan.fd \
  punswan4110.fd \
  estofs_padcirc.fd \
  degrib-2.15.cd \
  ripforecast.fd \
  runupforecast.fd \
  psurge2nwps.cd \
  nwps_utils.cd \
  ww3_sysprep.fd
do
  if [[ -f "${d}/Makefile" ]]; then
    echo "--> make clean in ${d}"
    ( cd "${d}" && make clean || true )
  fi
done

# -----------------------------------------------------------
# 2. Remove generic build artifacts everywhere
# -----------------------------------------------------------
echo "== Removing generic build artifacts =="

find . -name "*.o" -type f -delete
find . -name "*.a" -type f -delete
find . -name "config.log" -type f -delete
find . -name "config.status" -type f -delete

# -----------------------------------------------------------
# 3. Remove approved directories and files (FULL CLEAN)
# -----------------------------------------------------------
echo "== Removing approved external and runtime directories =="

# exec
rm -rf "${HOMEnwps}/exec"

# FIX (approved)
rm -rf "${HOMEnwps}/fix/bathy_db"
rm -f  "${HOMEnwps}/fix/pdef_ncep_global"

# lib (approved)
rm -rf "${HOMEnwps}/lib/cartopy"
rm -rf "${HOMEnwps}/lib/hdf5"
rm -rf "${HOMEnwps}/lib/netcdf"
rm -rf "${HOMEnwps}/lib/sorc/hdf5-1_8_9"
rm -rf "${HOMEnwps}/lib/sorc/netcdf-4.2"
rm -rf "${HOMEnwps}/lib/sorc/netcdf-fortran-4.2"
rm -f  "${HOMEnwps}/lib/libemapf.a"

# sorc-specific libs
rm -f  "${HOMEnwps}/sorc/emapf-c/libemapf.a"

# padcirc / estofs work dirs
rm -rf "${HOMEnwps}/sorc/estofs_padcirc.fd/work/adcprep"
rm -rf "${HOMEnwps}/sorc/estofs_padcirc.fd/work/odir1"
rm -rf "${HOMEnwps}/sorc/estofs_padcirc.fd/work/odir4"
rm -rf "${HOMEnwps}/sorc/estofs_padcirc.fd/work/odir_metis"
rm -rf "${HOMEnwps}/sorc/estofs_padcirc.fd/work/padcirc"
rm -f  "${HOMEnwps}/sorc/estofs_padcirc.fd/work/actualflags.txt"

# ush runtime artifacts (approved)
rm -f "${HOMEnwps}/ush/rtofs/datfiles/pdef_ncep_global.gz"
rm -f "${HOMEnwps}/ush/rtofs/datfiles/pdef_ncep_reg1.gz"
rm -f "${HOMEnwps}/ush/rtofs/datfiles/pdef_ncep_reg2.gz"
rm -f "${HOMEnwps}/ush/rtofs/datfiles/pdef_ncep_reg3.gz"

echo "============================================"
echo " NWPS FULL CLEAN COMPLETED SUCCESSFULLY"
echo "============================================"
exit 0


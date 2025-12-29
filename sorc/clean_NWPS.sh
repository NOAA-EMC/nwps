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
NWPSdir=${PWD%/*}

if [[ -z "${NWPSdir}" || ! -d "${NWPSdir}/sorc" ]]; then
  echo "ERROR: Unable to determine NWPSdir"
  exit 1
fi

echo "============================================"
echo " NWPS FULL CLEAN"
echo " NWPSdir = ${NWPSdir}"
echo "============================================"

cd "${NWPSdir}/sorc"

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
rm -rf "${NWPSdir}/exec"

# FIX (approved)
rm -rf "${NWPSdir}/fix/bathy_db"
rm -f  "${NWPSdir}/fix/pdef_ncep_global"

# lib (approved)
rm -rf "${NWPSdir}/lib/cartopy"
rm -rf "${NWPSdir}/lib/hdf5"
rm -rf "${NWPSdir}/lib/netcdf"
rm -rf "${NWPSdir}/lib/sorc/hdf5-1_8_9"
rm -rf "${NWPSdir}/lib/sorc/netcdf-4.2"
rm -rf "${NWPSdir}/lib/sorc/netcdf-fortran-4.2"
rm -f  "${NWPSdir}/lib/libemapf.a"

# sorc-specific libs
rm -f  "${NWPSdir}/sorc/emapf-c/libemapf.a"

# padcirc / estofs work dirs
rm -rf "${NWPSdir}/sorc/estofs_padcirc.fd/work/adcprep"
rm -rf "${NWPSdir}/sorc/estofs_padcirc.fd/work/odir1"
rm -rf "${NWPSdir}/sorc/estofs_padcirc.fd/work/odir4"
rm -rf "${NWPSdir}/sorc/estofs_padcirc.fd/work/odir_metis"
rm -rf "${NWPSdir}/sorc/estofs_padcirc.fd/work/padcirc"
rm -f  "${NWPSdir}/sorc/estofs_padcirc.fd/work/actualflags.txt"

# ush runtime artifacts (approved)
rm -f "${NWPSdir}/ush/rtofs/datfiles/pdef_ncep_global.gz"
rm -f "${NWPSdir}/ush/rtofs/datfiles/pdef_ncep_reg1.gz"
rm -f "${NWPSdir}/ush/rtofs/datfiles/pdef_ncep_reg2.gz"
rm -f "${NWPSdir}/ush/rtofs/datfiles/pdef_ncep_reg3.gz"

echo "============================================"
echo " NWPS FULL CLEAN COMPLETED SUCCESSFULLY"
echo "============================================"
exit 0


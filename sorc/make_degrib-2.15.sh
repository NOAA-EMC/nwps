#!/bin/bash
#
# ----------------------------------------------------------- 
# Original Author(s): Andre.VanderWesthuysen@noaa.gov
# File Creation Date: 07/28/2020
# Date Last Modified: 07/28/2020
#
# Version control: 1.00
#
# Support Team:
#
# Contributors: degrib 2.15 code received from Arthur Taylor (MDL)
# ----------------------------------------------------------- 
# ------------- Program Description and Details ------------- 
# ----------------------------------------------------------- 
# Script to call the build scripts for degrib v2.15, and its
# required libraries libemapf.a and libgd.a
# -----------------------------------------------------------
export pwd=`pwd`
export NWPSdir=${pwd%/*}
export srcDir=${NWPSdir}/sorc

# Load the build module
#module load ./degrib-2.15.cd/build_psurge.module
module list

# Clean all degrib object and archive files (including lib/libemapf.a and lib/libgd.a)
echo "Cleaning degrib object and archive files..." | tee ${srcDir}/degrib-2.15.cd/degrib_build.log
cd ${NWPSdir}/sorc/degrib-2.15.cd/
./build.sh degrib-2.15 clean | tee -a ${srcDir}/degrib-2.15.cd/degrib_build.log

# Build libemapf.a
echo "Building libemapf.a..." | tee -a ${srcDir}/degrib-2.15.cd/degrib_build.log
cd ${NWPSdir}/lib/sorc/emapf-c
make clean install | tee -a ${srcDir}/degrib-2.15.cd/degrib_build.log

# Build libgd.a
#echo "Building libgd.a..." | tee -a ${srcDir}/degrib-2.15.cd/degrib_build.log
#cd ${NWPSdir}/lib/sorc/gd
#make clean | tee -a ${srcDir}/degrib-2.15.cd/degrib_build.log
#make | tee -a ${srcDir}/degrib-2.15.cd/degrib_build.log
#mv libgd.a ../../ | tee -a ${srcDir}/degrib-2.15.cd/degrib_build.log

# Build and install degrib
echo "Building degrib..." | tee -a ${srcDir}/degrib-2.15.cd/degrib_build.log
cd ${NWPSdir}/sorc/degrib-2.15.cd/
./build.sh degrib-2.15 | tee -a ${srcDir}/degrib-2.15.cd/degrib_build.log

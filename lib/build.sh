#!/bin/bash
#==============================================================================
# build.sh                                              Last Change: 2020-07-27
#                                                        Arthur.Taylor@noaa.gov
#                                                              NWS/OSTI/MDL/DSD
#------------------------------------------------------------------------------
if [[ $# -ne 1 ]] || [[ $1 == "help" ]] ; then
   echo -e "Build script for P-Surge executables.\n"
   echo "Usage:"
   echo "  build.sh help           - Display this message and quit"
   echo "  build.sh all            - Build/install all libraries in ./sorc/*"
   echo "  build.sh clean          - Clean all libraries"
   exit
fi
if [[ "${SYSTEM:-CRAY}" == "DELL" ]] ; then
   echo "Can't run on the dell."
   exit
fi

#=======================================
# Function to build a directory.
#---------------------------------------
function build_dir {
   echo "=============================="
   echo "Building $1"
   echo "------------------------------"
   cd $srcDir/sorc/$1
   make
   if [[ $? -eq 0 ]]; then
      make install
   else
      echo "ERROR: build of $1 FAILED!"
   fi
   echo "------------------------------"
   echo ""
}

#================================================================== START =====
srcDir=$(cd "$(dirname "$0")" && pwd)

#=======================================
# Load the build module
#---------------------------------------
#module load ../sorc/degrib-2.15.cd/build_psurge.module    # Loaded in sorc/make_degrib-2.15.sh
#module list
#echo "------------------------------"
#echo ""

#=======================================
# Perform all or clean activities
#---------------------------------------
libList="emapf-c"
libList+=" gd"
if [[ $1 == "all" ]] ; then
   for lib in $libList ; do
      build_dir $lib
   done
   exit
elif [[ $1 == "clean" ]] ; then
   for lib in $libList ; do
      cd $srcDir/sorc/$lib
      make clean
   done
   exit
fi

#!/bin/bash
#==============================================================================
# build.sh                                              Last Change: 2020-07-27
#                                                        Arthur.Taylor@noaa.gov
#                                                              NWS/OSTI/MDL/DSD
# Modified by Andre.VanderWesthuysen@noaa.gov for use with NWPS v1.3
# Last Change: 2020-07-29
#------------------------------------------------------------------------------
if [[ $# -lt 1 ]] || [[ $1 == "help" ]] ; then
   echo -e "Build script for P-Surge executables.\n"
   echo "Usage:"
   echo "  build.sh help           - Display this message and quit"
   echo "  build.sh all            - Build/install all exec in each .cd subdir"
   echo "  build.sh clean          - Clean all .cd sub-directory"
   echo "  build.sh all clean      - Clean all .cd sub-directory"
   echo "  build.sh <dir w/o .cd> clean  - Clean <dir>.cd sub-directory"
   echo "  build.sh <dir1 w/o .cd> <dir2> .. <dirN>  - Build list of programs"
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
   echo "Check library depends..."
   echo "------------------------------"
   LIBDIR=$srcDir/../lib
   if [[ $1 == "psurge_envmerge.cd" || $1 == "drawshp.cd" || \
         $1 == "degrib-2.15.cd" ]] ; then
      LIB=$LIBDIR/libemapf.a
      if [ ! -e $LIB ] ; then
         echo "$1 requires $LIB to exist."
         echo "Please build it via:"
         echo "   $ cd $LIBDIR/sorc/emapf-c"
         echo "   $ make clean install"
         echo "   $ cd $srcDir"
         exit
      fi
   fi
   if [[ $1 == "drawshp.cd" || $1 == "degrib-2.15.cd" ]] ; then
      LIB=$LIBDIR/libgd.a
      if [ ! -e $LIB ] ; then
         echo "$1 requires $LIB to exist."
         echo "Please build it via:"
         echo "   $ cd $LIBDIR/sorc/gd"
         echo "   $ make clean ; make ; cp libgd.a ../../"
         echo "   $ cd $srcDir"
         exit
      fi
   fi
   echo ""
   echo "=============================="
   echo "Building $1"
   echo "------------------------------"
   cd $srcDir/$1
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
#srcDir=$(cd "$(dirname "$0")" && pwd)   # Set in sorc/make_degrib-2.15.sh

#=======================================
# Load the build module
#---------------------------------------
#module load ./build_psurge.module   # Loaded in sorc/make_degrib-2.15.sh
#module list
#echo "------------------------------"
#echo ""

#=======================================
# Perform all or clean activities
#---------------------------------------
if [[ $# -eq 1 ]] ; then
   if [[ $1 == "all" ]] ; then
      for dir in *.cd *.fd ; do
         build_dir $dir
      done
      exit
   elif [[ $1 == "clean" ]] ; then
      for dir in *.cd *.fd ; do
         cd $srcDir/$dir
         make clean
      done
      exit
   fi
elif [[ $# -eq 2 ]] ; then
   if [[ $2 == "clean" ]] ; then
      if [[ $1 == "all" ]] ; then
         for dir in *.cd *.fd; do
            cd $srcDir/$dir
            make clean
         done
      else
         if [[ -d $srcDir/$1.cd ]] ; then
            cd $srcDir/$1.cd
            make clean
         elif [[ -d $srcDir/$1.fd ]] ; then
            cd $srcDir/$1.fd
            make clean
         else
            echo "Couldn't find $srcDir/$1.cd or $srcDir/$1.fd"
            exit
         fi
      fi
      exit
   fi
fi

#=======================================
# Build a list of directories
#---------------------------------------
for dir in $*; do
   if [[ -d $srcDir/$dir.cd ]] ; then
      build_dir $dir.cd
   elif [[ -d $srcDir/$1.fd ]] ; then
      build_dir $dir.fd
   else
      echo "Couldn't find $srcDir/$1.cd or $srcDir/$1.fd"
      exit
   fi
done

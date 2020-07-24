#!/bin/sh
###############################################################################
#                                                                             #
# Compiles all codes, moves executables to exec and cleans up                 #
#                                                                             #
#                                                                 Feb, 2016   #
#                                                                             #
###############################################################################
#
# --------------------------------------------------------------------------- #
#Load estofs module

set -x

#module purge
#module load ncep
#module load ../modulefiles/NWPS/v1.3.0
#module list

# Loading Intel Compiler Suite
module load PrgEnv-intel/5.2.56
module load craype-haswell

# Loading ncep prod modules
module load HDF5-serial-intel-haswell/1.8.9
module load NetCDF-intel-haswell/4.2
module load jasper-gnu-haswell/1.900.1
module load png-intel-haswell/1.2.49
module load zlib-intel-haswell/1.2.7
module load nco-gnu-haswell/4.4.4 

# Loading ncep libs 
module load bacio-intel/2.0.1
module load bufr-intel/11.0.2
module load g2-intel/2.5.0
module load w3emc-intel/2.2.0
module load w3nco-intel/2.0.6
module load iobuf/2.0.5

# 1. Preparations: seek source codes to be compiled
export COMP=ftn
export COMP_MPI=ftn
export C_COMP=cc
export C_COMP_MP=cc

  fcodes=`ls -d estofs_padcirc.fd | sed 's/\.fd//g'`
  echo " FORTRAN codes found: "$fcodes
  outfile=`pwd`/estofs_padcirc.fd/padcirc_build.log
  rm -f $outfile

# 2. Create all execution

  if [ $# -eq 0 ];then
     for code in $fcodes; do 
       if [ ${code} == "estofs_padcirc" ]; then
          echo " Making $code " >> $outfile
          cd ${code}.?d/work
          make adcprep padcirc SWAN=enable >> $outfile
          if [ -s padcirc ]; then
             for exename in adcprep padcirc; do
                echo " Copy $exename to estofs_${exename} at exec " >> $outfile
                cp -f $exename ../../../exec/estofs_${exename}
             done
          fi
          make clean
          echo ' ' >> $outfile
          cd ../..
       else  
          echo " Making $code " >> $outfile
          cd ${code}.?d
          make >> $outfile
          echo " Moving $code to exec " >> $outfile
          make clean
          echo ' ' >> $outfile
          cd ..
       fi
     done
  elif [ $1 == "estofs_padcirc" ]; then
          echo " Making $1 " >> $outfile
          cd $1.?d/work
          make all >> $outfile
          if [ -s padcirc ]; then
             for exename in adcprep padcirc; do
                echo " Copy $exename to estofs_${exename} at exec " >> $outfile
                cp -f $exename ../../../exec/estofs_${exename}
             done
          fi
          make clean
          echo ' ' >> $outfile
          cd ../..
       else
          echo " Making $1 " >> $outfile
          cd $1.?d
          make >> $outfile
          echo " Moving $1 to exec " >> $outfile
          make clean
          echo ' ' >> $outfile
          cd ..
    fi

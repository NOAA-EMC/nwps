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
module list

# 1. Preparations: seek source codes to be compiled
source $NWPSdir/env/detect_machine.sh
if [[ $MACHINE_ID = hera* ]] ; then
export COMP=ifort
export COMP_MPI=ifort
export C_COMP=icc
export C_COMP_MP=icc

elif [[ $MACHINE_ID = wcoss2 ]]; then

export COMP=ftn
export COMP_MPI=ftn
export C_COMP=cc
export C_COMP_MP=cc

else 
 echo WARNING: UNKNOWN PLATFORM 1>&2
fi

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
          #AW: Dont clean. punswan needs these files: make clean
          echo ' ' >> $outfile
          cd ../..
       else  
          echo " Making $code " >> $outfile
          cd ${code}.?d
          make >> $outfile
          echo " Moving $code to exec " >> $outfile
          #AW: Dont clean. punswan needs these files: make clean
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
          #AW: Dont clean. punswan needs these files: clean
          echo ' ' >> $outfile
          cd ../..
       else
          echo " Making $1 " >> $outfile
          cd $1.?d
          make >> $outfile
          echo " Moving $1 to exec " >> $outfile
          #AW: Dont clean. punswan needs these files: clean
          echo ' ' >> $outfile
          cd ..
    fi

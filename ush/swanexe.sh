#!/bin/bash
set -xa
# ----------------------------------------------------------- 
# UNIX Shell Script File
# Tested Operating System(s): RHEL 5,6
# Tested Run Level(s): 3, 5
# Shell Used: BASH shell
# Original Author(s): Douglas.Gaer@noaa.gov
# File Creation Date: 01/25/2011
# Date Last Modified: 07/09/2013
#
# Version control: 1.12
#
# Support Team:
#
# Contributors:
# ----------------------------------------------------------- 
# ------------- Program Description and Details ------------- 
# ----------------------------------------------------------- 
#
# Script used to auto detect the hardware platform and select 
# the correct SWAN binary. 
#
# ----------------------------------------------------------- 
echo "in swanexe.sh"
set -x
env

CGNUM=$1

# Setup our NWPS environment                                                    
if [ "${USHnwps}" == "" ]
    then 
    echo "FATAL ERROR: Your USHnwps variable is not set"
    export err=1; err_chk
fi

# Check to see if our NWPS env is set
if [ "${NWPSenvset}" == "" ]
then 
    if [ -e ${USHnwps}/nwps_config.sh ];then
	    source ${USHnwps}/nwps_config.sh
    else
	    "FATAL ERROR: Cannot find ${USHnwps}/nwps_config.sh"
	    export err=1; err_chk
    fi
fi

cd ${RUNdir}

if [ "${ARCH}" == "" ] || [ "${ARCHBITS}" == "" ] || [ "${NUMCPUS}" == "" ] || [ "${MPIEXEC}" == "" ]
then
    source ${USHnwps}/set_os_env.sh
fi

if [ "${MODELCORE}" == "SWAN" ]
then
   echo "Starting SWAN executable for "${siteid}
   if [ "${siteid}" == "gyx" ] || [ "${siteid}" == "mfr" ] || [ "${siteid}" == "ajk" ]
   then
      aprun -n48 -N24 -j1 -d1 ${EXECnwps}/swan-mpi.exe
      export err=$?;
      echo "Exit Code: ${err}" | tee -a ${LOGdir}/swan_exe_error.log
   elif [ "${siteid}" == "hgx" ] || [ "${siteid}" == "mob" ] || [ "${siteid}" == "tae" ] || [ "${siteid}" == "jax" ] || [ "${siteid}" == "key" ] || [ "${siteid}" == "phi" ] || [ "${siteid}" == "mtr" ] || [ "${siteid}" == "alu" ] || [ "${siteid}" == "aer" ] || [ "${siteid}" == "afg" ]
   then
      aprun -n24 -N24 -j1 -d1 ${EXECnwps}/swan-mpi.exe
      export err=$?;
      echo "Exit Code: ${err}" | tee -a ${LOGdir}/swan_exe_error.log
   else
      aprun -n16 -N16 -j1 -d1 ${EXECnwps}/swan-mpi.exe
      export err=$?;
      echo "Exit Code: ${err}" | tee -a ${LOGdir}/swan_exe_error.log
   fi
   cp -f *CG1* ${DATA}/output/grid
   if [ "${err}" != "0" ];then
      msg="FATAL ERROR: Wave model executable swan-mpi.exe failed."
      postmsg "$jlogfile" "$msg"
   fi
   err_chk
elif [ "${MODELCORE}" == "UNSWAN" ]
then
   echo "Processing UNSWAN for "${siteid}" on CG"${CGNUM}
   if [ "${CGNUM}" == "1" ]
   then
      echo "Starting PuNSWAN executable for "${siteid}" on CG"${CGNUM}

      # Ensure grid has been configured for the Unstructured version of swan.
      if [ ! -e ${RUNdir}/PE0000 ]
      then
           msg="ERROR - missing PE0000 directory for UNSTRUCTURED run. Reconfigure bathy_db for Unstr SWAN."
           postmsg "$jlogfile" "$msg"
           exit 1
      fi

      # Run each domain with appropriate number of cores.
      if [ "${siteid}" == "car" ] || [ "${siteid}" == "mfl" ] || [ "${siteid}" == "tbw" ] || [ "${siteid}" == "box" ] || [ "${siteid}" == "sgx" ] || [ "${siteid}" == "sju" ] || [ "${siteid}" == "akq" ] || [ "${siteid}" == "okx" ]
      then
         echo "Copying required files for PuNSWAN run for "${siteid}
         for i in {0..9}; do
            cp ${RUNdir}/INPUT ${RUNdir}/PE000${i}/
         done
         for i in {10..47}; do
            cp ${RUNdir}/INPUT ${RUNdir}/PE00${i}/
         done

         echo "Starting PuNSWAN executable for "${siteid}
         aprun -n48 -N24 -j1 -d1 ${EXECnwps}/punswan4110-mpi.exe
         export err=$?;
         echo "Exit Code: ${err}" | tee -a ${LOGdir}/swan_exe_error.log
         cp ${RUNdir}/PE0000/PRINT ${RUNdir}/
         cp -f *CG1* ${DATA}/output/grid
         if [ "${err}" != "0" ];then
            msg="FATAL ERROR: Wave model executable punswan4110-mpi.exe failed."
            postmsg "$jlogfile" "$msg"
         fi
         err_chk
      elif [ "${siteid}" == "mhx" ]
      then
         echo "Copying required files for PuNSWAN run for "${siteid}
         for i in {0..9}; do
            cp ${RUNdir}/INPUT ${RUNdir}/PE000${i}/
         done
         for i in {10..23}; do
            cp ${RUNdir}/INPUT ${RUNdir}/PE00${i}/
         done

         echo "Starting PuNSWAN executable for "${siteid}
         aprun -n24 -N24 -j1 -d1 ${EXECnwps}/punswan4110-mpi.exe
         export err=$?;
         echo "Exit Code: ${err}" | tee -a ${LOGdir}/swan_exe_error.log
         cp ${RUNdir}/PE0000/PRINT ${RUNdir}/
         cp -f *CG1* ${DATA}/output/grid
         if [ "${err}" != "0" ];then
            msg="FATAL ERROR: Wave model executable punswan4110-mpi.exe failed."
            postmsg "$jlogfile" "$msg"
         fi
         err_chk
      elif [ "${siteid}" == "hfo" ]
      then
         echo "Copying required files for PuNSWAN run for "${siteid}
         for i in {0..9}; do
            cp ${RUNdir}/INPUT ${RUNdir}/PE000${i}/
         done
         for i in {10..15}; do
            cp ${RUNdir}/INPUT ${RUNdir}/PE00${i}/
         done

         echo "Starting PuNSWAN executable for "${siteid}
         aprun -n16 -N16 -j1 -d1 ${EXECnwps}/punswan4110-mpi.exe
         export err=$?;
         echo "Exit Code: ${err}" | tee -a ${LOGdir}/swan_exe_error.log
         cp ${RUNdir}/PE0000/PRINT ${RUNdir}/
         cp -f *CG1* ${DATA}/output/grid
         if [ "${err}" != "0" ];then
            msg="FATAL ERROR: Wave model executable punswan4110-mpi.exe failed."
            postmsg "$jlogfile" "$msg"
         fi
         err_chk
      fi
   fi

   # Interpolate unstructured mesh results onto regular grid for AWIPS (parameter names from SWAN manual)
   echo "Interpolating unstructured mesh results for "${siteid}" on CG"${CGNUM}
   cp ${DATA}/install/swn_reginterpCG${CGNUM}.py ${RUNdir}/

   cat /dev/null > ${RUNdir}/reginterpCG${CGNUM}_cmdfile
   echo "${PYTHON} ${RUNdir}/swn_reginterpCG${CGNUM}.py ${RUNdir}/ CG_UNSTRUC.nc CG${CGNUM} HSIG" >> ${RUNdir}/reginterpCG${CGNUM}_cmdfile
   echo "${PYTHON} ${RUNdir}/swn_reginterpCG${CGNUM}.py ${RUNdir}/ CG_UNSTRUC.nc CG${CGNUM} WIND" >> ${RUNdir}/reginterpCG${CGNUM}_cmdfile
   echo "${PYTHON} ${RUNdir}/swn_reginterpCG${CGNUM}.py ${RUNdir}/ CG_UNSTRUC.nc CG${CGNUM} TPS" >> ${RUNdir}/reginterpCG${CGNUM}_cmdfile
   echo "${PYTHON} ${RUNdir}/swn_reginterpCG${CGNUM}.py ${RUNdir}/ CG_UNSTRUC.nc CG${CGNUM} DIR" >> ${RUNdir}/reginterpCG${CGNUM}_cmdfile
   echo "${PYTHON} ${RUNdir}/swn_reginterpCG${CGNUM}.py ${RUNdir}/ CG_UNSTRUC.nc CG${CGNUM} PDIR" >> ${RUNdir}/reginterpCG${CGNUM}_cmdfile
   echo "${PYTHON} ${RUNdir}/swn_reginterpCG${CGNUM}.py ${RUNdir}/ CG_UNSTRUC.nc CG${CGNUM} VEL" >> ${RUNdir}/reginterpCG${CGNUM}_cmdfile
   echo "${PYTHON} ${RUNdir}/swn_reginterpCG${CGNUM}.py ${RUNdir}/ CG_UNSTRUC.nc CG${CGNUM} WATL" >> ${RUNdir}/reginterpCG${CGNUM}_cmdfile
   echo "${PYTHON} ${RUNdir}/swn_reginterpCG${CGNUM}.py ${RUNdir}/ CG_UNSTRUC.nc CG${CGNUM} HSWE" >> ${RUNdir}/reginterpCG${CGNUM}_cmdfile
   echo "${PYTHON} ${RUNdir}/swn_reginterpCG${CGNUM}.py ${RUNdir}/ CG_UNSTRUC.nc CG${CGNUM} WLEN" >> ${RUNdir}/reginterpCG${CGNUM}_cmdfile
   echo "${PYTHON} ${RUNdir}/swn_reginterpCG${CGNUM}.py ${RUNdir}/ CG_UNSTRUC.nc CG${CGNUM} DEPTH" >> ${RUNdir}/reginterpCG${CGNUM}_cmdfile

   aprun -n10 -N10 -j1 -d1 cfp ${RUNdir}/reginterpCG${CGNUM}_cmdfile
   export err=$?; err_chk
fi

exit 0
# -----------------------------------------------------------
# *******************************
# ********* End of File *********
# *******************************

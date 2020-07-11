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

# Set ship transect output to 3 HR
#sed -i '/SHIPRT/ s/1.0 HR/3.0 HR/' INPUT

if [ "${MODELCORE}" == "SWAN" ]
then
   echo "Starting SWAN executable for "${siteid}
   if [ "${siteid}" == "gyx" ] || [ "${siteid}" == "mfr" ] || [ "${siteid}" == "ajk" ] || [ "${siteid}" == "mtr" ]
   then
      aprun -n48 -N24 -j1 -d1 ${EXECnwps}/swan-mpi.exe
      export err=$?;
      echo "Exit Code: ${err}" | tee -a ${LOGdir}/swan_exe_error.log
   elif [ "${siteid}" == "hgx" ] || [ "${siteid}" == "mob" ] || [ "${siteid}" == "tae" ] || [ "${siteid}" == "jax" ] || [ "${siteid}" == "key" ] || [ "${siteid}" == "phi" ] || [ "${siteid}" == "aer" ] || [ "${siteid}" == "afg" ] || [ "${siteid}" == "lch" ]
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

      # Get run cycle to check for the presence of hotfiles     
      hh=`ls *.wnd | cut -c9-10`

      # Run each domain with appropriate number of cores.
      if [ "${siteid}" == "key" ] || [ "${siteid}" == "mfl" ] || [ "${siteid}" == "akq" ]
      then
         echo "Copying required files for PuNSWAN run for "${siteid}

         # Check that all hotfiles are present in the PE subfolders
         for i in {0..9}; do
            echo "Checking hotfile for PE000"${i}"/"${PDY}.${hh}"00"
            # Note: Checking also for PDYm1 to allow running of a late cycle from previous day           
            if [ -f ${RUNdir}/PE000${i}/${PDY}.${hh}00 ] || [ -f ${RUNdir}/PE000${i}/${PDYm1}.${hh}00 ]; then
               echo "Found PE000"${i}"/"${PDY}.${hh}"00"
            else
               echo "Warning: Not found PE000"${i}"/"${PDY}.${hh}"00"
               msg="WARNING - missing hotfile in PE000"${i}" directory for UNSTRUCTURED run. Will execute a cold start run."
               postmsg "$jlogfile" "$msg"
               sed -i '/INITial HOTStart/c\INIT DEFault' INPUT
            fi
         done
         for i in {10..95}; do
            echo "Checking hotfile for PE00"${i}"/"${PDY}.${hh}"00"           
            if [ -f ${RUNdir}/PE00${i}/${PDY}.${hh}00 ] || [ -f ${RUNdir}/PE00${i}/${PDYm1}.${hh}00 ]; then
               echo "Found PE00"${i}"/"${PDY}.${hh}"00"
            else
               echo "Warning: Not found PE00"${i}"/"${PDY}.${hh}"00"
               msg="WARNING - missing hotfile in PE00"${i}" directory for UNSTRUCTURED run. Will execute a cold start run."
               postmsg "$jlogfile" "$msg"
               sed -i '/INITial HOTStart/c\INIT DEFault' INPUT
            fi
         done

         for i in {0..9}; do        
            cp ${RUNdir}/INPUT ${RUNdir}/PE000${i}/
         done
         for i in {10..95}; do
            cp ${RUNdir}/INPUT ${RUNdir}/PE00${i}/
         done

         echo "Starting PuNSWAN executable for "${siteid}
         aprun -n96 -N24 -j1 -d1 ${EXECnwps}/punswan4110.exe
         export err=$?;
         echo "Exit Code: ${err}" | tee -a ${LOGdir}/swan_exe_error.log
         cp ${RUNdir}/PE0000/PRINT ${RUNdir}/
         cp -f *CG1* ${DATA}/output/grid
         if [ "${err}" != "0" ];then
            msg="FATAL ERROR: Wave model executable punswan4110.exe failed."
            postmsg "$jlogfile" "$msg"
         fi
         err_chk
      #######
      elif [ "${siteid}" == "alu" ]
      then
         echo "Copying required files for PuNSWAN run for "${siteid}

         # Check that all hotfiles are present in the PE subfolders
         for i in {0..9}; do
            echo "Checking hotfile for PE000"${i}"/"${PDY}.${hh}"00"
            # Note: Checking also for PDYm1 to allow running of a late cycle from previous day           
            if [ -f ${RUNdir}/PE000${i}/${PDY}.${hh}00 ] || [ -f ${RUNdir}/PE000${i}/${PDYm1}.${hh}00 ]; then
               echo "Found PE000"${i}"/"${PDY}.${hh}"00"
            else
               echo "Warning: Not found PE000"${i}"/"${PDY}.${hh}"00"
               msg="WARNING - missing hotfile in PE000"${i}" directory for UNSTRUCTURED run. Will execute a cold start run."
               postmsg "$jlogfile" "$msg"
               sed -i '/INITial HOTStart/c\INIT DEFault' INPUT
            fi
         done
         for i in {10..83}; do
            echo "Checking hotfile for PE00"${i}"/"${PDY}.${hh}"00"           
            if [ -f ${RUNdir}/PE00${i}/${PDY}.${hh}00 ] || [ -f ${RUNdir}/PE00${i}/${PDYm1}.${hh}00 ]; then
               echo "Found PE00"${i}"/"${PDY}.${hh}"00"
            else
               echo "Warning: Not found PE00"${i}"/"${PDY}.${hh}"00"
               msg="WARNING - missing hotfile in PE00"${i}" directory for UNSTRUCTURED run. Will execute a cold start run."
               postmsg "$jlogfile" "$msg"
               sed -i '/INITial HOTStart/c\INIT DEFault' INPUT
            fi
         done

         for i in {0..9}; do        
            cp ${RUNdir}/INPUT ${RUNdir}/PE000${i}/
         done
         for i in {10..83}; do
            cp ${RUNdir}/INPUT ${RUNdir}/PE00${i}/
         done

         echo "Starting PuNSWAN executable for "${siteid}
         aprun -n84 -N24 -j1 -d1 ${EXECnwps}/punswan4110.exe
         export err=$?;
         echo "Exit Code: ${err}" | tee -a ${LOGdir}/swan_exe_error.log
         cp ${RUNdir}/PE0000/PRINT ${RUNdir}/
         cp -f *CG1* ${DATA}/output/grid
         if [ "${err}" != "0" ];then
            msg="FATAL ERROR: Wave model executable punswan4110.exe failed."
            postmsg "$jlogfile" "$msg"
         fi
         err_chk
      #######
      elif [ "${siteid}" == "car" ] || [ "${siteid}" == "tbw" ] \
         || [ "${siteid}" == "box" ] || [ "${siteid}" == "sgx" ] || [ "${siteid}" == "sju" ] \
         || [ "${siteid}" == "akq" ] || [ "${siteid}" == "okx" ] || [ "${siteid}" == "gum" ] \
         || [ "${siteid}" == "alu" ] || [ "${siteid}" == "gua" ] || [ "${siteid}" == "mlb" ] \
         || [ "${siteid}" == "jax" ] || [ "${siteid}" == "chs" ] || [ "${siteid}" == "ilm" ] \
         || [ "${siteid}" == "phi" ] || [ "${siteid}" == "gyx" ] || [ "${siteid}" == "tae" ] \
         || [ "${siteid}" == "mob" ] || [ "${siteid}" == "hgx" ]
      then
         echo "Copying required files for PuNSWAN run for "${siteid}

         # Check that all hotfiles are present in the PE subfolders
         for i in {0..9}; do
            echo "Checking hotfile for PE000"${i}"/"${PDY}.${hh}"00"
            # Note: Checking also for PDYm1 to allow running of a late cycle from previous day         
            if [ -f ${RUNdir}/PE000${i}/${PDY}.${hh}00 ] || [ -f ${RUNdir}/PE000${i}/${PDYm1}.${hh}00 ]; then
               echo "Found PE000"${i}"/"${PDY}.${hh}"00"
            else
               echo "Warning: Not found PE000"${i}"/"${PDY}.${hh}"00"
               msg="WARNING - missing hotfile in PE000"${i}" directory for UNSTRUCTURED run. Will execute a cold start run."
               postmsg "$jlogfile" "$msg"
               sed -i '/INITial HOTStart/c\INIT DEFault' INPUT
            fi
         done
         for i in {10..47}; do
            echo "Checking hotfile for PE00"${i}"/"${PDY}.${hh}"00"           
            if [ -f ${RUNdir}/PE00${i}/${PDY}.${hh}00 ] || [ -f ${RUNdir}/PE00${i}/${PDYm1}.${hh}00 ]; then
               echo "Found PE00"${i}"/"${PDY}.${hh}"00"
            else
               echo "Warning: Not found PE00"${i}"/"${PDY}.${hh}"00"
               msg="WARNING - missing hotfile in PE00"${i}" directory for UNSTRUCTURED run. Will execute a cold start run."
               postmsg "$jlogfile" "$msg"
               sed -i '/INITial HOTStart/c\INIT DEFault' INPUT
            fi
         done

         for i in {0..9}; do        
            cp ${RUNdir}/INPUT ${RUNdir}/PE000${i}/
         done
         for i in {10..47}; do
            cp ${RUNdir}/INPUT ${RUNdir}/PE00${i}/
         done

         echo "Starting PuNSWAN executable for "${siteid}
         aprun -n48 -N24 -j1 -d1 ${EXECnwps}/punswan4110.exe
         export err=$?;
         echo "Exit Code: ${err}" | tee -a ${LOGdir}/swan_exe_error.log
         cp ${RUNdir}/PE0000/PRINT ${RUNdir}/
         cp -f *CG1* ${DATA}/output/grid
         if [ "${err}" != "0" ];then
            msg="FATAL ERROR: Wave model executable punswan4110.exe failed."
            postmsg "$jlogfile" "$msg"
         fi
         err_chk
      elif [ "${siteid}" == "mhx" ]
      then
         echo "Copying required files for PuNSWAN run for "${siteid}

         # Check that all hotfiles are present in the PE subfolders
         for i in {0..9}; do
            echo "Checking hotfile for PE000"${i}"/"${PDY}.${hh}"00"
            # Note: Checking also for PDYm1 to allow running of a late cycle from previous day           
            if [ -f ${RUNdir}/PE000${i}/${PDY}.${hh}00 ] || [ -f ${RUNdir}/PE000${i}/${PDYm1}.${hh}00 ]; then
               echo "Found PE000"${i}"/"${PDY}.${hh}"00"
            else
               echo "Warning: Not found PE000"${i}"/"${PDY}.${hh}"00"
               msg="WARNING - missing hotfile in PE000"${i}" directory for UNSTRUCTURED run. Will execute a cold start run."
               postmsg "$jlogfile" "$msg"
               sed -i '/INITial HOTStart/c\INIT DEFault' INPUT
            fi
         done
         for i in {10..23}; do
            echo "Checking hotfile for PE00"${i}"/"${PDY}.${hh}"00"           
            if [ -f ${RUNdir}/PE00${i}/${PDY}.${hh}00 ] || [ -f ${RUNdir}/PE00${i}/${PDYm1}.${hh}00 ]; then
               echo "Found PE00"${i}"/"${PDY}.${hh}"00"
            else
               echo "Warning: Not found PE00"${i}"/"${PDY}.${hh}"00"
               msg="WARNING - missing hotfile in PE00"${i}" directory for UNSTRUCTURED run. Will execute a cold start run."
               postmsg "$jlogfile" "$msg"
               sed -i '/INITial HOTStart/c\INIT DEFault' INPUT
            fi
         done

         for i in {0..9}; do
            cp ${RUNdir}/INPUT ${RUNdir}/PE000${i}/
         done
         for i in {10..23}; do
            cp ${RUNdir}/INPUT ${RUNdir}/PE00${i}/
         done

         echo "Starting PuNSWAN executable for "${siteid}
         aprun -n24 -N24 -j1 -d1 ${EXECnwps}/punswan4110.exe
         export err=$?;
         echo "Exit Code: ${err}" | tee -a ${LOGdir}/swan_exe_error.log
         cp ${RUNdir}/PE0000/PRINT ${RUNdir}/
         cp -f *CG1* ${DATA}/output/grid
         if [ "${err}" != "0" ];then
            msg="FATAL ERROR: Wave model executable punswan4110.exe failed."
            postmsg "$jlogfile" "$msg"
         fi
         err_chk
      elif [ "${siteid}" == "hfo" ]
      then
         echo "Copying required files for PuNSWAN run for "${siteid}

         # Check that all hotfiles are present in the PE subfolders
         for i in {0..9}; do
            echo "Checking hotfile for PE000"${i}"/"${PDY}.${hh}"00"
            # Note: Checking also for PDYm1 to allow running of a late cycle from previous day           
            if [ -f ${RUNdir}/PE000${i}/${PDY}.${hh}00 ] || [ -f ${RUNdir}/PE000${i}/${PDYm1}.${hh}00 ]; then
               echo "Found PE000"${i}"/"${PDY}.${hh}"00"
            else
               echo "Warning: Not found PE000"${i}"/"${PDY}.${hh}"00"
               msg="WARNING - missing hotfile in PE000"${i}" directory for UNSTRUCTURED run. Will execute a cold start run."
               postmsg "$jlogfile" "$msg"
               sed -i '/INITial HOTStart/c\INIT DEFault' INPUT
            fi
         done
         for i in {10..15}; do
            echo "Checking hotfile for PE00"${i}"/"${PDY}.${hh}"00"           
            if [ -f ${RUNdir}/PE00${i}/${PDY}.${hh}00 ] || [ -f ${RUNdir}/PE00${i}/${PDYm1}.${hh}00 ]; then
               echo "Found PE00"${i}"/"${PDY}.${hh}"00"
            else
               echo "Warning: Not found PE00"${i}"/"${PDY}.${hh}"00"
               msg="WARNING - missing hotfile in PE00"${i}" directory for UNSTRUCTURED run. Will execute a cold start run."
               postmsg "$jlogfile" "$msg"
               sed -i '/INITial HOTStart/c\INIT DEFault' INPUT
            fi
         done

         for i in {0..9}; do
            cp ${RUNdir}/INPUT ${RUNdir}/PE000${i}/
         done
         for i in {10..15}; do
            cp ${RUNdir}/INPUT ${RUNdir}/PE00${i}/
         done

         echo "Starting PuNSWAN executable for "${siteid}
         aprun -n16 -N16 -j1 -d1 ${EXECnwps}/punswan4110.exe
         export err=$?;
         echo "Exit Code: ${err}" | tee -a ${LOGdir}/swan_exe_error.log
         cp ${RUNdir}/PE0000/PRINT ${RUNdir}/
         cp -f *CG1* ${DATA}/output/grid
         if [ "${err}" != "0" ];then
            msg="FATAL ERROR: Wave model executable punswan4110.exe failed."
            postmsg "$jlogfile" "$msg"
         fi
         err_chk
      fi
   fi

   # Interpolate unstructured mesh results onto regular grid for AWIPS (parameter names from SWAN manual)
   echo "Interpolating unstructured mesh results for "${siteid}" on CG"${CGNUM}
   cp ${DATA}/install/swn_reginterpCG${CGNUM}.py ${RUNdir}/

   cat /dev/null > ${RUNdir}/reginterpCG${CGNUM}_cmdfile
   echo "${PYTHON} ${RUNdir}/swn_reginterpCG${CGNUM}.py ${RUNdir}/ CG_UNSTRUC.nc CG${CGNUM} HSIG ${siteid}" >> ${RUNdir}/reginterpCG${CGNUM}_cmdfile
   echo "${PYTHON} ${RUNdir}/swn_reginterpCG${CGNUM}.py ${RUNdir}/ CG_UNSTRUC.nc CG${CGNUM} WIND ${siteid}" >> ${RUNdir}/reginterpCG${CGNUM}_cmdfile
   echo "${PYTHON} ${RUNdir}/swn_reginterpCG${CGNUM}.py ${RUNdir}/ CG_UNSTRUC.nc CG${CGNUM} TPS ${siteid}" >> ${RUNdir}/reginterpCG${CGNUM}_cmdfile
   echo "${PYTHON} ${RUNdir}/swn_reginterpCG${CGNUM}.py ${RUNdir}/ CG_UNSTRUC.nc CG${CGNUM} DIR ${siteid}" >> ${RUNdir}/reginterpCG${CGNUM}_cmdfile
   echo "${PYTHON} ${RUNdir}/swn_reginterpCG${CGNUM}.py ${RUNdir}/ CG_UNSTRUC.nc CG${CGNUM} PDIR ${siteid}" >> ${RUNdir}/reginterpCG${CGNUM}_cmdfile
   echo "${PYTHON} ${RUNdir}/swn_reginterpCG${CGNUM}.py ${RUNdir}/ CG_UNSTRUC.nc CG${CGNUM} VEL ${siteid}" >> ${RUNdir}/reginterpCG${CGNUM}_cmdfile
   echo "${PYTHON} ${RUNdir}/swn_reginterpCG${CGNUM}.py ${RUNdir}/ CG_UNSTRUC.nc CG${CGNUM} WATL ${siteid}" >> ${RUNdir}/reginterpCG${CGNUM}_cmdfile
   echo "${PYTHON} ${RUNdir}/swn_reginterpCG${CGNUM}.py ${RUNdir}/ CG_UNSTRUC.nc CG${CGNUM} HSWE ${siteid}" >> ${RUNdir}/reginterpCG${CGNUM}_cmdfile
   echo "${PYTHON} ${RUNdir}/swn_reginterpCG${CGNUM}.py ${RUNdir}/ CG_UNSTRUC.nc CG${CGNUM} WLEN ${siteid}" >> ${RUNdir}/reginterpCG${CGNUM}_cmdfile
   echo "${PYTHON} ${RUNdir}/swn_reginterpCG${CGNUM}.py ${RUNdir}/ CG_UNSTRUC.nc CG${CGNUM} DEPTH ${siteid}" >> ${RUNdir}/reginterpCG${CGNUM}_cmdfile

   aprun -n10 -N10 -j1 -d1 cfp ${RUNdir}/reginterpCG${CGNUM}_cmdfile
   export err=$?; err_chk
fi

exit 0
# -----------------------------------------------------------
# *******************************
# ********* End of File *********
# *******************************

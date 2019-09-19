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
# Version control: 1.13
#
# Support Team:
#
# Contributors: Roberto Padilla-Hernandez
# ----------------------------------------------------------- 
# ------------- Program Description and Details ------------- 
# ----------------------------------------------------------- 
#
# Script used to auto detect the hardware platform and select 
# the correct SWAN binary. 
#
# ----------------------------------------------------------- 

# Setup our NWPS environment                                                    
if [ "${USHnwps}" == "" ]
    then 
    echo "ERROR - Your USHnwps variable is not set"
    export err=1; err_chk
fi

# Check to see if our NWPS env is set
if [ "${NWPSenvset}" == "" ]
then 
    if [ -e ${USHnwps}/nwps_config.sh ];then
        source ${USHnwps}/nwps_config.sh
    else
        "ERROR - Cannot find ${USHnwps}/nwps_config.sh"
        export err=1; err_chk
    fi
fi

cd ${RUNdir}

if [ "${ARCH}" == "" ] || [ "${ARCHBITS}" == "" ] || [ "${NUMCPUS}" == "" ] || [ "${MPIEXEC}" == "" ]
then
    source ${USHnwps}/set_os_env.sh
fi

NUMCPUS_SWAN=`grep "use constant NUMCPUS" ${RUNdir}/ConfigSwan.pm | awk -F\' '{ print $2 }'`
if [ $NUMCPUS -ne $NUMCPUS_SWAN ]
then
    echo "INFO - NUMCPUS value in ConfigSwan.pm does not match the actual number of CPUs"
    echo "INFO - Will use the actual number of CPUs for model run"
fi

cat /dev/null > ${LOGdir}/systrk_info.log
     
# Check the number of CPUs one last time
if [ "$NUMCPUS" == "" ]; then NUMCPUS="1"; fi
if [ $NUMCPUS -eq 1 ];then
    echo "Starting ${ARCHBITS}-bit serial version of ww3_systrk_ser"   
    ${EXECnwps}/ww3_systrk_ser > ${RUNdir}/ww3_systrk.out 2> ${RUNdir}/ww3_systrk.err
    export err=$?
    if [ "${err}" != "0" ]; then
        echo "Exit Code: ${err}"                                     | tee -a ${LOGdir}/systrk_info.log 
	    echo "ERROR - Something went wrong running ww3_systrk_ser"       | tee -a ${LOGdir}/systrk_info.log 
	    echo "ERROR - HERE IS WHAT WE HAVE IN THE FILE "                 | tee -a ${LOGdir}/systrk_info.log 
	    echo "        ${DATAdir}/logs/run_wavetrack_exe_error.log"       | tee -a ${LOGdir}/systrk_info.log 
        cat ${DATAdir}/logs/run_wavetrack_exe_error.log >> ${LOGdir}/systrk_info.log
        msg="FATAL ERROR: Wave system tracking executable ww3_systrk failed."
        postmsg "$jlogfile" "$msg"
        err_chk
    fi
else
    echo "Starting ${ARCHBITS}-bit MPI version of ww3_systrk_exe_mpi"  
    #echo " In ww3_systrackexe.sh MPIEXEC: $MPIEXEC" 
    #${MPIRUN} -n8 -N8 -j1 -d1 ${EXECnwps}/ww3_systrk_mpi > ${RUNdir}/ww3_systrk.out 2> ${RUNdir}/ww3_systrk.err
    echo " In ww3_systrackexe.sh, calling aprun" 
    #bsub < ${NWPSdir}/dev/ecf/jnwps_wtcore_cg1.ecf.${siteid}  >> ${NWPSdir}/dev/ecf/jobids_${siteid}.log;
    #AW20180418 aprun -n16 -N16 -j1 -d1 ${EXECnwps}/ww3_systrk_mpi > ${RUNdir}/ww3_systrk.out 2> ${RUNdir}/ww3_systrk.err
    #AW aprun -n1 -N1 -d1 ${PYTHON} ${NWPSdir}/sorc/ww3_syscluster/ww3_systrk_nobasemap_tables_gh.py ${SITEID,,}
    aprun -n1 -N1 -d1 ${PYTHON} ${NWPSdir}/ush/python/ww3_systrk_cluster.py ${SITEID,,}
    export err=$?
    if [ "${err}" != "0" ];then
        echo " ============  E R R O R ==============="                  | tee -a ${LOGdir}/systrk_info.log 
        echo "Exit Code: ${err}"                                     | tee -a ${LOGdir}/systrk_info.log 
	    echo " Something went wrong running ww3_systrk_exe_mpi"          | tee -a ${LOGdir}/systrk_info.log 
	    echo " HERE IS WHAT WE HAVE IN THE FILE "                        | tee -a ${LOGdir}/systrk_info.log 
        echo " "                                                         | tee -a ${LOGdir}/systrk_info.log
	    echo "        ${DATAdir}/logs/run_wavetrack_exe_error.log"       | tee -a ${LOGdir}/systrk_info.log 
        cat ${DATAdir}/logs/run_wavetrack_exe_error.log >> ${LOGdir}/systrk_info.log 
        msg="FATAL ERROR: Wave system tracking executable ww3_systrk_mpi failed."
        postmsg "$jlogfile" "$msg"
        err_chk
    else
	    echo " ww3_systrk_exe_mpi run was successful "   | tee -a ${LOGdir}/systrk_info.log 
        echo "     Exit Code: ${err}"           | tee -a ${LOGdir}/systrk_info.log 
    fi
fi
if [ "${err}" == "0" ];then
   mv -fv sys_pnt.ww3   SYS_PNT.OUT
   mv -fv sys_coord.ww3 SYS_COORD.OUT
   mv -fv sys_hs.ww3    SYS_HSIGN.OUT
   mv -fv sys_tp.ww3    SYS_TP.OUT
   mv -fv sys_dir.ww3   SYS_DIR.OUT
   mv -fv sys_dspr.ww3  SYS_DSPR.OUT
fi

exit 0
# -----------------------------------------------------------
# *******************************
# ********* End of File *********
# *******************************

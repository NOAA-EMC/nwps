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

cat /dev/null > ${LOGdir}/systrk_info.log

echo "Starting clustering-based Python script ww3_systrk_cluster.py"  
echo " In ww3_systrackexe.sh, calling aprun" 
aprun -n1 -N1 -d1 ${PYTHON} ${NWPSdir}/ush/python/ww3_systrk_cluster.py ${SITEID,,}
export err=$?
if [ "${err}" != "0" ];then
    echo " ============  E R R O R ==============="                  | tee -a ${LOGdir}/systrk_info.log
    echo "Exit Code: ${err}"                                         | tee -a ${LOGdir}/systrk_info.log 
    echo " Something went wrong running ww3_systrk_cluster.py"       | tee -a ${LOGdir}/systrk_info.log 
    echo " HERE IS WHAT WE HAVE IN THE FILE "                        | tee -a ${LOGdir}/systrk_info.log 
    echo " "                                                         | tee -a ${LOGdir}/systrk_info.log
    echo "        ${DATAdir}/logs/run_wavetrack_exe_error.log"       | tee -a ${LOGdir}/systrk_info.log 
    cat ${DATAdir}/logs/run_wavetrack_exe_error.log >> ${LOGdir}/systrk_info.log 
    msg="FATAL ERROR: Wave system tracking script ww3_systrk_cluster.py failed."
    postmsg "$jlogfile" "$msg"
    err_chk
else
    echo " ww3_systrk_cluster.py run was successful "   | tee -a ${LOGdir}/systrk_info.log 
    echo "     Exit Code: ${err}"           | tee -a ${LOGdir}/systrk_info.log 
fi

#if [ "${err}" == "0" ];then
#   mv -fv sys_pnt.ww3   SYS_PNT.OUT
#   mv -fv sys_coord.ww3 SYS_COORD.OUT
#   mv -fv sys_hs.ww3    SYS_HSIGN.OUT
#   mv -fv sys_tp.ww3    SYS_TP.OUT
#   mv -fv sys_dir.ww3   SYS_DIR.OUT
#   mv -fv sys_dspr.ww3  SYS_DSPR.OUT
#fi

exit 0
# -----------------------------------------------------------
# *******************************
# ********* End of File *********
# *******************************

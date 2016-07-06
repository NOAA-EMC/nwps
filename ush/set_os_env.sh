#!/bin/bash
set -xa
# ----------------------------------------------------------- 
# UNIX Shell Script File
# Tested Operating System(s): RHEL 5,6
# Tested Run Level(s): 3, 5
# Shell Used: BASH shell
# Original Author(s): Douglas.Gaer@noaa.gov
# File Creation Date: 01/25/2011
# Date Last Modified: 11/13/2014
#
# Version control: 1.17
#
# Support Team:
#
# Contributors:
# ----------------------------------------------------------- 
# ------------- Program Description and Details ------------- 
# ----------------------------------------------------------- 
#
# Setup our working operating system and hardware platform 
# environment. This script is designed to be used as a BASH
# include file.
#
# Portable NWPS workstation OS/Hardware setup for all BASH
# scripts.
# ----------------------------------------------------------- 

# Setup our NWPS environment                                                    
if [ "${HOMEnwps}" == "" ]
    then 
    echo "ERROR - Your NWPSdir variable is not set"
    export err=1; err_chk
fi

# Set our global UMASK to all user:group read/write access 
# and others read-only access
umask 0002

# Set our global timeout for SSH connections. Since we run several
# automated SSH/SCP/SFTP process we need this to be a long timeout.
export TMOUT=9999

# Set our username
export USERNAME=$(whoami)

# Setup our hardware platform
ARCH=$(uname -m)
if [ "${ARCH}" == "x86_64" ]
    then
    echo "64-bit OS detected"
    echo "Setting up 64-bit NWPS run environment" 
    export ARCHBITS="64"
else
    echo "32-bit OS detected" 
    echo "Setting up 32-bit NWPS run environment" 
    echo "WARNING - 32-bit platform is not fully supported in version 3 or higher"
    export ARCHBITS="32"
fi

# NOTE: Path for extra LIB files 
export MPIEXEC=aprun
export MPIRUN=aprun
export OPAL_PREFIX="${LSF_BINDIR}/.."
export PATH=$PATH:${EXECnwps}
export NCDUMP=ncdump
export NCGEN=ncgen
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${NWPSdir}/lib"

echo "Detecting CPU info and number of processors"
export CPU=$(cat /proc/cpuinfo | grep -m 1 "model name" | awk -F: '{ print $2 }' | tr -s " ")
export NUMCPUS=$(cat /proc/cpuinfo | grep processor | wc -l | tr -d " ")
export NCPUS="$NUMCPUS"
export OMP_NUM_THREADS="$NUMCPUS"
if [ ${NUMCPUS} -eq 1 ]; then echo "${NUMCPUS} CPU detected:${CPU}"; fi
if [ ${NUMCPUS} -gt 1 ]; then echo "${NUMCPUS} CPUs detected:${CPU}"; fi
export CPUMHZ=$(cat /proc/cpuinfo | grep -m 1 "cpu MHz" | awk -F: '{ print $2 }' | tr -d " ")
export CPUCACHE=$(cat /proc/cpuinfo | grep -m 1 "cache size" | awk -F: '{ print $2 }' | tr -d " ")
echo "CPU speed is ${CPUMHZ} MHz"
echo "CPU cache is ${CPUCACHE}" 

echo "Detecting system memory information"
export MemTotal=$(cat /proc/meminfo | grep MemTotal | awk '{ print $2 }')
export MemFree=$(cat /proc/meminfo | grep MemFree | awk '{ print $2 }')
export SwapTotal=$(cat /proc/meminfo | grep SwapTotal | awk '{ print $2 }')
export SwapFree=$(cat /proc/meminfo | grep SwapFree | awk '{ print $2 }')
echo "Total system memory is ${MemTotal} KB"
echo "Total SWAP space is ${SwapTotal} KB"
#for WCOSS
#code01
cat /dev/null > ${RUNdir}/info_to_all_modules.txt
# Setup our NWPS env
echo "$ARCHBITS" >> ${RUNdir}/info_to_all_modules.txt
echo "$MPIEXEC" >> ${RUNdir}/info_to_all_modules.txt
echo "$OPAL_PREFIX" >> ${RUNdir}/info_to_all_modules.txt
echo "$GADDIR" >> ${RUNdir}/info_to_all_modules.txt
echo "$NCDUMP" >> ${RUNdir}/info_to_all_modules.txt
echo "$NCGEN" >> ${RUNdir}/info_to_all_modules.txt
echo "$WGRIB2" >> ${RUNdir}/info_to_all_modules.txt
echo "$DEGRIB" >> ${RUNdir}/info_to_all_modules.txt
echo "$PATH" >> ${RUNdir}/info_to_all_modules.txt
echo "$LD_LIBRARY_PATH" >> ${RUNdir}/info_to_all_modules.txt
echo "$CPU" >> ${RUNdir}/info_to_all_modules.txt
echo "$NUMCPUS" >>  ${RUNdir}/info_to_all_modules.txt
echo "$NCPUS" >>  ${RUNdir}/info_to_all_modules.txt
echo "$CPUMHZ" >>  ${RUNdir}/info_to_all_modules.txt
echo "$CPUCACHE" >>  ${RUNdir}/info_to_all_modules.txt
echo "$MemTotal" >>  ${RUNdir}/info_to_all_modules.txt
echo "$MemFree" >>  ${RUNdir}/info_to_all_modules.txt
echo "$SwapTotal" >>  ${RUNdir}/info_to_all_modules.txt
echo "$SwapFree" >>  ${RUNdir}/info_to_all_modules.txt

# ----------------------------------------------------------- 
# ******************************* 
# ********* End of File ********* 
# ******************************* 

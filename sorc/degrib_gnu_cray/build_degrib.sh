#!/bin/bash
# ----------------------------------------------------------- 
# UNIX Shell Script File
# Tested Operating System(s): RHEL 7
# Tested Run Level(s): 3, 5
# Shell Used: BASH shell
# Original Author(s): Douglas.Gaer@noaa.gov
# File Creation Date: 06/29/2016
# Date Last Modified: 06/29/2016
#
# Version control: 1.01
#
# Support Team:
#
# Contributors:
# ----------------------------------------------------------- 
# ------------- Program Description and Details ------------- 
# ----------------------------------------------------------- 
#
# Script used to build degrib for NWPS
#
# ----------------------------------------------------------- 

echo "Building degrib for WCOSS Cray"

export NODETYPE="COMPUTE"
if [ ! -z ${1} ]; then export NODETYPE="${1^^}"; fi
export USE_IOBUF="NO"
export BUILD="gnu"
export COMPILER="gnu"

export WORKDIR=$(pwd)

source ${WORKDIR} load_gnu_env.sh ${NODETYPE}

echo "Build using GNU Cray-CE for Cray haswell"
echo "Starting build"
date -u

cd ${WORKDIR}/src
make
make install 
make clean
cd ${WORKDIR}

echo "degrib build complete"
date -u
# ----------------------------------------------------------- 
# ******************************* 
# ********* End of File ********* 
# ******************************* 

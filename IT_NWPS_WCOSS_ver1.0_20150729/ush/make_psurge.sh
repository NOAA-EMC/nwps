#!/bin/bash
# ----------------------------------------------------------- 
# UNIX Shell Script File
# Shell Used: BASH shell
# Original Author(s): Roberto Padilla-Hernandez
# File Creation Date: 05/09/2015
# Date Last Modified: 10/14/2015
#
# Version control: 1.00
#
# Support Team:
#
# Contributors: Andre van der Westhuysen
#
# ----------------------------------------------------------- 
# ------------- Program Description and Details ------------- 
# ----------------------------------------------------------- 
#
# ex job, to extract P-Surge output onto NWPS ingest grids.
# This is done in two steps, namely:
#
# 1) Call make_psurge_init.sh to prepare the list of WFO 
#    domains to process, based on a quick scan of their 
#    P-Surge exposure for a given storm.
#
# 2) Call make_psurge_final.sh to perform the final 
#    high-res water level field extraction for those WFOs  
#    selected to wfo_cmdfile in Step (1) above, e.g.
#    ${NWPSdir}/ush/make_psurge_final.sh  mfl 3600
#
# These steps used the program psurge2nwps, which has the 
# following functionality:
#
#$ ./psurge2nwps -H
#Please provide a list of wfo's and/or the wfo directory
#usage: ./psurge2nwps <flt file> [options]
#
# -H       = Prints this help
# -V       = Version of the program
#
# -d [arg] = Directory containing [wfo]_ncep_config.sh files
# -i       = [Optional] Use bi-linear interpolation (vs nearest neighbor)
# -m       = [Optional] Output meters (vs feet)
# -o [arg] = [Optional] Output format (default 1)
#           [1] = Binary 4 byte float file (.dat) with z values.
#            2 = ASCII file (.dat) with z values.
#            3 = ASCII file (.csv) with lon, lat, z values.
#            4 = ASCII file (.csv) with lon, lat, x, y, z values.
# -s [arg] = [Optional] spacing for the wfo grid (default = 0.0045 degree)
# -w [arg] = WFO(s) to convert.sh file(s) containing the NWPS extents
#
#Assumptions:
#  1) mapfile is same as .flt except with a .txt extension.
#  2) Name of .flt file is of form *_[asof]_[proj. time]_[exceed].*
#     e.g. SURGE10_asof_006_e10.flt
#
#Example: ./psurge2nwps foo.flt -w mfl,mlb -d ./wfoFiles
# -----------------------------------------------------------
#
# ----------------------------------------------------------- 

echo "============================================================="
echo "=                                                           ="
echo "=                  RUNNING MAKE_PSURGE                      ="
echo "=                                                           ="
echo "============================================================="

# 1) Prepare the list of WFO domains to process, based on a quick
#    scan of their P-Surge coverage for a given storm.
${USHnwps}/make_psurge_init.sh

# 2) Call make_psurge_final.sh to perform the final high-res 
#    water level field extraction for those WFOs selected to wfo_cmdfile 
#    in Step (1) above, e.g.
#    ${NWPSdir}/ush/make_psurge_final.sh  mfl 3600
cd ${RUNdir}
mpirun.lsf cfp ${RUNdir}/wfo_cmdfile

#Log file
mv ${RUNdir}/*.log ${LOGdir}/

#Cleaning 
rm ${RUNdir}/*.flt
rm ${RUNdir}/*.hdr
rm ${RUNdir}/*.ave
rm ${RUNdir}/*.txt
rm ${RUNdir}/*.dat
rm ${RUNdir}/*.datum
rm  ${RUNdir}/*.grib2 
echo "mpirun.lsf complete"
exit 0

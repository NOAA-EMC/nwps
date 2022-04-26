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
# These steps use the program psurge2nwps, which has the 
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
export err=$?; err_chk

# 2) Call make_psurge_final.sh to perform the final high-res 
#    water level field extraction for those WFOs selected to wfo_cmdfile 
#    in Step (1) above, e.g.
#    ${NWPSdir}/ush/make_psurge_final.sh  mfl 3600
cd ${RUNdir}
##Running 24 tasks, 6 per node (on a total of 4 nodes)
# aprun -n24 -N6 -j1 -d1 cfp ${RUNdir}/wfo_cmdfile
# aprun -n24 -N6 -S3 -j1 -d1 cfp ${RUNdir}/wfo_cmdfile
# aprun -j 1 -n 24 -N 6 -S 3 -d 3 -cc depth cfp ${RUNdir}/wfo_cmdfile
# cmd="aprun -j 1 -n 24 -N 6 -S 3 -d 3 -cc depth cfp ${RUNdir}/wfo_cmdfile"
export MPICH_CPUMASK_DISPLAY=1
export MPICH_RANK_REORDER_METHOD=3  # 0=RR ; 1=SMP=dflt ; 2=folded ; 3=custom
rm -f MPICH_RANK_ORDER 2>/dev/null
cat >> MPICH_RANK_ORDER << EOF
23,0,1,2,3,4
5,6,7,8,9,10
11,12,13,14,15,16
17,18,19,20,21,22
EOF

cp ${RUNdir}/wfo_cmdfile /tmp/wfo_cmdfile.orig
rm -f /tmp/wfo_cmdfile 2>/dev/null
# Reorder the 22 domains in the new wfo_cmdfile matters for load balance
# in conjunction with the above MPICH_RANK_ORDER:
# socket | cores | node_0        | node_1        | node_2        | node_3        |
# socket | cores | MPI DOM NX*NY | MPI DOM NX*NY | MPI DOM NX*NY | MPI DOM NX*NY |
# -------+-------+---------------+---------------+---------------+---------------+
# 0      |  0-3  | 23  N/A     0 |  5  bro 41205 | 11  mfl 40936 | 17  tae 35550 |
# 0      |  4-7  |  0  crp 52899 |  6  okx 15200 | 12  phi 15851 | 18  box 22720 |
# 0      |  8-11 |  1  mhx 20440 |  7  mob 18995 | 13  jax 18837 | 19  lwx 17316 |
# -------+-------+---------------+---------------+---------------+---------------+
# 1      | 12-15 |  2  lix 28458 |  8  gyx 20956 | 14  ilm 20956 | 20  hgx 38752 |
# 1      | 16-19 |  3  key 28350 |  9  lch 25545 | 15  akq 26134 | 21  tbw 30855 |
# 1      | 20-23 |  4  car 15142 | 10  chs 23220 | 16  mlb 22512 | 22  N/A     0 |
# -------+-------+---------------+---------------+---------------+---------------+
# sum( NX * NY ) |        145289 |        145121 |        145226 |        145193 |

# In cfp/1.1.0 MPI-rank 0 was the master rank which did not do any work;
# in cfp/2.0.1, which is used here now, all MPI-ranks work equally, where
# MPI-rank 0 execs cmd_line 1, MPI-rank 1 execs cmd_line 2, etc, round-robin.
for d in     crp mhx   lix key car \
         bro okx mob   gyx lch chs \
         mfl phi jax   ilm akq mlb \
         tae box lwx   hgx tbw
do grep " ${d} " /tmp/wfo_cmdfile.orig >> /tmp/wfo_cmdfile
done
mv /tmp/wfo_cmdfile /tmp/wfo_cmdfile.orig ${RUNdir}

export CFP_VERBOSE=1
cmd="mpiexec -np 24 --cpu-bind verbose,core cfp ${RUNdir}/wfo_cmdfile"
echo "${0}: info: before ${cmd} at `date`"
t0=$SECONDS
# eval ${cmd}
mpiexec -np 24 --cpu-bind verbose,core cfp ${RUNdir}/wfo_cmdfile
export err=$?; err_chk
t1=$SECONDS
echo "${0}: info: after ${cmd} at `date`"
echo "${0}: info: '${cmd}' took $(( ( t1 - t0 ) + 1 )) wallclock seconds."
unset CFP_VERBOSE

#Running 24 tasks, 12 per node (on a total of 2 nodes)
#aprun -n24 -N12 -j1 -d1 cfp ${RUNdir}/wfo_cmdfile
export err=$?; err_chk

#Log file
mv ${RUNdir}/*.log ${LOGdir}/

#Cleaning 
rm ${RUNdir}/*.flt
rm ${RUNdir}/*.hdr
rm ${RUNdir}/*.ave
rm ${RUNdir}/*.txt
rm ${RUNdir}/*.dat
rm ${RUNdir}/*.datum
rm ${RUNdir}/*.grib2 
echo "mpiexec complete"
exit 0

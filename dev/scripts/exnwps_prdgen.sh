#!/bin/bash
###############################################################################
#                                                                             #
# This is the actual forcast script for the NWPS                              #
# It uses only a single ush script                                            #
#                                                                             #
#  multiwavestart.sh   : get initial time of most recent restart file(s)      #
#                                                                             #
#  Original Author(s): Roberto Padilla-Henandez                               # 
# File Creation Date: 04/20/2004                                              #
#                                                                             #
#                                                                             #
# Contributors:                                                               #
#                                                                             #
# Remarks :                                                                   #
# -                                                                           #
#                                                                             #
#  Update record :                                                            #
#                                                                             #
# - File Creation Date:     22_July-2014                                      #
#                                                                             #
# - Date Last Modified: 07/10/2013                                            #
#                                                                             #
#                                                                             #
###############################################################################
# --------------------------------------------------------------------------- #
# --------------------------------------------------------------------------- #
# 0.  Preparations
# Use LOUD variable to turn on/off trace.  Defaults to YES (on).
export LOUD=${LOUD:-YES}; [[ $LOUD = yes ]] && export LOUD=YES
echo ' '
echo '                      ******************************'
echo '                      ****** NWPSYSTEM SCRIPT ******'
echo '                      ******************************'
echo ' '
echo "Starting at : `date`"
[[ "$LOUD" = YES ]] && set -x

source ${USHnwps}/nwps_config.sh
export err=$?; err_chk
${USHnwps}/prdgen.sh
export err=$?; err_chk
echo "Prdgen-process completed"
exit 0
# End of script ------------------------------------------------------------- #

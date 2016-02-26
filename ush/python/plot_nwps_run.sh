#!/bin/bash
# ----------------------------------------------------------- 
# UNIX Shell Script
# Tested Operating System(s): RHEL 5
# Tested Run Level(s): 3, 5
# Shell Used: BASH shell
# Original Author(s): Douglas.Gaer@noaa.gov
# File Creation Date: 12/10/2009
# Date Last Modified: 08/27/2011
#
# Version control: 1.36
#
# Support Team:
#
# Contributors: Roberto.Padilla@noaa.gov
# ----------------------------------------------------------- 
# ------------- Program Description and Details ------------- 
# ----------------------------------------------------------- 
#
# PYTHON processing script used to create test images
# for NWPS model.
#
# ----------------------------------------------------------- 

# Setup our NWPS environment                                                    
if [ "${USHnwps}" == "" ]
    then 
    echo "ERROR - Your USHnwps variable is not set"
    export err=1; err_chk
fi

if [ -e ${USHnwps}/nwps_config.sh ]
then
    source ${USHnwps}/nwps_config.sh
else
    "ERROR - Cannot find ${USHnwps}/nwps_config.sh"
    export err=1; err_chk
fi

# The SITE ID is set in NWPS config but can be specified on the command line
if [ "$1" != "" ]; then SITEID="$1"; fi

if [ "${SITEID}" == "" ]
    then
    SITEID="default"
fi
SITEID=$(echo ${SITEID} | tr [:upper:] [:lower:])

echo $$ > ${TMPdir}/${USERNAME}/nwps/7791_plot_nwps_run_sh.pid
echo " +==================== plot_nwps_run.sh ======================"
echo "CGNUMPLOT= ${CGNUMPLOT}"
echo " +==================== ========================================="
# Set default plotting routine here
${USHnwps}/python/plot_nwps_run_from_grib2.sh ${SITEID}

# NOTE: We are now plotting the specta-1d and partitions from the GraphicsOutput.pm
##${USHnwps}/grads/bin/plot_specta.sh ${SITEID}
##${USHnwps}/grads/bin/plot_partition.sh ${SITEID}
echo "All NWPS output plots can be viewed at: ${OUTPUTdir}/figures"

exit 0
# ----------------------------------------------------------- 
# ******************************* 
# ********* End of File ********* 
# ******************************* 

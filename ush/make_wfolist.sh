#!/bin/bash
# -----------------------------------------------------------
# UNIX Shell Script
# Tested Operating System(s): RHEL 5, 6
# Tested Run Level(s): 3, 5
# Shell Used: BASH shell
# Original Author(s): Douglas.Gaer@noaa.gov
# File Creation Date: 03/05/2013
# Date Last Modified: 08/13/2015
#
# Version control: 1.04
#
# Support Team:
#
# Contributors:  Roberto.Padilla@noaa.gov
#               
# -----------------------------------------------------------
# ------------- Program Description and Details -------------
# -----------------------------------------------------------
#
# Script used to init the WFOLIST var
#
#
# -----------------------------------------------------------


# NOTE: Data is processed on the server in UTC
export TZ=UTC

if [ ! -e ${FIXnwps}/wfolist.dat ]
then 
    echo "ERROR - Cannot find ${FIXnwps}/wfolist.dat"
    export err=1; err_chk
fi

PROCESS="all"
if [ "$1" != "" ]; then PROCESS=$(echo "$1" | tr [:upper:] [:lower:]); fi

cat /dev/null > ${VARdir}/wfolist_${PROCESS}.sh
echo "#!/bin/bash" >> ${VARdir}/wfolist_${PROCESS}.sh
echo -n 'export WFOLIST="' >> ${VARdir}/wfolist_${PROCESS}.sh

# Sort by site ID
cp ${FIXnwps}/wfolist.dat ${VARdir}/wfolist.dat
sort ${VARdir}/wfolist.dat > ${VARdir}/wfolist_sorted_${PROCESS}.dat 

echo ""
while read line
do
    WFODATLINE=$(echo $line | sed s/' '//g | grep -v "^#")
    if [ "${WFODATLINE}" != "" ] 
    then
	WFO=$(echo ${WFODATLINE} | tr [:lower:] [:upper:])
	wfo=$(echo ${WFODATLINE} | tr [:upper:] [:lower:])
	echo "Reading ${WFO} config"
	if [ ! -e $FIXnwps/configs/${wfo}_ncep_config.sh ] 
	then 
	    echo "ERROR - Missing $FIXnwps/configs/${wfo}_ncep_config.sh"
	    echo "ERROR - cannot include WFO: ${WFO}"
	else
	    source $FIXnwps/configs/${wfo}_ncep_config.sh
	    HASERROR="false"
	    if [ "${ESTOFSDOMAIN}" == "" ] || [ "${ESTOFSNX}" == "" ] || [ "${ESTOFSNY}" == "" ]  || [ "${ESTOFS_REGION}" == "" ]
	    then
		echo "ERROR - ESTOFS domain is not set for ${WFO}"
		echo "ERROR - Need to set ESTOFSDOMAIN, ESTOFSNX, ESTOFSNY, and ESTOFS_REGION vars for ${WFO}"
		echo "ERROR - Check the $FIXnwps/configs/${wfo}_ncep_config.sh config"
		HASERROR="true"
	    fi
	    ESTOFSDOMAIN=""
	    ESTOFSNX=""
	    ESTOFSNY=""
	    ESTOFS_REGION=""

	    if [ RTOFSSOURCE == "global" ]
	    then
		if [ "${RTOFSLON}" == "" ] || [ "${RTOFSLAT}" == "" ]
		then
		    echo "ERROR - Your RTOFS global domain is not set for ${WFO}"
		    echo "ERROR - Need to set RTOFSLON and RTOFSLAT vars for ${WFO}"
		    echo "ERROR - Check the $FIXnwps/configs/${wfo}_ncep_config.sh config"
		    HASERROR="true"
		fi
		RTOFSLON=""
		RTOFSLAT=""
		RTOFSDATFILE=""
	    else
		if [ "${RTOFSDOMAIN}" == "" ] || [ "${RTOFSNX}" == "" ] || [ "${RTOFSNY}" == "" ] || [ "${RTOFSSECTOR}" == "" ]
		then
		    echo "ERROR - Your RTOFS sector domain is not set for ${WFO}"
		    echo "ERROR - Need to set RTOFSDOMAIN, RTOFSNX, RTOFSNY, and RTOFSSECTOR vars for ${WFO}"
		    echo "ERROR - Check your $FIXnwps/configs/${wfo}_ncep_config.sh config"
		    HASERROR="true"
		fi
		RTOFSSECTOR=""
		RTOFSDOMAIN=""
		RTOFSNX=""
		RTOFSNY=""
	    fi

            if [ "${PROCESS}" == "estofs" ] && [ "${WFO}" == "GUM" ]; then
               echo "WARNING - No ESTOFS data available for WFO Guam at present"
               echo "WARNING - cannot include WFO: ${WFO}"
               continue
            fi

	    if [ "${HASERROR}" == "false" ]
	    then 
		echo "Adding ${WFO} to RTOFS/ESTOFS init list"
		echo -n "${WFO} " >> ${VARdir}/wfolist_${PROCESS}.sh
	    else
		echo "ERROR - cannot include WFO: ${WFO}"
	    fi

	fi
    fi
done < ${VARdir}/wfolist_sorted_${PROCESS}.dat

echo -n '"' >> ${VARdir}/wfolist_${PROCESS}.sh
sed -i s/' "'/'"'/g ${VARdir}/wfolist_${PROCESS}.sh

source ${VARdir}/wfolist_${PROCESS}.sh

exit 0
# -----------------------------------------------------------
# *******************************
# ********* End of File *********
# *******************************


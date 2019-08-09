#!/bin/bash
# ----------------------------------------------------------- 
# UNIX Shell Script File
# Tested Operating System(s): RHEL 6, 7
# Tested Run Level(s): 3, 5
# Shell Used: BASH shell
# Original Author(s): Alex Gibbs
# File Creation Date: 11/13/2013
# Date Last Modified: 01/10/2017
#
# Version control: 3.19
#
# Support Team:
#
# Contributors: Douglas.Gaer@noaa.gov
# ----------------------------------------------------------- 
# ------------- Program Description and Details ------------- 
# ----------------------------------------------------------- 
#
# Gen INPUTcg1 entries for ship routes.
#
# -----------------------------------------------------------
export TZ="UTC"

# Check to see if our SITEID is set
if [ "${SITEID}" == "" ]
    then
    echo "ERROR - Your SITEID variable is not set"
    exit 1
fi

if [ "${HOMEnwps}" == "" ]
    then 
    echo "ERROR - Your HOMEnwps variable is not set"
    exit 1
fi

if [ -e ${USHnwps}/nwps_config.sh ]
then
    source ${USHnwps}/nwps_config.sh
else
    echo "ERROR - Cannot find ${USHnwps}/nwps_config.sh"
    exit 1
fi

CFGFILE=${FIXnwps}/shiproutes/${siteid}_shiproutes.cfg
if [ ! -e ${CFGFILE} ]
then
    echo "ERROR - Missing ${FIXnwps}/shiproutes/${siteid}_shiproutes.cfg"
    echo "ERROR - No ship route data or plots will be created for ${SITEID}"
    exit 1
fi

PROCdir="${VARdir}/shiproutes"
if [ ! -e ${PROCdir} ]; then mkdir -p ${PROCdir}; fi

export curhour=$(date -u +%H)
if [ ! -z "${USER_PDY}" ]; then curhour=$(echo "${USER_PDY}" | cut -c9-10); fi
if [ $curhour -lt 12 ]; then CYCLE="00"; fi
if [ $curhour -ge 12 ] && [ $curhour -lt 18 ]; then CYCLE="06"; fi
if [ $curhour -ge 18 ] && [ $curhour -lt 22 ]; then CYCLE="12"; fi
if [ $curhour -ge 22 ]; then CYCLE="18"; fi

LOGFILE="${LOGdir}/shiproute_domain_setup.log"

cat /dev/null > ${LOGFILE}
echo "Setting up INPUTcg1 points for ${SITEID} shitp routes" | tee -a ${LOGFILE}
date -u  | tee -a ${LOGFILE}

cd ${PROCdir}

cat /dev/null > ${PROCdir}/INPUTcg1_shiproutes.app
echo "$" >> ${PROCdir}/INPUTcg1_shiproutes.app
echo "$ START SHIP ROUTE LINES" >> ${PROCdir}/INPUTcg1_shiproutes.app
echo "$" >> ${PROCdir}/INPUTcg1_shiproutes.app

error_level=0

# Read site configuration
# loc1,stlat,stlon,loc2,endlat,endlon,resolution,current_box_lats,current_box_lons,current_box_xaxis,swan_table_name
while read line
do
    DATLINE=$(echo $line | grep -v "^#")
    if [ "${DATLINE}" != "" ] 
    then
	loc1=$(echo "${DATLINE}" | awk -F, '{ print $1 }')
	stlat=$(echo "${DATLINE}" | awk -F, '{ print $2 }')
	stlon=$(echo "${DATLINE}" | awk -F, '{ print $3 }')
	loc2=$(echo "${DATLINE}" | awk -F, '{ print $4 }')
	endlat=$(echo "${DATLINE}" | awk -F, '{ print $5 }')
	endlon=$(echo "${DATLINE}" | awk -F, '{ print $6 }')
	res=$(echo "${DATLINE}" | awk -F, '{ print $7 }')
	current_box_lats=$(echo "${DATLINE}" | awk -F, '{ print $8 }')
	current_box_lons=$(echo "${DATLINE}" | awk -F, '{ print $9 }')
	current_box_xaxis=$(echo "${DATLINE}" | awk -F, '{ print $10 }')
	swan_table_name=$(echo "${DATLINE}" | awk -F, '{ print $11 }')

	echo "Running config to gen ship route entries for:" | tee -a ${LOGFILE}
	echo "loc1 = ${loc1}" | tee -a ${LOGFILE}
	echo "loc2 = ${loc2}" | tee -a ${LOGFILE}
	echo "stlat = ${stlat}" | tee -a ${LOGFILE}
	echo "stlon = ${stlon}" | tee -a ${LOGFILE}
	echo "endlat = ${endlat}" | tee -a ${LOGFILE}
	echo "endlon = ${endlon}" | tee -a ${LOGFILE}
	echo "res = ${res}" | tee -a ${LOGFILE}
	echo "current_box_lats = ${current_box_lats}" | tee -a ${LOGFILE}
	echo "current_box_lons = ${current_box_lons}" | tee -a ${LOGFILE}
	echo "current_box_xaxis = ${current_box_xaxis}" | tee -a ${LOGFILE}
	echo "swan_table_name = ${swan_table_name}" | tee -a ${LOGFILE}

	filename=$(echo "${loc1}_${loc2}")
	filename=$(echo "${filename}" | sed s/' '//g)

	echo "Checking ship route configuration" | tee -a ${LOGFILE}
	if [ "${loc1}" == "" ]; then
	    echo "ERROR - loc1 is not set, check ${CFGFILE} config file" | tee -a ${LOGFILE}
	    error_level=1
	    continue
	fi
	if [ "${loc2}" == "" ]; then
	    echo "ERROR - loc2 is not set, check ${CFGFILE} config file" | tee -a ${LOGFILE}
	    error_level=1
	    continue
	fi
	if [ "${stlat}" == "" ]; then
	    echo "ERROR - stlat is not set, check ${CFGFILE} config file" | tee -a ${LOGFILE}
	    error_level=1
	    continue
	fi
	if [ "${stlon}" == "" ]; then
	    echo "ERROR - stlon is not set, check ${CFGFILE} config file" | tee -a ${LOGFILE}
	    error_level=1
	    continue
	fi
	if [ "${endlat}" == "" ]; then
	    echo "ERROR - endlat is not set, check ${CFGFILE} config file" | tee -a ${LOGFILE}
	    error_level=1
	    continue
	fi
	if [ "${endlon}" == "" ]; then
	    echo "ERROR - endlon is not set, check ${CFGFILE} config file" | tee -a ${LOGFILE}
	    error_level=1
	    continue
	fi
	if [ "${res}" == "" ]; then
	    echo "ERROR - res	 is not set, check ${CFGFILE} config file" | tee -a ${LOGFILE}
	    error_level=1
	    continue
	fi
	if [ "${current_box_lats}" == "" ]; then
	    current_box_lats="${stlat} ${endlat}"
	    echo "WARNING - current_box_lats is not set, defaulting to ${stlat} ${endlat}" | tee -a ${LOGFILE}
	fi
	if [ "${current_box_lons}" == "" ]; then
	    current_box_lons="${stlon} ${endlon}"
	    echo "WARNING - current_box_lons is not set, defaulting to ${stlon} ${endlon}" | tee -a ${LOGFILE}
	fi
	if [ "${current_box_xaxis}" == "" ]; then
	    current_box_xaxis="${stlon} ${endlon}"
	    echo "WARNING - current_box_xaxis is not set, defaulting to ${stlon} ${endlon}" | tee -a ${LOGFILE}
	    continue
	fi

	echo "Departing point: ${stlat} ${stlon}" | tee -a ${LOGFILE}
	echo "Final Destination: ${endlat} ${endlon}" | tee -a ${LOGFILE}

	dist=$(${USHnwps}/dist_lat_lon.pl ${stlat} ${stlon} ${endlat} ${endlon})
	echo "Distance between start and end points: ${dist} km" | tee -a ${LOGFILE}

	# Calc number of points based on specified on resolution provided: 
	midpt=$(echo "scale=1;(${dist}/2)" | bc)
	ptnum=$(echo "scale=0;(${dist}/${res})" | bc)
	echo "Total Grid Points: $ptnum"
	if [ $ptnum -le 0 ]; then
	    echo "ERROR - Bad number of points $ptnum" | tee -a ${LOGFILE}
	    error_level=1
	    continue
	fi
	
	latincr=$(echo "scale=10;(${endlat} - ${stlat})/$ptnum" | bc)
	latincr=$(echo "${latincr}" | sed s'/-//'g)
	lonincr=$(echo "scale=10;(${stlon} - (${endlon}))/$ptnum" | bc)
	lonincr=$(echo "${lonincr}" | sed s'/-//'g)
	echo "dy: $latincr" | tee -a ${LOGFILE}
	echo "dx: $lonincr" | tee -a ${LOGFILE}
	
	cat /dev/null > ${PROCdir}/lat_points_NS.txt
	cat /dev/null > ${PROCdir}/lat_points.txt
	cat /dev/null > ${PROCdir}/lon_points_EW.txt 
	cat /dev/null > ${PROCdir}/lon_points.txt

	seq $stlat $latincr $endlat > ${PROCdir}/lat_points.txt
	num_SN_points=$(cat ${PROCdir}/lat_points.txt | wc -l)
	if [ $num_SN_points -le 0 ]
	then
	    echo "INFO: Switching LAT points from S->N to N->S"| tee -a ${LOGFILE}
	    seq $endlat $latincr $stlat > ${PROCdir}/lat_points_NS.txt
	    tac ${PROCdir}/lat_points_NS.txt > ${PROCdir}/lat_points.txt
	fi

	seq $stlon $lonincr $endlon > ${PROCdir}/lon_points.txt
	num_EW_points=$(cat ${PROCdir}/lon_points.txt | wc -l)
	if [ $num_EW_points -le 0 ]
	then
	    echo "INFO: Switching LON points from E->W to W->E"| tee -a ${LOGFILE}
	    seq $endlon $lonincr $stlon > ${PROCdir}/lon_points_WE.txt
	    tac ${PROCdir}/lon_points_WE.txt > ${PROCdir}/lon_points.txt
	fi

	ptnum_vert=$(cat ${PROCdir}/lat_points.txt | wc -l)
	echo "Number of LAT points: ${ptnum_vert}" | tee -a ${LOGFILE}

	# For the routes we are only tracking one horizontal level
	ptnum=$(cat ${PROCdir}/lon_points.txt | wc -l)
	echo "Number of LON points: ${ptnum}" | tee -a ${LOGFILE}
	
	if [ $num_SN_points -le 0 ]
	then
	    YDEF="YDEF 1 linear ${endlat} ${latincr}"
	else
	    YDEF="YDEF 1 linear ${stlat} ${latincr}"
	fi
	
	if [ $num_EW_points -le 0 ]
	then
	    XDEF="XDEF ${ptnum} linear ${endlon} ${lonincr}"
	else
	    XDEF="XDEF ${ptnum} linear ${stlon} ${lonincr}"
	fi
	
	echo "${XDEF}" | tee -a ${LOGFILE}
	echo "${YDEF}" | tee -a ${LOGFILE}
	
	echo -n "POINTS '${swan_table_name}'" >> ${PROCdir}/INPUTcg1_shiproutes.app
	while read -u 3 -r lon && read -u 4 -r lat
	do 
	    clon=$(echo "scale=3; (360.00 - ${lon})/1" | bc)
	    testval=$(echo "scale=0; ${lon}/1" | bc)
	    if [ $testval -lt 0 ]; then clon=$(echo "scale=3; (${lon} + 360.00)/1" | bc); fi
	    lat=$(echo "scale=4; ${lat}/1" | bc); 
	    echo " &" >> ${PROCdir}/INPUTcg1_shiproutes.app
	    echo -n "${clon} ${lat} " >> ${PROCdir}/INPUTcg1_shiproutes.app
	done 3<${PROCdir}/lon_points.txt 4<${PROCdir}/lat_points.txt
	echo "" >> ${PROCdir}/INPUTcg1_shiproutes.app
	echo "TABLE '${swan_table_name}' HEAD '${swan_table_name}' TIME XP YP HSIG TPS PDIR WIND OUTPUT $(date +%Y%m%d).${CYCLE}00 1.0 HR" >> ${PROCdir}/INPUTcg1_shiproutes.app

# End of config line read	
    fi
done < ${CFGFILE}

echo "$" >> ${PROCdir}/INPUTcg1_shiproutes.app
echo "$ END SHIP ROUTE LINES" >> ${PROCdir}/INPUTcg1_shiproutes.app
echo "$" >> ${PROCdir}/INPUTcg1_shiproutes.app

echo "Ship route INPUTcg1 lines complete for ${SITEID}" | tee -a ${LOGFILE}
date -u | tee -a ${LOGFILE}

exit ${error_level}
# -----------------------------------------------------------
# *******************************
# ********* End of File *********
# *******************************

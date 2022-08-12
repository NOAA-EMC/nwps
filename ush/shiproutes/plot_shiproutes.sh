#!/bin/bash
# ----------------------------------------------------------- 
# UNIX Shell Script File
# Tested Operating System(s): RHEL 6, 7
# Tested Run Level(s): 3, 5
# Shell Used: BASH shell
# Original Author(s): Alex Gibbs
# File Creation Date: 11/13/2013
# Date Last Modified: 01/13/2017
#
# Version control: 4.05
#
# Support Team:
#
# Contributors: Douglas.Gaer@noaa.gov
# ----------------------------------------------------------- 
# ------------- Program Description and Details ------------- 
# ----------------------------------------------------------- 
#
# Program used to generate ship routes. This is a multi-site
# adaptation of the MFL version written by Alex Gibbs. This
# version can be used for multiple sites and uses WGRIB2 to
# do the point extraction. 
#
# NOTE: Versions past 03/11/2016 will be recoded for WCOSS
#
# NOTE: 03/22/2016 GRADS migrated Python plotting.
#
# -----------------------------------------------------------
export TZ="UTC"

# Check to see if our NWPS env is set
if [ "${NWPSenvset}" == "" ]
then 
    if [ -e ${USHnwps}/nwps_config.sh ]
    then
	source ${USHnwps}/nwps_config.sh
    else
	echo "ERROR - Cannot find ${USHnwps}/nwps_config.sh"
	exit 1
    fi
fi

INPUTGRIB2file="${1}"

if [ "${INPUTGRIB2file}" == "" ]
then
    if [ ! -e ${OUTPUTdir}/grib2/CG1 ]; then mkdir -pv ${OUTPUTdir}/grib2/CG1; fi
    cd ${OUTPUTdir}/grib2/CG1
    INPUTGRIB2file=$(ls -1rat --color=none ???_nwps_CG1_????????_????.grib2 | tail -1)
    if [ "${INPUTGRIB2file}" == "" ]; then
	echo "ERROR - No CG1 GRIB2 file from last run"
	exit 1
    fi
    INPUTGRIB2file=$(echo "${OUTPUTdir}/grib2/CG1/${INPUTGRIB2file}")
fi

if [ ! -e ${INPUTGRIB2file} ]; then
    echo "ERROR - ${INPUTGRIB2file} file does not exist"
    exit 1
fi

CFGFILE=${FIXnwps}/shiproutes/${siteid}_shiproutes.cfg
if [ ! -e ${CFGFILE} ]
then
    echo "ERROR - Missing ${FIXnwps}/shiproutes/${siteid}_shiproutes.cfg"
    exit 1
fi

FIXPOINTS="${EXECnwps}/fix_ascii_point_data"
WRITEDAT="${EXECnwps}/writedat"
if [ -z "${PYTHON}" ]; then export PYTHON=python; fi

PROCdir="${VARdir}/shiproutes"
if [ ! -e ${PROCdir} ]; then mkdir -p ${PROCdir}; fi

TEMPDIR=${VARdir}/${siteid}.tmp/CG1
if [ ! -e $TEMPDIR} ]; then mkdir -p ${TEMPDIR}; fi

GRAPHICOUTPUTdir="${OUTPUTdir}/figures/${siteid}/shiproutes"
TEMPLATEDIR="${USHnwps}/python/etc/default"

if [ ! -e ${GRAPHICOUTPUTdir} ]; then mkdir -p ${GRAPHICOUTPUTdir}; fi

# NOTE: We need to track run times for plotting. Ship route plotting requires 
# NOTE: you to pull a data point for individual lat/lon values, which is 
# NOTE: computationally expensive with compressed data.
source ${USHnwps}/calc_runtime.sh

LOGFILE="${LOGdir}/plot_shiproutes.log"

echo "Starting ship route plots for ${SITEID}"
echo "Checking for lock files"

cat /dev/null > ${PROCdir}/start_secs.txt
cat /dev/null > ${PROCdir}/end_secs.txt
date +%s > ${PROCdir}/start_secs.txt

DEBUGLOGfile="${LOGdir}/plot_shiproutes_debug.log"
cat /dev/null > ${DEBUGLOGfile}
cat /dev/null > ${LOGFILE}
echo "Starting ship route plots for ${SITEID}" | tee -a ${LOGFILE}
date -u  | tee -a ${LOGFILE}

TEMPLATEDIR="${USHnwps}/shiproutes/etc/default"

GRIB2file="${PROCdir}/swancg1run.grib2"

cd ${PROCdir}
cat ${INPUTGRIB2file} > ${GRIB2file}

echo "Reading GRIB2 file ${GRIB2file}" | tee -a ${LOGFILE}

# Get our model time from the input CG1 file
grep "^INPGRID WIND" ${RUNdir}/inputCG1 > blah1
init=$(awk '{print $11;}' blah1)
echo "$init" > datetime
cut -c 1-4 datetime > year
cut -c 5-6 datetime > mon
cut -c 7-8 datetime > day
cut -c 10-11 datetime > hh
cut -c 12-13 datetime > mm
yyyy=$(cat year)
mon=$(cat mon)
dd=$(cat day)
hh=$(cat hh)
mm=$(cat mm)
ss="00"

time_str="${yyyy} ${mon} ${dd} ${hh} ${mm} ${ss}"
g2_etime=`echo ${time_str} | awk -F: '{ print mktime($1 $2 $3 $4 $5 $6) }'`

echo "GRIB2 Unix time: ${g2_etime}" | tee -a ${LOGFILE}
echo "GRIB2 sting time: ${yyyy}/${mon}/${dd} ${hh}:${mm}:${ss}" | tee -a ${LOGFILE}

# Get the first, second, and last forecast hours from the grib2 file
fhour1=$(${WGRIB2} ${GRIB2file} -match WIND | head -2 | awk -F':' '{ print $6 }' | awk '{ print $1 }' | grep -v 'anl')
fhour2=$(${WGRIB2} ${GRIB2file} -match WIND | head -3 | awk -F':' '{ print $6 }' | awk '{ print $1 }' | grep -v 'anl' | grep -v "${fhour1}")
lhour=$(${WGRIB2} ${GRIB2file} -match WIND | tail -1 | awk -F':' '{ print $6 }' | awk '{ print $1 }')

# Get hour time step from the grib2 vars
timestep=$(echo "${fhour2} - ${fhour1}" | bc )

echo "Timestep = ${timestep}" | tee -a ${LOGFILE}
echo "Number of forecast hours = ${lhour}" | tee -a ${LOGFILE}

num_hours=$(${WGRIB2} ${GRIB2file} -match WIND | wc -l)
num_forcast_hours=$(echo "(${num_hours} - 1) * ${timestep}" | bc)
if [ $num_forcast_hours -ne $lhour ]
then
    echo "ERROR - Bad grib2 time series for $lhour forcast hours with a timestep of $timestep" | tee -a ${LOGFILE}
    exit 1
fi

#Override time step to 3-hourly
timestep=3
lhour=49
num_hours=${lhour}

# Read site configuration
# loc1,stlat,stlon,loc2,endlat,endlon,resolution,current_box_lats,current_box_lons,current_box_xaxis,swan_table_name
rtnum=0
cat /dev/null > ${PROCdir}/python_shiproute_cur_elements.sh
cat /dev/null > ${PROCdir}/python_shiproute_elements.sh
while read line
do
    DATLINE=$(echo $line | grep -v "^#")
    if [ "${DATLINE}" != "" ] 
    then
        # Create subfolder for processing
        rtnum=$((rtnum+1))
        PROCdirparll="${PROCdir}/route${rtnum}"
        mkdir -p ${PROCdirparll}

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

	echo "Running config to gen ship route plots for:" | tee -a ${LOGFILE}
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

	echo "Checking ship route configuration" | tee -a ${LOGFILE}
	if [ "${loc1}" == "" ]; then
	    echo "ERROR - loc1 is not set, check ${CFGFILE} config file" | tee -a ${LOGFILE}
	    continue
	fi
	if [ "${loc2}" == "" ]; then
	    echo "ERROR - loc2 is not set, check ${CFGFILE} config file" | tee -a ${LOGFILE}
	    continue
	fi
	if [ "${stlat}" == "" ]; then
	    echo "ERROR - stlat is not set, check ${CFGFILE} config file" | tee -a ${LOGFILE}
	    continue
	fi
	if [ "${stlon}" == "" ]; then
	    echo "ERROR - stlon is not set, check ${CFGFILE} config file" | tee -a ${LOGFILE}
	    continue
	fi
	if [ "${endlat}" == "" ]; then
	    echo "ERROR - endlat is not set, check ${CFGFILE} config file" | tee -a ${LOGFILE}
	    continue
	fi
	if [ "${endlon}" == "" ]; then
	    echo "ERROR - endlon is not set, check ${CFGFILE} config file" | tee -a ${LOGFILE}
	    continue
	fi
	if [ "${res}" == "" ]; then
	    echo "ERROR - res	 is not set, check ${CFGFILE} config file" | tee -a ${LOGFILE}
	    continue
	fi
	if [ "${current_box_lats}" == "" ]; then
	    current_box_lats="${stlat} ${endlat}"
	    echo "INFO - current_box_lats is not set, defaulting to ${stlat} ${endlat}" | tee -a ${LOGFILE}
	fi
	if [ "${current_box_lons}" == "" ]; then
	    current_box_lons="${stlon} ${endlon}"
	    echo "WARNING - current_box_lons is not set, defaulting to ${stlon} ${endlon}" | tee -a ${LOGFILE}
	fi
	if [ "${current_box_xaxis}" == "" ]; then
	    current_box_xaxis="${stlon} ${endlon}"
	    echo "WARNING - current_box_xaxis is not set, defaulting to ${stlon} ${endlon}" | tee -a ${LOGFILE}
	fi
	if [ "${swan_table_name}" == "" ]; then
	    echo "ERROR - swan_table_name is not set, check ${CFGFILE} config file" | tee -a ${LOGFILE}
	    continue
	fi
	CG1line=$(grep -E '^TABLE' ${RUNdir}/inputCG1 | grep ${swan_table_name})
	if [ "${CG1line}" == "" ]; then
	    echo "ERROR - ${swan_table_name} not found in inputCG1 file" | tee -a ${LOGFILE}
	    continue
	fi
	STARTtime=$(echo ${CG1line} | awk '{ print $13 }')
	YY=$(echo ${STARTtime} | cut -b3-4)
	MO=$(echo ${STARTtime} | cut -b5-6)
	DD=$(echo ${STARTtime} | cut -b7-8)
	HH=$(echo ${STARTtime} | cut -b10-11)
	SWANoutputfile="${RUNdir}/${swan_table_name}.YY${YY}.MO${MO}.DD${DD}.HH${HH}"
	if [ ! -f ${SWANoutputfile} ]; then
	    echo "ERROR - ${SWANoutputfile} file does not exist" | tee -a ${LOGFILE}
	    continue
	fi

	cp -fpv ${SWANoutputfile} ${PROCdirparll}/${swan_table_name} | tee -a ${LOGFILE}
	rm -f ${SWANoutputfile}

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
	    continue
	fi
	
	latincr=$(echo "scale=10;(${endlat} - ${stlat})/$ptnum" | bc)
	latincr=$(echo "${latincr}" | sed s'/-//'g)
	lonincr=$(echo "scale=10;(${stlon} - (${endlon}))/$ptnum" | bc)
	lonincr=$(echo "${lonincr}" | sed s'/-//'g)
	echo "dy: $latincr" | tee -a ${LOGFILE}
	echo "dx: $lonincr" | tee -a ${LOGFILE}

	num_EW_points=$(seq $stlon $lonincr $endlon | wc -l)
	ptnum=${num_EW_points}
	XDEF="XDEF ${ptnum} linear ${stlon} ${lonincr}"
	if [ $num_EW_points -le 0 ]
	then
	    echo "INFO: Switching LON points from E->W to W->E"| tee -a ${LOGFILE}
	    num_EW_points=$(seq $endlon $lonincr $stlon | wc -l)
	    ptnum=${num_EW_points}
	    XDEF="XDEF ${ptnum} linear ${endlon} ${lonincr}"
	fi

	num_SN_points=$(seq $stlat $latincr $endlat | wc -l)
	YDEF="YDEF 1 linear ${stlat} ${latincr}"
	if [ $num_SN_points -le 0 ]
	then
	    echo "INFO: Switching LAT points from S->N to N->S"| tee -a ${LOGFILE}
	    YDEF="YDEF 1 linear ${endlat} ${latincr}"
	fi
	
	# For the routes we are only tracking one horizontal level
	echo "Number of LON points: ${ptnum}" | tee -a ${LOGFILE}
	
	echo "${XDEF}" | tee -a ${LOGFILE}
	echo "${YDEF}" | tee -a ${LOGFILE}

	TIMESTEP="${timestep}"
	HOURS=${num_hours}
	DHOUR=1
	
	echo "Writing Fortran BIN of horizontal points for HTSGW DIRPW WIND PERPW out to ${num_forcast_hours} forecast hours" | tee -a ${LOGFILE}
        echo "Filter table file to 3-hourly..."
	# Accounting for init hours that differ from the 3-hourly cadence (00z, 03z, 06z, 09z, ...)
	cycle=$(awk '{print $1;}' ${RUNdir}/CYCLE)
	hourshift=`expr $cycle % 3`
	starthour=$(( `expr $hourshift % 3` - 3 ))
	endhour=$(( 21 + `expr $hourshift % 3` ))

	#for h in {0..21..3}; do
	for (( h=$starthour; h<=$endhour; h+=3 )); do
           hp1=$(printf "%02d" $((h+1)) )
           hp2=$(printf "%02d" $((h+2)) )
           echo "Deleting rows for forecast hour .${hp1}0000"
           sed -i "/.${hp1}0000/d" ${PROCdirparll}/${swan_table_name}
           echo "Deleting rows for forecast hour .${hp2}0000"
           sed -i "/.${hp2}0000/d" ${PROCdirparll}/${swan_table_name}
        done
	${EXECnwps}/shiproute_to_bin -v ${PROCdirparll}/${swan_table_name} ${PROCdirparll}/shiproute.bin | tee -a ${LOGFILE}
	
	echo "Generating templates for plotting" | tee -a ${LOGFILE}
	time_stamp="${yyyy}${mon}${dd}_${hh}${mm}"
	echo "Time stamp: ${time_stamp}" | tee -a ${LOGFILE}
	time_str="${yyyy} ${mon} ${dd} ${hh} ${mm} 00"
	epoch_time=$(echo ${time_str} | awk -F: '{ print mktime($1 $2 $3 $4 $5 $6) }')
	month=$(echo ${epoch_time} | awk '{ print strftime("%b", $1) }' | tr [:upper:] [:lower:])
	echo "Time string: ${hh}z${dd}${month}${yyyy}" | tee -a ${LOGFILE}

	cg1CLON=$(${WGRIB2} ${GRIB2file} -V -d 1 | grep lon | grep to | grep by | awk '{ print $2 }')
	cg1LON=$(echo "${cg1CLON} - 360" | bc)
	cg1DX=$(${WGRIB2} ${GRIB2file} -V -d 1 | grep lon | grep to | grep by | awk '{ print $6 }')
	cg1NX=$(${WGRIB2} ${GRIB2file} -V -d 1 | grep lat-lon | grep grid | grep x | awk '{ print $2 }' | sed s/'grid:('//g)
	cg1LAT=$(${WGRIB2} ${GRIB2file} -V -d 1 | grep lat | grep to | grep by | awk '{ print $2 }')
	cg1DY=$(${WGRIB2} ${GRIB2file} -V -d 1 | grep lat | grep to | grep by | awk '{ print $6 }')
	cg1NY=$(${WGRIB2} ${GRIB2file} -V -d 1 | grep lat-lon | grep grid | grep x | awk '{ print $4 }' | sed s/')'//g)

	echo "Writing our Python plotting config file" | tee -a ${LOGFILE}
	cat /dev/null > ${PROCdirparll}/pyplot_shiproutes.cfg
	echo "# CFG file for python plotting program" >> $PROCdirparll/pyplot_shiproutes.cfg
	echo "[GRIB2]" >> $PROCdirparll/pyplot_shiproutes.cfg
	echo "DSET =  ${PROCdir}/swancg1run.grib2" >> $PROCdirparll/pyplot_shiproutes.cfg
	echo "UNDEF = 9.999E+20" >> $PROCdirparll/pyplot_shiproutes.cfg
	echo "PLOT = False" >> $PROCdirparll/pyplot_shiproutes.cfg
	echo "NLONS = $cg1NX" >> $PROCdirparll/pyplot_shiproutes.cfg
	echo "LL_LON = $cg1LON" >> $PROCdirparll/pyplot_shiproutes.cfg
	echo "DX = $cg1DX" >> $PROCdirparll/pyplot_shiproutes.cfg
	echo "NLATS = $cg1NY" >> $PROCdirparll/pyplot_shiproutes.cfg
	echo "LL_LAT = $cg1LAT" >> $PROCdirparll/pyplot_shiproutes.cfg
	echo "DY = $cg1DY" >> $PROCdirparll/pyplot_shiproutes.cfg
	echo "NUMTIMESTEPS = ${num_hours}" >> $PROCdirparll/pyplot_shiproutes.cfg
	echo "TIMESTEP =  ${timestep}" >> $PROCdirparll/pyplot_shiproutes.cfg
	echo "" >> $PROCdirparll/pyplot_shiproutes.cfg
	echo "# For this plot we are plotting the clipped region only" >> $PROCdirparll/pyplot_shiproutes.cfg
	echo "[GRIB2CLIP]" >> $PROCdirparll/pyplot_shiproutes.cfg
	echo "DSET = ${PROCdirparll}/swancg1run_clip.grib2" >> $PROCdirparll/pyplot_shiproutes.cfg
	echo "PLOT = True" >> $PROCdirparll/pyplot_shiproutes.cfg
	LL_LON=$(echo ${current_box_lons} | awk '{ print $1 }')
	UL_LON=$(echo ${current_box_lons} | awk '{ print $2 }')
	LL_LAT=$(echo ${current_box_lats} | awk '{ print $1 }')
	UL_LAT=$(echo ${current_box_lats} | awk '{ print $2 }')
	echo "LL_LON = ${LL_LON}" >> $PROCdirparll/pyplot_shiproutes.cfg
	echo "UL_LON = ${UL_LON}" >> $PROCdirparll/pyplot_shiproutes.cfg
	echo "LL_LAT = ${LL_LAT}" >> $PROCdirparll/pyplot_shiproutes.cfg
	echo "UL_LAT = ${UL_LAT}" >> $PROCdirparll/pyplot_shiproutes.cfg
	echo "" >> $PROCdirparll/pyplot_shiproutes.cfg
	echo "# Our ship route plotting configuration" >> $PROCdirparll/pyplot_shiproutes.cfg
	echo "[SHIPROUTE]" >> $PROCdirparll/pyplot_shiproutes.cfg
	echo "DSET = ${PROCdirparll}/shiproute.bin" >> $PROCdirparll/pyplot_shiproutes.cfg
	echo "UNDEF = 9.999E+20" >> $PROCdirparll/pyplot_shiproutes.cfg
	echo "NAME = ${loc1} to ${loc2}" >> $PROCdirparll/pyplot_shiproutes.cfg
	# Remove spaces from location name use in file names
	locFName1=$(echo "${loc1}" | sed s/' '/'_'/g)
	locFName2=$(echo "${loc2}" | sed s/' '/'_'/g)
	echo "IMGFILEPREFIX = swan_${locFName1}_${locFName2}" >> $PROCdirparll/pyplot_shiproutes.cfg
	echo "STLAT = ${stlat}" >> $PROCdirparll/pyplot_shiproutes.cfg
	echo "STLON = ${stlon}" >> $PROCdirparll/pyplot_shiproutes.cfg
	echo "ENDLAT = ${endlat}" >> $PROCdirparll/pyplot_shiproutes.cfg
	echo "ENDLON = ${endlon}" >> $PROCdirparll/pyplot_shiproutes.cfg
	echo "NUMPOINTS = ${ptnum}" >> $PROCdirparll/pyplot_shiproutes.cfg
	echo "RES = ${res}" >> $PROCdirparll/pyplot_shiproutes.cfg
	DISTANCE_NM=$(printf '%.0f' ${dist})
	echo "DISTANCE_NM = ${DISTANCE_NM}" >> $PROCdirparll/pyplot_shiproutes.cfg
	echo "PLOTCURRENTS = True" >> $PROCdirparll/pyplot_shiproutes.cfg
	echo "MODEL = NWPS" >> $PROCdirparll/pyplot_shiproutes.cfg
	echo "IMGSIZE = 150" >> $PROCdirparll/pyplot_shiproutes.cfg
	echo "HOUR = ${hh}" >> $PROCdirparll/pyplot_shiproutes.cfg
	echo "DAY = ${dd}" >> $PROCdirparll/pyplot_shiproutes.cfg
	echo "MONTH = ${month}" >> $PROCdirparll/pyplot_shiproutes.cfg
	echo "YEAR = ${yyyy}" >> $PROCdirparll/pyplot_shiproutes.cfg
	#cat ${TEMPLATEDIR}/NOAA-Transparent-Logo.png > ${PROCdirparll}/NOAA-Transparent-Logo.png
	#cat ${TEMPLATEDIR}/NWS_Logo.png > ${PROCdirparll}/NWS_Logo.png
	cp ${TEMPLATEDIR}/NOAA-Transparent-Logo.png ${PROCdirparll}/NOAA-Transparent-Logo.png
	cp ${TEMPLATEDIR}/NWS_Logo.png ${PROCdirparll}/NWS_Logo.png
	#cat ${NWPSdir}/ush/python/shiproute_cur.py > ${PROCdirparll}/shiproute_cur.py
	#cat ${NWPSdir}/ush/python/shiproute.py > ${PROCdirparll}/shiproute.py
	cp -p ${NWPSdir}/ush/python/shiproute_cur.py ${PROCdirparll}/shiproute_cur.py
	cp -p ${NWPSdir}/ush/python/shiproute.py ${PROCdirparll}/shiproute.py
	cd ${PROCdir}
	#${PYTHON} ${PROCdirparll}/shiproute_cur.py ${PROCdirparll}/pyplot_shiproutes.cfg | tee -a ${DEBUGLOGfile}
	#${PYTHON} ${PROCdirparll}/shiproute.py ${PROCdirparll}/pyplot_shiproutes.cfg | tee -a ${DEBUGLOGfile}

        #echo "${PYTHON} ${PROCdirparll}/shiproute_cur.py ${PROCdirparll} pyplot_shiproutes.cfg" >> ${PROCdir}/python_shiproute_cur_elements.sh
        echo "${PROCdirparll}/shiproute_cur.py ${PROCdirparll} pyplot_shiproutes.cfg; ${PROCdirparll}/shiproute.py ${PROCdirparll} pyplot_shiproutes.cfg" >> ${PROCdir}/python_shiproute_elements.sh
        echo "${PROCdirparll}/shiproute_cur.py ${PROCdirparll} pyplot_shiproutes.cfg; ${PROCdirparll}/shiproute.py ${PROCdirparll} pyplot_shiproutes.cfg" >> ${TEMPDIR}/python_grib2_elements.sh

# End of config line read	
    fi
done < ${CFGFILE}

#echo "Executing ${PROCdir}/python_shiproute_cur_elements.sh for ${rtnum} transects"
#aprun -n${rtnum} -N${rtnum} -j1 -d1 cfp ${PROCdir}/python_shiproute_cur_elements.sh

#echo "Executing ${PROCdir}/python_shiproute_elements.sh for ${rtnum} transects"
#aprun -n${rtnum} -N${rtnum} -j1 -d1 cfp ${PROCdir}/python_shiproute_elements.sh

exit 0

echo "INFO - Cleaning previous ship route plots from ${GRAPHICOUTPUTdir}" >> ${DEBUGLOGfile} 2>&1
while read line
do
    DATLINE=$(echo $line | grep -v "^#")
    if [ "${DATLINE}" != "" ] 
    then
	loc1=$(echo "${DATLINE}" | awk -F, '{ print $1 }')
	loc2=$(echo "${DATLINE}" | awk -F, '{ print $4 }')
	locFName1=$(echo "${loc1}" | sed s/' '/'_'/g)
	locFName2=$(echo "${loc2}" | sed s/' '/'_'/g)
	find ${GRAPHICOUTPUTdir} -name "*locFName1_locFName2*.png" -print | xargs rm -vf  >> ${DEBUGLOGfile} 2>&1
    fi
done < ${CFGFILE}

echo "Publishing results" | tee -a ${LOGFILE}
cp -pfv ${PROCdir}/route*/swan*hr*.png  ${GRAPHICOUTPUTdir}/. >> ${DEBUGLOGfile} 2>&1
chmod 777 ${GRAPHICOUTPUTdir}/swan*hr*.png
figsTarFile="shiproute_plots_CG1_${yyyy}${mon}${dd}${hh}.tar.gz"
cd ${GRAPHICOUTPUTdir}
tar cvfz ${figsTarFile} *.png >> ${DEBUGLOGfile} 2>&1

cycleout=$(awk '{print $1;}' ${RUNdir}/CYCLE)
COMOUTCYC="${COMOUT}/${cycleout}/CG1"
mkdir -p $COMOUTCYC
cp -fpv ${figsTarFile} $COMOUTCYC/${figsTarFile} >> ${DEBUGLOGfile} 2>&1

echo "Cleaning ${PROCdir} directory" >> ${DEBUGLOGfile} 2>&1
#AW20191121 find ${PROCdir} -name "*.png" -print | xargs rm -fv >> ${DEBUGLOGfile} 2>&1

echo "Ship route plotting complete for ${SITEID}" | tee -a ${LOGFILE}
date -u | tee -a ${LOGFILE}
date +%s > ${PROCdir}/end_secs.txt

START=$(cat ${PROCdir}/start_secs.txt)
FINISH=$(cat ${PROCdir}/end_secs.txt)
PROCNAME="Ship route plotting for ${siteid}"
calc_runtime ${START} ${FINISH} "${PROCNAME}"| tee -a ${LOGFILE}

exit 0
# -----------------------------------------------------------
# *******************************
# ********* End of File *********
# *******************************

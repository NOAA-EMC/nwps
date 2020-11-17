#!/bin/bash
# ----------------------------------------------------------- 
# UNIX Shell Script
# Tested Operating System(s): RHEL 5
# Tested Run Level(s): 3, 5
# Shell Used: BASH shell
# Original Author(s): Douglas.Gaer@noaa.gov, Andre.VanderWesthuysen@noaa.gov
# File Creation Date: 12/10/2009
# Date Last Modified: 04/30/2015
#
# Version control: 2.02
#
# Support Team:
#
# Contributors:
# ----------------------------------------------------------- 
# ------------- Program Description and Details ------------- 
# ----------------------------------------------------------- 
#
# PYTHON processing script used to create test images
# for NWPS model.
#
# This script is used to plot the GRIB2 model output.
#
# ----------------------------------------------------------- 

# Check to see if our NWPS env is set
if [ "${NWPSenvset}" == "" ]
then 
    if [ -e ${USHnwps}/nwps_config.sh ]
    then
	source ${USHnwps}/nwps_config.sh
    else
	echo "ERROR - Cannot find ${USHnwps}/nwps_config.sh"
	export err=1; err_chk
    fi
fi

# The SITE ID is set in NWPS config but can be specified on the command line
if [ "$1" != "" ]; then SITEID="$1"; fi

if [ "${SITEID}" == "" ]
    then
    SITEID="default"
fi
SITEID=$(echo ${SITEID} | tr [:upper:] [:lower:])

echo " +==================== 1 1 1 plot_nwps_run_from_grib2.sh ======================"
echo "CGNUMPLOT= ${CGNUMPLOT}"
echo " +======================================================================="


# Check for hotstart
HASHOTSTART=$(cat ${RUNdir}/hotstart.flag)
if [ "${HASHOTSTART}" == "" ]; then HASHOTSTART="FALSE"; fi

echo "Starting Python plotting script for NWPS grib2 output file"
if [ "${HASHOTSTART}" == "TRUE" ] 
then
    echo "HOTSTART was used for this run, will include hours 0-12"
else
    echo "HOTSTART was not used for this run, will skip hours 0-12"
fi

# Check which water level source was used
export tst1=$(grep .wlev ${RUNdir}/inputCG1 | grep psurge | cut -c 1-7)
export tst2=$(grep .wlev ${RUNdir}/inputCG1 | cut -c 1-7)
echo $tst1
echo $tst2
if [ "${tst1}" != "" ]
   then
   export WATERLEVELS='PSURGE'
   source ${RUNdir}/PEXCD
elif [ "${tst2}" != "" ]
   then
   export WATERLEVELS='ESTOFS'
else
   export WATERLEVELS='NO'
fi
echo $WATERLEVELS
echo $EXCD

echo "This script should only be ran following the completion of your last successful run"
echo "SITE ID: ${SITEID}"

PYTHON=python

ETCdir="${NWPSdir}/ush/python/etc"
PYPdir="${NWPSdir}/ush/python"
FIGOUTPUTdir="${OUTPUTdir}/figures"
PLOT_templdir=${DATA}/plot/templates
#if [ ! -e ${PYPdir} ]; then mkdir -p ${PYPdir}; fi
#if [ ! -e ${ETCdir} ]; then mkdir -p ${ETCdir}; fi
#if [ ! -e ${VARdir} ]; then mkdir -p ${VARdir}; fi
#if [ ! -e ${LOGdir} ]; then mkdir -p ${LOGdir}; fi
if [ ! -e ${FIGOUTPUTdir} ]; then mkdir -p ${FIGOUTPUTdir}; fi
if [ ! -e ${PLOT_templdir} ]; then mkdir -p ${PLOT_templdir}; fi
echo $$ > ${TMPdir}/${USERNAME}/nwps/7790_plot_nwps_run_from_grib2_sh.pid

# Read our SWAN configuration for this run
export NESTS="NO"
hasnest=$(cat ${RUNdir}/nests.flag)
if [ "${hasnest}" == "TRUE" ]; then export NESTS="YES"; fi
SWANPARMS=`perl -I${NWPSdir}/ush/bin -I${RUNdir} ${PYPdir}/get_swan_config_parms.pl`

# Process all CGs
for parm in ${SWANPARMS}
  do
  CGNUM=$(echo ${parm} | awk -F, '{ print $1 }' | cut -b3)
  echo " +==================== plot_nwps_run_from_grib2.sh ======================"
  echo "CGNUMPLOT= ${CGNUMPLOT}"
  echo "CGNUM= ${CGNUM}"


  SITEID=$(echo ${SITEID} | tr [:upper:] [:lower:])
  if [ "${CGNUM}" -ne "${CGNUMPLOT}" ]
    then
     continue
  fi  
  LENGTHTIMESTEP=$(echo ${parm} | awk -F, '{ print $2 }')
  SWANFCSTLENGTH=$(echo ${parm} | awk -F, '{ print $3 }')
  NORTHEASTLAT=$(echo ${parm} | awk -F, '{ print $4 }' | awk -F: '{ print $2 }')
  NORTHEASTLON=$(echo ${parm} | awk -F, '{ print $5 }' | awk -F: '{ print $2 }')
  NUMMESHESLAT=$(echo ${parm} | awk -F, '{ print $6 }' | awk -F: '{ print $2 }')
  NUMMESHESLON=$(echo ${parm} | awk -F, '{ print $7 }' | awk -F: '{ print $2 }')
  SOUTHWESTLAT=$(echo ${parm} | awk -F, '{ print $8 }' | awk -F: '{ print $2 }')
  SOUTHWESTLON=$(echo ${parm} | awk -F, '{ print $9 }' | awk -F: '{ print $2 }')
  USEWIND=$(echo ${parm} | awk -F, '{ print $10 }') 
  GRAPHICOUTPUTDIRECTORY="${OUTPUTdir}/grib2/CG${CGNUM}"
  OUTPUTDATATYPES=$(echo ${parm} | awk -F, '{ print $12 }' | sed s'/|/ /'g)
  VARS=$(echo ${parm} | awk -F, '{ print $13 }')

  echo "Processing CG${CGNUM}"
  echo "LENGTHTIMESTEP = ${LENGTHTIMESTEP}"
  echo "SWANFCSTLENGTH = ${SWANFCSTLENGTH}"
  echo "NORTHEASTLAT = ${NORTHEASTLAT}"
  echo "NORTHEASTLON = ${NORTHEASTLON}"
  echo "NUMMESHESLAT = ${NUMMESHESLAT}"
  echo "NUMMESHESLON = ${NUMMESHESLON}"
  echo "SOUTHWESTLAT = ${SOUTHWESTLAT}"
  echo "SOUTHWESTLON = ${SOUTHWESTLON}"
  echo "USEWIND = ${USEWIND}"
  echo "GRAPHICOUTPUTDIRECTORY = ${GRAPHICOUTPUTDIRECTORY}"

  NSD=$(echo "scale=2; ${NORTHEASTLAT}-${SOUTHWESTLAT}" | bc)
  NSR=$(echo "scale=10; ${NSD}/${NUMMESHESLAT}" | bc)
  echo "NORTH-SOUTH DEGREES = $NSD"
  echo "NORTH-SOUTH RESOLUTION = $NSR"
  SOUTHWESTLON=$(echo ${SOUTHWESTLON} | sed s'/-//'g)
  NORTHEASTLON=$(echo ${NORTHEASTLON} | sed s'/-//'g)
  EWD=$(echo "scale=2; ${SOUTHWESTLON}-${NORTHEASTLON}" | bc)
  EWR=$(echo "scale=10; ${EWD}/${NUMMESHESLON}" | bc)
  echo "EAST-WEST DEGREES = $EWD"
  echo "EAST-WEST RESOLUTION = $EWR"
  echo "OUTPUTDATATYPES = ${OUTPUTDATATYPES}"
  echo "VARS = $VARS"

  SITEID=$(echo ${SITEID} | tr [:upper:] [:lower:])

  files=$(ls -1t ${GRAPHICOUTPUTDIRECTORY}/???_nwps_CG?_????????_????.grib2)
  file=$(echo ${files} | awk '{ print $1 }')
  if [ CG"${CGNUMPLOT}" == "${RIPDOMAIN}" ] || [ CG"${CGNUMPLOT}" == "${RUNUPDOMAIN}" ]
  then
     files_riprunup=$(ls -1t ${GRAPHICOUTPUTDIRECTORY}/???_nwps_CG?_????????_????.grib2)
     file_riprunup=$(echo ${files_riprunup} | awk '{ print $1 }')
  fi
  TEMPDIR=${VARdir}/${SITEID}.tmp/CG${CGNUM}
  mkdir -p ${TEMPDIR}
  echo "Writing all temp files to ${TEMPDIR}"

  GRAPHICSdir="${FIGOUTPUTdir}/${SITEID}/CG${CGNUM}"
  mkdir -p ${GRAPHICSdir}

  # Lets clean any old graphics
  find ${TEMPDIR} -name "*.png" -print | xargs rm -f
  find ${GRAPHICSdir} -name "*.png" -print | xargs rm -f

  #echo "Copying ${GRAPHICOUTPUTDIRECTORY}/${file} grib2 file for processing"
  #cp -f ${GRAPHICOUTPUTDIRECTORY}/${file} ${TEMPDIR}/swan.grib2
  echo "Copying ${file} grib2 file for processing"
  cp -f ${file} ${TEMPDIR}/swan.grib2
  if [ CG"${CGNUMPLOT}" == "${RIPDOMAIN}" ] || [ CG"${CGNUMPLOT}" == "${RUNUPDOMAIN}" ]
  then
     echo "Copying ${file_riprunup} grib2 file for processing"
     cp -f ${file_riprunup} ${TEMPDIR}/swan_riprunup.grib2
  fi

  if [ ! -e "${ETCdir}/default" ]
  then
     echo "ERROR - Missing ${ETCdir}/default directory"
     echo "Will not be able to create graphics"
    export err=1; err_chk
  fi
  echo "WARNING - No PYTHON plotting templates found for ${SITEID}"
  echo "Building a default set for ${SITEID}"
  #mkdir -p ${ETCdir}/${SITEID}
  #cp -f ${ETCdir}/default/*.* ${ETCdir}/${SITEID}/.

  cp -f ${ETCdir}/default/* ${PLOT_templdir}
  echo "Checking for default templates in ${PLOT_templdir}"
  curpwd=$(pwd)
  cd ${ETCdir}/default
  templates=$(ls -1t --color=none *.*)
  #cd ${ETCdir}/${SITEID}
  cd ${PLOT_templdir}
  for f in ${templates}
  do
      if [ ! -e ${f} ]; then cp -fpv ${ETCdir}/default/${f} ${PLOT_templdir}/${f}; fi
  done
  echo "Template update complete"

  echo "Creating run-time PYTHON files from ${PYPdir}/*.py files"
  echo "This will not overwrite your site template file"
  cp -f ${PYPdir}/* ${TEMPDIR}/.

  # AG 11/27/2011: This script will adjust all color scales from latest run.
  #echo ""
  #echo "Updating colorscales based on the latest swan.grib2 data"
  #echo ""
  #${PYPdir}/fix_colorscales.sh ${CGNUM}

  # Create SITE and RUN specific GS files
  # Out time and run length will vary with each model run
  sed -i "s/<!-- SET TIMESTEP HERE -->/t2=t1*${LENGTHTIMESTEP}-${LENGTHTIMESTEP}/g" ${TEMPDIR}/*.py

  

  echo "Copying LOGO from ${ETCdir}/default/*.gif files"
  cp -f ${ETCdir}/default/*.gif ${TEMPDIR}/.
    cp -f ${ETCdir}/default/*.png ${TEMPDIR}/.
  #echo "Unpacking shape files for plotting"
  cd ${TEMPDIR}
  #tar xvfz ${SHAPEFILEdb}/marine_zones.tar.gz
  #tar xvfz ${SHAPEFILEdb}/cwa.tar.gz
  #tar xvfz ${SHAPEFILEdb}/river_basins.tar.gz
  #tar xvfz ${SHAPEFILEdb}/lakes.tar.gz
  #tar xvfz ${SHAPEFILEdb}/rivers.tar.gz
  #tar xvfz ${SHAPEFILEdb}/zones.tar.gz

  echo "Creating GRADS control file, used by Python"
  echo "${YYYY}${MM}${DD}_${HH}${MIN}" > ${TEMPDIR}/datelab.txt
  cat /dev/null > ${TEMPDIR}/swan.ctl
  if [ CG"${CGNUMPLOT}" == "${RIPDOMAIN}" ] || [ CG"${CGNUMPLOT}" == "${RUNUPDOMAIN}" ]
  then
     cat /dev/null > ${TEMPDIR}/swan_riprunup.ctl
  fi
  
  echo "Creating PYTHON graphics for $file"
  
  ftimes=$(${WGRIB2} ${TEMPDIR}/swan.grib2 | awk -F: '{ print $3 }' | awk -F= '{ print $2 }')
  for i in $ftimes
  do
      ftime=$i
      break
  done

  # Example file name: 20100120_1200
  YYYY=$(echo ${ftime} | cut -b1-4)
  MM=$(echo ${ftime} | cut -b5-6)
  DD=$(echo ${ftime} | cut -b7-8)
  HH=$(echo ${ftime} | cut -b9-10) 
  MIN="00"
  
  time_str="${YYYY} ${MM} ${DD} ${HH} ${MIN} 00"
  epoch_time=$(echo ${time_str} | awk -F: '{ print mktime($1 $2 $3 $4 $5 $6) }')
  month=$(echo ${epoch_time} | awk '{ print strftime("%b", $1) }' | tr [:upper:] [:lower:])
  
  DSET="${file}"
  DTYPE="grib2"
  TITLE="SWAN CG${CGNUM} Control File"
  UNDEF="9.999E+20"
  XDEF=$(echo "scale=0; ${NUMMESHESLON}+1" | bc)
  XDEF=$(echo "$XDEF linear -$SOUTHWESTLON $EWR") 
  YDEF=$(echo "scale=0; ${NUMMESHESLAT}+1" | bc)
  YDEF=$(echo "$YDEF linear $SOUTHWESTLAT $NSR") 
  
  # There is only one vertical level (the surface)
  ZDEF="1 levels 1 1"
  TDEF=$(echo "scale=0; (${SWANFCSTLENGTH}/${LENGTHTIMESTEP})+1" | bc)
  TDEF=$(echo "${TDEF} linear ${HH}z${DD}${month}${YYYY} ${LENGTHTIMESTEP}hr")
  VARS="${VARS}"

  echo "DSET swan.grib2" >> ${TEMPDIR}/swan.ctl
  echo "index swan.idx" >> ${TEMPDIR}/swan.ctl
  echo "DTYPE ${DTYPE}" >> ${TEMPDIR}/swan.ctl
  echo "TITLE ${TITLE}" >> ${TEMPDIR}/swan.ctl
  echo "UNDEF ${UNDEF}" >> ${TEMPDIR}/swan.ctl
  echo "XDEF ${XDEF}" >> ${TEMPDIR}/swan.ctl
  echo "YDEF ${YDEF}" >> ${TEMPDIR}/swan.ctl
  echo "ZDEF ${ZDEF}" >> ${TEMPDIR}/swan.ctl
  echo "TDEF ${TDEF}" >> ${TEMPDIR}/swan.ctl
  echo "VARS 11" >> ${TEMPDIR}/swan.ctl
  echo "HTSGWsfc=>htsgw        0,1,0   10,0,3 ** surface Significant Height of Combined Wind Waves and Swell [m]" >> ${TEMPDIR}/swan.ctl
  echo "DIRPWsfc=>wavedir      0,1,0   10,0,10 ** surface Primary Wave Direction [deg]" >> ${TEMPDIR}/swan.ctl
  echo "PERPWsfc=>waveper      0,1,0   10,0,11 ** surface Primary Wave Mean Period [s]" >> ${TEMPDIR}/swan.ctl
  echo "DBSSsfc=>depth         0,1,0   10,4,195 ** surface Geometric Depth Below Sea Surface [m]" >> ${TEMPDIR}/swan.ctl
  echo "SWELLsfc=>swell        0,1,0   10,0,8 ** surface Significant Height of Swell Waves [m]" >> ${TEMPDIR}/swan.ctl
  echo "WDIRsfc=>wnddir        0,1,0   0,2,0 ** surface Wind Direction (from which blowing) [deg]" >> ${TEMPDIR}/swan.ctl
  echo "WINDsfc=>wndspdms      0,1,0   0,2,1 ** surface Wind Speed [m/s]" >> ${TEMPDIR}/swan.ctl
  echo "DSLMsfc=>wlevel        0,1,0   10,3,1 ** surface Deviation of Sea Level from Mean [m]" >> ${TEMPDIR}/swan.ctl
  echo "DIRCsfc=>curdir        0,1,0   10,1,0 ** surface Current Direction [deg]" >> ${TEMPDIR}/swan.ctl
  echo "SPCsfc=>curspdms       0,1,0   10,1,1 ** surface Current Speed [m/s]" >> ${TEMPDIR}/swan.ctl
  # TODO: Need GRIB2 definition from WMO for wave length
  echo "var10255255sfc=>wlen   0,1,0   10,255,255 ** surface mean wave length (m)" >> ${TEMPDIR}/swan.ctl
  echo "ENDVARS" >> ${TEMPDIR}/swan.ctl

  #AW052917 Write a separate control file for runup and rips until we can pack then into same grib2 file
  if [ CG"${CGNUMPLOT}" == "${RIPDOMAIN}" ] || [ CG"${CGNUMPLOT}" == "${RUNUPDOMAIN}" ]
  then
     echo "DSET swan_riprunup.grib2" >> ${TEMPDIR}/swan_riprunup.ctl
     echo "index swan.idx" >> ${TEMPDIR}/swan_riprunup.ctl
     echo "DTYPE ${DTYPE}" >> ${TEMPDIR}/swan_riprunup.ctl
     echo "TITLE ${TITLE}" >> ${TEMPDIR}/swan_riprunup.ctl
     echo "UNDEF ${UNDEF}" >> ${TEMPDIR}/swan_riprunup.ctl
     echo "XDEF ${XDEF}" >> ${TEMPDIR}/swan_riprunup.ctl
     echo "YDEF ${YDEF}" >> ${TEMPDIR}/swan_riprunup.ctl
     echo "ZDEF ${ZDEF}" >> ${TEMPDIR}/swan_riprunup.ctl
     echo "TDEF ${TDEF}" >> ${TEMPDIR}/swan_riprunup.ctl
     echo "VARS 11" >> ${TEMPDIR}/swan_riprunup.ctl
     echo "EROSIONsfc=>htsgw        0,1,0   10,2,3 ** surface Erosion probability [%]" >> ${TEMPDIR}/swan_riprunup.ctl
     echo "OWASHsfc=>wavedir        0,1,0   10,2,3 ** surface Overwash probability [%]" >> ${TEMPDIR}/swan_riprunup.ctl
     echo "RIPsfc=>waveper          0,1,0   10,2,3 ** surface Rip current probability [%]" >> ${TEMPDIR}/swan_riprunup.ctl
     echo "ENDVARS" >> ${TEMPDIR}/swan_riprunup.ctl
  fi

  cd ${TEMPDIR}

  #echo "Creating GRIB2 index map"
  #${GRIBMAP} -v -i swan.ctl

  # NOTE: If you change the default Python directory you will need to 
  # NOTE: change or remake all ${NWPSdir}/ush/python/etc/siteid/python_elements.sh
  # NOTE: files PYTHON variable is when we source ${NWPSdir}/utils/etc/nwps_config.sh
#  if [ ! -e "${TEMPDIR}/python_grib2_elements.sh" ]
#      then 
#      echo "WARNING - No site specific python grib2_element file"
#      echo "Will plot all elements by default"
      echo "Creating new site specific python element file for GRIB2 plot"
      #cat /dev/null > ${TEMPDIR}/python_grib2_elements.sh
      echo "${PYTHON} wind.py 1 16" >> ${TEMPDIR}/python_grib2_elements.sh
      echo "${PYTHON} wind.py 17 32" >> ${TEMPDIR}/python_grib2_elements.sh
      echo "${PYTHON} wind.py 33 49" >> ${TEMPDIR}/python_grib2_elements.sh
      #AW echo "${PYTHON} depth.py" >> ${TEMPDIR}/python_grib2_elements.sh
      echo "${PYTHON} htsgw.py 1 16" >> ${TEMPDIR}/python_grib2_elements.sh
      echo "${PYTHON} htsgw.py 17 32" >> ${TEMPDIR}/python_grib2_elements.sh
      echo "${PYTHON} htsgw.py 33 49" >> ${TEMPDIR}/python_grib2_elements.sh
      echo "${PYTHON} period.py 1 16" >> ${TEMPDIR}/python_grib2_elements.sh
      echo "${PYTHON} period.py 17 32" >> ${TEMPDIR}/python_grib2_elements.sh
      echo "${PYTHON} period.py 33 49" >> ${TEMPDIR}/python_grib2_elements.sh
      #AW echo "${PYTHON} wlen.py" >> ${TEMPDIR}/python_grib2_elements.sh
      echo "${PYTHON} cur.py 1 16" >> ${TEMPDIR}/python_grib2_elements.sh
      echo "${PYTHON} cur.py 17 32" >> ${TEMPDIR}/python_grib2_elements.sh
      echo "${PYTHON} cur.py 33 49" >> ${TEMPDIR}/python_grib2_elements.sh
      echo "${PYTHON} wlev.py 1 25" >> ${TEMPDIR}/python_grib2_elements.sh
      echo "${PYTHON} wlev.py 26 49" >> ${TEMPDIR}/python_grib2_elements.sh
      echo "${PYTHON} swell.py 1 25" >> ${TEMPDIR}/python_grib2_elements.sh
      echo "${PYTHON} swell.py 26 49" >> ${TEMPDIR}/python_grib2_elements.sh
      if [ "${RIPPROG}" == "1" ] && [ CG"${CGNUMPLOT}" == "${RIPDOMAIN}" ]
      then
         # Reduce parallelization for WFOs for which ship routes also need to be computed
         if [ "${SITEID}" == "mfl" ] || [ "${SITEID}" == "key" ] || [ "${SITEID}" == "akq" ]
         then
            echo "${PYTHON} rip.py 1 49" >> ${TEMPDIR}/python_grib2_elements.sh
         else
            echo "${PYTHON} rip.py 1 25" >> ${TEMPDIR}/python_grib2_elements.sh
            echo "${PYTHON} rip.py 26 49" >> ${TEMPDIR}/python_grib2_elements.sh
         fi
      fi
      if [ "${RUNUPPROG}" == "1" ] && [ CG"${CGNUMPLOT}" == "${RUNUPDOMAIN}" ]
      then
         if [ "${SITEID}" == "mfl" ] || [ "${SITEID}" == "key" ] || [ "${SITEID}" == "akq" ]
         then
            echo "${PYTHON} erosion.py 1 49" >> ${TEMPDIR}/python_grib2_elements.sh
            echo "${PYTHON} owash.py 1 49" >> ${TEMPDIR}/python_grib2_elements.sh
         else
            echo "${PYTHON} erosion.py 1 25" >> ${TEMPDIR}/python_grib2_elements.sh
            echo "${PYTHON} erosion.py 26 49" >> ${TEMPDIR}/python_grib2_elements.sh
            echo "${PYTHON} owash.py 1 25" >> ${TEMPDIR}/python_grib2_elements.sh
            echo "${PYTHON} owash.py 26 49" >> ${TEMPDIR}/python_grib2_elements.sh
         fi
      fi
#      echo '##echo "Creating PYTHON plot for Specific Locations"' >> ${TEMPDIR}/python_grib2_elements.sh
#      echo "##${PYTHON} graph-dvd.py" >> ${TEMPDIR}/python_grib2_elements.sh
#  fi

  echo "Executing ${TEMPDIR}/python_grib2_elements.sh"
  if [ "${CGNUM}" -eq "1" ]
     then
     njobs=`wc -l ${TEMPDIR}/python_grib2_elements.sh | cut -c1-2`
     echo "Executing ${njobs} plotting jobs using cfp"
     aprun -n${njobs} -N${njobs} -j1 -d1 cfp ${TEMPDIR}/python_grib2_elements.sh
     export err=$?; err_chk
  elif [ "${SITEID}" == "alu" ] || [ "${SITEID}" == "aer" ] || [ "${SITEID}" == "ajk" ]
     then
     echo "Executing plotting jobs in serial"
     bash ${TEMPDIR}/python_grib2_elements.sh
     export err=$?; err_chk
  else
     #AW echo "Executing plotting jobs in serial"
     #AW bash ${TEMPDIR}/python_grib2_elements.sh
     #AW export err=$?; err_chk
     echo "*** Not creating plots for CG2-5: Plotting jobs now done externally"
  fi

#  if [ "${CGNUM}" -eq "1" ]
#     then
#     echo "Copying PNG images to ${GRAPHICSdir}"
#     if [ "${HASHOTSTART}" == "TRUE" ]
#     then 
#         echo "HOTSTART was used for this run, keeping hours 0-9 for CG${CGNUM}"
#     else
#         echo "No HOTSTART was used for this run, removing hours 0-9 for CG${CGNUM}."
###         rm -vf *hr00[0-9].png
#     fi
#
#     rm *logo* *Logo*
#     cp -vpf *.png ${GRAPHICSdir}/.
#     chmod 777 ${GRAPHICSdir}/*.png
#     cd ${GRAPHICSdir}
##     Spectra plots (if any) must be in ${GRAPHICSdir} already
##     AW010620: Spectra plots no longer produced, so copy command deactivated.
#     figsTarFile="plots_CG${CGNUM}_${YYYY}${MM}${DD}${HH}.tar.gz"
#     #cp ${FIGOUTPUTdir}/${SITEID}/spectra/CG${CGNUM}/*.png .
#
#     tar cvfz ${figsTarFile} *.png
#     cycleout=$(awk '{print $1;}' ${RUNdir}/CYCLE)
#     COMOUTCYC="${COMOUT}/${cycleout}/CG${CGNUM}"
#     mkdir -p $COMOUTCYC
#     cp ${figsTarFile} $COMOUTCYC/${figsTarFile}
#  fi
done


echo "NWPS grib2 output plots can be viewed at: ${GRAPHICSdir}"

exit 0
# ----------------------------------------------------------- 
# ******************************* 
# ********* End of File ********* 
# ******************************* 

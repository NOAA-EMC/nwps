#!/bin/bash
# -----------------------------------------------------------
# UNIX Shell Script
# Tested Operating System(s): RHEL 5/6
# Shell Used: BASH shell
# Original Author(s): WFO MHX: Donnie King, Greg Dusek and Scott Kennedy
# File Creation Date: 7/1/2013
# Date Last Modified: 12/10/2013
#
# Version control: 1.00
#
# Support Team:
#
# Contributors: alex.gibbs@noaa.gov Roberto.Padilla@noaa.gov
#
# -----------------------------------------------------------
# ------------- Program Description and Details -------------
# -----------------------------------------------------------
#
# This program assumes the contour fields within NWPS 
# have been installed in the $NWPSdir/bin/RunSwan.pm. If not, view 
# the online documentation for further instructions at:
# 
# innovation.srh.noaa.gov/nwps/nwpsmanual.php/rip_current_program
#
# To execute:                                ARG1 ARG2
# $NWPSdir/bin/rip_current_program/run_nos.sh CG2 5
#
# Arguments=2:
#
# 1. Grid that you are extracting data along contours from. (ie CG2)
# 2. contour: 5 (for 5m contour)
# -----------------------------------------------------------


if [ "${SITEID}" == "" ]
    then
    echo "ERROR - Your SITEID variable is not set"
    export err=1; err_chk
fi

if [ "${NWPSdir}" == "" ]
    then 
    echo "ERROR - Your NWPSdir variable is not set"
    export err=1; err_chk
fi

if [ -e ${USHnwps}/nwps_config.sh ]
then
    source ${USHnwps}/nwps_config.sh
else
    echo "ERROR - Cannot find ${USHnwps}/nwps_config.sh"
    export err=1; err_chk
fi

if [ "$1" != "" ]; then CGnumber="$1"; fi

if [ "${CGnumber}" == "" ]
    then
    msg="FATAL ERROR: Rip current program: No CGNUM was specified. Minimum usage is run_nos.sh [CGnumber] [Contour]"
    postmsg $jlogfile "$msg"
    export err=1; err_chk
fi
echo "++++++++++++ IN RUN_NOS.SH++++++++++++++++++"
echo "CGnumber: ${CGnumber}"
echo "++++++++++++++++++++++++++++++++++++++++++++"

CGnumber=$(echo ${CGnumber} | tr [:lower:] [:upper:])

if [ "$2" != "" ]; then contour="$2"; fi

if [ "${contour}" == "" ]
    then
    msg="FATAL ERROR: Rip current program: No contour was specified. Minimum usage is run_nos.sh [CGnumber] [Contour]"
    postmsg $jlogfile "$msg"
    export err=1; err_chk
fi

echo "Platform is: $NWPSplatform"

if [ $NWPSplatform == "SRSWAN" ]
then
  NWPSDATA="${NWPSSRSWANDATA}"
elif [ $NWPSplatform == "DEV" ]
then
  NWPSDATA="${NWPSDEVDATA}"
elif [ $NWPSplatform == "IFPSWAN" ]
then
  NWPSDATA="${NWPSIFPSWANDATA}"
elif [ $NWPSplatform == "WCOSS" ] || [ $NWPSplatform == "DEVWCOSS" ]
then
  NWPSDATA="${DATA}"
fi

echo "NWPSDATA is: $NWPSDATA"

if [ -e ${NWPSDATA}/logs/runrip.log ]
   then
   rm -f ${NWPSDATA}/logs/runrip.log
fi

cat /dev/null > ${NWPSDATA}/logs/runrip.log

#____________________________________________________________________

{
# Get rid of old netCDF and rip data:
#yyyy=$(date +%Y)
#cd ${NWPSDATA}/output/netCdf/${CGnumber} && ls -t1 ${yyyy}* | tail -n +2 | xargs rm -r
#rm ${NWPSDATA}/var/${siteid}.tmp/${CGnumber}/rip*
#rm ${NWPSDATA}/output/rip_current/data/${contour}m/rip.nc
#rm ${NWPSDATA}/output/rip_current/data/${contour}m/*.ctl
#rm ${NWPSDATA}/output/netCdf/rip_current/data/${contour}m/*.ctl

# Find newest GRIB2 output file to process
ls -lt ${NWPSDATA}/output/grib2/${CGnumber}
gribfile=$(ls ${NWPSDATA}/output/grib2/${CGnumber}/*${CGnumber}*grib2 | xargs -n 1 basename | tail -n 1)
cycle=`echo $gribfile | cut -c23-26`
cutcycle=`echo $gribfile | cut -c23-24`
windfile=`echo $gribfile | cut -c14-21`
fullname=`echo $gribfile | cut -c14-26`

#CG=${contour}m_${CGnumber}_"$cutcycle"_"$windfile"_prob.txt_${SITEID}
CGCONT=${contour}m_contour_${CGnumber}."$fullname"_${SITEID}

echo "" 
echo "_________________________________________________________________"
echo "                           Rip Current Program                   "
echo "                                                                 "
echo "SITE:     ${SITEID}"
echo "DOMAIN:   ${CGnumber}"
echo "CONTOUR:  ${contour}m"
echo "CYCLE:    ${fullname}"
echo ""
echo "_________________________________________________________________"

######################################################
# Create Working Directory and configure program within NWPS

RIPdir="${NWPSDATA}/output/rip_current/data/${contour}m"
if [ ! -e ${RIPdir} ]; then mkdir -vp ${RIPdir}; fi
#cp ${NWPSdir}/ush/rip_current_program/finddate.sh ${RIPdir}
cp ${FIXnwps}/beach_orient_db/${contour}m_RipForecastShoreline_${SITEID}.txt ${RIPdir}/RipForecastShoreline.txt
#cp $NWPSdir/ush/rip_current_program/plot_rip_probs.sh ${RUNdir}/.

# fetch contour files in the run directory from NWPS
cp ${NWPSDATA}/run/${contour}m_contour_${CGnumber} ${RIPdir}/${contour}m_contour_${CGnumber}"."$windfile"_"$cycle"_${SITEID}"

# Run the Rip Current Model
pwd
${NWPSdir}/ush/rip_current_program/run_rip.sh $cutcycle $windfile ${CGnumber}

FORT23="${WFO}_${NET}_${contour}m_${CGnumber}_ripprob.${fullname}"

#fileout=$CG
cycleout=$(awk '{print $1;}' ${RUNdir}/CYCLE)
COMOUTCYC="${COMOUT}/${cycleout}/${CGnumber}"
mkdir -p $COMOUTCYC
cp -fv  ${RIPdir}/${CGCONT} ${COMOUTCYC}/${CGCOUNT}
cp -fv  ${RIPdir}/${FORT23} ${COMOUTCYC}/${FORT23}

mkdir -p $GESOUT/riphist/${SITEID}
cp -fv  ${RIPdir}/${CGCONT} ${GESOUT}/riphist/${SITEID}/${CGCOUNT}

# Create GrADS plots
#NOT ANY MORE
#cp $NWPSdir/bin/rip_current_program/plot_rip_probs.sh ${RUNdir}/.
#cp $NWPSdir/bin/rip_current_program/final_netcdf_template ${RIPdir}
#cp $NWPSdir/bin/rip_current_program/rip_plot.gs ${NWPSDATA}/var/${siteid}.tmp/${CGnumber}

## Note: These 2 PNGs will reflect an example final Graphic in the GrADS plot (recommend creating a 
## PNG of your CG Bathy plot specifying or describing the Geo location of where you are 
## providing probabilities for. To view an example...view the cg2bathy.PNG below.

## This ripmodel.PNG is a simple default graphic of the actual 3D Rip Current Model:
#cp $NWPSdir/bin/rip_current_program/ripmodel.PNG ${NWPSDATA}/var/${siteid}.tmp/${CGnumber}
## This cg2bathy.PNG is an example of a bathy plot from the Miami CG2
#cp $NWPSdir/bin/rip_current_program/cg2bathy.PNG ${NWPSDATA}/var/${siteid}.tmp/${CGnumber}

echo "These files will be transmitted to NOS:
$CG
$CGCONT"

##### Now ftp to NOS #################
#HOST=140.90.78.212
#USER=anonymous
#PASS=\r
#ftp -inv $HOST  << EOF
#user $USER $PASS
#cd pub/incoming/NWS
#lcd ${RIPdir}
#put "$CG" 
#put "$CGCONT"
#bye
#EOF

#________________________________________________________________________________
# Finalize by extracting the necessary data out of the *prob* file into a netCDF
# file. From there the final GrADS plot will be created and dropped in you 
# grads directory.
#________________________________________________________________________________

#echo ""  
#echo "Configure netCDF and GrADS control files:" 
#echo "" 

#$${RUNdir}/plot_rip_probs.sh ${SITEID} ${CGnumber} ${contour}m ${cutcycle} 

#cp ${RIPdir}/rip.nc ${NWPSDATA}/var/${siteid}.tmp/${CGnumber}
#cp ${RIPdir}/ripprob.ctl ${NWPSDATA}/var/${siteid}.tmp/${CGnumber}
#cd ${NWPSDATA}/var/${siteid}.tmp/${CGnumber}/

# create plot and clean working data directory: 
#${NWPSdir}/lib${ARCHBITS}/grads/bin/grads -blc ${NWPSDATA}/var/${siteid}.tmp/${CGnumber}/rip_plot.gs 

#echo "" >> ${NWPSDATA}/logs/runrip.log 
#echo "Let's clean the old rip current files, but keep the past 4-5 days worth." 
#echo "" 

# Only keep the latest 14 contour files: Remember you must have 72 hrs worth of data for the program to run.
# So, before uncommenting, give your site a few days or so of runs to accumulate plenty of data. 

# cd ${RIPdir} && ls -t1 ${contour}m_contour* | tail -n +15 | xargs rm -r 
# cd ${RIPdir} && ls -t1 ${contour}m_${CGnumber}* | tail -n +15 | xargs rm -r 

exit 0
} >> ${NWPSDATA}/logs/runrip.log

# -----------------------------------------------------------
# *******************************
# ********* End of File *********
# *******************************

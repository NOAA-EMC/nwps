#!/bin/bash
# -----------------------------------------------------------
# UNIX Shell Script
# Tested Operating System(s): RHEL 5
# Shell Used: BASH shell
# Original Author(s): Alex.Gibbs@noaa.gov
# File Creation Date: 7/28/2012
# Date Last Modified: 6/26/2014
#
# Version control: 1.01
#
# Support Team:
#
# Contributors: Pablo Santos, Roberto.Padilla@noaa.gov
#
# -----------------------------------------------------------
# ------------- Program Description and Details -------------
# -----------------------------------------------------------
#
# This is the post-processing script for the partitioned
# wave fields. This includes assembling all wave systems
# (heights,directions & periods) into one final netCDF file
# along with plots.
#
# To execute:                           ARG1 ARG2
# ./postprocess_plot_partition_fields.sh MFL CG1
#
# NOTE: if the SITEID and GRID are not specified only CG1
# will be plotted for the latest site configured found in
# $NWPSdir/etc/nwps_config.sh
#
# Arguments=2:
#
# MFL=SITEID
# CG1=domain you would like to plot
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

echo "$SITEID"

if [ "$2" != "" ]; then CGnumber="$2"; fi

if [ "${CGnumber}" == "" ]
    then
    CGnumber="CG1"
    echo "NO CGNUM WAS SPECIFIED...SO ONLY PROCESSING CG1 PARTITIONED FIELDS"
fi
CGnumber=$(echo ${CGnumber} | tr [:lower:] [:upper:])

# -----------------------------------------------------------

#source ${PARMnwps}/set_platform.sh

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
elif [ $NWPSplatform == "WCOSS" ]
then
  NWPSDATA="${DATA}"
elif [ $NWPSplatform == "DEVWCOSS" ]
then
  NWPSDATA="${NWPSDEVDATA}"
fi
echo "============== postprocess_plot_partition_fields.sh ==========="
echo "NWPSdir : ${HOMEnwps}"

echo $$ > ${TMPdir}/${USERNAME}/nwps/7788_postprocess_plot_partition_fields_sh.pid

echo "NWPSDATA is: $NWPSDATA"

date=$(date "+%D  %H:%M:%S")
ncgen="${HOMEnwps}/lib64/netcdf/bin/ncgen"
grib2dir="${NWPSDATA}/output/grib2"
#graphics="${NWPSDATA}/var/${SITEID}.tmp/2D_PARTITION_PLOTS"
#plotting="${NWPSDATA}/var/${SITEID}.tmp/${CGnumber}"
graphics="${NWPSDATA}/var/${SITEID}.tmp/2D_PARTITION_PLOTS"
# Pablo 11/22/2012: plotting is already cleaned when plot_partition is called before this script. in That script TMPdir (same as here) is cleaned.
plotting="${NWPSDATA}/var/${SITEID}.tmp/${CGnumber}"
# Pablo 11/22/2012: to avoid old images getting mixed in new runs. waves numbers in 2D partition plots should match Hansen Plots number of wave groups.
find ${graphics} -name "*.png" -print | xargs rm -f

ETCdir="${USHnwps}/grads/etc"
RUNwvtrck="${NWPSDATA}/output/partition/${CGnumber}"
part_chk="${NWPSDATA}/run"
CDFdir="${NWPSDATA}/output/netCdf/tmp"
gradstemplates="${USHnwps}/grads/etc/default"
grads="${EXECnwps}/grads/grads"
PLOT_templdir=${DATA}/plot/templates
# needed files
SYSCOORD="${RUNwvtrck}/SYS_COORD.OUT"
HSIGpartition="${RUNwvtrck}/SYS_HSIGN.OUT"
DIRpartition="${RUNwvtrck}/SYS_DIR.OUT"
TPpartition="${RUNwvtrck}/SYS_TP.OUT"
inputparm="${part_chk}/input${CGnumber}"

if [ $NUMCPUS -eq 1 ]
   then
   ww3systrkinplog="${part_chk}/sys_log.ww3"
else
   ww3systrkinplog="${part_chk}/sys_log0000.ww3"
fi

if [ ! -e ${graphics} ]; then mkdir -p ${graphics}; fi
if [ ! -e ${CDFdir} ]; then mkdir -p ${CDFdir}; fi

#######################################################
cd ${CDFdir} # where all work is done for netcdf file
#######################################################

if [ ! -e ${HSIGpartition} ]
then
    msg="FATAL ERROR: Missing SYS_HSIGN.OUT file. Cannot open ${HSIGpartition}"
    postmsg "$jlogfile" "$msg"
    export err=1; err_chk
else
    cp ${HSIGpartition} .
fi

if [ ! -e ${SYSCOORD} ]
then
    msg="FATAL ERROR: Missing SYS_COORD.OUT file. Cannot open ${SYSCOORD}"
    postmsg "$jlogfile" "$msg"
    export err=1; err_chk
else
    cp ${SYSCOORD} .

    latline=$(sed -n '/Latitude/ =' ${SYSCOORD})
    lastline=$(wc -l ${SYSCOORD} > lastlinefile)
    lastline=$(awk '{print $1;}' lastlinefile)

    # find x grid points for partitioned domain

    sed -e "${latline},${lastline} d" ${SYSCOORD} > blahlon
    tail -n 1 blahlon > blahlon1
    x=$(wc -w blahlon1 > blahlon2)
    x=$(awk '{print $1;}' blahlon2)

    # find y grid points for partitioned domain

    sed -e "1,${latline} d" ${SYSCOORD} > blahlat
    y=$(wc -l blahlat > blahlat1)
    y=$(awk '{print $1;}' blahlat1)
fi

if [ ! -e ${DIRpartition} ]
then
    msg="FATAL ERROR: Missing SYS_DIR.OUT file. Cannot open ${DIRpartition}"
    postmsg "$jlogfile" "$msg"
    export err=1; err_chk
else
    cp ${DIRpartition} .
fi

if [ ! -e ${TPpartition} ]
then
    msg="FATAL ERROR: Missing SYS_TP.OUT file. Cannot open ${TPpartition}"
    postmsg "$jlogfile" "$msg"
    export err=1; err_chk
else
    cp ${TPpartition} .
fi

if [ ! -e ${part_chk}/partition.raw ]
then
    msg="FATAL ERROR: Missing partition.raw file. SYSTRK was not executed from the last run"
    postmsg "$jlogfile" "$msg"
    export err=1; err_chk
fi

if [ ! -e ${inputparm} ]
then
    msg="FATAL ERROR: Missing input${CGnumber} file. Cannot open ${inputparm}"
    postmsg "$jlogfile" "$msg"
    export err=1; err_chk
fi

pattern1=`grep -ic "FRAME 'RAWGRID'" ${inputparm}`
pattern2=`grep -ic "^BLOCK 'COMPGRID' HEADER 'swan_part.CG1.raw'" ${inputparm}`

if [ ${pattern1} -eq 1 ]
then
   echo ""
   echo "I FOUND A FRAME RAWGRID LINE IN THE INPUTCG FILE, SO A DIFF TRACKING RES APPEARS TO HAVE BEEN USED"
   grep "^FRAME 'RAWGRID'" ${inputparm} > swan_partition_step
else
    grep "^BLOCK 'COMPGRID' HEADER 'swan_part.CG1.raw'" ${inputparm} > swan_partition_step
fi

if [ ! -e ${ww3systrkinplog} ]
then
    msg="FATAL ERROR: Missing ${ww3systrkinplog} file. Cannot open ${ww3systrkinplog}"
    postmsg "$jlogfile" "$msg"
    export err=1; err_chk
else
    echo "__________________________________________________________________________________"
    echo ""
    echo "Checking the sys_log0000.ww3 in the run directory..."
    grep "Longitude range" ${ww3systrkinplog} > lontrack
    grep "Latitude range" ${ww3systrkinplog} > lattrack
    SWLAT=$(awk '{print $4;}' lattrack)
    NELAT=$(awk '{print $5;}' lattrack)
    SWLON=$(awk '{print $6;}' lontrack)
    NELON=$(awk '{print $7;}' lontrack)
fi

if [ ${pattern1} -eq 1 ]
then
    # Wave tracking done on different grid than the CGRID ("COMPGRID"), called the "RAWGRID"
    echo "LET'S DO A QUICK CHECK AND MAKE SURE WE HAVE THE CORRECT GRID POINTS FOR X AND Y"
    echo ""
    echo "HERE IS WHAT I FOUND IN THE ${inputparm}:"
    echo ""
    newres=$(grep "^FRAME 'RAWGRID'" ${inputparm})
    echo ${newres}
    echo ""
    echo "____________________________________________________________________________________________________________"

    echo ""
    echo "=============================================================================="
    echo ""
    echo "POST-PROCESSING PARTITIONED WAVE FIELDS"
    echo "$date"
    echo ""

    cp ${inputparm} .
    grep "^CGRID" input${CGnumber} > blah
    grep "^INPGRID WIND" input${CGnumber} > blah1
    grep "^BLOCK 'RAWGRID' HEADER" input${CGnumber} > blah10
    grep "^FRAME 'RAWGRID'" ${inputparm} > newres
    grdpts=$(echo "($x * $y)" | bc)
    SWLON=$(echo "$SWLON - 360.00" | bc)
    NELON=$(echo "$NELON - 360.00" | bc)
    blahCTRLAT=$(echo "($NELAT - $SWLAT) / 2.00" | bc)
    CTRLAT=$(echo "($SWLAT + $blahCTRLAT)" | bc)
    blahCTRLON=$(echo "($SWLON - $NELON) / 2.00" | bc)
    CTRLON=$(echo "($NELON + $blahCTRLON)" | bc)
    init=$(awk '{print $11;}' blah1)
    step=$(awk '{print $10;}' blah10)
    TDEF=$(grep -c "Time" SYS_HSIGN.OUT)
    SWANFCSTLENGTH=$(echo "($TDEF * $step) - $step" | bc)
    NSD=$(echo "scale=2; ${NELAT}-${SWLAT}" | bc)
    dy=$(echo "scale=10; ${NSD}/(${y}-1)" | bc)
    SWLON=$(echo ${SWLON} | sed s'/-//'g)
    NELON=$(echo ${NELON} | sed s'/-//'g)
    EWD=$(echo "scale=2; ${SWLON}-${NELON}" | bc)
    dx=$(echo "scale=10; ${EWD}/(${x}-1)" | bc)
    DSET="${siteid}_partition_${CGnumber}_${init}"
    DTYPE="netcdf"
    TITLE="NWPS PARTITIONING"
    UNDEF="9999.00"
    XDEF=$(echo "XDEF ${x} linear -$SWLON $dx")
    YDEF=$(echo "YDEF ${y} linear $SWLAT $dy")
    ZDEF="1 levels 1"

    echo "____________________________________________________"
    echo "                  DOMAIN & RUN CONFIG               "
    echo ""
    echo "SWLAT = $SWLAT"
    echo "SWLON = $SWLON"
    echo "NELAT = $NELAT"
    echo "NELON = $NELON"
    echo "nx=$x"
    echo "ny=$y"
    echo "dx=$dx"
    echo "dy=$dy"
    echo "Total Grid Points (per step) = ${grdpts}"
    echo "MODEL INIT TIME = $init"
    echo "OUTPUT TIME STEP = $step"
    echo "TOTAL RUN LENGTH = $SWANFCSTLENGTH"
    echo ""
    echo "____________________________________________________"
else
    # Wave tracking done on the CGRID ("COMPGRID")
    echo ""
    echo ""
    echo "=============================================================================="
    echo ""
    echo "POST-PROCESSING PARTITIONED WAVE FIELDS"
    echo "$date"
    echo ""

    cp ${inputparm} .
    grep "^CGRID" input${CGnumber} > blah
    grep "^INPGRID WIND" input${CGnumber} > blah1
    #grep "^BLOCK 'RAWGRID" input${CGnumber} > blah1
    grep "^BLOCK 'COMPGRID' HEADER" input${CGnumber} > blah10
    SWLONCIRC=$(awk '{print $2;}' blah)
    NELONCIRC=$(awk '{print $2+$5;}' blah)
    grdpts=$(echo "($x * $y)" | bc)
    SWLON=$(echo "$SWLONCIRC - 360.00" | bc)
    NELON=$(echo "$NELONCIRC - 360.00" | bc)
    blahCTRLAT=$(echo "($NELAT - $SWLAT) / 2.00" | bc)
    CTRLAT=$(echo "($SWLAT + $blahCTRLAT)" | bc)
    blahCTRLON=$(echo "($SWLON - $NELON) / 2.00" | bc)
    CTRLON=$(echo "($NELON + $blahCTRLON)" | bc)
    init=$(awk '{print $11;}' blah1)
    step=$(awk '{print $10;}' blah10)
    #step=$(awk '{print $9;}' blah10)
    TDEF=$(grep -c "Time" SYS_HSIGN.OUT)
    SWANFCSTLENGTH=$(echo "($TDEF * $step) - $step" | bc)
    NSD=$(echo "scale=2; ${NELAT}-${SWLAT}" | bc)
    dy=$(echo "scale=10; ${NSD}/(${y}-1)" | bc)
    SWLON=$(echo ${SWLON} | sed s'/-//'g)
    NELON=$(echo ${NELON} | sed s'/-//'g)
    EWD=$(echo "scale=2; ${SWLON}-${NELON}" | bc)
    dx=$(echo "scale=10; ${EWD}/(${x}-1)" | bc)
    DSET="${init}"
    DTYPE="netcdf"
    TITLE="NWPS PARTITIONING"
    UNDEF="9999.00"
    XDEF=$(echo "XDEF ${x} linear -$SWLON $dx")
    YDEF=$(echo "YDEF ${y} linear $SWLAT $dy")
    ZDEF="1 levels 1"

    echo "____________________________________________________"
    echo "                  DOMAIN & RUN CONFIG               "
    echo ""
    echo "SWLAT = $SWLAT"
    echo "SWLON = $SWLON"
    echo "NELAT = $NELAT"
    echo "NELON = $NELON"
    echo "nx=$x"
    echo "ny=$y"
    echo "dx=$dx"
    echo "dy=$dy"
    echo "Total Grid Points (per step) = ${grdpts}"
    echo "MODEL INIT TIME = $init"
    echo "OUTPUT TIME STEP = $step"
    echo "TOTAL RUN LENGTH = $SWANFCSTLENGTH"
    echo ""
    echo "____________________________________________________"

fi
##############################################################################
hr=0

echo "$step" > stepn
echo "$SWANFCSTLENGTH" > len

step=$(sed -e 's/\.0//' stepn) # no decimal needed
SWANFCSTLENGTH=$(sed -e 's/\.0//' len) # no decimal needed

echo "step and SWANFCSTLENGTH are: $step $SWANFCSTLENGTH"

for TYPE in HSIGN DIR TP
do

hr=0
sed -i "1,2 d" SYS_${TYPE}.OUT
while [ $hr -lt $SWANFCSTLENGTH ]
do

cat -n SYS_${TYPE}.OUT | sed -n '/Time/p' | head -2 > blah
sed -e '1 d' blah > blah1
awk '{print $1;}' blah1 > blah2
rm blah blah1

line=$(cat blah2)
line1=$(echo "${line}-1" | bc)

head -$line1 SYS_${TYPE}.OUT > ${TYPE}_$hr.txt
sed -i "1,$line1 d" SYS_${TYPE}.OUT

hr=`expr $hr + $step`

#end while loop
done

mv SYS_${TYPE}.OUT ${TYPE}_$SWANFCSTLENGTH.txt
rm blah2

#############################################################################
#
# Now that each time step in the run has been isolated into individual files,
# it is time to find out how many wave systems were output from this run. This
# section will go into each of the prev developed files and separate each
# wave field found at each time step.
#
##############################################################################

################################################
#
# Begin outer loop to grab the correct hour
#
################################################
date=$(date "+%D  %H:%M:%S")
hr=0

while [ $hr -le $SWANFCSTLENGTH ]
do

cat ${TYPE}_${hr}.txt | sed -n '/Tot number of systems/p' > blah
awk '{print $1;}' blah > blah1

systems=$(cat blah1)
if [ $systems -eq 0 ]
then
   echo "WARNING: No wave systems identified. Not producing wave tracking CG0 GRIB2 file for this run." | tee -a ${RUNdir}/Warn_Forecaster_${SITEID^^}.${PDY}.txt
   cycle=$(awk '{print $1;}' ${RUNdir}/CYCLE)
   COMOUTCYC="${COMOUT}/${cycle}"
if [ "${SENDCOM}" == "YES" ]; then
   mkdir -p $COMOUTCYC $GESOUT/warnings
   cp -fv  ${RUNdir}/Warn_Forecaster_${SITEID^^}.${PDY}.txt ${COMOUTCYC}/Warn_Forecaster_${SITEID^^}.${PDY}.txt
   cp -fv  ${RUNdir}/Warn_Forecaster_${SITEID^^}.${PDY}.txt ${GESOUT}/warnings/Warn_Forecaster_${SITEID^^}.${PDY}.txt
fi

   msg="WARNING: No wave systems identified. Not producing wave tracking CG0 GRIB2 file for this run."
   postmsg "$jlogfile" "$msg"

   #Send the number of systems to a file, this can be used when including headers
   echo "Saving the number of wave systems in ${RUNdir}/NumWaveSystems.txt" 
   cat /dev/null > ${RUNdir}/NumWaveSystems.txt
   echo "${systems}" | tee -a ${RUNdir}/NumWaveSystems.txt
   exit 0
fi

counter=1

        ################################################
        #
        # Begin inner loop to separate each wave system
        #
        ################################################

        while [ $counter -lt $systems ]
        do

        cat -n ${TYPE}_${hr}.txt | sed -n '/System number/p' | head -2 > blah2
        awk '{print $1;}' blah2 > blah3
        sed -e '1 d' blah3 > blah4

        line=$(cat blah4)
        line1=$(echo "${line}-1" | bc)

        head -$line1 ${TYPE}_${hr}.txt > ${hr}_${TYPE}_${counter}.txt
        sed -i "1,$line1 d" ${TYPE}_${hr}.txt

        if [ $counter -eq 1 ]
        then

        sed -i '1, 4 d' ${hr}_${TYPE}_${counter}.txt

        else
        sed -i '1, 2 d' ${hr}_${TYPE}_${counter}.txt
        fi


        # Since IDLA=1 (NW to SE)  is currently used...we need to flip the grid points
        # so that the pattern reflects IDLA=3 (SW to NE)
        # The next version of systrak will be changing to IDLA=3.

        tac ${hr}_${TYPE}_${counter}.txt > ${hr}_${TYPE}_${counter}

        counter=`expr $counter + 1`
        done

        ################################################
        # Finish inner loop
        #
        ################################################

mv ${TYPE}_${hr}.txt ${hr}_final_${TYPE}_system.txt
sed -i '1, 2 d' ${hr}_final_${TYPE}_system.txt

# same as above .... flip the values for the IDLA=3

tac ${hr}_final_${TYPE}_system.txt > ${hr}_final_${TYPE}_system

hr=`expr $hr + $step`
done

#Send the number of systems to a file, this can be used when including headers
echo "Saving the number of wave systems in ${RUNdir}/NumWaveSystems.txt" 
cat /dev/null > ${RUNdir}/NumWaveSystems.txt
echo "${systems}" | tee -a ${RUNdir}/NumWaveSystems.txt
#
################################################
# Finish outer loop
################################################

################################################
#
# Process each wave group into one file that
# can be appended into netcdf template.
#
################################################

echo ""
echo "TOTAL NUMBER OF WAVE SYSTEMS TO BE PROCESSED FOR ${TYPE} = $systems"
echo "Processing each system..."
echo ""

counter=1

while [ $counter -lt $systems ]
do

hr=0

        while [ $hr -le $SWANFCSTLENGTH ]
        do

        sed -i 's/    /,/g' ${hr}_${TYPE}_${counter}
        sed -i 's/ /,/g' ${hr}_${TYPE}_${counter}
        sed -i 's/,/\n/g' ${hr}_${TYPE}_${counter}
        sed -i 's/$/,/g' ${hr}_${TYPE}_${counter}
        sed -i '/^,/d' ${hr}_${TYPE}_${counter}

        # isolate hourly files for each system to be processed for grib2
        cp ${hr}_${TYPE}_${counter} ${grib2dir}

        hr=`expr $hr + $step`

        done

  counter=`expr $counter + 1`
done

# work on final system

hr=0

while [ $hr  -le $SWANFCSTLENGTH ]
do
        sed -i 's/    /,/g' ${hr}_final_${TYPE}_system
        sed -i 's/ /,/g' ${hr}_final_${TYPE}_system
        sed -i 's/,/\n/g' ${hr}_final_${TYPE}_system
        sed -i 's/$/,/g' ${hr}_final_${TYPE}_system
        sed -i '/^,/d' ${hr}_final_${TYPE}_system

        # isolate hourly files for final system to be processed for grib2
        cp ${hr}_final_${TYPE}_system ${grib2dir}

        hr=`expr $hr + $step`
done

################################################
#
# Pack each wave field into one file
#
################################################

counter=1

while [ $counter -lt $systems ]
do

hr=0

  echo ${TYPE}${counter} = > ${TYPE}_${counter}

  echo "   WORKING ON SYSTEM NUMBER $counter of $systems"

        while [ $hr -le $SWANFCSTLENGTH ]
        do

        cat ${hr}_${TYPE}_${counter} >> ${TYPE}_${counter}

        hr=`expr $hr + $step`

        done

  sed -i '$s/,$/;/' ${TYPE}_${counter}

  counter=`expr $counter + 1`
done

hr=0

echo "   WORKING ON FINAL WAVE SYSTEM"

echo ${TYPE}$systems = > final_${TYPE}_system

while [ $hr -le $SWANFCSTLENGTH ]
do

cat ${hr}_final_${TYPE}_system >> final_${TYPE}_system

hr=`expr $hr + $step`
done

sed -i '$s/,$/;/' final_${TYPE}_system

#end for loop
done

date=$(date "+%D  %H:%M:%S")

######################################################################
#echo "BUILDING THE NETCDF TEMPLATE" not enymore
######################################################################

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

time_stamp="${yyyy}${mon}${dd}_${hh}${mm}"
##################################################################################
# ASSEMBLE GRIB2 FILES AND PLOT IMAGES WITH GrADS from FINAL GRIB2 DATA
##################################################################################

cd ${grib2dir}

# remove all commas in files that were used to pack meta data into netcdf files
sed -i 's/,//g' *
sed -i 's/9999.00/0.00/' *

##wgrib2="${NWPSdir}/lib64/wgrib2/bin/wgrib2"
#swan_out_to_bin="${NWPSdir}/lib64/nwps_utils/bin/swan_out_to_bin"
#g2_write_template"${NWPSdir}/lib64/nwps_utils/bin/g2_write_template"

wgrib2="${EXECnwps}/wgrib2"
swan_out_to_bin="${EXECnwps}/swan_out_to_bin"
g2_write_template="${EXECnwps}/g2_write_template"

for TYPE in HSIGN DIR TP
do

counter=1

 while [ $counter -lt $systems ]
 do

  hr=0

  echo "   WORKING ON SYSTEM NUMBER $counter of $systems"

        while [ $hr -le $SWANFCSTLENGTH ]
        do

        #cp $NWPSdir/templates/${siteid}/partition.meta ${grib2dir}
        cp ${NWPSDATA}/parm/templates/${siteid}/partition.meta ${grib2dir}

        sed -i "s/<< SET START YEAR >>/${yyyy}/g" partition.meta
        sed -i "s/<< SET START MONTH >>/${mon}/g" partition.meta
        sed -i "s/<< SET START DAY >>/${dd}/g" partition.meta
        sed -i "s/<< SET START HOUR >>/${hh}/g" partition.meta
        sed -i "s/<< SET START MINUTE >>/${mm}/g" partition.meta
        sed -i "s/<< SET START SECOND >>/00/g" partition.meta

        sed -i "s/<< SET NUM POINTS >>/${grdpts}/g" partition.meta
        sed -i "s/<< SET NX >>/${x}/g" partition.meta
        sed -i "s/<< SET NY >>/${y}/g" partition.meta
        sed -i "s/<< SET DX >>/${dx}/g" partition.meta
        sed -i "s/<< SET DY >>/${dy}/g" partition.meta
        sed -i "s/<< SET LA1 >>/${SWLAT}/g" partition.meta
        sed -i "s/<< SET LO1 >>/${SWLON}/g" partition.meta
        sed -i "s/<< SET LA2 >>/${NELAT}/g" partition.meta
        sed -i "s/<< SET LO2 >>/${NELON}/g" partition.meta
        sed -i "s/<< SET FORECAST HOUR >>/${hr}/g" partition.meta
        sed -i "s/<< SET WAVE NUMBER >>/${counter}/g" partition.meta

        # Configure meta file based on grib2 parameter table number.

        if [ "${TYPE}" == "HSIGN" ]; then
           sed -i "s/<< SET WAVE TYPE >>/8/g" partition.meta
        fi
        if [ "${TYPE}" == "DIR" ]; then
           sed -i "s/<< SET WAVE TYPE >>/7/g" partition.meta
        fi
        if [ "${TYPE}" == "TP" ]; then
           sed -i "s/<< SET WAVE TYPE >>/9/g" partition.meta
        fi

        # Assemble grib2 files now that the meta file is configured for this time step

        # Example command 1:  swan_out_to_bin HSIG.CG1.CGRID.YY11.MO01.DD25.HH00 627 3 1 24
        ${swan_out_to_bin} ${hr}_${TYPE}_${counter} ${grdpts} ${step} 1 ${SWANFCSTLENGTH}

        # Write a GRIB2 template file
        # Example: g2_write_template varname.meta outfile.grb2
        # ${g2_write_template} partition.meta ${TYPE}_template.grib2
        ${g2_write_template} partition.meta ${TYPE}_template.grib2
 

        # Encode the SWAN output into a GRIB2 file
        # Example wgrib2 HSIG_template.grib2 -no_header -import_bin point_values.bin -grib_out HSIG.grib2
        ${wgrib2} ${TYPE}_template.grib2 -no_header -import_bin 0_${hr}_${TYPE}_${counter}.bin -grib_out ${hr}_${TYPE}_${counter}.grib2

        hr=`expr $hr + $step`

        done

        counter=`expr $counter + 1`
 done
done

#############################################FINAL###############################

for TYPE in HSIGN DIR TP
do

hr=0

  echo "   WORKING ON SYSTEM NUMBER $counter of $systems"

        while [ $hr -le $SWANFCSTLENGTH ]
        do

        #cp $NWPSdir/templates/${siteid}/partition.meta ${grib2dir}
        cp ${NWPSDATA}/parm/templates/${siteid}/partition.meta ${grib2dir}
        sed -i "s/<< SET START YEAR >>/${yyyy}/g" partition.meta
        sed -i "s/<< SET START MONTH >>/${mon}/g" partition.meta
        sed -i "s/<< SET START DAY >>/${dd}/g" partition.meta
        sed -i "s/<< SET START HOUR >>/${hh}/g" partition.meta
        sed -i "s/<< SET START MINUTE >>/${mm}/g" partition.meta
        sed -i "s/<< SET START SECOND >>/00/g" partition.meta

        sed -i "s/<< SET NUM POINTS >>/${grdpts}/g" partition.meta
        sed -i "s/<< SET NX >>/${x}/g" partition.meta
        sed -i "s/<< SET NY >>/${y}/g" partition.meta
        sed -i "s/<< SET DX >>/${dx}/g" partition.meta
        sed -i "s/<< SET DY >>/${dy}/g" partition.meta
        sed -i "s/<< SET LA1 >>/${SWLAT}/g" partition.meta
        sed -i "s/<< SET LO1 >>/${SWLON}/g" partition.meta
        sed -i "s/<< SET LA2 >>/${NELAT}/g" partition.meta
        sed -i "s/<< SET LO2 >>/${NELON}/g" partition.meta
        sed -i "s/<< SET FORECAST HOUR >>/${hr}/g" partition.meta
        sed -i "s/<< SET WAVE NUMBER >>/${counter}/g" partition.meta

        # Configure meta file based on grib2 parameter table number.

        if [ "${TYPE}" == "HSIGN" ]; then
           sed -i "s/<< SET WAVE TYPE >>/8/g" partition.meta
        fi
        if [ "${TYPE}" == "DIR" ]; then
           sed -i "s/<< SET WAVE TYPE >>/7/g" partition.meta
        fi
        if [ "${TYPE}" == "TP" ]; then
           sed -i "s/<< SET WAVE TYPE >>/9/g" partition.meta
        fi

        # Assemble grib2 files now that the meta file is configured for this time step

        # Example command 1:  swan_out_to_bin HSIG.CG1.CGRID.YY11.MO01.DD25.HH00 627 3 1 24
        ${swan_out_to_bin} ${hr}_final_${TYPE}_system ${grdpts} ${step} 1 ${SWANFCSTLENGTH}

        # Write a GRIB2 template file
        # Example: g2_write_template varname.meta outfile.grb2
        # ${g2_write_template} partition.meta ${TYPE}_template.grib2
        ${g2_write_template} partition.meta ${TYPE}_template.grib2


        # Encode the SWAN output into a GRIB2 file
        # Example wgrib2 HSIG_template.grib2 -no_header -import_bin point_values.bin -grib_out HSIG.grib2
        ${wgrib2} ${TYPE}_template.grib2 -no_header -import_bin 0_${hr}_final_${TYPE}_system.bin -grib_out ${hr}_final_${TYPE}_system.grib2

        hr=`expr $hr + $step`

        done

done


#################################################################################
# Append all grib2 data together into one final grib2 file:

for TYPE in HSIGN DIR TP
do

counter=1

 while [ $counter -lt $systems ]
 do

  hr=${step}

  echo "   WORKING ON SYSTEM NUMBER $counter of $systems"

        while [ $hr -le $SWANFCSTLENGTH ]
        do
          cat ${hr}_${TYPE}_${counter}.grib2 >> 0_${TYPE}_${counter}.grib2
          hr=`expr $hr + $step`
        done

   counter=`expr $counter + 1`
 done
done

##########################final

for TYPE in HSIGN DIR TP
do

  hr=${step}

  echo "   WORKING ON final SYSTEM NUMBER $counter of $systems"

        while [ $hr -le $SWANFCSTLENGTH ]
        do
          cat ${hr}_final_${TYPE}_system.grib2 >> 0_final_${TYPE}_system.grib2
          hr=`expr $hr + $step`
        done
done

#############################


for TYPE in HSIGN DIR TP
do

counter=2

 while [ $counter -lt $systems ]
 do
   cat 0_${TYPE}_${counter}.grib2 >> 0_${TYPE}_1.grib2
   counter=`expr $counter + 1`
 done
done

###################################################
# create final grib2 file

if [ $systems -gt 1 ]
then
   cat 0_DIR_1.grib2 >> 0_HSIGN_1.grib2
   cat 0_TP_1.grib2 >> 0_HSIGN_1.grib2
   cat 0_final_HSIGN_system.grib2 >> 0_HSIGN_1.grib2
else
   cp 0_final_HSIGN_system.grib2 0_HSIGN_1.grib2
fi
cat 0_final_DIR_system.grib2 >> 0_HSIGN_1.grib2
cat 0_final_TP_system.grib2 >> 0_HSIGN_1.grib2
mv 0_HSIGN_1.grib2 ${siteid}_nwps_CG0_Trkng_${time_stamp}.grib2

# make final tracking grib2 directory

if [ ! -e ${grib2dir}/tracking/CG0 ]; then mkdir -p ${grib2dir}/tracking/CG0; fi

mv ${siteid}_nwps_CG0_Trkng_${time_stamp}.grib2 ${grib2dir}/tracking/CG0

cycle=$(awk '{print $1;}' ${RUNdir}/CYCLE)
COMOUTCYC="${COMOUT}/${cycle}/CG0"
if [ "${SENDCOM}" == "YES" ]; then
   mkdir -p $COMOUTCYC
   cp -fv  ${grib2dir}/tracking/CG0/${siteid}_nwps_CG0_Trkng_${time_stamp}.grib2 $COMOUTCYC/
   if [ "${SENDDBN}" == "YES" ]; then
       ${DBNROOT}/bin/dbn_alert MODEL NWPS_GRIB $job  ${COMOUTCYC}/${siteid}_nwps_CG0_Trkng_${time_stamp}.grib2
   fi
fi

# keep the past 15 tracking grib2 files
#cd ${grib2dir}/tracking/CG0 && ls -t1 ${siteid}_nwps_CG0* | tail -n +15 | xargs rm -r


#----------------------------------------------------------------------
#----------------------------------------------------------------------
echo ""
echo "DOING SOME CLEANUP"
echo ""

cd ${CDFdir}

 rm year mon day hh mm lattrack lontrack newres
 rm datetime
#AW rm swan_partition_step *TP* stepn len blah* *HSIGN* *DIR* partition_template.cdl input${CGnumber}
 rm swan_partition_step *TP* stepn len blah* *HSIGN* *DIR* input${CGnumber}
# rm ${RUNwvtrck}/*.OUT
# rm ${RUNdir}/partition.raw
#AW rm ${plotting}/${init}

####################################################################################
#
#
date=$(date "+%D  %H:%M:%S")

echo ""
echo "COMPLETE"
echo "$date"
echo "=============================================================================="

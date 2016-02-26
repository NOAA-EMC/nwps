#!/bin/bash
# ----------------------------------------------------------- 
# UNIX Shell Script File
# Tested Operating System(s): RHEL 5,6
# Tested Run Level(s): 3, 5
# Shell Used: BASH shell
# Original Author(s): Alex Gibbs, Tony Freeman, Pablo Santos, Douglas Gaer
# File Creation Date: 06/01/2009
# Date Last Modified: 11/15/2014
#
# Version control: 1.01
#
# Support Team:
#
# Contributors: Roberto Padilla
# ----------------------------------------------------------- 
# ------------- Program Description and Details ------------- 
# ----------------------------------------------------------- 
#
#
# ----------------------------------------------------------- 
export CGNUMPLOT=${1}
CGNUM="${1}"
echo "= = = =  = = =   IN NWPS_POSPROC_CG1.SH  = =  = = =  = = ="
echo " CGNUMPLOT= ${CGNUMPLOT}"
ndata=1
while read p; do
  echo ${ndata} $p
   if [ ${ndata} -eq 1 ]; then
    NWPSdir=$p;
   fi
   if [ ${ndata} -eq 2 ]; then
     ISPRODUCTIO=$p;
   fi
   if [ ${ndata} -eq 3 ]; then
     DEBUGGING=$p;
   fi
   if [ ${ndata} -eq 4 ]; then
     DEBUG_LEVEL=$p;
   fi
   if [ ${ndata} -eq 5 ]; then
     BATHYdb=$p;
   fi
   if [ ${ndata} -eq 6 ]; then
     SHAPEFILEdb=$p;
   fi
   if [ ${ndata} -eq 7 ]; then
     ARCHdir=$p;
   fi
   if [ ${ndata} -eq 8 ]; then
    DATAdir=$p;
   fi
   if [ ${ndata} -eq 9 ]; then
    INPUTdir=$p;
   fi
   if [ ${ndata} -eq 10 ]; then
     LOGdir=$p;
   fi
   if [ ${ndata} -eq 11 ]; then
     VARdir=$p;
   fi
   if [ ${ndata} -eq 12 ]; then
     OUTPUTdir=$p;
   fi
   if [ ${ndata} -eq 13 ]; then
     RUNdir=$p;
   fi
   if [ ${ndata} -eq 14 ]; then
     TMPdir=$p;
   fi
   if [ ${ndata} -eq 15 ]; then
     RUNLEN=$p;
   fi
   if [ ${ndata} -eq 16 ]; then
     WNA=$p;
   fi
   if [ ${ndata} -eq 17 ]; then
     NEST=$p;
   fi
   if [ ${ndata} -eq 18 ]; then
     RTOFS=$p;
   fi
   if [ ${ndata} -eq 19 ]; then
     ESTOFS=$p;
   fi
   if [ ${ndata} -eq 20 ]; then
     WINDS=$p;
   fi
   if [ ${ndata} -eq 21 ]; then
     WEB=$p;
   fi
   if [ ${ndata} -eq 22 ]; then
     export PLOT=$p;
   fi
   if [ ${ndata} -eq 23 ]; then
     SITEID=$p;
   fi
   if [ ${ndata} -eq 24 ]; then
    MODELCORE=$p;
   fi
  ndata=$(( $ndata + 1 ))
done < ${RUNdir}/info_to_nwps_coremodel.txt

#export NWPSdir DEBUGGING DEBUG_LEVEL BATHYdb SHAPEFILEdb ARCHdir
#export DATAdir LOGdir VARdir OUTPUTdir RUNdir TMPdir RUNLEN
#export NEST RTOFS ESTOFS WEB PLOT MODELCORE LOGdir SITEID WNA 
#export WINDS INPUTdir  ISPRODUCTIO DATAdir
#source ${NWPSdir}/parm/platform/set_platform.sh
logrunup=${LOGdir}/runup.log
echo "NWPS posproc_CG${CGNUM} " | tee -a $logfile

# Halt this script it the model or Perl interface crashes
if [ -e ${OUTPUTdir}/netCdf/not_completed ]
    then
    echo "SWAN Run failed!"                                  | tee -a $logfile
    echo "Exiting ${PROGRAMname} with no further processing" | tee -a $logfile
    #RemoveLockFile
    export err=1; err_chk
fi

echo " "                                            | tee -a $logrunup
echo -n "SWAN Run Finished OK Preparing for Post-Process"     | tee -a $logrunup                                                
echo " " | tee -a $logrunup
#____________________________RUNUP PROGRAM________________________________
#Run Program    
  echo "DATA: ${DATA}  DATAdir: ${DATAdir}"   | tee -a $logrunup
  source ${DATA}/parm/templates/${siteid}/${SITEID}
  runupcg=${RUNUPDOMAIN:2:1}
  runupcg2="${RUNUPDOMAIN:2:1}"
  echo "runupcg: ${runupcg}"
  echo "runupcg2: ${runupcg2}"
  echo "${RUNUPPROG} -eq ${RUNUPPROG}  and   ${runupcg} == ${CGNUM} ?"   | tee -a $logrunup

  if [ ${RUNUPPROG} -eq "1" ] && [ ${runupcg} == ${CGNUM} ]
  then
     echo "RUNUP WILL BE PROCESSED" | tee -a $logrunup
     dpt_runup_contour=${RUNUPCONT}
     echo " CG domain for wave runup        : ${RUNUPDOMAIN}" | tee -a $logrunup
     echo " Depth contour used for runup    : ${dpt_runup_contour}" | tee -a $logrunup

     inputparm="${RUNdir}/inputCG${CGNUM}"
     if [ ! -e ${inputparm} ]
     then
        msg="FATAL ERROR: Runup program: Missing inputCG${CGNUM} file. Cannot open ${inputparm}"
        postmsg $jlogfile "$msg"        
        export err=1; err_chk
     fi
     #Moving input files and programs to teh temporary directoy
     export TEMPDIRrunup=${VARdir}/${siteid}.tmp/CG${CGNUM}/runup
     mkdir -p ${TEMPDIRrunup}
     cd ${TEMPDIRrunup}
     #Copying all needed data, input and programs here to execute run_runup.sh
     # in ${VARdir}/${siteid}.tmp/CG${CGNUM}/runup
     cp ${inputparm} .
     grep "^INPGRID WIND" inputCG${CGNUM} > blah1
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

     date_stamp="${yyyy}${mon}${dd}"
     echo "date_stamp: ${date_stamp}"  | tee -a $logrunup
     CYCLErunup="${hh}${mm}" 
     # nomenclature in[ut file for run_runup.sh e.g 20m_cont_CG2.20150202_0000_MHX
     fileor="${dpt_runup_contour}_contour_CG${CGNUM}"
     filein="${dpt_runup_contour}_cont_CG${CGNUM}.${yyyy}${mon}${dd}_${CYCLErunup}_${SITEID}"
     fileout="${dpt_runup_contour}_CG${CGNUM}_runup.${yyyy}${mon}${dd}_${hh}${mm}_${SITEID}.txt"
     echo "filein: ${filein}"  | tee -a $logrunup
     cp -fvp ${RUNdir}/${fileor} .
     cp ${fileor} ${filein}    | tee -a $logrunup
     cp -fvp ${FIXnwps}/beach_slope_db/CG${CGNUM}.${SITEID}_slopes.txt .   | tee -a $logrunup
     cp ${HOMEnwps}/exec/runupforecast.exe .   | tee -a $logrunup
     cp ${USHnwps}/run_runup.sh .   | tee -a $logrunup
     ls -lt  | tee -a $logrunup
     source run_runup.sh  ${CYCLErunup} ${date_stamp}  
     
     #Make output directory
     OUTDIRrunup=${DATA}/output/runup/CG${CGNUM}/
     mkdir -p ${OUTDIRrunup}
     cp -fv  ${dpt_runup_contour}_CG${CGNUM}_runup.txt ${OUTDIRrunup}/${fileout}

     cycle=$(awk '{print $1;}' ${RUNdir}/CYCLE)
     COMOUTCYC="${COMOUT}/${cycle}/CG${CGNUM}"
     if [ "${SENDCOM}" == "YES" ]; then
        mkdir -p $COMOUTCYC
        cp -fv  ${OUTDIRrunup}/${fileout} ${COMOUTCYC}/${fileout}
     fi
  fi
#_________________________RIP CURRENT PROGRAM____________________________________________
#Run Program 
  SITEID=${SITEID^^}
  source ${DATA}/parm/templates/${siteid}/${SITEID}
#  source ${DOMAINFILE}
  ripcg=${RIPDOMAIN:2:1}
  if [ ${RIPPROG} -eq "1" ] && [ ${ripcg} == ${CGNUM} ]
  then
     echo "RIP CURRENT PROBABILITY WILL BE COMPUTED" 
     dptcontour=${RIPCONT:0:1}
     echo " CG domain for rip currents: ${RIPDOMAIN}"
     echo " Depth contour used     : ${dptcontour} m"
     ${USHnwps}/rip_current_program/run_nos.sh ${RIPDOMAIN} ${dptcontour}
     #cp -vpf ripprob.png ${GRAPHICSdir}/.
  else
     echo " Rip current calculation not activated for this domain (CG${CGNUM})"
  fi
#_______________________________________________________________________________________

echo "RUN ${plotGorP} SCRIPTS"                            | tee -a $logfile

# NOTE: If WEB is enable we must set PLOT to YES
if [ "${WEB}" == "YES" ]; then export PLOT="YES"; fi

# NOTE: This will allow us to automate plotting with out send to Web option
if [ "${PLOT}" == "YES" ]
then

    echo "Cleaning Previous grads plots from ${OUTPUTdir}/grads/${siteid}" | tee -a $logfile
    rm -fr ${OUTPUTdir}/grads/${siteid}/CG* | tee -a $logfile
    rm -fr ${OUTPUTdir}/grads/${siteid}/partition | tee -a $logfile
    echo "Creating output plots" | tee -a $logfile
    #${USHnwps}/grads/bin/plot_nwps_run.sh ${SITEID} |tee -a $logfile
    ${USHnwps}/python/plot_nwps_run.sh ${SITEID} |tee -a $logfile


fi
#Sending grib2 files with gridded wave parameters to COMOUT
cd ${DATA}/output/grib2/CG${CGNUM}
     inputparm="${RUNdir}/inputCG${CGNUM}"
     if [ ! -e ${inputparm} ]
     then
        echo "ERROR - Missing inputCG${CGNUM} file"
        echo "ERROR - Cannot open ${inputparm}"
        export err=1; err_chk
     fi
     #Copying all needed data; input and programs here to run ru_runup.sh
     # in ${VARdir}/${siteid}.tmp/CG${CGNUM}/runup
     cp ${inputparm} .
     grep "^INPGRID WIND" inputCG${CGNUM} > blah1
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

     date_stamp="${yyyy}${mon}${dd}"
     grib2File="${siteid}_nwps_CG${CGNUM}_${date_stamp}_${hh}${mm}.grib2"
     cycle=$(awk '{print $1;}' ${RUNdir}/CYCLE)
     COMOUTCYC="${COMOUT}/${cycle}/CG${CGNUM}"
     if [ "${SENDCOM}" == "YES" ]; then
        mkdir -p $COMOUTCYC
        cp -fv  ${grib2File} ${COMOUTCYC}/${grib2File}
        if [ "${SENDDBN}" == "YES" ]; then
            ${DBNROOT}/bin/dbn_alert MODEL NWPS_GRIB $job ${COMOUTCYC}/${grib2File}
        fi
     fi

export WEB="NO"
echo " "  | tee -a $logfile

################################################################### 
# HOTSTART SECTION
# created: alex.gibbs@noaa.gov
# 
# Archives the latest hot files generated from a run to be used 
# in the next run. Only 128 files (2 days) will be saved, the rest
# will be purged.
#
###################################################################

echo "Archiving HOTSTART files to be used for the next run"   | tee -a $logfile
cycle=$(awk '{print $1;}' ${RUNdir}/CYCLE)
HOTdir="${GESOUT}/hotstart/${SITEID}/$cycle"   
#HOTdir="${GESOUT}/hotstart/"     
if [ ! -e ${HOTdir} ]
then 
   mkdir -p ${HOTdir}
fi
#rm -vf ${INPUTdir}/hotstart/* >> ${LOGdir}/hotstart.log 2>&1
cd ${RUNdir}/
mv -vf ${RUNdir}/2[0-9][0-9][0-9][0-9][0-9][0-9][0-9].* ${HOTdir}/. >> ${LOGdir}/hotstart.log 2>&1

echo "CLEANING OLD HOTSTART FILES" | tee -a ${LOGdir}/hotstart.log
cd ${INPUTdir}/hotstart/

#for i in $(ls -1d ${INPUTdir}/hotstart/)
#do
#    cd $i >> ${LOGdir}/hotstart.log
#    KEEP=128
#    COUNT=$(ls -1 *00* | wc -l)
#    TRIM=$(expr $COUNT - $KEEP)
#    BASEDIR=$(basename $i)
#    if [[ $TRIM -gt 0 ]]
#    then
#        for j in $(ls -1 *00* | tail -n $TRIM)
#        do
#            echo -n ": " | tee -a ${LOGdir}/hotstart.log
#            rm -fv $j    | tee -a ${LOGdir}/hotstart.log
#        done
#    fi
#done
echo "SAVING LATEST HOTSTART FILES" | tee -a ${LOGdir}/hotstart.log
echo "DONE" | tee -a ${LOGdir}/hotstart.log

echo " " | tee -a $logfile

echo "Cleaning out archive directory:"              | tee -a $logfile
cd ${ARCHdir}/
ITEMSTOKEEP=60
TOTAL=$(ls -1 *tgz | sort | wc -l)
HEAD=$(expr $TOTAL - $ITEMSTOKEEP)
if [[ $TOTAL -le $ITEMSTOKEEP ]]
then
    echo ": Nothing to clean ..."               | tee -a $logfile
else
    for i in $(ls -1 *tgz | head -n $HEAD)
    do
	echo -n ": "                        | tee -a $logfile
	rm -vf $i                           | tee -a $logfile
    done
fi

echo " " | tee -a $logfile
################################################################### 
echo "Cleaning out netcdf/cdl directory:"           | tee -a $logfile
cd ${OUTPUTdir}/netCdf/cdl
KEEP=0
COUNT=$(ls -1 | wc -l)
TRIM=$(expr $COUNT - $KEEP)
if [[ $TRIM -gt 0 ]]
then
    for i in $(ls -1 | head -n $TRIM)
    do
	echo -n ": "                        | tee -a $logfile
        rm -vf $i                           | tee -a $logfile
    done
fi
echo "Done" | tee -a $logfile

echo " " | tee -a $logfile
################################################################### 
# NOTE: Add all output DIRs to archive here
OUTPUTdirs="grib2 hdf5 netCdf partition spectra"

for dir in $OUTPUTdirs
do 
    echo "Archive ${dir} output to ${ARCHdir}:"   | tee -a $logfile
    for i in $(ls -1d ${OUTPUTdir}/${dir}/CG[0-9])
    do
	BASEDIR=$(basename $i)
	cd $i
	for j in $(ls -1 * | head -n $TRIM)
	do
	    test -d ${ARCHdir}/${dir}/$BASEDIR || mkdir -vp ${ARCHdir}/${dir}/$BASEDIR | tee -a $logfile
	    echo -n ": " | tee -a $logfile
	    cp -fvp $j ${ARCHdir}/${dir}/$BASEDIR/ | tee -a $logfile
	done
    done
    echo "Done" | tee -a $logfile
done

echo " " | tee -a $logfile
################################################################### 
for dir in $OUTPUTdirs
do 
    echo "Cleaning ${ARCHdir} DIR CG# files" | tee -a $logfile
    for i in $(ls -1d ${ARCHdir}/${dir}/CG[0-9])
    do
	cd $i
	KEEP=7
	COUNT=$(ls -1 * | wc -l)
	TRIM=$(expr $COUNT - $KEEP)
	if [[ $TRIM -gt 0 ]]
	then
	    echo "Removing old files in $i ... " | tee -a $logfile
	    for j in $(ls -1 * | head -n $TRIM)
	    do
		echo -n ": " | tee -a $logfile
		rm -fv $j     | tee -a $logfile
	    done
	fi
    done
    echo "Done" | tee -a $logfile
done

echo " " | tee -a $logfile

################################################################### 
echo "Cleaning out netcdf/CG directories:"           | tee -a $logfile
cd ${OUTPUTdir}/netCdf/CG1
KEEP=2
COUNT=$(ls -1 | wc -l)
TRIM=$(expr $COUNT - $KEEP)
if [[ $TRIM -gt 0 ]]
then
    for i in $(ls -1 | head -n $TRIM)
    do
        echo -n ": "                        | tee -a $logfile
        rm -vf $i                           | tee -a $logfile
    done
fi
echo "Done" | tee -a $logfile

echo " " | tee -a $logfile

if [ -e ${OUTPUTdir}/netCdf/CG2 ]
then
cd ${OUTPUTdir}/netCdf/CG2
KEEP=2
COUNT=$(ls -1 | wc -l)
TRIM=$(expr $COUNT - $KEEP)
if [[ $TRIM -gt 0 ]]
then
    for i in $(ls -1 | head -n $TRIM)
    do
        echo -n ": "                        | tee -a $logfile
        rm -vf $i                           | tee -a $logfile
    done
fi
echo "Done" | tee -a $logfile

echo " " | tee -a $logfile
fi

if [ -e ${OUTPUTdir}/netCdf/CG3 ]
then
cd ${OUTPUTdir}/netCdf/CG3
KEEP=2
COUNT=$(ls -1 | wc -l)
TRIM=$(expr $COUNT - $KEEP)
if [[ $TRIM -gt 0 ]]
then
    for i in $(ls -1 | head -n $TRIM)
    do
        echo -n ": "                        | tee -a $logfile
        rm -vf $i                           | tee -a $logfile
    done
fi
echo "Done" | tee -a $logfile

echo " " | tee -a $logfile
fi

if [ -e ${OUTPUTdir}/netCdf/CG4 ]
then
cd ${OUTPUTdir}/netCdf/CG4
KEEP=2
COUNT=$(ls -1 | wc -l)
TRIM=$(expr $COUNT - $KEEP)
if [[ $TRIM -gt 0 ]]
then
    for i in $(ls -1 | head -n $TRIM)
    do
        echo -n ": "                        | tee -a $logfile
        rm -vf $i                           | tee -a $logfile
    done
fi
echo "Done" | tee -a $logfile

echo " " | tee -a $logfile
fi

if [ -e ${OUTPUTdir}/netCdf/CG5 ]
then
cd ${OUTPUTdir}/netCdf/CG5
KEEP=2
COUNT=$(ls -1 | wc -l)
TRIM=$(expr $COUNT - $KEEP)
if [[ $TRIM -gt 0 ]]
then
    for i in $(ls -1 | head -n $TRIM)
    do
        echo -n ": "                        | tee -a $logfile
        rm -vf $i                           | tee -a $logfile
    done
fi
echo "Done" | tee -a $logfile

echo " " | tee -a $logfile
fi

################################################################### 
#echo "Cleaning out grib2/CG directories:"           | tee -a $logfile
#cd ${OUTPUTdir}/grib2/CG1
#KEEP=2
#COUNT=$(ls -1 | wc -l)
#TRIM=$(expr $COUNT - $KEEP)
#if [[ $TRIM -gt 0 ]]
#then
#    for i in $(ls -1 | head -n $TRIM)
#    do
#        echo -n ": "                        | tee -a $logfile
#        rm -vf $i                           | tee -a $logfile
#    done
#fi
#echo "Done" | tee -a $logfile
#
#echo " " | tee -a $logfile
#
#if [ -e ${OUTPUTdir}/grib2/CG2 ]
#then
#cd ${OUTPUTdir}/grib2/CG2
#KEEP=2
#COUNT=$(ls -1 | wc -l)
#TRIM=$(expr $COUNT - $KEEP)
#if [[ $TRIM -gt 0 ]]
#then
#    for i in $(ls -1 | head -n $TRIM)
#    do
#        echo -n ": "                        | tee -a $logfile
#        rm -vf $i                           | tee -a $logfile
#    done
#fi
#echo "Done" | tee -a $logfile

#echo " " | tee -a $logfile
#fi

#if [ -e ${OUTPUTdir}/grib2/CG3 ]
#then
#cd ${OUTPUTdir}/grib2/CG3
#KEEP=2
#COUNT=$(ls -1 | wc -l)
#TRIM=$(expr $COUNT - $KEEP)
#if [[ $TRIM -gt 0 ]]
#then
#    for i in $(ls -1 | head -n $TRIM)
#    do
#        echo -n ": "                        | tee -a $logfile
#        rm -vf $i                           | tee -a $logfile
#    done
#fi
#echo "Done" | tee -a $logfile#
#
#echo " " | tee -a $logfile
#fi
#
#if [ -e ${OUTPUTdir}/grib2/CG4 ]
#then
#cd ${OUTPUTdir}/grib2/CG4
#KEEP=2
#COUNT=$(ls -1 | wc -l)
#TRIM=$(expr $COUNT - $KEEP)
#if [[ $TRIM -gt 0 ]]
#then
#    for i in $(ls -1 | head -n $TRIM)
#    do
#        echo -n ": "                        | tee -a $logfile
#        rm -vf $i                           | tee -a $logfile
#    done
#fi
#echo "Done" | tee -a $logfile
#
#echo " " | tee -a $logfile
#fi
#
#if [ -e ${OUTPUTdir}/grib2/CG5 ]
#then
#cd ${OUTPUTdir}/grib2/CG5
#KEEP=2
#COUNT=$(ls -1 | wc -l)
#TRIM=$(expr $COUNT - $KEEP)
#if [[ $TRIM -gt 0 ]]
#then
#    for i in $(ls -1 | head -n $TRIM)
#    do
#        echo -n ": "                        | tee -a $logfile
#        rm -vf $i                           | tee -a $logfile
#    done
#fi
#echo "Done" | tee -a $logfile
#
#echo " " | tee -a $logfile
#fi

################################################################### 
echo "Cleaning out hdf5/CG directories:"           | tee -a $logfile
cd ${OUTPUTdir}/hdf5/CG1
KEEP=2
COUNT=$(ls -1 | wc -l)
TRIM=$(expr $COUNT - $KEEP)
if [[ $TRIM -gt 0 ]]
then
    for i in $(ls -1 | head -n $TRIM)
    do
        echo -n ": "                        | tee -a $logfile
        rm -vf $i                           | tee -a $logfile
    done
fi
echo "Done" | tee -a $logfile

echo " " | tee -a $logfile

if [ -e ${OUTPUTdir}/hdf5/CG2 ]
then
cd ${OUTPUTdir}/hdf5/CG2
KEEP=2
COUNT=$(ls -1 | wc -l)
TRIM=$(expr $COUNT - $KEEP)
if [[ $TRIM -gt 0 ]]
then
    for i in $(ls -1 | head -n $TRIM)
    do
        echo -n ": "                        | tee -a $logfile
        rm -vf $i                           | tee -a $logfile
    done
fi
echo "Done" | tee -a $logfile

echo " " | tee -a $logfile
fi

if [ -e ${OUTPUTdir}/hdf5/CG3 ]
then
cd ${OUTPUTdir}/hdf5/CG3
KEEP=2
COUNT=$(ls -1 | wc -l)
TRIM=$(expr $COUNT - $KEEP)
if [[ $TRIM -gt 0 ]]
then
    for i in $(ls -1 | head -n $TRIM)
    do
        echo -n ": "                        | tee -a $logfile
        rm -vf $i                           | tee -a $logfile
    done
fi
echo "Done" | tee -a $logfile

echo " " | tee -a $logfile
fi

if [ -e ${OUTPUTdir}/hdf5/CG4 ]
then
cd ${OUTPUTdir}/hdf5/CG4
KEEP=2
COUNT=$(ls -1 | wc -l)
TRIM=$(expr $COUNT - $KEEP)
if [[ $TRIM -gt 0 ]]
then
    for i in $(ls -1 | head -n $TRIM)
    do
        echo -n ": "                        | tee -a $logfile
        rm -vf $i                           | tee -a $logfile
    done
fi
echo "Done" | tee -a $logfile

echo " " | tee -a $logfile
fi

if [ -e ${OUTPUTdir}/hdf5/CG5 ]
then
cd ${OUTPUTdir}/hdf5/CG5
KEEP=2
COUNT=$(ls -1 | wc -l)
TRIM=$(expr $COUNT - $KEEP)
if [[ $TRIM -gt 0 ]]
then
    for i in $(ls -1 | head -n $TRIM)
    do
        echo -n ": "                        | tee -a $logfile
        rm -vf $i                           | tee -a $logfile
    done
fi
echo "Done" | tee -a $logfile

echo " " | tee -a $logfile
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
elif [ $NWPSplatform == "WCOSS" ]
then
  NWPSDATA="${DATA}"
fi

# echo "NWPSDATA is: $NWPSDATA. Cleaning old tracking netcdf files."

# if [ -e ${NWPSDATA}/var/${siteid}.tmp/CG1 ]
# then
# cd ${NWPSDATA}/var/${siteid}.tmp/CG1
# KEEP=2
# COUNT=$(ls -1 | wc -l)
# TRIM=$(expr $COUNT - $KEEP)
# if [[ $TRIM -gt 0 ]]
# then
 #    for i in $(ls -1 | head -n $TRIM)
#     do
#        echo -n ": "                        | tee -a $logfile
#        rm -vf $i                           | tee -a $logfile
#    done
# fi
#echo "Done" | tee -a $logfile

#echo " " | tee -a $logfile
#fi

################################################################### 
echo "HANDLE LOCK FILE"                             | tee -a $logfile
echo "DONE"

echo " " | tee -a $logfile
################################################################### 
echo " "                                            | tee -a $logfile
echo "===================================="         | tee -a $logfile
echo "Done running NWPS"                            | tee -a $logfile
date "+%D  %H:%M:%S"                                | tee -a $logfile
echo "===================================="         | tee -a $logfile
echo " "                                            | tee -a $logfile

source ${USHnwps}/calc_runtime.sh
echo " " | tee -a $logfile

date +%s > ${VARdir}/total_end_secs.txt
START=$(cat ${VARdir}/total_start_secs.txt)
FINISH=$(cat ${VARdir}/total_end_secs.txt)
PROCNAME="NWPS package"
calc_runtime ${START} ${FINISH} "${PROCNAME}"| tee -a $logfile

echo " " | tee -a $logfile

cd ${DATA}/
exit 0

#!/bin/bash
set -xa
# ----------------------------------------------------------- 
# UNIX Shell Script File
# Tested Operating System(s): RHEL 5,6
# Tested Run Level(s): 3, 5
# Shell Used: BASH shell
# Original Author(s): Alex Gibbs, Tony Freeman, Pablo Santos, Douglas Gaer
# File Creation Date: 06/01/2009
# Date Last Modified: 11/18/2014
#
# Version control: 1.14
#
# Support Team:
#
# Contributors: Roberto Padilla-Hernandez
#
# ----------------------------------------------------------- 
# ------------- Program Description and Details ------------- 
# ----------------------------------------------------------- 
#
# Script used to setup an NWPS domain for SWAN and WW3 
#
# ----------------------------------------------------------- 

# Check to see if our SITEID is set
if [ "${SITEID}" == "" ]
    then
    echo "ERROR - Your SITEID variable is not set"
    export err=1; err_chk
fi

# Setup our NWPS environment                                                    
if [ "${HOMEnwps}" == "" ]
    then 
    echo "ERROR - Your NWPSdir variable is not set"
    export err=1; err_chk
fi

PROGRAMNAME=setup.sh
mkdir -p ${LOGdir}
LOGFILE=${LOGdir}/domain_setup.log
cat /dev/null > ${LOGdir}/domain_setup.log

NUMCPUS=$(cat /proc/cpuinfo | grep processor | wc -l | tr -d " ")
JETLAG=$(expr $(date -u +%H) - $(date +%H))
YMD=$(date +%Y%m%d)
YMDHM=$(date +%Y%m%d%H%M)

### FUNCTIONS AREA ##################################
function logit () {
    echo "$@" | tee -a ${LOGFILE}
}

#function get_wd () {
#    CWD=$1
#    COUNT=$(echo $CWD | tr "/" " " | wc -w)
#    PROGRAM=$(echo $CWD | tr "/" " " | awk "{ print \$$COUNT }")
#    PATHTEST=$(echo "$CWD" | sed -e "s#/$PROGRAM##g")
#    if [[ $PATHTEST == "./" || $PATHTEST == "" || $PATHTEST == "." ]]
#    then
#	WD="."
#    else
#	WD="$PATHTEST"
#    fi
#    if [[ $WD == "." ]]
#    then
#	WD=$(pwd)
#    fi
#}

#function check_pwd () {
#    get_wd $0
#    cd $WD
#    if [[ ! -f $PROGRAMNAME ]]
#    then
#	logit " "
#	logit "Unable to find $PROGRAMNAME"
#	logit " "
#	logit "Please execute $PROGRAMNAME from the directory in which it resides"
#	logit " "
#	logit "Example: "
#	logit "         cd ${DATA}/"
#	logit "         ${USHnwps}/setup.sh"
#	logit " "
#	logit "Exiting ... "
#	logit " "
#	export err=1; err_chk
#    else
#	echo "found $PROGRAMNAME in $WD ..." >> ${LOGFILE}
#    fi
#}

function get_sid () {
    clear
    logit " "
    logit " "
    logit "---------------------------------------------------------------------"
    logit " "
    logit "Please enter your Site ID in lowercase. Example: tae"
    logit " "
    read -p "Enter the Site ID in lowercase letters: " BLAH
    MYSID=$BLAH
    if [[ -z $MYSID ]]
    then
        logit "MYSID is not present. Please correct this problem."
        logit "Exiting ..."
        export err=1; err_chk
    fi
    LSID=$(echo "$MYSID" | tr "[A-Z]" "[a-z]")
    USID=$(echo "$MYSID" | tr "[a-z]" "[A-Z]")
}

function get_rid () {
    clear
    logit " "
    logit " "
    logit "---------------------------------------------------------------------"
    logit " "
    logit "Please enter your Region ID in lowercase. Example: sr"
    logit " "
    logit "NWS Region IDs are:"
    logit "al - Alaska Region"
    logit "cr - Central Region, Great Lakes"
    logit "er - Eastern Region"
    logit "gr - Eastern Region, Great Lakes"
    logit "pr - Pacific Region"
    logit "sr - Southern Region"
    logit "wr - Western Region" 
    logit " "
    read -p "Enter the Site ID in lowercase letters: " BLAH
    MYRID=$BLAH
    
    if [[ -z $MYRID ]]
    then
        logit "MYRID is not present. Please correct this problem."
        logit "Exiting ..."
        export err=1; err_chk
    fi
    LRID=$(echo "$MYRID" | tr "[A-Z]" "[a-z]")
    URID=$(echo "$MYRID" | tr "[a-z]" "[A-Z]")
}

function get_modeltype () {
    clear
    MODEL=NONE
    while [[ "$MODEL" != "SWAN" && "$MODEL" != "UNSWAN" && "$MODEL" != "WW3" ]]
    do
       logit " "
       logit " "
       logit "---------------------------------------------------------------------"
       logit "Enter the name of the Wave Model you want to run (SWAN, UNSWAN or WW3).  Example:SWAN "
       logit " "
       read -p ": " BLAH
    
    MODEL=$BLAH
    BLAH=""
    
    done
}
function get_ne_lat () {
    clear
    logit " "
    logit " "
    logit "---------------------------------------------------------------------"
    logit " "
    logit "Enter the North East Latitude.  Example: 30.50"
    logit " "
    read -p "Enter the NE Latitude: " BLAH
    BLAH=$(echo "$BLAH + 0.0" | bc | tr -d "-") 
    BLAH=$(printf "%.02f" $BLAH)
    if [[ $BLAH == "0.00" ]]
    then
	logit " "
	logit "Sorry. I cannot determine [ $BLAH ] to be a valid lat/lon point"
	logit " "
	logit "Exiting ... "
	logit " "
	export err=1; err_chk
    else
	NELAT="$BLAH"
    fi
    BLAH=""
}

function get_ne_lon () {
    clear
    logit " "
    logit " "
    logit "---------------------------------------------------------------------"
    logit " "
    logit "Enter the North East Longitude.  Example: 82.30"
    logit " "
    read -p "Enter the NE Longitude: " BLAH
    BLAH=$(echo "$BLAH + 0.0" | bc | tr -d "-") 
    BLAH=$(printf "%.02f" $BLAH)
    if [[ $BLAH == "0.00" ]]
    then
        logit " "
        logit "Sorry. I cannot determine [ $BLAH ] to be a valid lat/lon point"
        logit " "
        logit "Exiting ... "
        logit " "
        export err=1; err_chk
    else 
        NELON="$BLAH"
	NELONCIRC=$(echo "360.00 - $BLAH" | bc)
    fi
    BLAH=""
}

function get_sw_lat () {
    clear
    logit " "
    logit " "
    logit "---------------------------------------------------------------------"
    logit " "
    logit "Enter the South West Latitude.  Example: 27.50"
    logit " "
    read -p "Enter the SW Latitude: " BLAH
    BLAH=$(echo "$BLAH + 0.0" | bc | tr -d "-") 
    BLAH=$(printf "%.02f" $BLAH)
    if [[ $BLAH == "0.00" ]]
    then
        logit " "
        logit "Sorry. I cannot determine [ $BLAH ] to be a valid lat/lon point"
        logit " "
        logit "Exiting ... "
        logit " "
        export err=1; err_chk
    else 
        SWLAT="$BLAH"
    fi
    BLAH=""
}

function get_sw_lon () {
    clear
    logit " "
    logit " "
    logit "---------------------------------------------------------------------"
    logit " "
    logit "Enter the South West Longitude.  Example: 88.20"
    logit " "
    read -p "Enter the SW Longitude: " BLAH
    BLAH=$(echo "$BLAH + 0.0" | bc | tr -d "-") 
    BLAH=$(printf "%.02f" $BLAH)
    if [[ $BLAH == "0.00" ]]
    then
        logit " "
        logit "Sorry. I cannot determine [ $BLAH ] to be a valid lat/lon point"
        logit " "
        logit "Exiting ... "
        logit " "
        export err=1; err_chk
    else 
        SWLON="$BLAH"
        SWLONCIRC=$(echo "360.00 - $BLAH" | bc)
    fi
    BLAH=""
}

function get_res () {
    clear
    logit " "
    logit " "
    logit "---------------------------------------------------------------------"
    logit " "
    logit "Enter the Desired Resolution.  Example: 1.5 for 1.5 km (recommended)"
    logit " "
    read -p "Enter the spatial resolution: " BLAH
    BLAH=$(echo "$BLAH + 0.0" | bc | tr -d "-")
    BLAH=$(printf "%.02f" $BLAH)
    if [[ $BLAH == "0.00" ]]
    then
        logit " "
        logit "Sorry. I cannot determine [ $BLAH ] to be a valid entry"
        logit " "
        logit "Exiting ... "
        logit " "
        export err=1; err_chk
    else
        RES="$BLAH"
    fi
    BLAH=""
}

function get_time_step () {
    clear
    logit " "
    logit " "
    logit "---------------------------------------------------------------------"
    logit " "
    logit "Enter the Desired Time Step.  Example: 3 for 3 hours (recommended)"
    logit " "
    read -p "Enter the Desired Time Step for SWAN Runs: " BLAH
    if [[ $BLAH == "0" ]]
    then
        logit " "
        logit "Sorry. I cannot determine [ $BLAH ] to be a valid entry"
        logit " "
        logit "Exiting ... "
        logit " "
        export err=1; err_chk
    else
        TSTEP="$BLAH"
    fi
    BLAH=""
}
################################################################################
#funcion get_coord_spc1d                                                       #
#Goal: To read the coordinates and name of one or several locations where the  #
#      user wants to have 1D spectra from the wave model                       #
#                                                                              #
#Written by   :  Roberto Padilla-Hernandez  EMC/NCEP/MMAB/IMSG                 #
#Base on      :  createHeader subroutine                                       #
#Explanation:                                                                  #
# Ask to the user for the number (NUMSPC) of output locations for 1D spectra.  #
# Read the Longitude, Latitud and Name of every location.                      #
# Those data are introduced to the SWAN input file (inputCG#) by the main      #
# program (setup.sh)                                                           #
#first written: 04/20/11                                                       #
#last update: ----                                                             #
#                                                                              #
################################################################################
function get_coord_spc1d () {
    clear
    spclons=""
    spclats=""
    spcnames=""
    logit " "
    logit " "
    logit "---------------------------------------------------------------------"
    logit "Enter the NUMBER OF POINTS FOR WAVE PARTITION (GERLING-HANSON PLOTS) & OUTPUT SPECTRA.  Example: 4 "
    logit " "
    read -p ": " BLAH
    
    NUMSPC=$BLAH
    numofchars=0
    BLAH=""
    
       #LOOP OVER THE NUMBER OF SPECTRA
    x=1
    while [ $x -le $NUMSPC ]
    do
        clear
        logit " "
        logit "----------------------------------------------------------------------------"
        logit " "
        if [ $numofchars -gt "8" ];then
            logit "**************************************************************"
            logit "*****Name HAS MORE THAN 8 CHARACTERS. IT HAS: $numofchars *****"
            logit "**************************************************************"
        fi
        logit "Enter the West Longitude, Latitude and Name (NO MORE THAN 8 CHARACTERS LONG)"
        logit " of the output spectra location number --$x--"   
        logit " Example: 88.50  22.40 BUOY304c"
	    logit " "
	    read -p " " BLAH BLAHLA BLAHNAME
        BLAHLO=$(echo "360.00 - $BLAH" | bc)
        numofchars=${#BLAHNAME}
        if [ $numofchars -le "8" ];then
            spclons[$x]=$BLAHLO
            spclats[$x]=$BLAHLA
            spcnames[$x]=$BLAHNAME
            BLAH="";BLAHLO=""; BLAHLA=""; BLAHNAME=""
            numofchars=0
            x=$(( $x + 1 ))
        fi
        logit "Counter: $x"
    done
    logit "LONGITUDES: ${spclons[*]}  "
    logit "LATITUDES : ${spclats[*]}  "
    logit "LOC. NAMES: ${spcnames[*]}  "
}

################################################################################
#funcion edit_input_for_blockout                                               #
#Goal: To include block output lines. In the case of regular grids, this is    #
#      done with a frame with dimensions of the COMPGRID. For unstructured     #
#      meshes, this is written to the native mesh COMPGRID in netcdf4 format.  #
#                                                                              #
#Written by   :  Andre van der Westhuysen  EMC/NCEP/MMAB/IMSG                  #
#Base on      :                                                                #
#Explanation:                                                                  #
# The ouput locations (names, longs and lats) command lines are introduced     #
# to the wave input file (inputCG#)                                            #
#                                                                              #
#first written: 05/12/17                                                       #
#last update: 05/12/2017
#                                                                              #
################################################################################
function edit_inputCG_for_blockout () {
    if [ "${MODELCORE}" == "UNSWAN" ]; then
       # For UNSTRUC mode we output the mesh in netCDF format, and extract the AWIPS grids with swn_reginterpCG1.py
       # In the postproc step (GraphicOutput.pm) we will pack this mesh at the FRAMECG1 resolution.
       #AW lineprt1="BLOCK 'COMPGRID' NOHEAD 'CG_UNSTRUC.nc' LAY 3 XP YP HSIG WIND TPS DIR PDIR VEL WATL HSWE WLEN DEPTH \&"
       lineprt1="BLOCK 'COMPGRID' NOHEAD 'CG_UNSTRUC.nc' LAY 3 XP YP HSIG WIND TPS DIR PDIR VEL WATL HSWE \&"
       lineprt2="OUTPUT 20100301.1800 #TSTEP#.0 HR"
       lineprt3="$ FRAMECG1 'OUTGRID' #SWLONCIRC# #SWLAT# 0. #XLENC# #YLENC# #MESHLON# #MESHLAT#"
       lineprt4="$ FRAMECG2 'OUTGRID' #SWLONCIRCN1# #SWLATN1# 0. #XLENCN1# #YLENCN1# #MESHLONN1# #MESHLATN1#"
       lineprt5="$ FRAMECG3 'OUTGRID' #SWLONCIRCN2# #SWLATN2# 0. #XLENCN2# #YLENCN2# #MESHLONN2# #MESHLATN2#"
       lineprt6="$ FRAMECG4 'OUTGRID' #SWLONCIRCN3# #SWLATN3# 0. #XLENCN3# #YLENCN3# #MESHLONN3# #MESHLATN3#"
       lineprt7="$ FRAMECG5 'OUTGRID' #SWLONCIRCN4# #SWLATN4# 0. #XLENCN4# #YLENCN4# #MESHLONN4# #MESHLATN4#"
       sed -i "s/$ BLOCK UNSTRUC LINE01/${lineprt1}/g" inputCG1
       sed -i "s/$ BLOCK UNSTRUC LINE02/${lineprt2}/g" inputCG1
       sed -i "s/$ BLOCK UNSTRUC LINE03/${lineprt3}/g" inputCG1
       sed -i "s/$ BLOCK UNSTRUC LINE04/${lineprt4}/g" inputCG1
       sed -i "s/$ BLOCK UNSTRUC LINE05/${lineprt5}/g" inputCG1
       sed -i "s/$ BLOCK UNSTRUC LINE06/${lineprt6}/g" inputCG1
       sed -i "s/$ BLOCK UNSTRUC LINE07/${lineprt7}/g" inputCG1
    else
       lineprt1="FRAME 'OUTGRID' #SWLONCIRC# #SWLAT# 0. #XLENC# #YLENC# #MESHLON# #MESHLAT#"
       lineprt2="BLOCK 'OUTGRID' NOHEAD 'HSIG.CG1.CGRID' LAY 3 HSIG OUTPUT 20100301.1800 #TSTEP#.0 HR"
       lineprt3="BLOCK 'OUTGRID' NOHEAD 'WIND.CG1.CGRID' LAY 3 WIND OUTPUT 20100301.1800 #TSTEP#.0 HR"
       lineprt4="BLOCK 'OUTGRID' NOHEAD 'TPS.CG1.CGRID' LAY 3 TPS OUTPUT 20100301.1800 #TSTEP#.0 HR"
       lineprt5="BLOCK 'OUTGRID' NOHEAD 'DIR.CG1.CGRID' LAY 3 DIR OUTPUT 20100301.1800 #TSTEP#.0 HR"
       lineprt6="BLOCK 'OUTGRID' NOHEAD 'PDIR.CG1.CGRID' LAY 3 PDIR OUTPUT 20100301.1800 #TSTEP#.0 HR"
       lineprt7="BLOCK 'OUTGRID' NOHEAD 'VEL.CG1.CGRID' LAY 3 VEL OUTPUT 20100301.1800 #TSTEP#.0 HR"
       lineprt8="BLOCK 'OUTGRID' NOHEAD 'WATL.CG1.CGRID' LAY 3 WATL OUTPUT 20100301.1800 #TSTEP#.0 HR"
       lineprt9="BLOCK 'OUTGRID' NOHEAD 'HSWE.CG1.CGRID' LAY 3 HSWE OUTPUT 20100301.1800 #TSTEP#.0 HR"
       #AW lineprt10="BLOCK 'OUTGRID' NOHEAD 'WLEN.CG1.CGRID' LAY 3 WLEN OUTPUT 20100301.1800 #TSTEP#.0 HR"
       #AW lineprt11="BLOCK 'OUTGRID' NOHEAD 'DEPTH.CG1.CGRID' LAY 3 DEPTH OUTPUT 20100301.1800 #TSTEP#.0 HR"
       sed -i "s/$ BLOCK REG LINE01/${lineprt1}/g" inputCG1
       sed -i "s/$ BLOCK REG LINE02/${lineprt2}/g" inputCG1
       sed -i "s/$ BLOCK REG LINE03/${lineprt3}/g" inputCG1
       sed -i "s/$ BLOCK REG LINE04/${lineprt4}/g" inputCG1
       sed -i "s/$ BLOCK REG LINE05/${lineprt5}/g" inputCG1
       sed -i "s/$ BLOCK REG LINE06/${lineprt6}/g" inputCG1
       sed -i "s/$ BLOCK REG LINE07/${lineprt7}/g" inputCG1
       sed -i "s/$ BLOCK REG LINE08/${lineprt8}/g" inputCG1
       sed -i "s/$ BLOCK REG LINE09/${lineprt9}/g" inputCG1
       #AW sed -i "s/$ BLOCK REG LINE10/${lineprt10}/g" inputCG1
       #AW sed -i "s/$ BLOCK REG LINE11/${lineprt11}/g" inputCG1
    fi
}

################################################################################
#funcion get_coord_hsplots                                                     #
#Goal: get the proper flags if the users wants or not hanson plots             #
#      If Hanson plots, then ask for coordinates of output location            #
#                                                                              #
#Written by   :  Roberto Padilla-Hernandez  EMC/NCEP/MMAB/IMSG                 #
#Base on      :                                                                #
#Explanation:                                                                  #
# If the user wants hanson plots then the subroutine reads the coordinates and #
# name of the locations where the user wants to have the wave partition and    #
# the corresponding hanson plots                                               #
# Those data are introduced to the user-defined input file (inputCG#)          #
# program (setup.sh)                                                           #
#                                                                              #
# first written: 06/02/11                                                      #
# last update: 08/27/2011
#                                                                              #
################################################################################
function get_coord_hsplots () {
    HSFLAGS[0]="n"
    HSFLAGS[1]="n"
    HSFLAGS[2]="n"
    NUMPRT=0
    clear
    logit " "
    logit "----------------------------------------------------------------------------"
    logit " "
    logit "Do you want Hanson Plots in some locations?"
    logit " y or n "
    logit " "
    read -p ": " hspyorn
    logit $hspyorn
    if [ $hspyorn == "y" ];
    then
        HSFLAGS[0]="y"
        HSFLAGS[1]="y"
        HSFLAGS[2]="y"
        prtlons=""
        prtlats=""
        prtnames=""
        clear
	    logit " "
        logit "---------------------------------------------------------------------"
        logit "You can repeat name and coordinates from output spectra location "
	    logit "but you can NOT use same name with different coordinates"
	    logit "You CAN give different name repeating coordinates from spectral locations "
	    logit " "
	    logit "Enter the Number of locations for Hanson Plots. Example: 4 "
        logit " "
	    read -p ": " BLAH
        NUMPRT=$BLAH
        numofchars=0
 	    BLAH=""
           #LOOP OVER THE NUMBER OF OUTPUT LOCATIONS
        x=1
        while [ $x -le $NUMPRT ]
        do
            clear
            logit " "
            logit "----------------------------------------------------------------------------"
            logit " "
            if [ $numofchars -gt "8" ];then
                logit "**************************************************************"
                logit "*****Name HAS MORE THAN 8 CHARACTERS. IT HAS: $numofchars *****"
                logit "**************************************************************"
            fi
            logit "Enter the West Longitude, Latitude and Name (NO MORE THAN 8 CHARACTERS LONG)"
            logit " of the output partition location  number --$x--"   
            logit " Example: 88.50  22.40 BUOYXZ1c"
	        logit " "
	        read -p " " BLAH BLAHLA BLAHNAME
            BLAHLO=$(echo "360.00 - $BLAH" | bc)
            numofchars=${#BLAHNAME}
            if [ $numofchars -le "8" ];then
                prtlons[$x]=$BLAHLO
                prtlats[$x]=$BLAHLA
                prtnames[$x]=$BLAHNAME
                BLAH="";BLAHLO=""; BLAHLA=""; BLAHNAME=""
                numofchars=0
                x=$(( $x + 1 ))
            fi
        done
    fi
}

################################################################################
#funcion edit_input_for_partition                                              #
#Goal: To include in the wave model user-input file the locations for partition#
#      output and the parameters required by the user                          #
#                                                                              #
#Written by   :  Roberto Padilla-Hernandez  EMC/NCEP/MMAB/IMSG                 #
#Base on      :                                                                #
#Explanation:                                                                  #
# The ouput locations (names, longs and lats) command lines are introduced     #
# to the wave input file (inputCG#)                                            #
#                                                                              #
#first written: 06/06/11                                                       #
#last update: 08/27/2011
#                                                                              #
################################################################################
function edit_inputCG_for_partition () {
    if [ $hspyorn == "y" ]; then
       if [ $WVTONCG -eq 1 ]; then
          lineprt1="BLOCK 'COMPGRID' HEADER 'swan_part.CG1.raw' LAY 3 PARTITIONS OUTPUT 20100301.1800 #TSTEP#.0 HR"
          sed -i "/$PARTITION OUTCOMMANDS/ a $lineprt1" inputCG1
       else
          lineprt2="BLOCK 'RAWGRID' HEADER 'swan_part.CG1.raw' LAY 3 PARTITIONS OUTPUT 20100301.1800 #TSTEP# HR"
          sed -i "/$PARTITION OUTCOMMANDS/ a $lineprt2" inputCG1
          lineprt1="FRAME 'RAWGRID' #SWLONCIRCWT# #SWLATWT# 0. #XLENWT# #YLENWT# #MESHLONWT# #MESHLATWT#"
          sed -i "/$PARTITION OUTCOMMANDS/ a $lineprt1" inputCG1
       fi
#THIS PART IS READY TO ACTIVATE THE WAVE PARTITION IN SWAN FOR THE NESTED GRIDS
#, NEEDS TO BE TESTED 	JUST UNCOMMENT THE LINES
#       if [ -f "inputCG2" ];then
#          lineprtN1="BLOCK 'COMPGRID' HEADER 'swan_part.CG2.raw' LAY 3 PARTITIONS OUTPUT 20100301.1800 #TSTEP# HR"
#          sed -i "/$PARTITION OUTCOMMANDS/ a $lineprtN1" inputCG2
#       fi
#       if [ -f "inputCG3" ];then
#          lineprtN1="BLOCK 'COMPGRID' HEADER 'swan_part.CG3.raw' LAY 3 PARTITIONS OUTPUT 20100301.1800 #TSTEP# HR"
#          sed -i "/$PARTITION OUTCOMMANDS/ a $lineprtN1" inputCG3
#       fi
#       if [ -f "inputCG4" ];then
#          lineprtN1="BLOCK 'COMPGRID' HEADER 'swan_part.CG4.raw' LAY 3 PARTITIONS OUTPUT 20100301.1800 #TSTEP# HR"
#          sed -i "/$PARTITION OUTCOMMANDS/ a $lineprtN1" inputCG4
#       fi
#       if [ -f "inputCG5" ];then
#          lineprtN1="BLOCK 'COMPGRID' HEADER 'swan_part.CG5.raw' LAY 3 PARTITIONS OUTPUT 20100301.1800 #TSTEP# HR"
#          sed -i "/$PARTITION OUTCOMMANDS/ a $lineprtN1" inputCG5
#       fi
#
#       if [ -f "inputCG6" ];then
#          lineprtN1="BLOCK 'COMPGRID' HEADER 'swan_part.CG6.raw' LAY 3 PARTITIONS OUTPUT 20100301.1800 #TSTEP# HR"
#          sed -i "/$PARTITION OUTCOMMANDS/ a $lineprtN1" inputCG6
#       fi
#
#       if [ -f "inputCG7" ];then
#          lineprtN1="BLOCK 'COMPGRID' HEADER 'swan_part.CG7.raw' LAY 3 PARTITIONS OUTPUT 20100301.1800 #TSTEP# HR"
#          sed -i "/$PARTITION OUTCOMMANDS/ a $lineprtN1" inputCG7
#       fi
#       if [ -f "inputCG8" ];then
#          lineprtN1="BLOCK 'COMPGRID' HEADER 'swan_part.CG8.raw' LAY 3 PARTITIONS OUTPUT 20100301.1800 #TSTEP# HR"
#          sed -i "/$PARTITION OUTCOMMANDS/ a $lineprtN1" inputCG8
#       fi
#
#       if [ -f "inputCG9" ];then
#          lineprtN1="BLOCK 'COMPGRID' HEADER 'swan_part.CG9.raw' LAY 3 PARTITIONS OUTPUT 20100301.1800 #TSTEP# HR"
#          sed -i "/$PARTITION OUTCOMMANDS/ a $lineprtN1" inputCG9
#       fi
#
#       if [ -f "inputCG10" ];then
#          lineprtN1="BLOCK 'COMPGRID' HEADER 'swan_part.CG10.raw' LAY 3 PARTITIONS OUTPUT 20100301.1800 #TSTEP# HR"
#          sed -i "/$PARTITION OUTCOMMANDS/ a $lineprtN1" inputCG10
#       fi
    fi
}

################################################################################
function edit_inputCG_for_currents () {
    if [ "${CURRL1}" != "" ]; then
            sed -i "/$ CURR STARTS HERE/ a ${CURRL1}" inputCG1
            sed -i "/$ CURR ENDS HERE/ a ${CURRL2}" inputCG1
            sed -i '/$ CURR STARTS HERE/d ' inputCG1
            sed -i '/$ CURR ENDS HERE/d ' inputCG1
# NEST GRID 1
            sed -i "/$ CURR STARTS HERE/ a ${CURRL1}" inputCG2
            sed -i "/$ CURR ENDS HERE/ a ${CURRL2}" inputCG2
            sed -i '/$ CURR STARTS HERE/d ' inputCG2
            sed -i '/$ CURR ENDS HERE/d ' inputCG2
# NEST GRID 2
            sed -i "/$ CURR STARTS HERE/ a ${CURRL1}" inputCG3
            sed -i "/$ CURR ENDS HERE/ a ${CURRL2}" inputCG3
            sed -i '/$ CURR STARTS HERE/d ' inputCG3
            sed -i '/$ CURR ENDS HERE/d ' inputCG3
# NEST GRID 3
            sed -i "/$ CURR STARTS HERE/ a ${CURRL1}" inputCG4
            sed -i "/$ CURR ENDS HERE/ a ${CURRL2}" inputCG4
            sed -i '/$ CURR STARTS HERE/d ' inputCG4
            sed -i '/$ CURR ENDS HERE/d ' inputCG4
# NEST GRID 4
            sed -i "/$ CURR STARTS HERE/ a ${CURRL1}" inputCG5
            sed -i "/$ CURR ENDS HERE/ a ${CURRL2}" inputCG5
            sed -i '/$ CURR STARTS HERE/d ' inputCG5
            sed -i '/$ CURR ENDS HERE/d ' inputCG5
    fi
}

################################################################################
function confirm_values () {
    clear
    logit " "
    logit " "
    logit "---------------------------------------------------------------------"
    logit "CONFIRM VALUES AND INSTALL"
    logit "---------------------------------------------------------------------"
    logit " "
    logit "Your Site ID                 = $LSID"
    logit "Your Region ID               = $LSID"
    logit " "
    logit "NE LATITUDE                  = $NELAT"
    logit "NE LONGITUDE                 = $NELON  (Spherical Coord = $NELONCIRC)"
    logit "SW LATITUDE                  = $SWLAT"
    logit "SW LONGITUDE                 = $SWLON  (Spherical Coord = $SWLONCIRC)"
    logit "GEOGRAPH. RESOLUTION         = $RES KM"
    logit "WAVE MODEL OUTPUT TIME STEP  = $TSTEP HR"
    logit " "
    if [ $NUMSPC -gt "0" ]
       then
       logit "$NUMSPC Locations for 1D-Spectra"  
       if [ $hspyorn == "y" ]; then
          logit "and Wave Tracking information"
       fi   
       logit "LONGITUDES: ${spclons[*]}  "
       logit "LATITUDES : ${spclats[*]}  "
       logit "LOC. NAMES: ${spcnames[*]}  "
    else
       logit " 1D-Spectra Information not required" 
    fi
    
#    logit " "
#    logit "This script is being ran from this directory: $WD"
    logit " "
    logit "Please check that the above information is correct before continuing"
    logit "---------------------------------------------------------------------"
    logit " "
    read -p "Press ENTER to continue with installation or Ctrl-C to exit: " BLAH
    BLAH=""
}

function auto_run()
{
    logit ""
    logit "Starting automatic domain setup "
    date -u | tee -a ${LOGFILE}
    if [ ! -e ${DOMAINFILE} ]
	then
    	logit "ERROR - Missing ${DOMAINFILE}"
    	logit "No automatic Setup was performed!"
    	export err=1; err_chk
    fi

    # The domain setup must contain
    # export SITEID="XXX"
    # export REGIONID="XX"
    # export NELAT="value"
    # export NELON="value"
    # export SWLAT="value"
    # export SWLON="value"
    # export RES="value"
    # export TSTEP="value"

    # Optional domain setup for specta points
    # export SEPCPOINTS="name1:lat:lon name2:lat:lon name3:lat:lon name4:lat:lon"
    NESTGRIDS=0
    source ${DOMAINFILE}
    echo " ${DOMAINFILE} "

    if [ ${NESTGRIDS} -eq 0 ] && [ ${NESTCG} == "Yes" ]; then
        echo " *************************************************************"
        echo " *   - - - - - - -  - - - - WARNING - - - - - - - - - - - - - "
        echo " * NESTGRIDS=${NESTGRIDS} NESTCG=${NESTCG}                    "
        echo " * --nest GIVEN AS AN ARGUMENT                                "
        echo " *                  BUT                                       "
        echo " * NESTED GRID INFO NOT IN $DOMAINFILE                        "  
        echo " * RUN WILL PROCEED WITH NO NESTED GRIDS                      "
        #export err=1; err_chk
        export NESTCG="NO"
        export NESTS="NO"
        echo " now :  NESTGRIDS=${NESTGRIDS} NESTCG=${NESTCG} NESTS=${NESTS}"
        echo " *************************************************************"
    fi

    if [[ -z $SITEID ]]
    then
        logit "ERROR - SITEID is not present. Please correct this problem."
	    logit "No automatic Setup was performed!"
        export err=1; err_chk
    fi
    LSID=$(echo ${SITEID} | tr [:upper:] [:lower:])
    USID=$(echo ${SITEID} | tr [:lower:] [:upper:])

    if [[ -z $REGIONID ]]
    then
        logit "ERROR - REGIONID is not present. Please correct this problem."
	    logit "No automatic Setup was performed!"
        export err=1; err_chk
    fi
    LRID=$(echo ${REGIONID} | tr [:upper:] [:lower:])
    URID=$(echo ${REGIONID} | tr [:lower:] [:upper:])

    if [[ -z $MODELTYPE ]]
    then
        logit "ERROR - MODELTYPE is not present. Please correct this problem."
	    logit "No automatic Setup was performed!"
        export err=1; err_chk
    fi
    LRMODEL=$(echo ${MODELCORE} | tr [:upper:] [:lower:])
    URMODEL=$(echo ${MODELCORE} | tr [:lower:] [:upper:])

    NELAT=$(echo "$NELAT + 0.0" | bc | tr -d "-") 
    NELAT=$(printf "%.02f" $NELAT)
    if [[ $NELAT == "0.00" ]]
    then
	    logit "ERROR - Cannot determine NELAT to be a valid lat/lon point"
	    logit "No automatic Setup was performed!"
	    export err=1; err_chk
    fi

    NELON=$(echo "$NELON + 0.0" | bc | tr -d "-") 
    NELON=$(printf "%.02f" $NELON)
    NELONCIRC=$(echo "360.00 - $NELON" | bc)
    if [[ $NELON == "0.00" ]]
    then
	    logit "ERROR - Cannot determine NELON to be a valid lat/lon point"
	    logit "No automatic Setup was performed!"
	    export err=1; err_chk
    fi

    SWLAT=$(echo "$SWLAT + 0.0" | bc | tr -d "-") 
    SWLAT=$(printf "%.02f" $SWLAT)
    if [[ $SWLAT == "0.00" ]]
    then
	    logit "ERROR - Cannot determine SWLAT to be a valid lat/lon point"
	    logit "No automatic Setup was performed!"
	    export err=1; err_chk
    fi

    SWLON=$(echo "$SWLON + 0.0" | bc | tr -d "-") 
    SWLON=$(printf "%.02f" $SWLON)
    SWLONCIRC=$(echo "360.00 - $SWLON" | bc)
    if [[ $SWLON == "0.00" ]]
    then
	    logit "ERROR - Cannot determine SWLON to be a valid lat/lon point"
	    logit "No automatic Setup was performed!"
	    export err=1; err_chk
    fi

    RES=$(echo "$RES + 0.0" | bc | tr -d "-")
    RES=$(printf "%.02f" $RES)
    if [[ $RES == "0.00" ]]
    then
        logit "ERROR - Cannot determine RES to be a valid entry"
	    logit "No automatic Setup was performed!"
	    export err=1; err_chk
    fi

    if [[ $TSTEP == "0" ]]
    	then
        logit "ERROR - Cannot determine TSTEP to be a valid entry"
		logit "No automatic Setup was performed!"
		export err=1; err_chk
    fi
# FOR NESTED GRID NUMBER 1 (COMUTATIONAL GRID NUMBER 2 -> CG2)
    if [ $NESTGRIDS -gt 0 ] && [ ${NESTCG} == "Yes" ]
    then
       for (( j = 1 ; j < ${NESTGRIDS}+1 ; j++ ))
       do
         if [ $j -eq 1 ]
         then
            NELATN[$j]=${NELATN1}
            NELONN[$j]=${NELONN1} 
            SWLATN[$j]=${SWLATN1}
            SWLONN[$j]=${SWLONN1}
            RESN[$j]=${RESN1}
            TSTEPN[$j]=${TSTEPN1}
            STATN[$j]=${STATN1}

         elif [ $j -eq 2 ]
         then
            NELATN[$j]=${NELATN2}
            NELONN[$j]=${NELONN2} 
            SWLATN[$j]=${SWLATN2}
            SWLONN[$j]=${SWLONN2}
            RESN[$j]=${RESN2}
            TSTEPN[$j]=${TSTEPN2}
            STATN[$j]=${STATN2}

         elif [ $j -eq 3 ]
         then
            NELATN[$j]=${NELATN3}
            NELONN[$j]=${NELONN3} 
            SWLATN[$j]=${SWLATN3}
            SWLONN[$j]=${SWLONN3}
            RESN[$j]=${RESN3}
            TSTEPN[$j]=${TSTEPN3}
            STATN[$j]=${STATN3}

         elif [ $j -eq 4 ]
         then
            NELATN[$j]=${NELATN4}
            NELONN[$j]=${NELONN4} 
            SWLATN[$j]=${SWLATN4}
            SWLONN[$j]=${SWLONN4}
            RESN[$j]=${RESN4}
            TSTEPN[$j]=${TSTEPN4}
            STATN[$j]=${STATN4}

         elif [ $j -eq 5 ]
         then
            NELATN[$j]=${NELATN5}
            NELONN[$j]=${NELONN5} 
            SWLATN[$j]=${SWLATN5}
            SWLONN[$j]=${SWLONN5}
            RESN[$j]=${RESN5}
            TSTEPN[$j]=${TSTEPN5}
            STATN[$j]=${STATN5}

         elif [ $j -eq 6 ]
         then
            NELATN[$j]=${NELATN6}
            NELONN[$j]=${NELONN6} 
            SWLATN[$j]=${SWLATN6}
            SWLONN[$j]=${SWLONN6}
            RESN[$j]=${RESN6}
            TSTEPN[$j]=${TSTEPN6}
            STATN[$j]=${STATN6}

         elif [ $j -eq 7 ]
         then
            NELATN[$j]=${NELATN7}
            NELONN[$j]=${NELONN7} 
            SWLATN[$j]=${SWLATN7}
            SWLONN[$j]=${SWLONN7}
            RESN[$j]=${RESN7}
            TSTEPN[$j]=${TSTEPN7}
            STATN[$j]=${STATN7}

         elif [ $j -eq 8 ]
         then
            NELATN[$j]=${NELATN8}
            NELONN[$j]=${NELONN8} 
            SWLATN[$j]=${SWLATN8}
            SWLONN[$j]=${SWLONN8}
            RESN[$j]=${RESN8}
            TSTEPN[$j]=${TSTEPN8}
            STATN[$j]=${STATN8}

         elif [ $j -eq 9 ]
         then
            NELATN[$j]=${NELATN9}
            NELONN[$j]=${NELONN9} 
            SWLATN[$j]=${SWLATN9}
            SWLONN[$j]=${SWLONN9}
            RESN[$j]=${RESN9}
            TSTEPN[$j]=${TSTEPN9}
            STATN[$j]=${STATN9}

         elif [ $j -eq 10 ]
         then
            NELATN[$j]=${NELATN10}
            NELONN[$j]=${NELONN10} 
            SWLATN[$j]=${SWLATN10}
            SWLONN[$j]=${SWLONN10}
            RESN[$j]=${RESN10}
            TSTEPN[$j]=${TSTEPN10}
            STATN[$j]=${STATN10}
         fi
          echo "${STATN[$j]}"
         if [[ ${STATN[$j]} == "STA" ]]
         then
           STATorNON="STATIONARY"
         else
           STATorNON="NONSTATIONARY"
         fi

         echo " "
         echo " "
         echo "             NESTED GRID: $j      "
         echo "     ${NELATN[$j]} -------------------  "
         echo "          |                  |  "
         echo "          |                  |  "
         echo "          |                  |  "
         echo "          |                  |  "
         echo "     ${SWLATN[$j]}-------------------- ="
         echo "          |                  |  "
         echo "        ${SWLONN[$j]}           ${NELONN[$j]} "
         echo "   "
         echo "       RESOLUTION:   ${RESN[$j]} KM "
         echo "            RUN  :   ${STATorNON}  " 
         echo " "
         echo " " 


         NELATN[j]=$(echo "${NELATN[j]} + 0.0" | bc | tr -d "-") 
         NELATN[j]=$(printf "%.02f" ${NELATN[j]})

         if [[ ${NELATN[j]} == "0.00" ]]
         then
           logit "ERROR - For nested grid: $j Cannot determine NELATN to be a valid lat/lon point"
           logit "No automatic Setup was performed!"
          export err=1; err_chk
         fi

         NELONN[$j]=$(echo "${NELONN[$j]} + 0.0" | bc | tr -d "-") 
         NELONN[$j]=$(printf "%.02f" ${NELONN[$j]})
         NELONCIRCN[$j]=$(echo "360.00 - ${NELONN[$j]}" | bc)
         if [[ ${NELONN[$j]} == "0.00" ]]
         then
            logit "ERROR - Cannot determine NELONN1 to be a valid lat/lon point"
	    	logit "No automatic Setup was performed!"
	    	export err=1; err_chk
         fi

         SWLATN[$j]=$(echo "${SWLATN[$j]} + 0.0" | bc | tr -d "-") 
         SWLATN[$j]=$(printf "%.02f" ${SWLATN[$j]})
         if [[ ${SWLATN[$j]} == "0.00" ]]
         then
	    logit "ERROR - Cannot determine SWLATN1 to be a valid lat/lon point"
	    logit "No automatic Setup was performed!"
	    export err=1; err_chk
         fi

         SWLONN[$j]=$(echo "${SWLONN[$j]} + 0.0" | bc | tr -d "-") 
         SWLONN[$j]=$(printf "%.02f" ${SWLONN[$j]})
         SWLONCIRCN[$j]=$(echo "360.00 - ${SWLONN[$j]}" | bc)
         if [[ ${SWLONN[$j]} == "0.00" ]]
         then
	    logit "ERROR - Cannot determine SWLONN1 to be a valid lat/lon point"
	    logit "No automatic Setup was performed!"
	    export err=1; err_chk
         fi

         RESN[$j]=$(echo "${RESN[$j]} + 0.0" | bc | tr -d "-")
         RESN[$j]=$(printf "%.02f" ${RESN[$j]})
         if [[ ${RESN[$j]} == "0.00" ]]
         then
            logit "ERROR - Cannot determine RESN1 to be a valid entry"
	    logit "No automatic Setup was performed!"
	    export err=1; err_chk
         fi

         if [[ ${TSTEPN[$j]} == "0" ]]
         then
            logit "ERROR - Cannot determine TSTEPN1 to be a valid entry"
	    logit "No automatic Setup was performed!"
	    export err=1; err_chk
         fi
       done
    fi
# END NESTED GRID NUMBER 1

    NUMSPC=0
    spclons=""
    spclats=""
    spcnames=""
    x=1
    if [ "${SPECPOINTS}" != "" ]
    then
        ###hspyorn="y"
	    for p in ${SPECPOINTS}
	    do
	        spname=$(echo ${p} | awk -F: '{ print $1 }')
	        splat=$(echo ${p} | awk -F: '{ print $2 }')
	        splat=$(echo "${splat} + 0.0" | bc | tr -d "-") 
            splat=$(printf "%.03f" ${splat})
	        splon=$(echo ${p} | awk -F: '{ print $3 }')
	        splon=$(echo "${splon} + 0.0" | bc | tr -d "-") 
            splon=$(printf "%.03f" ${splon})
	        if [ "${spname}" == "" ] || [ "$splat" == " 0.000" ] || [ "$splon" == " 0.000" ]
	        then
	            logit "ERROR - Bad specta point name:lat:lon value"
	            logit "No automatic Setup was performed!"
	            export err=1; err_chk
	        fi
	        splon=$(echo "360.000 - ${splon}" | bc)
	        spclons[$x]=$splon
            spclats[$x]=$splat
            spcnames[$x]=$spname
	        splon=""; splat=""; spname=""
	        x=$(( $x + 1))
	    done
	    NUMSPC=$(( $x - 1))
    fi

    #===============W A V E   T R A C K I N G  F R A M E =======================
    #Introducing wave tracking on/off Frame for wave partition and geographical 
    #resolution for wave partition and  wave tracking
    if [ "${WVTRCK}" = "ON" ]
    then
    hspyorn="y"
  if [ "${WVTONCG}" == "0" ]
    then
    NELATWT=$(echo "$NELATWT + 0.0" | bc | tr -d "-") 
    #NELATWT=$(printf "%.02f" $NELATWT)
    NELATWT=$(printf "%6.2f" $NELATWT)
    if [[ $NELATWT == "0.00" ]]
    then
	logit "ERROR - Cannot determine NELATWT to be a valid lat/lon point"
	logit "No automatic Setup was performed!"
	export err=1; err_chk
    fi

    NELONWT=$(echo "$NELONWT + 0.0" | bc | tr -d "-") 
    NELONWT=$(printf "%.02f" $NELONWT)
    NELONCIRCWT=$(echo "360.00 - $NELONWT" | bc)
    NELONCIRCWT=$(printf "%6.2f" $NELONCIRCWT)
    if [[ $NELONWT == "0.00" ]]
    then
	logit "ERROR - Cannot determine NELONWT to be a valid lat/lon point"
	logit "No automatic Setup was performed!"
	export err=1; err_chk
    fi

    SWLATWT=$(echo "$SWLATWT + 0.0" | bc | tr -d "-") 
    #SWLATWT=$(printf "%.02f" $SWLATWT)
    SWLATWT=$(printf "%6.2f" $SWLATWT)
    if [[ $SWLATWT == "0.00" ]]
    then
	logit "ERROR - Cannot determine SWLATWT to be a valid lat/lon point"
	logit "No automatic Setup was performed!"
	export err=1; err_chk
    fi

    SWLONWT=$(echo "$SWLONWT + 0.0" | bc | tr -d "-") 
    SWLONWT=$(printf "%.02f" $SWLONWT)
    SWLONCIRCWT=$(echo "360.00 - $SWLONWT" | bc)
    SWLONCIRCWT=$(printf "%6.2f" $SWLONCIRCWT)
    if [[ $SWLONWT == "0.00" ]]
    then
	logit "ERROR - Cannot determine SWLONWT to be a valid lat/lon point"
	logit "No automatic Setup was performed!"
	export err=1; err_chk
    fi

    GEORESWT=$(echo "$GEORESWT + 0.0" | bc | tr -d "-")
    GEORESWT=$(printf "%.02f" $GEORESWT)
    if [[ $GEORESWT == "0.00" ]]
        then
        logit "ERROR - Cannot determine GEORESWT to be a valid entry"
	logit "No automatic Setup was performed!"
	export err=1; err_chk
    fi


    distx=`perl ${USHnwps}/dist_lat_lon.pl $SWLATWT $SWLONWT $SWLATWT $NELONWT`
    disty=`perl ${USHnwps}/dist_lat_lon.pl $SWLATWT $SWLONWT $NELATWT $SWLONWT`
    MESHLATWT=$(echo "$disty/$GEORESWT" | bc)
    MESHLATWT=$(printf "%4d" $MESHLATWT)
    MESHLONWT=$(echo "$distx/$GEORESWT" | bc)
    MESHLONWT=$(printf "%4d" $MESHLONWT)
    XLENWT=$(echo "$NELONCIRCWT - $SWLONCIRCWT" | bc)
    YLENWT=$(echo "$NELATWT - $SWLATWT" | bc)
  fi

##############################################################
    if [ "${SPECPOINTS}" != "" ]
    then
	for p in ${SPECPOINTS}
	do
	    spname=$(echo ${p} | awk -F: '{ print $1 }')
	    splat=$(echo ${p} | awk -F: '{ print $2 }')
	    splat=$(echo "${splat} + 0.0" | bc | tr -d "-") 
            splat=$(printf "%.03f" ${splat})
	    splon=$(echo ${p} | awk -F: '{ print $3 }')
	    splon=$(echo "${splon} + 0.0" | bc | tr -d "-") 
            splon=$(printf "%.03f" ${splon})
	    splon=$(echo "360.000 - ${splon}" | bc)

#            echo "${splon}, ${splat} "
             
            Result1=$(echo "${splon} > ${NELONCIRC}" | bc )
            Result2=$(echo "${splon} < ${SWLONCIRC}" | bc )
            Result3=$(echo "${splat} > ${NELAT}" | bc )
            Result4=$(echo "${splat} < ${SWLAT}" | bc )
            #echo " ${Result1} ${Result2} ${Result3} ${Result4}"
	    if [ "${Result1}" == "1" ] || [ "${Result2}" == "1" ] || [ "${Result3}" == "1" ] || [ "${Result4}" == "1" ]
		then
                echo "*******************************************************"
		logit "ERROR - Spectral output location  (${splon},${splat}) "
                logit "Out of wave tracking geographical domain              "
		logit "No automatic Setup was performed!                     "
                echo "*******************************************************"
		export err=1; err_chk
	    fi
	done
    fi
##############################################################


fi

    logit "Automatic domain setup complete"
    logit "SITE ID                      = $USID"
    logit "site id                      = $LSID"
    logit "REGION ID                    = $URID"
    logit "region id                    = $LRID"
    logit "MODEL ID                     = $URMODEL"
    logit "model id                     = $LRMODEL"
    logit "NE LATITUDE                  = $NELAT"
    logit "NE LONGITUDE                 = $NELON  (Spherical Coord = $NELONCIRC)"
    logit "SW LATITUDE                  = $SWLAT"
    logit "SW LONGITUDE                 = $SWLON  (Spherical Coord = $SWLONCIRC)"
    logit "GEOGRAPH. RESOLUTION         = $RES KM"
    logit "WAVE MODEL OUTPUT TIME STEP  = $TSTEP HR"
    logit " "
    if [ $NUMSPC -gt "0" ]
       then
       logit "$NUMSPC Locations for 1D-Spectra"
       if [ $hspyorn == "y" ]; then
          logit "and Wave Tracking information"
       fi  
       logit "LONGITUDES: ${spclons[*]}  "
       logit "LATITUDES : ${spclats[*]}  "
       logit "LOC. NAMES: ${spcnames[*]}  "
    else
       logit "Wave Tracking Information not required" 
    fi


#    if [ $NESTGRIDS -eq 1 ] && [ $NESTCG == "Yes" ]
#       then
#       logit " "
#       logit "============== NESTED GRID 1 ===================="
#       logit "Automatic domain setup complete for NESTED GRID 1"
#       logit "NE LATITUDE                  = $NELATN1"
#       logit "NE LONGITUDE                 = $NELONN1  (Spherical Coord = $NELONCIRCN1)"
#       logit "SW LATITUDE                  = $SWLATN1"
#       logit "SW LONGITUDE                 = $SWLONN1  (Spherical Coord = $SWLONCIRCN1)"
#       logit "GEOGRAPH. RESOLUTION         = $RESN1 KM"
#       logit "WAVE MODEL OUTPUT TIME STEP  = $TSTEPN1 HR"
#       logit " "
#    fi
}

### PROGRAM LOGIC ###################################

echo "Checking ..." >> ${LOGFILE}
#check_pwd

echo "Need to check if NWPS workstation package is installed..." >> ${LOGFILE}
USER=$(whoami)
#if [ ! -e ${NWPSdir}/parm/templates ] 
#    then
#    logit "ERROR - You do not have the NWPS workstation package installed."
#    logit "You must install the workstation package"
#    export err=1; err_chk
#fi

# Clear the partition flags
hspyorn="n"
prtgdyorn="n"
for (( i = 0 ; i < 7 ; i++ ))
do
    PARTFLAGS[$i]="n";
done

DOMAINFILE="${1}"
NESTCG="${2}"
MODELCORE="${3}"

if [ "${DOMAINFILE}" != "" ]
    then
    if [ "${NESTCG}" == "" ]
	then
	echo "ERROR - You must specify a NESTCG argument (Yes or No)"
	export err=1; err_chk
    fi

    if [ "${MODELCORE}" == "" ]
	then
	echo "ERROR - You must specify a MODELCORE argument (SWAN, UNSWAN or WW3)"
	export err=1; err_chk
    fi

    auto_run
else
    logit ""
    logit "Starting interactive domain setup"
    date -u | tee -a ${LOGFILE}
    logit ""
    logit "NOTE: Interactive mode is used for testing and development"
    logit "NOTE: For production systems create domain setup file"
    logit "NOTE: Examples can be found in ${NWPSdir}/fix/domains"
    logit "NOTE: After creating a domain setup file run command below"
    logit "NOTE: ${0} domains/XXX"
    logit "NOTE: replace XXX with the 3 letter site ID of your domain"
    logit ""
    logit "Press enter to continue this interactive setup..."
    logit "Press Ctrl-C to exit..."
    logit ""
    read prompt

    get_sid
    get_rid
    get_modeltype
    get_ne_lat
    get_ne_lon
    get_sw_lat
    get_sw_lon
    get_res
    get_time_step
    NUMSPC=0
    echo ""
    echo -n "Would you like to have Gerling-hanson and 1D-spectra plots for some locations in this domain (y/n)> "
    read prompt
    if [ "$prompt" == "y" ] || [ "$prompt" == "Y" ]
    then
	get_coord_spc1d    #Get coordinates for output spec-1D locations
        #hspyorn="y"
    fi
    #get_coord_hsplots      #Get coordinates for output wave-partition locations
    #get_flags_partition

    confirm_values
fi

cd ${DATA}

distx=`perl ${USHnwps}/dist_lat_lon.pl $SWLAT $SWLON $SWLAT $NELON`
disty=`perl ${USHnwps}/dist_lat_lon.pl $SWLAT $SWLON $NELAT $SWLON`

MESHLAT=$(echo "$disty/$RES" | bc)
MESHLON=$(echo "$distx/$RES" | bc)
XLENC=$(echo "$NELONCIRC - $SWLONCIRC" | bc)
YLENC=$(echo "$NELAT - $SWLAT" | bc)


if [ ${NESTGRIDS} -gt 0 ] && [ ${NESTCG} == "Yes" ]
then
    for (( j = 1 ; j < ${NESTGRIDS}+1 ; j++ ))
    do
    	distxN[$j]=`perl ${USHnwps}/dist_lat_lon.pl ${SWLATN[$j]} ${SWLONN[$j]} ${SWLATN[$j]} ${NELONN[$j]}`
    	distyN[$j]=`perl ${USHnwps}/dist_lat_lon.pl ${SWLATN[$j]} ${SWLONN[$j]} ${NELATN[$j]} ${SWLONN[$j]}`
    	MESHLATN[$j]=$(echo "${distyN[$j]}/${RESN[$j]}" | bc)
    	MESHLONN[$j]=$(echo "${distxN[$j]}/${RESN[$j]}" | bc)
    	XLENCN[$j]=$(echo "${NELONCIRCN[$j]} - ${SWLONCIRCN[$j]}" | bc)
    	YLENCN[$j]=$(echo "${NELATN[$j]} - ${SWLATN[$j]}" | bc)
    done
fi


logit " "
#####################################################
logit "### Setting up new NWPS domain :"
logit " "

cd ${DATA}

#if [ ! -e ${PARMnwps}/templates/${LSID} ]
#then
#    logit ": Creating new templates ... "
#    mkdir -p ${PARMnwps}/templates/${LSID}
#else
#    logit ": Backing up the current templates ... "
#    cd ${PARMnwps}/templates/${LSID}
#    BACKUPEXT=$(date +%Y%m%d_%H%M%S)
#    #tar cfz templates_${BACKUPEXT}.tar.gz *
#    tar cfz templates.tar.gz *
#    cd ${DATA}
#fi

logit ": Customize ${DATAdir}/parm/templates/${LSID} ... "
mkdir -p ${DATA}/install
cd ${DATA}/install
cp -fp ${FIXnwps}/templates/* ${DATA}/install &> /dev/null

logit " "
if [ $NUMSPC -gt "0" ]
then
    x=1
    while [ $x -le $NUMSPC ]
    do
        line="POINTS '${spcnames[$x]}' ${spclons[$x]} ${spclats[$x]}"
        sed -i "/$SPECTRA OUT-LOCATIONS/ a $line" inputCG1

        if [ -f "inputCG2" ];then
            sed -i "/$SPECTRA OUT-LOCATIONS/ a $line" inputCG2
        fi
        if [ -f "inputCG3" ];then
            sed -i "/$SPECTRA OUT-LOCATIONS/ a $line" inputCG3
        fi
        if [ -f "inputCG4" ];then
            sed -i "/$SPECTRA OUT-LOCATIONS/ a $line" inputCG4
        fi
        if [ -f "inputCG5" ];then
            sed -i "/$SPECTRA OUT-LOCATIONS/ a $line" inputCG5
        fi

	linesystrk="${spclons[$x]} ${spclats[$x]}"
        sed -i "/#outputpointshere#/ a $linesystrk" ww3_systrk.inp
        x=$(( $x + 1 ))
    done
    x=1
    while [ $x -le $NUMSPC ]
    do
        if { [ "${SITEID}" == "HFOX" ] && [ $x -gt 1 ]; }; then
           linespc1="\$SPECOUT '${spcnames[$x]}' SPEC1D ABSOLUTE 'SPC1D.${spcnames[$x]}.CG1' OUTPUT 20100301.1800 3.0 HR"
           line2dspc1="\$SPECOUT '${spcnames[$x]}' SPEC2D ABSOLUTE 'SPC2D.${spcnames[$x]}.CG1' OUTPUT 20100301.1800 3.0 HR"
        else
           linespc1="SPECOUT '${spcnames[$x]}' SPEC1D ABSOLUTE 'SPC1D.${spcnames[$x]}.CG1' OUTPUT 20100301.1800 3.0 HR"
           line2dspc1="SPECOUT '${spcnames[$x]}' SPEC2D ABSOLUTE 'SPC2D.${spcnames[$x]}.CG1' OUTPUT 20100301.1800 3.0 HR"
        fi
        sed -i "/$SPECTRA COMMANDS/ a $line2dspc1" inputCG1
        sed -i "/$SPECTRA COMMANDS/ a $linespc1" inputCG1

        if [ -f "inputCG2" ];then
            linespc2="SPECOUT '${spcnames[$x]}' SPEC1D ABSOLUTE 'SPC1D.${spcnames[$x]}.CG2' OUTPUT 20100301.1800 3.0 HR"
            line2dspc2="SPECOUT '${spcnames[$x]}' SPEC2D ABSOLUTE 'SPC2D.${spcnames[$x]}.CG2' OUTPUT 20100301.1800 3.0 HR"
            sed -i "/$SPECTRA COMMANDS/ a $line2dspc2" inputCG2
            sed -i "/$SPECTRA COMMANDS/ a $linespc2" inputCG2
        fi
        if [ -f "inputCG3" ];then
            linespc3="SPECOUT '${spcnames[$x]}' SPEC1D ABSOLUTE 'SPC1D.${spcnames[$x]}.CG3' OUTPUT 20100301.1800 3.0 HR"
            line2dspc3="SPECOUT '${spcnames[$x]}' SPEC2D ABSOLUTE 'SPC2D.${spcnames[$x]}.CG3' OUTPUT 20100301.1800 3.0 HR"
            sed -i "/$SPECTRA COMMANDS/ a $line2dspc3" inputCG3
            sed -i "/$SPECTRA COMMANDS/ a $linespc3" inputCG3
        fi
        if [ -f "inputCG4" ];then
            linespc4="SPECOUT '${spcnames[$x]}' SPEC1D ABSOLUTE 'SPC1D.${spcnames[$x]}.CG4' OUTPUT 20100301.1800 3.0 HR"
            line2dspc4="SPECOUT '${spcnames[$x]}' SPEC2D ABSOLUTE 'SPC2D.${spcnames[$x]}.CG4' OUTPUT 20100301.1800 3.0 HR"
            sed -i "/$SPECTRA COMMANDS/ a $line2dspc4" inputCG4
            sed -i "/$SPECTRA COMMANDS/ a $linespc4" inputCG4
        fi
        if [ -f "inputCG5" ];then
            linespc5="SPECOUT '${spcnames[$x]}' SPEC1D ABSOLUTE 'SPC1D.${spcnames[$x]}.CG5' OUTPUT 20100301.1800 3.0 HR"
            line2dspc5="SPECOUT '${spcnames[$x]}' SPEC2D ABSOLUTE 'SPC2D.${spcnames[$x]}.CG5' OUTPUT 20100301.1800 3.0 HR"
            sed -i "/$SPECTRA COMMANDS/ a $line2dspc5" inputCG5
            sed -i "/$SPECTRA COMMANDS/ a $linespc5" inputCG5
        fi
        x=$(( $x + 1 ))
    done
    sed -i '/#outputpointshere#/d' ww3_systrk.inp 
    x=1
    while [ $x -le $NUMSPC ]
    do
        line1="TABLE '${spcnames[$x]}' NOHEADER 'WND.${spcnames[$x]}.CG1' WIND OUTPUT 20100301.1800 3.0 HR"
        line2="TABLE '${spcnames[$x]}' NOHEADER 'WND.${spcnames[$x]}.CG2' WIND OUTPUT 20100301.1800 3.0 HR"
        sed -i "/$PARTITION OUTCOMMANDS/ a $line1" inputCG1

        if [ -f "inputCG2" ];then
            sed -i "/$PARTITION OUTCOMMANDS/ a $line2" inputCG2
        fi
        x=$(( $x + 1 ))
    done
fi

edit_inputCG_for_partition;
edit_inputCG_for_blockout;
edit_inputCG_for_currents;
#Code to include the nested grids in the CGinclude.pm file
#file Nest_info_CGinclude is included in CGinclude.pm
#many times as the number of nested grids
if [ ${NESTGRIDS} -gt 0 ] && [ ${NESTCG} == "Yes" ]
   then
   echo " "
   echo "UPDATING WAVE MODEL INPUT FILE FOR NESTED GRIDS"
   echo " NUMBER OF NESTED GRIDS: ${NESTGRIDS}"
   for (( i = 1 ; i < ${NESTGRIDS}+1 ; i++ ))
      do
      cgrid=$(( $i + 1))
      echo " NESTED        GRID NUMBER: ${i}"
      echo " COMPUTATIONAL GRID NUMBER: ${cgrid}"
      cp -fp Nest_info_CGinclude Nest
      sed -e "s/CGNumber/CG${cgrid}/g" -i Nest
      sed -e "s/NestNumber/N${i}/g" -i Nest
      sed -e "s/COMPGRID/${cgrid}/g" -i Nest
      sed "/#HERECG${cgrid} : COMPUT GRID ${cgrid} (CG${cgrid}) NEST NUM $i IF EXIST/{
      r Nest
      }" CGinclude.pm > newfileCGinclude.wna
      mv newfileCGinclude.wna CGinclude.pm
      echo " "
done

fi
cat /dev/null > ${RUNdir}/cgn_cmdfile
    if [ "${NESTGRIDS}" -gt "0" ] && [ "${NESTCG}" == "Yes" ]
    then
       echo " ADDING THE NESTED GRIDS INFO"
       for (( j = 1 ; j < ${NESTGRIDS}+1 ; j++ ))
       do
          echo " NESTED GRID NUMBER: ${j}"
          cgrid=$(( $j + 1))

          # Add nested grids NGRID only in case of SWAN model core (not UNSWAN)
          if [ "${MODELCORE}" == "SWAN" ]
          then
             line2nest="NESTOUT 'NEST$j' 'bc_CG$cgrid' OUTPUT 20100301.1800 #TSTEP#.0 HR"
             sed -i "/$NESTGRID DATA/ a $line2nest" inputCG1          
             line1nest="NGRID 'NEST$j' ${SWLONCIRCN[j]} ${SWLATN[j]} 0. ${XLENCN[j]} ${YLENCN[j]}"
             sed -i "/$NESTGRID DATA/ a $line1nest" inputCG1
          fi

          # Creating the command file to postprocess nested grids in a "parallel way"
          echo "${USHnwps}/run_posproc_cgn_parallel.sh $cgrid " >> ${RUNdir}/cgn_cmdfile
       done
    fi

for i in $(ls -1)
do
    sed -i "s/XXX/$USID/g" $i
    sed -i "s/xxx/$LSID/g" $i
    sed -i "s/$USID output begin flag $USID/XXX output begin flag XXX/g" $i
    sed -i "s/#JETLAG#/$JETLAG/g" $i
    sed -i "s/#NUMCPUS#/$NUMCPUS/g" $i
    sed -i "s/#NELAT#/$NELAT/g" $i
    sed -i "s/#NELON#/-$NELON/g" $i
    sed -i "s/#SWLAT#/$SWLAT/g" $i
    sed -i "s/#SWLON#/-$SWLON/g" $i
    sed -i "s/#MESHLAT#/$MESHLAT/g" $i
    sed -i "s/#MESHLON#/$MESHLON/g" $i
    sed -i "s/#TSTEP#/$TSTEP/g" $i
    sed -i "s/#YMD#/$YMD/g" $i
    sed -i "s/#SWLONCIRC#/$SWLONCIRC/g" $i
    sed -i "s/#XLENC#/$XLENC/g" $i
    sed -i "s/#YLENC#/$YLENC/g" $i
    if [ "${NESTGRIDS}" -gt "0" ] && [ "${NESTCG}" == "Yes" ]
      then
      for (( j = 1 ; j < ${NESTGRIDS}+1 ; j++ ))
         do
          sed -i "s/#NELATN$j#/${NELATN[j]}/g" $i
          sed -i "s/#NELONN$j#/-${NELONN[j]}/g" $i
          sed -i "s/#SWLATN$j#/${SWLATN[j]}/g" $i
          sed -i "s/#SWLONN$j#/-${SWLONN[j]}/g" $i
          sed -i "s/#MESHLATN$j#/${MESHLATN[j]}/g" $i
          sed -i "s/#MESHLONN$j#/${MESHLONN[j]}/g" $i
          sed -i "s/#TSTEPN$j#/${TSTEPN[j]}/g" $i
          sed -i "s/#YMD#/$YMD/g" $i
          sed -i "s/#SWLONCIRCN$j#/${SWLONCIRCN[j]}/g" $i
          sed -i "s/#XLENCN$j#/${XLENCN[j]}/g" $i
          sed -i "s/#YLENCN$j#/${YLENCN[j]}/g" $i
          if [ "${SITEID}" == "GUM" ] && [ "${i}" == "inputCG3" ]
          then
             sed -i "s/\\$<< PUT NUM LIMITER HERE >>/NUM DIRimpl cdd=1 cdlim=2/g" $i
          fi
          if [ "${SITEID}" == "AER" ] && [ "${i}" == "inputCG3" ]
          then
             sed -i "s/\\$<< PUT NUM LIMITER HERE >>/NUM DIRimpl cdd=1 cdlim=2/g" $i
          fi
      done
    fi
# TRACKING ON/OFF AND FRAME COMMAND
    if [ $hspyorn == "y" ]; then
       sed -i "s/#SWLATWT#/$SWLATWT/g" $i
       sed -i "s/#SWLONCIRCWT#/$SWLONCIRCWT/g" $i
       sed -i "s/#NELATWT#/$NELATWT/g" $i
       sed -i "s/#NELONCIRCWT#/$NELONCIRCWT/g" $i
       sed -i "s/#MESHLATWT#/$MESHLATWT/g" $i
       sed -i "s/#MESHLONWT#/$MESHLONWT/g" $i
       sed -i "s/#XLENWT#/$XLENWT/g" $i
       sed -i "s/#YLENWT#/$YLENWT/g" $i
       sed -i "s/#WvTrkKnobs#/$WVTRKPA/g" $i
    fi

    if [[ $BOUNCOND == "1" ]]
    then
      # Info for boundary conditions files into wna_input.cfg
      #Info from the ${DOMAIN} file then copy those lines to wna_input.cfg
       sed -i "s/#multi1#/$FTPPAT1/g" $i
       sed -i "s/#multi2#/$FTPPAT1B/g" $i
       sed -i "s/#ID#/$FTPPAT2/g" $i
       sed -i "s/#NATTEMPTS#/$NFTPATTEMPTS/g" $i
       sed -i "s/#WVCPS#/$WAVECPS/g" $i
    fi
    chmod 664 $i
done
#NOTE: Eventhough the user can choose to include boundary conditions from the
#      domain file ({$NWPSdir}/fixp/domains/FILE,  this can be overridden
#      by the input information from the GUI.
#Following lines will introduce the BOUN SEG command lines into inputCG1
#     echo " ********************************************"
#     echo " DOMAINFILE:  ${DOMAINFILE}                 *"
#     echo " BOUNCOND  :  $BOUNCOND                     *"
#     echo " MODELCORE :  ${MODELCORE}                  *"
#   echo " **********************************************"
if [[ $BOUNCOND == "1" ]]
   then

   #rm ${NWPSdir}/parm/templates/${LSID}/BounCommandLines.txt

   if [ ${MODELCORE} == "SWAN" ] || [ ${MODELCORE} == "swan" ] || [ ${MODELCORE} == "UNSWAN" ]
   then
      echo " **********************************************"
      echo " BOUNDARY CONDITIONS BEING ADDED TO INPUTCG1  *"
      echo " **********************************************"
      a="#\$BOUNDARY COMMAND LINES"
      b="#\$END BOUNSEG"
      sed -n "/$a/,/$b/p" ${DOMAINFILE} > BounCommandLines.txt
      #sed "/$a/d" -i BounCommandLines.txt
      #sed "/$b/d" -i BounCommandLines.txt
      sed -e "s/\#//g" -i BounCommandLines.txt
      sed '/$HERE BOUN SEG/{
      r BounCommandLines.txt
      d
      }' inputCG1 > newfile.wna
      mv newfile.wna inputCG1
   elif [ ${MODELCORE} == "WW3" ] || [ ${MODELCORE} == "ww3" ]
   then
      echo " **********************************************"
      echo " BOUNDARY CONDITIONS SEGMENTS BEING PREPARE FOR WWWIII  *"
      echo " **********************************************"
      a="#\$BOUNDARY SEGMENT FOR WWIII"
      b="#\$END BOUN SEG FOR WWIII"
      sed -n "/$a/,/$b/p" ${DOMAINFILE} > BounCommandLines.txt
      sed -e "s/\#//g" -i BounCommandLines.txt
   else
      echo " **********************************************"
      echo " MODELCORE NOT DEFINED .. EXIT *"
      echo " **********************************************"
      export err=1; err_chk
   fi
fi
#____________________________RIP CURRENT PROGRAM___________________________________
#
echo "RIPPROG: $RIPPROG"
if [[ $RIPPROG == "1" ]]
   then

   #rm ${NWPSdir}/parm/templates/${LSID}/RipCommandLines.txt

   echo " **********************************************"
   echo " Rip Contours being added to input${RIPDOMAIN}  *"
   echo " **********************************************"
   a="#\$RIP LINES"
   b="#\$END RIP"
   sed -n "/$a/,/$b/p" ${DOMAINFILE} > RipCommandLines.txt
   #sed "/$a/d" -i RipCommandLines.txt
   #sed "/$b/d" -i RipCommandLines.txt
   sed -e "s/\#//g" -i RipCommandLines.txt
   sed '/$RIP LINES/{
   r RipCommandLines.txt
   d
   }' input${RIPDOMAIN} > newfile.rip
   mv newfile.rip input${RIPDOMAIN}
fi
#____________________________RUNUP  PROGRAM_____________________
#
echo "RUNUPPROG: $RUNUPPROG"
if [[ $RUNUPPROG == "1" ]]
   then


   echo " **********************************************"
   echo " Runup Contours being added to input${RIPDOMAIN}  *"
   echo " **********************************************"
   a="#\$RUNUP LINES"
   b="#\$END RUNUP"
   sed -n "/$a/,/$b/p" ${DOMAINFILE} > RunupCommandLines.txt
   sed -e "s/\#//g" -i RunupCommandLines.txt
   sed '/$RUNUP LINES/{
   r RunupCommandLines.txt
   d
   }' input${RUNUPDOMAIN} > newfile.runup
   mv newfile.runup input${RUNUPDOMAIN}
fi
#__________________END RUNUP PROGRAM____________________________
#
#
##__________________OBSTACLES___________________________________
#
echo "USEOBSTA: $USEOBSTA"
#cat inputCG1
if [[ "$USEOBSTA" == "1" ]]
   then
   echo " **********************************************"
   echo " Obstacles being added to all domains         *"
   echo " **********************************************"
   a="#\$OBSTACLES LINES"
   b="#\$END OBSTACLES"
   sed -n "/$a/,/$b/p" ${DOMAINFILE} > ObstaCommandLines.txt
   sed -e "s/\#//g" -i ObstaCommandLines.txt
   for (( j = 1 ; j < ${NESTGRIDS}+2 ; j++ ))
      do
         echo " Inserting obstacles in inputCG${j}"
         cgrid=$(( $j ))
         sed '/$OBSTACLES LINES/{
         r ObstaCommandLines.txt
         d
         }' inputCG${cgrid} > newfile.obsta
         mv newfile.obsta inputCG${cgrid}
   done
fi
#__________________END OBSTACLES_____________________________


##__________________SHIP ROUTES___________________________________
#

CFGFILE=${FIXnwps}/shiproutes/${siteid}_shiproutes.cfg
grep "$ SHIPROUTE LINES BEGIN HERE" inputCG1 &> /dev/null
if [ -f  ${CFGFILE} ] && [ $? -eq 0 ]; then
    echo "Creating inputCG1 ship route lines"
    ${USHnwps}/shiproutes/shiproute_domain_setup.sh 
    echo "Running ${USHnwps}/shiproutes/shiproute_domain_setup.sh"
    ${USHnwps}/shiproutes/shiproute_domain_setup.sh
    if [ $? -eq 0 ]; then
	cat ${VARdir}/shiproutes/INPUTcg1_shiproutes.app > ShipRouteLines.txt
	sed '/$ SHIPROUTE LINES BEGIN HERE/{
        r ShipRouteLines.txt
        d
        }' inputCG1 > inputCG1_shiproutes
	mv -fv inputCG1_shiproutes inputCG1
	rm -fv ShipRouteLines.txt
    else
	echo "ERROR - Error generating shiproute points"
	echo "ERROR - See ouput log: ${LOGdir}/shiproute_domain_setup.log"
    fi
else
    if [ $? -ne 0 ]; then
	echo "INFO - Our inputCG1 fixed template does not have '$ SHIPROUTE LINES BEGIN HERE' line"
	echo "INFO - No ship route data or plots will be created for ${SITEID} due to bad inputCG1 template"
    fi
    if [ ! -f ${CFGFILE} ]; then 
	echo "INFO - ${SITEID} has no CFG file for ship routes, missing: ${FIXnwps}/shiproutes/${siteid}_shiproutes.cfg"
	echo "INFO - No ship route data or plots will be created for ${SITEID} due to no shiproute config file"
    fi
fi


##__________________END SHIP ROUTES_______________________________


#
#Following lines will introduce the Nested Grids info into the CGinclude.pm file

# NOTE: This step will modify ConfigSwan.pm
cat ${USHnwps}/pm/ConfigSwan_master_template.pm > ${RUNdir}/ConfigSwan.pm
sed -r -i "s/^(use constant NUMCPUS => ')([0-9]+)(';)/\1${NUMCPUS}\3/g" ${RUNdir}/ConfigSwan.pm
sed -r -i "s/^(use constant JETLAG => ')([0-9]+)(';)/\1${JETLAG}\3/g" ${RUNdir}/ConfigSwan.pm

# Copy the templates

#RPcp -pf * ${NWPSdir}/parm/templates/${LSID}/.
#RPcp -pf ${NWPSdir}/fix/domains/${SITEID} ${NWPSdir}/parm/templates/${LSID}/.
mkdir -p ${DATA}/parm/templates/${LSID}/
cp -pf * ${DATA}/parm/templates/${LSID}/.
cp -pf   ${FIXnwps}/domains/${SITEID}  ${DATA}/parm/templates/${LSID}/.

# If no spectra locations, remove the specra lines from our CGS include file
if [ $NUMSPC -eq 0 ]
then
    parms="FREQUENCYARRAY NUMOFOUTPUTSPC1D SPECTRANAMES1D SPC1DLONGITUDES SPC1DLATITUDES"
    for parm in ${parms}
    do
	#RPcat ${NWPSdir}/parm/templates/${LSID}/CGinclude.pm > ${VARdir}/CGinclude_spectra.pm
	#RPcat ${VARdir}/CGinclude_spectra.pm | grep -v ${parm} > ${NWPSdir}/parm/templates/${LSID}/CGinclude.pm 
	cat ${DATA}/parm/templates/${LSID}/CGinclude.pm > ${VARdir}/CGinclude_spectra.pm
	cat ${DATA}/CGinclude_spectra.pm | grep -v ${parm} > ${DATA}/parm/templates/${LSID}/CGinclude.pm 
    done
fi

# If no partition locations, remove the paritition lines from our CGS include file
#if [ $NUMPRT -eq 0 ]
#then
#    parms="NUMOFOUTPUTPART PARTITIONNAMES PARTLONGITUDES PARTLATITUDES"
#    for parm in ${parms}
#    do
#	cat ${NWPSdir}/parm/templates/${LSID}/CGinclude.pm > ${VARdir}/CGinclude_spectra.pm
#	cat ${VARdir}/CGinclude_spectra.pm | grep -v ${parm} > ${NWPSdir}/parm/templates/${LSID}/CGinclude.pm 
#    done
#fi

#rm -rf ${WD}/templates/install
#cd ${WD}

logit ": Setup setting ${DATA}/parm/templates/${LSID}/siteid.sh for local SITE ID ... "
mkdir -p ${DATA}/parm/templates/${LSID}
cat /dev/null > ${DATA}/parm/templates/${LSID}/siteid.sh
echo "#!/bin/bash" >> ${DATA}/parm/templates/${LSID}/siteid.sh
echo "# Set our 3 letter SITE ID"  >> ${DATA}/parm/templates/${LSID}/siteid.sh
echo "# NOTE: Do NOT manually edit this script" >> ${DATA}/parm/templates/${LSID}/siteid.sh
echo "# NOTE: This script will be created during your domain setup" >> ${DATA}/parm/templates/${LSID}/siteid.sh
echo "#"  >> ${DATA}/parm/templates/${LSID}/siteid.sh
echo "export SITEID=$USID" >> ${DATA}/parm/templates/${LSID}/siteid.sh
echo "export siteid=$LSID" >> ${DATA}/parm/templates/${LSID}/siteid.sh
echo "#"  >> ${DATA}/parm/templates/${LSID}/siteid.sh
echo "# Set our 2 letter Region ID"  >> ${DATA}/parm/templates/${LSID}/siteid.sh
echo "export REGIONID=$URID" >> ${DATA}/parm/templates/${LSID}/siteid.sh
echo "export regionid=$LRID" >> ${DATA}/parm/templates/${LSID}/siteid.sh
# experimental XXX
echo -n 'export DOMAINFILE=${DATA}/parm/templates/' >> ${DATA}/parm/templates/${LSID}/siteid.sh
echo "${LSID}/${USID}" >> ${DATA}/parm/templates/${LSID}/siteid.sh
echo "listinf DOMAINFILE"
cat ${DOMAINFILE}
##cp -fpv ${DOMAINFILE} ${DATA}/parm/templates/${LSID}/${USID}
chmod 775 ${DATA}/parm/templates/${LSID}/siteid.sh

logit ": Setup setting ${DATA}/parm/templates/${LSID}/modeltype.sh for model type ... "
cat /dev/null > ${DATA}/parm/templates/${LSID}/modeltype.sh
echo "#!/bin/bash" >> ${DATA}/parm/templates/${LSID}/modeltype.sh
echo "# Set our core Wave Model"  >> ${DATA}/parm/templates/${LSID}/modeltype.sh
echo "#"  >> ${DATA}/parm/templates/${LSID}/modeltype.sh
echo "export MODELTYPE=$URMODEL" >> ${DATA}/parm/templates/${LSID}/modeltype.sh
echo "export modeltype=$LRMODEL" >> ${DATA}/parm/templates/${LSID}/modeltype.sh
#chmod 775 ${NWPSdir}/parm/templates/${LSID}/modeltype.sh

#cd ${WD}

logit " "
logit "Domain setup complete"
date -u | tee -a ${LOGFILE}
logit " "

exit 0
# ----------------------------------------------------------- 
# ******************************* 
# ********* End of File ********* 
# ******************************* 

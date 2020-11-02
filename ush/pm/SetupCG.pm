#!/usr/bin/perl
# ----------------------------------------------------------- 
# PERL Script
# PERL Version(s): 5
# Original Author(s): Eve-Marie Devalire for WFO-Eureka 
# File Creation Date: 04/20/2004
# Date Last Modified: 11/14/2016
#
# Version control for WCOSS: 1.00
#
# Support Team:
#
# Contributors: Alex Gibbs, Tony Freeman, Pablo Santos, Douglas Gaer, 
#               Roberto Padilla-Hernandez, Andre van der Westhuysen
#
# Inclusion of  WWIII and Version for WCOSS Roberto.Padilla@noaa.gov
# Separating the preprocessing work from RunSwan module Andre.VanderWesthuysen@noaa.gov
#
# ----------------------------------------------------------- 
# ------------- Program Description and Details ------------- 
# ----------------------------------------------------------- 
################################################################################
#                               SetupCG package                                #
################################################################################
# This script creates the command files, move and make the SWAN model running  #
################################################################################
#               The subroutines implemented here are the following:            #
################################################################################
##createSwanCommandFiles                                                       #
##makeInputCGx                                                                 #
##fixDate                                                                      #
##fixComputationDate                                                           #
#
##getWW3Files                                                        #
################################################################################
#                   The packages used are the following:                       #
################################################################################
#Tie::File                                                                     #
#POSIX                                                                         #
#Cwd                                                                           #
################################################################################
# ----------------------------------------------------------- 

######################################################
#      Packages and exportation requirements         #
######################################################
package SetupCG;
use Math::Trig;
#use File::Slurp;
# Setup our NWPS env for this Perl script
my $NWPSdir = $ENV{'HOMEnwps'};
my $USHnwps = $ENV{'USHnwps'};
my $DATA = $ENV{'DATA'};
my $USERNAME = $ENV{'USERNAME'};
my $ISPRODUCTION = $ENV{'ISPRODUCTION'};
my $DEBUGGING = $ENV{'DEBUGGING'};
my $DEBUG_LEVEL = $ENV{'DEBUG_LEVEL'};
my $HOTSTART = $ENV{'HOTSTART'};
my $HOTSTARTTIMESTEP = $ENV{'HOTSTARTTIMESTEP'};
my $USERDELTAC = $ENV{'USERDELTAC'};

# Setup our processing DIRs
my $BATHYdb = $ENV{'BATHYdb'};
my $SHAPEFILEdb = $ENV{'SHAPEFILEdb'};
my $ARCHdir = $ENV{'ARCHdir'};
my $DATAdir = $ENV{'DATAdir'};
my $INPUTdir = $ENV{'INPUTdir'};
my $LOGdir = $ENV{'LOGdir'};
my $VARdir = $ENV{'VARdir'};
my $OUTPUTdir = $ENV{'OUTPUTdir'};
my $RUNdir = $ENV{'RUNdir'};
my $TMPdir = $ENV{'TMPdir'};
my $GESIN = $ENV{'GESIN'};
my $GESINm1 = $ENV{'GESINm1'};
my $GESINm2 = $ENV{'GESINm2'};
my $NWPSplatform = $ENV{'NWPSplatform'};
##our $RUNdir = $ENV{'RUNdir'};
our $MODELCORE = $ENV{'MODELCORE'};
our $MPMODE = $ENV{'MPMODE'};
my $HOMEdir = $ENV{'HOME'};
our %RunValues;
my $SITEID = $ENV{'SITEID'};
my $PDY = $ENV{'PDY'};
my $WNA = $ENV{'WNA'};
our $PATH = $ENV{PATH};
our $numofOutputSpectra;
our $numofOutputPoints;
our $numofOutputPartition;
our $numofGrids;
#our %RunValues;
# User defines the time step to create hotfiles during the run. The default is 3 hourly. 
my $hotStepLength = 3; 

if ( "${HOTSTARTTIMESTEP}" ne "") {
    $hotStepLength = ${HOTSTARTTIMESTEP}; 
}
#use lib ("$ENV{'NWPSdir'}/ush/bin");
use POSIX;
use Cwd 'chdir';
use Tie::File;
use CommonSub qw(giveDate ftp mvFiles removeFiles removeOldFiles goForward copyFile 
renameFilesWithSuffix giveNextEntryLine changeLine report);
use ArraySub qw(takeUndefAway takeSpaceAway printArray printArrayIn formatArray
formatDoubleArray pushDoubleArray printDoubleArray takeSpaceAway giveMaxArray
giveMaxDoubleArray giveSumDoubleArray reverseDoubleArray printDoubleArrayIn inArray);
use Archive qw(archiveFiles);
require Exporter;
@ISA=qw(Exporter);
@EXPORT=qw(makeSwanRun);
use ConfigSwan;
use Logs;
use Data::Dumper;
$path=PATH;
our $test=0;
our $gtop;

if((${NWPSplatform} eq 'WCOSS') || (${NWPSplatform} eq 'DEVWCOSS')) {
    my $infoFile02 = "${RUNdir}/info_to_nwps_coremodel.txt";
    open IN, "<$infoFile02"  or die "Cannot open: $!";
    our ($NWPSdir, $DEBUGGING, $DEBUG_LEVEL, $BATHYdb, $SHAPEFILEdb, $ARCHdir);
    our ($DATAdir, $LOGdir, $VARdir, $OUTPUTdir, $RUNdir, $TMPdir, $RUNLEN);
    our ($NESTS, $RTOFS, $ESTOFS, $WEB, $PLOT, $MODELCORE, $LOGdir, $SITEID);
    our ($WNA, $WINDS, $INPUTdir, $ISPRODUCTIO, $DATAdir, $siteid, $GEN_NETCDF);
    our ($USERDELTAC);
    
    my $ndata=0;
    while (<IN>) {
	$ndata+=1;
	chomp($_);
	if ($ndata ==1) {
	    $NWPSdir=$_;
	}
	if ($ndata ==2) {
	    $ISPRODUCTIO=$_;
	}
	if ($ndata ==3) {
	    $DEBUGGING=$_;
	}
	if ($ndata ==4) {
	    $DEBUG_LEVEL=$_;
	}
	if ($ndata ==5) {
	    $BATHYdb=$_;
	}
	if ($ndata ==6) {
	    $SHAPEFILEdb =$_;
	}
	if ($ndata ==7) {
	    $ARCHdir=$_;
	}
	if ($ndata ==8) {
	    $DATAdir=$_;
	}
	if ($ndata ==9) {
	    $INPUTdir=$_;
	}
	if ($ndata ==10) {
	    $LOGdir=$_;
	}
	if ($ndata ==11) {
	    $VARdir=$_;
	}
	if ($ndata ==12) {
	    $OUTPUTdir=$_;
	}
	if ($ndata ==13) {
	    $RUNdir=$_;
	}
	if ($ndata ==14) {
	    $TMPdir=$_;
	}
	if ($ndata ==15) {
	    $RUNLEN=$_;
	}
	if ($ndata ==16) {
	    $WNA=$_;
	}
	if ($ndata ==17) {
	    $NESTS=$_;
	}
	if ($ndata ==18) {
	    $RTOFS=$_;
	}
	if ($ndata ==19) {
	    $ESTOFS=$_;
	}
	if ($ndata ==20) {
	    $WINDS=$_;
	}
	if ($ndata ==21) {
	    $WEB=$_;
	}
	if ($ndata ==22) {
	    $PLOT=$_;
	}
	if ($ndata ==23) {
	    $SITEID=$_;
	    $siteid= lc $SITEID;
	}
	if ($ndata ==24) {
	    $MODELCORE=$_;
	}
	if ($ndata ==25) {
	    $GEN_NETCDF=$_;
	}
	if ($ndata ==26) {
	    $USERDELTAC=$_;
	}
    }
    close IN;
#print "-----------------------Values in SetupCG.pm --------------------\n";
#print "$NWPSdir, $ISPRODUCTIO, $DEBUGGING, $DEBUG_LEVEL, $BATHYdb, $SHAPEFILEdb, $ARCHdir\n";
#print "$DATAdir, $INPUTdir, $LOGdir, $VARdir, $OUTPUTdir, $RUNdir, $TMPdir, $RUNLEN, $WNA\n";
#print "$NEST, $RTOFS, $ESTOFS, $WINDS, $WEB, $PLOT, $MODELCORE, $LOGdir, $SITEID, $DATAdir\n";
#print "$GEN_NETCDF, $USERDELTAC\n";
#
}

######################################################
#                    Subroutines                     #
######################################################

################################################################################
# NAME: &makeSwanRun
# CALL: &makeSwanRun($date,$inpGrid,$filename)
# GOAL: for each domain, it creates the inputCGx files, the command files for
#       the swan model, moves the files appropriately, run the model and moves
#       the SWAN's output files globally at the end (less function calls)
#       inputCGx are command files from the past run used as templates
################################################################################

sub makeSwanRun ($$$%){
	local ($date,$inpGrid,$fileName,%CG) = @_;
	Logs::run("Creating swan command file.");
	Logs::bug("begin makeSwanRun",1);
        local $readInpWind="READINP WIND 1.0 '".$fileName."' 3 0 0 0 FREE";
	local ($century,$year,$month,$day,$hour)=unpack"A2 A2 A2 A2 A2",$date;
	$date=$century.$year.$month.$day.".".$hour."00";
	$time[0]=$date;
	local ($todayYear,$todayMonth,$todayDay,undef,$todayHour)=unpack"A4 A2 A2 A A2",$date;
	Logs::bug("in make swan run(thisHour,thisDay,thisMonth,thisYear)=($todayHour/$todayDay/$todayMonth/$todayYear)",9);	
	local $dateSuffix="YY".$year.".MO".$month.".DD".$day.".HH".$hour;
	chdir ("${RUNdir}/") or Logs::err("directory change issue\ncan't change directory to ${RUNdir}/ error: $!",2);
#for_WCOSS
#codeSetupCGsh01
        $numofGrids=scalar keys %ConfigSwan::CGS;

	&makeInputCGx(%CG);

	Logs::bug("end makeSwanRun",1);
	return $dateSuffix;
}

################################################################################
# NAME: &makeInputCGx
# CALL: &makeInputCGx(%CG);
# GOAL: create the input file depending on the CGx
################################################################################

sub makeInputCGx (%){
    # 04/23/2010: Add flag to signal a SWAN.EXE crash to the Perl/BASH interface
    # Clean up any existing flag files
    `rm -f SWAN_EXE_HAS_CRASHED > /dev/null 2>&1`; 

    Logs::bug("begin makeInputCGx",1);
    my %CG = @_;
    my $timeStepLength = $CG{LENGTHTIMESTEP};
    Logs::bug("timeStepLength=$timeStepLength",9);
    local $suffix=" ".$timeStepLength.".0 HR";
    my ($thisHour,$thisDay,$thisMonth,$thisYear)= ($todayHour,$todayDay,$todayMonth,$todayYear);
    foreach $i (1 .. floor(SWANFCSTLENGTH/$timeStepLength)){
	($thisHour,$thisDay,$thisMonth,$thisYear)=&goForward($thisHour,
							     $thisDay,$thisMonth,$thisYear,$timeStepLength);
	my $time=$thisYear.$thisMonth.$thisDay.".".$thisHour."00";
	$time[$i]=$time;
    }

    ### BEGIN: HOTSTART SECTION
    #if($HOTSTART eq '') { # Check to see if our hotstart variable has been set
#	$HOTSTART = "FALSE"; 
#    }

#    if($HOTSTART eq 'TRUE') {
    ($thisHour,$thisDay,$thisMonth,$thisYear)=($todayHour,$todayDay,$todayMonth,$todayYear);
    $i=1;
    $hottime[0]=$time[0];
    foreach $i (1 .. floor(SWANFCSTLENGTH/$hotStepLength)){
	    ($thisHour,$thisDay,$thisMonth,$thisYear)=&goForward($thisHour,
								 $thisDay,$thisMonth,$thisYear,$hotStepLength);
	    my $hottime=$thisYear.$thisMonth.$thisDay.".".$thisHour."00";
	    $hottime[$i]=$hottime;
    }
#    }
    ### END: HOTSTART SECTION
    &printArray(9,@time);
    local @values;
    
    #Get CG attributes -NB	
    my ($CGsouthwestlat, $CGsouthwestlon, $CGnortheastlat, $CGnortheastlon, 
	$CGlengthdegreeslat, $CGlengthdegreeslon, $CGnummeshlat,$CGnummeshlon) = &getCGBoundaries(%CG);
    
###############################################################################################################
#
# GRID - SWAN computational grid defined.
# Alex Gibbs/Tony Freeman: 11Apr2011
#
# All outer domains will be set to use 24 directions. All inner nests (>= CG2) will be set to 36 directions.
#
################################################################################################################

    if ($CG{CGNUM} eq 1 ) {
	$circle="CIRCLE 36 0.035 1.5 36";
    } else {
	$circle="CIRCLE 36 0.035 1.5 36";
    }

    @values=("PROJ=PROJ 'SWAN-".FTPPAT2."-CG".$CG{CGNUM}."' '$day$hour'",
	     "RUN DATE='RUN DATE: 20$year-$month-$day $hour"."HR'",
	     "CGRID=CGRID $CGsouthwestlon $CGsouthwestlat 0. $CGlengthdegreeslon $CGlengthdegreeslat $CGnummeshlon $CGnummeshlat $circle");
    
    if(defined($CG{USEWIND})) {	#NB
	Logs::bug("Updating command file, including wind",9);
	push (@values, ("INPGRID WIND=$inpGrid",
			"READINP WIND=$readInpWind")
	    );
    }
    
    my $inputFile="inputCG".$CG{CGNUM};
    local @inputCGx;
    tie @inputCGx, 'Tie::File', $inputFile or Logs::err("array tie issue\n
        can't tie the array inputCG".$CG{CGNUM}." with the corresponding file",2);
    
    my $lineNumber=0;
    foreach (@values) {
	($pattern,$newValue)=split/=/;
	$lineNumber=&giveNextEntryLine($pattern,$lineNumber,\@inputCGx);
	&changeLine($lineNumber,$newValue,\@inputCGx);
	$lineNumber++;#to start again from the following line
    }
    
    # Specify Spec2D output commands
    my $spec2dline = &giveNextEntryLine("XXX output begin flag XXX",1,\@inputCGx);
    &Logs::err("Flag line: 'XXX output begin flag XXX' missing in file inputCG".$CG{CGNUM},2) if($spec2dline==-1);
    # first we erase the contents of the inputCGx file after the SPEC2D.OUTPUT.BEGIN marker
    while($#inputCGx > $spec2dline){
	pop @inputCGx;
    }
    if(defined($CG{PARTITIONZONES})){
	foreach my $zone (keys(%{$CG{PARTITIONZONES}})) {
	    my ($westNode,$eastNode,$southNode,$northNode) = &getSubGrid($zone,%CG);
	    $inputCGx[@inputCGx] = "\$";
	    $inputCGx[@inputCGx] = "\$ Generate output file for partition zone: $zone";
	    $inputCGx[@inputCGx] = "GROUP '$zone' SUBG $westNode $eastNode $southNode $northNode";
	    $inputCGx[@inputCGx] = "TABLE  '$zone' '$zone\_TAB' DEP VEL WIND OUTPUT YYYYMMDD.HHMM H.M HR";
	    $inputCGx[@inputCGx] = "SPEC '$zone' SPEC2D 'spec2d.out.$zone' OUTPUT YYYYMMDD.HHMM H.M HR";		
	    $inputCGx[@inputCGx] = "BLOCK '$zone' NOHEAD 'WIND.$zone' LAY 3 WIND OUTPUT YYYYMMDD.HHMM H.M HR";		
	}
    }
    if(defined($CG{TEXTLOCATIONS})) {
	foreach my $textloc (keys(%{$CG{TEXTLOCATIONS}})) {
	    $inputCGx[@inputCGx] = "\$";
	    $inputCGx[@inputCGx] = "\$ Generate output for location: $textloc";
	    my $pointlon = ${$CG{TEXTLOCATIONS}{$textloc}}{LON};
	    my $pointlat = ${$CG{TEXTLOCATIONS}{$textloc}}{LAT};
	    $inputCGx[@inputCGx] = "POIN '$textloc'  $pointlon  $pointlat";
	    $inputCGx[@inputCGx] = "TABLE  '$textloc' '$textloc"."_TAB' WIND HSIGN HSWELL TPS PDIR DEPTH OUTPUT OUTPUT YYYYMMDD.HHMM H.M HR";
	    $inputCGx[@inputCGx] = "SPEC '$textloc' SPEC2D 'spec2d.out.$textloc' OUTPUT YYYYMMDD.HHMM H.M HR";
	}
    }

##############################################################################################
#
# HOTStart Section:
# Alex Gibbs/Tony Freeman: 11Apr2011
#
# This section will determine whether or not SWAN uses the previous runs hotstart file. Conditions
# are that the hotstart file exists in ${RUNdir}/ && is less than 24 hrs old.
#
# After each run, the hotfiles created are stored in ${INPUTdir}/hotstart/
# 
###############################################################################################
    if($HOTSTART eq 'TRUE') {
    #Find most recent hotstart directory in nwges
    if (-e "${GESIN}/hotstart/${SITEID}") {
       $Prev_HOTdir="${GESIN}/hotstart/${SITEID}";
    }
    elsif (-e "${GESINm1}/hotstart/${SITEID}") {
       $Prev_HOTdir="${GESINm1}/hotstart/${SITEID}";
    }
    elsif (-e "${GESINm2}/hotstart/${SITEID}") {
       $Prev_HOTdir="${GESINm2}/hotstart/${SITEID}";
    }
    system("echo $Prev_HOTdir >> ${LOGdir}/hotstart.log 2>&1");
    #Find most recent cycle
    if ("${Prev_HOTdir}" ne "") {
        $hotfiles_cyc = `ls -t -d ${Prev_HOTdir}/* | head -1`;
        chomp $hotfiles_cyc;
    }

    if ($MODELCORE eq "SWAN") {
        system("echo Setting up hotfiles for model core ${MODELCORE}... >> ${LOGdir}/hotstart.log");
	#AW $hotfilelocation="${INPUTdir}/hotstart/${hottime[0]}*";
	$hotfilelocation="${hotfiles_cyc}/${hottime[0]}*";
	$newhotfilelocation='${RUNdir}/';
	system("cp -pfv $hotfilelocation $newhotfilelocation >> ${LOGdir}/hotstart.log 2>&1");
	system("echo OFF > ${RUNdir}/hotstart.flag");
	if(-e "${RUNdir}/${hottime[0]}-001") {
	    system("cp -pfv ${hotfiles_cyc}/${hottime[0]}-001 ${RUNdir}/${hottime[0]} >> ${LOGdir}/hotstart.log 2>&1");
	}

	if ((-e "${RUNdir}/${hottime[0]}" ) || (-e "${RUNdir}/${hottime[0]}-001")) {
	    system("echo Hotstart file ${hottime[0]} was used to initialize this SWAN run. >> ${LOGdir}/hotstart.log");
	    system("echo TRUE > ${RUNdir}/hotstart.flag");
	    Logs::run("GrADS plots will include all images.", 1);
	} 
	else {
	    system("echo No hotstart file was used for this SWAN run. Do not use the first 12 hrs of this run. >> ${LOGdir}/hotstart.log");
	    system("echo FALSE > ${RUNdir}/hotstart.flag");
	    Logs::run("GrADS plots will exclude the first 12 hrs of images for model spin-up.", 1);
	#    $HOTSTART = "FALSE";
	}
        # Reject hotfiles older than 2 days
	if ((( -e "${RUNdir}/${hottime[0]}" ) && ( int( -M "${RUNdir}/${hottime[0]}" ) < 3 )) || 
	    ((-e "${RUNdir}/${hottime[0]}-001" ) && ( int( -M "${RUNdir}/${hottime[0]}-001" ) < 3))) {
	    if ($inputFile eq "inputCG1") {
		$inputCGx[@inputCGx]="\$";
		$inputCGx[@inputCGx]="\$";
		$inputCGx[@inputCGx]="\$ SWAN will use the latest hotstart file.";
		$inputCGx[@inputCGx]="\$";
		$inputCGx[@inputCGx]="INITial HOTStart MULTiple '" . $hottime[0] . "'";
		$inputCGx[@inputCGx]="\$";
		Logs::run("This run will use the latest hotstart file available.", 1);
	    } else {
	    Logs::run("The latest hotstart file does not exist, too old to use or this is an inner nest.", 1);
	    Logs::run("GrADS plots will exclude the first 12 hrs of images for model spin-up.", 1);
	    system("echo FALSE > ${RUNdir}/hotstart.flag");
	#    $HOTSTART = "FALSE";
	    }
	}
    }   #SWAN
    if ($MODELCORE eq "UNSWAN") {
        system("echo Setting up hotfiles for model core ${MODELCORE} in PE directories... >> ${LOGdir}/hotstart.log");
        for (my $core=0; $core<10; $core++){
	   #AW $hotfilelocation="${INPUTdir}/hotstart/PE000${core}/${hottime[0]}";
	   $hotfilelocation="${hotfiles_cyc}/PE000${core}/${hottime[0]}";
	   $newhotfilelocation="${RUNdir}/PE000${core}/";
	   system("cp -pfv $hotfilelocation $newhotfilelocation >> ${LOGdir}/hotstart.log 2>&1");
        }
        for (my $core=10; $core<16; $core++){
	   #AW $hotfilelocation="${INPUTdir}/hotstart/PE00${core}/${hottime[0]}";
	   $hotfilelocation="${hotfiles_cyc}/PE00${core}/${hottime[0]}";
	   $newhotfilelocation="${RUNdir}/PE00${core}/";
	   system("cp -pfv $hotfilelocation $newhotfilelocation >> ${LOGdir}/hotstart.log 2>&1");
        }
        if ( ("${SITEID}" eq "MHX") || ("${SITEID}" eq "CAR") || ("${SITEID}" eq "MFL") 
          || ("${SITEID}" eq "TBW") || ("${SITEID}" eq "BOX") || ("${SITEID}" eq "SGX") 
          || ("${SITEID}" eq "SJU") || ("${SITEID}" eq "AKQ") || ("${SITEID}" eq "OKX") 
          || ("${SITEID}" eq "GUM") || ("${SITEID}" eq "ALU") || ("${SITEID}" eq "GUA") 
          || ("${SITEID}" eq "MLB") || ("${SITEID}" eq "JAX") || ("${SITEID}" eq "CHS") 
          || ("${SITEID}" eq "ILM") || ("${SITEID}" eq "PHI") || ("${SITEID}" eq "GYX")
          || ("${SITEID}" eq "KEY") || ("${SITEID}" eq "TAE") || ("${SITEID}" eq "MOB")
          || ("${SITEID}" eq "HGX") || ("${SITEID}" eq "HFO") ) {
           for (my $core=16; $core<48; $core++){
	      #AW $hotfilelocation="${INPUTdir}/hotstart/PE00${core}/${hottime[0]}";
	      $hotfilelocation="${hotfiles_cyc}/PE00${core}/${hottime[0]}";
      	      $newhotfilelocation="${RUNdir}/PE00${core}/";
	      system("cp -pfv $hotfilelocation $newhotfilelocation >> ${LOGdir}/hotstart.log 2>&1");
           }
        }
        if ( "${SITEID}" eq "ALU" ) {
           for (my $core=48; $core<84; $core++){
	      #AW $hotfilelocation="${INPUTdir}/hotstart/PE00${core}/${hottime[0]}";
	      $hotfilelocation="${hotfiles_cyc}/PE00${core}/${hottime[0]}";
      	      $newhotfilelocation="${RUNdir}/PE00${core}/";
	      system("cp -pfv $hotfilelocation $newhotfilelocation >> ${LOGdir}/hotstart.log 2>&1");
           }
        }
        if ( ("${SITEID}" eq "KEY") || ("${SITEID}" eq "MFL") || ("${SITEID}" eq "AKQ") 
          || ("${SITEID}" eq "MLB") || ("${SITEID}" eq "BOX") ) {
           for (my $core=48; $core<96; $core++){
	      #AW $hotfilelocation="${INPUTdir}/hotstart/PE00${core}/${hottime[0]}";
	      $hotfilelocation="${hotfiles_cyc}/PE00${core}/${hottime[0]}";
      	      $newhotfilelocation="${RUNdir}/PE00${core}/";
	      system("cp -pfv $hotfilelocation $newhotfilelocation >> ${LOGdir}/hotstart.log 2>&1");
           }
        }
	system("echo OFF > ${RUNdir}/hotstart.flag");
	#if(-e "${RUNdir}/PE0000/${hottime[0]}") {
	#    system("cp -pfv ${INPUTdir}/hotstart/${hottime[0]}-001 ${RUNdir}/${hottime[0]} >> ${LOGdir}/hotstart.log 2>&1");
	#}

	if (-e "${RUNdir}/PE0000/${hottime[0]}" ) {
	    system("echo Hotstart file ${hottime[0]} was used to initialize this UNSWAN run. >> ${LOGdir}/hotstart.log");
	    system("echo TRUE > ${RUNdir}/hotstart.flag");
	    Logs::run("GrADS plots will include all images.", 1);
	} 
	else {
	    system("echo No hotstart file was used for this UNSWAN run. Do not use the first 12 hrs of this run. >> ${LOGdir}/hotstart.log");
	    system("echo FALSE > ${RUNdir}/hotstart.flag");
	    Logs::run("GrADS plots will exclude the first 12 hrs of images for model spin-up.", 1);
	#    $HOTSTART = "FALSE";
	}
        # Reject hotfiles older than 2 days
	if (( -e "${RUNdir}/PE0000/${hottime[0]}" ) && ( int( -M "${RUNdir}/PE0000/${hottime[0]}" ) < 3 )) {
	    if ($inputFile eq "inputCG1") {
		$inputCGx[@inputCGx]="\$";
		$inputCGx[@inputCGx]="\$";
		$inputCGx[@inputCGx]="\$ SWAN will use the latest hotstart file.";
		$inputCGx[@inputCGx]="\$";
		$inputCGx[@inputCGx]="INITial HOTStart MULTiple '" . $hottime[0] . "'";
		$inputCGx[@inputCGx]="\$";
		Logs::run("This run will use the latest hotstart file available.", 1);
	    } else {
	    Logs::run("The latest hotstart file does not exist, too old to use or this is an inner nest.", 1);
	    Logs::run("GrADS plots will exclude the first 12 hrs of images for model spin-up.", 1);
	    system("echo FALSE > ${RUNdir}/hotstart.flag");
	#    $HOTSTART = "FALSE";
	    }
	}
    }   #UNSWAN
    } else {
       system("echo FALSE > ${RUNdir}/hotstart.flag");
    }    

###############################################################################################
# TAFB-NWPS boundary condition section:

      if($WNA eq "TAFB-NWPS") {
       # TODO: We need to move this to NCEP site and move to cron script for processing	  
       system("wget innovation.srh.noaa.gov/images/rtimages/nhc/nwps/wfo_boundary_conditions/bc_${SITEID}_$hottime[0]");
       system("cp -pfv bc_${SITEID}_$hottime[0] ${RUNdir}");
       Logs::run("my run is bc_${SITEID}_$hottime[0]", 1);

       if ($inputFile eq "inputCG1") {
                $inputCGx[@inputCGx]="\$";
                $inputCGx[@inputCGx]="\$";
                $inputCGx[@inputCGx]="\$ Initializing boundary with TAFB output";
                $inputCGx[@inputCGx]="\$";
                $inputCGx[@inputCGx]="BOUN NEST 'bc_${SITEID}_$hottime[0]'";
                $inputCGx[@inputCGx]="\$";     
        }     
 
       if(-e "${RUNdir}/bc_${SITEID}_$hottime[0]") {
         system("echo TAFB-NWPS Boundary Conditions were used to initialize your grid for this run. >> ${LOGdir}/hotstart.log");
       } else {
         system("echo WARNING!! TAFB-NWPS Boundary Conditions were not processed for this run. Boundary conditions were not used!  >> ${LOGdir}/hotstart.log");
       }    

     } 
    
################################################################################################
    
    # DS -> NOTE: &fixDate modifies BLOCK output control and uses $suffix (see above comment).
    &fixDate();
    
    # DS -> NOTE: &fixComputationDate modifies COMPUTE output control.
    if ($DEBUGGING eq "TRUE") {
	print "TIME STEP BEFORE FUNCTION IS: $timeStepLength\n";
    }
    &fixComputationDate($timeStepLength,$inputFile,\@time,\@hottime);
    
    untie @inputCGx;
#AW    my $archInputFile="INPUT.CG".$CG{CGNUM}.".$dateSuffix";
#AW    my $swanInputFile="INPUT";
    Logs::bug("done creating command file for CG".$CG{CGNUM},1);
    
#AW    #swan need the input file to be called INPUT (as we need also to archive it, we copy it first)
#AW    &copyFile($inputFile,$swanInputFile);
#AW    #put it in swanInput directory (where the swan executable is)
#AW    &mvFiles("${RUNdir}/",$swanInputFile);
#AW    #to archive the file, include date in name to recognize it
#AW    system("cp $inputFile $archInputFile")==0 or &Logs::err("Couldn't copy file $inputFile to $archInputFile : $!",2);
#AW    &archiveFiles($archInputFile,"${RUNdir}");
    
    Logs::bug("end makeInputCGx",1);
}

################################################################################
# NAME: &fixDate
# CALL:&fixDate();
# GOAL:change all the date after OUTPUT with the right date
################################################################################

sub fixDate {
    my $line=0;
    while(1){
	Logs::bug("I am in fixDate, and date=$date, line=$line",9);
	$line=&giveNextEntryLine("OUTPUT",$line,\@inputCGx);
	last if ($line==-1);
	$inputCGx[$line]=~"OUTPUT";
	my $prefix=$`; #`

        #NOTE: Set output time step to $suffix, except for contour output 
        #      where a smaller value is needed for rip current and runup (1.0 H)
        my $_=$inputCGx[$line];
        my $otype = (split)[1];
        if (($otype eq "'5mcont'") || ($otype eq "'20mcont'")) {
           Logs::bug("Output is of type $otype, time step set at 1.0 H",9);
           $inputCGx[$line]=$prefix."OUTPUT ".$date." 1.0 HR";
        } else {
           $inputCGx[$line]=$prefix."OUTPUT ".$date.$suffix;
        }

        #AW: $inputCGx[$line]=$prefix."OUTPUT ".$date.$suffix;
	Logs::bug("printing to line $line: ".$prefix."OUTPUT ".$date.$suffix,9);
	$line++;
    }
    #Logs::bug("end fixDate",9);
}



################################################################################
# NAME: &fixComputationDate
# CALL:&fixComputationdate(@time,$timeStepLength);
# GOAL:create the computation time lines
################################################################################

sub fixComputationDate {

    my($timeStepLength,$inputFile,$time,$hottime)=@_;
    my($sitefile, $cginprog,$inpback, $siteidlc);
    my @time = @$time;
    my @hottime = @$hottime;

    if ($DEBUGGING eq 'TRUE') {    
	foreach $blah (@time) {
	    print "time = $blah\n";
	}
	foreach $blah (@hottime) {
	    print "hottime = $blah\n";
	}
    }

    my $i=0;
    my $line=0;

    my $end=(SWANFCSTLENGTH/$hotStepLength);
    $end2=(SWANFCSTLENGTH/$timeStepLength);
    
    # Model time step defined.
    # Check for a user defined deltac
    my $deltac = ${timeStepLength}*3600/18; #600 s source model time step
#XXXXXXXXXXXXX  RPH
print "In SetupCG  USERDELTAC: $USERDELTAC";
#my $deltac = 1800; #600 s source model time step
    if (($USERDELTAC eq "") || ($USERDELTAC eq 'NO')) {
	Logs::run("Using default DELTAC of ${deltac} seconds");
    }
    else {
	if ($USERDELTAC =~ /\d/ || $USERDELTAC =~ /^-?\d*\.?\d*$/ ) {
	    Logs::run("User has specified a DELTAC of ${USERDELTAC} seconds");
	    $deltac = $USERDELTAC;
	}
	else {
	    Logs::run("ERROR - User has specified invalid DELTAC value of ${USERDELTAC}");
	    Logs::run("WARNING - Will continue run using DELTAC value of ${deltac}");
	}
    }
    
    $inputCGx[@inputCGx] = "\$";
    $inputCGx[@inputCGx] = "\$ The following commands specify at which instances in time to write to output";
    
################################################################################
# HotStart-Time Step Integration-Stationary-NonStationary
# 
# created: alex.gibbs@noaa.gov & roberto.padilla@noaa.gov
#
# NWPS default model time step: 600s
# NWPS default hotfile generation: 3 hrly 
# NonStationary Mode: All outer domains defined as CG1
# Stationary Mode: All inner nests defined to as CG2 or greater.
#
#################################################################################

    $inpback=$inputFile;
    $cginprog=chop($inpback)-1;
    $siteidlc=lc(${SITEID});
    $sitefile= "${DATA}/parm/templates/${siteidlc}/${SITEID}";

    if( -e $sitefile ) {
	print "Opening file $sitefile\n";
	open SITEFILE, "$sitefile";
	while ( $line = <SITEFILE> ) {
	    chomp($line);
	    my @values = split /\s+/,$line;
	    if($values[0] eq "export" && $values[1] ne undef){
		@value2 = split //,$values[1];
		#splice(ARRAY, OFFSET, LENGTH)
		@found = splice(@value2, 0, 5);
		$final= join ("", @found);
		if($final eq "STATN"){
		    $gridn=splice(@value2, 0,1);
		    @found = splice(@value2, 2,3);
		    $stat= join ("", @found);
		    if ($cginprog eq $gridn){
			$STATorNON=$stat;
			print "GRID Number $cginprog: $STATorNON\n";
		    }
		}
	    }
	}
    }
    else {
	print "ERROR - Cannot open sitefile $sitefile\n";
        system("export err=1; err_chk")
    }

    close SITEFILE;
    if ($STSTorNON eq "STA"){
      print " **** STATIONARY RUN ****\n";
    }else{
      print " **** NONSTATIONARY RUN ****\n";
    }

    while ($i<$end)  {
        #This is to add a STATIONARY initial conditions for:
        # (a) a NON-Stationary run on a nested grid, or
        # (b) if no hotfile is available for the CG1 domain (system cold restart)
        #print "++++++++++++++++++++++ i= $i +++++++++++++++++\n";
        if ($inputFile ne "inputCG1" && $STATorNON eq "NON" && $i==0) {
	    $inputCGx[@inputCGx]="COMPUTE STAT ".$hottime[$i];
        }
        my $HotFlagFile = "hotstart.flag";
        open IN, "<$HotFlagFile"  or die "Cannot open: $!";
        $HOTFLAG = <IN>;
        chomp ($HOTFLAG);
        close IN;   
        if ($inputFile eq "inputCG1" && $HOTFLAG eq "FALSE" && $i==0) {
            Logs::run("WARNING: No HOTFILES available for this cycle. Including a COMPUTE STAT cold restart in CG1 run");
            system("echo WARNING: No HOTFILES available for this cycle. Including a COMPUTE STAT cold restart in CG1 run  >> ${RUNdir}/Warn_Forecaster_${SITEID}.${PDY}.txt");
            #AW: This warning message to the jlogfile/SDM is perhaps too verbose, 
            #    since it doesn't require any action.
            #system('msg=""WARNING: No HOTFILES available for this cycle. Including a COMPUTE STAT cold restart in CG1 run""');
            #system('./postmsg ""$jlogfile"" ""$msg""');
	    $inputCGx[@inputCGx]="COMPUTE STAT ".$hottime[$i];
        }

	if ($inputFile eq "inputCG1" || $STATorNON eq "NON") {

#=====================================================================================================
            # ADD HERE THE ESTOFS WATER LEVELS LINES WHEN PSURGE IS USED

            my $EstofsLines = "Estofs_Lines$inputFile";
            Logs::run("$EstofsLines");

            if ( -e $EstofsLines) {
               Logs::run("${RUNdir}/Estofs_Lines   Exists!"); 
               print" ADD HERE THE ESTOFS WATER LEVELS LINES WHEN PSURGE IS USED";
              Logs::run("COMPUTE NONSTAT  $hottime[$i] $deltac SEC   $hottime[$i+1]");
               my $PsurgeEndTime = "Psurge_End_Time";
               #open my $in, "<$PsurgeEndTime" or die "Can't read file: $!";
               open IN, "<$PsurgeEndTime"  or die "Cannot open: $!";
               $PSendTime = <IN>;
               chomp ($PSendTime);
               close IN;
               #while( <$in> ) {
               #  my $PSendTime=$_;
               # Logs::run("PSendTime: $PSendTime");
               #  chomp $PSendTime;
               #}
               #close $in;
               my @ptime = split("", $PSendTime);
                Logs::run("PSendTime: $PSendTime");

               my $pstime= $ptime[0].$ptime[1].$ptime[2].$ptime[3].$ptime[4].$ptime[5].$ptime[6].$ptime[7].$ptime[9].$ptime[10].$ptime[11].$ptime[12];

               Logs::run("hottime[i]: $hottime[$i]");

               my @hoti = split("", $hottime[$i]);
               my $hotime= $hoti[0].$hoti[1].$hoti[2].$hoti[3].$hoti[4].$hoti[5].$hoti[6].$hoti[7].$hoti[9].$hoti[10].$hoti[11].$hoti[12];
               Logs::run("hotime: $hotime");

               Logs::run("pstime:$pstime     hotime:$hotime");

               if ( $hotime >= $pstime) {
                  print "$pstime IS EQUAL TO  $hotime, ADDING ESTOFS LINES TO inputCG";
                  open IN, "<$EstofsLines"  or die "Cannot open: $!";

                 # while( <$in> ) {
                     $line= <IN>;
                     Logs::run("line to include: $line");
	             $inputCGx[@inputCGx]=$line;
                     $line= <IN>;
                     Logs::run("line to include: $line");
	             $inputCGx[@inputCGx]=$line;
                     system("rm -f $EstofsLines");
                     system("ls -lt");
                  #}
               close IN;
               }
            }
#================================================================================
	    $inputCGx[@inputCGx]="COMPUTE NONSTAT ".$hottime[$i]." ".$deltac." SEC ".$hottime[$i+1];
            #Here only for CG1 there are hotfile, NOT for  nested grids.
	    #if ($inputFile eq "inputCG1") {
	    if ($WNA ne "test" && $inputFile eq "inputCG1") {
	        $inputCGx[@inputCGx]="HOTFile '" . $hottime[$i+1] . "'";
            }
	} 
	else {
	    $inputCGx[@inputCGx]="COMPUTE STAT ".$hottime[$i];
            #NOT hotfiles output in nested grids.
            #$inputCGx[@inputCGx]="HOTFile '" . $hottime[$i+1] . "'";
	}
	$i++;
    }
    if ($STATorNON eq "STA") {
	$inputCGx[@inputCGx]="COMPUTE STAT ".$hottime[$end];
    }
    $inputCGx[@inputCGx]="STOP";
}

# NAME: &correctCurrentLine
# CALL: &correctCurrentLine();
# GOAL:create the computation time lines
################################################################################
sub correctCurrentLine{
	#Logs::bug("correctCurrentLine",9);
  	$inpGrid=~/NONSTAT/;
  	my $end=$'; #'
  	@info = split(" ",$end);
  	$end = " $info[0]"." 1.0 HR "."$info[3]";

  	Logs::bug("end=$end",9) if ($test==1);

  	# update water level input line
  	my $line=&giveNextEntryLine('INPGRID WLEV',1,\@inputCGx);
  	$inputCGx[$line]=~/NONSTAT/;
  	my $beginning=$`;
  	$inputCGx[$line]=$beginning.$&.$end;

  	# update current input line
  	$line=&giveNextEntryLine('INPGRID CURR',1,\@inputCGx);
  	$inputCGx[$line]=~/NONSTAT/;
  	$beginning=$`;
  	$inputCGx[$line]=$beginning.$&.$end;

  	#Logs::bug("currentLine=$inputCGx[$line]",9);
	#Logs::bug("end correctCurrentLine",9);
}
#################################################################################
# NAME: &getCGBoundaries
# CALL: &getCGBoundaries(%CG);
# GOAL: get southwest grid point (lat/lon), compute size of grid (degrees), 
#	get number of meshes in grid.
# VARIABLES: $southwestlat, $southwestlon, $lengthdegreeslat, $lengthdegreeslon, 
#            $nummeshlat,$nummeshlon
#
# 
################################################################################
sub getCGBoundaries (%) {
	#get config file values
	my %CG = @_;
	my ($southwestlat, $southwestlon) = ($CG{CGBOUNDARIES}{SOUTHWESTLAT},$CG{CGBOUNDARIES}{SOUTHWESTLON});
	$southwestlon = $southwestlon+360 if ($southwestlon =~ /-/);
	my ($northeastlat, $northeastlon) = ($CG{CGBOUNDARIES}{NORTHEASTLAT},$CG{CGBOUNDARIES}{NORTHEASTLON});
	$northeastlon = $northeastlon+360 if ($northeastlon =~ /-/);
	my ($nummeshlat,$nummeshlon) = ($CG{CGBOUNDARIES}{NUMMESHESLAT}, $CG{CGBOUNDARIES}{NUMMESHESLON});

	#compute size of grid (degrees)
	my $lengthdegreeslat = $northeastlat - $southwestlat;
	my $lengthdegreeslon = $northeastlon - $southwestlon;

	#return values
	return ($southwestlat, $southwestlon, $northeastlat, $northeastlon, $lengthdegreeslat, $lengthdegreeslon, $nummeshlat, $nummeshlon);
}
################################################################################
# NAME: &getSubGrid
# CALL: &getSubGrid(%ZONE);
# GOAL: compute zone's bouindaries in terms of parent CG's grid
################################################################################
sub getSubGrid ($%) {
	my ($zone,%CG) = @_;
	my %ZONE = %{$CG{PARTITIONZONES}{$zone}};
	my (@lats,@lons);

#get zone boundary latitudes and longitudes
	foreach my $latlon (@{$ZONE{BOUNDARY}}) {
		($lats[++$#lats],$lons[++$#lons]) = split('/',$latlon);
		#convert negative longitude values to positive values
		$lons[$#lons] += 360 if ($lons[$#lons] =~ /-/);
	}
	#find extreme longitudes
	@lons = sort(@lons); #places smallest number in first element
	($westmostlon, $eastmostlon) = ($lons[0],$lons[$#lons]);
        #find extreme latitudes
        @lats = sort(@lats); #places smallest number in first element
        ($southmostlat, $northmostlat) = ($lats[0], $lats[$#lats]);
	
#get CG's boundaries 
	my ($CGsouthwestlat, $CGsouthwestlon, $CGnortheastlat, $CGnortheastlon, 
		$CGlengthdegreeslat, $CGlengthdegreeslon, $CGnummeshlat,$CGnummeshlon) 
			= &getCGBoundaries(%CG);
	#convert negative values to positive values
	$CGsouthwestlon = ($CGsouthwestlon + 360) if ($CGsouthwestlon =~ /-/);
	$CGnortheastlon = ($CGnortheastlon + 360) if ($CGnortheastlon =~ /-/);

#Check that zone boundaries are within parent CG's boundaries, replace zone boundary values if needed. 
	if ($westmostlon < $CGsouthwestlon) {
		$westmostlon = $CGsouthwestlon;
		Logs::err("Zone: $zone west boundary outside of ".$CG{CGNUM},3);
	}
	if ($eastmostlon > $CGnortheastlon) {
		$eastmostlon = $CGnortheastlon;
		Logs::err("Zone: $zone east boundary outside of ".$CG{CGNUM},3);
	}
	if ($northmostlat > $CGnortheastlat) {
		$northmostlat = $CGnortheastlat;
                Logs::err("Zone: $zone north boundary outside of ".$CG{CGNUM},3);
        }
	if ($southmostlat < $CGsouthwestlat) {
		$southmostlat = $CGsouthwestlat;
                Logs::err("Zone: $zone south boundary outside of ".$CG{CGNUM},3);
        }

#compute SubGrid points
	my $westNode = floor((($westmostlon-$CGsouthwestlon)/$CGlengthdegreeslon)*$CGnummeshlon);
	my $eastNode = ceil((($eastmostlon-$CGsouthwestlon)/$CGlengthdegreeslon)*$CGnummeshlon);
	my $southNode = floor((($southmostlat-$CGsouthwestlat)/$CGlengthdegreeslat)*$CGnummeshlat);
 	my $northNode = ceil((($northmostlat-$CGsouthwestlat)/$CGlengthdegreeslat)*$CGnummeshlat);

#return SubGrid values
	#print "\nSubGrid: $westNode, $eastNode, $southNode, $northNode\n";
	return ($westNode, $eastNode, $southNode, $northNode);
}
#################################################################################
1;


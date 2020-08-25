#!/usr/bin/perl
# ----------------------------------------------------------- 
# PERL Script
# PERL Version(s): 5
# Original Author(s): Eve-Marie Devalire for WFO-Eureka 
# File Creation Date: 04/20/2004
# Date Last Modified: 08/20/2015
#
# Version control for WCOSS: 1.00
#
# Support Team:
#
# Contributors: Alex Gibbs, Tony Freeman, Pablo Santos, Douglas Gaer, 
#               Roberto Padilla-Hernandez
#
# Inclusion of  WWIII and Version for WCOSS Roberto.Padilla@noaa.gov
#  :
# ----------------------------------------------------------- 
# ------------- Program Description and Details ------------- 
# ----------------------------------------------------------- 
################################################################################
#                               RunSwan package                                #
################################################################################
# This script creates the command files, move and make the SWAN model running  #
################################################################################
#               The subroutines implemented here are the following:            #
################################################################################
##createSwanCommandFiles                                                       #
##runWaveModel                                                                 #
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
package RunSwan;
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
my $NWPSplatform = $ENV{'NWPSplatform'};
##our $RUNdir = $ENV{'RUNdir'};
our $MODELCORE = $ENV{'MODELCORE'};
our $MPMODE = $ENV{'MPMODE'};
my $HOMEdir = $ENV{'HOME'};
our %RunValues;
my $SITEID = $ENV{'SITEID'};
my $PDY = $ENV{'PDY'};
my $WNA = $ENV{'WNA'};
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
@EXPORT=qw(runModel);
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
#print "-----------------------Values in RunSwan.pm --------------------\n";
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
# NAME: &runModel
# CALL: &runModel($date,$inpGrid,$filename)
# GOAL: For a given CG domain this subroutine runs the model and moves
#       the SWAN's output files globally at the end (less function calls)
#       inputCGx are command files from the past run used as templates
################################################################################

sub runModel ($$$%){
	local ($date,$inpGrid,$fileName,%CG) = @_;
	Logs::run("Running main wave model.");
	Logs::bug("begin runModel",1);
        local $readInpWind="READINP WIND 1.0 '".$fileName."' 3 0 0 0 FREE";
	local ($century,$year,$month,$day,$hour)=unpack"A2 A2 A2 A2 A2",$date;
	$date=$century.$year.$month.$day.".".$hour."00";
	$time[0]=$date;
	local ($todayYear,$todayMonth,$todayDay,undef,$todayHour)=unpack"A4 A2 A2 A A2",$date;
	Logs::bug("in make swan run(thisHour,thisDay,thisMonth,thisYear)=($todayHour/$todayDay/$todayMonth/$todayYear)",9);	
	local $dateSuffix="YY".$year.".MO".$month.".DD".$day.".HH".$hour;
	chdir ("${RUNdir}/") or Logs::err("directory change issue\ncan't change directory to ${RUNdir}/ error: $!",2);
#for_WCOSS
#coderunSwansh01
        $numofGrids=scalar keys %ConfigSwan::CGS;

        &runWaveModel(%CG);

        &renameFilesWithSuffix($dateSuffix,"PRT|spec2d|TAB|CGRID");
	# 06/24/2011: Moving SWAN ouput files for ${OUTPUTdir}/partition directory 
#        my $cgxx="CG".$CG{CGNUM}; 
#        system(" mkdir -p  ${OUTPUTdir}/partition/${cgxx}");
#        &mvFiles("${OUTPUTdir}/partition/${cgxx}","PRT"); 
        &mvFiles("${OUTPUTdir}/spectra/","spec2d");

	# 05/17/2011: Moving SWAN output files for ${OUTPUTdir}/grid directory
        &mvFiles("${OUTPUTdir}/grid/","CGRID");

        &archiveFiles("PRINT","${RUNdir}");
	Logs::bug("end runModel",1);
	return $dateSuffix;
}

################################################################################
# NAME: &runWaveModel
# CALL: &runWaveModel(%CG);
# GOAL: Here is where the CORE WAVE model (SWAN or WWIII) run starts
################################################################################

sub runWaveModel (%){
    # 04/23/2010: Add flag to signal a SWAN.EXE crash to the Perl/BASH interface
    # Clean up any existing flag files
    `rm -f SWAN_EXE_HAS_CRASHED > /dev/null 2>&1`; 

    Logs::bug("begin runWaveModel",1);
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

    # replace the CGRID line for unstructured mode
    if ($MODELCORE eq "UNSWAN") {
       print "Configure the unstructured INPUT file for SWAN\n";
       my $pattern=`grep "^CGRID" inputCG1`;
       chomp ($pattern);
       system("sed -i 's/$pattern/CGRID UNSTRUCTURED CIRCLE 36 0.035 1.5 36/g' inputCG1");
       system("sed -i 's/\$ << UNSTR GRID >>/READ UNSTRUCTURED ADCIRC/g' inputCG1");
    }

    if ( ("${SITEID}" eq "MFL") || ("${SITEID}" eq "KEY") ) {
       system("sed -i 's/NUM ACCUR 0.04 0.04 0.04 96. 10/NUM STOPC dabs=0.005 drel=0.01 curvat=0.005 npnts=96.0 NONSTAT mxitns=5 limiter=0.01/g' inputCG1");
    }

    #swan need the input file to be called INPUT (as we need also to archive it, we copy it first)
    untie @inputCGx;
    my $inputFile="inputCG".$CG{CGNUM};
    my $archInputFile="INPUT.CG".$CG{CGNUM}.".$dateSuffix";
    my $swanInputFile="INPUT";
    &copyFile($inputFile,$swanInputFile);
    #put it in swanInput directory (where the swan executable is)
    &mvFiles("${RUNdir}/",$swanInputFile);
    #to archive the file, include date in name to recognize it
    system("cp $inputFile $archInputFile")==0 or &Logs::err("Couldn't copy file $inputFile to $archInputFile : $!",2);
    &archiveFiles($archInputFile,"${RUNdir}");

    # NOTE: Here is where the CORE WAVE model (SWAN or WWIII) run starts
    my $CGinProg=$CG{CGNUM};
    print "Model core: $MODELCORE\n";
    print "Multi Processor Mode: $MPMODE\n";
    if ( ($MODELCORE eq "SWAN") || ($MODELCORE eq "UNSWAN") ) {
       # Start the SWAN.EXE here
       Logs::run("Begin SWAN model run for CG".$CG{CGNUM}.".");
       system("date +%s > ${VARdir}/modelrun_start_secs.txt");
       system("${USHnwps}/swanexe.sh ".$CG{CGNUM}." > swan.log 2> ${LOGdir}/swan_exe_error.log");
       system("date +%s > ${VARdir}/modelrun_end_secs.txt");
    }
    else {
	if ($CG{CGNUM} eq $numofGrids) {
	    print "++++++++++++++sub makeInputCGx++++++++++++++++++\n";
	    print " Number of Computational Grids: $numofGrids\n";
	    print " Working in Comp Grid Number  : $CG{CGNUM}\n";
	    print " Is Nest activated            : $NESTS\n";
	    print "+++++++++++++++++++++++++++++++++++++++++++++++\n";
	    &getWW3Files($archInputFile,%CG);
	    # Start the WWIII.EXEs here
	    Logs::run("Begin WWIII model run for CG".$CG{CGNUM}.".");
	    system("date +%s > ${VARdir}/modelrun_start_secs.txt");
	    system ("${RUNdir}/run_ww3_multi_updated.sh > ww3.log 2> ${LOGdir}/ww3_exe_error.log");
	    #system ("${NWPSdir}/ush/bin/run_ww3_multi_updated.sh > ww3.log 2> ${LOGdir}/ww3_exe_error.log");
	    system("date +%s > ${VARdir}/modelrun_end_secs.txt");
	    Logs::run("END WWIII model run for CG".$CG{CGNUM}.".");
	    print "Formatting all output files from WW3\n\n";
	    &formatWW3Fields;
	    &formatWW3Spec;
	    &formatWW3PntWnd;
	}
    }

    # TRACKING FOR CG1 ONLY
    #my $sysTrcktFileName="swan_part.CG".$CG{CGNUM}.".raw";
    my $sysTrcktFileName="swan_part.CG1.raw";

    Logs::run("End Wave model run for CG".$CG{CGNUM}.".");
    #&ReadMetadataFile($archInputFile,%CG);
    my $cgnum="CG".$CG{CGNUM};
        
    if(-e "${RUNdir}/$sysTrcktFileName") {
        system("echo TRUE > ${RUNdir}/Tracking.flag");
##  here edit ww3_systrk.inp
        my @timeBeg=split('\.' ,$time[0]);
        my $timeforsystrk=$timeBeg[0]." ".$timeBeg[1]."00";
        my $tStepInSec=$timeStepLength*3600;
        my $numtimes=floor(SWANFCSTLENGTH/$timeStepLength)+1;
        local @inputsystrk;
        tie @inputsystrk, 'Tie::File', "ww3_systrk.inp" or print "array tie issue $file with the corresponding file \n";
        my $sust1="#TbegOut#";
        my $sust2="#DeltaOut#";
        my $sust3="#NumOfOutTimes#";
        foreach my $line (@inputsystrk) {
          $line =~ s/$sust1/$timeforsystrk/gi;
          $line =~ s/$sust2/$tStepInSec/gi;
          $line =~ s/$sust3/$numtimes/gi;
        }
    }
    else{
        system("echo FALSE > ${RUNdir}/Tracking.flag");
    } 
    
     #Check for SWAN.EXE crash. NOTE: When the model crashed we cannot proceed
     #or the graphics post processing will hang forever.
    if(-e "HSIG.CG".$CG{CGNUM}.".CGRID-001") {
	open ERRF, "${LOGdir}/swan_exe_error.log";
	my $holdTerminator = $/;
	undef $/;
	my $errfcontents = <ERRF>;
	$/ = $holdTerminator;
	close ERRF;
	`touch SWAN_EXE_HAS_CRASHED`; 
	Logs::run("SWAN.EXE failure, halting run.");
        #AW>system('msg=""FATAL ERROR: SWAN.EXE failure, halting run.""')
        #AW>system('./postmsg ""$jlogfile"" ""$msg""')
        #AW>system('export err=1; ./err_chk')
	# The Perl scripts will die and exit here...
	Logs::err("SWAN.EXE failure, halting run. SWAN.EXE's error message reads:\n$errfcontents",2);
    }  
    
    # Check to ensure swan ran without error by looking for HSIG.CGx.CGRID
    unless(-e "HSIG.CG".$CG{CGNUM}.".CGRID"){
	# file missing, so report the error from swan's Errfile.  use perl's 
	# 'SLURP' capability to grab the whole file as a string
	open ERRF, "${RUNdir}/Errfile-001";
	my $holdTerminator = $/;
	undef $/;
	my $errfcontents = <ERRF>;
	$/ = $holdTerminator;
	close ERRF;
	# Signal a SWAN.EXE crash.
	`touch SWAN_EXE_HAS_CRASHED`; 
	# Add logging to the RUN log.
	Logs::run("SWAN model failure, halting run.");
        #AW>system('msg=""FATAL ERROR: SWAN.EXE failure, halting run.""')
        #AW>system('./postmsg ""$jlogfile"" ""$msg""')
        #AW>system('export err=1; ./err_chk')
	Logs::err("SWAN model failure, halting run. SWAN's error message reads:\n$errfcontents",2);
    }

    system("cat PRINT* > PRINTALL");
    system("mv -f PRINTALL PRINT");
#   system("cp -f PRINT $LOGdir");
#   rename("PRINT","PRINT.CG".$CG{CGNUM}.".$dateSuffix") or Logs::err("Could not rename file PRINT to PRINT.CG".$CG{CGNUM}.".$dateSuffix, error $!",2);
    my $swanPrintFile="PRINT.CG".$CG{CGNUM}.".$dateSuffix";
    rename("PRINT",$swanPrintFile) or Logs::err("Could not rename file PRINT to $swanPrintFile, error $!",2);

    system("cp -f $swanPrintFile $LOGdir");

    Logs::bug("end runWaveModel",1);
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
################################################################################`
# Subroutine ReadMetadataFile
# Calling program/subroutine: RunSwan.pm/getWW3Files
# CALL: &ReadMetadataFile($swanInputFile,%CG);
# GOAL: for each domain, it read the input file for SWAN, which in this case 
#       it is a kind of metadata file for WW3 input files. Moves the
#       files appropriately
# SUBROUTINES CALLS:  &makeWindforWW3, &makeWW3InputFiles;
# Original Author(s): Roberto Padilla-Hernandez
# File Creation Date: January-2012
# Date Last Modified:
################################################################################
sub ReadMetadataFile($%) {
    use Tie::File;
    local ($swanInputFile,%CG)=@_;
    my ($Tbegc   , $Unitsc, $windExt, @wndExt,$runID);
    my ($currdExt, @curExt                          );
    my (@char    , @char1 , @char2                  );
    my $computLines=0; 
    $numofOutputPoints=0;
    $numofOutputSpectra=0; 
    $numofOutputPartition=0;     
    $RunValues{"NumofCGrids"}  =$numofGrids;
#   if currents are present variable is changed to true later
    $RunValues{"CURRTRUE"  } ="FALSE";
#   TODO define the number of wind grids. This has to be computed reading the
#   INPGRID commmand from INPUTCGX files, if there is one or several wind files
    $RunValues{"NumofInpGrds"} = 0; #$numofWndGrids;
    $RunValues{"WNDFileExt"  } ="no";
    $RunValues{"CURFileExt"  } ="no";
    $RunValues{"CURFileType" } ="no";
    $RunValues{"DKShift"     } ="F";
    $RunValues{"WLEFileExt"  } ="no";
    $RunValues{"ICEFileExt"  } ="no";
    $RunValues{"WLEMultInp"  } ="\$ wle";
    $RunValues{"CURMultInp"  } ="\$ cur";
    $RunValues{"WNDMultInp"  } ="\$ wnd";
    $RunValues{"ICEMultInp"  } ="\$ ice";
    $RunValues{"BCTRUE"      } ="FALSE";
    chdir("${RUNdir}/"); 
#    system("pwd");

#
    $RunValues{"CGX"}=$CG{CGNUM};
    open (SWANINP,$swanInputFile);
    if(! SWANINP ) {
	system("echo \"**Input file : $swanInputFile could not be opened\" >> getWW3Files.log");
	exit;
   }
#	print "**Input file : $swanInputFile  opened \n";
    #Looking for data for every command in the "user input" metadata
    my $charcom="\$"; 
    while (<SWANINP>) {
        $comline=$_;
        @temp=split /\s+/,$comline;
        if ($comline =~ /^\$/) {
	}else{
	   if ($comline =~/^PROJ/)  {
              #print " Searching for:  PROJ\n";;
              $keyfound=$_;
	      chomp $keyfound;
	      @temp=split /\s+/,$keyfound;
              @char1=split //, $temp[1]; 
              @char2=split //, $temp[2];
              #pop @char1;
              #shift @char2; #scraching the apostrophes in the name
              $proj=join ("",@char1," ");

              $proj="   ".$proj;
              $RunValues{"PROJ"}=$proj;     # No. of elements: 1
              $runID=join ("",@char2);
              $RunValues{"RunID"}=$runID;     # No. of elements: 1
              undef $keyfound, @temp;
           }
           if ($comline =~/SET/)  {
             #print " Searching for:  SET\n";;
             $keyfound=$_;
	     chomp $keyfound;
             @temp=split /\s+/,$keyfound;
             $level= $temp[1]; $depmin=$temp[2];
             $RunValues{"level"}  =$temp[1];
             $RunValues{"nor"}    =$temp[2];
             $RunValues{"depmin"} =$temp[3];
             $RunValues{"maxmes"} =$temp[4];
             $RunValues{"maxerr"} =$temp[5];
             $RunValues{"grav"}   =$temp[6];
             $RunValues{"rho"}    =$temp[7];
             $RunValues{"convent"}=$temp[8];  #total elements: 9 
             undef $keyfound, @temp;
           }
           if ($comline =~/MODE/)  {
             #print " Searching for:  MODE\n";;
             $keyfound=$_;
	        chomp $keyfound;
             @temp=split /\s+/,$keyfound;
             $RunValues{"MODE"}=$temp[1];   #total elements: 10 
             undef $keyfound, @temp;
           }
           if ($comline =~/COORD/)  {
             #print " Searching for:  COORD\n";;
             $keyfound=$_;
	        chomp $keyfound;
             @temp=split /\s+/,$keyfound;
             $RunValues{"COORD"}=$temp[1];   #total elements: 11 
             undef $keyfound, @temp;
           }
           if ($comline =~/^CGRID/)  {
             #print " Searching for:  CGRID\n";
             $keyfound=$_;
	        chomp $keyfound;
             @temp=split /\s+/,$_;
             #$RunValues{"xpc"   } =$temp[1];
             #$RunValues{"ypc"   } =$temp[2];
             $RunValues{"alpc"  } =$temp[3];
             $RunValues{"xlenc" } =$temp[4];
             $RunValues{"ylenc" } =$temp[5];
#            for ww3 is the numb of points instead numb of meshes
             $RunValues{"npxc"  } =$temp[6]+1;
             $RunValues{"npyc"  } =$temp[7]+1;
#            WW3 has an extended comp. grid in all boundaries (two columns and rows more
#            and Num of Points, NOT meshes
             $RunValues{"npxcww3"  } =$temp[6]+1;
             $RunValues{"npycww3"  } =$temp[7]+1;
#            In WW3 the output is from 2 to npxc-1 and 2-> npyc-1
             $RunValues{"npxout"  } =$temp[6]+1;
             $RunValues{"npyout"  } =$temp[7]+1;
             $RunValues{"CGnpxnpy"}= $RunValues{"npxc"}*$RunValues{"npyc"};
             $RunValues{"delxc" }= $temp[4]/$temp[6];
             $RunValues{"delyc" }= $temp[5]/$temp[7];
             $RunValues{"xpc"   } =$temp[1];
             $RunValues{"ypc"   } =$temp[2];
             $RunValues{"CIRCLE"} =$temp[8];
             $RunValues{"npdc"  } =$temp[9]+1;
             $RunValues{"flow"  } =$temp[10];
             $RunValues{"fhigh" } =$temp[11]; 
             $RunValues{"npsc"   }=int(log($temp[11]/$temp[10])/log(1.1)+0.5)+1;  #25

             undef $keyfound, @temp;
           }
           if ($comline =~/^INPGRID BOTTOM/)  {
               #print " Searching for:  INPGRID BOTTOM\n";;
             $keyfound=$_;
	        chomp $keyfound;
             @temp=split /\s+/,$_;
             $RunValues{"BOTxpinp"  } =$temp[2];
             $RunValues{"BOTypinp"  } =$temp[3];
             $RunValues{"BOTalpinp" } =$temp[4];
             $RunValues{"BOTnpxinp" } =$temp[5]+1;
             $RunValues{"BOTnpyinp" } =$temp[6]+1;
             $RunValues{"BOTdxinp"  } =$temp[7];
             $RunValues{"BOTdyinp"  } =$temp[8];
             $RunValues{"BOTexcval" } =$temp[10]; #33
             undef $keyfound, @temp;

           }
           if ($comline =~/^READINP BOTTOM/)  {
               #print " Searching for:  READ BOTTOM\n";;
             $keyfound=$_;
	        chomp $keyfound;
             @temp=split /\s+/,$_;
             $RunValues{"BOTfac"    } =$temp[2]*(-1);
             $RunValues{"BOTname"   } =$temp[3];
             $RunValues{"BOTidla"   } =$temp[4];
             $RunValues{"BOTnhedf"  } =$temp[5];
             $RunValues{"BOTformat" } =$temp[6]; #38
             undef $keyfound, @temp;
           }
           if ($comline =~/^INPGRID WIND/)  {
             #print " Searching for: INPGRID WIND\n";;
             $keyfound=$_;
             chomp $keyfound;
             @temp=split /\s+/,$_;
             $RunValues{"WNDxpinp"   } =$temp[2];
             $RunValues{"WNDypinp"   } =$temp[3];
             $RunValues{"WNDalpinp"  } =$temp[4];
#               for ww3 is the numb of points instead numb of meshes
             $RunValues{"WNDnpxinp"  } =$temp[5]+1;
             $RunValues{"WNDnpyinp"  } =$temp[6]+1;
             $RunValues{"WNDnpxnpy"  } =($temp[5]+1)*($temp[6]+1);
             $RunValues{"WNDdxinp"   } =$temp[7];
             $RunValues{"WNDdyinp"   } =$temp[8];
#               end long and end lat
             $RunValues{"WNDxqinp"   } =$temp[2]+($temp[5]+1)*$temp[7];
             $RunValues{"WNDyqinp"   } =$temp[3]+($temp[6]+1)*$temp[8];
             $RunValues{"WNDtbeginp" } =$temp[10];
             $RunValues{"WNDdeltinp" } =$temp[11];
             $RunValues{"WNDtunit"   } =$temp[12];
             $RunValues{"WNDtendinp" } =$temp[13];
             undef $keyfound, @temp;
           }
           if ($comline =~/^READINP WIND/)  {
             #print " Searching for:  READ WIND\n";;
             $keyfound=$_;
	        chomp $keyfound;
             @temp=split /\s+/,$_;
             $RunValues{"WNDfac"    } =$temp[2];
             $RunValues{"WNDname"   } =$temp[3];
             @char=split //,$temp[3];
             pop @char; shift @char; #scraching the apostrophes in the name
             @wndExt = splice @char, 11;
             $windExt= join ("", @wndExt);
             $RunValues{"WNDFileExt"} =$windExt;
             $RunValues{"WNDidla"   } =$temp[4];
             $RunValues{"WNDnhedf"  } =$temp[5];
             $RunValues{"WNDnhedt"  } =$temp[6];
             $RunValues{"WNDnhedv"  } =$temp[7];
             $RunValues{"WNDformat" } =$temp[8];
             $RunValues{"NumofInpGrds"}=$RunValues{"NumofInpGrds"}+1;
             $RunValues{"WNDMultInp"  } ="'wnd'";
             undef $keyfound, @temp;
           }
           if ($comline =~/^INPGRID CUR/)  {
             #print " Searching for: INPGRID CUR\n";;
             $keyfound=$_;
	     chomp $keyfound;
             @temp=split /\s+/,$_;
             $RunValues{"CURxpinp"   } =$temp[2];
             $RunValues{"CURypinp"   } =$temp[3];
             $RunValues{"CURalpinp"  } =$temp[4];
#               for ww3 is the numb of points instead numb of meshes
             $RunValues{"CURnpxinp"  } =$temp[5]+1;
             $RunValues{"CURnpyinp"  } =$temp[6]+1;
             $RunValues{"CURnpxnpy"  } =($temp[5]+1)*($temp[6]+1);
             $RunValues{"CURdxinp"   } =$temp[7];
             $RunValues{"CURdyinp"   } =$temp[8];
#               end long and end lat
             $RunValues{"CURxqinp"   } =$temp[2]+($temp[5]+1)*$temp[7];
             $RunValues{"CURyqinp"   } =$temp[3]+($temp[6]+1)*$temp[8];
             $RunValues{"CURtbeginp" } =$temp[10];
             $RunValues{"CURdeltinp" } =$temp[11];
             $RunValues{"CURtunit"   } =$temp[12];
             $RunValues{"CURtendinp" } =$temp[13];
             undef $keyfound, @temp;
           }
           if ($comline =~/^READINP CUR/)  {
             #print " Searching for:  READ CUR\n";;
             $keyfound=$_;
	        chomp $keyfound;
             @temp=split /\s+/,$_;
             $RunValues{"CURfac"    } =$temp[2];
             $RunValues{"CURname"   } =$temp[3];


#             @char=split //,$temp[3];
#             pop @char; shift @char; #scraching the apostrophes in the name
#             @curExt = splice @char, 15;
#             $currExt= join ("", @curExt);
             $RunValues{"CURFileExt"} ="cur";
#             $RunValues{"CURFileType"} ="cur";
             $RunValues{"DKShift"}     ="T";
             $RunValues{"CURidla"   } =$temp[4];
             $RunValues{"CURnhedf"  } =$temp[5];
             $RunValues{"CURnhedt"  } =$temp[6];
             $RunValues{"CURnhedv"  } =$temp[7];
             $RunValues{"CURformat" } =$temp[8]; #74
             $RunValues{"CURRTRUE"  } ="TRUE";
             $RunValues{"NumofInpGrds"}=$RunValues{"NumofInpGrds"}+1;
             $RunValues{"CURMultInp"  } ="'cur'";
             undef $keyfound, @temp;
           }
           if ($comline =~/^INPGRID WLEV/)  {
             #print " Searching for: INPGRID WLEV\n";;
             $keyfound=$_;
	        chomp $keyfound;
             @temp=split /\s+/,$_;
             $RunValues{"WLEVxpinp"   } =$temp[2];
             $RunValues{"WLEVypinp"   } =$temp[3];
             $RunValues{"WLEValpinp"  } =$temp[4];
             $RunValues{"WLEVnpxinp"  } =$temp[5]+1;
             $RunValues{"WLEVnpyinp"  } =$temp[6]+1;
             $RunValues{"WLEVdxinp"   } =$temp[7];
             $RunValues{"WLEVdyinp"   } =$temp[8];
             $RunValues{"WLEVtbeginp" } =$temp[10];
             $RunValues{"WLEVdeltinp" } =$temp[11];
             $RunValues{"WLEVtunit"   } =$temp[12];
             $RunValues{"WLEVtendinp" } =$temp[13]; #85
             undef $keyfound, @temp;
           }
           if ($comline =~/^BOUN/)  {
             $RunValues{"BCTRUE"  } ="TRUE";
           }
           if ($comline =~/^READINP WLEV/)  {
             #print " Searching for:  READ WLEV\n";;
             $keyfound=$_;
	        chomp $keyfound;
             @temp=split /\s+/,$_;
             $RunValues{"WLEVfac"    } =$temp[2];
             $RunValues{"WLEVname"   } =$temp[3];
             $RunValues{"WLEVidla"   } =$temp[4];
             $RunValues{"WLEVnhedf"  } =$temp[5];
#               $RunValues{"WLEVnhedt"  } =$temp[6];
#               $RunValues{"WLEVnhedv"  } =$temp[7];
             $RunValues{"WLEVformat" } =$temp[6];
             $RunValues{"NumofInpGrds"}=$RunValues{"NumofInpGrds"}+1;
             undef $keyfound, @temp;
           }
           if ($comline =~/^COMPUTE/)  {
             
             #print " Searching for: COMPUTE ($computLines)\n";
             $keyfound=$_;
	        chomp $keyfound;
             @temp=split /\s+/,$_;
             #my $STAT="STAT".$computLines;
             $RunValues{"STAT"    } =$temp[1];
             if ($temp[2] eq "STAT") {
                $StatMode = "STAT";
                $RunValues{"STATtime"    } =$temp[3];
             } elsif ($temp[1] eq "NONSTAT"){
                $computLines+=1;
                $Tbegc="Tbegc".$computLines;
                $deltac="deltac".$computLines;
                $Unitsc="Unitsc".$computLines;
                $Tendc="Tendc".$computLines;
                $RunValues{$Tbegc       } =$temp[2];
                $RunValues{$deltac      } =$temp[3];
                $RunValues{$Unitsc      } =$temp[4];
                $RunValues{$Tendc       } =$temp[5];
                $RunValues{"MaxCFLxy"   } =$temp[3];
                $RunValues{"GlobTStep"  } =$temp[3]*10;
                $RunValues{"MaxCFLkt"   } =$temp[3]*5;
                $RunValues{"MinSTTstep" } =$temp[3];
                undef $keyfound, @temp;
             }
           }
           if ($comline =~/^POINTS/)  {
             $numofOutputPoints+=1;
             #print " Searching for: Output Points ($numofOutputPoints)\n";
             $keyfound=$_;
	        chomp $keyfound;
             @temp=split /\s+/,$_;
             $pointName="pointname".$numofOutputPoints;
             $pointLong="pointlong".$numofOutputPoints;
             $pointLati="pointlati".$numofOutputPoints;
             $RunValues{$pointName } =$temp[1];
             $RunValues{$pointLong } =$temp[2];
             $RunValues{$pointLati } =$temp[3];
             undef $keyfound, @temp;  
           }
           if ($comline =~/^SPECOUT/)  {
             $numofOutputSpectra+=1;
             #print " Searching for: Output Spectra ($numofOutputSpectra)\n";
             $keyfound=$_;
	     chomp $keyfound;
             @temp=split /\s+/,$_;
             $specName    = "SpecName".$numofOutputSpectra;
             $spec12D     = "SpecType".$numofOutputSpectra;
             $specType    = "SpecRelAbs".$numofOutputSpectra;
             $specOutFile = "SpecOutFile".$numofOutputSpectra;
             $RunValues{$specName  } =$temp[1];
             $RunValues{$spec12D    } =$temp[2];
             $RunValues{$specType   } =$temp[3];
             $RunValues{$specOutFile} =$temp[4];
             $timeUnit=$temp[8];
             if ($timeUnit eq "SEC") {
                $tmpfactor= 1;
             }elsif ($timeUnit eq "MIN"){
               $tmpfactor= 60;
             }elsif ($timeUnit eq "HR"){
               $tmpfactor= 3600;
             }elsif ($timeUnit eq "DAY"){
               $tmpfactor= 86400;
             }



             undef $keyfound, @temp;
             
           }

           if ($comline =~/.raw/)  {
             $numofOutputPartition=$numofOutputSpectra;
             $keyfound=$_;
	     chomp $keyfound;
             @temp=split /\s+/,$_;
             $partName    = "PartName".$numofOutputSpectra;
             $RunValues{$partName   } =$temp[1];
             undef $keyfound, @temp;             
           }

 #
        }
    }
    $RunValues{"NumSpcOut"} =$numofOutputSpectra;
    $RunValues{"NumPrtOut"} =$numofOutputPartition;
# Formatting the start and end time strings for WW3 
    @temp=split //,$RunValues{"Tbegc1"};
    $temp[8]=" ";
    $Tbegc1=join ("", @temp,"00");
    undef @temp;
    $TFinal="Tendc".$computLines;
    @temp=split //,$RunValues{$TFinal};
    $temp[8]=" ";
    $Tendend=join ("", @temp,"00");
    undef @temp;

    $RunValues{"numofComputLines"} =$computLines;
    $RunValues{"RunTimeStart"} = $Tbegc1;
    $RunValues{"RunTimeEnd"  } = $Tendend;
    my $timeStepLength = $CG{LENGTHTIMESTEP};
    $RunValues{"NumOfOutTimes"}=floor(SWANFCSTLENGTH/$timeStepLength)+1;
    $RunValues{"DeltaOutput"}=$timeStepLength;
    $RunValues{"DeltaOutputww3"}=$timeStepLength*3600; #Output time step for ww3 must be inseconds

# Formatting the start and end time strings for output for WW3 
# TO DO  these times must be taken from a BLOCK commqand line
    @temp=split //,$RunValues{"specTbegOut"};
    $temp[8]=" ";
    $Tbegspc=join ("", @temp,"00");
    undef @temp, $RunValues{"specTbegOut"};
#    $RunValues{"TbegOut"} =$Tbegspc;
    $RunValues{"TbegOut"} =$Tbegc1;
    $RunValues{"TendOut"} =$RunValues{"RunTimeEnd"  };
    $timeStepLength = $CG{LENGTHTIMESTEP};
#   now program has the botom filename
   my $bot_filename=$RunValues{"BOTname"};
   @char=split //, $bot_filename;
   undef $bot_filename;
   pop @char; shift @char; #scraching the apostrophes in the name
   $bot_filename=join ("", @char);

#   copy the bathymetry file
#    my $bot_ori=${SITEID}.".bot";
#    system ("cp -vpf ${NWPSdir}/bathy_db/$bot_ori ${RUNdir}/$bot_filename");

#Print all values in the hash
   my $paranum=0;
   print "\n Values for the Keywords\n";
   while (($key, $value) = each(%RunValues)){
     $paranum+=1;
     print " $paranum: $key\t\t$value \n";
   }
}
#
################################################################################
# NAME: &getWW3Files
# CALL: &getWW3Files($date,$inpGrid,$filename)
# GOAL: Get the WW3 templates Input and executables files.
# Original Author(s): Roberto Padilla-Hernandez
# File Creation Date: January-2012
# Date Last Modified:
################################################################################

sub getWW3Files($%) {
    use File::Copy "cp";
    use Tie::File;
    local ($swanInputFile,%CG) = @_;
    local @ww3Files;

    ###print "================= In getWW3Files    ========\n";
    ###print "Swan Input File: $swanInputFile \n";
    ###system("pwd");
    ###print "Rundir: ${RUNdir}\n";
    chdir ("${NWPSdir}/fix/templates/ww3_templates/");
#   Copied all input files for WWIII to ${HOME}/data/nwps/run
    @ww3Files = <*>; 
    foreach $file (@ww3Files) {
         print "$file \n"; 
         system("cp -pfv $file ${RUNdir}/$file")==0
         or Logs::err("Couldn't copy $file  to ${RUNdir}/$file : $!",2);
    }
    undef @ww3Files;

#   Copied all WWIII executables to ${HOME}/data/nwps/run
    chdir ("${NWPSdir}/lib64/ww3/");
    @ww3Files = <*>; 
    foreach $file (@ww3Files) {
         print "$file \n"; 
         system("cp -vpf $file ${RUNdir}/$file")==0
         or Logs::err("Couldn't copy $file  to ${RUNdir}/$file : $!",2);
    }

    #system ("cp -vpf ${NWPSdir}/ush/bin/run_ww3_multi.sh ${RUNdir}/run_ww3_multi.sh");
#XXXXXXXXXXXXXXXXXXXXXX
#    system ("cp -vpf ~/WWIII/exe/ww3_multi ${RUNdir}/.");

    chdir("${RUNdir}/");

    &ReadMetadataFile($swanInputFile,%CG);
    print "*************************************\n";
    print "ReadMetadataFile : DONE\n";
    &makeWW3InputFiles;
    print "makeWW3InputFiles : DONE\n";
    &makeWindforWW3;
    print "makeWindforWW3 : DONE\n";

    if ($RunValues{"CURRTRUE"  }  eq "TRUE") {;
       print "CALLING: makeCurrforWW3 \n";
       &makeCurrforWW3;
    }
    
}
##################################################################################
# Subroutine makeWW3InputFiles
# Calling program/subroutine: RunSwan.pm/getWW3InputFiles
# CALL: &ReadMetadataFile;
# GOAL: Updates all WW3 Input Files
# SUBROUTINES CALLS: None
# Original Author(s): Roberto Padilla-Hernandez
# File Creation Date: January-2012
# Date Last Modified:
################################################################################
  sub makeWW3InputFiles  {
    use File::Find;
    my (@spcNum   , @prtNum, @ww3Files, $i, $j,@inputww3);
    my ($pointLong, $pointLati);

    @ww3Files = glob("ww3*.inp*");
    #making the array for the number of output spectra
    foreach $i (1..$numofOutputSpectra) {
      @spcNum=join ("", @spcNum,$i,"\n");
    }
    foreach $i (1..$numofOutputPartition) {
      @prtNum=join ("", @prtNum,$i,"\n");
    }
     #print "numofOutputPartition: $numofOutputPartition\n";
     #print "prtNum: @prtNum\n";

    # Loop through the array printing out the filenames
    foreach my $file (@ww3Files) {
        print "EDITING $file\n";
        tie @inputww3, 'Tie::File', $file or print "array tie issue $file with the corresponding file \n";
        while (($key, $value) = each(%RunValues)){
           foreach my $line (@inputww3) {
#          Replace Key with value
           my $keyn="#".$key."#";
             $line =~ s/$keyn/@spcNum/gi if $keyn eq "#NumSpcOut#";  #This if for ww3_outp_spec.inp
             $line =~ s/$keyn/@prtNum/gi if $keyn eq "#NumPrtOut#";  #This if for ww3_outp_part.inp
             $line =~ s/$keyn/$value/gi;
           }
        }
        untie @inputww3;
        if ($file eq "ww3_multi.inp") {
           open my $in, '<', $file or die "Can't read old file: $!";
           open my $out, '>', "$file.new" or die "Can't write new file: $!";

           while( <$in> ) {
              $line=$_;
              chomp $line;
              if ($line eq "#outputpointshere#") {
                foreach $i (1..$numofOutputSpectra) {
                   $specName="SpecName".$i;
                   foreach $j (1..$numofOutputPoints) {
                      $pointName="pointname".$j;
                      #Relating the  spectra output names to point names and locations
                      if ($RunValues{$specName} eq $RunValues{$pointName}) {
                         $pointLong="pointlong".$j;
                         $pointLati="pointlati".$j;
                         print $out "   $RunValues{$pointLong} $RunValues{$pointLati} $RunValues{$specName}\n";
                         last;
                      }
                   }
                }
              }else{
                print $out $_;
              }
             
           }
 
          close $out; close $in;
          system("mv -f ww3_multi.inp.new ww3_multi.inp");
        }

        if ($file eq "ww3_grid.inp.grd1") {
           #my $fileboundin="$NWPSdir/parm/templates/$SITEID/BounCommandLines.txt";
           #system("sed -i '/\$HERE BOUN SEG/r $fileboundin' $file");
           my $siteid=$SITEID;
           $siteid=~tr/[A-Z]/[a-z]/;
           print "*******************************************************\n";
           print "$SITEID $siteid \n";
           my $boundIn=`cat ${DATA}/parm/templates/$siteid/BounCommandLines.txt`;
           #print "$boundIn \n";
           open my $in, '<', $file or die "Can't read old file: $!";
           open my $out, '>', "$file.new" or die "Can't write new file: $!";
           while( <$in> ) {
              $line=$_;
              chomp $line;

              if ($line eq "\$HERE BOUN SEG") {
                  print $out $boundIn;
              }else{
                 print $out $_;
              }
           }

          close $out; close $in;
          system("mv -f ww3_grid.inp.grd1.new ww3_grid.inp.grd1");

        }


        if ($file eq "ww3_systrk.inp") {
           open my $in, '<', $file or die "Can't read old file: $!";
           open my $out, '>', "$file.new" or die "Can't write new file: $!";

           while( <$in> ) {
              $line=$_;
              chomp $line;
              if ($line eq "#outputpointshere#") {
                foreach $i (1..$numofOutputSpectra) {
                   $specName="SpecName".$i;
                   foreach $j (1..$numofOutputPoints) {
                      $pointName="pointname".$j;
                      #Relating the  spectra output names to point names and locations
                      if ($RunValues{$specName} eq $RunValues{$pointName}) {
                         $pointLong="pointlong".$j;
                         $pointLati="pointlati".$j;
                         print $out "   $RunValues{$pointLong} $RunValues{$pointLati}\n";
                         last;
                      }
                   }
                }
              }else{
                print $out $_;
              }
             
           }
 
          close $out; close $in;
          system("mv -f ww3_systrk.inp.new ww3_systrk.inp");
        }
    }

    system("cp -pfv ${NWPSdir}/bin/run_ww3_multi.sh ${RUNdir}/run_ww3_multi_updated.sh");
    system("chmod +x ${RUNdir}/run_ww3_multi_updated.sh");

# To introduce the current fields and Bound Conditions , if present
    if ($RunValues{"CURRTRUE"  }  eq "TRUE") {;
       print "CURRENTS ARE PRESENT \n";
        system("echo TRUE > ${RUNdir}/Currents.flag");
       local @inputcurr;
       tie   @inputcurr, 'Tie::File', "${RUNdir}/run_ww3_multi_updated.sh" or print "array tie issue with file run_ww3_multi_updated.sh \n";
       my $sust1="cur='no'";
       my $sust2="cur='cur'";
       foreach my $line (@inputcurr) {
         $line =~ s/$sust1/$sust2/gi;
       }
       untie @inputcurr;
    }
## To introduce Bound Conditions , if present
    if ($RunValues{"BCTRUE"  }  eq "TRUE") {;
       print "Boundary Conditions will be imposed  \n";
        system("echo TRUE > ${RUNdir}/BCound.flag");
       local @inputBC;
       tie   @inputBC, 'Tie::File', "${RUNdir}/run_ww3_multi_updated.sh" or print "array tie issue with file run_ww3_multi_updated.sh \n";
       my $sust1="bouncond='no'";
       my $sust2="bouncond='yes'";

       foreach my $line (@inputBC) {
         $line =~ s/$sust1/$sust2/gi;
       }
       untie @inputBC;
    }



#    closedir(DIR);
}
##################################################################################
# Subroutine makeWindforWW3
# Calling program/subroutine: RunSwan.pm/getWW3InputFiles
# CALL: &ReadMetadataFile($swanInputFile,%CG);
# Original Author(s): Roberto Padilla-Hernandez
# File Creation Date: January-2012
# Date Last Modified:
#
# Contributors: 
#
# GOAL: Prepares the wind file for WW3 adding dates and formatting
# SUBROUTINES CALLS:&goForward
################################################################################
  sub makeWindforWW3 {
     my($result);
     $Npx=$RunValues{"WNDnpxinp"  };
     my @temp=split //,$RunValues{"WNDtbeginp"};
     $temp[8]=" ";
     my $wndbeg=join ("", @temp,"00");
     
     local $thisYear  = join ("",$temp[0],$temp[1],$temp[2],$temp[3]);
     local $thisMonth = join ("",$temp[4],$temp[5]);
     local $thisDay   = join ("",$temp[6],$temp[7]);
     local $thisHour  = join ("",$temp[9],$temp[10]);
     undef @temp;

     @temp=split //,$RunValues{"WNDname"};
     pop @temp; shift @temp; #scraching the apostrophes in the name
     my $windFileName=join ("",@temp);
     print " Wind File Name: $windFileName\n";
     my $windNameOut =join ("",$windFileName,".dd");
     undef @temp;

     $numOfData=$RunValues{"WNDnpxnpy"}*2;

     open IN, "<$windFileName"  or die "Cannot open: $!";
     open OUT, ">$windNameOut"  or die "Cannot create: $!";


     my $printyorn=1;
     my $ndata=0;
     my $count=0;
     while (<IN>) {
        $ndata+=1;
        $count++;
        if ($printyorn ==1){
            $deltawnd  =0;
            $printyorn =0;
        }else{
            $deltawnd=$RunValues{"WNDdeltinp" };
        }

        if ($ndata == 1) {
           ($thisHour,$thisDay,$thisMonth,$thisYear)=&goForward($thisHour,
                                   $thisDay,$thisMonth,$thisYear,$deltawnd);
	   $time=$thisYear.$thisMonth.$thisDay." ".$thisHour."00";
           print OUT "$time\n";
           undef $time
	}
        if ($ndata ==$numOfData) {
          $ndata=0;
        }
        $result = sprintf("%5.2f", $_);

	print OUT "$result ";
        print OUT "\n"  if (($count % $Npx) == 0);
     }
     close IN;
     close OUT;
     system ("mv -f $windNameOut  wind.raw");

}
##################################################################################
# Subroutine makeWindforWW3
# Calling program/subroutine: RunSwan.pm/getWW3InputFiles
# CALL: &ReadMetadataFile($swanInputFile,%CG);
# Original Author(s): Roberto Padilla-Hernandez
# File Creation Date: January-2012
# Date Last Modified:
#
# Contributors: 
#
# GOAL: Prepares the wind file for WW3 adding dates and formatting
# SUBROUTINES CALLS:&goForward
################################################################################
  sub makeCurrforWW3 {
     my($result  , $Npx         , $idlacurr, $ndata);
     my(@curarray, $TimesForCurr, $ndataComp       );
     $Npx       = $RunValues{"CURnpxinp"};
     $Npy       = $RunValues{"CURnpyinp"};
     $idlacurr  = $RunValues{"CURidla"  };
     $ndataComp = $RunValues{"CURnpxnpy"};
     $ndVector  = $RunValues{"CURnpxnpy"}*2;
     my @temp=split //,$RunValues{"CURtbeginp"};
     $temp[8]=" ";
     my $wndbeg=join ("", @temp,"00");
     
     local $thisYear  = join ("",$temp[0],$temp[1],$temp[2],$temp[3]);
     local $thisMonth = join ("",$temp[4],$temp[5]);
     local $thisDay   = join ("",$temp[6],$temp[7]);
     local $thisHour  = join ("",$temp[9],$temp[10]);
     undef @temp;

     my @temp=split //,$RunValues{"CURname"};
     pop @temp; shift @temp; #scraching the apostrophes in the name
     my $currFileName=join ("",@temp);

     my $currNameOut =join ("",$currFileName,".dd");
     undef @temp;
     #print " curr File Name IN : $currFileName\n";
     #print " curr File Name OUT: $currNameOut\n";

     open IN, "<$currFileName"  or die "Cannot open: $!";
     open OUT, ">$currNameOut"  or die "Cannot create: $!";


     my $printyorn=1;
     my $ndata=0;
     my $count=0;
     if ($idlacurr ==4 ){
        while (<IN>) {
           $ndata+=1;
           $count++;
           if ($printyorn ==1){
               $deltacur  =0;
               $printyorn =0;
           }else{
               $deltacur=$RunValues{"CURdeltinp" };
           }

           if ($ndata == 1) {
              ($thisHour,$thisDay,$thisMonth,$thisYear)=&goForward($thisHour,
                                   $thisDay,$thisMonth,$thisYear,$deltacur);
	      $time=$thisYear.$thisMonth.$thisDay." ".$thisHour."00";
              print OUT "$time\n";
              undef $time
	   }
           if ($ndata ==$ndVector) {
             $ndata=0;
           }
           $result = sprintf("%5.2f", $_);

	   print OUT "$result ";
           # % the remainder of dividing left value by right value. 
           print OUT "\n"  if (($count == $Npx) == 0);
        }
     }
     if ($idlacurr == 5){
           $count=0;
        while (<IN>) {
           $count++;
           $curarray[$count] = $_;
        }
        $TimesForCurr=$count/($ndVector);
        $countx=0;
        $county=0;
        $count =0;
        for (my $it=0; $it<$TimesForCurr; $it++){
           if ($it ==0){
              $deltacur  =0;
              $printyorn =0;
           }else{
              $deltacur=$RunValues{"CURdeltinp" };
           }
           ($thisHour,$thisDay,$thisMonth,$thisYear)=&goForward($thisHour,
                                 $thisDay,$thisMonth,$thisYear,$deltacur);
	   $time=$thisYear.$thisMonth.$thisDay." ".$thisHour."00";
           print OUT "$time\n";
           for (my $ic=0; $ic<2; $ic++){
              for (my $iy=1; $iy<$Npy+1; $iy++){
                 for (my $ix=0; $ix<$Npx; $ix++){
                    $count=($ix*$Npy)+$iy+($ndataComp*$ic)+($ndVector*$it);
                    $result = sprintf("%6.3f", $curarray[$count]);
                    print OUT "$result ";

                 } #X
                 # % the remainder of dividing left value by right value. 
                 print OUT "\n";#  if (($count % $Npx) == 0);
              } #Y
           } # for component
        }  # For time
     } # For idla=5
     close IN;
     close OUT;
     system ("mv -f $currNameOut  curr.raw");
}
##################################################################################
# Subroutine &formatWW3Fields
# Calling program/subroutine: RunSwan.pm/makeInputCGx
# CALL: &formatWW3Fields;
# Original Author(s): Roberto Padilla-Hernandez
# File Creation Date: January-2012
# Date Last Modified: November-2012
#
# Contributors: 
#
# GOAL: Gives to the WW3 Output Files the proper format for post-processing. 
# SUBROUTINES CALLS: &goForward
#
################################################################################
sub formatWW3Fields {

    my   ($numPoints  ,$YY        ,$i       ,$FileNameOut   , $line         );
    my   ($result     ,$arraySize ,$jw      ,$Deltaoutf     ,@char          );       
    my   (@ww3Param   ,@uvcomp    ,@temp    ,%fileOutPrefix                 );
    local($thisYear   ,$thisMonth ,$thisDay ,$thisHour                      );
#
    $CGNum=$CG{CGNUM};
    $Npx       = $RunValues{"npxc"};
    $Npy       = $RunValues{"npyc"};
    $numPoints = $RunValues{"CGnpxnpy" };
    #print " Npx,Npy,npx*npy=$Npx, $Npy, $numPoints\n"; 
    #                         Hs, wnd,   Tps, dir, pdir, vel, watl, Hswe, wlen, depth
    @ww3Param             = ("hs","wnd","fp","dir", "dp", "cur","wlv","phs","l","dpt");
    #SWAN output prefix..
    $fileOutPrefix{"hs"}  = "HSIG";
    $fileOutPrefix{"wnd"} = "WIND";
    $fileOutPrefix{"fp"}  = "TPS";
    $fileOutPrefix{"dir"} = "DIR";
    $fileOutPrefix{"dp"}  = "PDIR";
    $fileOutPrefix{"cur"} = "VEL";
    $fileOutPrefix{"wlv"} = "WATL";
    $fileOutPrefix{"phs"} = "HSWE";
    $fileOutPrefix{"l"}  =  "WLEN";
    $fileOutPrefix{"dpt"} = "DEPTH";

    foreach $exten (@ww3Param) {
      $FileNameOut=$fileOutPrefix{$exten}."."."CG".$CGNum."."."CGRID";
      open OUT, ">$FileNameOut"  or die "Cannot create: $!";
      @temp=split //,$RunValues{"TbegOut"};
      $thisYear  = join ("",$temp[0],$temp[1],$temp[2],$temp[3]);
      $thisMonth = join ("",$temp[4],$temp[5]);
      $thisDay   = join ("",$temp[6],$temp[7]);
      $thisHour  = join ("",$temp[9],$temp[10]);
      undef @temp;
      foreach $i (1..$RunValues{"NumOfOutTimes"}) {
        if ($i ==1){
           $Deltaoutf  =0;
        }else{
           $Deltaoutf=$RunValues{"DeltaOutput"};
        }
        ($thisHour,$thisDay,$thisMonth,$thisYear)=&goForward($thisHour,
                              $thisDay,$thisMonth,$thisYear,$Deltaoutf);
        @char=split //,$thisYear;
        $YY=join ("",$char[2],$char[3]);
        $time=$YY.$thisMonth.$thisDay.$thisHour;
        $FileIn="ww3.".$time.".".$exten; 
#        print "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz\n";
#        print "$thisHour, $thisDay, $thisMonth, $thisYear,$Deltaoutf\n";
#        print "time: $time\n";
#        print "$FileIn \n";
#        print "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz\n";
        open IN, "<$FileIn"  or die "Cannot open: $!";
        $dataNumber=0;
        while ( $line = <IN> ) {
          chomp ($line);
          $dataNumber++;
          if ($dataNumber ==1){;
            @head=split /\s+/,$line;
            $factor= $head[12]; 
            next;
          }
          @values=split /\s+/,$line;
          shift @values;
          $arraySize = scalar (@values);
          if (($exten ne "wnd") && ($exten ne "cur")){  # Scalars
            foreach $ii (reverse(0..$Npy-1)){
              $i1=$ii*$Npx;
              foreach $j (0..$Npx-1) {
                $j1=$i1+$j;

                if (($exten eq "fp") && ($values[$j1] != 0.)){
                  $values[$j1] = 1./$values[$j1];
                }
                $values[$j1]=$values[$j1]*$factor;
                if ($values[$j1] < 0){ 
                  $values[$j1] =   -9 if (($exten eq "hs")or($exten eq "fp")or($exten eq "phs")or($exten eq "l"));
                  $values[$j1] =  -99 if (($exten eq "dpt"));
                  $values[$j1] = -999 if (($exten eq "dp")or($exten eq "dir"));
                }
                if ($values[$j1] >= 0){ 
                  $result = sprintf("  %.4E",$values[$j1]);
                }else{
                  $result = sprintf(" %.4E",$values[$j1]);
                }
                print OUT "$result";
                $jw=$j+1; 
                if (($jw % 6) == 0 || $jw == $Npx) {
                  print OUT "\n";
                }
              }
            }
          }else{                                         #Vectors
            @uvcomp=@values[0..$numPoints-1];
            $arraySizeu = scalar(@uvcomp);
            foreach $ii (reverse(0.. $Npy-1)){            
              $i1=$ii*$Npx;
              foreach $j (0..$Npx-1) {
                $j1=$i1+$j;
                if ($uvcomp[$j1] == -999){ 
                  $uvcomp[$j1] =    0.0;
                }
                if ($values[$j1] > 0){ 
                  $result = sprintf("  %.4E",$uvcomp[$j1]*$factor);
                }else{
                  $result = sprintf(" %.4E",$uvcomp[$j1]*$factor);
                }
                print OUT "$result"; 
                $jw=$j+1; 
                if (($jw % 6) == 0 || $jw == $Npx) {
                  print OUT "\n";
                }
              }
            }
          }
        }
      }
    }
    close IN;
    close OUT;
}
##################################################################################
# Subroutine &formatWW3Spec
# Calling program/subroutine: RunSwan.pm/makeInputCGx
# CALL: &formatWW3Fields;
# GOAL: Gives to the WW3 Output Files the proper format for post-processing. 
# SUBROUTINES CALLS: &goForward
#
# Original Author(s): Roberto Padilla-Hernandez
# File Creation Date: February-2012
# Date Last Modified: 
#
# Contributors: 
#
################################################################################
sub formatWW3Spec {
        my (@spcValue,@freqValue,$FileIn, $numOfFreq,$NumOfSpec,$Speci,@temp);
        my (@date1,@date2,@dateout,$line,$locName,$i,$loclon,$loclat);
        my ($spcFileName,$CGx, $project,$runId, $temp2,$textCoord);
        my ($numofOutTimes,@filehandles,$Fileout,$itime,@dirValue,@sprdValue);
        local *OUT;
        $FileIn="tab33.ww3";
        $numOfFreq=$RunValues{"npsc"};
        $NumOfSpec=$RunValues{"NumSpcOut"};
        $CGx=$RunValues{"CGX"};
        $project=$RunValues{"PROJ"};
        $runId=$RunValues{"RunID"};
        if ($RunValues{"COORD"} eq "SPHE") {
          $textCoord="LONLAT                                  locations in spherical coordinates";
        }else{
          $textCoord="LONLAT                                  locations in x-y-space";
        }
        $numofOutTimes=$RunValues{"NumOfOutTimes"};
#       Open Data File to Read
        print "\n sub formatWW3Spec, Input File: $FileIn\n";
        open IN, "<$FileIn"  or die "Cannot open: $!";
        print "File  $FileIn Opened \n";
#       Loop for the number of output times
      for $itime (1..$numofOutTimes){
#       Loop for the number of spectra in the file
        for $Speci (0.. $NumOfSpec-1){
          $line = <IN>;
          chomp ($line);
#         Time string
          @temp=split /\s+/,$line;
          @date1=split /\//, $temp[3];
          @date2=split /:/, $temp[4];
          @dateout=join("",@date1,".",@date2);
          $line = <IN>;chomp ($line);
          @temp=split /\s+/,$line;
#         Name and coord of output location
          $locName=$temp[3];$loclon=$temp[5];$loclat=$temp[6]; 
          $spcFileName="SPC1D.".$locName.".CG".$CGx;
          if ($itime == 1){
            open(OUT, ">$spcFileName") || die "cannot create: $!";
            push(@filehandles, *OUT);
        print "File $spcFileName Opened \n";
          }else{
            open(OUT, ">>$spcFileName") || die "cannot create: $!";
          }
          $Fileout=$filehandles[$Speci];
#         skipping depth, U*, U10, U10 direction and some header lines
          for $i (1..8){
            $line = <IN>;
          }
          for $i (1..$numOfFreq){
            $line = <IN>;chomp ($line); 
            @temp=split /\s+/,$line;
            shift(@temp);
            $freqValue[$i]= sprintf("%10.4f",$temp[0]);
            $spcValue[$i] = $temp[2];
            $dirValue[$i] = $temp[3];
            if($dirValue[$i] == -999.9) {
              $dirValue[$i]= -999.0;
            }
            $dirValue[$i]= sprintf("%6.1f",$dirValue[$i]);
            $sprdValue[$i] = $temp[4];
            if($sprdValue[$i] == -999.9) {
              $sprdValue[$i]= -9.0;
            }
            $sprdValue[$i]= sprintf("%6.1f",$sprdValue[$i]);
            undef  @temp;
            if ($dirValue[$i] == -999.0 && $sprdValue[$i] == -9.0) {
              $spcValue[$i]=-0.9900E+02;
            }
#           Giving the proper spaces at the beggining
            $spcValue[$i]= sprintf(" %.4E",$spcValue[$i]);
            if ($spcValue [$i]> 0.0){
             $spcValue [$i] =" ".$spcValue[$i];
            }
          }
          for $i (1..2){
            $line = <IN>;
          }
#         writing the freq array
          if ($itime == 1){
	    print $Fileout "SWAN   1                                WW3 spectral file (SWAN-Format), version\n";
            print $Fileout "\$   Data produced by WW3 version 4.xxx               \n";
            $temp2="\$   "."Project: ".$project.";  run number:  ".$runId;
            print $Fileout "$temp2\n";   
            print $Fileout "TIME                                    time-dependent data\n";
            print $Fileout "     1                                  time coding option\n";
            print $Fileout "$textCoord\n"; 
            print $Fileout "     1                                  number of locations\n";
            print $Fileout "  $loclon   $loclat\n";
            print $Fileout "AFREQ                                   absolute frequencies in Hz\n";
            print $Fileout "    $numOfFreq                                  number of frequencies\n";
            for $i (1..$numOfFreq){
              print $Fileout "$freqValue[$i]\n";
            }
            print $Fileout "QUANT\n";
            print $Fileout "     3 \t\t\t\t\tnumber of quantities in table\n";
            print $Fileout "VaDens \t\t\t\t\tvariance densities in m2/Hz\n";
            print $Fileout "m2/Hz \t\t\t\t\tunit\n";
            print $Fileout "   -0.9900E+02 \t\t\t\texception value\n";
            print $Fileout "NDIR \t\t\t\t\taverage nautical direction in degr\n";
            print $Fileout "degr \t\t\t\t\tunit\n";
            print $Fileout "   -0.9990E+03 \t\t\t\texception value\n";
            print $Fileout "DSPRDEGR \t\t\t\tdirectional spreading   \n";                
            print $Fileout "degr \t\t\t\t\tunit\n";
            print $Fileout "   -0.9000E+01 \t\t\t\texception value\n";
          }
          print $Fileout "@dateout \t\t\tdate and time\n";
          print $Fileout "LOCATION     1\n";
#         writing the Spectrum1D array
          for $i (1..$numOfFreq){
            print $Fileout "$spcValue[$i]  $dirValue[$i]  $sprdValue[$i]\n";
          }
        }
        close OUT;
      }
        close IN;
}
##################################################################################
# Subroutine &formatWW3PntWnd
# Calling program/subroutine: RunSwan.pm/makeInputCGx
# CALL: &formatWW3WW3PntWnd;
# GOAL: Gives to the WW3 point Output Files for wind the proper format for
#       post-processing. 
# SUBROUTINES CALLS: &goForward
#
# Original Author(s): Roberto Padilla-Hernandez
# File Creation Date: February-2012
# Date Last Modified: 
#
# Contributors: 
#
################################################################################
sub formatWW3PntWnd {
    my ($FileIn, $i     , $depth, $spdcur , $dircur  , $spdwnd, $dirwnd   );
    my ($spdwnd, $dirwnd, $line , $locName, $loclon  , $CGx   , $textCoord);
    my (@temp  , @date1 , @date2, @dateout, $loclat  , $wndFileName       );
    my ($numofOutTimes  , @filehandles    , $Fileout , $itime , $NumOfSpec);
    my ($pointLong      , $pointLati      , $j       , @char              );
    local *OUT;
    $FileIn="tab44.ww3";
    $NumOfSpec=$RunValues{"NumSpcOut"};
    $CGx=$RunValues{"CGX"};
    $numofOutTimes=$RunValues{"NumOfOutTimes"};
#   Open Data File to Read
    open IN, "<$FileIn"  or die "Cannot open: $!";
#   Loop for the number of output times
    for $itime (1..$numofOutTimes){
#     Time string
      $line = <IN>;
      @temp=split /\s+/,$line;
      @date1=split /\//, $temp[3];
      @date2=split /:/, $temp[4];
      @dateout=join("",@date1,".",@date2);
      for $i (1..4){
        $line = <IN>;
      }
#     Loop for the number of spectra in the file
      for $i (0.. $NumOfSpec-1){
        $line = <IN>;
        @temp=split /\s+/,$line;
#       Name and coord of output location
        $loclon=$temp[1];$loclat=$temp[2];
        $depth=$temp[3];
        $spdcur=$temp[4];$dircur=deg2rad($temp[5]);
        $spdwnd=$temp[6];$dirwnd=deg2rad($temp[7]);
        $ucomp=$spdwnd*cos(deg2rad(270)-$dirwnd);
        $vcomp=$spdwnd*sin(deg2rad(270)-$dirwnd);
        $ucomp=0.0 if (abs($ucomp) < 0.0001);
        $vcomp=0.0 if (abs($vcomp) < 0.0001); 
        #print "$loclon, $loclat  $depth  $spdcur $dircur $spdwnd $dirwnd == $ucomp, $vcomp\n"; 
        #Relating the  spectra output names to point names and locations
        foreach $j (1..$NumOfSpec) {
          $specName ="SpecName".$j;
          $pointLong="pointlong".$j;
          $pointLati="pointlati".$j;
          if ($RunValues{$pointLong} == $loclon && $RunValues{$pointLati} == $loclat) {
            @char=split //, $RunValues{$specName};
            pop @char; shift @char; 
            $locName=join ("", @char);
             #print "$RunValues{$specName} $RunValues{$pointLong} $RunValues{$pointLati} $locName\n";
             $wndFileName="WND.".$locName.".CG".$CGx;
             #print "$LocName   $wndFileName\n";
             last;
          }
        }
        #$curFileName="CUR.".$locName.".CG".$CGx;
        if ($itime == 1){
          open(OUT, ">$wndFileName") || die "cannot create: $!";
          push(@filehandles, *OUT);
        }else{
          open(OUT, ">>$wndFileName") || die "cannot create: $!";
        }
        $Fileout=$filehandles[$i];
#       Giving the proper spaces at the beggining
        $ucomp= sprintf(" %.4E",$ucomp);
        $vcomp= sprintf(" %.4E",$vcomp);
#       writing the Spectrum1D array
        print $Fileout "$ucomp $vcomp\n";
        close OUT;
      }
      for $j (1..2){
        $line = <IN>;
      }
    }
        close IN;
}
##################################################################################
# Subroutine &formatTracking
# Calling program/subroutine: RunSwan.pm/makeInputCGx
# CALL: &formatTracking;
# GOAL: Gives to the Wave Tracking Output Files the proper format for post-processing. 
# SUBROUTINES CALLS: &goForward
# 
# Original Author(s): Roberto Padilla-Hernandez
# File Creation Date: March-2012
# Date Last Modified: 
#
# Contributors: 
################################################################################
sub formatTracking02 {
use IO::File;
        my ($Pointi,@Header,$wu,$wv);
        my ($FileIn,$NumOfSpec,@temp,$prtFileName,$wndFileName);
        my ($line,$locName,$i,$j,$loclon,$loclat,$pointlo,$pointla);
        my ($CGx,$pointName,$pointLong,$pointLati);
        my ($numofOutTimes,@filehandles,$Fileout,$itime);
        my (@filesInHandles, $FileWindIn,$fh, $wuv);
        my ($resultu,  $resultv);
        my (@arrayOut, $value, $datain, $witness);
        local *OUT;
        $FileIn="SYS_PNT.OUT";
        $NumOfSpec=$RunValues{"NumSpcOut"};
        $CGx=$RunValues{"CGX"};
        $numofOutTimes=$RunValues{"NumOfOutTimes"};
#       Open Data File to Read
        print "File IN: $FileIn   numofOutTimes: $numofOutTimes\n";
        open IN, "<$FileIn"  or die "Cannot open: $!";
#       Reading header lines
        for $i (0..6){
          $line = <IN>;
          chomp ($line);
          $Header[$i]=$line;
          $Header[$i]=$Header[$i]."      X-Windv       Y-Windv    " if ($i == 4);
          $Header[$i]=$Header[$i]."        [m/s]         [m/s]    "  if ($i == 5);
        }
#       Loop for the number of output times
        my $contime=0;
        for $itime (1..$numofOutTimes){
          $line = <IN>;
          chomp ($line);
          my $timeread = $line;
#         Loop for the number of output location 
          for $Pointi (0..$NumOfSpec-1){
            #print "Point Number: $Pointi\n";
            $line = <IN>;
            chomp ($line);
            @temp=split /\s+/,$line;
            $loclon=sprintf("%13.3f",$temp[1]);
            $loclat=sprintf(" %13.4f",$temp[2]);
            undef @arrayOut;
            push(@arrayOut,$loclon);
            push(@arrayOut,$loclat);
#           Loop for the 10 partitions (Hs, Tp, Dir) 
           foreach $prtn (3..32) {    
                  $witness=0;
              if ($prtn > 22 && $prtn < 33){
                  $witness=1;
                 $datain=sprintf(" %13.3f",$temp[$prtn]);
              }
              elsif ($prtn > 12 && $prtn < 23){
                  $witness=2;
                 $datain=sprintf(" %13.4f",$temp[$prtn]);
              }
              elsif ($prtn > 2 && $prtn < 13){
                  $witness=3;
                 $datain=sprintf(" %13.5f",$temp[$prtn]);
              }
              push(@arrayOut,$datain);
              undef $datain;
           }
            #Relating the  spectra output names to point names and locations
            foreach $j (1..$NumOfSpec) {
              $pointlo="pointlong".$j;
              $pointla="pointlati".$j;
              $specName ="SpecName".$j;
              if ($loclon == $RunValues{$pointlo} && $loclat == $RunValues{$pointla}) {
                @char=split //, $RunValues{$specName};
                pop @char; shift @char; 
                $locName=join ("", @char);
                $prtFileName="PRT.".$locName.".CG".$CGx.".TAB";
                $wndFileName="WND.".$locName.".CG".$CGx;
                last;
              } 
            }     
            if ($itime == 1){
              open(OUT, ">$prtFileName") || die "cannot create: $!";
              push(@filehandles, *OUT);
              $Fileout=$filehandles[$Pointi];
              for $i (0..6){                     #The file has 6 lines header
               print $Fileout "$Header[$i]\n";
              } 
              $fh = new IO::File($wndFileName, "r");
              push(@filesInHandles, $fh);
            }else{
              open(OUT, ">>$prtFileName") || die "cannot create: $!";
            }
            $Fileout=$filehandles[$Pointi];
            $FileWindIn=$filesInHandles[$Pointi];
             $wuv = <$FileWindIn>;
             chomp $wuv;
             @temp=split /\s+/,$wuv;
             $wu = sprintf(" %13.4f", $temp[1]);
             $wv = sprintf(" %13.4f", $temp[2]);
            push(@arrayOut,$wu);
            push(@arrayOut,$wv);
           foreach $value (@arrayOut) {    # data for every line
             print $Fileout "$value";
           }
           print $Fileout " \n";
            close OUT;
          }
        }
        close IN;
}
#################################################################################
1;


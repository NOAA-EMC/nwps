#!/usr/bin/perl
# ----------------------------------------------------------- 
# PERL Script
# PERL Version(s): 5
# Original Author(s): Eve-Marie Devalire for WFO-Eureka 
# File Creation Date: 04/20/2004
# Date Last Modified: 11/18/2014
#
# Version control: 2.33
#
# Support Team:
#
# Contributors: Alex Gibbs, Tony Freeman, Pablo Santos, Douglas Gaer
# ----------------------------------------------------------- 
# ------------- Program Description and Details ------------- 
# ----------------------------------------------------------- 
#
# This program is the one making all the other communicate. It receives one
# from each one of the non common packages and deal with global varaibles.
# Thus, it processes the input, makes the SWAN model run for each domain,
# process the output and ship the files to AWIPS.
#
# The packages used are the following:
#
# WaveInput
# WindInput
# GraphicOutput
# TextOutput
# SwanRun
# ----------------------------------------------------------- 

######################################################
#      Packages and exportation requirements         #
######################################################

use lib ("$ENV{'PMnwps'}");
use lib ("$ENV{'USHnwps'}");
use WaveInput qw(waveInputProcessing);
use WindInput qw(windInputProcessing);
use GraphicOutput qw(graphicOutputProcessing);
use RunSwan qw(makeSwanRun);
use CommonSub qw(removeFiles removeOldFiles mvFiles renameFilesWithSuffix giveDate);
use ArraySub qw(inArray);
use ConfigSwan;
use Cleanup;
use Logs;
use WaveHazards qw(runWaveHazards);
use Archive qw(isRunFromArchive extractArchive archiveFiles completeArchiveAndCleanup);
use TextOutput qw(textOutputProcessing);

######################################################
#               Variables declaration                #
######################################################
our $dateSuffix;
our ($cg,$date,$inpGrid,$filename,$spectraFrom);
our (@date,$h,$min);
our $path=PATH;

######################################################
#               Environment Variables                #
######################################################
# Setup our NWPS env
my $NWPSdir = $ENV{'HOMEnwps'};
my $USHnwps= $ENV{'nwps'};
my $ISPRODUCTION = $ENV{'ISPRODUCTION'};
my $DEBUGGING = $ENV{'DEBUGGING'};
my $DEBUG_LEVEL = $ENV{'DEBUG_LEVEL'};

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

# Setup our model run environment
my $RUNLEN = $ENV{'RUNLEN'};
my $WNA = $ENV{'WNA'};
my $NESTS = $ENV{'NESTS'};
my $RTOFS = $ENV{'RTOFS'};
my $WATERLEVELS = $ENV{'WATERLEVELS'};
my $ESTOFS = $ENV{'ESTOFS'};
my $PSURGE = $ENV{'PSURGE'};
my $EXCD = $ENV{'EXCD'};
my $WINDS = $ENV{'WINDS'};
my $WEB = $ENV{'WEB'};
my $PLOT = $ENV{'PLOT'};
my $SITEID = $ENV{'SITEID'};
my $siteid = $ENV{'siteid'};
my $MODELCORE = $ENV{'MODELCORE'};
my $USERNAME = $ENV{'USERNAME'};
my $NWPSplatform = $ENV{'NWPSplatform'};

system("echo $$ > ${TMPdir}/${USERNAME}/nwps/8991_swan_pl.pid");

######################################################
#                Subroutines calls                   #
######################################################

Logs::initialize(); 
Logs::run("BEGIN RUN");

if ($WATERLEVELS eq "ESTOFS") {
    $ESTOFS = "YES";
}

if ($WATERLEVELS eq "PSURGE") {
    $PSURGE = "YES";
}

if ($DEBUGGING eq "TRUE") {
    Logs::run("NWPSdir: $NWPSdir");
    Logs::run("DEBUGGING: $DEBUGGING");
    Logs::run("DEBUG_LEVEL: $DEBUG_LEVEL");
    Logs::run("ISPRODUCTION: $ISPRODUCTION");
    Logs::run("RUNLEN: $RUNLEN");
    Logs::run("WNA: $WNA");
    Logs::run("NESTS: $NESTS");
    Logs::run("RTOFS: $RTOFS");
    Logs::run("WATERLEVELS: $WATERLEVELS");
    Logs::run("ESTOFS: $ESTOFS");
    Logs::run("PSURGE: $PSURGE");
    Logs::run("EXCD: $EXCD");
    Logs::run("WINDS: $WINDS");
    Logs::run("WEB: $WEB");
}

Logs::run("Cleanup directory structure and kill any running swan processes.");
&cleanUp();

if(&isRunFromArchive()) {
    Logs::run("RUN FROM ARCHIVE: this run will use archived wind and wave data from the file: ".RUNFROMARCHIVE);
    &extractArchive();
}

if ($WNA eq "WNAWave" || $WNA eq "HURWave") {
    Logs::run("Download and pre-process wave data.");
    &waveInputProcessing();
}

Logs::run("Pre-process wind data.");
($date,$inpGrid,$filename)=&windInputProcessing();

Logs::run("Wind Data Processed. Model Initial Time is $date.");

if ($RTOFS eq "YES") {
  if (-e "${USHnwps}/rtofs/bin/gen_current.sh" ) {
    system("${USHnwps}/rtofs/bin/gen_current.sh ${date} $ARGV[0]");
  }
  else {
    Logs::run("You do not have the current processing scripts installed.");
    Logs::run("Proceeding without current interactions.");
  }
}

if ($ESTOFS eq "YES") {
  if (-e "${USHnwps}/estofs/bin/gen_waterlevel.sh" ) {
    system("${USHnwps}/estofs/bin/gen_waterlevel.sh ${date}");
  }
  else {
    Logs::run("You do not have the ESTOFS water level processing scripts installed.");
    Logs::run("Proceeding without water level interactions.");
  }
}

if ($PSURGE eq "YES") {
  if (-e "${USHnwps}/psurge/bin/gen_waterlevel.sh" ) {
    system("${USHnwps}/psurge/bin/gen_waterlevel.sh ${date} ${EXCD}");
  }
  else {
    Logs::run("You do not have the PSURGE water level processing scripts installed.");
    Logs::run("Proceeding without water level interactions.");
  }
}

#Get the CGS hash
my %CGSS = %ConfigSwan::CGS;
#Get the number of hashes (Number of computational grids) in the hash CGS
my $numcgrids += scalar keys %CGSS; 
print "Number of Computational grids:  " . keys( %CGSS). "\n";

#foreach my $CG (sort(values(%ConfigSwan::CGS))) {
#foreach my $CG ( reverse sort values  %ConfigSwan::CGS) {
#Give the names of the hashes that contains the CG information
my @columns = qw(CG1 CG2 CG3 CG4 CG5);
#Loop over the actual umber of Comp. Grids, in spite of nymber of elemnts in @columns 
for $i (0..$numcgrids-1){
  # Get a slice of the Config hash
  my $CG = @CGSS{$columns[$i]}; # 6,1,3
    %CG = %{$CG};
    $dateSuffix = &makeSwanRun($date,$inpGrid,$filename,%CG);
    if (defined($CG{GRAPHICOUTPUTDIRECTORY})) {
	Logs::run("Graphic post-processing for CG".$CG{CGNUM});
	&graphicOutputProcessing(%CG);
    }
}

Logs::run("Archive input and output data files.");
&completeArchiveAndCleanup($dateSuffix);

system("touch ${OUTPUTdir}/netCdf/completed");

Logs::run("END RUN");
# ----------------------------------------------------------- 
# ******************************* 
# ********* End of File ********* 
# ******************************* 

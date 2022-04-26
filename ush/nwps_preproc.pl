#!/usr/bin/env perl
# ----------------------------------------------------------- 
# PERL Script
# PERL Version(s): 5
# Original Author(s): Eve-Marie Devalire for WFO-Eureka 
#                     Roberto Padilla-Hernandez NOAA/EMC/MMAB - IMSG
# File Creation Date:  
# Date Last Modified: 04/06/2015
#
# Version control: 2.31
#
# Support Team:
#
# Contributors: Alex Gibbs, Tony Freeman, Pablo Santos, Douglas Gaer
#               
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
use lib ("$ENV{'USHnwps'}");
use lib ("$ENV{'PMnwps'}");
use lib ("$ENV{'RUNdir'}");
use WaveInput qw(waveInputProcessing);
use WindInput qw(windInputProcessing);
#AW111416 use GraphicOutput qw(graphicOutputProcessing);
#AW111416 use RunSwan qw(makeSwanRun);
use SetupCG qw(makeSwanRun);
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
my $USHnwps = $ENV{'USHnwps'};
my $ISPRODUCTION = $ENV{'ISPRODUCTION'};
my $DEBUGGING = $ENV{'DEBUGGING'};
my $DEBUG_LEVEL = $ENV{'DEBUG_LEVEL'};
my $RETROSPECTIVE = $ENV{'RETROSPECTIVE'};

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
my $WINDS = $ENV{'WINDS'};
my $WEB = $ENV{'WEB'};
my $PLOT = $ENV{'PLOT'};
my $SITEID = $ENV{'SITEID'};
my $MODELCORE = $ENV{'MODELCORE'};
my $NWPSplatform = $ENV{'NWPSplatform'};

######################################################
#                Subroutines calls                   #
######################################################
#for_WCOSS
#codeswanpl03
#
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
#Break here for WCOSS_main_01
Logs::run("Cleanup directory structure and kill any running swan processes.");
&cleanUp();

#if(&isRunFromArchive()) {
#    Logs::run("RUN FROM ARCHIVE: this run will use archived wind and wave data from the file: ".RUNFROMARCHIVE);
#    &extractArchive();
#}
if ($RETROSPECTIVE eq "TRUE") {
    #system("${USHnwps}/extract_archive.sh");
    #Tarball already exists in archive, just untar it
    system("${USHnwps}/extract_archive_waves.sh");
}

if ($RETROSPECTIVE eq "FALSE") {
if ($WNA eq "WNAWave" || $WNA eq "HURWave") {
    print "======   Download and pre-process wave data =====\n";
    Logs::run("Download and pre-process wave data.");
    &waveInputProcessing();
}
}

Logs::run("Pre-process wind data.");
($date,$inpGrid,$filename)=&windInputProcessing();

if((${NWPSplatform} eq 'WCOSS') || (${NWPSplatform} eq 'DEVWCOSS')) {
    my $infoFile = "${RUNdir}/info_to_makeSwanRun.txt";
    open(my $fh, '>', $infoFile) or die "Could not open file '$infoFile' $!";
    print $fh "$date\n";
    print $fh "$inpGrid\n";
    print $fh "$filename";
    close $fh;
}
#
Logs::run("Wind Data Processed. Model Initial Time is $date.");

if(-e "${RUNdir}/nortofs") {
  $RTOFS="NOT"
}

if(-e "${RUNdir}/noestofs") {
  $ESTOFS="NOT"
}
if(-e "${RUNdir}/nopsurge") {
  $PSURGE="NOT"
}
print " ============ In nwps_preproc.pl ==============\n";
print "RTOFS: $RTOFS,  ESTOFS: $ESTOFS,  PSURGE: $PSURGE   date:${date}\n";

#if ($RETROSPECTIVE eq "FALSE") {
if ($RTOFS eq "YES") {
  if (-e "${USHnwps}/rtofs/bin/gen_current.sh" ) {
    system("${USHnwps}/rtofs/bin/gen_current.sh ${date} $ARGV[0]");
  }
  else {
    Logs::run("You do not have the current processing scripts installed.");
    Logs::run("Proceeding without current interactions.");
  }
}

if ($WATERLEVELS eq "ESTOFS" && $ESTOFS eq "YES") {
  if (-e "${USHnwps}/estofs/bin/gen_waterlevel.sh" ) {
    system("${USHnwps}/estofs/bin/gen_waterlevel.sh ${date}");
  }
  else {
    Logs::run("You do not have the water level processing scripts installed.");
    Logs::run("Proceeding without water level interactions.");
  }
}
elsif ($WATERLEVELS eq "PSURGE" && $PSURGE eq "YES") {
  if (-e "${USHnwps}/psurge/bin/gen_waterlevel.sh" ) {
     open (FILE, '${RUNdir}/PEXCD');
     chomp ($EXCD = (<FILE>));
     close(FILE);
     print " EXCEEDANCE IN NWPS_PREPROC.PL: ${EXCD}";
     system("${USHnwps}/psurge/bin/gen_waterlevel.sh ${date}");
     # If Psurge is used, then it is necessary to add ESTOFS fields
     # for the end of the run as Psurge has only 78 hrs.. We need 102
     #if ($ESTOFS eq "YES") {
        system("${USHnwps}/estofs/bin/gen_waterlevel.sh ${date}");
     #}
  }
  else {
    Logs::run("You do not have the water level processing scripts installed.");
    Logs::run("Proceeding without water level interactions.");
  }
}
#}

#AW11416: Added call to makeSwanRun from RunSwan.pm here, to unify preprocessing

if((${NWPSplatform} eq 'WCOSS') || (${NWPSplatform} eq 'DEVWCOSS')) {
    my $infoFile01 = "${RUNdir}/info_to_makeSwanRun.txt";
    open IN, "<$infoFile01"  or die "Cannot open: $!";
    my $ndata=0;
    while (<IN>) {
	$ndata+=1;
	$count++;
	print "ndata= $ndata\n";
	if ($ndata ==1) {
	    $date=$_;
	    print "$data\n";
	}
	if ($ndata ==2) {
	    $inpGrid=$_;
	    print "$inpGrid\n";
	}
	if ($ndata ==3) {
	    $filename=$_;
	    print "$filename\n";
	}
    }
    close IN;
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
for $i (0..0){
  # Get a slice of the Config hash
  my $CG = @CGSS{$columns[$i]}; # 6,1,3
    %CG = %{$CG};
    $dateSuffix = &makeSwanRun($date,$inpGrid,$filename,%CG);
}
# ----------------------------------------------------------- 
# ******************************* 
# ********* End of File ********* 
# ******************************* 

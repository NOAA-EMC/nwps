#!/usr/bin/perl
# ----------------------------------------------------------- 
# PERL Script
# PERL Version(s): 5
# Original Author(s): Eve-Marie Devalire for WFO-Eureka 
# File Creation Date: 04/20/2004
# Date Last Modified: 11/15/2014
#
# Version control: 2.31
#
# Support Team:
#
# Contributors: Alex Gibbs, Tony Freeman, Pablo Santos, Douglas Gaer
#               Roberto Padilla-Hernandez
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
use lib ("$ENV{'RUNdir'}");
use lib ("$ENV{'DATA'}");
#AW111416 use WaveInput qw(waveInputProcessing);
#AW111416 use WindInput qw(windInputProcessing);
#AW111416 use GraphicOutput qw(graphicOutputProcessing);
#AW111416 use RunSwan qw(makeSwanRun);
use SetupCG qw(makeSwanRun);
use RunSwan qw(runModel);
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
print " ++++++++++++++++++ nwps_coremodel_CGn.pl++++++++++++++++++++++\n";
print " Rundir: ${RUNdir} \n";
print " NWPSplatform: ${NWPSplatform} \n";
print " ++++++++++++++++++ nwps_coremodel_CGn.pl++++++++++++++++++++++\n";

if((${NWPSplatform} eq 'WCOSS') || (${NWPSplatform} eq 'DEVWCOSS')) {
    my $infoFile02 = "${RUNdir}/info_to_nwps_coremodel.txt";
    open IN, "<$infoFile02"  or die "Cannot open: $!";
    our ($NWPSdir, $DEBUGGING, $DEBUG_LEVEL, $BATHYdb, $SHAPEFILEdb, $ARCHdir);
    our ($DATAdir, $LOGdir, $VARdir, $OUTPUTdir, $RUNdir, $TMPdir, $RUNLEN);
    our ($NESTS, $RTOFS, $WATERLEVELS, $WEB, $PLOT, $MODELCORE, $LOGdir, $SITEID);
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
	    $WATERLEVELS=$_;
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

print "$NWPSdir, $ISPRODUCTIO, $DEBUGGING, $DEBUG_LEVEL, $BATHYdb, $SHAPEFILEdb, $ARCHdir\n";
print "$DATAdir, $INPUTdir, $LOGdir, $VARdir, $OUTPUTdir, $RUNdir, $TMPdir, $RUNLEN, $WNA\n";
print "$NESTS, $RTOFS, $ESTOFS, $WINDS, $WEB, $PLOT, $SITEID, $MODELCORE,\n";
print "$GEN_NETCDF, $USERDELTAC \n";

}

Logs::initialize(); 
Logs::run("BEGIN RUN");

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
    Logs::run("WINDS: $WINDS");
    Logs::run("WEB: $WEB");
}
#Break here for WCOSS_main_01
#Break here for WCOSS_main_02
#
#for_WCOSS
#codeswanpl02
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
for $i (1..$numcgrids-1){
  # Get a slice of the Config hash
  my $CG = @CGSS{$columns[$i]}; # 6,1,3
    %CG = %{$CG};
    $dateSuffix = &makeSwanRun($date,$inpGrid,$filename,%CG);
} 

#AW11416: Created new separate call to runModel from RunSwan.pm here, to split preprocessing and postprocessing

#foreach my $CG (sort(values(%ConfigSwan::CGS))) {
#foreach my $CG ( reverse sort values  %ConfigSwan::CGS) {
#Give the names of the hashes that contains the CG information
my @columns = qw(CG1 CG2 CG3 CG4 CG5);
#Loop over the actual umber of Comp. Grids, in spite of nymber of elemnts in @columns 
for $i (1..$numcgrids-1){
  # Get a slice of the Config hash
  my $CG = @CGSS{$columns[$i]}; # 6,1,3
    %CG = %{$CG};
    $dateSuffix = &runModel($date,$inpGrid,$filename,%CG);
} 
#Break here for WCOSS_main_03

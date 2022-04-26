#!/usr/bin/env perl
# ----------------------------------------------------------- 
# PERL Script
# PERL Version(s): 5
# Original Author(s): Eve-Marie Devalire for WFO-Eureka 
# File Creation Date: 04/20/2004
# Date Last Modified: 07/10/2013
#
# Version control: 2.30
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
use lib ("$ENV{'USHnwps'}");
use lib ("$ENV{'PMnwps'}");
use lib ("$ENV{'RUNdir'}");
use WaveInput qw(waveInputProcessing);
use WindInput qw(windInputProcessing);
use GraphicOutput qw(graphicOutputProcessing);
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
my $ESTOFS = $ENV{'ESTOFS'};
my $WINDS = $ENV{'WINDS'};
my $WEB = $ENV{'WEB'};
my $PLOT = $ENV{'PLOT'};
my $SITEID = $ENV{'SITEID'};
my $MODELCORE = $ENV{'MODELCORE'};
my $CGNUMPLOT = $ENV{'CGNUMPLOT'};
######################################################
#                Subroutines calls                   #
######################################################
#for_WCOSS
#codeswanpl03
print "========== in nwps_posproc_CG2.pl================\n";
print " RUNdir: ${RUNdir}\n";
print " CGNUMPLOT: ${CGNUMPLOT} \n";
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

#print "$NWPSdir, $ISPRODUCTIO, $DEBUGGING, $DEBUG_LEVEL, $BATHYdb, $SHAPEFILEdb, $ARCHdir\n";
#print "$DATAdir, $INPUTdir, $LOGdir, $VARdir, $OUTPUTdir, $RUNdir, $TMPdir, $RUNLEN, $WNA\n";
#print "$NEST, $RTOFS, $ESTOFS, $WINDS, $WEB, $PLOT, $MODELCORE, $LOGdir, $SITEID, $DATAdir\n";
#print "$GEN_NETCDF\n";
#
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
    Logs::run("ESTOFS: $ESTOFS");
    Logs::run("WINDS: $WINDS");
    Logs::run("WEB: $WEB");
}
#Break here for WCOSS_main_01
#Break here for WCOSS_main_02
#
#for_WCOSS
#codeswanpl02
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
###for $i (1..1){
my $less=1;
my $i=${CGNUMPLOT}-$less;
  # Get a slice of the Config hash
  my $CG = @CGSS{$columns[$i]}; # 6,1,3
    %CG = %{$CG};
# scratch next three lines for WCOSS_main
    if (defined($CG{GRAPHICOUTPUTDIRECTORY})) {
	Logs::run("Graphic post-processing for CG".$CG{CGNUM});
	&graphicOutputProcessing(%CG);
    }  #delete for wcoss
###} 
#Break here for WCOSS_main_03
#Logs::run("Archive input and output data files.");
#&completeArchiveAndCleanup($dateSuffix);

system("touch ${OUTPUTdir}/netCdf/completed");

Logs::run("END RUN");
# ----------------------------------------------------------- 
# ******************************* 
# ********* End of File ********* 
# ******************************* 
#End of file

#!/usr/bin/perl
# ----------------------------------------------------------- 
# PERL Script
# PERL Version(s): 5
# Original Author(s): Eve-Marie Devalire for WFO-Eureka 
# File Creation Date: 04/20/2004
# Date Last Modified: 11/15/2014
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
################################################################################
#                         ConfigSwan package                                   #
################################################################################
# This package serves as a configuration file, all model settings unique to    #
# your WFO should be made here.  The rest of the packages in the swan/bin      #
# directory should not be modified unless you no longer need or want technical #
# support with your GFE-integrated nearshore wave model implementation.        #
################################################################################

######################################################
#      Packages and exportation requirements         #
######################################################
package ConfigSwan;
require Exporter;
@ISA=qw(Exporter);
@EXPORT=qw(NUMCGRIDS NUMCPUS SWANFCSTLENGTH PATH NDAYSARCHIVE JETLAG DATATYPE DEBUG CG1DIR CWDIR NFTPATTEMPTS RUNFROMARCHIVE USEWINDCGS NDBC2DLOCS NDBC1DLOCS NDBCDIR VECOFFSET NDBCDIR LDADDIR NDBC1DLOCS NDBC2DLOCS ENPFILESDIR);

#######################################################################
#########################GENERAL CONFIGURATION#########################
#######################################################################
# Setup our NWPS env for this Perl script
my $NWPSdir = $ENV{'HOMEnwps'};
my $DATA = $ENV{'DATA'};
my $USERNAME = $ENV{'USERNAME'};
my $ISPRODUCTION = $ENV{'ISPRODUCTION'};
my $DEBUGGING = $ENV{'DEBUGGING'};
my $DEBUG_LEVEL = $ENV{'DEBUG_LEVEL'};
my $siteid = $ENV{'siteid'};
my $SITEID = $ENV{'SITEID'};
my $NUMCPUS = $ENV{'NUMCPUS'};

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

# NOTE: We must set the NESTS variable to enable or disable nesting
my $NESTS = $ENV{'NESTS'};

# Complete path of the folder the setup script has been run from write it as the following: "/model"
# (in your default instal11212ion the swan folder is directly under root)
use constant PATH => '';
# Number of Computational Grids (CG's) Note: more than 1 CG is only necessary for offices with a bar forecast.
use constant NUMCGRIDS => '1';
# SWAN forecasting time lenght (in hours)
use constant SWANFCSTLENGTH => '24';
# jet lag with UTC time
use constant JETLAG => '-19';
# number of days you want the files to be archived
use constant NDAYSARCHIVE => '7';
# Run model on archived data.  Define this directive as '' or the empty string to turn the feature off.
#  Example: SWAN_TAE_ARCHIVE.YY08.MO12.DD08.HH12.tgz; 
use constant RUNFROMARCHIVE => '';
# Save the following files located in swan/archive from being removed after NDAYSARCHIVE
#our @SAVEARCHIVEFILES = ('SWAN_TAE_ARCHIVE.YY07.MO012.DD15.HH12.tgz');
our @SAVEARCHIVEFILES = ('');

if((${NWPSplatform} eq 'WCOSS') || (${NWPSplatform} eq 'DEVWCOSS')) {
#for_WCOSS
#codeConfigpm01
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
}

#######################################################################
#######################WAVE INPUT CONFIGURATION########################
#######################################################################
# NOTE: The WW3 config has been moved to WaveInput.pm
use constant VECOFFSET =>'5';

#######################################################################
###############COMPUTATIONAL GRID (CGS) CONFIGURATION##################
#######################################################################
use CGinclude qw(:DEFAULT);

# NOTE: CG1 is required so we should always have CG1 defined
our %CGS = ( );
$CGS{'CG1'} = $CG1;
#system("echo FALSE > ${RUNdir}/nests.flag");

my $filein="${RUNdir}/nests.flag";

 open IN, "<$filein";
 while (<IN>) {
 	chomp;
        ${NESTTorF}=$_;
 }
 close (IN); 
if (${NESTTorF} eq 'TRUE') {
    $NESTS="YES";
}

# NOTE: Nesting is optional and we can have one or more nests
my $num_nests = 0;
if( ${NESTS} eq 'YES') {
    system("echo TRUE > ${RUNdir}/nests.flag");
    if (defined($CG2)) {
	$num_nests = $num_nests + 1;
	$CGS{'CG2'} = $CG2;
	# NOTE: Folloing line for testing only
	##print("INFO - Nesting is enabled for GC2\n");
    }
    else {
	# NOTE: Folloing line for testing only
	##print("INFO - Nesting is enabled but GC2 is not defined in your CGinput.pm template\n");
    }
    if (defined($CG3)) {
	$num_nests = $num_nests + 1;
	$CGS{'CG3'} = $CG3;
	# NOTE: Folloing line for testing only
	##print("INFO - Nesting is enabled for GC3\n");
    }
    else {
	# NOTE: Folloing line for testing only
	#print("INFO - Nesting is enabled but GC3 is not defined in your CGinput.pm template\n");
    }
    if (defined($CG4)) {
	$num_nests = $num_nests + 1;
	$CGS{'CG4'} = $CG4;
	# NOTE: Folloing line for testing only
	##print("INFO - Nesting is enabled for GC4\n");
    }
    else {
	# NOTE: Folloing line for testing only
	##print("INFO - Nesting is enabled but GC4 is not defined in your CGinput.pm template\n");
    }
    if (defined($CG5)) {
	$num_nests = $num_nests + 1;
	$CGS{'CG5'} = $CG5;
	# NOTE: Folloing line for testing only
	##print("INFO - Nesting is enabled for GC5\n");
    }
    else {
	# NOTE: Folloing line for testing only
	#print("INFO - Nesting is enabled but GC5 is not defined in your CGinput.pm template\n");
    }
    
    if ($num_nests == 0) {
	# NOTE: Folloing lines for testing only
	##print("ERROR - Nesting is enabled but GC2, 3, 4, or 5 is not defined in your CGinput.pm template\n");
	##print("WARNING - Will continue model run without nesting\n");
    }
}

# NOTE: The following lines are for testing only
## use Data::Dumper;
## print Dumper \%CGS;

#######################################################################
###########################DEBUG CONFIGURATION#########################
#######################################################################
# DEBUG puts the scripts in debug mode which results in output printed to the file 'nwps/logs/buglog.txt'   This is output apart from what 
# is written to the files ${LOGdir}/runlog.log and ${LOGdir}/errlog.log.  There are three primary levels of debug mode, 0, 1 and 2, and 8 
# additional specialized levels.
#   0 : level 0 means debugging is off and no messages will be reported. Note: Messages from subroutine Logs::run are still reported.
#   1 : at level 1, selected subroutines report themselves everytime they are executed in order to trace where the scripts are going and 
#       possibly failing.  
#   2 : at level 2, all data is reported, WARNING level 2 is a LOT of output so make sure this mode is not turned on
#       during operational runs of the scripts.
#
#   levels 3 through 11 correspond to printing all data from specific packages, additionally, any level 1 data from anywhere
#   in the system will also be reported for reference.
#   3 : all data from ArraySub.pm is reported 
#   4 : all data from Checking.pm is reported
#   5 : all data from CommonSub.pm is reported
#   12 : all data from GraphicOutput.pm is reported
#   7 : all data from matSubs.pm is reported
#   8 : all data from Partitionning.pm is reported
#   9 : all data from RunSwan.pm is reported
#   10: all data from WaveInput.pm is reported
#   11: all data from WindInput.pm is reported
#   12: all data from WaveHazards.pm is reported
#   13: all data from Archive.pm is reported
our @DEBUG = (1);	#list of Debug levels
##################################################################################

1;



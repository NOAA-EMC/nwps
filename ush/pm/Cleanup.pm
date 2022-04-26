#!/usr/bin/env perl
# ----------------------------------------------------------- 
# PERL Script
# PERL Version(s): 5
# Original Author(s): Eve-Marie Devalire for WFO-Eureka 
# File Creation Date: 04/20/2004
# Date Last Modified: 07/09/2013
#
# Version control: 2.23
#
# Support Team:
#
# Contributors: Alex Gibbs, Tony Freeman, Pablo Santos, Douglas Gaer
# ----------------------------------------------------------- 
# ------------- Program Description and Details ------------- 
# ----------------------------------------------------------- 
# This package contains all the subroutines that more than one perl program
# SWAN related is using with the exception of the Arrays related subroutines
# which have their own  package.
#
# ----------------------------------------------------------- 

# Packages and exportation requirements
package Cleanup;
use POSIX;
require Exporter;
@ISA=qw(Exporter);
@EXPORT=qw(cleanUp);
use CommonSub qw(removeFiles);
use Logs;
use ConfigSwan;

our $path=PATH;

# Setup our NWPS env
my $NWPSdir = $ENV{'HOMEnwps'};
my $DATA = $ENV{'DATA'};
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
my $NWPSplatform = $ENV{'NWPSplatform'};

################################################################################
# NAME: cleanUp subroutine
# CALL: &cleanUp();
# GOAL: Remove files from previous run(s)
################################################################################
sub cleanUp {
    # check if any other swan process is currently running
    my $NWPSdir = $ENV{'HOMEnwps'};
    my $INPUTdir = $ENV{'INPUTdir'};
    my $OUTPUTdir = $ENV{'OUTPUTdir'};
    my $inp_windfiles = "${INPUTdir}";

    #remove all the files from the previous run 
    &removeFiles('enp',"${INPUTdir}/wave/");
    &removeFiles('CGRID',"${OUTPUTdir}/grid");
    &removeFiles('WIND|enp|CG|CW|INPUT|PRINT|log',"${ARCHdir}/pen");
    &removeFiles('WIND|enp|CG|CW|INPUT|PRINT|log',"${ARCHdir}/extract");
    &removeFiles('wnd|enp|CGRID|spec|TAB|INPUT.CG|WIND|PRINT|NGRID|UNSTRUC|Errfile',"${RUNdir}");
    &removeFiles('txt|spec|TAB|20',"${OUTPUTdir}/spectra");
    #&removeFiles('wnd|txt$',"${INPUTdir}/wind");
    #&removeFiles('WIND',"${INPUTdir}/wind"); 
    &removeFiles('vectorPlot',"${OUTPUTdir}/vector");
    &removeFiles('5',"${OUTPUTdir}/netCdf");
    &removeFiles('5',"${OUTPUTdir}/grib2");
    &removeFiles('5',"${OUTPUTdir}/hdf5");
    &removeFiles('20',"${OUTPUTdir}/partition");
    &removeFiles('20',"${OUTPUTdir}/spectra");
    &removeFiles('20',"${OUTPUTdir}/validation");

    # Remove all but the most recent *_WIND.txt.gz files (Note: this operation depends on the names of
    # of the files to be in the format: YYYYMMDDHHSS_WIND.txt.gz )
    opendir(WIND_DIR, "${inp_windfiles}");
    my @windFiles = grep /gz/, readdir WIND_DIR or &Logs::err("Could not read from ${inp_windfiles} or it is empty: $!",3);
    @windFiles = sort @windFiles;
    pop @windFiles;
    foreach my ${wFile} (@windFiles) {
	print "wind file $wFile\n";
	&removeFiles(${wFile},"${inp_windfiles}");
    }
}

################################################################################
1;

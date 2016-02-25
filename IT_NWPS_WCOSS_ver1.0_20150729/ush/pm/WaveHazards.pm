#!/usr/bin/perl
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
################################################################################
#                               WaveHazards package                             #
################################################################################
# 
################################################################################
#               The subroutines implemented here are the following:            #
################################################################################
##runWaveHazards
################################################################################
#                   The packages used are the following:                       #
################################################################################
#Tie::File                                                                     #
################################################################################
#                   			NOTES                       	       #
################################################################################
# ----------------------------------------------------------- 

######################################################
#      Packages and exportation requirements         #
######################################################
package WaveHazards;
use Tie::File;
@ISA=qw(Exporter);
@EXPORT=qw(runWaveHazards);
use ConfigSwan;

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

######################################################
#                    Subroutines                     #
######################################################

################################################################################
# NAME: &runWaveHazards
# CALL: &runWaveHazards(".$CG{CGNUM}.")
# GOAL: This subroutine alters the config file for WaveHazards and executes the
#	program.  Any future development of the wave hazards program may include
#	pre or post-processing which would happen in this package.
################################################################################

sub runWaveHazards ($%){
	my ($dateSuffix,%CG) = @_;
	local $path=PATH;
	Logs::bug("begin runWaveHazards",1);

	chdir("${NWPSdir}/wavehazards");
	tie @wavehaz_par, 'Tie::File', "wavehazards_v3.par" or Logs::err("can't tie to file wavehazards_v3.par",2);
	$wavehaz_par[8] =  (SWANFCSTLENGTH+1)."                             ! SWAN data: number of time steps   (i8)";
	$wavehaz_par[9] =  ".$dateSuffix          ! Date suffix ending each file name (a30)";
	$wavehaz_par[10] = "./data/HSIG.CG".$CG{CGNUM}.".CGRID           ! SWAN file name: wave height grid (m) (a30)";
	$wavehaz_par[11] = "./data/WLEN.CG".$CG{CGNUM}.".CGRID         ! SWAN file name: wave length grid (m) (a30)";
	$wavehaz_par[12] = "./data/DEPTH.CG".$CG{CGNUM}.".CGRID        ! SWAN file name: water depth grid (m) (a30)";
	$wavehaz_par[13] = "./data/PDIR.CG".$CG{CGNUM}.".CGRID         ! SWAN file name: peak wave direction (deg) (a30)";
	$wavehaz_par[14] = "./data/VEL.CG".$CG{CGNUM}.".CGRID          ! SWAN file name: x-y velocity components (m/s) (a30)";
	$wavehaz_par[15] = "./data/VELDIR.CG".$CG{CGNUM}.".CGRID       ! OUTPUT: intermediate calculation file (deg) (a30)";
	$wavehaz_par[16] = "./data/BRK.CG".$CG{CGNUM}.".CGRID          ! OUTPUT: binary (0 or 1) wave hazards grid (a30)";
	untie @wavehaz_par;
	`./wavehazards_v3`;
	Logs::bug("end runWaveHazards",1);
}


##################################################################################
 
################################################################################
1;

######  

#!/usr/bin/perl
# ----------------------------------------------------------- 
# PERL Script
# PERL Version(s): 5
# Original Author(s): Eve-Marie Devalire for WFO-Eureka 
# File Creation Date: 04/20/2004
# Date Last Modified: 04/10/2015
#
# Version control: 2.30
#
# Support Team:
#
# Contributors: Alex Gibbs, Tony Freeman, Pablo Santos, Douglas Gaer
#               Roberto Padilla-Hernandez
#
# Wind pre-processing routine for all known AWIPS grids added by Douglas.Gaer@noaa.gov
# at SRH. GRID projection formulas for AWIPS grids provided by Thomas.J.Lefebvre@noaa.gov 
# and Mike.Romberg@noaa.gov at GDS. Interpolation routines for all AWIPS grids by
# Douglas.Gaer@noaa.gov at SRH. Re-projection and interpolation program site tested
# at MFL by Pablo.Santos@noaa.gov and Alex.Gibbs@noaa.gov.
#
# ----------------------------------------------------------- 
# ------------- Program Description and Details ------------- 
# ----------------------------------------------------------- 
#
################################################################################
#                               WindInput package                              #
################################################################################
# This package takes care of processing the wind input for the SWAN model, that#
# is to say retrieve the wind data and create corresponding file  in a format  #
# understandable by the SWAN model and make it available to it.                #
# The files translated are in NetCdf format                                    #
################################################################################

################################################################################
# 06/21/2011: Major change to this Perl module
#
# Below is a list of AWIPS grids and projections that we must support for all
# CONUS and NON-CONUS coastal WFOs. The orginal Perl package was modified to 
# use a C++ program that will re-project any AWIPS grid and write an output 
# file for the SWAN model.
#	
# AWIPS Projections:
#
#  LambertConformal
#  PolarStereographic
#  Mercator
#  LatLon
#
# AWIPS Grids:
#
#  AWIPS_Grid201
#  AWIPS_Grid202
#  AWIPS_Grid203
#  AWIPS_Grid204
#  AWIPS_Grid205
#  AWIPS_Grid206
#  AWIPS_Grid207
#  AWIPS_Grid208
#  AWIPS_Grid209
#  AWIPS_Grid210
#  AWIPS_Grid211
#  AWIPS_Grid212
#  AWIPS_Grid213
#  AWIPS_Grid214
#  AWIPS_Grid214AK
#  AWIPS_Grid215
#  AWIPS_Grid216
#  AWIPS_Grid217
#  AWIPS_Grid218
#  AWIPS_Grid219
#  AWIPS_Grid221
#  AWIPS_Grid222
#  AWIPS_Grid225
#  AWIPS_Grid226
#  AWIPS_Grid227
#  AWIPS_Grid228
#  AWIPS_Grid229
#  AWIPS_Grid230
#  AWIPS_Grid231
#  AWIPS_Grid232
#  AWIPS_Grid233
#  AWIPS_Grid234
#  AWIPS_HRAP
#
#  Any LATLON grid
#

###############################################################################
# ----------------------------------------------------------- 

######################################################
#      Packages and exportation requirements         #
######################################################
package WindInput;

# Setup our NWPS env
my $NWPSdir = $ENV{'HOMEnwps'};
my $USHnwps = $ENV{'USHnwps'};
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

# Setup our model run environment
my $WINDS = $ENV{'WINDS'};
my $SITEID = $ENV{'SITEID'};
my $siteid = $ENV{'siteid'};
my $NWPSplatform = $ENV{'NWPSplatform'};

# Look for any SITE Wind profile overrides
my $WindInterpolationType = $ENV{'WindInterpolationType'};
my $WindTimeStep = $ENV{'WindTimeStep'};

# Look for a wind file name specified on the command line
my $CommandLineWindFileName = $ENV{'CommandLineWindFileName'};

use POSIX;
use Cwd 'chdir';
use Tie::File;
use CommonSub qw(report giveDate ftp mvFiles removeFiles goForward 
copyFile renameFilesWithSuffix giveNextEntryLine changeLine);
use ArraySub qw(takeUndefAway takeSpaceAway printArray printArrayIn formatArray
formatDoubleArray pushDoubleArray printDoubleArray takeSpaceAway giveMaxArray
giveMaxDoubleArray giveSumDoubleArray reverseDoubleArray printDoubleArrayIn);
require Exporter;
@ISA=qw(Exporter);
@EXPORT=qw(windInputProcessing);
our $test=0;
our $gtop;
use ConfigSwan;
use Archive qw(isRunFromArchive archiveFiles copyWindFromArchive);

######################################################
#                    Subroutines                     #
######################################################

################################################################################
# NAME: &windInputProcessing
# CALL: &windInputProcessing()
# GOAL: This is the subroutine equivalent to the main. It is responsible for
#       taking care of archiving, downloading the wind data file, processing it
#       one by one and finally moving the resulting files to the right place.
################################################################################

sub windInputProcessing{
    local $path=PATH;
    my $NWPSdir = $ENV{'HOMEnwps'};
    my $USHnwps = $ENV{'USHnwps'};
    my $full_wind_path_fname="";
    Logs::bug("begin windInputProcessing",1);
    chdir("${INPUTdir}/wind");
    my $windlogfname = "${LOGdir}/wind_preprocessing.log";
    my $windlog = open(WINDLOG, ">${windlogfname}");
    if( ! $windlog ){
	Logs::bug("ERROR - Cannot create file ${windlogfname}",6);
    }
    print WINDLOG "Starting wind input pre-processing routine\n";
    system("date +%s > ${VARdir}/wind_start_secs.txt");
    my $windflag = $ENV{'WINDS'};
    print "In WindInputProcessing:  WindFlag: $windflag \n";
    if( $windflag eq "GFS" ) {
	print WINDLOG "Detected GFS input flag, changing our wind source to GFS input\n";
	system("${USHnwps}/gfswind/bin/gen_winds.sh >> $windlogfname");
	if($? != 0) {
	    Logs::err("ERROR - Problem with GFS wind pre-processing, see  $windlogfname\n",2);
	}
    }
    elsif ( $windflag eq "NAM" ) {
	print WINDLOG "Detected NAM input flag, changing our source to NAM input\n";
	Logs::err("INFO - The NAM winds feature has not been implemented in this release\nEXITING run...\n",2);
    }
    elsif ( $windflag eq "CUSTOM" ) {
	print WINDLOG "Detected custom input flag, changing our source to user define input\n";
	system("$NWPSdir/templates/${siteid}/gen_winds.sh >> $windlogfname");
	if($? != 0) {
	    Logs::err("ERROR - Problem with user defined wind pre-processing, see  $windlogfname\n",2);
	}
    }
    else {
	print WINDLOG "Using default AWIPS netCDF input as our wind source\n";
	if($CommandLineWindFileName eq "") {
	    $windNetCdfFile=&takeNetCdfFile();
	    $full_wind_path_fname="${INPUTdir}/wind/${windNetCdfFile}";
	}
	else {
	    $windNetCdfFile="${CommandLineWindFileName}";
	    $full_wind_path_fname="${windNetCdfFile}";
	}
    
	my $itype = "${WindInterpolationType}";
	# NOTE: The missing value for projected grids must be set to 0 to mask any null water areas.
	# NOTE: When GFE grids are re-projected to a LATLON grid for SWAN we will have null values
	# NOTE: along the outer edges of the domain. These ares must be set to 0 for SWAN.
	my $missing_value = "0";
	my $timestep = "${WindTimeStep}";
	if($itype eq "") {
	    $itype = "bilinear";
	}
	if($timestep eq "") {
	    $timestep = "0";
	}
	print WINDLOG "Wind interpolation = $itype\n";
	print WINDLOG "Wind missing value = $missing_value\n";
	if($timestep eq "0") {
	    print WINDLOG "Wind time step = netCDF time step\n";
	}
	else {
	    print WINDLOG "Wind time step = $timestep\n";
	}
    
	# Call to standalone wind-tool that will re-project and interpolate GFE wind grids
	system("read_awips_windfile --itype=${itype} --missing-value=${missing_value} --timestep=${timestep} ${full_wind_path_fname} ${INPUTdir}/wind >> $windlogfname");
	if($? != 0) {
	    Logs::err("ERROR - Problem with wind pre-processing, see  $windlogfname\n",2);
	}
    }

    # No matter what input wind source we use, we will always require the output file below
    print WINDLOG "Reading perl input file ${INPUTdir}/wind/perl_input.txt\n";
    my $infile_fp = open (INFILE, "${INPUTdir}/wind/perl_input.txt");
    if( ! $infile_fp ){
	print WINDLOG "ERROR - Could not open perl input file ${INPUTdir}/wind/perl_input.txt\n";
	Logs::err("ERROR - Problem with wind pre-processing, see  $windlogfname\n",2);
    }
    
    my $inarray;
    my $date;
    my $inpGrid;
    my $filename;
    while (<INFILE>) {
	chomp;
	@inarray = split(/:/, $_);
	if($inarray[0] eq 'DATE') {
	    $date = $inarray[1];
	}
	if($inarray[0] eq 'INPUTGRID') {
	    $inpGrid = $inarray[1];
	}
	if($inarray[0] eq 'FILENAME') {
	    $filename = $inarray[1];
	}
    }
    close (INFILE); 
    print WINDLOG "Read following values:\n";
    print WINDLOG"DATE:$date\nINPUTGRID:$inpGrid\nFILENAME:$filename\n";
    
    &mvFiles("${RUNdir}/",$filename);
    
    if(${DEBUGGING} ne 'TRUE') {
	print WINDLOG "Cleaning raw wind processing directory\n";
	&removeFiles('txt$',"${INPUTdir}/wind");
	&removeFiles('bin$',"${INPUTdir}/wind");
    }
    system("date +%s > ${VARdir}/wind_end_secs.txt");
    print WINDLOG "Wind input pre-processing complete\n";
    close(WINDLOG);
    
    Logs::bug("end windInputProcessing",1);
    return ($date,$inpGrid,$filename);
}

################################################################################
# NAME: &takeNetCdfFile();
# CALL: &takeNetCdfFile();
# GOAL: look for the most recent file in the wind input folder, copy to ${INPUTdir}/wind
################################################################################

sub takeNetCdfFile {
    my $NWPSdir = $ENV{'HOMEnwps'};
    my $fileToUnzip;
    Logs::bug("begin takeNetCdfFile",1);
    chdir ("${INPUTdir}/wind") or Logs::err("Directory can't be changed\nCould not change directoiry to ${INPUTdir}/wind\nError:$!\n",2);
    $windNetCdfFile=glob("*WIND.txt");
    $full_wind_path_fname="${INPUTdir}/wind/${windNetCdfFile}";
    Logs::bug("end takeNetCdfFile",1);
    return $windNetCdfFile;
}
	
################################################################################
1;

######  

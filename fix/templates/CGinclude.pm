#!/usr/bin/perl
# CGinclude.pm for NWPS
# Version: 1.02
# ----------------------------------------------------------- 
# DO NOT MODIFY THE BASELINE CONFIG ON LINES 6 THROUGH 13
package CGinclude;
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw($CG1 $CG2 $CG3 $CG4 $CG5);
my $NWPSdir = $ENV{'NWPSdir'};
my $OUTPUTdir = $ENV{'OUTPUTdir'};
my $NESTS = $ENV{'NESTS'};
##################################################################################
# DO NOT ABOVE BELOW THIS LINE
##################################################################################

# COMPUTATIONAL GRID ONE
# NOTE: CG1 is required for all domains
our $CG1 = {	
	CGNUM			=> 1,
	CGBOUNDARIES		=> {	SOUTHWESTLAT 	=> #SWLAT#,
					SOUTHWESTLON	=> #SWLON#,
					NORTHEASTLAT 	=> #NELAT#,
					NORTHEASTLON	=> #NELON#,
					NUMMESHESLAT	=> #MESHLAT#,
					NUMMESHESLON    => #MESHLON#,
				},
	USEWIND 		=> 1,
	GRAPHICOUTPUTDIRECTORY 	=> "${OUTPUTdir}/netCdf/CG1",
	OUTPUTDATATYPES		=> ['htsgw', 'dirpw', 'perpw', 'swell', 'wnd', 'depth', 'WLEN', 'wlevel', 'cur', 'spc1d'],
	LENGTHTIMESTEP          => #TSTEP#,
        FREQUENCYARRAY          => [FREQHERE],
        NUMOFOUTPUTSPC1D        => NOUTSPECTRA,
        SPECTRANAMES1D          => [SPECTRALNAMES],
        SPC1DLONGITUDES         => [SPC1DLONS],
        SPC1DLATITUDES          => [SPC1DLATS],
	NUMOFOUTPUTPART         => NOUTPARTITION,
        PARTITIONNAMES          => [PARTNAMES],
        PARTLONGITUDES          => [PARTLONS],
        PARTLATITUDES           => [PARTLATS],
        #TEXTLOCATIONS =>
        #{
        #        JUP =>
        #        {
        #                LAT =>26.96,
        #                LON =>279.96,
        #        },
	#},

	DUMMYPARM		=> ['ENDOFCGARRAY' ]
};	

# COMPUTATIONAL GRIDS FOR INNER NESTS
# NOTE: CG2, CG3, CG4, and CG5 is optional for all domains
# NOTE: Your first nest will be CG2 and you can have one or
# NOTE: more nests up to CG5. Each nest requires an array to 
# NOTE: be setup here by the site.

# DO NOT EDIT BELOW THIS LINE, UNLESS YOU KNOW WHAT ARE YOU DOING

#HERECG2 : COMPUT GRID 2 (CG2) NEST NUM 1 IF EXIST
#HERECG3 : COMPUT GRID 3 (CG3) NEST NUM 2 IF EXIST
#HERECG4 : COMPUT GRID 4 (CG4) NEST NUM 3 IF EXIST
#HERECG5 : COMPUT GRID 5 (CG5) NEST NUM 4 IF EXIST
##################################################################################
# DO NOT EDIT BELOW THIS LINE
##################################################################################
1;

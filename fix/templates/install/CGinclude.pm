#!/usr/bin/env perl
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
	CGBOUNDARIES		=> {	SOUTHWESTLAT 	=> 24.10,
					SOUTHWESTLON	=> -83.54,
					NORTHEASTLAT 	=> 27.70,
					NORTHEASTLON	=> -78.41,
					NUMMESHESLAT	=> 33,
					NUMMESHESLON    => 43,
				},
	USEWIND 		=> 1,
	GRAPHICOUTPUTDIRECTORY 	=> "${OUTPUTdir}/netCdf/CG1",
	OUTPUTDATATYPES		=> ['htsgw', 'dirpw', 'perpw', 'swell', 'wnd', 'depth', 'WLEN', 'wlevel', 'cur', 'spc1d'],
	LENGTHTIMESTEP          => 3,
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
our $CG2 = {
        CGNUM                   => 2,
	CGBOUNDARIES		=> {	SOUTHWESTLAT 	=> 25.84,
					SOUTHWESTLON	=> -80.12,
					NORTHEASTLAT 	=> 25.90,
					NORTHEASTLON	=> -80.10,
					NUMMESHESLAT	=> 222,
					NUMMESHESLON    => 66,
                                },
        USEWIND                 => 1,
        GRAPHICOUTPUTDIRECTORY  => "${OUTPUTdir}/netCdf/CG2",
        OUTPUTDATATYPES         => ['htsgw', 'dirpw', 'perpw', 'swell', 'wnd', 'depth', 'WLEN', 'wlevel', 'cur', 'spc1d'],
        LENGTHTIMESTEP          => 3,
        FREQUENCYARRAY          => [FREQHERE],
        NUMOFOUTPUTSPC1D        => NOUTSPECTRA,
        SPECTRANAMES1D          => [SPECTRALNAMES],
        SPC1DLONGITUDES         => [SPC1DLONS],
        SPC1DLATITUDES          => [SPC1DLATS],
        NUMOFOUTPUTPART         => NOUTPARTITION,
        PARTITIONNAMES          => [PARTNAMES],
        PARTLONGITUDES          => [PARTLONS],
        PARTLATITUDES           => [PARTLATS],
        DUMMYPARM               => ['ENDOFCGARRAY' ]
};
#HERECG3 : COMPUT GRID 3 (CG3) NEST NUM 2 IF EXIST
our $CG3 = {
        CGNUM                   => 3,
	CGBOUNDARIES		=> {	SOUTHWESTLAT 	=> 26.40,
					SOUTHWESTLON	=> -80.07,
					NORTHEASTLAT 	=> 26.52,
					NORTHEASTLON	=> -79.98,
					NUMMESHESLAT	=> 26,
					NUMMESHESLON    => 17,
                                },
        USEWIND                 => 1,
        GRAPHICOUTPUTDIRECTORY  => "${OUTPUTdir}/netCdf/CG3",
        OUTPUTDATATYPES         => ['htsgw', 'dirpw', 'perpw', 'swell', 'wnd', 'depth', 'WLEN', 'wlevel', 'cur', 'spc1d'],
        LENGTHTIMESTEP          => 3,
        FREQUENCYARRAY          => [FREQHERE],
        NUMOFOUTPUTSPC1D        => NOUTSPECTRA,
        SPECTRANAMES1D          => [SPECTRALNAMES],
        SPC1DLONGITUDES         => [SPC1DLONS],
        SPC1DLATITUDES          => [SPC1DLATS],
        NUMOFOUTPUTPART         => NOUTPARTITION,
        PARTITIONNAMES          => [PARTNAMES],
        PARTLONGITUDES          => [PARTLONS],
        PARTLATITUDES           => [PARTLATS],
        DUMMYPARM               => ['ENDOFCGARRAY' ]
};
#HERECG4 : COMPUT GRID 4 (CG4) NEST NUM 3 IF EXIST
our $CG4 = {
        CGNUM                   => 4,
	CGBOUNDARIES		=> {	SOUTHWESTLAT 	=> 26.25,
					SOUTHWESTLON	=> -80.09,
					NORTHEASTLAT 	=> 26.37,
					NORTHEASTLON	=> -80.00,
					NUMMESHESLAT	=> 26,
					NUMMESHESLON    => 17,
                                },
        USEWIND                 => 1,
        GRAPHICOUTPUTDIRECTORY  => "${OUTPUTdir}/netCdf/CG4",
        OUTPUTDATATYPES         => ['htsgw', 'dirpw', 'perpw', 'swell', 'wnd', 'depth', 'WLEN', 'wlevel', 'cur', 'spc1d'],
        LENGTHTIMESTEP          => 3,
        FREQUENCYARRAY          => [FREQHERE],
        NUMOFOUTPUTSPC1D        => NOUTSPECTRA,
        SPECTRANAMES1D          => [SPECTRALNAMES],
        SPC1DLONGITUDES         => [SPC1DLONS],
        SPC1DLATITUDES          => [SPC1DLATS],
        NUMOFOUTPUTPART         => NOUTPARTITION,
        PARTITIONNAMES          => [PARTNAMES],
        PARTLONGITUDES          => [PARTLONS],
        PARTLATITUDES           => [PARTLATS],
        DUMMYPARM               => ['ENDOFCGARRAY' ]
};
#HERECG5 : COMPUT GRID 5 (CG5) NEST NUM 4 IF EXIST
our $CG5 = {
        CGNUM                   => 5,
	CGBOUNDARIES		=> {	SOUTHWESTLAT 	=> 25.75,
					SOUTHWESTLON	=> -80.13,
					NORTHEASTLAT 	=> 25.87,
					NORTHEASTLON	=> -80.04,
					NUMMESHESLAT	=> 26,
					NUMMESHESLON    => 18,
                                },
        USEWIND                 => 1,
        GRAPHICOUTPUTDIRECTORY  => "${OUTPUTdir}/netCdf/CG5",
        OUTPUTDATATYPES         => ['htsgw', 'dirpw', 'perpw', 'swell', 'wnd', 'depth', 'WLEN', 'wlevel', 'cur', 'spc1d'],
        LENGTHTIMESTEP          => 3,
        FREQUENCYARRAY          => [FREQHERE],
        NUMOFOUTPUTSPC1D        => NOUTSPECTRA,
        SPECTRANAMES1D          => [SPECTRALNAMES],
        SPC1DLONGITUDES         => [SPC1DLONS],
        SPC1DLATITUDES          => [SPC1DLATS],
        NUMOFOUTPUTPART         => NOUTPARTITION,
        PARTITIONNAMES          => [PARTNAMES],
        PARTLONGITUDES          => [PARTLONS],
        PARTLATITUDES           => [PARTLATS],
        DUMMYPARM               => ['ENDOFCGARRAY' ]
};
##################################################################################
# DO NOT EDIT BELOW THIS LINE
##################################################################################
1;

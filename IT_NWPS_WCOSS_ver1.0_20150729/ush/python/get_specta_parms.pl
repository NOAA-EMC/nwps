#!/usr/bin/perl
# ----------------------------------------------------------- 
# Perl Script
# Operating System(s): RHEL 5
# Perl Version Used: 5.x
# Original Author(s): Douglas.Gaer@noaa.gov
# File Creation Date: 12/10/2009
# Date Last Modified: 08/25/2011
#
# Version control: 1.19
#
# Support Team:
#
# Contributors: Roberto Padilla-Hernandez
# ----------------------------------------------------------- 
# ------------- Program Description and Details ------------- 
# ----------------------------------------------------------- 
#
# GRADS processing script used read all SWAN GCs and output 
# configuration parameters in a CSV format. NOTE: This version
# was modified to work with specra lines in ConfigSwan.pm.
#
# USAGE 1: SWANPARMS=`perl -I${USHnwps} -I${RUNdir} ${BINdir}/get_spectra_parms.pl`
#
# USAGE 2: perl -I${USHnwps} -I${RUNdir} ./get_spectra_parms.pl 
#
# ----------------------------------------------------------- 

use ConfigSwan;

# Read all SWAN GCs and output config in CSV format
foreach my $CG (reverse sort(values(%ConfigSwan::CGS))) {
        %CG = %{$CG};
        print "CG".$CG{CGNUM}.",".$CG{LENGTHTIMESTEP}.",".SWANFCSTLENGTH.",";
	my $COORDS = $CG{CGBOUNDARIES};
	for my $k1 ( sort keys %$COORDS ) {
	    print "$k1:";
	    print "$COORDS->{$k1},";
	}
	print $CG{USEWIND}.",";
	print $CG{GRAPHICOUTPUTDIRECTORY}.",";

	# Printing method for nested PERL array
	my $DATATYPES = $CG{OUTPUTDATATYPES};
	my $num = scalar @$DATATYPES;
	my $i = 0;
	for ($i = 0; $i < $num; $i++) {
	    print @$DATATYPES[$i];
	    # Create a PIPE delimited list of our nested data types array
	    if($i < ($num-1)) { print "|"; }
	}

	# After the DATATYPE output VAR for number of variables
	print ",$num,";
	my $FREQS = $CG{FREQUENCYARRAY};
	my $numofFreq = scalar @$FREQS;
	my $i = 0;
	for ($i = 0; $i < $numofFreq; $i++) {
	    print @$FREQS[$i];
	    # Create a PIPE delimited list of our nested data types array
	    if($i < ($numofFreq-1)) { print "|"; }
	}
	# After the Frequencies output NumOfFreqs for number of frequencies
	print ",$numofFreq,";
        print $CG{NUMOFOUTPUTSPC1D}.",";
	#
	my $SPECTRANAMES = $CG{SPECTRANAMES1D};
	my $i = 0;
	for ($i = 0; $i < $CG{NUMOFOUTPUTSPC1D}; $i++) {
	    print @$SPECTRANAMES[$i];
	    # Create a PIPE delimited list of our nested data types array
	    if($i < ($CG{NUMOFOUTPUTSPC1D}-1)) { print "|"; }
	}
        print ",";
	my $SPC1DLONS = $CG{SPC1DLONGITUDES};
	$i = 0;
	for ($i = 0; $i < $CG{NUMOFOUTPUTSPC1D}; $i++) {
	    print @$SPC1DLONS[$i];
	    # Create a PIPE delimited list of our nested data types array
	    if($i < ($CG{NUMOFOUTPUTSPC1D}-1)) { print "|"; }
	}
        print ",";
	my $SPC1DLATS = $CG{SPC1DLATITUDES};
	$i = 0;
	for ($i = 0; $i < $CG{NUMOFOUTPUTSPC1D}; $i++) {
	    print @$SPC1DLATS[$i];
	    # Create a PIPE delimited list of our nested data types array
	    if($i < ($CG{NUMOFOUTPUTSPC1D}-1)) { print "|"; }
	}
	# Print a single line feed after our last config read

	print "\n";
}

exit 0;
# ----------------------------------------------------------- 
# ******************************* 
# ********* End of File ********* 
# ******************************* 

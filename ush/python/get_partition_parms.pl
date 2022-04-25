#!/usr/bin/env perl
# ----------------------------------------------------------- 
# Perl Script
# Operating System(s): RHEL 5
# Perl Version Used: 5.x
# Original Author(s): Roberto Padilla-Hernandez
# File Creation Date: 12/10/2009
# Date Last Modified: 06/05/2011
#
# Version control: 1.18
#
# Support Team:
#
# Contributors: Douglas Gaer
# ----------------------------------------------------------- 
# ------------- Program Description and Details ------------- 
# ----------------------------------------------------------- 
#
# GRADS processing script used read all SWAN GCs and output 
# configuration parameters in a CSV format. NOTE: This version
# was modified to work with specra lines in ConfigSwan.pm.
#
# USAGE 1: SWANPARMS=`perl -I${USHnwps} -I${RUNdir} ${BINdir}/get_partition_parms.pl`
#
# USAGE 2: perl -I${USHnwps} -I${RUNdir} ./get_partition_parms.pl 
#
# ----------------------------------------------------------- 

use lib ("$ENV{'USHnwps'}");
use lib ("$ENV{'RUNdir'}");
use ConfigSwan;

# Read all SWAN GCs and output config in CSV format
foreach my $CG (reverse sort(values(%ConfigSwan::CGS))) {
    %CG = %{$CG};
    # Wave tracking is currently limited to the CG1 domain
    if($CG{CGNUM} == 1) {
        print "CG".$CG{CGNUM}.",".$CG{LENGTHTIMESTEP}.",".SWANFCSTLENGTH.",";
	#
        my $NUMPRT = $CG{NUMOFOUTPUTPART};
	print "$NUMPRT,";
	my $PARTNAMES = $CG{PARTITIONNAMES};
	my $i;
	for ($i = 0; $i < $CG{NUMOFOUTPUTPART}; $i++) {
	    print @$PARTNAMES[$i];
	    # Create a PIPE delimited list of our nested data types array
	    if($i < ($CG{NUMOFOUTPUTPART}-1)) { print "|"; }
	}
        print ",";
	my $PARTLONS = $CG{PARTLONGITUDES};
	$i = 0;
	for ($i = 0; $i < $CG{NUMOFOUTPUTPART}; $i++) {
	    print @$PARTLONS[$i];
	    # Create a PIPE delimited list of our nested data types array
	    if($i < ($CG{NUMOFOUTPUTPART}-1)) { print "|"; }
	}
        print ",";
	my $PARTLATS = $CG{PARTLATITUDES};
	$i = 0;
	for ($i = 0; $i < $CG{NUMOFOUTPUTPART}; $i++) {
	    print @$PARTLATS[$i];
	    # Create a PIPE delimited list of our nested data types array
	    if($i < ($CG{NUMOFOUTPUTPART}-1)) { print "|"; }
	}
	# Print a single line feed after our last config read
	print "\n";
    }
}

exit 0;
# ----------------------------------------------------------- 
# ******************************* 
# ********* End of File ********* 
# ******************************* 

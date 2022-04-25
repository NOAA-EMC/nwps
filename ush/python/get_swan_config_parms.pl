#!/usr/bin/env perl
# ----------------------------------------------------------- 
# Perl Script
# Operating System(s): RHEL 5
# Perl Version Used: 5.x
# Original Author(s): Douglas.Gaer@noaa.gov
# File Creation Date: 12/10/2009
# Date Last Modified: 03/06/2010
#
# Version control: 1.17
#
# Support Team:
#
# Contributors:
# ----------------------------------------------------------- 
# ------------- Program Description and Details ------------- 
# ----------------------------------------------------------- 
#
# GRADS processing script used read all SWAN GCs and output 
# configuration parameters in a CSV format.
#
# USAGE 1: SWANPARMS=`perl -I${USHnwps} -I${RUNdir} ${BINdir}/get_swan_config_parms.pl`
#
# USAGE 2: perl -I${USHnwps} -I${RUNdir} ./get_swan_config_parms.pl 
#
# ----------------------------------------------------------- 

use lib ("$ENV{'RUNdir'}");
use ConfigSwan;

# Read all SWAN GCs and output config in CSV format
#foreach my $CG (reverse sort(values(%ConfigSwan::CGS))) {
foreach my $CG (reverse reverse sort(values(%ConfigSwan::CGS))) {
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
	print ",$num";

	# Print a single line feed after our last config read
	print "\n";
}

exit 0;
# ----------------------------------------------------------- 
# ******************************* 
# ********* End of File ********* 
# ******************************* 

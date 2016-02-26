#!/usr/bin/perl

use lib ("$ENV{'PMnwps'}");
use ConfigSwan;

foreach my $CG (reverse sort(values(%ConfigSwan::CGS))) {
        %CG = %{$CG};
        print "CG".$CG{CGNUM}.",".$CG{LENGTHTIMESTEP}.",".SWANFCSTLENGTH."\n";
}

exit 0;

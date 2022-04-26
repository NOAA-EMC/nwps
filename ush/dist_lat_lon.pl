#!/usr/bin/env perl
# ----------------------------------------------------------- 
# PERL Script
# PERL Version(s): 5
# Original Author(s): Pablo Santos
# File Creation Date: 09/20/2009
# Date Last Modified: 07/09/2013
#
# Version control: 1.03
#
# Support Team:
#
# Contributors:
# ----------------------------------------------------------- 
# ------------- Program Description and Details ------------- 
# ----------------------------------------------------------- 
#
# Script use to calculate LAT/LON
#
# ----------------------------------------------------------- 
use Math::Trig;

# This script assumes the input lat and lon is in degrees decimal using negative for western or souther values.
# Furthermore, lat1 is NE corner lat, lat2 is SW corner lat, lon1 is NE corner lon, and lon2 is SW corner lon.

#print "INPUTS ARE: $ARGV[0], $ARGV[1], $ARGV[2], $ARGV[3]\n";

$lat1 = $ARGV[0]*3.1415926535897932384/180.;
$lon1 = $ARGV[1]*3.1415926535897932384/180.;
$lat2 = $ARGV[2]*3.1415926535897932384/180.;
$lon2 = $ARGV[3]*3.1415926535897932384/180.;
$aa = 6378.1370; #Radius of the Earth at the Equator
$bb = 6356.7523; #Radius of the Earth at the Poles

$meanlat = ($lat1 + $lat2)/2.0;

# $lat1 and $lon1 are the coordinates of the first point in radians
# $lat2 and $lon2 are the coordinates of the second point in radians

my $a = sin(($lat2 - $lat1)/2.0);
my $b = sin(($lon2 - $lon1)/2.0);
my $h = ($a*$a) + cos($lat1) * cos($lat2) * ($b*$b);
my $theta = 2 * asin(sqrt($h)); # distance in radians

my $num = (($aa**2)*(cos($meanlat)))**2 + (($bb**2)*(sin($meanlat)))**2; 
my $den = ($aa*(cos($meanlat)))**2 + ($bb*(sin($meanlat)))**2;
my $r = sqrt($num/$den);
my $dist = $r*$theta;


# in order to find the distance, multiply $theta by the radius of the earth, e.g.
# $theta * 6,372.7976 = distance in kilometres (value from http://en.wikipedia.org/wiki/Earth_radius)

#print "Mean Radius for the domain is : $r\n";
#print "The distance between these two points is $dist \n";
print "$dist";
# ----------------------------------------------------------- 
# ******************************* 
# ********* End of File ********* 
# ******************************* 

#!/usr/bin/perl
# ----------------------------------------------------------- 
# PERL Script
# PERL Version(s): 5
# Original Author(s): Eve-Marie Devalire for WFO-Eureka 
# File Creation Date: 04/20/2004
# Date Last Modified: 07/09/2013
#
# Version control: 2.22
#
# Support Team:
#
# Contributors: Alex Gibbs, Tony Freeman, Pablo Santos, Douglas Gaer
# ----------------------------------------------------------- 
# ------------- Program Description and Details ------------- 
# ----------------------------------------------------------- 
################################################################################
#                           TextOutput package                                 #
################################################################################
# This package takes care of processing the text output for the SWAN model,    #
# with retrieving the right spectra files,processing for each particular point #
# we want and printing it in WaveWatchIII output format to process it in an    #
# existing fortran code which creates the text bulletin.                       #
# The resulting files are then shipped to AWIPS                                #
################################################################################
#               The subroutines implemented here are the following:            #
################################################################################
# createFileFor                                                                #
# getHeader                                                                    #
# createFileHeader                                                             #
# getRecord                                                                    #
# constructString                                                              #
# createHeader                                                                 #
# createTemp                                                                   #
# translate                                                                    #
# findSpeedAndDir                                                              #
# giveValues                                                                   #
# convertFromScientificNotation                                                #
# runFortranProg                                                               #
################################################################################
#                   The packages used are the following:                       #
################################################################################
# ArraySub                                                                     #
# CommonSub                                                                    #
################################################################################
# ----------------------------------------------------------- 

################################################################################
#      Packages and exportation requirements                                   #
################################################################################

package TextOutput;
require Exporter;
@ISA=qw(Exporter);
@EXPORT=qw(textOutputProcessing);
use strict;
no strict 'refs';
no strict 'subs';
#use Convert::SciEng;
use CommonSub qw(giveDate ftp mvFiles removeFiles removeOldFiles goForward copyFile 
renameFilesWithSuffix giveNextEntryLine changeLine report);
use ArraySub qw(takeUndefAway takeSpaceAway printArray printArrayIn formatArray
formatDoubleArray pushDoubleArray printDoubleArray takeSpaceAway giveMaxArray
giveMaxDoubleArray giveSumDoubleArray reverseDoubleArray);
use Logs;
use POSIX();
use ConfigSwan;
use Math::Trig;

# Setup our NWPS env
my $NWPSdir = $ENV{'HOMEnwps'};
my $DATA = $ENV{'DATA'};
my $ISPRODUCTION = $ENV{'ISPRODUCTION'};
my $DEBUGGING = $ENV{'DEBUGGING'};
my $DEBUG_LEVEL = $ENV{'DEBUG_LEVEL'};
my $ARCHBITS = $ENV{'ARCHBITS'};

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

our $path=PATH;
our $test=0;

######################################################
#             Variables declarations                 #
######################################################

our $location;
our ($i,$j,$nFreq,$nDir,$lineNum,@freq,@dir,@record,@WW3format,@coordonates);
our $timeStep;
our @swanOut;
our $dateSuffix;
our @loc;
our $cg;
our $timeStepLength;
our $cgnum;

######################################################
#                    Subroutines                     #
######################################################

################################################################################
# NAME: &textOutputProcessing
# CALL: &textOutputProcessing()
# GOAL: This is the subroutine equivalent to the main. It is responsible for
#       retrieving the right files, create the WW3 format file for each one of
#       the spectral point domain, and store them in the appropriate folder
#       (have still to decide where we'll be displaying those)
################################################################################

sub textOutputProcessing {
	our ($dateSuffix,$cgRef)=@_;
	our %CG = %$cgRef;
	$cgnum = $CG{CGNUM};
	$timeStepLength = $CG{LENGTHTIMESTEP};
	chdir "${OUTPUTdir}/spectra";
	@loc = keys(%{$CG{TEXTLOCATIONS}});
	my $ndbcDir=NDBCDIR;
	foreach (@loc) {
	       	&createFileFor($_);
      		&mvFiles("${OUTPUTdir}/validation/","WW3");
		system("${NWPSdir}/lib${ARCHBITS}/validation/NWSWavedat ${OUTPUTdir}/validation/ $_.WW3 ${OUTPUTdir}/validation/ $_");
		my $obsFile="NDBC_".$_.".mat";
		#my $modFile=$_."_SWANfcst_00.mat";
		my $modFile=$_."_SWANtotal_fcst.mat";
		system("${NWPSdir}/lib${ARCHBITS}/validation/validationGraph $ndbcDir/$obsFile ${OUTPUTdir}/validation/$_/$modFile $_ ${OUTPUTdir}/validation/$_/");
	}
	&removeFiles("WW3","${OUTPUTdir}/spectra/");#we don't need them anymore after and fast to produce
	&removeOldFiles(NDAYSARCHIVE,"bull");
	&renameFilesWithSuffix(".$dateSuffix","bull");
}
       
################################################################################
# NAME: createFileFor
# CALL: &createFileFor($location)
# GOAL: create the file in creating the header of the file and then for each
#       time step the corresponding data
################################################################################

sub createFileFor {
	chdir "${OUTPUTdir}/spectra";
	open (WW3,">$_[0].WW3");
	&getHeader($_[0]);
	our $timeStep=SWANFCSTLENGTH/$timeStepLength+1;
	our $i=0;
	while ($i<=$timeStep) {
		my $check=&getRecord($_[0],$i);
		last if ($check==0);
		$i++;
	}
	close WW3;
	&copyFile("$_[0].WW3","${OUTPUTdir}/validation/$_[0].WW3");
        chdir "${OUTPUTdir}/validation";
	#&runFortranProg($_[0]);
}

################################################################################
# NAME: getheader subroutine
# CALL: &getHeader($location);
# GOAL: get the data from the swan output file depending on the $location we
#       want the data to be on and print corresponding info in WW3 format file
################################################################################

sub getHeader {
	undef @freq;
	undef @dir;
	chdir "${OUTPUTdir}/spectra";
	open (SWANOUT, "spec2d.out.$_[0].$dateSuffix") or Logs::bug("the file spec2d.out.$_[0].$dateSuffix has not been open, error:$!");
	@swanOut=<SWANOUT>;
	chomp (@swanOut);
	close SWANOUT;
	$lineNum=&giveNextEntryLine("number of locations",0,\@swanOut);
	undef @coordonates;
	@coordonates=split /\s+/,$swanOut[$lineNum+1];
	# do a shift because the first element is empty
	shift @coordonates;
	# get number of frequencies and the corresponding list
	$lineNum=&giveNextEntryLine("number of frequencies",$lineNum,\@swanOut);
	$swanOut[$lineNum]=~/(\d+)/;
	$nFreq=$1;
	#list of freq starts on the following line
	$lineNum++;
	foreach $i (0 .. $nFreq-1)
		{
		push @freq,$swanOut[$lineNum];
		$lineNum++;
		$i++;
	}
	# get number of directions and the corresponding list
	$lineNum++;
	$swanOut[$lineNum]=~/(\d+)/;
	$nDir=$1;
	#list of directions starts on the following line
	$lineNum++;
	foreach $i (0 .. $nDir-1)
	{
		push @dir,$swanOut[$lineNum];
		$lineNum++;
		$i++;
	}
	my $freqValues=&constructString(\@freq);
	my $dirValues=&constructString(\@dir);
	my $firstLine="'SWAN SPECTRA'     $nFreq    $nDir     1 SWAN (Simulating WAve Nearshore)";
	print WW3 "$firstLine\n$freqValues\n$dirValues\n";
}

################################################################################
# NAME:  &getRecord
# CALL:  &getRecord($location,$i)a record is composed of $nFreq lines of $nDir
#       values)$i let us know in which record we are
# GOAL: get for each piece of record the date, the factor and the data
################################################################################

sub getRecord {
	my $i=$_[1]; 
	undef @record;#to have a new array for each record
	my $tempRef;
	my ($date,$factor);
	my $size=@swanOut;
	$lineNum=&giveNextEntryLine("date",$lineNum,\@swanOut);
	$swanOut[$lineNum]=~/(\d+).(\d+)/;
	$date="$1 $2";
	$lineNum++;#FACTOR line
	$lineNum++;# factor value line
	$swanOut[$lineNum]=~/(\S+)/;
	$factor=$1;
	$lineNum++;# beginning of data record
	#create the header part and print it for each record
	&createHeader(@_,$date);
	foreach $i(0 .. $nFreq-1)
	{
		$tempRef=&createTemp();
		push @record, $tempRef;
		$lineNum++;
	}
	#&printDoubleArray(\@record) if ($test==1);
	&translate($factor);
	#print "record after translate" if ($test==1);
	#&printDoubleArray(\@record) if ($test==1);
	my $recordRef=&reverseDoubleArray(\@record);	
	@record=@$recordRef;
	#print "record after reverse" if ($test==1);
	#&printDoubleArray(\@record) if ($test==1);
	my $valuePerLine=0;
	my $line;
	#the following print the record in the file (WW3 format)
	for $i (0 .. $#record)
 	{
		for $j (0 .. $#{$record[$i]})
		{
			$line.=sprintf "  %4.3e",$record[$i][$j];
                        $valuePerLine++;
			if ($valuePerLine==7 or ($i==$#record and $j==$#{$record[$i]}))
			{
				print WW3 "$line\n";
				#print "in WW3:$line\n";
				undef $line;
				$valuePerLine=0;
			}
		}
	}
	return 0 if ($lineNum==($size-$nFreq-3));#to know when reach last record...-3 for the line we skip
	return 1;
}

################################################################################
# NAME: &createTemp
# CALL: &createTemp()
# GOAL: create a temp array with data for $nDir value (a subroutine had to be
#       created because if we try the same treatment in getRecords sub temp has
#       to be undefined each time which involves references to undefined arrays)
################################################################################

sub createTemp {
	my @temp= split /\s+/,$swanOut[$lineNum];
	shift(@temp);
	return \@temp;
}
	
################################################################################
# NAME:&translate
# CALL:&translate($factor)
# GOAL:transform the data so that it fits WW3 format requirement
################################################################################

sub translate {
	my $factor=$_[0];
	my $pi=atan(1)*4;
	#&printDoubleArray(\@record);
	for $i (0 .. $#record)
	{
		for $j (0 .. $#{$record[$i]})
		{
			$record[$i][$j]=$record[$i][$j]*180/$pi*$factor;
		}
	}								
	#&printDoubleArray(\@record);
}

################################################################################
# NAME: &createHeader
# CALL: &translate($location,$j,$date)
# GOAL: create the header of each record for a particular location, including
#       thedate and values we take from the Tables obtained running SWAN (wind
#       velocity, water depth, current velocity, current direction) $j keep
#       track of the line we want to read the table from
################################################################################

sub createHeader {
	my ($location,$j,$date)=@_;
	my (@table,@header,$valueLine);
	my($currentVel,$currentDir,$windVel,$windDir,$lat,$lon);
	# DS -> The elements of the array were switch to ($lon,$lat) where before it was 
	# defined as ($lat,$lon) to correct for a misunderstanding in spherical coordinate names.
	($lon,$lat)=@coordonates;

	my $lines=0;
	my $table=$location."_TAB.".$dateSuffix;
	open (TAB,$table) || Logs::bug("can't open the table for the location
                $location in writing ($table), error:$!");
	@table=<TAB>;
	close TAB;
	#to go through the header of the files (comments lines and legend)
	while ($table[$lines]=~/%/)
	{
		$lines++;
	}
	$lines=$lines+$j;
	my (undef,$depth,$xVel,$yVel,$xWindVel,$yWindVel)=split /\s+/,$table[$lines];
	($currentVel,$currentDir)=&findSpeedAndDir($xVel,$yVel);
	($windVel,$windDir)=&findSpeedAndDir($xWindVel,$yWindVel);
	$valueLine=sprintf "'$location    '  %4.2f %5.2f     %4.1f   %3.2f %4.1f   %3.2f %4.1f",$lat,$lon,$depth,$windVel,$windDir,$currentVel,$currentDir;
	print WW3 "$date\n$valueLine\n";
}

################################################################################
# NAME:  &giveValues
# CALL:  &giveValues($lineNum,$pattern,$arrayName,$splitOn,$flag)
# GOAL:  return the values we need from the array arrayName and depending on
#       the pattern we are looking for in the array, the old line number(from
#       which line we have to start our search), the value we want the 'split'
#       to be on, and the flag indicates if we want the result in an array (1)
#       or in a string (2) or in a string and an array(3)
################################################################################

sub giveValues {
	my ($pattern,$arrayName,$splitOn,$flag);
	($lineNum,$pattern,$arrayName,$splitOn,$flag)=@_;
	$lineNum=&giveNextEntryLine($pattern,$lineNum,$arrayName);
	chop $$arrayName[$lineNum];
	my (undef,$valuesString)=split /$splitOn/,$$arrayName[$lineNum];#need sometimes the all string
	if ($flag!=2)
	{
		return ($lineNum,$valuesString);
	}
	else
	{
		my @valuesArray;
		@valuesArray=split / /,$valuesString;
		&takeUndefAway(\@valuesArray);
		return ($lineNum,@valuesArray) if ($flag==1);
		return ($lineNum,$valuesString,@valuesArray) if ($flag==3);
	}
}

################################################################################
# NAME: &convertFromScientificNotation
# CALL:&convertFromScientificNotation();
# GOAL:convert the data array from float to scientific notation
################################################################################

sub convertToScientificNotation {
	my $name=$_[0];
	my $i;
	my $j;
	foreach $i (0 .. $#$name)
	{
		foreach $j (0 .. $#{$$name[$i]})
		{
			$$name[$i][$j]=sprintf "%4.3e",$$name[$i][$j];
		}
	}
}

################################################################################
# NAME: constructString
# CALL: constrcutstring(@array)
# GOAL: construct from array(small) the corresponding string to print
################################################################################

sub constructString {
	my $arrayRef=shift;
	my @array=@$arrayRef;
	my $valuePerline=1;
	my $string;
	foreach (@array)
	{	
		$string.=sprintf"  %4.3e",$_;
		if ($valuePerline==7)
		{
			$valuePerline=0;
			$string.="\n";
		}
		$valuePerline++;
	}
	return $string;
}
	
################################################################################
# NAME: findSpeedAndDir
# CALL: findSpeedAndDir(x,y);
# GOAL: calculate the direction and the magnitude (speed) of a particulr type of
#       data, for a given vector
################################################################################

sub findSpeedAndDir {
	my ($x,$y)=@_;
	my $theta;
	my $mag=sqrt($x**2+$y**2);
	my $pi=atan(1,1)*4;
	#The direction angle is assumed to be relative to north with a clockwise
        #direction being positive.
	$theta=0 if ($x==0 and $y==0);
        $theta=180 if ($x==0 and $y>0);
        $theta=0 if ($x==0 and $y<0);
        $theta=270 if ($y==0 and $x>0);
        $theta=90 if ($y==0 and $x<0);
        $theta=270-atan($y/$x)*180/$pi if ($x>0 and $y>0);
        $theta=90-atan($y/$x)*180/$pi if ($x<0 and $y>0);
        $theta=90-atan($y/$x)*180/$pi if ($x<0 and $y<0);
        $theta=270-atan($y/$x)*180/$pi if ($x>0 and $y<0);
        return ($mag,$theta);
}

################################################################################
# NAME: runFortranProg
# CALL: runFortranProg($location);
# GOAL: create rthe parameter file for the Fortran program producing the text bulletin
#       and make the parameter and data file accessible to the related executable
################################################################################
#
#sub runFortranProg {	
#	open (PARAM,">${OUTPUTdir}/validation/parametersFile");
#	printf PARAM "$_[0]\n";#location point
#	#print PARAM "$spectraFrom\n";#run cycle
#	#1-FIX-2-04/29/05-this line wasn't right, now figure out the first computaion time (included in $dateSuffix)=> make fortran code read in paramFile
#	my (undef,$hour)=unpack"A17 A2",$dateSuffix;
#	print PARAM "$hour\n";#time cycle
#	print PARAM "$_[0].WW3\n";#input file
#	print PARAM "1\n";#format
#	print PARAM "$_[0].bull\n";#output file (text bulletin)
#	close PARAM;
#	# run text bulletin creation program
#	system "./TextBullWWIII.x";
#}
#
################################################################################
1;

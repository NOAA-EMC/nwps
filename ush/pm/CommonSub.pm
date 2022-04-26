#!/usr/bin/env perl
# ----------------------------------------------------------- 
# PERL Script
# PERL Version(s): 5
# Original Author(s): Eve-Marie Devalire for WFO-Eureka 
# File Creation Date: 04/20/2004
# Date Last Modified: 09/20/2011
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
#                               CommonSub package                              #
################################################################################
# This package contains all the subroutines that more than one perl program    #
#SWAN related is using with the exception of the Arrays related subroutines    #
#which have their own  package.                                                #
################################################################################
#               The subroutines implemented here are the following:            #
################################################################################
##giveDate                                                                     #
##ftp                                                                          #
##copyWaveFiles
##mvFiles                                                                      #
##goForward                                                                    #
##renameFilesWithSuffix                                                        #
##giveNextEntryLine                                                            #
##changeLine                                                                   #
##convertFromScientificNotation                                                #
##removeOldFiles                                                               #
##translate                                                                    #
##copyFile                                                                     #
##removeFiles                                                                  #
##createTemp                                                                   #
##giveValues                                                                   #
################################################################################
#                   The packages used are the following:                       #
################################################################################
#ArraySub                                                                      #
#File::Copy                                                                    #
#Net::FTP                                                                      #
################################################################################
# ----------------------------------------------------------- 

######################################################
#      Packages and exportation requirements         #
######################################################

package CommonSub;
#use Mail::Mailer;
use File::Copy;
use Net::FTP;
use POSIX;
require Exporter;
@ISA=qw(Exporter);
@EXPORT=qw(giveDate ftp copyWaveFiles mvFiles removeFiles removeOldFiles goForward copyFile 
renameFilesWithSuffix giveNextEntryLine changeLine report);
use ArraySub qw(printDoubleArray takeSpaceAway printArray);
use Logs;
use ConfigSwan;
use Data::Dumper;

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
my $LDMdir = $ENV{'LDMdir'};
my $NWPSplatform = $ENV{'NWPSplatform'};

local $test=1;

######################################################
#                    Subroutines                     #
######################################################

################################################################################
# NAME: giveDate subroutine
# CALL: &giveDate();
# GOAL: give the actual date and time in an array with formatted variables
################################################################################
                                                                                                                             
sub giveDate {
	my($sec,$min,$hour,$mday,$mon,$year)=gmtime(time);
	$mon++; # because the range is 0->6
	$year=$year+1900; #because 1900 has been substracted before
	#to have the date returned formatted
	$sec=sprintf "%2.2d",$sec;
	$min=sprintf "%2.2d",$min;
	$hour=sprintf "%2.2d",$hour;
	$mday=sprintf "%2.2d",$mday;
	$mon=sprintf "%2.2d",$mon;
	$year=sprintf "%4.4d",$year;

	#my $hReal=$hour+$min/60;
	#push @date,$hReal;# put hReal at the end to have an easy access to it
	my @date=($sec,$min,$hour,$mday,$mon,$year);
	#print "Obtain the date out @date\n";#***************************
	#&printArray(@date);
	return @date;
}
                                                                                                                             
################################################################################
# NAME: ftp
# CALL: &ftp(url,remoteDirectory,pattern1, pattern2,pattern3);
# GOAL: download with ftp process the files that are matching the pattern 1 and
#       2 at the indicated url and in the directory we have precised
################################################################################

sub ftp{ 
    # We need to flush the output buffers before starting FTP download
    my $old_fh = select(STDOUT);
    $| = 1;
    select($old_fh); 

    my ($url,$directory,$firstPattern,$secPattern,$thirdPattern)=@_;

    Logs::run("Starting ftp download ${url}, ${directory}, ${firstPattern}, ${secPattern}, ${thirdPattern}");
    my $ftp;
    my $connection=1;
    my $iTry=1;
    $ftp= Net::FTP->new($url); 
    Logs::bug("ftp=$ftp",5);
    until ($ftp) {
	Logs::err("Can't connect: $@\n",3);
	print "Warning, can't connect to ftp site (Error Message: $@), will try again in one minute...\n";
	sleep(60);
	$ftp= Net::FTP->new($url); 
	$iTry++;
	last if ($iTry==10);
    }
    Logs::err("ftp Issue\nDoesn't manage to connect after 10 tries , please check the ftp connection and if it is fine err swan.pl again\n",2) if ($iTry==10);
    Logs::bug("Sub ftp attempted $iTry times before managing to connect",5);
    $ftp->login() or Logs::err("ftp Issue - Could'nt login in anonymous",3); 
    $ftp->binary();
    $ftp->cwd($directory) or Logs::err("ftp Issue\nCould'nt change directory into $directory\n",3);#change directory
    my @list=$ftp->ls() or Logs::err("ftp Issue\nCould'nt list directory $directory,\n",3);#get the list of files in this remote directory
    my @filesToDownload=grep(/$firstPattern/ && /$secPattern/ && /${thirdPattern}[0-9]/ ,@list);
    return 0 unless(@filesToDownload);
    foreach (@filesToDownload) {
	$iTry = 1;
	until (-e $_) {
	    $ftp->get($_) or Logs::err("ftp Issue - Could'nt get $_, tries num= $iTry++\n",3);
	    $iTry++;
	    last if ($iTry==10);
	}
	Logs::err("ftp Issue - Doesn't manage to retrieve the previous file, please err swan.pl again",2) if ($iTry==10);
	Logs::bug("$_ downloaded",5);
    }
    $ftp->quit() or Logs::err("Couldn't quit ftp... ftp=$ftp",3);
    Logs::bug("Ftp subroutine complete",1);
    return \@filesToDownload;
}


################################################################################
# NAME: copyWaveFiles
# CALL: $copyWaveFiles($oldPath,$newPath)
# GOAL: copy file to another path
################################################################################

sub copyWaveFiles{
        my ($oldPath,$newPath,$prefix)=@_;
        system "cp $oldPath/${prefix}* $newPath/";
        system ("ls $INPUTdir/wave/${prefix}*.spec > $INPUTdir/wave/bcFileList.dat");
        Logs::bug("COPY\nThe path $oldPath has been copied to $newPath",1);

	open MYFILE, "$INPUTdir/wave/bcFileList.dat";	
	my @fileList = readline MYFILE;

	foreach my $file (@fileList) {
	    $file=~s/\n//g;
	    Logs::bug("copying  $file\n",1);
	}

	return \@fileList;
}



################################################################################
# NAME: mvFiles
# CALL: &mvFiles($newSpot,$matchingPattern,$secondMatchingPattern);the
#       secondMatchingPattern is optional
# GOAL: move the files corresponding with the matching pattern from the current
#       directory to the new spot they have to be in
################################################################################
                                                                                                                             
sub mvFiles {
	# remove a trailing slash on the dir name if it exists.
        $newDir = (substr($_[0],-1) eq "/") ? substr($_[0],0,-1) : $_[0];

	opendir(DIR, ".") or Logs::err("Directory opening issue\nCould'nt open the current directory :Error: $!",2);
	my  @filesToMove;
	@filesToMove=grep(/$_[1]/,readdir(DIR)) if (@_==2);
	@filesToMove=grep(/$_[1]/ && /$_[2]/,readdir(DIR)) if (@_==3);
	Logs::bug("files to move:",5);
	foreach (@filesToMove) {
		Logs::bug("$_",5);
	}
	closedir DIR or Logs::err("Directory closing issue\nCould'nt close the current directory :Error: $!",2);
	foreach (@filesToMove) {	
		my $oldName="./".$_;
		Logs::bug("old name: $oldName",5);
		my $newName=$newDir."/".$_;
		Logs::bug("new name: $newName",5);
		move($oldName,$newName) or Logs::err("Couldn't move $oldName to $newName : $!",3);
	}                                
}
        
################################################################################
# NAME:  removeFiles
# CALL:  &removeFiles($pattern,$dir)
# GOAL:  remove the files matching the pattern from the directory $dir
################################################################################

sub removeFiles{
	my $dirToOpen;
	# remove a trailing slash on the dir name if it exists.
	$dirToOpen = (substr($_[1],-1) eq "/") ? substr($_[1],0,-1) : $_[1];
	opendir (DIR,$dirToOpen)  or Logs::err("Directory can't be opened: $dirToOpen ($!)",2);
	my @filesInDir = readdir DIR;
	if(@filesInDir>0){
		my @filesToRemove=grep /$_[0]/,@filesInDir;
		foreach $file (@filesToRemove){
			Logs::bug("Removing file: $dirToOpen/$file",1);
			unlink $dirToOpen."/".$file or Logs::err("Couldn't unlink the file: $file ($!)",3);
		}
	}
	closedir DIR;
}
	
################################################################################
# NAME:  removeOldFiles
# CALL:  removeOldFiles($numberOfDays,$pattern,$folder)
# GOAL:  remove from folder the files matching the pattern older
#        than the number of days in argument 
################################################################################

sub removeOldFiles {
	my $folder = defined($_[2]) ? $_[2] : ".";
	
	opendir ARCH,$folder  or  Logs::err("Couldn't open current directory",3);
	my @file=grep /$_[1]/, readdir ARCH;
	my @fileToRemove;
	foreach (@file) {
		push @fileToRemove, $_ unless (-M $_<$_[0] or -d $_);# -M gives how old is the file in days
	}
	unlink @fileToRemove;
}

################################################################################
# NAME: goForward subroutine
# CALL: ($hourStart,$dayStart,$monthStart,$yearStart)=&goForward($hour,$day
#       ,$month,$year,$hourForward)
# GOAL: return a date with the number of backing up hours forward added
#       to the initial value
################################################################################

sub goForward {
	my $hourStart=$_[0]+$_[4];
	#Logs::bug("in go Forward: receive @_",5);
	my ($dayStart,$monthStart,$yearStart)=($_[1],$_[2],$_[3]);
	# to find out what are the number of days in that month and to
        # take care about bisextil years
 	my @daysInMonth=(31,999,31,30,31,30,31,31,30,31,30,31);
 	if ($yearStart%4==0) { 
  		$daysInMonth[1]=29;
	} else {
   		$daysInMonth[1]=28;
	}
	# following code in case we changed day, month and/or year
	# hour goes from 00 to 23, day from 1 to 30/31, month 1 to 12
	if ($hourStart>23){
 		$hourStart=$hourStart-24;
 		$dayStart=$dayStart+1;
	}
	if ($dayStart==$daysInMonth[$monthStart-1]+1){ #monthStart-1 because in
		                                       #@daysInMonth, subscript
 		$monthStart=$monthStart+1;             #starts from 0
		if ($monthStart==13){ #because if it already 12 and we had 1
   			$monthStart=1;
   			$yearStart=$yearStart+1;
 		}
 		$dayStart=1;
	}#end if dayStart==0
	$hourStart=sprintf"%2.2d",$hourStart;
	$dayStart=sprintf"%2.2d",$dayStart;
	$monthStart=sprintf"%2.2d",$monthStart;
	$yearStart=sprintf"%4.4d",$yearStart;
	# Logs::bug("return ($hourStart,$dayStart,$monthStart,$yearStart)",5);	
	return ($hourStart,$dayStart,$monthStart,$yearStart);
} # end sub goForward

################################################################################
# NAME: copyFile
# CALL: $copyFile($oldName,$newName)
# GOAL: copy a file to another (because for some reasons the copy from
#       File::Copy doesn't work....)
################################################################################

sub copyFile{
	my ($oldName,$newName)=@_;
	my @old;
	tie @old, 'Tie::File', $oldName or Logs::err("array tie issue in copyFile\ncan't tie the array old with the corresponding file $oldName error: $!",3);
	open (NEW,">$newName") or Logs::err("opening file issue in copyFile\ncan't open the new file $newName error: $!",3);
	foreach (@old){
		print NEW "$_\n" or Logs::err("printing array old issue in copyFile\ncan't copy the array corresponding to the old file into the new file error: $!",3);
	}
	untie @old;
	close NEW; 
	Logs::bug("COPY\nThe file $oldName has been copied to $newName",5);
}

################################################################################
# NAME: renameFilesWithSuffix
# CALL: &renameFilesWithSuffix($suffix,$pattern)
# GOAL: rename a group of files matching a pattern with a given suffix after a given date
################################################################################

sub renameFilesWithSuffix {
	my ($suffix,$pattern)=@_;
	#0-FIX-1-04/26/05-to better handle error checking, in renameFileWithSuffix
	my $error=0;
	opendir(DIR, ".") or Logs::err("Directory opening issue\nCould'nt open the current directory :Error: $!\n",2);
	my  @filesToRename;
	@filesToRename=grep(/$pattern/,readdir(DIR));
	my $file;
	foreach $file (@filesToRename) {
		if ($file=~m/.gz/) { #if the file is zipped add suffix before .gz extension
        	$beg=$`;
			Logs::bug("try to rename $file to $beg.$suffix.gz",5);
        	rename ($file,"$beg.$suffix.gz") or $error=1;
   		} else {
            		#1-FIX-1-04/26/05-still to better handle error checking, in renameFileWithSuffix
            		rename ($file,"$file.$suffix") or $error=1;
        	}
		if ($error) {
			Logs::err("Error renaming file\nthe file $file has not been renamed with the date, error $!",3);
		} else {
			Logs::bug("The following file $file has been renamed with the suffix '$suffix'",5);
		}
	}
    	#err("The following files have been renamed with the suffix '$suffix'\n");
    	Logs::bug("in renaming file, the following:",5) if($test);
	&printArray(5,\@filesToRename) if ($test);
}
	
################################################################################
# NAME: &giveNextEntryLine
# CALL: &giveNextEntryLine($pattern,$oldLineNumber,$arrayName); where $pattern
#       is the pattern we have to find,$oldLineNumber tells the line to start
#       from (to avoid looking from the beginning) and $arrayName is the name
#       to search in
# GOAL: give the current line when a pattern match so that we know
#       in the calling program or subroutine where to act
################################################################################

sub giveNextEntryLine {
	local ($pattern,$iLine,$arrayA1)=@_;

	my $lastLine=(@$arrayA1-1);
	return -1 if($line>$lastLine || !defined($pattern));
	until ($$arrayA1[$iLine]=~m/$pattern/){
		if ($iLine>=$lastLine){
			return -1;
		}
		$iLine++;
	}
	return $iLine;
}

################################################################################
# NAME: &changeLine
# CALL: &changeLine($lineNum,$newValue,$arrayRef);
# GOAL: for a given array,change the line data given by the line number with
#       whereas the value given or execute a subroutine to find out the value to
#       replace with.
################################################################################

sub changeLine {
	local ($lineNum,$newValue,*arrayA2)=@_;
	if ($newValue=~m#/#){ #the string correspond to a reference
		my($subName,$arg1)=split/\//,$';
		#arg2 is optional, but if not here, it isn't an issue, just undef
		&$subName($arg1,$arg2);
	} else {
		$arrayA2[$lineNum]=$newValue;
	}
}

################################################################################
1;

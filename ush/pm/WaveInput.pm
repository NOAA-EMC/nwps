#!/usr/bin/env perl
# ----------------------------------------------------------- 
# PERL Script
# PERL Version(s): 5
# Original Author(s): Eve-Marie Devalire for WFO-Eureka 
# File Creation Date: 04/20/2004
# Date Last Modified: 08/26/2013 #To Process BC Locally
#
# Version control: 2.26
#
# Support Team:
#
# Contributors: Alex Gibbs, Tony Freeman, Pablo Santos, Douglas Gaer
# ----------------------------------------------------------- 
# ------------- Program Description and Details ------------- 
# ----------------------------------------------------------- 
#
################################################################################
#                               WaveInput package                              #
################################################################################
# This package takes care of processing the wave input for the SWAN model, that#
# is to say download the wave data and create corresponding files in a format  #
# understandable by the SWAN model.                                            #
# The files we download are in the WaveWatchIII model output format            #
################################################################################
#               The subroutines implemented here are the following:            #
################################################################################
##waveInputProcessing                                                          #
##createSwanBody                                                               #
##createSwanHeader                                                             #
##usefulValues                                                                 #
##checkSizeAndName                                                             #
##translate                                                                    #
##createTemp                                                                   #
##transformValues                                                              #
################################################################################
#                   The packages used are the following:                       #
################################################################################
#ArraySub                                                                      #
#CommonSub                                                                     #
#Tie::File                                                                     #
#POSIX                                                                         #
#File::Copy                                                                    #
#File::Basename                                                                #
################################################################################
# ----------------------------------------------------------- 

######################################################
#      Packages and exportation requirements         #
######################################################
package WaveInput;

# Setup our NWPS env
my $NWPSdir = $ENV{'HOMEnwps'};
my $DATA = $ENV{'DATA'};
my $siteid = $ENV{'siteid'};
my $SITEID = $ENV{'SITEID'};
my $ISPRODUCTION = $ENV{'ISPRODUCTION'};
my $DEBUGGING = $ENV{'DEBUGGING'};
my $DEBUG_LEVEL = $ENV{'DEBUG_LEVEL'};
my $WNA = $ENV{'WNA'};
my $MODELCORE = $ENV{'MODELCORE'};
my $LDMdir = $ENV{'LDMdir'};

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

use File::Copy;
use POSIX;
use Tie::File;
use File::Basename;
require Exporter;
@ISA=qw(Exporter);
@EXPORT=qw(waveInputProcessing $FTPPAT1 $FTPPAT1B $FTPPAT2 $NFTPATTEMPTS @WAVECPS);
use CommonSub qw(report giveDate ftp copyWaveFiles mvFiles removeFiles removeOldFiles 
copyFile giveNextEntryLine changeLine);
use ArraySub qw(takeUndefAway takeSpaceAway printArray printArrayIn formatArray
formatDoubleArray pushDoubleArray printDoubleArray takeSpaceAway giveMaxArray
giveMaxDoubleArray giveSumDoubleArray reverseDoubleArray);
use Archive qw(isRunFromArchive copyWavesFromArchive archiveFiles);
use Logs;
use ConfigSwan;
our $gtop;
our $FTPPAT1;
our $FTPPAT1B;
our $FTPPAT2;
our $NFTPATTEMPTS;
our @WAVECPS;
print " ========      WaveInput.pm     =========\n";
print " WNA:   $WNA \n"; 
# If we are using WW3 boundary conditions, load the WW3 FTP download configuration
if (($WNA eq "WNAWave") || ($WNA eq "HURWave")) {
    # Patterns used to retrieve wave files through ftp (e.g. nah.TAE51.spec)

	print "Using WW3 boundary conditions, load the WW3 FTP download configuration\n";
    my $infile_fp = open (INFILE, "${RUNdir}/wna_input.cfg");
    if( ! $infile_fp ){
	Logs::err("ERROR - Problem with WNA pre-processing cannot open ${RUNdir}/wna_input.cfg\n",2);
	print "ERROR - Problem with WNA pre-processing cannot open ${RUNdir}/wna_input.cfg\n";
    }
    
    # wna_input.cfg example below
    #
    # FTPPAT1:multi_1
    # FTPPAT1B:nah
    # FTPPAT2:TAE
    # NFTPATTEMPTS:3
    # WAVECPS:nah.TAE56.spec.swan,nah.TAE62.spec.swan,nah.TAE66.spec.swan,nah.TAE51.spec.swan.cp

    while (<INFILE>) {
	chomp;
	@inarray = split(/:/, $_);
	if($inarray[0] eq 'FTPPAT1') {
	    $FTPPAT1 = $inarray[1];
	}
	if($inarray[0] eq 'FTPPAT1B') {
	    $FTPPAT1B = $inarray[1];
	}
	if($inarray[0] eq 'FTPPAT2') {
	    $FTPPAT2 = $inarray[1];
	}
	if($inarray[0] eq 'NFTPATTEMPTS') {
	    # The number of times the script will attempt to ftp and unzip files before quitting
	    $NFTPATTEMPTS = $inarray[1];
	}
	if($inarray[0] eq 'WAVECPS') {
	    # Wave files that need to be copied for SWAN to run (specified in outer domain command file)
	    # These files represent corners of the wave boundries and so are used twice, once for each
	    # edge connected to the corner.
	    @WAVECPS = split(',', $inarray[1]);
	}
    }
    close (INFILE); 
    
    # NOTE: The following lines are for testing only
    ##print $FTPPAT1 ."\n";
    ##print $FTPPAT1B ."\n";;
    ##print $FTPPAT2 ."\n";;
    ##print $NFTPATTEMPTS ."\n";;
    ##use Data::Dumper;
    ##print Dumper @WAVECPS;
    
    if(  $FTPPAT1 eq "" ){
	Logs::err("ERROR - Problem with WNA pre-processing FTPPAT1 is not set in ${RUNdir}/wna_input.cfg\n",2);
    }
    if(  $FTPPAT1B eq "" ){
	Logs::err("ERROR - Problem with WNA pre-processing FTPPAT1B is not set in ${RUNdir}/wna_input.cfg\n",2);
    }
    if(  $FTPPAT2 eq "" ){
	Logs::err("ERROR - Problem with WNA pre-processing FTPPAT2 is not set in ${RUNdir}/wna_input.cfg\n",2);
    }
    if(  $NFTPATTEMPTS eq "" ){
	Logs::err("ERROR - Problem with WNA pre-processing NFTPATTEMPTS is not set in ${RUNdir}/wna_input.cfg\n",2);
    }

    my $num_wavecps = 0;
    foreach my $val (@WAVECPS) {
	$num_wavecps = $num_wavecps + 1;
    }
    if( $num_wavecps < 1) {
	Logs::err("ERROR - Problem with WNA pre-processing WAVECPS is not set in ${RUNdir}/wna_input.cfg\n",2);
    }
}


######################################################
#                    Subroutines                     #
######################################################

################################################################################
# NAME: &waveInputProcessing
# CALL: &waveInputProcessing()
# GOAL: This is the subroutine equivalent to the main. It is responsible for
#       taking care of archiving, download the wave data file, processing thoses
#       one by one and finally moving the resulting files to the right place.
################################################################################
sub waveInputProcessing {
    my $NWPSdir = $ENV{'HOMEnwps'};
    Logs::bug("begin waveInputProcessing",1);
    my $nftpAttempts = $NFTPATTEMPTS;

print "+++++++++++++++++++ waveInputProcessing  +++++++++++++++\n";
print "NWPSdir : $NWPSdir\n";
print "INPUTdir : ${INPUTdir}\n";
print "LDMdir & INPUTdir:  $LDMdir & $INPUTdir\n";


    chdir("${INPUTdir}/wave") or Logs::err("Could'nt change directory to ${INPUTdir}/wave :$!",10);

    # NOTE: If this function is called you must have the following variables set
    if(  $FTPPAT1 eq "" ){
	Logs::err("ERROR - Problem with WNA pre-processing FTPPAT1 is not set in ${RUNdir}/wna_input.cfg\n",2);
    }
    if(  $FTPPAT1B eq "" ){
	Logs::err("ERROR - Problem with WNA pre-processing FTPPAT1B is not set in ${RUNdir}/wna_input.cfg\n",2);
    }
    if(  $FTPPAT2 eq "" ){
	Logs::err("ERROR - Problem with WNA pre-processing FTPPAT2 is not set in ${RUNdir}/wna_input.cfg\n",2);
    }

    $ftpPattern1=$FTPPAT1;
    $ftpPattern1Bis=$FTPPAT1B;
    #removes the spec files older than 1 week (arbitrary value can be changed)
    &removeOldFiles(NDAYSARCHIVE,$FTPPAT1);
    my $list;
    my @tau=('18','12','06','00');
    my $z='z';
    my @time=localtime(time);
    my $time;
    my $backup;
#  TIME: foreach $i (0 .. 1)
#  {
#      #will first call it for today and then for yesterday if no data has been found
#      $time=&formatDate(@time,$i);
#      foreach my $t (@tau)
#      {
#	  $backup=1;
#	  $list=&ftp("ftpprd.ncep.noaa.gov","/pub/data/nccf/com/wave/prod/wave.$time/bulls.t$t$z",${FTPPAT1},"spec",${FTPPAT2});
#	  last TIME unless ($list==0);
#      }
#  }

    $list=&copyWaveFiles("$LDMdir/wna","$INPUTdir/wave","$FTPPAT1"); 
    $backup=1;

# AG added for archiving multi* WW3 boundary files before reformatted for swan:
    ##RPsystem("cp ${INPUTdir}/wave/* /tmp");

# FOR WW3
    if ($MODELCORE eq "WW3") {
#XXXXXXXXXXXXXXXXXXXXXXXXXXXXX
#       system("cp ~/data/BOUND_DATA_FOR_WW3/bcdata/* ${INPUTdir}/wave/ ");
       my $directory = "${INPUTdir}/wave";
#       print "======== directory for wave BC: $directory ======== \n";
       opendir (DIR, $directory) or die $!;
# making the input file for ww3_bound.exe
       open my $out, '>', "${RUNdir}/ww3_bound.inp" or die "Can't open new file: $!";
       my $fileHeader=<<END;
\$ boundary option: READ or WRITE
WRITE 
\$ Interpolation method. 1: nearest, 2: linear interpolation
2 
\$ Type of spectra files: 'A' for ASCII and 'N' for NetCDF (this option 
\$                                           is not yet implemented) 
A
\$ list of spectra files. These ASCII files use the WAVEWATCH III format
\$
END
       print $out "$fileHeader";
       while (my $filespc = readdir(DIR)) {
          next if $filespc =~/^[.]/;
#          print "$filespc\n";
          print $out "$filespc\n";
       }
       my $fileBottom=<<END;
'STOPSTRING'
\$ 
END
       print $out "$fileBottom";
       closedir(DIR);
       close $out;
       system("pwd");
        system("ls -lt");    
        system("mv -f * ${RUNdir}/ ");
    }else{
    Logs::bug("list: $list \n",1);
    if ($list)
    {
	foreach (@$list)
	{
	    if ($backup==1)
	    {
		my $file=$_;
		($header,$date,$freqRef,$dirRef,$spectraFrom)=&usefulValues($file);
		&checkSizeAndName($file);
		@freq=@$freqRef;
		$nFreq=@freq;
		@dir=@$dirRef;
		$nDir=@dir;
		&translate($file);
		system "gzip -f $_";
		#`cp -vfp $_.gz ${ARCHdir}/pen/$_.gz`;
	    }
	    else
	    {
                # This portion of the code needs revision. We no longer archive reformated BCs"
		print "*******************$_**************************";
		$_=~/.gz/;
		my $file=$`;
		`cp -vfp $_ ${ARCHdir}/$_`;
		print "my file=$file\n";
		system "gunzip $_";
		($header,$date,$freqRef,$dirRef,$spectraFrom)=&usefulValues($file);
		&checkSizeAndName($file);
		@freq=@$freqRef;
		$nFreq=@freq;
		@dir=@$dirRef;
		$nDir=@dir;
		&translate($file);
	    }
	}
    }
    
    foreach my $wavecp (@WAVECPS)
    {
	&copyFile($wavecp,"$wavecp.cp");
    }
    } #swan or ww3 closing if 
    
    chdir "${INPUTdir}/wave/";
    #move the processed files to ${RUNdir}
    &mvFiles("${RUNdir}/","swan");
    #clear the directory
    &removeFiles("spec","${INPUTdir}/wave/");
    &removeFiles("dat","${INPUTdir}/wave/");
    Logs::bug("end waveInputProcessing",1);
}

################################################################################
# NAME: checkSizeAndName subroutine
# CALL: &checkSizeAndName($size,$header,$date) where size is the size of the
#       file we are dealing with, header is the first file line (to check file
#       is ok) and date the first one to appear in the file(which will give the
#       name)
# GOAL: check the size of the file and rename the corresponding file depending
#       on when it was created
################################################################################

sub checkSizeAndName {     
	Logs::bug("begin checkSizeAndName: ",10);
	my $size=-s($_[0]);
	if ($size<100000){
		Logs::err("Problem with WW3 file size\nThe WW3 file $_[0] is smaller than 100000 bytes ($size) which is less than 1/4 of its usual size. You'd better check that out",3);
	}
	#shouldn't arrive/ if does frequently should plan a special treatment
	if ($header eq "/'WAVEWATCH III SPECTRA/'"){
		Logs::err("Pb with WW file header\nThe WW3 file $_[0] doesn't start with 'WAVEWATCH III SPECTRA', there might be issues with it, please check it out",3);
	}
	my ($date,undef,$hour,$min)=unpack"A8 A A2 A2",$date;
	my (undef,undef,$actualHour)=&giveDate();
	#because of the jet lag
	$actualHour=($actualHour+JETLAG)%24;
	#to check the file is the most recent one
	if ($actualHour-$hour>6){
		Logs::err("Not most recent file\nThe file $_[0] is not the most recent one. It is $actualHour and the last hour available is $hour (day:$date)",3);
	}
	my $oldFile=$_[0].".gz";
	my ($name,$path,$suffix) = fileparse($oldFile,"\.gz");
	Logs::bug("end checkSizeAndName: ",10);
}

################################################################################
# NAME: usefulValues
# CALL: &usefulValues($file)
# GOAL: return important values whiwh are in the header of the file (date,@freq,@dir...
################################################################################

sub usefulValues {
	Logs::bug("begin usefulValues: for the file $_[0]",1);
	open (FILE, "$_[0]");
	# note that setting $\ to undef could have been done to work on the file as one long string
        #the last field contains the values we want to have(because it considers the whole line)
	my @header=split / /,<FILE>,4;
	my $ww3Header=join ' ',$header[0],$header[1],$header[2];
	my $string=$header[-1];#I take the value of the last array entry
	$string =~ /\s+(\d+)\s+(\d+)\s+(\d+)\s+/;#as there are spaces, I take each variable independently
	my ($nFreq,$nDir,$nloc)=($1,$2,$3);
	my $spectraFrom=$';
	chomp $spectraFrom;
	if ($nloc!=1) {
		Logs::err("Problem with loc value\nin WW3 file $_[0] nloc is not equal to 1 but to $nloc! This script assumes one loc per file and converts one ww3 file to one swan file. Please check that out!",3);
	}
	my $line=<FILE>;
        chomp $line;
	my @freq;#array of frequencies
	my @dir;#array of directions
	#I put the values in the array because if I just count the number of variables,
        #I am one line further without values...
        @freq=split /\s/,$line;
        my $x;#just a counter
	&takeUndefAway(\@freq);
	my $nFreqOnLine=@freq;
	my $nFreqLines=ceil($nFreq/$nFreqOnLine);
	while ($nFreqLines>1) {
		$line=<FILE>;
                chomp $line;
		@freq=(@freq,split /\s/,$line,($nFreqOnLine+1));
		$nFreqLines--;
	}
	&takeUndefAway(\@freq);
	#same thing with directions (following data in file)
	$line=<FILE>;
	chomp $line;
	@dir=split /\s\s/,$line;                                                                                                    
	&takeUndefAway(\@dir);#once to have the right number of dir on one line
	my $nDirOnLine=@dir;
        my $nDirLines=ceil($nDir/$nDirOnLine);
        while ($nDirLines>1) {
		$line=<FILE>;
		chomp $line;
                # "+1" not to have the spaces left on the last line value
                @dir=(@dir,split /\s\s/,$line,($nDirOnLine+1));
                $nDirLines--;
	}	                                                                                                    
 	&takeUndefAway(\@dir);
	$pi=atan2(1,1)*4;
	for ($x=0; $x < @dir; $x++){
		#conversion from oceanographic (WW3) to meteorologic (consistent with SWAN)
		$dir[$x]=$dir[$x]*180/$pi-180;
		if ($dir[$x] <= 0) { #NB DIAGNOSTIC...convert neg to pos degress
			$dir[$x]+=360;
		} 
	}
	my $date=<FILE>;
	close FILE;
	Logs::bug("end usefulValues: for file $_[0]",1);
	return ($ww3Header,$date,\@freq,\@dir,$spectraFrom);                                                                 
}

################################################################################
# NAME: &translate
# CALL: &translate(file,freqArrayRef,dirArrayRef,date)with date the first date
#       and time treated in the file
# GOAL: translate the file .spec (WW3 output) into a .swan recognizable
#       by the swan model. It also do some checking
################################################################################

sub translate {
 	Logs::bug("begin translate: $_[0]",1);
	##create new array with the frequency differences
	my @freqDiff;
	$freqDiff[0]=$freq[1]-$freq[0];
	$freqDiff[$nFreq-1]=$freq[$nFreq-1]-$freq[$nFreq-2];
	my $i;
	my $pi=atan2(1,1)*4;
	my $dirDiff=(360/$nDir)*($pi/180); #NB Comment: Shouldn't this be calculated in the same way as freqDiff, i.e., $dirDiff[i]=$Dir[i+1]-$Dir[i] ?

	for ($i=1;$i<($nFreq-1);$i++){
		$freqDiff[$i]=($freq[$i+1]-$freq[$i-1])/2;
	}
	##################NB  TRY THIS####################################	
	#print "\n\n\nEKA$file\n";	
        #$dirDiff2[0]=$dir[1]-$dir[0];
        #$dirDiff2[$nDir-1]=$dir[$nDir-1]-$dir[$nDir-2];	
	#for ($i=1;$i<($nDir-1);$i++){
        #        $dirDiff2[$i]=(($dir[$i+1]-$dir[$i-1])/2)*($pi/180);
        #        print "\ndirDiff2= ".$dirDiff2[$i].", dirDiff= ".$dirDiff."\n";
        #}
	##################################################################

	# record array contains the content from the file with one row corresponding to one line
	my @record;
	open (WAVE,$_[0]) or Logs::err("issue opening file $_[0], error:$!",2);
	@record=<WAVE>;
	#Logs::err("\n$record[0]\n",3);
	close WAVE;
	push @record, " ";
	local $ftpPat2=$FTPPAT2;
	push @record,"\n\'$ftpPat2";
	my $iLineRecord=0;
	my $first;
	# here I don't keep track of the record, it is just to reach the first one
        ($first,$iLineRecord)=&giveNextRecord($iLineRecord,@record);
	#Logs::err("\n\n\nfirst= $first, \n\n\n iLineRecord= $iLineRecord\n\n\n",3);
 
        my $iFreq;
	my $iDir;
	#sort the directions array in ascending order directions
	#{$a<=>$b;} is needed to indicate that the sort has to be done on numeric value (alphabatically by default)
	@sortedDir=sort {$a<=>$b;}  @dir; 

	&formatArray('%20.10f',\@sortedDir);
	&formatArray('%20.10f',\@dir);
	my $iRecord=0;#number of records in one file 
	our $q=0;
	#create and open the swan file in writting
	SPECTRUM: for (;;){ 
		#create an infinite loop to treat each spectrum contained in the file. The loop stops because of the 'last' command
		my $line;
		$line=$record[$iLineRecord];
		#Logs::err("\nInside SPECTRUM loop\n\n\n",3);
                #Logs::err("\n\n\nline = $line\n\n\n",3);
		my ($date,$blah,$hour,$min)=unpack"A8 A A2 A2",$line;
		#Logs::err("date = $date \n blah = $blah \n undef = $undef\n hour = $hour \n min = $min \n\n\n",3);
		#Logs::err("specDate = ($date + ($hour / 100))\n\n\n",3);
		$specDate=($date + ($hour / 100));
		#Logs::err("SPECDATE = $specDate\n\n\n",3);
		
		if ( $min != 0 ) {
			Logs::err("Pb with WW3 file date\nMinutes in the WW3 file $_[0] are not equal to 0 but to $min. You  need to generalize code more\n\n\n",3)
		}
		$line=$record[$iLineRecord+1];#the next line is the locStr
		chomp $line;
		$locStr=$line;
		my $recordString;
		($recordString,$iLineRecord)=&giveNextRecord($iLineRecord+2,@record);
		my $iTime=0;#number of time we create a temp array
		while ($iTime!=($nDir)){
			my $tempRef;
			($recordString,$tempRef)=&createTemp($recordString,$iTime);
			push @freqDirArray, $tempRef;
			$iTime++;#last line
		}
		my ($maxFreqDirArray,$iMax,$jMax)=&giveMaxDoubleArray(\@freqDirArray);	
		if ($maxFreqDirArray<1E-15){
			$freqDirArray[0][0]=1E-15;
		}
		my $freqPeak0=$freq[$jMax];
		my $dirPeak0=$dir[$iMax];
		#print "\n".$freqPeak0.", ".$dirPeak0; #NB DIAGNOSTIC
		my $variance=0;
		for $i (0 .. $#freqDirArray){
			for $j (0 .. $#{$freqDirArray[$i]}){
				$variance=$variance+$freqDirArray[$i][$j]*$dirDiff*$freqDiff[$j];
			}
			my $ef=&giveSumDoubleArray(\@freqDirArray)*$dirDiff;
		}
		$hmO=4*sqrt($variance);
		# construct @sortedFreqDir from @freqDirArray with the directions in ascending order
		foreach $i (0 .. $#dir){
			foreach $j (0 .. $#dir){
				if ($sortedDir[$j]==$dir[$i]){
					my @line=@{$freqDirArray[$i]}[0 .. $#freq];
					$sortedFreqDir[$j]=[@line];
				}
			}
		}
		# create @etOld and @etNew (since we are not making plots this part is pretty unuseful)
		my @etOld;
		my @etNew;
		foreach $i (0 .. $#dir){
			$etOld[$i]=0;
			$etNew[$i]=0;
			foreach $j (0 .. $#freq){
				$etOld[$i]=$etOld[$i]+$freqDirArray[$i][$j]*$freqDiff[$j];
				$etNew[$i]=$etNew[$i]+$sortedFreqDir[$i][$j]*$freqDiff[$j];
			}
		}
			
		# following code check if the spectrum peaks are ok
		(undef,$iMax,$jMax)=&giveMaxDoubleArray(\@sortedFreqDir);
		my $fPeak=$freq[$jMax];
		$dirPeak=$sortedDir[$iMax];
		$periodPeak=1/$fPeak;
		if ($fPeak!=$freqPeak0){ 
			Logs::run("peak freq issue in WaveInput.pm"); 
			# Colin 2007-05-20 actually, this does happen, but we aren't sure why
			# I've commented out this warning because the boundary conditions work
			# to our satisfaction and the peak issue only pops up at a couple of 
			# points.
			Logs::err("Peak issue: fPeak=$fPeak and fPeak0=$freqPeak0",3);
		}
		(undef,$iDir)=&giveMaxArray(\@etOld);
		my $dirPeakOld=$dir[$iDir];
		(undef,$iDir)=&giveMaxArray(\@etNew);
		my $dirPeakNew=$sortedDir[$iDir];
		if ($dirPeakOld!=$dirPeakNew){ #should never happen
			print "\npeak dir issue\n";
			 Logs::err("Peak issue: dirPeak=$dirPeak; dirPeak0=$dirPeak0 ; dirPeakOld=$dirPeakOld and dirPeakNew=$dirPeakNew",3);
		}
		$q++;
		&createSwanHeader if ($iRecord==0);
		&createSwanBody;	
		$iRecord++;
		
		undef @sortedFreqDir;
		undef @freqDirArray;
		
		#'-1' because of the flag I put at the end
		last SPECTRUM if ($iLineRecord==($#record-1));
	}
	
	#create and open the swan file in writting
	my $swanFile=$_[0].".swan";
	print "file for SWAN was:$swanFile\n";
		
	$swanFile=~s/$ftpPattern1/$ftpPattern1Bis/;
	print "file for SWAN now is:$swanFile\n";
	open (SWAN, ">$swanFile");
	&printSwanArray(1,@swanHeader);
	&printSwanArray(2,@swan);
	#&printDoubleArray(\@swan);#to have it in the report file
	close SWAN;
	undef @swanHeader;
	undef @swan;
	Logs::bug("end translate: $_[0]",1);
}

################################################################################
# NAME: &giveNextRecord
# CALL: &giveNextRecord(lineNum,@array)
# GOAL: gives a string with the data set to put in the freqDirArray,
#       returns also a number of line to indicate to the function calling what
#       is the line number it has to start with (in our case:the date line)
################################################################################

sub giveNextRecord {
	my $line;
	my $iLine;
	my $recordString;
	my ($startLine,@record)=@_;
	$pattern="\'$ftpPat2";
	$iLine=$startLine;
	until ($record[$iLine]=~m/$pattern/){ #to find which line number is the line with 'EKA'
		$iLine++;
	}	
	#we want the record until the end of the data set which is 2 lines before the 'EKA' line
        my $nLine=$iLine-2;
        foreach $iLine ($startLine .. $nLine) {
		$line=$record[$iLine];
		chomp $line;
		$recordString.=$line;
	}				
	#return the string with the data set and the num of the line containing the date
	return ($recordString,$nLine+1);
}

################################################################################
# NAME: &createTemp
# CALL: &createTemp($record,$iTime)
# GOAL: create the temp array which is used to create the freqDirArray because
#       multidimentional array don't exist as a type in perl, it is an array of
#       array
################################################################################

sub createTemp {
	my $record=$_[0];
	my $iTime=$_[1];
	my @temp;
	my $maxTemp=1;
	TEMP: while ($maxTemp!=($nFreq)) {
		push(@temp,split /\s+/,$record,2);#I could take more than 2 but
                #this way it contruct the array cell after cell and it would be
                #always ok depending on the number of frequencies
		&takeUndefAway(\@temp);#to avoid having empty cells
		last TEMP if (($maxTemp==($nFreq-1) && $iTime==($nDir-1)));
		$record=pop @temp;#the record left to analyse is in the last cell
		$maxTemp=@temp;
	}
	&takeSpaceAway(\@temp);
	return ($record,\@temp);
}

################################################################################
# NAME: createSwanHeader
# CALL: createSwanHeader()
# GOAL: create the swan file header for this wave data.
################################################################################

sub createSwanHeader {	
        #Logs::bug("begin creatingSwanHeader",1);
	push @swanHeader, ("SWAN   1                                Swan standard spectral file, version");
	push @swanHeader, ("\$   Data produced by SWAN version  40.X");
	push @swanHeader, ("\$ SPECTRA FROM $spectraFrom");
	push @swanHeader, ("\$ WW3 INFO (first record) : $locStr");
	my $str=sprintf "\$ Hm0 = %2.4f , Tpeak = %2.4f , thetap = %2.4f",$hmO,$periodPeak,$dirPeak;
	push @swanHeader, ($str);
	push @swanHeader, ("TIME                                    time-dependent data");
	push @swanHeader, ("     1                                  time coding option");
	push @swanHeader, ("LONLAT                                  locations in spherical coordinates");
	push @swanHeader, ("     1                                  number of locations");
	# in Erick's code it was written SWAN does not use this value. However I prefer to put it in case it takes account of line numbers or smth, and it would be nore general!
	my $coordonateValue=$locStr;
	$coordonateValue=~/\S+\s+\S+\s+(\S+\s+\S+)\s/;
	$coordonateValue=$1;
	push @swanHeader, ("$coordonateValue");
	push @swanHeader, ("AFREQ                                   absolute frequencies in Hz");
	$str=sprintf "%8d",$nFreq;
	push @swanHeader, ("$str                                 number of frequencies");
	&formatArray('%10.4f',\@freq);
	push @swanHeader,@freq;
	push @swanHeader, ("NDIR                                    spectral Nautical directions in degr");
	$str=sprintf "%8d                                  number of directions",$nDir;
	push @swanHeader, ($str);
	push @swanHeader,@sortedDir;
	push @swanHeader, ("QUANT");
	push @swanHeader, ("     1                                  number of quantities in table");
	push @swanHeader, ("VaDens                                  variance densities in m2/Hz/degr");
	push @swanHeader, ("m2/Hz/degr                              unit");
	push @swanHeader, ("   -0.9900E+02                          exception value");
        #Logs::bug("end createSwanHeader",1);
}

################################################################################
# NAME: createSwanBody
# CALL: createSwanBody()
# GOAL: create the boby part of the swan file corresponding to the data for each
#       spectrum
################################################################################

sub createSwanBody {
	#Logs::bug("begin createSwanBody",10);
	&transformValues();
	my (@header1,@header2,@header3);
	$str=sprintf "%12.6f",$specDate;
	push @header1, ($str);
	push @header2, ('FACTOR');
	$str=sprintf "%10.8e",$factor; #NB DIAGNOSTIC ...increase # of decimals from 5 to 8
	push @header3, ($str);
	#as we have a multidimensional array for swan which is an array of references
        #we create this header array containing a ref to eacg of the 3 header lines
        my @header=(\@header1,\@header2,\@header3);
        &pushDoubleArray(\@swan,\@header,2);
	&formatDoubleArray("%4d",\@swanData);  #NB DIAGNOSTIC ...try without rounding variance densities to integers
	# The data in swan data need to be reverse so that we print it as
        #excpected by the swan model
	$swanDataRef=&reverseDoubleArray(\@swanData);
	@swanData=@$swanDataRef;
	&formatDoubleArray("%4d",\@swanData);  #NB DIAGNOSTIC ...try without rounding variance densities to integers
	&pushDoubleArray(\@swan,\@swanData,2);
	#************************************************************************************
	undef @swanData;;
	undef @header;
	#Logs::bug("end createSwanBody",10);
}

################################################################################
# NAME: transformValues
# CALL: transformValues()
# GOAL: some values have to be transformed before we can insert them in the swan
#       file
################################################################################


sub transformValues {
	for $i (0 .. $#sortedFreqDir) {
		for $j (0 .. $#{$sortedFreqDir[$i]}) {
			$sortedFreqDir[$i][$j]=$sortedFreqDir[$i][$j]*($pi/180);

		}
	}
	my($max,undef,undef)=&giveMaxDoubleArray(\@sortedFreqDir);
#	print "\nMax=".$max."\n";   #NB DIAGNOSTIC ONLY
	$factor=($max/990);#check which one I use
	for $i (0 .. $#dir) {
		for $j (0 .. $#freq) {
			my $valueToRound=$sortedFreqDir[$i][$j]/$factor;
			$swanData[$i][$j]=$valueToRound;
		}
	}
	$factor=sprintf "%.8f",$factor;
	($max,undef,undef)=&giveMaxDoubleArray(\@swanData);
	$max=sprintf "%4.f",$max;
	if ($max!=990){
                Logs::err("swanData's max is different from 990, it is equal to $max, you'd better check that",3);
	}
}

################################################################################
# NAME: printSwanArray
# CALL: &printSwanArray(@array) this sub is here ans not in ArraySub because
#       it is specific to the wave treatment
# GOAL: print an array in the swan file depending on the dimension of the array
################################################################################

sub printSwanArray {
	#Logs::bug("begin printSwanArray",1);
	my ($i,$j);
	my ($dim,@array)=@_;
	if ($dim==2) {
		for $i (0 .. $#array) {
               		for $j (0 .. $#{$array[$i]}) {
                       		print SWAN "$array[$i][$j] ";
			}
			print SWAN "\n";
		}
	}elsif ($dim==1){
		foreach (@array) {
			print SWAN "$_\n";
		}
	}
        #Logs::bug("end printSwanArray",1);
}
##################################################################################
# NAME: formatDate
# CALL: &formtDate($flag) 
# GOAL: get the date formatted, if flag == 1 get yesterday date
################################################################################
sub formatDate {
	my $flag=pop;
	my $second = $_[0];
	my $minute = $_[1];
	my $hour = $_[2];
	my $day = $_[3];
	$day=$day-1 if ($flag==1);#if it runs just after midnight
	my $month = 1+$_[4];
	my $year = $_[5]+1900;
	my $time=sprintf"%2d%2d%2d",$year,$month,$day;
	$time =~ s/ /0/g;
	return ($time);
}
################################################################################
1;

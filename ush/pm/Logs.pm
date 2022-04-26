#!/usr/bin/env perl
# ----------------------------------------------------------- 
# PERL Script
# PERL Version(s): 5
# Original Author(s): Eve-Marie Devalire for WFO-Eureka 
# File Creation Date: 04/20/2004
# Date Last Modified: 11/15/2014
#
# Version control: 2.24
#
# Support Team:
#
# Contributors: Alex Gibbs, Tony Freeman, Pablo Santos, Douglas Gaer
# ----------------------------------------------------------- 
# ------------- Program Description and Details ------------- 
# ----------------------------------------------------------- 
#
# Logging module
#
# ----------------------------------------------------------- 

package Logs;

use ConfigSwan;
use Data::Dumper;
our ($rlog,$elog,$blog);

#for_WCOSS
#codelogspm01
my $NWPSdir = $ENV{'HOMEnwps'};
my $DATA = $ENV{'DATA'};
my $ISPRODUCTION = $ENV{'ISPRODUCTION'};
my $DEBUGGING = $ENV{'DEBUGGING'};
my $DEBUG_LEVEL = $ENV{'DEBUG_LEVEL'};
my $NWPSplatform = $ENV{'NWPSplatform'};

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

if((${NWPSplatform} eq 'WCOSS') || (${NWPSplatform} eq 'DEVWCOSS')) {
    my $infoFile02 = "${RUNdir}/info_to_nwps_coremodel.txt";
    open IN, "<$infoFile02"  or die "Cannot open: $!";
    our ($NWPSdir, $DEBUGGING, $DEBUG_LEVEL, $BATHYdb, $SHAPEFILEdb, $ARCHdir);
    our ($DATAdir, $LOGdir, $VARdir, $OUTPUTdir, $RUNdir, $TMPdir, $RUNLEN);
    our ($NESTS, $RTOFS, $ESTOFS, $WEB, $PLOT, $MODELCORE, $LOGdir, $SITEID);
    our ($WNA, $WINDS, $INPUTdir, $ISPRODUCTIO, $DATAdir, $siteid, $GEN_NETCDF);
    our ($USERDELTAC);
    
    my $ndata=0;
    while (<IN>) {
	$ndata+=1;
	chomp($_);
	if ($ndata ==1) {
	    $NWPSdir=$_;
	}
	if ($ndata ==2) {
	    $ISPRODUCTIO=$_;
	}
	if ($ndata ==3) {
	    $DEBUGGING=$_;
	}
	if ($ndata ==4) {
	    $DEBUG_LEVEL=$_;
	}
	if ($ndata ==5) {
	    $BATHYdb=$_;
	}
	if ($ndata ==6) {
	    $SHAPEFILEdb =$_;
	}
	if ($ndata ==7) {
	    $ARCHdir=$_;
	}
	if ($ndata ==8) {
	    $DATAdir=$_;
	}
	if ($ndata ==9) {
	    $INPUTdir=$_;
	}
	if ($ndata ==10) {
	    $LOGdir=$_;
	}
	if ($ndata ==11) {
	    $VARdir=$_;
	}
	if ($ndata ==12) {
	    $OUTPUTdir=$_;
	}
	if ($ndata ==13) {
	    $RUNdir=$_;
	}
	if ($ndata ==14) {
	    $TMPdir=$_;
	}
	if ($ndata ==15) {
	    $RUNLEN=$_;
	}
	if ($ndata ==16) {
	    $WNA=$_;
	}
	if ($ndata ==17) {
	    $NESTS=$_;
	}
	if ($ndata ==18) {
	    $RTOFS=$_;
	}
	if ($ndata ==19) {
	    $ESTOFS=$_;
	}
	if ($ndata ==20) {
	    $WINDS=$_;
	}
	if ($ndata ==21) {
	    $WEB=$_;
	}
	if ($ndata ==22) {
	    $PLOT=$_;
	}
	if ($ndata ==23) {
	    $SITEID=$_;
	    $siteid= lc $SITEID;
	}
	if ($ndata ==24) {
	    $MODELCORE=$_;
	}
	if ($ndata ==25) {
	    $GEN_NETCDF=$_;
	}
	if ($ndata ==26) {
	    $USERDELTAC=$_;
	}
    }
    close IN;

#print "$NWPSdir, $ISPRODUCTIO, $DEBUGGING, $DEBUG_LEVEL, $BATHYdb, $SHAPEFILEdb, $ARCHdir\n";
#print "$DATAdir, $INPUTdir, $LOGdir, $VARdir, $OUTPUTdir, $RUNdir, $TMPdir, $RUNLEN, $WNA\n";
#print "$NEST, $RTOFS, $ESTOFS, $WINDS, $WEB, $PLOT, $MODELCORE, $LOGdir, $SITEID, $DATAdir\n";
#print "$GEN_NETCDF\n";
#
}

$SIG{__WARN__}=sub{ warn @_ unless $_[0]=~/Use of uninitialized value/};

sub initialize {
  my $path = PATH;
  open RLOG, ">${LOGdir}/runlog.log" or die "${LOGdir}/runlog.log - $!";
  $rlog = \*RLOG;
  open ELOG, ">${LOGdir}/errlog.log" or die "${LOGdir}/errlog.log - $!";
  $elog = \*ELOG;
  open BLOG, ">${LOGdir}/buglog.log" or die "${LOGdir}/buglog.log - $!";
  $blog = \*BLOG;
}

################################################################################
# NAME: run
# CALL: Logs::run($message,$flag);
# The flag can be equal to:
# 1 :write in report,
# 2 :write in report, in error log and die, in case the program can't run
#   anymore if that happens,
# 3 :write in report and in error file but doesn't die, it means that something
#   unusal happen but the program can still run
# GOAL: create a report and an error log file at the same time while the program
# is running. These files would be send to the related persons at the end of the
# run. Those files are opened and close in the main program, not to loose time
# with opening/closing them each time ther is something to print
################################################################################

sub run{
	our ($rlog);
	my $message=shift;
	my($tmstmp) = time_stamp();
	if(!caller(1)){
		$line = (caller(0))[2];
		$callingfn =  "Main (line $line)";
	}else{
		($package,$filename,$line,$subr)=caller(1);
		$callingfn = "$package::$subr (line $line)";
	}
   	writefile($rlog,">> ".substr($tmstmp,0,-7)."  $callingfn\n$message\n");
   	writefile($blog,">> $tmstmp  $callingfn\n$message\n");
	print ">> ".substr($tmstmp,0,-7)."  $callingfn\n$message\n\n"; 
}

sub err{
        our ($rlog,$elog);
        my $message=shift;
        my $flag=shift;
        my($tmstmp) = time_stamp();
        if(!caller(1)){
                $line = (caller(0))[2];
                $callingfn =  "Main (line $line)";
        }else{
                ($package,$filename,$line,$subr)=caller(1);
                $callingfn = "$package::$subr (line $line)";
        }
	$warnORerr = ($flag==3) ? "Warning:" : "Error:";
	writefile($rlog,">> $warnORerr ".substr($tmstmp,0,-7)."  $callingfn\n$message\n");
	writefile($elog,">> $warnORerr ".substr($tmstmp,0,-7)."  $callingfn\n$message\n");
	if ($flag==2){
	    `touch ${OUTPUTdir}/netCdf/not_completed`; 
	    die "$message";
	}
}


sub bug{
        our $blog;
	my $message=shift;
        my $level=shift;
	my ($package,$filename,$line,$subr);
	foreach $debug (@ConfigSwan::DEBUG) {
		if( ($debug>0 && $level==1) || ($debug==2) || ($debug==$level)){
	        	my($tmstmp) = time_stamp();
			if(!caller(1) && $level<=$debug){
                		$line = (caller(0))[2];
				writefile($blog,">>$tmstmp  Main (line $line)\n$message\n");
			}else{ 
				($package,$filename,$line,$subr)=caller(1);
				$line = (caller(0))[2]; 
				writefile($blog,">>$tmstmp  $package::$subr (line $line)\n$message\n");
			}
		}
		if ($level==1) {last};
	}
}

sub writefile {
	my $self = shift;
	my $text = shift;
	#my $SAVEHND = select $$self;
	my $SAVEHND = select $self;
	$|=1; # Flushes the output buffer
	print  $text, "\n";
	select  $SAVEHND;
}

sub time_stamp {
    my ($d,$t,$us);
    my $secs = `date +%s`;
    my $usecs = `date +%6N`;
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$wsdst) = localtime($secs);
    $year += 1900;
    $mon++;
    $d = sprintf("%4d-%2.2d-%2.2d",$year,$mon,$mday);
    $t = sprintf("%2.2d:%2.2d:%2.2d",$hour,$min,$sec);
    $us = sprintf("%6.6d",$usecs);
    return "$d $t.$us";
}

################################################################################
1;

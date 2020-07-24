#!/usr/bin/perl
# ----------------------------------------------------------- 
# PERL Script
# PERL Version(s): 5
# Original Author(s): Roberto Padilla-Hernandez 
# File Creation Date: 08/29/2012
# Date Last Modified: 11/16/2014 
#
# Version control: 1.04
#
# Support Team:
#
# Contributors: 
#
# ----------------------------------------------------------- 
# ------------- Program Description and Details ------------- 
# ----------------------------------------------------------- 
#
# This program makes the wave tracking module run for each
# domain and create the output files for plotting.
#
# The packages used are the following:
#
# WaveInput
# WindInput
# GraphicOutput
# TextOutput
# SwanRun
# ----------------------------------------------------------- 

######################################################
#      Packages and exportation requirements         #
######################################################
use POSIX;
use Math::Trig;
use GraphicOutput qw(getValuesFromCommandFile);
use CommonSub qw(removeFiles removeOldFiles mvFiles renameFilesWithSuffix giveDate);
use ConfigSwan;
use Cleanup;
use Logs;
use Archive qw(completeArchiveAndCleanup);
use Cwd 'chdir';
use diagnostics -verbose;
disable  diagnostics;
######################################################
#               Variables declaration                #
######################################################
our $dateSuffix;
our $path=PATH;
our (@partitionFileNames);
our ($dimRecord,$dimValue,$filename,$lat00,$lon00,$centralLat,$centralLon,$latNxNy,$lonNxNy);
our (@spc1DFileNames, @valuesSpc1D, @headerSpc1D);
our (@spc1dLon,@spc1dLat);
our (@prtLon,@prtLat,@prtFileNames,@prtShortName);
our %RunValues;
our $timeStepLength;
our @data;
our @input;
our $gtop;
our @values;
our @header;
our @netCdfData;
######################################################
#               Environment Variables                #
######################################################
# Setup our NWPS env
my $NWPSdir = $ENV{'HOMEnwps'};
my $USHnwps= $ENV{'USHnwps'};
use lib ("$ENV{'RUNdir'}");
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

# Setup our model run environment
my $RUNLEN = $ENV{'RUNLEN'};
my $WNA = $ENV{'WNA'};
my $NESTS = $ENV{'NESTS'};
my $RTOFS = $ENV{'RTOFS'};
my $WINDS = $ENV{'WINDS'};
my $WEB = $ENV{'WEB'};
my $PLOT = $ENV{'PLOT'};
my $SITEID = $ENV{'SITEID'};
my $NWPSplatform = $ENV{'NWPSplatform'};

print "+++++++++++++++++++  waveTracking.pl +++++++++++++++\n";
print "NWPSplatform: ${NWPSplatform}\n";
print "NWPSdir : ${NWPSdir}\n";


if((${NWPSplatform} eq 'WCOSS') || (${NWPSplatform} eq 'DEVWCOSS')) {
    my $infoFile02 = "${RUNdir}/info_to_nwps_coremodel.txt";
    open IN, "<$infoFile02"  or die "Cannot open: $!";
    our ($NWPSdir, $DEBUGGING, $DEBUG_LEVEL, $BATHYdb, $SHAPEFILEdb, $ARCHdir);
    our ($DATAdir, $LOGdir, $VARdir, $OUTPUTdir, $RUNdir, $TMPdir, $RUNLEN);
    our ($NESTS, $RTOFS, $ESTOFS, $WEB, $PLOT, $MODELCORE, $SITEID);
    our ($WNA, $WINDS, $INPUTdir, $ISPRODUCTIO, $siteid, $GEN_NETCDF);
    our ($USERDELTAC);
#
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

   print "$NWPSdir, $DEBUGGING, $DEBUG_LEVEL, $BATHYdb, $SHAPEFILEdb, $ARCHdir \n";
   print "$DATAdir, $LOGdir, $VARdir, $OUTPUTdir, $RUNdir, $TMPdir, $RUNLEN \n";
   print "$NESTS, $RTOFS, $ESTOFS, $WEB, $PLOT, $MODELCORE, $SITEID\ n";
   print "$WNA, $WINDS, $INPUTdir, $ISPRODUCTIO, $DATAdir, $siteid, $GEN_NETCDF \n";
   print "$USERDELTAC\n";
}
#
if ($DEBUGGING eq "TRUE") {
    Logs::run("NWPSdir: $NWPSdir");
    Logs::run("DEBUGGING: $DEBUGGING");
    Logs::run("DEBUG_LEVEL: $DEBUG_LEVEL");
    Logs::run("ISPRODUCTION: $ISPRODUCTION");
    Logs::run("RUNLEN: $RUNLEN");
    Logs::run("WNA: $WNA");
    Logs::run("NESTS: $NESTS");
    Logs::run("RTOFS: $RTOFS");
    Logs::run("WINDS: $WINDS");
    Logs::run("WEB: $WEB");
}
my $wavetracklogfname = "${LOGdir}/run_wavetrack_pl.log";
my $wvtrcklog = open(WVTLOG, ">${wavetracklogfname}");
#Get the CGS hash
my %CGSS = %ConfigSwan::CGS;
#Get the number of hashes (Number of computational grids) in the hash CGS
my $numcgrids += scalar keys %CGSS; 

#foreach my $CG (sort(values(%ConfigSwan::CGS))) {
#foreach my $CG ( reverse sort values  %ConfigSwan::CGS) {
#Give the names of the hashes that contains the CG information
my @columns = qw(CG1 CG2 CG3 CG4 CG5);
#Loop over the actual number of Comp. Grids, in spite of nymber of elemnts in @columns 
#For the time being wave tracking only on CG1
#for $i (0..$numcgrids-1){   #If you want wave tracking on all grids use this line
for $i (0..0){
   # Get a slice of the Config hash
   my $CG = @CGSS{$columns[$i]}; # 6,1,3
   %CG = %{$CG};
   my $cgnum = $CG{CGNUM};
   #my $sysTrcktFileName="swan_part.CG".$CG{CGNUM}.".raw";
   chdir($RUNdir) or die "Cant chdir to $RUNdir $!";
#XXX
  system("more CGinclude.pm");
   print "=================================\n";
   print "=                               =\n";
   print "=  Running Wave System Tracking =\n";
   print "= Computational Grid: $cgnum         =\n";
   print "=                               =\n";
   print "=================================\n";
   print " SysTrcktFileName: $sysTrcktFileName\n";


# TODO for the time being only output locations in CG1 can be processed
   if ($cgnum ==2) {
      # For wave tracking
      my $systrkInp="ww3_systrk.inp";
      my $temp_file="temporal_file";
      open my $in,  '<',  $systrkInp      or die "Can't read old file: $!";
      open my $out, '>', "$temp_file" or die "Can't write new file: $!";
      while( <$in> )
      {
        last if $_=~/Output/;
        print $out $_;
        print $_;
      }
      print $out "\$\n";
      print $out "\$\n";
      print $out "\$\n";
      print $out "    0.    0.\n";
      print $out "\$\n";
      print $out "\$\n";
      print $out "\$\n";
      close $in;
      close $out;
      system("mv -f $temp_file $systrkInp");
   }

##   system("mv -f ${sysTrcktFileName} partition.raw");
   system("cp -f ${sysTrcktFileName} partition.raw");
   #AW # Remove any exception values in partition file produced by SWAN, in particular wind speed
   #AW system("sed -i 's/\\*\\*\\*\\*\\*/  0.0/g' partition.raw");
   system("date +%s > ${VARdir}/wavetrackrun_start_secs.txt");
   system("${USHnwps}/ww3_systrackexe_clust.sh > ${LOGdir}/run_ww3_systrk.log 2> ${LOGdir}/run_ww3_systrk_exe_error.log");
   system("date +%s > ${VARdir}/wavetrackrun_end_secs.txt");
   #Print a warning that NWPS is not using wavetracking mpi (if requested) but the serial version
   my $mpiORser = "${LOGdir}/waveTrck_mpiORser.log";
   if (-e $mpiORser) {
     print "***********************************************************************************\n";
     system("cat ${LOGdir}/waveTrck_mpiORser.log");
     print "***********************************************************************************\n";
   } 
   ($dimRecord,$dimValue,$filename,$lat00,$lon00,$centralLat,$centralLon,$latNxNy,$lonNxNy)=&getValuesFromCommandFile("CG$cgnum");
   my (undef,$prtyear,$prtmonth,$prtday,undef,$prthour)=unpack"A2 A2 A2 A2 A A2",$filename;
   my $prtdateSuffix="YY".$prtyear.".MO".$prtmonth.".DD".$prtday.".HH".$prthour;
   my $archInputFile="INPUT.CG".$CG{CGNUM}.".$prtdateSuffix";
   system("mkdir -pv ${OUTPUTdir}/partition/CG${cgnum}");
   enable  diagnostics;
   if ($cgnum ==1) {
      &ReadPRTLocNames($archInputFile,%CG);
      &formatTracking;
      &renameFilesWithSuffix($prtdateSuffix,"PRT|GRID");
      undef @partitionFileNames;
      &getPrtNamesLonLat("CG$cgnum");
      print WVTLOG "We have partition raw SWAN output for this run\n";
      print WVTLOG "Starting partition processing for raw SWAN output\n";
#      system("mkdir -pv ${OUTPUTdir}/partition/CG${cgnum}");
      chdir("${OUTPUTdir}/partition/CG${cgnum}");
      system("mv -fv ${RUNdir}/SYS_* ${OUTPUTdir}/partition/CG${cgnum}/ ");
      foreach $partitionName (@partitionFileNames) {
         my $findCG = index($partitionName, "CG${cgnum}");
         if ($findCG > 0) {
   	    system("mv -fv ${RUNdir}/${partitionName}.${prtdateSuffix} ${OUTPUTdir}/partition/CG${cgnum}/${partitionName}.${prtdateSuffix}");
	    print WVTLOG "Create partition data file for ${partitionName}\n";
	    &createDataPartition('partition', ${partitionName}, "CG${cgnum}");
         }
      }



if((${NWPSplatform} eq 'WCOSS') || (${NWPSplatform} eq 'DEVWCOSS')) {
    my $infoFile02 = "${RUNdir}/info_to_nwps_coremodel.txt";
    open IN, "<$infoFile02"  or die "Cannot open: $!";
    our ($NWPSdir, $DEBUGGING, $DEBUG_LEVEL, $BATHYdb, $SHAPEFILEdb, $ARCHdir);
    our ($DATAdir, $LOGdir, $VARdir, $OUTPUTdir, $RUNdir, $TMPdir, $RUNLEN);
    our ($NESTS, $RTOFS, $ESTOFS, $WEB, $PLOT, $MODELCORE,  $SITEID);
    our ($WNA, $WINDS, $INPUTdir, $ISPRODUCTIO, $siteid, $GEN_NETCDF);
    our ($USERDELTAC);
#
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

   print "$NWPSdir, $DEBUGGING, $DEBUG_LEVEL, $BATHYdb, $SHAPEFILEdb, $ARCHdir \n";
   print "$DATAdir, $LOGdir, $VARdir, $OUTPUTdir, $RUNdir, $TMPdir, $RUNLEN \n";
   print "$NESTS, $RTOFS, $ESTOFS, $WEB, $PLOT, $MODELCORE, $LOGdir, $SITEID\ n";
   print "$WNA, $WINDS, $INPUTdir, $ISPRODUCTIO, $DATAdir, $siteid, $GEN_NETCDF \n";
   print "$USERDELTAC\n";
}
      our $PLOT="YES";
      if ($PLOT eq "YES" ) {
         #For the time being NWPS do not make GH plots on the Nested Grids
         my $gotoBin="$RUNdir";
         chdir($gotoBin) or die "Cant chdir to $gotoBin $!";
         system("cp -f CGinclude.pm CGinclude_backup.pm");
         my $cgincludeIn="CGinclude.pm";
         my $temp_file2="temporal_file2";
         open my $in,  '<',  $cgincludeIn      or die "Can't read old file: $!";
         open my $out, '>', "$temp_file2" or die "Can't write new file: $!";
         while( <$in> ){
            last if $_=~/\(CG2\)/;
            print $out $_;
            #XXX
            print "$_ \n";
         }
         close $out;
         system("cp -pfv $temp_file2 $cgincludeIn");
         chdir($RUNdir) or die "Cant chdir to $RUNdir $!";
         print "===============================================\n";
         print "PLOT PARTITION for CG${cgnum}\n";
         print "===============================================\n";
         #system("${USHnwps}/grads/bin/plot_partition.sh >> ${LOGdir}/partition_encoding.log 2>&1");
         system("${USHnwps}/python/plot_partition.sh >> ${LOGdir}/partition_encoding.log 2>&1");
         print "plot_partition DONE! \n";
      }
    }else{
         system("mv -fv ${RUNdir}/SYS_* ${OUTPUTdir}/partition/CG${cgnum}/ ");
    } # End if ($cgnum ==1)

    my $gotoBin="$RUNdir";
    chdir($gotoBin) or die "Cant chdir to $gotoBin $!";
    system("cp -f CGinclude_backup.pm CGinclude.pm");
    $CGNUMBER="CG$cgnum";
    print "$CGNUMBER \n";
    chdir($RUNdir) or die "Cant chdir to $RUNdir $!";
    #system("${USHnwps}/grads/bin/postprocess_plot_partition_fields.sh ${SITEID} ${CGNUMBER}");
    system("${USHnwps}/postprocess_partition_fields_clust.sh ${SITEID} ${CGNUMBER}");
    print "postprocess_partition_fields  DONE! \n";
    #system("cp -f ${RUNdir}/sys_log0000.ww3 ${LOGdir}/."); #Info from Log files are used for packing
} # END for $i (0..$numcgrids-1)

system("touch ${OUTPUTdir}/tracking_completed");

#AW Logs::run("Archive input and output data files.");
#AW &completeArchiveAndCleanup($dateSuffix);

Logs::run("END RUN WAVE TRACKING");
##################################################################################
# Subroutine &formatTracking
# Calling program/subroutine: waveTracking.pl
# CALL: &formatTracking;
# GOAL: Gives to the Wave Tracking Output Files the proper format for post-processing. 
# SUBROUTINES CALLS: &formatTracking
# Roberto Padilla-Hernandez: February-2012
################################################################################
sub formatTracking {
use IO::File;
        my ($Pointi        , @Header     , $wu       , $wv      , $j);
        my ($wndFileName   , $FileIn     , $NumOfSpec, @temp    , $locName );
        my ($i             , $loclon     , $loclat   , $pointlo , $pointla);
        my ($prtFileName   , $CGx        , $pointName           );
        my ($numofOutTimes , @filehandles, $Fileout  , $itime   , $jj);
        my (@filesInHandles, $FileWindIn , $fh       , $wuv     );
        my ($line          , $resultu    , $resultv  , $spcfound);
        my (@arrayOut      , $value      , $datain   , $witness );
        my ($pointLong     , $pointLati  , $ind1     , $ind2    );
        local *OUT;
        $FileIn="SYS_PNT.OUT";
        $NumOfSpec=$RunValues{"NumSpcOut"};
        $CGx=$RunValues{"CGX"};
        $numofOutTimes=$RunValues{"NumOfOutTimes"};
#                system("pwd");
#                system("ls -lt");
#       Open Data File to Read
        #print "File IN: $FileIn   numofOutTimes: $numofOutTimes \n";
        open IN, "<$FileIn"  or die "Cannot open: $!";
#       Reading header lines
        for $i (0..6){
          $line = <IN>;
          chomp ($line);
          $Header[$i]=$line;
          $Header[$i]=$Header[$i]."      X-Windv       Y-Windv    " if ($i == 4);
          $Header[$i]=$Header[$i]."        [m/s]         [m/s]    "  if ($i == 5);
        }
#       Loop for the number of output times
        my $contime=0;
        for $itime (1..$numofOutTimes){
          $line = <IN>;
          chomp ($line);
          my $timeread = $line;
          $jj=0;
#         Loop for the number of output location 
          for $Pointi (0..$NumOfSpec-1){
            $jj+=1;
            #print "Point Number: $Pointi\n";
            $line = <IN>;
            chomp ($line);
            #print "LINE: $line\n";
            @temp=split /\s+/,$line;
            $loclon=sprintf("%13.3f",$temp[1]);
            $loclat=sprintf(" %13.3f",$temp[2]);
            #print " $loclon  $loclat \n";
            #Relating the  spectra output names to point names and locations
            #print "In formatTracking: Num os spectra: $NumOfSpec\n";
            $spcfound="not";
            foreach $j (1..$NumOfSpec) {
              $pointlo="pointlong".$j;
              $pointla="pointlati".$j;
              $specName ="SpecName".$j;

              if ($loclon == $RunValues{$pointlo} && $loclat == $RunValues{$pointla}) {
                #print "+++  $loclon == $RunValues{$pointlo}; $loclat == $RunValues{$pointla}\n";
                $spcfound="yes";
                @char=split //, $RunValues{$specName};

                pop @char; shift @char; 
                $locName=join ("", @char);
                $prtFileName="PRT.".$locName.".CG".$CGx.".TAB";
                $wndFileName="WND.".$locName.".CG".$CGx;
                #print "In formatTracking prtFileName: $prtFileName\n";
                #print "                  wndFileName: $wndFileName\n";
                last;
              } 
            }  
            if ($spcfound eq "not"){ 
                print "****** LOCATION FOR PARTITION NOT FOUND **********\n";
                print "*   AT LEAST ONE OF THE OUTPUT LOCATIONS         *\n";
                print "* IS OUT OF THE WAVETRACKING DOMAIN VERIFY YOUR  *\n";
                print "* INPUT INFO FOR SPECPOINTS IN THE DOMAIN FILE   *\n";
                print "*                                                *\n"; 
                print "* IN SYS_PNT.OUT THE LOC ($loclon, $loclat)	*\n";
                print "* HAS BEEN FOUND                                 *\n"; 
                print "**************************************************\n";
                print "$line\n";
                $pointlo  = "pointlong".$jj;
                $pointla  = "pointlati".$jj;
                $specName = "SpecName".$jj;
                $loclon   = sprintf("%13.3f",$RunValues{$pointlo});
                $loclat   = sprintf("%13.3f",$RunValues{$pointla});
                @char     = split //, $RunValues{$specName};
                pop @char;  shift @char; 
                $locName  = join ("", @char);
                $prtFileName="PRT.".$locName.".CG".$CGx.".TAB";
                $wndFileName="WND.".$locName.".CG".$CGx;
            }

            undef @arrayOut;
            push(@arrayOut,$loclon);
            push(@arrayOut,$loclat);
#           Loop for the 10 partitions (Hs, Tp, Dir) 
            #print"SPCFOUND:$spcfound\n";
            foreach $prtn (3..32) {
#              if ($spcfound eq "not" || $temp[$prtn] >900.0){
              if ($spcfound eq "not"){ 
                  $temp[$prtn]=0.0;
              }
                  $witness=0;
              if ($prtn > 22 && $prtn < 33){
                  $witness=1;
                 $datain=sprintf(" %13.4f",$temp[$prtn]);  #%13.3f
              }
              elsif ($prtn > 12 && $prtn < 23){
                  $witness=2;
                 $datain=sprintf(" %13.4f",$temp[$prtn]);  # %13.4f
              }
              elsif ($prtn > 2 && $prtn < 13){
                  $witness=3;
                 $datain=sprintf(" %13.4f",$temp[$prtn]); #13.5f
              }
            #print "datain and temp[prtn] : $datain $temp[$prtn]\n";
              push(@arrayOut,$datain);
              undef $datain;
            }
            if ($itime == 1){
              open(OUT, ">$prtFileName") || die "cannot create: $!";
              push(@filehandles, *OUT);
              $Fileout=$filehandles[$Pointi];
              for $i (0..6){                     #The file has 7 lines header
               print $Fileout "$Header[$i]\n";
              } 
              $fh = new IO::File($wndFileName, "r");
              push(@filesInHandles, $fh);
            }else{
              open(OUT, ">>$prtFileName") || die "cannot create: $!";
            }
            $Fileout=$filehandles[$Pointi];
            $FileWindIn=$filesInHandles[$Pointi];
            $wuv = <$FileWindIn>;
            chomp $wuv;
            print "wuv:  $wuv\n";
            my @tempw= (0) x 3;
            @tempw=split /\s+/,$wuv;

            my $arrSize = @tempw;
            #print "arraysize: $arrSize";

#           if ($tempw[2]+0 == 0) { 
            if ($arrSize == 2) { 
             $ind1=0; $ind2=1;
            #print "in formatTracking 0 $tempw[0], 1 $tempw[1]\n";
            }else{
             $ind1=1; $ind2=2;   
            #print "in formatTracking 1 $tempw[1], 2 $tempw[2]\n";
            }
            #print " ind1:$ind1 ind2:$ind2   \n";
            $wu = sprintf(" %13.4f", $tempw[$ind1]);
            $wv = sprintf(" %13.4f", $tempw[$ind2]);
            #$wu = sprintf(" %13.4f", $tempw[1]);
            #$wv = sprintf(" %13.4f", $tempw[2]);
            #print "wu, wv: $wu, $wv\n";
            push(@arrayOut,$wu);
            push(@arrayOut,$wv);
            foreach $value (@arrayOut) {    # data for every line
             print $Fileout "$value";
            }
            print $Fileout " \n";
            close OUT;
          }
        }
        close IN;
}


################################################################################
# NAME: getPartitionFileNames                                                  #
# CALL: &getPartitionFileNames                                                 #
# GOAL: Find and store the output filenames for wave partition provided by the #
#       user in the domain setup                                               #
#                                                                              #
#Written by   :  Roberto Padilla-Hernandez  EMC/NCEP/MMAB/IMSG                 #
#                                                                              #
#Contributors:                                                                 #
#                                                                              #
#first written: 07/11/2011                                                     #
#last update: 03/15/2011                                                       #
#                                                                              #
################################################################################
sub getPrtNamesLonLat {
    my ($sought1 , $name, $numOfPartLoc, @temp , @char,$longName   );
    my ($domain)=@_;
    my $contstring1="5mcont";
    my $contstring2="20mcont";
    my $SHIPRTstring1="SHIPRT1";
    my $SHIPRTstring2="SHIPRT2";
    my $SHIPRTstring3="SHIPRT3";
    my $SHIPRTstring4="SHIPRT4";
    $sought1="POINTS";
    $numOfPartLoc=0;
    open (DATA,"input$_[0]");
    if(! DATA ) {
	$partitionYorN = "NO";
	system("echo \"**Input file : input$_[0] could not be opened\" >> ${LOGdir}/partition_encoding.log");
	return;
    }
    while (<DATA>) {
	if ($_ =~/^$sought1/) {
	    $numOfPartLoc++;
	    chomp $_;
	    @temp=split /\s+/,$_;
            @char=split //, $temp[1];
            pop @char; shift @char; #scraching the apostrophes in the name
            $name=join ("",@char);

	    # 01/09/2020: Check for 5m and 20m contour points
	    if($name =~/^$contstring1/) {
		next;
	    }
	    if($name =~/^$contstring2/) {
		next;
	    }
	    # 01/10/2017: Check for Ship route points
	    if($name =~/^$SHIPRTstring1/) {
		next;
	    }
	    if($name =~/^$SHIPRTstring2/) {
		next;
	    }
	    if($name =~/^$SHIPRTstring3/) {
		next;
	    }
	    if($name =~/^$SHIPRTstring4/) {
		next;
	    }

            undef @char;
            push @prtShortName, $name;
            push @prtLon, $temp[2];
            push @prtLat, $temp[3];
            $longName="PRT."."$name."."$domain."."TAB";
            $numOfPartLoc++;
	    push @partitionFileNames, $longName;
         }
    }

    system("echo \"Filenames:  @partitionFileNames\" >> ${LOGdir}/partition_encoding.log");
 
    if ($numOfPartLoc > 0) { 
	$partitionYorN = "YES"; 
    }
    else {
	$partitionYorN = "NO"; 
    }

    if(${DEBUGGING} eq 'TRUE') {
	system("echo \"============================================\" >> ${LOGdir}/partition_encoding.log");
	system("echo \" partition yes/not:  $partitionYorN\" >> ${LOGdir}/partition_encoding.log");
	system("echo \"============================================\" >> ${LOGdir}/partition_encoding.log");
    }
    
    close DATA;
}
################################################################################
# NAME: &createDataPartition                                                   #
# CALL: &createDataPartition('partition', ${partitionName}, "CG${cgnum}")      #
# GOAL: Create a BIN file of floating point values that can be ploted by GRADS #
#       Includes the prostprocessing of wind vectors                           #
#                                                                              #
# Written by   :  Roberto Padilla-Hernandez  EMC/NCEP/MMAB/IMSG                #
#                                                                              #
# Contributors: Douglas.Gaer@noaa.gov Southern Region Headquarters             #
#                                                                              #
# first written: 07/11/2011                                                    #
# last update: 08/27/2011                                                                 #
#                                                                              #
# Read the partition output files values and encode them directly to a         #
# BIN file that will be plotted by GRADS                                       #
#                                                                              #
################################################################################
sub createDataPartition {
    #print ("begin createDataPartition\n");
    my ($dataType, $fname, $domain)=@_;

    my (%PTHs      ,%PTTp       ,%PTDp    ,%vector                         );
    my (@temp      ,@count      ,@TpArray ,$prtbinfile ,$i1    ,$UV        );
    my ($numTimes  ,$uvalue     ,$vvalue  ,$line       ,$prtn              );
    my ($firstchar ,$diff       ,$Tpindex ,$locHs      ,$locTp ,$locDp     );
    my ($i         ,@windU   ,@windV      ,%wnduarray                      );
    my (%wndvarray ,$windbinfile,$prtYorN ,$windComp   ,$yuv               );


    my ($time, $inirest, $period,    ,);
    $dataType='PARTIT' if ($dataType eq 'prt');
           for ($i = 0; $i <= 25; $i += 0.5) { 
               push @TpArray, $i;
            }
    #print "fname: $fname\n";
    my (undef,$year,$month,$day,undef,$hour)=unpack"A2 A2 A2 A2 A A2",$filename;
    $dateSuffix="YY".$year.".MO".$month.".DD".$day.".HH".$hour;
    open (DATA,"$fname.$dateSuffix");
    if( ! DATA ) {
        $partitionYorN = "NO";
	$hasprterror = "TRUE";
	system("echo \"IN createdataPart: The file $fname.$dateSuffix couldn't be opened, error:$!\" >> ${LOGdir}/partition_encoding.log");
	return;
    }
    system("echo \"The file ${fname} has been opened\" >> ${LOGdir}/partition_encoding.log");

#    my $prtascfile  = open(PRTASCFILE,  ">${fname}.asc") or die ;
    $prtbinfile = open(PRTBINFILE, ">${fname}.${dateSuffix}.bin") or die;
    $windbinfile = open(WINDBINFILE, ">${fname}.${dateSuffix}.bin_wind") or die;
    if( ! $prtbinfile ){
        $partitionYorN = "NO";
	$hasprterror = "TRUE";
	system("echo \"IN createdataSpc1D: Cannot create file ${fname}.bin, error:$!\" >> ${LOGdir}/partition_encoding.log");
	#undef (@data);
	return;
    }
    if( ! $windbinfile ){
	$prtYorN="NO";
	$hasprterror = "TRUE";
	system("echo \"IN createdataWind: Cannot create file ${fname}_wind.bin, error:$!\" >> ${LOGdir}/partition_encoding.log");
	return;
    }

    binmode PRTBINFILE;
    binmode WINDBINFILE;

    $numTimes=-1; # $numTimes: Number of output times
    until (eof(DATA)) {
       $line=<DATA>; 
       @temp=split /\s+/,$line;
       $firstchar = substr($temp[0], 0, 1); # Returns the first character
       if($firstchar eq "%") { # Check to see if We have a comment line 
          next;
       }else{
          $numTimes++;
          shift @temp;
           foreach $prtn (0..9) {    # for each partition
              if ($numTimes == 0){ $count[$prtn]=0;}
#              for ($temp[$prtn+2], $temp[$prtn+12], $temp[$prtn+22]) {
#                 if ($_ eq "NaN") {$_="0.000";}
#              }
              $PTHs{"$numTimes,$prtn"} = $temp[$prtn+2];
              $PTTp{"$numTimes,$prtn"} = $temp[$prtn+12];
              $PTDp{"$numTimes,$prtn"} = deg2rad($temp[$prtn+22]); 
              $locHs=exists $PTHs{"$numTimes,$prtn"} ? $PTHs{"$numTimes,$prtn"}: 0;
              $locTp=exists $PTTp{"$numTimes,$prtn"} ? $PTTp{"$numTimes,$prtn"}: 0;
              if ($locHs>0.001) {
                 $count[$prtn]=$count[$prtn]+1;
              }
           }
              $windU[$numTimes] = $temp[32];
              $windV[$numTimes] = $temp[33];
       }
    }
    close(DATA);

      #WIND
    foreach $yuv (1..3){
       foreach $time (0..$numTimes) {
          if ($yuv == 2) {
             $wnduarray{"$time,$yuv"} = $windU[$time];
             $wndvarray{"$time,$yuv"} = $windV[$time];
          }else{
             $wnduarray{"$time,$yuv"} = -99.99;
             $wndvarray{"$time,$yuv"} = -99.99;
          }
       }
    }


    foreach $UV (1...2) {                 # For each vector component
       #WIND
       foreach my $yuv (1..3){
          foreach $time (0..$numTimes) {
             if ($UV==1) {
                $windComp=exists $wnduarray{"$time,$yuv"} ? $wnduarray{"$time,$yuv"}: 0;
             }else{
                $windComp=exists $wndvarray{"$time,$yuv"} ? $wndvarray{"$time,$yuv"}: 0;
          }
          print WINDBINFILE pack('f', $windComp);
       }
    }


       foreach $prtn (0..9) {             # For each partition
          %vector=();
          foreach $time (0..$numTimes) {  # For each output time
             $diff=-1;
             $Tpindex=-1;
             while ($diff < 0 && $Tpindex <= $#TpArray) {
                $Tpindex++;
                $vector{"$time,$Tpindex"}=-99.99;
                $locHs=exists $PTHs{"$time,$prtn"} ? $PTHs{"$time,$prtn"}: 0;
                $locTp=exists $PTTp{"$time,$prtn"} ? $PTTp{"$time,$prtn"}: 0;
                $locDp=exists $PTDp{"$time,$prtn"} ? $PTDp{"$time,$prtn"}: 0;
             if ($locHs==0.0) {$locHs= 0.001; }
              if ($locTp==0.0) {$locTp= 4; }
                #Looking the closest period in the period-table loockup
                $diff=$TpArray[$Tpindex]-$locTp;
                if ($locHs== 0){$diff=-1;}
                $uvalue = exists $vector{"$time,$Tpindex"} ? $vector{"$time,$Tpindex"}: 0;
                #IF found the closest period and Hs >0 and there is more than one value>0
                #then compute the vector component and complete the date-period domain with 
                # -99.99 values 
                ##########XXXif (abs($diff) <0.3 && $locHs >0 && $count[$prtn] > 1) {
                if (abs($diff) <0.3 && $locHs >0 && $count[$prtn] > 0) {
                   if ($UV==1) {
                      $vector{"$time,$Tpindex"}=$locHs*cos(deg2rad(270)-$locDp);
                   }else{
                      $vector{"$time,$Tpindex"}=$locHs*sin(deg2rad(270)-$locDp);
                   }
                   $inirest=$Tpindex+1;
                   foreach $i1 ($inirest..$#TpArray) {
                      $vector{"$time,$i1"}=-99.99;
                      #$uvalue = exists $vector{"$time,$i1"} ? $vector{"$time,$i1"}: 0;
                   }
                   $diff=1; $Tpindex =$#TpArray;
                } #Close if (Period is found, Energy != 0, more than one value>0)
             } # Close while
          } #close for num of times
          foreach  $period (0..$#TpArray) {
             foreach  $time (0..$numTimes) {
                $uvalue = exists $vector{"$time,$period"} ? $vector{"$time,$period"}: 0;
	        print PRTBINFILE pack('f', $uvalue);
             } 
      # print PRTASCFILE "\n";   
          } 
      # print PRTASCFILE "\n";   
       } # Close for partition 0-9
    } #Close for vector components
    close(PRTBINFILE);
    close(WINDBINFILE);
#    close(PRTASCFILE);
}
################################################################################
# NAME: ReadPRTLocNames                                                        #
# CALL: &   &ReadPRTLocNames($archInputFile,%CG);                              #
# GOAL: for each domain, it read some information from SWAN INPUT file         #
#       to create the file names for wave tracking in a geografical locations  #
# Written by   :  Roberto Padilla-Hernandez  EMC/NCEP/MMAB/IMSG                #
#                                                                              #
# Contributors:                                                                #
#                                                                              #
# first written: 07/11/2011                                                    #
# last update: 08/27/2011                                                      #
#                                                                              #
#                                                                              #
################################################################################

sub ReadPRTLocNames($%) {
    use Tie::File;
    local ($swanInputFile,%CG)=@_;
    my ($Tbegc, $Unitsc, $windExt, @wndExt,$runID);
    my (@char , @char1 , @char2                  );
    my $computLines=0; 
    $numofOutputPoints=0;
    $numofOutputSpectra=0; 
    $numofOutputPartition=0;     
    ##$RunValues{"NumofCGrids"}  =$numofGrids;
#   TODO define the number of wind grids. This has to be computed reading the
#   INPGRID commmand from INPUTCGX files, if there is one or several wind files
    ##$RunValues{"NumofWndGrids"}  =1; #$numofWndGrids;
    
    chdir("${RUNdir}/"); 
#
    $RunValues{"CGX"}=$CG{CGNUM};
    open (SWANINP,$swanInputFile);
    if(! SWANINP ) {
	system("echo \"**Input file : $swanInputFile could not be opened\" >> getWW3Files.log");
	exit;
    }
    #Looking for data for every command in the "user input" metadata
    my $charcom="\$"; 
    while (<SWANINP>) {
        $comline=$_;
        @temp=split /\s+/,$comline;
        if ($comline =~ /^\$/) {
	}else{
	   if ($comline =~/^PROJ/)  {
              #print " Searching for:  PROJ\n";;
              $keyfound=$_;
	      chomp $keyfound;
	      @temp=split /\s+/,$keyfound;
              @char1=split //, $temp[1]; 
              @char2=split //, $temp[2];
              #pop @char1;
              #shift @char2; #scraching the apostrophes in the name
              $proj=join ("",@char1," ");

              $proj="   ".$proj;
              $RunValues{"PROJ"}=$proj;     # No. of elements: 1
              $runID=join ("",@char2);
              $RunValues{"RunID"}=$runID;     # No. of elements: 1
              undef $keyfound, @temp;
           }
           if ($comline =~/SET/)  {
             #print " Searching for:  SET\n";;
             $keyfound=$_;
	     chomp $keyfound;
             @temp=split /\s+/,$keyfound;
             $level= $temp[1]; $depmin=$temp[2];
             $RunValues{"level"}  =$temp[1];
             $RunValues{"nor"}    =$temp[2];
             $RunValues{"depmin"} =$temp[3];
             $RunValues{"maxmes"} =$temp[4];
             $RunValues{"maxerr"} =$temp[5];
             $RunValues{"grav"}   =$temp[6];
             $RunValues{"rho"}    =$temp[7];
             $RunValues{"convent"}=$temp[8];  #total elements: 9 
             undef $keyfound, @temp;
           }
           if ($comline =~/MODE/)  {
             #print " Searching for:  MODE\n";;
             $keyfound=$_;
	        chomp $keyfound;
             @temp=split /\s+/,$keyfound;
             $RunValues{"MODE"}=$temp[1];   #total elements: 10 
             undef $keyfound, @temp;
           }
           if ($comline =~/COORD/)  {
             #print " Searching for:  COORD\n";;
             $keyfound=$_;
	        chomp $keyfound;
             @temp=split /\s+/,$keyfound;
             $RunValues{"COORD"}=$temp[1];   #total elements: 11 
             undef $keyfound, @temp;
           }
#AW           if ($comline =~/^CGRID/)  {
#AW             #print " Searching for:  CGRID\n";
#AW             $keyfound=$_;
#AW	        chomp $keyfound;
#AW             @temp=split /\s+/,$_;
#AW             #$RunValues{"xpc"   } =$temp[1];
#AW             #$RunValues{"ypc"   } =$temp[2];
#AW             $RunValues{"alpc"  } =$temp[3];
#AW             $RunValues{"xlenc" } =$temp[4];
#AW             $RunValues{"ylenc" } =$temp[5];
#AW#            for ww3 is the numb of points instead numb of meshes
#AW             $RunValues{"npxc"  } =$temp[6]+1;
#AW             $RunValues{"npyc"  } =$temp[7]+1;
#AW#            WW3 has an extended comp. grid in all boundaries
#AW             $RunValues{"npxcww3"  } =$temp[6]+1;
#AW             $RunValues{"npycww3"  } =$temp[7]+1;
#AW#            In WW3 the output is from 2 to npxc-1 and 2-> npyc-1
#AW             $RunValues{"npxout"  } =$temp[6]+1;
#AW             $RunValues{"npyout"  } =$temp[7]+1;
#AW             $RunValues{"CGnpxnpy"}= $RunValues{"npxc"}*$RunValues{"npyc"};
#AW             $RunValues{"delxc" }= $temp[4]/$temp[6];
#AW             $RunValues{"delyc" }= $temp[5]/$temp[7];
#AW             $RunValues{"xpc"   } =$temp[1]-$RunValues{"delxc" };
#AW             $RunValues{"ypc"   } =$temp[2]-$RunValues{"delyc" };
#AW             $RunValues{"CIRCLE"} =$temp[8];
#AW             $RunValues{"npdc"  } =$temp[9]+1;
#AW             $RunValues{"flow"  } =$temp[10];
#AW             $RunValues{"fhigh" } =$temp[11]; 
#AW             $RunValues{"npsc"   }=int(log($temp[11]/$temp[10])/log(1.1)+0.5)+1;  #25
#AW
#AW             undef $keyfound, @temp;
#AW           }
           if ($comline =~/^INPGRID BOTTOM/)  {
               #print " Searching for:  INPGRID BOTTOM\n";;
             $keyfound=$_;
	        chomp $keyfound;
             @temp=split /\s+/,$_;
             $RunValues{"BOTxpinp"  } =$temp[2];
             $RunValues{"BOTypinp"  } =$temp[3];
             $RunValues{"BOTalpinp" } =$temp[4];
             $RunValues{"BOTnpxinp" } =$temp[5]+1;
             $RunValues{"BOTnpyinp" } =$temp[6]+1;
             $RunValues{"BOTdxinp"  } =$temp[7];
             $RunValues{"BOTdyinp"  } =$temp[8];
             $RunValues{"BOTexcval" } =$temp[10]; #33
             undef $keyfound, @temp;

           }
           if ($comline =~/^READINP BOTTOM/)  {
               #print " Searching for:  READ BOTTOM\n";;
             $keyfound=$_;
	        chomp $keyfound;
             @temp=split /\s+/,$_;
             $RunValues{"BOTfac"    } =$temp[2]*(-1);
             $RunValues{"BOTname"   } =$temp[3];
             $RunValues{"BOTidla"   } =$temp[4];
             $RunValues{"BOTnhedf"  } =$temp[5];
             $RunValues{"BOTformat" } =$temp[6]; #38
             undef $keyfound, @temp;
           }
#           if ($comline =~/^INPGRID WIND/)  {
#             #print " Searching for: INPGRID WIND\n";;
#             $keyfound=$_;
#             chomp $keyfound;
#             @temp=split /\s+/,$_;
#             $RunValues{"WNDxpinp"   } =$temp[2];
#             $RunValues{"WNDypinp"   } =$temp[3];
#             $RunValues{"WNDalpinp"  } =$temp[4];
##               for ww3 is the numb of points instead numb of meshes
#             $RunValues{"WNDnpxinp"  } =$temp[5]+1;
#             $RunValues{"WNDnpyinp"  } =$temp[6]+1;
#             $RunValues{"WNDnpxnpy"  } =($temp[5]+1)*($temp[6]+1);
#             $RunValues{"WNDdxinp"   } =$temp[7];
#             $RunValues{"WNDdyinp"   } =$temp[8];
##               end long and end lat
#             $RunValues{"WNDxqinp"   } =$temp[2]+($temp[5]+1)*$temp[7];
#             $RunValues{"WNDyqinp"   } =$temp[3]+($temp[6]+1)*$temp[8];
#             $RunValues{"WNDtbeginp" } =$temp[10];
#             $RunValues{"WNDdeltinp" } =$temp[11];
#             $RunValues{"WNDtunit"   } =$temp[12];
#             $RunValues{"WNDtendinp" } =$temp[13];   #49
#             undef $keyfound, @temp;
#           }
           if ($comline =~/^READINP WIND/)  {
             #print " Searching for:  READ WIND\n";;
             $keyfound=$_;
	        chomp $keyfound;
             @temp=split /\s+/,$_;
             $RunValues{"WNDfac"    } =$temp[2];
             $RunValues{"WNDname"   } =$temp[3];
             @char=split //,$temp[3];
             undef $bot_filename;
             pop @char; shift @char; #scraching the apostrophes in the name
             @wndExt = splice @char, 11;
             $windExt= join ("", @wndExt);
             $RunValues{"WNDFileExt"} =$windExt;
             $RunValues{"WNDidla"   } =$temp[4];
             $RunValues{"WNDnhedf"  } =$temp[5];
             $RunValues{"WNDnhedt"  } =$temp[6];
             $RunValues{"WNDnhedv"  } =$temp[7];
             $RunValues{"WNDformat" } =$temp[8];  #56
             undef $keyfound, @temp;
           }
           if ($comline =~/^INPGRID CUR/)  {
             #print " Searching for: INPGRID CUR\n";;
             $keyfound=$_;
	     chomp $keyfound;
             @temp=split /\s+/,$_;
             $RunValues{"CURxpinp"   } =$temp[2];
             $RunValues{"CURypinp"   } =$temp[3];
             $RunValues{"CURalpinp"  } =$temp[4];
             $RunValues{"CURnpxinp"  } =$temp[5]+1;
             $RunValues{"CURnpyinp"  } =$temp[6]+1;
             $RunValues{"CURdxinp"   } =$temp[7];
             $RunValues{"CURdyinp"   } =$temp[8];
             $RunValues{"CURtbeginp" } =$temp[10];
             $RunValues{"CURdeltinp" } =$temp[11];
             $RunValues{"CURtunit"   } =$temp[12];
             $RunValues{"CURtendinp" } =$temp[13];  #67 
             undef $keyfound, @temp;
           }
           if ($comline =~/^READINP CUR/)  {
             #print " Searching for:  READ CUR\n";;
             $keyfound=$_;
	        chomp $keyfound;
             @temp=split /\s+/,$_;
             $RunValues{"CURfac"    } =$temp[2];
             $RunValues{"CURname"   } =$temp[3];
             $RunValues{"CURidla"   } =$temp[4];
             $RunValues{"CURnhedf"  } =$temp[5];
             $RunValues{"CURnhedt"  } =$temp[6];
             $RunValues{"CURnhedv"  } =$temp[7];
             $RunValues{"CURformat" } =$temp[8]; #74
             undef $keyfound, @temp;
           }
           if ($comline =~/^INPGRID WLEV/)  {
             #print " Searching for: INPGRID WLEV\n";;
             $keyfound=$_;
	        chomp $keyfound;
             @temp=split /\s+/,$_;
             $RunValues{"WLEVxpinp"   } =$temp[2];
             $RunValues{"WLEVypinp"   } =$temp[3];
             $RunValues{"WLEValpinp"  } =$temp[4];
             $RunValues{"WLEVnpxinp"  } =$temp[5]+1;
             $RunValues{"WLEVnpyinp"  } =$temp[6]+1;
             $RunValues{"WLEVdxinp"   } =$temp[7];
             $RunValues{"WLEVdyinp"   } =$temp[8];
             $RunValues{"WLEVtbeginp" } =$temp[10];
             $RunValues{"WLEVdeltinp" } =$temp[11];
             $RunValues{"WLEVtunit"   } =$temp[12];
             $RunValues{"WLEVtendinp" } =$temp[13]; #85
             undef $keyfound, @temp;
           }
           if ($comline =~/^READINP WLEV/)  {
             #print " Searching for:  READ WLEV\n";;
             $keyfound=$_;
	        chomp $keyfound;
             @temp=split /\s+/,$_;
             $RunValues{"WLEVfac"    } =$temp[2];
             $RunValues{"WLEVname"   } =$temp[3];
             $RunValues{"WLEVidla"   } =$temp[4];
             $RunValues{"WLEVnhedf"  } =$temp[5];
#               $RunValues{"WLEVnhedt"  } =$temp[6];
#               $RunValues{"WLEVnhedv"  } =$temp[7];
             $RunValues{"WLEVformat" } =$temp[6]; #90
             undef $keyfound, @temp;
           }
           if ($comline =~/^COMPUTE/)  {
             $computLines+=1;
             #print " Searching for: COMPUTE ($computLines)\n";
             $keyfound=$_;
	        chomp $keyfound;
             @temp=split /\s+/,$_;
             #my $STAT="STAT".$computLines;
             $RunValues{"STAT"    } =$temp[1];
             if ($temp[2] eq "STAT") {
                $StatMode = "STAT";
                $RunValues{"STATtime"    } =$temp[3];
             } elsif ($temp[1] eq "NONSTAT"){
                $Tbegc="Tbegc".$computLines;
                $deltac="deltac".$computLines;
                $Unitsc="Unitsc".$computLines;
                $Tendc="Tendc".$computLines;
                $RunValues{$Tbegc  } =$temp[2];
                $RunValues{$deltac } =$temp[3];
                $RunValues{$Unitsc } =$temp[4];
                $RunValues{$Tendc  } =$temp[5];
                undef $keyfound, @temp;
             }
           }
           if ($comline =~/^POINTS/)  {
             $numofOutputPoints+=1;
             #print " Searching for: Output Points ($numofOutputPoints)\n";
             $keyfound=$_;
	        chomp $keyfound;
             @temp=split /\s+/,$_;
             $pointName="pointname".$numofOutputPoints;
             $pointLong="pointlong".$numofOutputPoints;
             $pointLati="pointlati".$numofOutputPoints;
             $RunValues{$pointName } =$temp[1];
             $RunValues{$pointLong } =$temp[2];
             $RunValues{$pointLati } =$temp[3];
             undef $keyfound, @temp;  
           }
           #if ($comline =~/^SPECOUT/)  {
           if ($comline =~/SPEC1D/)  {
             $numofOutputSpectra+=1;
             #print " Searching for: Output Spectra ($numofOutputSpectra)\n";
             $keyfound=$_;
	     chomp $keyfound;
             @temp=split /\s+/,$_;
             $specName    = "SpecName".$numofOutputSpectra;
             $spec12D     = "SpecType".$numofOutputSpectra;
             $specType    = "SpecRelAbs".$numofOutputSpectra;
             $specOutFile = "SpecOutFile".$numofOutputSpectra;
             $RunValues{$specName  } =$temp[1];
             $RunValues{$spec12D    } =$temp[2];
             $RunValues{$specType   } =$temp[3];
             $RunValues{$specOutFile} =$temp[4];
             $timeUnit=$temp[8];
             if ($timeUnit eq "SEC") {
                $tmpfactor= 1;
             }elsif ($timeUnit eq "MIN"){
               $tmpfactor= 60;
             }elsif ($timeUnit eq "HR"){
               $tmpfactor= 3600;
             }elsif ($timeUnit eq "DAY"){
               $tmpfactor= 86400;
             }
             if ($numofOutputSpectra == 1) {
                $RunValues{"specTbegOut" } =$temp[6];
                $RunValues{"DeltaOut"} =$temp[7]*$tmpfactor;
             }
             undef $keyfound, @temp;
             
           }

           if ($comline =~/PTHSIGN/)  {
             $numofOutputPartition+=1;
             #print " Searching for: Output Spectra ($numofOutputSpectra)\n";
             $keyfound=$_;
	     chomp $keyfound;
             @temp=split /\s+/,$_;
             $partName    = "PartName".$numofOutputSpectra;
             $RunValues{$partName   } =$temp[1];
             undef $keyfound, @temp;
             
           }

 #
        }
    }
    $RunValues{"NumSpcOut"} =$numofOutputSpectra;
    $RunValues{"NumPrtOut"} =$numofOutputPartition;
# Formatting the start and end time strings for WW3 
    @temp=split //,$RunValues{"Tbegc1"};
    $temp[8]=" ";
    $Tbegc1=join ("", @temp,"00");
    undef @temp;
    $TFinal="Tendc".$computLines;
    @temp=split //,$RunValues{$TFinal};
    $temp[8]=" ";
    $Tendend=join ("", @temp,"00");
    undef @temp;

    $RunValues{"numofComputLines"} =$computLines;
    $RunValues{"RunTimeStart"} = $Tbegc1;
    $RunValues{"RunTimeEnd"  } = $Tendend;
    my $timeStepLength = $CG{LENGTHTIMESTEP};
    $RunValues{"NumOfOutTimes"}=floor(SWANFCSTLENGTH/$timeStepLength)+1;
    $RunValues{"DeltaOutput"}=$timeStepLength;


# Formatting the start and end time strings for output for WW3 
# TO DO  these times must be taken from a BLOCK commqand line
    @temp=split //,$RunValues{"specTbegOut"};
    $temp[8]=" ";
    $Tbegspc=join ("", @temp,"00");
    undef @temp, $RunValues{"specTbegOut"};
    $RunValues{"TbegOut"} =$Tbegspc;
    $RunValues{"TendOut"} =$RunValues{"RunTimeEnd"  };
    my $timeStepLength = $CG{LENGTHTIMESTEP};
#   now program has the botom filename
   my $bot_filename=$RunValues{"BOTname"};
   @char=split //, $bot_filename;
   undef $bot_filename;
   pop @char; shift @char; #scraching the apostrophes in the name
   $bot_filename=join ("", @char);

#Print all values in the hash
#   my $paranum=0;
#   print "\n Values for the Keywords\n";
#   while (($key, $value) = each(%RunValues)){
#     $paranum+=1;
#     print " $paranum: $key\t\t$value \n";
#   }
}
##
# ----------------------------------------------------------- 
# ******************************* 
# ********* End of File ********* 
# ******************************* 

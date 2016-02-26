#!/usr/bin/perl
# ----------------------------------------------------------- 
# PERL Script
# PERL Version(s): 5
# Original Author(s): Eve-Marie Devalire for WFO-Eureka 
# File Creation Date: 04/20/2004
# Date Last Modified: 11/15/2014
#
# Version control: 2.27
#
# Support Team:
#
# Contributors: Alex Gibbs, Tony Freeman, Pablo Santos, Douglas Gaer
# ----------------------------------------------------------- 
# ------------- Program Description and Details ------------- 
# ----------------------------------------------------------- 
#
################################################################################
#                               Archive package                                #
################################################################################
# 
################################################################################
#               The subroutines implemented here are the following:            #
################################################################################
#extractArchive
#copyWindFromArchive
#copyWavesFromArchive
#archiveFiles
#completeArchiveAndCleanup
################################################################################
#                   The packages used are the following:                       #
################################################################################
#Tie::File                                                                     #
################################################################################
#                   			NOTES                       	       #
################################################################################
# ----------------------------------------------------------- 

######################################################
#      Packages and exportation requirements         #
######################################################

package Archive;
use Tie::File;
use Data::Dumper;
@ISA=qw(Exporter);
@EXPORT=qw(extractArchive isRunFromArchive copyWindFromArchive copyWavesFromArchive archiveFiles completeArchiveAndCleanup);
use ConfigSwan;
use CommonSub qw(removeFiles removeOldFiles);
use Logs;

######################################################
#               Environment Variables                #
######################################################
# Setup our NWPS env
my $NWPSdir = $ENV{'HOMEnwps'};
my $PMnwps = $ENV{'PMnwps'};
my $DATA = $ENV{'DATA'};
my $ISPRODUCTION = $ENV{'ISPRODUCTION'};
my $DEBUGGING = $ENV{'DEBUGGING'};
my $DEBUG_LEVEL = $ENV{'DEBUG_LEVEL'};
my $siteid = $ENV{'siteid'};
my $SITEID = $ENV{'SITEID'};
my $TMPdir = $ENV{'TMPdir'};

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

#for_WCOSS
#codeArchive01
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
}

######################################################
#                    Subroutines                     #
######################################################

sub extractArchive {
    $runFromArchive = RUNFROMARCHIVE;
    &Logs::bug("begin extractArchive",1);
    chdir("${ARCHdir}/extract");
    system("cp -vfp ../$runFromArchive ./")==0 or &Logs::err("Cannot copy specified archive file ${ARCHdir}/$runFromArchive to extract directory: $!",2);
    system("tar -xzf $runFromArchive")==0 or &Logs::err("Cannot untar archive $runFromArchive : $!",2);
    &Logs::bug("end extractArchive",1);
}

sub isRunFromArchive {
    return (RUNFROMARCHIVE eq '') ? 0 : 1;
}

sub copyWindFromArchive {
    &Logs::bug("begin copyWindFromArchive",1);
    
    opendir(EXTDIR,"${ARCHdir}/extract");
    my @archFiles = grep /WIND/, readdir EXTDIR;
    closedir(EXTDIR);
    
    if(@archFiles==0) {&Logs::err("No wind file found in archive extract directory.",2);}
    if(@archFiles>1) {&Logs::err("There are multiple wind files in the archive extract directory, using $archFiles[0]",3);}
    
    system("cp -vfp ${ARCHdir}/extract/$archFiles[0] ${INPUTdir}/wind")==0 or &Logs::err("Cannot copy archived wind file ${ARCHdir}/extract/$archFiles[0] to wind input directory: $!",2);
    system("cp -vfp ${ARCHdir}/extract/$archFiles[0] ${ARCHdir}/pen")==0 or &Logs::err("Cannot copy archived wind file ${ARCHdir}/extract/$archFiles[0] to archive pen: $!",2);
    
    &Logs::bug("end copyWindFromArchive",1);
    return $archFiles[0];
}

sub copyWavesFromArchive {
    &Logs::bug("begin copyWavesFromArchive",1);
    
    opendir(ARCHDIR,"${ARCHdir}/extract");
    my @archFiles = grep /enp/, readdir ARCHDIR;
    closedir(ARCHDIR);
    
    system("cp -vfp ${ARCHdir}/extract/enp* ${INPUTdir}/wave")==0 or &Logs::err("Cannot copy archived wave files ${ARCHdir}/extract/enp* to wave input directory: $!",2);
    
    &Logs::bug("end copyWavesFromArchive",1);
    return \@archFiles;
}

sub archiveFiles {
    my $pattern = shift;
    my $dir = shift;
    
    # remove a trailing slash on the dir name if it exists.
    $dirToOpen = (substr($dir,-1) eq "/") ? substr($dir,0,-1) : $dir;
    opendir (DIR,$dirToOpen)  or &Logs::err("Directory can't be opened: $dirToOpen ($!)",2);
    my @filesInDir = readdir DIR;
    if(@filesInDir>0){
	my @filesToArchive=grep /$pattern/,@filesInDir;
	foreach $file (@filesToArchive){
	    &Logs::bug("Archiving file: $dirToOpen/$file",13);
	    system("cp -vfp $dirToOpen/$file ${ARCHdir}/pen")==0 or &Logs::err("Couldn't copy the file: $file to the archive pen ($!)",3);
	}
    } else{
	&Logs::err("No files found in directory $dirToOpen, cannot archive on pattern $pattern.",3);
    }
    closedir DIR;
}

sub completeArchiveAndCleanup {
    my $dateSuffix = shift;
    # Copy config and log files to archive pen and create tar file containing archive
    # of inputs and outputs of the run
    if(!&isRunFromArchive()){
	my $officeAcr = ${SITEID};
	system "mkdir -p ${ARCHdir}/pen";
	chdir("${DATA}");
	chdir("${LOGdir}");
	system "mkdir -p ${ARCHdir}/pen/logs";
        system "mkdir -p ${ARCHdir}/pen/templates";
        system "cp -fp ${NWPSdir}/fix/templates/* ${ARCHdir}/pen/templates";
        system "cp -fp ${PMnwps}/RunSwan.pm ${ARCHdir}/pen/templates";
        # system "cp -fp ${NWPSdir}/fix/bathy_db/${siteid}.tar.gz ${ARCHdir}/pen/templates";
	system "cp -fp *.log ${ARCHdir}/pen/logs";
	# Updated by AG for all raw input files: GFE wind/wlev..cur *.dat files/multi* before processed/grib2 
	# Updated for NWPS by Douglas.Gaer@noaa.gov
	chdir("${RUNdir}");
	system "cp -fp *.log ${ARCHdir}/pen/logs";
        system "cp -fp *.flag ${ARCHdir}/pen &> /dev/null";
        system "cp -fp *.raw ${ARCHdir}/pen &> /dev/null";
        system "cp -fp inputCG* ${ARCHdir}/pen &> /dev/null";
        # get GFE processed netcdf text wind file
        chdir("${INPUTdir}");
        system "cp -fp *.gz ${ARCHdir}/pen/";
        #archive domain file
        system "cp ${NWPSdir}/fix/domains/${SITEID} ${ARCHdir}/pen/";
        # get raw .dat estofs & rtofs files
        system "cp ${RUNdir}/*.cur ${ARCHdir}/pen/";
        system "cp ${RUNdir}/*.wlev ${ARCHdir}/pen/"; 
        # get final grib2 data
        chdir("${OUTPUTdir}/grib2/CG1");
        system "cp -fp * ${ARCHdir}/pen/";
        chdir("${OUTPUTdir}/grib2/CG2");
        system "cp -fp * ${ARCHdir}/pen/";
        # finalize multi-# boundary condition files for package (raw files, not processed)
	chdir("${ARCHdir}/pen");
        system "mv ${TMPdir}/multi_* ${ARCHdir}/pen/";
        system "cp ${DATAdir}/ldm/wna/*.spec ${ARCHdir}/pen/";

        # archive TAFB boundary condition file if used
        system "cp -fp ${RUNdir}/bc_${SITEID}* ${ARCHdir}/pen/"; 
	system "tar -czf ../NWPS_".$officeAcr."_ARCHIVE.$dateSuffix.tgz *";
    	system "rm -rf ${ARCHdir}/pen/logs";
    } else{
	&Logs::run("Compare output from this run to the archived output");
	&compareNewOutputToArchived();
    }
    
    # Touch any specified archive files to keep from being removed by removeOldFiles
    foreach my $savefile (%ConfigSwan::SAVEARCHIVEFILES){
	system("touch ${ARCHdir}/$savefile")==0 or &Logs::err("Couldn't touch the file: $savefile ($!)",3);
    }
    
    # Clean up directory structure
    my $pattern = "TAB|spec|GRID";
    
    &CommonSub::removeFiles($pattern,"${OUTPUTdir}/grid");
#    &CommonSub::removeFiles("enp|wnd|NGRID|INPUT|PRINT","${RUNdir}");
    &CommonSub::removeFiles("enp|spec|NGRID|PRINT","${RUNdir}");
    &CommonSub::removeFiles("vectorPlot","${OUTPUTdir}/vector");
    &CommonSub::removeFiles('\w+',"${ARCHdir}/pen") if(!&isRunFromArchive());
    
    foreach my $gcg (keys(%ConfigSwan::GRAPHICOUTPUTCGS)){
	&CommonSub::removeOldFiles(%ConfigSwan::NDAYSARCHIVE,'\w+',$ConfigSwan::GRAPHICOUTPUTCGS{$gcg});
    }
    foreach my $pcg (keys(%ConfigSwan::PARTITIONCGS)){
	&CommonSub::removeOldFiles(%ConfigSwan::NDAYSARCHIVE,'\w+',$ConfigSwan::PARTITIONCGS{$pcg});
    }
    &CommonSub::removeOldFiles(%ConfigSwan::NDAYSARCHIVE,'\w+',"${ARCHdir}");
    &CommonSub::removeOldFiles(%ConfigSwan::NDAYSARCHIVE,'\w+',"${OUTPUTdir}/netCdf/cdl");
    &CommonSub::removeOldFiles(%ConfigSwan::NDAYSARCHIVE,'\w+',"${OUTPUTdir}/vector/images");
}

sub compareNewOutputToArchived {
    &Logs::bug("begin compareNewOutputToArchived",1);
    
    opendir(OLDDIR,"${ARCHdir}/extract");
    my @oldFiles = readdir OLDDIR;
    closedir(OLDDIR);
    
    opendir(NEWDIR,"${ARCHdir}/pen");
    my @newFiles = readdir NEWDIR;
    closedir(NEWDIR);
    
    foreach my $old (@oldFiles){
	next if $old =~ /INPUT|PRINT|WIND|enp|ARCHIVE|Config|log.txt|vectorPlot|^\.$|\.\./;
	my @matchingFiles = grep /$old/,@newFiles;
	if(@matchingFiles==0){
	    &Logs::err("Can't find a match for ${ARCHdir}/extract/$old in ${ARCHdir}/pen, skipping file",3);
	    next;
	}
	(@matchingFiels>1) and &Logs::err("Multiple matches found for ${ARCHdir}/extract/$old in ${ARCHdir}/pen, using $matchingFiles[0]",3);
	# run diff command here
	&Logs::bug("comparing $old to $matchingFiles[0]",13);
	system("diff ${ARCHdir}/extract/$old ${ARCHdir}/pen/$matchingFiles[0] > ${ARCHdir}/pen/different");
	if(-z "${ARCHdir}/pen/different"){
	    &Logs::run("The file ${ARCHdir}/extract/$old is IDENTICAL to ${ARCHdir}/pen/$matchingFiles[0]");
	}else{
	    &Logs::run("The file ${ARCHdir}/extract/$old is DIFFERENT from ${ARCHdir}/pen/$matchingFiles[0]",3);
	}
    }	
    &Logs::bug("end compareNewOutputToArchived",1);	
}

################################################################################
1;



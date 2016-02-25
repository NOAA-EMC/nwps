#!/usr/bin/perl
# ----------------------------------------------------------- 
# PERL Script
# PERL Version(s): 5
# Original Author(s): Eve-Marie Devalire for WFO-Eureka 
# File Creation Date: 04/20/2004
# Date Last Modified: 11/17/2014
#
# Version control: 2.51
#
# Support Team:
#
# Contributors: Alex Gibbs, Tony Freeman, Pablo Santos, Douglas Gaer
#               Roberto Padilla-Hernandez
#
# GRIB2 encoding and HDF5 output added by Douglas.Gaer@noaa.gov
#
# Specrta 1d output added by Roberto Padilla-Hernandez
#
# ----------------------------------------------------------- 
# ------------- Program Description and Details ------------- 
# ----------------------------------------------------------- 
################################################################################
#                           GraphicOutput package                              #
################################################################################
# This package takes care of processing the grid output for the SWAN model,    #
# with retrieving the right files,processing for each doamin all the data types#
# we want and printing it in NetCdf format compatible with AWIPS and D2D.      #
# It then copies the files to the mounted output directory                     #
################################################################################
#               The subroutines implemented here are the following:            #
################################################################################
##graphicOutputProcessing                                                      #
##getValuesFromCommandFile                                                     #
##createHeader                                                                 #
##createData                                                                   #
##printNetCdfFile                                                              #
##transfertFiles                                                               #
##translateToAwips                                                             #
##toLatLon                                                                     #
##changeBadValues                                                              #
##convertFromScientificNotation                                                #
##fillInventoryValues                                                          #
##fillTimeValue                                                                #
################################################################################
#                   The packages used are the following:                       #
###############################################################################
#ArraySub                                                                      #
#CommonSub                                                                     #
#Tie::File                                                                     #
#Convert::SciEng                                                               #
#Time::Local                                                                   #
################################################################################
# ----------------------------------------------------------- 

######################################################
#      Packages and exportation requirements         #
######################################################
package GraphicOutput;
#use vars;
use Tie::File;
#use Convert::SciEng;
use Time::Local;
use Math::Trig;
use CommonSub qw(giveDate ftp mvFiles removeFiles removeOldFiles goForward copyFile 
renameFilesWithSuffix report giveNextEntryLine);
use ArraySub qw(takeUndefAway takeSpaceAway printArray printArrayIn formatArray
formatDoubleArray pushDoubleArray printDoubleArray takeSpaceAway giveMaxArray
giveMaxDoubleArray giveSumDoubleArray reverseDoubleArray);
require Exporter;
@ISA=qw(Exporter);
@EXPORT=qw(graphicOutputProcessing getValuesFromCommandFile);
use strict;
no strict 'refs';
no strict 'subs';
use ConfigSwan; 
#our $path=PATH;
our $PATH=$ENV{PATH};
use Archive qw(archiveFiles);

# Setup our NWPS env
my $NWPSdir = $ENV{'HOMEnwps'};
my $DATA = $ENV{'DATA'};
my $ISPRODUCTION = $ENV{'ISPRODUCTION'};
my $DEBUGGING = $ENV{'DEBUGGING'};
my $DEBUG_LEVEL = $ENV{'DEBUG_LEVEL'};
my $SITETYPE = $ENV{'SITETYPE'};
my $MODELTYPE = $ENV{'MODELTYPE'};
my $NCGEN = $ENV{'NCGEN'};
my $WGRIB2 = $ENV{'WGRIB2'};
my $SITEID = $ENV{'SITEID'};
my $siteid = $ENV{'siteid'};
my $GEN_NETCDF = $ENV{'GEN_NETCDF'};
my $GEN_HDF5 = $ENV{'GEN_HDF5'};
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
#for ww3 inclusion
my $MODELCORE = $ENV{'MODELCORE'};
our ($numOfFreq, @freqArray  );
our ($donotEnter, $spc1dYorN, $hasspcerror);
our (@spc1DFileNames, @valuesSpc1D, @headerSpc1D);
our (@spc1dLon,@spc1dLat);
our ($partitionYorN, $hasprterror, @partitionFileNames);
our (@prtLon,@prtLat,@prtFileNames,@prtShortName);
######################################################
#             Variables declarations                 #
######################################################

our $test=0;
our $template;
our $cg;
our $cgdirectory;
our $timeStepLength;
our $dimTimeStep;
our @data;#contain the data for each peace of information (particular data type for a particular location)
our @input;
our $gtop;
our @values;
our @header;
our @netCdfData;
our ($dimRecord,$dimValue,$filename,$lat00,$lon00,$centralLat,$centralLon,$latNxNy,$lonNxNy);
our $dateSuffix;
our (@dataX,@dataY);#same as above when data is described as a vector...
our (@dataMag,@dataDir);#resulting data (magnitude,direction) from the vector coordonates
######################################################
#                    Subroutines                     #
######################################################

################################################################################
# NAME: &graphicOutputProcessing
# CALL: &graphicOutputProcessing($cg)
# GOAL: This is the subroutine equivalent to the main. It is responsible for
#       retrieving the right files, create the netCdf file for each one of the
#       domain, and make them available to AWIPS
################################################################################
#
#for_WCOSS
#codeGraphicOutput01
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
#print "$NESTS, $RTOFS, $ESTOFS, $WINDS, $WEB, $PLOT, $MODELCORE, $LOGdir, $SITEID, $DATAdir\n";
#print "$GEN_NETCDF\n";
#codeGraphicOutput02
    my ($ARCHBITS, $MPIEXEC, $OPAL_PREFIX, $GADDIR, $GRIBMAP, $NCDUMP, $NCGEN, $GRADS);
    my ($DEGRIB, $LD_LIBRARY_PATH, $CPU, $CPUMHZ, $CPUCACHE, $MemTotal, $MemFree);
    my ($WGRIB2, $SwapTotal, $SwapFree, $NUMCPUS, $NCPUS);
    
    my $infoFile03 = "${RUNdir}/info_to_all_modules.txt";
    open IN, "<$infoFile03"  or die "Cannot open: $!";
    
    $ndata=0;
    while (<IN>) {
	$ndata+=1;
	chomp($_);
	if ($ndata ==1) {
	    $ARCHBITS=$_;
	}
	if ($ndata ==2) {
	    $MPIEXEC=$_;
	}
	if ($ndata ==3) {
	    $OPAL_PREFIX =$_;
	}
	if ($ndata ==4) {
	    $GADDIR=$_;
	}
	if ($ndata ==5) {
	    $GRIBMAP=$_;
	}
	if ($ndata ==6) {
	    $NCDUMP=$_;
	}
	if ($ndata ==7) {
	    $NCGEN=$_;
	}
	if ($ndata ==8) {
	    $GRADS=$_;
	}
	if ($ndata ==9) {
	    $WGRIB2=$_;
	}
	if ($ndata ==10) {
	    $DEGRIB=$_;
	}
	if ($ndata ==11) {
	    $PATH=$_;
	}
	if ($ndata ==12) {
	    $LD_LIBRARY_PATH=$_;
	}
	if ($ndata ==13) {
	    $CPU=$_;
	}
	if ($ndata ==14) {
	    $NUMCPUS=$_;
	}
	if ($ndata ==15) {
	    $NCPUS=$_;
	}
	if ($ndata ==16) {
	    $CPUMHZ=$_;
	}
	if ($ndata ==17) {
	    $CPUCACHE=$_;
	}
	if ($ndata ==18) {
	    $MemTotal=$_;
	}
	if ($ndata ==19) {
	    $MemFree=$_;
	}
	if ($ndata ==20) {
	    $SwapTotal=$_;
	}
	if ($ndata ==21) {
	    $SwapFree=$_;
	}
    }
    close IN;
    
#print "$ARCHBITS, $MPIEXEC, $OPAL_PREFIX, $GADDIR, $GRIBMAP, $NCDUMP, $NCGEN, $GRADS\n";
#print "$DEGRIB, $LD_LIBRARY_PATH, $CPU, $CPUMHZ, $CPUCACHE, $MemTotal, $MemFree\n";
#print "$WGRIB2, $SwapTotal, $SwapFree, $NUMCPUS, $NCPUS\n";
#print "PATH: $PATH\n";
#print "WGRIB2: $WGRIB2\n";
}


#
sub graphicOutputProcessing (%){
    Logs::bug("begin graphicOutputProcessing",1);
    my %CG = @_;
    my $dataType;
    my $cgnum = $CG{CGNUM};
    $cgdirectory = $CG{GRAPHICOUTPUTDIRECTORY};
#for WCOSS
#    $cgdirectory="${OUTPUTdir}/$cgdirectory";
    $timeStepLength = $CG{LENGTHTIMESTEP};  
    $template="cdlHeaderCG".$CG{CGNUM};
    $dimTimeStep=SWANFCSTLENGTH/$timeStepLength+1;
    ($dimRecord,$dimValue,$filename,$lat00,$lon00,$centralLat,$centralLon,$latNxNy,$lonNxNy)=&getValuesFromCommandFile("CG$cgnum");
    # have to define the array after having set the variables/
    #the following array is read by a subroutine, which look for the
    #pattern given by the first value. Then it replaces this line	
    #in the file by the following string if there is a '*' or
    #run the subroutine defined after the '/'to find the
    #replacement string,
    
    @values=(
	"netcdf*netcdf $filename {",
	"valtimes*\tn_valtimes = $dimTimeStep;",
	"x*\tx= $dimValue ;",
	"y*\ty= $dimRecord ;", 
	"centralLat*:centralLat =".sprintf("%.4f",$centralLat)."f ;",
	"centralLon*:centralLon =".sprintf("%.4f",$centralLon)."f ;",
	"lat00*:lat00 =".sprintf("%.4f",$lat00)."f ;",
	"lon00*:lon00 =".sprintf("%.4f",$lon00)."f ;",
	"latNxNy*:latNxNy =".sprintf("%.4f",$latNxNy)."f ;",
	"lonNxNy*:lonNxNy =".sprintf("%.4f",$lonNxNy)."f ;",
	"model* model = \"swanCG$cgnum\";",
	"model_id* model_id = 999$cgnum;",
	);
    
    chdir ("${OUTPUTdir}/grid/");
    
    # GRIB2 encoding written by: Douglas.Gaer@noaa.gov Southern Region Headquarters 
    # 05/17/2011: GRIB2 processing takes place here
    Logs::bug("Starting GRIB2 encoding",1);
    my $g2logfname = "${LOGdir}/grib2_encoding.log";
    Logs::bug("Creating GRIB2 files, logging results to ${g2logfname}",6);
#xxx    my $g2log = open(G2LOG, ">${g2logfname}");
    my $g2log = open(G2LOG, ">>${g2logfname}");
    if( ! $g2log ){
	Logs::bug("ERROR - Cannot create file ${g2logfname}",6);
    }
    system("date +%s > ${VARdir}/grib2_start_secs.txt");
    
    print G2LOG "Startring GRIB2 encoding process for raw SWAN output\n";
    system("date -u >> ${g2logfname}");
    
    system ("mkdir -pv ${OUTPUTdir}/grib2/CG${cgnum} >> ${g2logfname}");
    system ("mkdir -pv ${OUTPUTdir}/grib2/raw_swan_output_CG${cgnum} >> ${g2logfname}");
    system ("rm -fv ${OUTPUTdir}/grib2/raw_swan_output_CG${cgnum}/*CGRID* >> ${g2logfname}");
    
    # 05/17/2011: We must use the RAW output before it gets processed for netCDF and hdf5 output
    system ("cp -fpv ${OUTPUTdir}/grid/*CGRID* ${OUTPUTdir}/grib2/raw_swan_output_CG${cgnum}/. >> ${g2logfname}");
    
    chdir ("${OUTPUTdir}/grib2/raw_swan_output_CG${cgnum}");
    
    print G2LOG "Setting GRIB2 parameters for CG${cgnum}\n";
    my $g2NX=$dimValue;
    my $g2NY=$dimRecord;
    my $g2LA1=$lat00;
    my $g2LO1=$lon00;
    my $g2LA2=$latNxNy;
    my $g2LO2=$lonNxNy;
    # NOTE: If DX and DY is zero the template program will calculate the values
    my $g2DX=0;
    my $g2DY=0;
    my $g2_num_data_points = $g2NX * $g2NY;
    my $g2_time_step = $timeStepLength;
    my $g2_run_len = ($dimTimeStep -1) * $timeStepLength;
    if($g2_run_len <= 0) { 
	$g2_run_len = 1;
    }
    my $g2YEAR = substr($filename, 0, 4);
    my $g2YY = substr($g2YEAR, 2, 2);
    my $g2MONTH = substr($filename, 4, 2);
    my $g2DAY = substr($filename, 6, 2);
    my $g2HOUR = substr($filename, 9, 2);
    my $g2MINUTE = substr($filename, 11, 2);
    my $g2SECOND = "00";
    
    print G2LOG "g2NX = $g2NX\n";
    print G2LOG "g2NY = $g2NY\n";
    print G2LOG "g2LA1 = $g2LA1\n";
    print G2LOG "g2LO1 = $g2LO1\n";
    print G2LOG "g2LA2 = $g2LA2\n";
    print G2LOG "g2LO2 = $g2LO2\n";
    print G2LOG "g2DX = $g2DX\n";
    print G2LOG "g2DY = $g2DY\n";
    print G2LOG "g2_num_data_points  = $g2_num_data_points\n";
    print G2LOG "g2_time_step  = $g2_time_step\n";
    print G2LOG "g2_run_len = $g2_run_len\n";
    print G2LOG "g2YEAR = $g2YEAR\n";
    print G2LOG "g2YY = $g2YY\n";
    print G2LOG "g2MONTH = $g2MONTH\n";
    print G2LOG "g2DAY = $g2DAY\n";
    print G2LOG "g2HOUR = $g2HOUR\n";
    print G2LOG "g2MINUTE = $g2MINUTE\n";
    print G2LOG "g2SECOND = $g2SECOND\n";
    
    foreach (@{$CG{OUTPUTDATATYPES}}) {
	print G2LOG "Processing GRIB2 dataType $_\n";
	my $g2DataType=$_;
	my $num_componets = 1;
	
	# TODO: To exclude any variables from the GRIB2 file, do that in the IF statements below
	if ($g2DataType eq 'spc1d') { 
	    next;
	}
	if ($g2DataType eq 'partition' ) {
	    next;
	}

	# TODO: Ensure all GRIB2 variables are mapped to SWAN outputs in IF statements below
	if ($g2DataType eq 'htsgw') { 
	    $g2DataType='HSIG'; 
	}
	if ($g2DataType eq 'depth') { 
	    $g2DataType='DEPTH'; 
	}
	if ($g2DataType eq 'dirpw') { 
	    $g2DataType='PDIR'; 
	}
	if ($g2DataType eq 'perpw') { 
	    $g2DataType='TPS'; 
	}
	if ($g2DataType eq 'WLEN') { 
	    $g2DataType='WLEN'; 
	}
	if ($g2DataType eq 'brkw') { 
	    $g2DataType='DISSU'; 
	}
	if ($g2DataType eq 'swell') { 
	    $g2DataType='HSWE'; 
	}
	if ($g2DataType eq 'wlevel') { 
	    $g2DataType='WATL'; 
	}
	if ($g2DataType eq 'cur') {
	    $g2DataType='VEL';
	    $num_componets = 2;
	}
	if ($g2DataType eq 'wnd') {
	    $g2DataType='WIND';
	    $num_componets = 2;
	}
	
	# Process the SWAN raw output in ASCII point file format
	# Example file: HSIG.CG1.CGRID.YY11.MO01.DD25.HH00
	my $SWANCGIDFILE = "${g2DataType}.CG${cgnum}.CGRID.YY${g2YY}.MO${g2MONTH}.DD${g2DAY}.HH${g2HOUR}";
	print G2LOG "SWAN CGRID file: $SWANCGIDFILE\n";
	
	# Call C program that will convert the ASCII point file for all hours to an hourly BIN file per forecast hour
	# The BIN file is sequence of floating point values readable by GRADS, WGRIB2, CDO, DEGRIB, C and Fortran processing programs
	# Example command 1:  swan_out_to_bin HSIG.CG1.CGRID.YY11.MO01.DD25.HH00 627 3 1 24 
	# Example command 2:  swan_out_to_bin WIND.CG1.CGRID.YY11.MO01.DD25.HH00 627 3 2 24 dir mag speeddir
	if ($num_componets == 1) {
	    print G2LOG "System call: swan_out_to_bin ${SWANCGIDFILE} ${g2_num_data_points} ${g2_time_step} ${num_componets} ${g2_run_len} \
>> ${g2logfname}\n";
	    system("swan_out_to_bin ${SWANCGIDFILE} ${g2_num_data_points} ${g2_time_step} ${num_componets} ${g2_run_len} >> ${g2logfname}" );
	}
	else {
	    
	    print G2LOG "System call: swan_out_to_bin ${SWANCGIDFILE} ${g2_num_data_points} ${g2_time_step} ${num_componets} ${g2_run_len} dir mag speeddir \
>> ${g2logfname}\n";
	    system("swan_out_to_bin ${SWANCGIDFILE} ${g2_num_data_points} ${g2_time_step} ${num_componets} ${g2_run_len} dir mag speeddir >> ${g2logfname}" );
	}
	
	for(my $comp_count = 0; $comp_count <  $num_componets; $comp_count++) {
	    my $g2tempval = $g2DataType;
	    
	    if(($num_componets == 2) && ($comp_count == 0)) {
		$g2DataType = "${g2tempval}_dir";
		print G2LOG "Processing dir element of $g2DataType\n";
	    }
	    elsif (($num_componets == 2) && ($comp_count == 1)) {
		$g2DataType = "${g2tempval}_mag";
		print G2LOG "Processing mag element of $g2DataType\n";
	    }
	    else {
		$g2DataType = ${g2tempval};
	    }
	    
	    # Copy over our GRIB2 template and write a GRIB2 template file for this parameter
	    system("cp -pfv ${DATA}/parm/templates/${siteid}/${g2DataType}.meta  ${g2DataType}.meta  >> ${g2logfname}");
	    system("sed -i 's/<< SET START YEAR >>/${g2YEAR}/g' ${g2DataType}.meta >> ${g2logfname}");
	    system("sed -i 's/<< SET START MONTH >>/${g2MONTH}/g' ${g2DataType}.meta >> ${g2logfname}");
	    system("sed -i 's/<< SET START DAY >>/${g2DAY}/g' ${g2DataType}.meta >> ${g2logfname}");
	    system("sed -i 's/<< SET START HOUR >>/${g2HOUR}/g' ${g2DataType}.meta >> ${g2logfname}");
	    system("sed -i 's/<< SET START MINUTE >>/${g2MINUTE}/g' ${g2DataType}.meta >> ${g2logfname}");
	    system("sed -i 's/<< SET START SECOND >>/${g2SECOND}/g' ${g2DataType}.meta >> ${g2logfname}");
	    system("sed -i 's/<< SET NUM POINTS >>/${g2_num_data_points}/g' ${g2DataType}.meta >> ${g2logfname}");
	    system("sed -i 's/<< SET NX >>/${g2NX}/g' ${g2DataType}.meta >> ${g2logfname}");
	    system("sed -i 's/<< SET NY >>/${g2NY}/g' ${g2DataType}.meta >> ${g2logfname}");
	    system("sed -i 's/<< SET LA1 >>/${g2LA1}/g' ${g2DataType}.meta >> ${g2logfname}");
	    system("sed -i 's/<< SET LO1 >>/${g2LO1}/g' ${g2DataType}.meta >> ${g2logfname}");
	    system("sed -i 's/<< SET LA2 >>/${g2LA2}/g' ${g2DataType}.meta >> ${g2logfname}");
	    system("sed -i 's/<< SET LO2 >>/${g2LO2}/g' ${g2DataType}.meta >> ${g2logfname}");
	    system("sed -i 's/<< SET DX >>/${g2DX}/g' ${g2DataType}.meta >> ${g2logfname}");
	    system("sed -i 's/<< SET DY >>/${g2DY}/g' ${g2DataType}.meta >> ${g2logfname}");
	    
	    print G2LOG "Processing GRIB2 output for: $_ CG$cgnum $g2DataType $num_componets $dimTimeStep\n";
	    
	    my $g2_curr_fhour = 0;
	    my $g2_num_timesteps = $dimTimeStep-1;
	    if($g2_num_timesteps <= 0) { $g2_num_timesteps = 1; }
	    for(my $g2TS = 0; $g2TS < ($g2_num_timesteps+1); $g2TS++) {
		system("cp -pfv ${g2DataType}.meta ${g2DataType}.meta.current_hour >> ${g2logfname}");
		$g2_curr_fhour = $g2_time_step * $g2TS;
		system("sed -i 's/<< SET FORECAST HOUR >>/${g2_curr_fhour}/g' ${g2DataType}.meta.current_hour >> ${g2logfname}");
		
		# Write a GRIB2 template file
		# Example: g2_write_template varname.meta outfile.grb2
		system("g2_write_template ${g2DataType}.meta.current_hour ${g2DataType}_template.grib2 >> ${g2logfname}");
		
		# Get my BIN file for this GRIB2 variable
		my $BINFILE="${g2_curr_fhour}_${SWANCGIDFILE}.bin";
		if(($num_componets == 2) && ($comp_count == 0)) {
		    $BINFILE="${g2_curr_fhour}_direction_${SWANCGIDFILE}.bin";
		}
		elsif (($num_componets == 2) && ($comp_count == 1)) {
		    $BINFILE="${g2_curr_fhour}_speed_${SWANCGIDFILE}.bin";
		}
		else {
		    ;
		}
		print G2LOG "Processing file $BINFILE\n";
		
		# Enode the SWAN output into a GRIB2 file
		# Example wgrib2 HSIG_template.grib2 -no_header -import_bin point_values.bin -grib_out HSIG.grib2
		my $g2out = "${siteid}_nwps_CG${cgnum}_${g2DataType}_${g2YEAR}${g2MONTH}${g2DAY}_f${g2_curr_fhour}.grib2";
		print G2LOG "System call: ${WGRIB2} ${g2DataType}_template.grib2 -no_header -import_bin ${BINFILE} -grib_out ${g2out}\n";
		system("${WGRIB2} ${g2DataType}_template.grib2 -no_header -import_bin ${BINFILE} -grib_out ${g2out} >> ${g2logfname}");
	    }
	    $g2DataType =  $g2tempval;
	}
    }
    
    #  Cat all grib2 files into a single file for each CG by f${hour}
    my $g2_curr_fhour = 0;
    my $g2_num_timesteps = $dimTimeStep-1;
    my $g2out = "${siteid}_nwps_CG${cgnum}_${g2YEAR}${g2MONTH}${g2DAY}_${g2HOUR}${g2MINUTE}.grib2";
    print G2LOG "Creating GRIB2 output file: ${OUTPUTdir}/grib2/CG${cgnum}/${g2out}\n";
    system ("cat /dev/null > ${OUTPUTdir}/grib2/CG${cgnum}/${g2out}");
    my $g2infile = "NULL";
    if($g2_num_timesteps <= 0) { $g2_num_timesteps = 1; }
    
    # TODO: Ensure all GRIB2 variables are included in the array below
    my @g2_variables = ("HSIG","DEPTH","PDIR", "TPS", "WLEN", "DISSU", "HSWE", "WATL", "VEL_dir", "VEL_mag", "WIND_dir", "WIND_mag");
    for(my $g2TS = 0; $g2TS < ($g2_num_timesteps+1); $g2TS++) {
	$g2_curr_fhour = $g2_time_step * $g2TS;
	foreach (@g2_variables) { 
	    my $g2DataType = $_; 
	    print G2LOG "Adding: ${g2DataType} for forecast hour ${g2_curr_fhour}\n";
	    $g2infile = "${siteid}_nwps_CG${cgnum}_${g2DataType}_${g2YEAR}${g2MONTH}${g2DAY}_f${g2_curr_fhour}.grib2";
	    if( -e $g2infile ) {
		system ("cat ${g2infile} >> ${OUTPUTdir}/grib2/CG${cgnum}/${g2out}");
	    }
	    else {
		print G2LOG "WARNING - Input file does not exist: ${g2infile}\n";
	    }
	}
    }
    
    chdir ("${OUTPUTdir}/grib2/");
    if(${DEBUGGING} ne 'TRUE') {
	print G2LOG "Cleaning GRIB2 raw processing directory\n";
	system ("rm -fv ${OUTPUTdir}/grib2/raw_swan_output_CG${cgnum}/* >> ${g2logfname}");
	system ("rmdir ${OUTPUTdir}/grib2/raw_swan_output_CG${cgnum} >> ${g2logfname}");
    }
    
    system("date -u >> ${g2logfname}");
    system("date +%s > ${VARdir}/grib2_end_secs.txt");
    print G2LOG "GRIB2 encoding complete\n";
    close(G2LOG);
    Logs::bug("GRIB2 encoding complete",1);
    
    #RPH specta 1d changes
    Logs::bug("Starting specta 1d processing",1);
    
    my $spectralogfname = "${LOGdir}/spectra1d_encoding.log";
    Logs::bug("Creating spectra 1d files, logging results to ${spectralogfname}",6);
    my $spclog = open(SPCLOG, ">>${spectralogfname}");
    if( ! $spclog ){
	Logs::bug("ERROR - Cannot create file ${spectralogfname}",6);
    }
    system("date +%s > ${VARdir}/spectra1d_start_secs.txt");
    print SPCLOG "Startring spectra 1d encoding process for raw SWAN output\n";
    
    chdir("${RUNdir}");
    my $spc1DName;
    $spc1dYorN="NO";
    $hasspcerror="FALSE"; 
    @spc1DFileNames = &getSpc1DFileNames("CG$cgnum");

    if( $spc1dYorN eq 'YES' && $hasspcerror eq 'FALSE' ) { 
	print SPCLOG "We have spectra 1d raw SWAN output for this run\n";
	print SPCLOG "Starting spectra 1d processing for raw SWAN output\n";
	($numOfFreq)=&getFreqValueFromCommandFile("CG$cgnum");
	print SPCLOG "Number of frequencies = $numOfFreq\n";
	system("mkdir -p ${OUTPUTdir}/spectra/CG${cgnum}");
	chdir("${OUTPUTdir}/spectra/CG${cgnum}");
	my (undef,$spcyear,$spcmonth,$spcday,undef,$spchour)=unpack"A2 A2 A2 A2 A A2",$filename;
	my $spcdateSuffix="YY".$spcyear.".MO".$spcmonth.".DD".$spcday.".HH".$spchour;
	system("rm -f ${OUTPUTdir}/spectra/CG${cgnum}/SPC1D*.*");
	foreach $spc1DName (@spc1DFileNames) {
	    system("mv -f ${RUNdir}/${spc1DName} ${OUTPUTdir}/spectra/CG${cgnum}/${spc1DName}.${spcdateSuffix}");
	    print SPCLOG "Create spectra data file for ${spc1DName} CG${cgnum}\n";
	    &createDataSpc1D('spc1d', ${spc1DName}, "CG${cgnum}");
	    if($hasspcerror eq 'TRUE' ) { 
		print SPCLOG "ERROR - Fatal error processing ${OUTPUTdir}/spectra/CG${cgnum}/${spc1DName}.${spcdateSuffix}\n";
		print SPCLOG "ERROR - Will not be creating any spectra-1d output for CG${cgnum}\n";
		next;
	    }
	}
	
	if($hasspcerror eq 'TRUE' ) { 
	    $freqArray[0] = "ERROR, ";
	}
	chdir ("${DATA}");
	&addSpectraInfoToConfigSwan;
    }
    else {
	print SPCLOG "We have no spectra 1d raw SWAN output for this run\n";
	print SPCLOG "No spectra 1d file processed\n";
    }

    if( $spc1dYorN eq 'YES' && $hasspcerror eq 'FALSE' ) { 
	print SPCLOG "Plotting spectra-1d images\n";
	#system("${NWPSdir}/ush/grads/bin/plot_specta.sh ${cgnum} >> ${LOGdir}/spectra1d_encoding.log 2>&1"); 
	system("${NWPSdir}/ush/python/plot_specta.sh ${cgnum} >> ${LOGdir}/spectra1d_encoding.log 2>&1"); 
    }
    system("date +%s > ${VARdir}/spectra1d_end_secs.txt");
    print SPCLOG "Specta 1d processing complete\n";
    close(SPCLOG);
    Logs::bug("Specta 1d processing complete",1);
    #RPH specta 1d changes
#xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
#xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    # Partition addition BEGIN
    Logs::bug("Starting Partition processing",1);
    
    my $partitionlogfname = "${LOGdir}/partition_encoding.log";
    Logs::bug("Creating partition files, logging results to ${partitionlogfname}",6);
    my $prtlog = open(PRTLOG, ">${partitionlogfname}");
    if( ! $prtlog ){
	Logs::bug("ERROR - Cannot create file ${partitionlogfname}",6);
    }
    system("date +%s > ${VARdir}/partition_start_secs.txt");
    print PRTLOG "Startring partition encoding process for raw SWAN output\n";
    
    chdir("${RUNdir}");
    my $partitionName;
    $partitionYorN="NO";
    $hasprterror="FALSE"; 
    &getPrtNamesLonLat("CG$cgnum");
    my $i3;
    $i3=-1;
    foreach (@prtShortName) {
	$i3++;
	print PRTLOG "Filenum, Locname, Lon, Lat: $i3, $_, $prtLon[$i3],$prtLat[$i3]\n";
    }
    chdir ("${DATA}");
    &addPartitionInfoToConfigSwan;
    print PRTLOG "Create partition data file for @partitionFileNames\n";
    system("rm -vf ${OUTPUTdir}/partition/CG${cgnum}/PRT.*");
    close(PRTLOG);

    if( $GEN_NETCDF ne 'TRUE' ) {
	Logs::bug("end graphicOutputProcessing",1);
	close(PRTLOG);
	return;
    }
    
    Logs::bug("Starting netCDF encoding",1);
    system("date +%s > ${VARdir}/netcdf_start_secs.txt");
    chdir ("${OUTPUTdir}/grid/");
    &createHeader("CG$cgnum");
    foreach (@{$CG{OUTPUTDATATYPES}}) {
	Logs::bug("netCDF dataType=$_",6);
	Logs::bug("header created for CG$cgnum, create data for $_,CG$cgnum",6);
	if (($_ eq 'cur') || ($_ eq 'wnd')){
	    &createMagAndDirData($_,"CG$cgnum");
	} 
	else {
	    # TODO: To exclude any variables from the netCDF file, do that in the IF statements below
	    if ($_ eq 'spc1d') { 
		next;
	    }
	    if ($_ eq 'partition') { 
		next;
	    }
	    &createData($_,"CG$cgnum");
	}
	Logs::bug("data created for CG$cgnum",6);
    }
    
    chdir ("${OUTPUTdir}/netCdf/");
	print PRTLOG "=====printAndShipNetCdfFile \n";
    &printAndShipNetCdfFile("$cgnum");
	print PRTLOG "=====printAndShipNetCdfFile DONE \n";
    undef (@netCdfData);
    undef @header;
    system("date +%s > ${VARdir}/netcdf_end_secs.txt");
    Logs::bug("netCDF encoding complete",1);
    Logs::bug("end graphicOutputProcessing",1);
    close(PRTLOG);
}

################################################################################
# NAME: &createHeader();
# CALL: &createHeader();
# GOAL: create the header from a template changing the values which have to with
#       the values array described above and print it in the appropriate file
#       depending on the domain (CG1,CG2,CG3)
################################################################################

sub createHeader {
    Logs::bug("begin createHeader",1);
    # $template is the netCdf Header template
    my $pwd=`pwd`;
    # NOTE: We should not die here until will aleart that perl package has crashed
    open (TEMP, "<$template");
    if( ! TEMP ) {
	Logs::err("ERROR - Could not open netCDF template ${template}, halting run.",1);
    }
    
    @header=<TEMP>;
    close TEMP;
    chomp(@header);
    my $lineNumber=0;
    my ($pattern,$newValue);
    foreach (@values) {
	# DS -> NOTE: The next line splits @values on about the * character
	($pattern,$newValue)=split/\*/;
	$lineNumber=&giveNextEntryLine($pattern,$lineNumber,\@header);
	&changeLine($lineNumber,$newValue,\@header);
	$lineNumber++;#to start again from the following line
    }
    # DS -> NOTE: &fillTimeValue fills in the appropriate values associated with 
    # valtimeMINUSreftime in the netCDF file. 
    &fillTimeValue;
    
    # DS -> NOTE: &fillInventoryValues fills in the series of "1" in the 
    # (data type)Inventory series.
    &fillInventoryValues;
    Logs::bug("end createHeader",1);
}
	
################################################################################
# NAME: getValuesFromCommandFile
# CALL: &getValuesFromCommandFile()
# GOAL: take values from the swan command file concerned and return the values
#needed depending on the domain (CG1/CG2...)
################################################################################

sub getValuesFromCommandFile 
{
    Logs::bug("begin getValuesFromCommandFile",1);
    #declare all the following variables
    my $pwd=`pwd`;
    chdir "${RUNdir}";
    open (INPUT,"input$_[0]") or &report ("open file issue\ncan't open the
                file input$_[0]",2);
    @input=<INPUT>;
    close INPUT;
    chomp (@input);
    
    #capture domainOrigin from inputCGx file as well as the number of time
    #steps and number of spatial steps in X and Y(same number because
    #the grid is a square)
    my $lineNum; 	
    $lineNum=&giveNextEntryLine("CGRID",1,\@input);
    my @domainValues=split / /,$input[$lineNum];
    # the values indicates the number of spaces between values in the input
    #file, so we have to had one for each value, then '*8" is for the
    #timeSteps (recordNumber * timeStep)
    my ($dimRecord,$dimXY)=(($domainValues[7]+1),$domainValues[6]+1);
    
    #in the following part we transform the lat/lon to AWIPS coordonate and
    #then back to lat/lon to be able to calculate the lat/lon for the center.
    #domain extent is not this value but we'll need the difference between
    #these values of domainExtent and domainOrigin to find the real
    #domainExtent. The difference itself can't be calculated because the
    #numbers are too small and consequently not supported by AWIPS format
    my ($lonOrigin,$latOrigin,$lonExtent,$latExtent)=($domainValues[1],
						      $domainValues[2],$domainValues[4]+$domainValues[1],
						      $domainValues[5]+$domainValues[2]);
    $lonOrigin=$lonOrigin-360;#we have the latitude from the east and want it from west 
    $lonExtent=$lonExtent-360;
    
    #now that we have the AWIPS coordonates for the domain origin point
    #(Lower Left) and the domain extent point (upper right)we can figure out
    #the ones for the center of the domain
    my $centraLat=($latOrigin+$latExtent)/2;
    my $centralLon=($lonOrigin+$lonExtent)/2;
    #figure out the first computation time (it will become the filename)
    $lineNum=&giveNextEntryLine("^COMPUTE",$lineNum,\@input);
    $input[$lineNum]=~/(\d+).(\d+)/;
    my $fileName="$1_$2";#that is how it knows the reference time
    
    $centraLat=sprintf "%8.4f",$centraLat;
    $centralLon=sprintf "%8.4f",$centralLon;
    $latExtent=sprintf "%8.4f",$latExtent;
    $lonExtent=sprintf "%8.4f",$lonExtent;
    
    Logs::bug("end getValuesFromCommandFile",1);
    return ($dimRecord,$dimXY,$fileName,$latOrigin,$lonOrigin,$centraLat,$centralLon,$latExtent,$lonExtent);
}

################################################################################
# NAME: &createData
# CALL: &createData($dataType,$domain)
# GOAL: create the data part of the netCdf file  with each type of data
#       currently: significant wave height, period and direction
#
# NOTE: The AWIPS I netCDF creation using in memory arrays will explode in memory
# NOTE: when processing large and/or hi-resolution domains. This will cause 
# NOTE: the post processing use several GB of system memory and can make the post
# NOTE: procssing take 10 to 20 minutes to complete. The netCDF creation can be
# NOTE: disabled in the NWPS model using GRIB2 as the primary model output.
################################################################################

sub createData {
    Logs::bug("begin createData",1);
    #improvement;link the data type to the corresponding file-> find
    #something else than if to deal with that not to have to add lines here
    #if add variables->certainly rename swan output depending on the data
    #type variables names (which depends on D2D configuration!!!)
    my ($dataType,$domain)=@_;
    Logs::bug("data type is $dataType",1);
    push @netCdfData, " $dataType =";
    $dataType='HSIG' if ($dataType eq 'htsgw');
    $dataType='DEPTH' if ($dataType eq 'depth');
    $dataType='PDIR' if ($dataType eq 'dirpw');
    $dataType='TPS' if ($dataType eq 'perpw');
    $dataType='WLEN' if ($dataType eq 'WLEN');
    $dataType='DISSU' if ($dataType eq 'brkw');
    $dataType='WATL' if ($dataType eq 'wlevel');
    $dataType='HSWE' if ($dataType eq 'swell');
    
    my $line;
    my (undef,$year,$month,$day,undef,$hour)=unpack"A2 A2 A2 A2 A A2",$filename;
    $dateSuffix="YY".$year.".MO".$month.".DD".$day.".HH".$hour;
    Logs::bug("dataType,domain,dateSuffix=$dataType.$domain.CGRID.$dateSuffix",6);
    open (DATA,"$dataType.$domain.CGRID.$dateSuffix") or Logs::err("The file $dataType.$domain.CGRID.$dateSuffix couldn't be opened, error:$!",2);
    
    my $iRecord=0;
    my $nRecord=$dimRecord*($dimTimeStep); #NB DIAGNOSTIC...changed 2 to 0
    my $nValues;
    my @temp;
    my @record;
    Logs::bug("dimRecord=$dimRecord dimTimeStep=$dimTimeStep nRecord=$nRecord dimValue=$dimValue",6);
    Logs::bug("The file $dataType.$domain.CGRID.$dateSuffix has been opened",6);
    while ($iRecord<$nRecord) {
	$nValues=0;
	until ($nValues==$dimValue){
	    $line=<DATA>; 
	    chomp $line;
	    @temp=split /\s+/,$line;
	    #to eliminate the first element of this temporary array
	    #which is undefined because of the split
	    shift @temp;
	    push @record,@temp;
	    undef @temp;
	    $nValues=@record;
	    Logs::bug("In until loop, dataType=$dataType, nValues=$nValues, dimValue=$dimValue",6);
	}
	push @data,@record;
	Logs::bug("In while loop, iRecord=$iRecord",6);
	$iRecord++;
	undef @record;
    }
    close DATA;
    &changeBadValues("data","-0.9000E+01","1.e+37")
	if (($dataType eq "HSIG")or($dataType eq "TPS")or($dataType eq "HSWE")or($dataType eq "WLEN"));
    &changeBadValues("data","-99","1.e+37")
	if ($dataType eq "DEPTH");
    &changeBadValues("data","-0.9990E+03","1.e+37")
	if ($dataType eq "PDIR");
    
    
    &convertFromScientificNotation("data");
    push @netCdfData, @data;
    undef (@data);
    Logs::bug("end createData",1);
}

################################################################################
# NAME: &createData
# CALL: &createData($dataType,$domain)
# GOAL: create the data part of the netCdf file  with each type of data
#       currently: significant wave height, period and direction
#
# NOTE: The AWIPS I netCDF creation using in memory arrays will explode in memory
# NOTE: when processing large and/or hi-resolution domains. This will cause 
# NOTE: the post processing use several GB of system memory and can make the post
# NOTE: procssing take 10 to 20 minutes to complete. The netCDF creation can be
# NOTE: disabled in the NWPS model using GRIB2 as the primary model output.
################################################################################
sub createMagAndDirData{
    Logs::bug("begin createMagAndDir",6);
    my ($dataType,$domain)=@_;
    my ($dataTypeMag,$dataTypeDir)=($dataType.'Mag',$dataType.'Dir');
    $dataType='VEL' if ($dataType eq 'cur');
    $dataType='WIND' if ($dataType eq 'wnd');
    my $line;
    my (undef,$year,$month,$day,undef,$hour)=unpack"A2 A2 A2 A2 A A2",$filename;
    $dateSuffix="YY".$year.".MO".$month.".DD".$day.".HH".$hour;
    Logs::bug("dataType,domain,dateSuffix=$dataType.$domain.CGRID.$dateSuffix",6);
    open (DATA,"$dataType.$domain.CGRID.$dateSuffix") or Logs::err("The file $dataType.$domain.CGRID.$dateSuffix hasn't been opened, error:$!",2);
    my $iRecord=0;
    my $nRecord=$dimRecord*($dimTimeStep-2); #NB DIAGNOSTIC...2 is ok
    my $nValues;
    my @temp;
    my @record;
    my $ts=0;
    Logs::bug("inmage and dir dimRecord=$dimRecord dimTimeStep=$dimTimeStep nRecord=$nRecord dimValue=$dimValue",6);
    Logs::bug("dimRecord=$dimRecord dimTimeStep=$dimTimeStep dimValue=$dimValue",6);
    Logs::bug("The file $dataType.$domain.CGRID.$dateSuffix has been opened",6);
    while ($ts<($dimTimeStep)){	#NB DIAGNOSTIC...eliminated "2" from "$dimTimeStep-2"
	$iRecord=0;
	until ($iRecord==$dimRecord){
	    $nValues=0;
	    until ($nValues==$dimValue){
		$line=<DATA>;
		chop $line;
		@temp=split /\s+/,$line;
		#to eliminate the first element of this temporary array
		#which is undefined because of the split
		shift @temp;
		push @record,@temp;
		undef @temp;
		$nValues=@record;
		
	    }
	    push @dataX,@record;
	    undef @record;
	    $iRecord++;
	}
	$iRecord=0;
	until ($iRecord==$dimRecord){
	    $nValues=0;
	    until ($nValues==$dimValue){
		$line=<DATA>;
		chop $line;
		@temp=split /\s+/,$line;
		#to eliminate the first element of this temporary array
		#which is undefined because of the split
		shift @temp;
		push @record,@temp;
		undef @temp;
		$nValues=@record;
		
	    }
	    push @dataY,@record;
	    $iRecord++;
	    undef @record;
	}
	$ts++;
    }
    close DATA;
    &convertFromScientificNotation("dataX");
    &convertFromScientificNotation("dataY");
    &findSpeedAndDir();
    push @netCdfData, " $dataTypeMag =";
    push @netCdfData, @dataMag;
    push @netCdfData, " $dataTypeDir =";
    push @netCdfData, @dataDir;
    undef (@dataX);
    undef (@dataY);
    Logs::bug("end createMagAndDir",6);
}

################################################################################
# NAME: &convertFromScientificNotation
# CALL:&convertFromScientificNotation();
# GOAL:convert the data array from scientific notation to float
################################################################################

sub convertFromScientificNotation
{
    my $name=$_[0];
    my $i;
    foreach $i (0 .. $#$name)
    {
	$$name[$i]=~s/E/e/;
	$$name[$i]=sprintf "%4.2f",$$name[$i];
	unless ($name=~/X/ || $name=~/Y/)#because we are changing the values for dataX and dataY afterwards
	    # so we don't want the comas to be in the value
	{
	    #use this subroutine to add a coma, too (format requirement)
	    $$name[$i]=$$name[$i]."," unless ($i==$#$name);
	    #use this subroutine to add a semi-column for the last one, too
	    $$name[$i]=$$name[$i]." ;" if ($i==$#$name);
	}
    }
    
}
	
################################################################################
# NAME: &printNetCdfFile
# CALL: &printNetCdfFile();
# GOAL: print the header and the data part in the text netCdf output file.
################################################################################

sub printAndShipNetCdfFile {
    Logs::bug("begin printAndShipNetCdfFile",1);
    my $file=$filename; 
    my ($cgnum) = @_;
    open (OUT,">>$file.cdl") or Logs::err("the file $file.cdl associated to the filehandle OUT has not been opened in writting correctly, error $!",1);
    my $nValuesOnLine=13;
    my $iValuesOnLine=0;
    my $iValues=0;
    foreach (@header) {
	print OUT "$_\n";
    }
    foreach (@netCdfData) {
	if ($_!~/=/) {  #because of the name of the data set
	    #to have 15 values per line at the most and to go to a
	    #new line for every record
	    print OUT " \n   " if (($iValuesOnLine==$nValuesOnLine)
				   && ($iValuesOnLine!=0));
	    print OUT "\n " if ((($iValues % $dimValue)==0
				 && ($iValuesOnLine!=0)) or ($iValues==0));
	    $iValuesOnLine=0 if (($iValuesOnLine==$nValuesOnLine)
				 or (($iValues % $dimValue)==0));
	    print OUT " $_";
	    $iValuesOnLine++;
	    $iValues++;
	} else {
	    print OUT "\n\n$_\n";
	}
    }
    print OUT "\n}";
    close OUT;
    
    # transform the text version (called cdl file) of the netCdf file into
    #a binary version with 'ncgen'
    
    if( ${GEN_NETCDF} eq 'TRUE') { 
	system ("${NCGEN} -o $file $file.cdl")==0 or Logs::err("Can't create netCdf file from $file.cdl : $!",1);
    }

    system ("mkdir -p ${OUTPUTdir}/netCdf/CG${cgnum}");
    system ("mkdir -p ${OUTPUTdir}/hdf5/CG${cgnum}");
    
    if( (${GEN_HDF5} eq 'TRUE') && (${GEN_NETCDF} eq 'TRUE') ) { 
	# HDF5 creation if enabled
	system("${NCGEN} -k 3 $file.cdl -o $file.hdf5")==0 or Logs::err("Can't create HDF5 file from $file.cdl : $!",1);
	system("mv -vf ${OUTPUTdir}/netCdf/$file.hdf5 ${OUTPUTdir}/hdf5/CG${cgnum}/$file.hdf5")==0 or Logs::err("Couldn't copy ${OUTPUTdir}/netCdf/$file.hdf5 to ${OUTPUTdir}/hdf5/CG${cgnum}/$file.hdf5 : $!",2);
    }
    &mvFiles("${OUTPUTdir}/netCdf/cdl/","$file.cdl");
    
    # temporarily rename and archive file
    system("cp -vfp ${OUTPUTdir}/netCdf/$file ${OUTPUTdir}/netCdf/$file.CG$cg")==0 or Logs::err("Couldn't copy ${OUTPUTdir}/netCdf/$file to ${OUTPUTdir}/netCdf/$file.CG$cg : $!",1);
    &archiveFiles("$file.CG$cg","${OUTPUTdir}/netCdf");
    system("rm -vf ${OUTPUTdir}/netCdf/$file.CG$cg")==0 or Logs::err("Couldn't remove file $file.CG$cg : $!",1);
    
    system("mv -vf ${OUTPUTdir}/netCdf/$file $cgdirectory/.")==0 or Logs::err("Couldn't move ${OUTPUTdir}/netCdf/$file to $cgdirectory/.",1);
    
    Logs::bug("end printAndShipNetCdfFile",1);
}

################################################################################
# NAME: &translateToAwips
# CALL:&translateToAwips($valueX,$valueY);
# GOAL:translate the values in argument into AWIPS coordonates
#	plesae refer to the wind input package for more details about this process
################################################################################

sub translateToAwips
{
    #set pi value
    my $pi=atan(1)*4;
    
    #transform arguments in radians
    my $phi=$_[0]*($pi/180);
    my $lambda=-$_[1]*($pi/180);
    
    #set the parameters
    my $phi0=25*($pi/180);
    my $lambda0=95*($pi/180);
    my $n=sin($phi0);
    my $f=(cos($phi0)*((sin($pi/4+$phi0/2)/cos($pi/4+$phi0/2))**$n))/$n;
    my $rho0=cos($phi0)/sin($phi0);
    my $rho=$f/((sin($pi/4+$phi/2)/cos($pi/4+$phi/2))**$n);
    my $theta=$n*($lambda-$lambda0);
    
    #make the translation
    my $xRad=-$rho*sin($theta);
    my $yRad=$rho0-$rho*cos($theta);
    my $xAwips=1+($xRad+0.6633)*(92/1.1735);
    my $yAwips=1+($yRad+0.1307)*(64/0.8163);
    return ($xAwips,$yAwips);
}
	
################################################################################
# NAME: &changeBadValues($arrayName,$badValue,$valueToReplaceWith);
# CALL:&changeBadValues($arrayName,$badValue,$valueToReplaceWith);
# GOAL: change the badValue into valueToReplaceWith for the array described
#       by arrayName, and report to tell how many changes were done
################################################################################

sub changeBadValues
{
    my ($name,$badValue,$valueToReplaceWith)=@_;
    my $count=0;
    my $i;
    for $i (0 .. $#$name)
    {
	if ($$name[$i]==$badValue)
	{
	    $$name[$i]=$valueToReplaceWith;
	    $count++;
	}
    }
    Logs::bug("number of bad values\n$count values were bad and changed
                from $badValue to $valueToReplaceWith for $name",6);
}
	
################################################################################
# NAME: fillInventoryValues
# CALL: &fillInventoryValues($dataType)
# GOAL: create the inventory line depending on the time steps number and apply
#        this line as many time as needed (num of variables)
################################################################################

sub fillInventoryValues
{
    my $inventoryLine;
    my $i;
    my $line=&giveNextEntryLine("data_variables",1,\@header);
    foreach $i (0 .. $dimTimeStep-1) #NB DIAGNOSTIC...changed 2 to 1
    {
	$inventoryLine.='"1",';
    }
    chop($inventoryLine);
    $inventoryLine.=';';
    #to change inventory line only in data part
    $line=&giveNextEntryLine("data:",$line,\@header);
    $i=0;
    foreach (;;)
    {
	$line=&giveNextEntryLine("Inventory",$line,\@header);
	last if ($line==-1);
	$header[$line]=~"Inventory";
	my $prefix=$`;#RPH `
	$header[$line]=$prefix."Inventory = $inventoryLine";
	$line++;
	$i++;
    }
}
	
################################################################################
# NAME: fillTimeValue
# CALL: &fillTimeValue()
# GOAL: create the time line depending on the time steps number and write it
#        where it has to be
################################################################################
sub fillTimeValue
{
    my $value=0;
    my $i;
    my $timeLine="$value,";
    #to change time line only in data part
    my $line=&giveNextEntryLine("data:",1,\@header);
    $line=&giveNextEntryLine("MINUS",$line,\@header);
    foreach $i (0 .. ($dimTimeStep-2)){ #NB DIAGNOSTIC...changed 2 to 1
	$value+=$timeStepLength*3600;
	$timeLine.="$value,";
    }
    chop($timeLine);
    $timeLine.=";";
    $header[$line]=" valtimeMINUSreftime = $timeLine";
}
	
################################################################################
# NAME:  &toLatLon
# CALL:  &toLatLon($xAWIPS,$yAWIPS);
# GOAL:  to transform the coordinates of the domain described in the netCdf file
#        from AWIPS 211 grid to Longitude and Latitude
################################################################################

sub toLatLon
{
    #transform from AWIPS to radial coordinates
    my $xRAD=($_[0]-1)*(1.1735/92)-0.6633;
    my $yRAD=($_[1]-1)*(0.8163/64)-0.1307;
    
    #transform from radial to lat/lon
    my $pi=atan(1)*4;
    my $phiNOT=25*($pi/180);
    my $lambdaNOT=95*($pi/180);
    my $en=sin($phiNOT);
    my $eff=(cos($phiNOT)*((sin($pi/4+$phiNOT/2)/cos($pi/4+$phiNOT/2))**$en))/$en;
    my $rhoNOT=cos($phiNOT)/sin($phiNOT);
    my $rho=($xRAD**2+($rhoNOT-$yRAD)**2)**1.2;
    my $theta=atan($xRAD/($rhoNOT-$yRAD));
    my $phi=2*atan((($eff*cos($en*(($lambdaNOT-$theta/$en)-$lambdaNOT)))**(1/$en))/(($rhoNOT-$yRAD)**(1/$en)))-$pi/2;
    my $lambda=$lambdaNOT-$theta/$en;
    my $Latitude=(180/$pi)*$phi;
    my $Longitude=(180/$pi)*$lambda;
    return($Latitude,-$Longitude);
}

################################################################################
# NAME: &changeLine
# CALL: &changeLine($lineNum,$newValue,$arrayRef);
# GOAL: for a given array,change the line data given by the line number with
#       whereas the value given or execute a subroutine to find out the value to
#       replace with.
################################################################################
sub changeLine
{
    my ($lineNum,$newValue,$arrayRef)=@_;
    if ($newValue=~m#/#)#the string correspond to a reference
    {
	my $subName=$';#RPH'
	    &$subName;
    }
    else
    {
	$$arrayRef[$lineNum]=$newValue;
    }
}

################################################################################
# NAME: &findSpeedAndDir
# CALL: &findSpeedAndDir();
# GOAL: calculate the direction and the magnitude (speed) of a particulr type of
#       data, from the vector coordonate in @dataX and @dataY
################################################################################
sub findSpeedAndDir
{
    my $i=0;
    my $max=@dataX;
    $max++;
    my ($x,$y);
    undef @dataMag;
    undef @dataDir;
    while ($i<$max) {
	($x,$y)=($dataX[$i],$dataY[$i]);
	my $theta;#direction angle
	# the magnitude of the vector is given by:
	my $mag=sqrt($x**2+$y**2);
	my $pi=atan(1)*4;
	#The direction angle is assumed to be relative to north with a clockwise
	#direction being positive.  Assuming meteorologic convention (direction from)
	$theta=0 if ($x==0 and $y==0);
	$theta=180 if ($x==0 and $y>0);
	$theta=0 if ($x==0 and $y<0);
	$theta=270 if ($y==0 and $x>0);
	$theta=90 if ($y==0 and $x<0);
	$theta=270-atan($y/$x)*180/$pi if ($x>0 and $y>0);
	$theta=90-atan($y/$x)*180/$pi if ($x<0 and $y>0);
	$theta=90-atan($y/$x)*180/$pi if ($x<0 and $y<0);
	$theta=270-atan($y/$x)*180/$pi if ($x>0 and $y<0);
	$mag=1.9438*$mag; # NOTE: In this netCDF version we are converting m/s to knots here!!!
	$mag=sprintf "%2.2f",$mag;
	$theta=sprintf "%3d",$theta;

	# Account for missing input values and set to netCDF fill values
	if($dataX[$i] > 999) {
	    $mag = "1.e+37";
	    $theta = "1.e+37";
	}
	if($dataY[$i] > 999) {
	    $mag = "1.e+37";
	    $theta = "1.e+37";
	}

	push @dataMag,$mag."," unless ($i==$max-1);
	push @dataDir,$theta."," unless ($i==$max-1);
	push @dataMag,$mag.";" if ($i==$max-1);
	push @dataDir,$theta.";" if ($i==$max-1);
	$i++;
    }
}

################################################################################
# NAME: &convertToFeet
# CALL: &convertToFeet($arrayRef);
# GOAL: for a given array,convert the values from metyer to feet
################################################################################
sub convertToFeet
	{
	my $arrayRef=shift;
	my @array=@$arrayRef;
	foreach (@array)
		{
		$_=$_*3.2808399;
		}
	}                                                                                                                             
################################################################################

#RPH start
################################################################################
# NAME: getSpec1DFileNames                                                     #
# CALL: &getSpec1DFileNames                                                    #
# GOAL: Find and store the output filenames for the 1D spectra provided by the #
# user in the SWAN input file                                                  #
#                                                                              #
#Written by   :  Roberto Padilla-Hernandez  EMC/NCEP/MMAB/IMSG                 #
#                                                                              #
#Contributors: Douglas.Gaer@noaa.gov Southern Region Headquarters              #
#                                                                              #
#first written: 03/31/2011                                                     #
#last update:   08/25/2011
#                                                                              #
################################################################################
sub getSpc1DFileNames {
    my ($command   , $sought, $name, $numOfSpectra, $sought2 );
    my (@FilesNames, @temp  , @char,  @char1 );
    $sought="SPEC1D";
    $numOfSpectra=0;
    open (DATA,"input$_[0]");
    if(! DATA ) {
	$spc1dYorN = "NO";
	system("echo \"**Input file : input$_[0] could not be opened\" >> ${LOGdir}/spectra1d_encoding.log");
	return;
    }
    while (<DATA>) {
	if ($_ =~/$sought/) {
	    chomp $_;
	    @temp=split /\s+/,$_;
	    @char=split //, $temp[0];
	    $command=join ("", @char[0,1,2,3]);
	    if ($command eq "SPEC") {
		$numOfSpectra++;
		@char1=split //, $temp[4];
		pop @char1; shift @char1; #scraching the apostrophes in the name
		$name=join ("",@char1);
		push @FilesNames, $name;
	    }
	}
    }

#The subroutine has to close the file once it found the the OUTPUT POINT, because
#This point can be declared twice, as an ouput for spectra and for wave partition
#with the same name and coordinates, the subroutine stores the first it finds.
    $sought2='POINTS';
    for my $i1 (@FilesNames){
       my $fragment =  substr $i1, 6, -4;
       my $spc1dnames="'".$fragment."'";
       #print "Looking for: $spc1dnames\n";
       close DATA;
       open (DATA,"input$_[0]");
       while (<DATA>) {
	  if ($_ =~/$sought2/ && $_ =~/$spc1dnames/) {
             #print "LINE: $_\n";
	     chomp $_;
	     @temp=split /\s+/,$_;
	     @char=split //, $temp[0];
	     $command=join ("", @char[0,1,2,3]);
	     if ($command eq "POIN") {
                @char=undef; $command=undef;
                #print "Location, Lon, Lat: $spc1dnames $temp[2]  $temp[3]\n\n";
                push @spc1dLon, $temp[2];
                push @spc1dLat, $temp[3];
                last
	     }
	  }
       }
    }
    
    system("echo \"Filenames:  @FilesNames\" >> ${LOGdir}/spectra1d_encoding.log");
    if ($numOfSpectra > 0) { 
	$spc1dYorN = "YES"; 
    }
    else {
	$spc1dYorN = "NO"; 
    }

    if(${DEBUGGING} eq 'TRUE') {
	system("echo \"============================================\" >> ${LOGdir}/spectra1d_encoding.log");
	system("echo \" spectra yes/not:  $spc1dYorN\" >> ${LOGdir}/spectra1d_encoding.log");
	system("echo \"============================================\" >> ${LOGdir}/spectra1d_encoding.log");
    }
    
    close DATA;
    return(@FilesNames);
}

################################################################################
# NAME: &createDataSpc1D                                                       #
# CALL: &createDataSpc1D('spc1d', ${spc1DName}, "CG${cgnum}")                  #
# GOAL: Create a BIN file of floating point values that can be ploted by GRADS #
#                                                                              #
# Written by   :  Roberto Padilla-Hernandez  EMC/NCEP/MMAB/IMSG                #
#                                                                              #
# Contributors: Douglas.Gaer@noaa.gov Southern Region Headquarters             #
#                                                                              #
# first written: 03/31/2011                                                    #
# last update:   06/06/2011                                                    #
#                                                                              #
# Updated by Douglas.Gaer not to use in memory array for floating point values.#
# We now read the value and encode directly to a BIN file that GRADS can plot. #
#                                                                              #
################################################################################

sub createDataSpc1D {
    Logs::bug("begin createDataSpc1D",1);
    #improvement;link the data type to the corresponding file-> find
    #something else than if to deal with that not to have to add lines here
    #if add variables->certainly rename swan output depending on the data
    #type variables names (which depends on D2D configuration!!!)
    my ($dataType,$fname,$domain)=@_;
    
    $dataType='SPC1D' if ($dataType eq 'spc1d');
    my ($line, @temp, $numTimes, @record, @tempfind);
    my (undef,$year,$month,$day,undef,$hour)=unpack"A2 A2 A2 A2 A A2",$filename;
    $dateSuffix="YY".$year.".MO".$month.".DD".$day.".HH".$hour;

    open (DATA,"$fname.$dateSuffix");
    if( ! DATA ) {
        $spc1dYorN = "NO";
	$hasspcerror = "TRUE";
	system("echo \"IN createdataSpc1D: The file $fname.$dateSuffix couldn't be opened, error:$!\" >> ${LOGdir}/spectra1d_encoding.log");
	return;
    }
    my $nRecord=$numOfFreq*$dimTimeStep;

    system("echo \"dimTimeStep=${dimTimeStep} nRecord=${nRecord}\" >> ${LOGdir}/spectra1d_encoding.log");
    system("echo \"The file ${fname}.${dateSuffix} has been opened\" >> ${LOGdir}/spectra1d_encoding.log");
    
    $line=<DATA>;
    chomp $line;
    @temp=split /\s+/,$line;
    
    if ($donotEnter == 0){
	$donotEnter=1;
	until ($temp[0] eq "AFREQ"){
	    $line=<DATA>;
	    chomp $line;
	    @temp=split /\s+/,$line;
	}
	#Get the Frequency array
	$line=<DATA>; #This line is the number of freq.
	# 09/22/2011: Changed to fix Perl warnings about non-int type 
	#####
	@temp=split /\s+/,$line;
        $numOfFreq = $temp[1];
	######
	for (1..$numOfFreq){
	    $line=<DATA>; 
	    chomp $line;
	    @temp=split /\s+/,$line;
	    shift @temp;
	    if ($_ < $numOfFreq) {
		push @freqArray,$temp[0].",";
	    }
	    else{
		push @freqArray,$temp[0];
	    }
	    undef @temp;
       }
    }
    undef @tempfind;
    until ($tempfind[0] eq "LOCATION" || $tempfind[0] eq "NODATA") {
	  $line=<DATA>;
	  chomp $line;
	  @tempfind=split /\s+/,$line;
    }
   
    my $spcbinfile = open(SPCBINFILE, ">${fname}.${dateSuffix}.bin");
    if( ! $spcbinfile ){
	$spc1dYorN="NO";
	$hasspcerror = "TRUE";
	system("echo \"IN createdataSpc1D: Cannot create file ${fname}.${dateSuffix}.bin, error:$!\" >> ${LOGdir}/spectra1d_encoding.log");
	undef (@data);
	return;
    }
    binmode SPCBINFILE;
#==========================================================   
    if($tempfind[0] eq "LOCATION") { 
      until (eof(DATA)) {
	$line=<DATA>; 
	@temp=split /\s+/,$line;
	shift @temp;
        my $firstchar = substr($temp[0], 0, 1); # Returns the first character
	# 09/22/2011: TODO: Need to fixed if statement below to gid rid of Perl warnings
        # if($firstchar eq ' ') { # Check to see if We have a floating point value
        if($firstchar == ' ') { # Check to see if We have a floating point value
	    my $val = $temp[0];
	    $val =~ s/' '//; # Trim leading spaces
	    if ($val =~ /\d/ || $val =~ /^-?\d*\.?\d*$/ ) {
		# We have a floating point so pack into the BIN file
		print SPCBINFILE pack('f', $val);
	    }
	}
      }
    }
#==========================================================
    if($tempfind[0] eq "NODATA") { 
      until (eof(DATA)) {
	for (1..$numOfFreq){
	   my $val = "-0.9900E+02";
           print SPCBINFILE pack('f', $val);
	}
        $line=<DATA>; 
      }
    }
#==========================================================
    close(DATA);
    close(SPCBINFILE);
}

################################################################################
# NAME: addSpectraInfoToConfigSwan                                             #
# CALL: addSpectraInfoToConfigSwan                                             #
# GOAL: Adds the frequency array to CGinclude.pm to be used as the X-axis for  #
#       the plotting modules.                                                  #             
#                                                                              #
# Written by   :  Roberto Padilla-Hernandez  EMC/NCEP/MMAB/IMSG                #
#                                                                              #
# Contributors:                                                                #             
#                                                                              #
# first written: 03/20/2011                                                    #
# last update:                                                                 #
#                                                                              #
################################################################################
sub addSpectraInfoToConfigSwan{
    Logs::bug("begin addSpectraInfoToConfigSwan",1);
    my (@spc1dLonArray, @spc1dLatArray);
    my $namein = "${RUNdir}/CGinclude.pm";
    my $nameout= "${RUNdir}/CGinclude_02.pm";
    if( -e $nameout ) {
	system("rm -f ${nameout}");
    }
    my $this="FREQHERE"; my @that=@freqArray;
    my $this2="NOUTSPECTRA"; my $numoutspc=@spc1DFileNames;
    my $this3="SPECTRALNAMES"; my @spc1dNamesArray;
    my $this4="SPC1DLONS";
    my $this5="SPC1DLATS"; 
    my $i=0;
    foreach my $i1 (@spc1DFileNames) {
       my $fragment =  substr $i1, 6, -4;
       my $spc1DName="'".$fragment."'";
	push @spc1dNamesArray,$spc1DName;
	push @spc1dLonArray,$spc1dLon[$i];
	push @spc1dLatArray,$spc1dLat[$i];
	if($i < ($numoutspc-1)) { 
           push @spc1dNamesArray, ",";
           push @spc1dLonArray, ",";
           push @spc1dLatArray, ",";
 };
	$i++;
    }

    if( ! -e $namein ) {
	Logs::bug("ERROR - addSpectraInfoToConfigSwan function cannot open: ${namein}",6);
	return;
    }

    open IN, "<$namein";
    open OUT, ">$nameout";

    if( ! -e $nameout ) {
	Logs::bug("ERROR - addSpectraInfoToConfigSwan function cannot create: ${nameout}",6);
	return;
    }

    while (<IN>) {
	s/$this/@that/;
	s/$this2/$numoutspc/;
	s/$this3/@spc1dNamesArray/;
	s/$this4/@spc1dLonArray/;
	s/$this5/@spc1dLatArray/;
	print OUT $_;
    }
    close IN;
    close OUT; 
    system("echo \"IN addSpectraInfoToConfigSwan before cp\" >> ${LOGdir}/spectra1d_encoding.log");
    system("cp -vfp $nameout $namein");
    system("echo \"IN addSpectraInfoToConfigSwan after cp\" >> ${LOGdir}/spectra1d_encoding.log");
    system("rm -f $nameout");
}

################################################################################
# NAME: getFreqValueFromCommandFile
# CALL: &getFreqValueFromCommandFile(CGnumber)
# GOAL: take values from the swan command file concerned and return the freq value
#       needed depending on the domain (CG1/CG2...)
################################################################################

sub getFreqValueFromCommandFile {
    my $pwd=`pwd`;
    chdir "${RUNdir}";
    open (INPUT,"input$_[0]") or &report ("open file issue\ncan't open the
                file input$_[0]",2);
    @input=<INPUT>;
    close INPUT;
    chomp (@input);
    my $lineNum; 	
    $lineNum=&giveNextEntryLine("CGRID",1,\@input);
    my @domainValues=split / /,$input[$lineNum];
    my $nOF=$domainValues[12]+1;
    return ($nOF);
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
#last update: 03/15/2011                                                                  #
#                                                                              #
################################################################################
sub getPrtNamesLonLat {
    my ($sought1 , $name, $numOfPartLoc, @temp , @char,$longName   );
    my ($domain)=@_;
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
# NAME: addPartitionInfoToConfigSwan                                           #
# CALL: &addPartitionInfoToConfigSwan()                                        #
# GOAL: Adds the output location names to ConfigSwan.pm to be used in the      #
#       plotting modules                                                       #
#                                                                              #
# Written by   :  Roberto Padilla-Hernandez  EMC/NCEP/MMAB/IMSG                #
#                                                                              #
# Contributors:                                                                #
#                                                                              #
# first written: 07/11/2011                                                    #
# last update: 08/27/2011                                                      #
#                                                                              #
# Updates the CGinclude.pm file with information from partition command lines #
# from the user input file, this info will be used by plot_partition.sh        # 
################################################################################
sub addPartitionInfoToConfigSwan{
    Logs::bug("begin addPartitionInfoToConfigSwan",1);

    my (@partitionLonArray, @partitionLatArray, @partitionNamesArray);
    my $namein = "${RUNdir}/CGinclude.pm";
    my $nameout= "${RUNdir}/CGinclude_02.pm";
    if( -e $nameout ) {
	system("rm -f ${nameout}");
    }
    my $numoutprt=@prtShortName;
    my $this1="NOUTPARTITION"; 
    my $this2="PARTNAMES";
    my $this3="PARTLONS";
    my $this4="PARTLATS"; 
    my $i=0;
    foreach my $partitionName (@prtShortName) {
	push @partitionNamesArray,$partitionName;
	push @partitionLonArray,$prtLon[$i];
	push @partitionLatArray,$prtLat[$i];
	if($i < ($numoutprt-1)) {
           push @partitionNamesArray, ","; 
           push @partitionLonArray, ",";
           push @partitionLatArray, ",";
        }
	$i++;
    }

    if( ! -e $namein ) {
	Logs::bug("ERROR - addPartitionInfoToConfigSwan function cannot open: ${namein}",6);
	return;
    }

    open IN, "<$namein";
    open OUT, ">$nameout";

    if( ! -e $nameout ) {
	Logs::bug("ERROR - addPartitionInfoToConfigSwan function cannot create: ${nameout}",6);
        return;
    }

    while (<IN>) {
	s/$this1/$numoutprt/;
	s/$this2/@partitionNamesArray/;
	s/$this3/@partitionLonArray/;
	s/$this4/@partitionLatArray/;

	print OUT $_;
    }
    close IN;
    close OUT; 
    system("echo \"IN addPartitionInfoToConfigSwan before cp\" >> ${LOGdir}/partition_encoding.log");
    system("cp -vfp $nameout $namein");
    system("echo \"IN addPartitionInfoToConfigSwan after cp\" >> ${LOGdir}/partition_encoding.log");
    system("rm -f $nameout");
}

################################################################################
#RPH end

1;

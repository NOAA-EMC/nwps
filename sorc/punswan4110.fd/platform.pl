my $os  = `uname -s`;
   $os  = $^O unless chomp($os);

my $cpu = `uname -m`;
   $cpu = $^O unless chomp($cpu);


#Ali Salimi 2/8/23 Start
use Sys::Hostname;

my $hostname = hostname;

my $MACHINE_ID;

if ($hostname =~ /adecflow0[12].acorn.wcoss2.ncep.noaa.gov/) {
    $MACHINE_ID = "wcoss2";
} elsif ($hostname =~ /alogin0[12].acorn.wcoss2.ncep.noaa.gov/) {
    $MACHINE_ID = "wcoss2";
} elsif ($hostname =~ /clogin0[1-9].cactus.wcoss2.ncep.noaa.gov/) {
    $MACHINE_ID = "wcoss2";
} elsif ($hostname =~ /clogin10.cactus.wcoss2.ncep.noaa.gov/) {
    $MACHINE_ID = "wcoss2";
} elsif ($hostname =~ /dlogin0[1-9].dogwood.wcoss2.ncep.noaa.gov/) {
    $MACHINE_ID = "wcoss2";
} elsif ($hostname =~ /dlogin10.dogwood.wcoss2.ncep.noaa.gov/) {
    $MACHINE_ID = "wcoss2";
} elsif ($hostname =~ /hfe0[1-9]/) {
    $MACHINE_ID = "hera";
} elsif ($hostname =~ /hfe1[0-2]/) {
    $MACHINE_ID = "hera";
} elsif ($hostname =~ /hecflow01/) {
    $MACHINE_ID = "hera";
}

my $F90_MPI = '';
#Ali Salimi 2/8/23 Start

open(OUTFILE,">macros.inc");

if ($os =~ /Linux/i) {
  my $compiler = getcmpl();
  if ( $compiler eq "ifort" )
  {
    system 'rm ifort';
    if ($MACHINE_ID eq 'wcoss2') {       #Ali Salimi 2/8/23 Start
      $F90_MPI = 'ftn';
    }
    elsif ($MACHINE_ID eq 'hera') {
      $F90_MPI = 'mpiifort';
    }                                    #Ali Salimi 2/8/23 end

    print OUTFILE "##############################################################################\n";
    print OUTFILE "# IA32_Intel/x86-64_Intel:	Intel Pentium with Linux using Intel compiler 11.\n";
    print OUTFILE "##############################################################################\n";
    print OUTFILE "F90_SER = ifort\n";
    print OUTFILE "F90_OMP = ifort\n";
    print OUTFILE "F90_MPI = $F90_MPI\n";
    print OUTFILE "FLAGS_OPT = -c\n";
    print OUTFILE "FLAGS_MSC = -O1 \n";
    print OUTFILE "FLAGS90_MSC = \$(FLAGS_MSC)\n";
    print OUTFILE "FLAGS_DYN = -fPIC\n";
    print OUTFILE "FLAGS_SER =\n";
    print OUTFILE "FLAGS_OMP = -openmp\n";
    print OUTFILE "FLAGS_MPI =\n";
    print OUTFILE "NETCDFROOT = \$(NETCDF) \n";
    print OUTFILE "ifneq (\$(NETCDF),)\n";
    print OUTFILE "  INCS_SER = -I\$(NETCDF_INCLUDES) \n";
    print OUTFILE "  INCS_OMP = -I\$(NETCDF_INCLUDES) \n";
    print OUTFILE "  INCS_MPI = -I\$(NETCDF_INCLUDES) \n";
    print OUTFILE "  LIBS_SER = -L\$(NETCDF_LIBRARIES) -lnetcdff -lnetcdf -L\$(HDF5_LIBRARIES) -lhdf5_hl -lhdf5hl_fortran -lhdf5 -lhdf5_fortran -L\$(Z_LIB) -lz -ldl -lm\n";
    print OUTFILE "  LIBS_OMP = -L\$(NETCDF_LIBRARIES) -lnetcdff -lnetcdf -L\$(HDF5_LIBRARIES) -lhdf5_hl -lhdf5hl_fortran -lhdf5 -lhdf5_fortran -L\$(Z_LIB) -lz -ldl -lm\n";
    print OUTFILE "  LIBS_MPI = -L\$(NETCDF_LIBRARIES) -lnetcdff -lnetcdf -L\$(HDF5_LIBRARIES) -lhdf5_hl -lhdf5hl_fortran -lhdf5 -lhdf5_fortran -L\$(Z_LIB) -lz -ldl -lm\n";
    print OUTFILE "  NCF_OBJS = nctablemd.o agioncmd.o swn_outnc.o\n";
    print OUTFILE "else\n";
    print OUTFILE "  INCS_SER =\n";
    print OUTFILE "  INCS_OMP =\n";
    print OUTFILE "  INCS_MPI =\n";
    print OUTFILE "  LIBS_SER =\n";
    print OUTFILE "  LIBS_OMP =\n";
    print OUTFILE "  LIBS_MPI =\n";
    print OUTFILE "  NCF_OBJS =\n";
    print OUTFILE "endif\n";
    print OUTFILE "O_DIR = ../estofs_padcirc.fd/work/odir4/\n";
    print OUTFILE "OUT = -o \n";
    print OUTFILE "EXTO = o\n";
    print OUTFILE "MAKE = make\n";
    print OUTFILE "RM = rm -f\n";
    print OUTFILE "ifneq (\$(NETCDFROOT),)\n";
    print OUTFILE "  swch = -unix -impi -netcdf\n";
    print OUTFILE "else\n";
    print OUTFILE "  swch = -unix -impi\n";
    print OUTFILE "endif\n";
  }
  else
  {
    die "Current Fortran compiler '$compiler' not supported.... \n";
  }
}

close(OUTFILE);

# =============================================================================

sub getcmpl {

   my $compiler = $ENV{'FC'};

   unless ( $compiler ) {
      foreach ('ifort','f90','ifc','efc','pgf90','xlf90', 'lf95','gfortran','g95') {
         $compiler = $_;
         my $path  = `which $compiler`;
         last if $path;
      }
   }

   return $compiler;
}

# =============================================================================

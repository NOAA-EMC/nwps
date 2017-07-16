my $os  = `uname -s`;
   $os  = $^O unless chomp($os);

my $cpu = `uname -m`;
   $cpu = $^O unless chomp($cpu);

open(OUTFILE,">macros.inc");

if ($os =~ /Linux/i) {
  my $compiler = getcmpl();
  if ( $compiler eq "ifort" )
  {
    print OUTFILE "##############################################################################\n";
    print OUTFILE "# IA32_Intel/x86-64_Intel:	Intel Pentium with Linux using Intel compiler 11.\n";
    print OUTFILE "##############################################################################\n";
    print OUTFILE "F90_SER = ifort\n";
    print OUTFILE "F90_OMP = ifort\n";
    print OUTFILE "F90_MPI = ftn\n";
    print OUTFILE "FLAGS_OPT = -c\n";
    print OUTFILE "FLAGS_MSC = -g -O2 \n";
    print OUTFILE "FLAGS90_MSC = \$(FLAGS_MSC)\n";
    print OUTFILE "FLAGS_DYN = -fPIC\n";
    print OUTFILE "FLAGS_SER =\n";
    print OUTFILE "FLAGS_OMP = -openmp\n";
    print OUTFILE "FLAGS_MPI =\n";
    print OUTFILE "NETCDFROOT = \$(NETCDF) \n";
    print OUTFILE "ifneq (\$(NETCDF),)\n";
    print OUTFILE "  INCS_SER = \$(NETCDF_INCLUDE) \n";
    print OUTFILE "  INCS_OMP = \$(NETCDF_INCLUDE) \n";
    print OUTFILE "  INCS_MPI = \$(NETCDF_INCLUDE) \n";
    print OUTFILE "  LIBS_SER = \$(NETCDF_LDFLAGS) \$(HDF5_LDFLAGS) \$(Z_LIB)\n";
    print OUTFILE "  LIBS_OMP = \$(NETCDF_LDFLAGS) \$(HDF5_LDFLAGS) \$(Z_LIB)\n";
    print OUTFILE "  LIBS_MPI = \$(NETCDF_LDFLAGS) \$(HDF5_LDFLAGS) \$(Z_LIB)\n";
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

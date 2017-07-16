# SRCDIR is set in makefile or on the compile line
INCDIRS := -I . -I $(SRCDIR)/prep

########################################################################
# Compiler flags for Linux operating system on 64bit x86 CPU
#
ifeq ($(MACHINE)-$(OS),x86_64-linux-gnu)
#
# ***NOTE*** User must select between various Linux setups
#            by commenting/uncommenting the appropriate compiler
#
compiler=ncep
#COMP=ifort
#COMP_MPI=ftn
#C_COMP=icc
#C_COMP_MP=cc
#
# Compiler Flags for gfortran and gcc
ifeq ($(compiler),ncep)
  PPFC          := ${COMP} 
  FC            := ${COMP}
  PFC           := ${COMP_MPI} 
  INCDIRS       := $(INCDIRS) ${NETCDF_INCLUDE} ${HDF5_INCLUDE} -I ${Z_INC}
  FFLAGS1       :=  $(INCDIRS) -O2 -FI -assume byterecl -132 -assume buffered_io -fp-model strict -fp-model source
#  FFLAGS1       :=  $(INCDIRS) -O3 -FI -assume byterecl -132 -assume buffered_io -axCORE-AVX2
  ifeq ($(DEBUG),full)
     FFLAGS1       :=  $(INCDIRS) -g -O0 -traceback -debug -check all -i-dynamic -FI -assume byterecl -132 -DALL_TRACE -DFULL_STACK -DFLUSH_MESSAGES
  endif
  FFLAGS2       :=  $(FFLAGS1)
  FFLAGS3       :=  $(FFLAGS1)
  DA            :=  -DREAL8 -DLINUX -DCSCA
  DP            :=  -DREAL8 -DLINUX -DCSCA -DCMPI
  DPRE          :=  -DREAL8 -DLINUX
  ifeq ($(SWAN),enable)
     DPRE          := $(DPRE) -DADCSWAN
  endif
  IMODS         :=  -I
  CC            := ${C_COMP} 
  CCBE		:= ${C_COMP_MP} 
  CFLAGS        := $(INCDIRS) -O2 -m64 -DLINUX
#  CFLAGS        := $(INCDIRS) -O3 -m64 -DLINUX
  ifeq ($(DEBUG),full)
     CFLAGS        := $(INCDIRS) -g -O0 -march=k8 -m64 -mcmodel=medium -DLINUX
  endif
  CLIBS         :=
  FLIBS         :=
  MSGLIBS       :=
  NETCDFHOME    :=/usrx/local/prod/NetCDF/4.2/intel/haswell
#  HDF5HOME      :=/usrx/local/prod/HDF5/1.8.9/serial/intel/haswell/lib
#  ZHOME         :=/usrx/local/prod/zlib/1.2.7/intel/haswell/lib
  ifeq ($(NETCDF),enable)
     FLIBS          := $(FLIBS) ${NETCDF_LDFLAGS} ${NETCDF_LDFLAGS_C} ${HDF5_LDFLAGS} ${Z_LIB}
  endif
  $(warning (INFO) Corresponding machine found in cmplrflags.mk.)
  ifneq ($(FOUND),TRUE)
     FOUND := TRUE
  else
     MULTIPLE := TRUE
  endif
endif
#
endif


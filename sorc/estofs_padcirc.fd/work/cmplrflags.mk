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
  INCDIRS       := $(INCDIRS) -I ${NETCDF_INC} -I ${HDF5_INC} -I ${Z_INC}
  FFLAGS1       :=  $(INCDIRS) -O2 -FI -assume byterecl -132 -assume buffered_io -fp-model strict
  ifeq ($(DEBUG),full)
     FFLAGS1       :=  $(INCDIRS) -g -O0 -traceback -debug -check all -FI -assume byterecl -132 -DALL_TRACE -DFULL_STACK -DFLUSH_MESSAGES
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
  CCBE          := ${C_COMP_MP} 
  CFLAGS        := $(INCDIRS) -O1 -m64 -DLINUX
#  CFLAGS        := $(INCDIRS) -O3 -m64 -DLINUX
  ifeq ($(DEBUG),full)
     CFLAGS        := $(INCDIRS) -g -O0 -m64 -mcmodel=medium -DLINUX
  endif
  CLIBS         :=
  FLIBS         :=
  MSGLIBS       :=
  NETCDFHOME    :=${NETCDF_ROOT}
  HDF5HOME      :=${HDF5_ROOT}
#  ZHOME         :=
  ifeq ($(NETCDFen),enable)
     FLIBS          := $(FLIBS) -L${NETCDFHOME}/lib -lnetcdff -L$(HDF5HOME)/lib -lhdf5
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


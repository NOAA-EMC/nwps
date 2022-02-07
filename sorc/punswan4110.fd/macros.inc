##############################################################################
# IA32_Intel/x86-64_Intel:	Intel Pentium with Linux using Intel compiler 11.
##############################################################################
F90_SER = ifort
F90_OMP = ifort
F90_MPI = ftn
FLAGS_OPT = -c
FLAGS_MSC = -O1 
FLAGS90_MSC = $(FLAGS_MSC)
FLAGS_DYN = -fPIC
FLAGS_SER =
FLAGS_OMP = -openmp
FLAGS_MPI =
NETCDFROOT = $(NETCDF) 
ifneq ($(NETCDF),)
  INCS_SER = -I$(NETCDF_INCLUDES) 
  INCS_OMP = -I$(NETCDF_INCLUDES) 
  INCS_MPI = -I$(NETCDF_INCLUDES) 
  LIBS_SER = -L$(NETCDF_LIBRARIES) -lnetcdff -lnetcdf -L$(HDF5_LIBRARIES) -lhdf5_hl -lhdf5hl_fortran -lhdf5 -lhdf5_fortran $(Z_LIB)
  LIBS_OMP = -L$(NETCDF_LIBRARIES) -lnetcdff -lnetcdf -L$(HDF5_LIBRARIES) -lhdf5_hl -lhdf5hl_fortran -lhdf5 -lhdf5_fortran $(Z_LIB)
  LIBS_MPI = -L$(NETCDF_LIBRARIES) -lnetcdff -lnetcdf -L$(HDF5_LIBRARIES) -lhdf5_hl -lhdf5hl_fortran -lhdf5 -lhdf5_fortran $(Z_LIB)
  NCF_OBJS = nctablemd.o agioncmd.o swn_outnc.o
else
  INCS_SER =
  INCS_OMP =
  INCS_MPI =
  LIBS_SER =
  LIBS_OMP =
  LIBS_MPI =
  NCF_OBJS =
endif
O_DIR = ../estofs_padcirc.fd/work/odir4/
OUT = -o 
EXTO = o
MAKE = make
RM = rm -f
ifneq ($(NETCDFROOT),)
  swch = -unix -impi -netcdf
else
  swch = -unix -impi
endif

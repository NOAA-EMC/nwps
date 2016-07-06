##############################################################################
# IA32_Intel/x86-64_Intel:	Intel Pentium with Linux using Intel compiler 9.1.
##############################################################################
F90_SER = ifort
F90_OMP = ifort
F90_MPI = ftn
FLAGS_OPT = -c
FLAGS_MSC = -g -O2 
FLAGS90_MSC = $(FLAGS_MSC) -ffree-line-length-none
FLAGS_SER =
FLAGS_OMP = -openmp
FLAGS_MPI =
INCS_SER =
INCS_OMP =
INCS_MPI =
LIBS_SER =
LIBS_OMP =
LIBS_MPI =
OUT = -o 
EXTO = o
MAKE = make
RM = rm -f
swch = -unix -impi -cdate12

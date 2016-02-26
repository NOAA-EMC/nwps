#######################
#### Start of File ####
#######################
# --------------------------------------------------------------- 
# Makefile
# C/C++ Compiler : GNU gcc/g++ 4.4.4
# Orginal Author: Douglas.Gaer@noaa.gov
# File Creation Date: 04/18/2011
# Date Last Modified: 07/24/2014
#
# Version: 1.06
#
# Contributors:
# --------------------------------------------------------------- 
# --------------- Makefile Description and Details -------------- 
# --------------------------------------------------------------- 
#
# Makefile to build utility program
#
# --------------------------------------------------------------- 
SHELL = /bin/bash

# Define a name for the executable
PROJECT = readdat

# Additional C/C++ libraries
CLIBS =

# Additional Fortran libraries
FLIBS = 

# Define compiler and linker flags macros
CC = icc
CFLAGS := -v -Wall $(CFLAGS)
FFLAGS := $(FFLAGS)
COMPILE_ONLY = -c
OUTPUT = -o
#LFLAGS := -static $(LFLAGS)

# Build dependency rules
# ===============================================================
RTOFS_PROCESS_LL_DEP = 

# ===============================================================

# Compile the files and build the executable
# ===============================================================
all:	$(PROJECT) 

readdat.o:	readdat.c $(RTOFS_PROCESS_LL_DEP)
	$(CC) $(COMPILE_ONLY) $(CLAGS) readdat.c

OBJS = readdat.o

$(PROJECT):	$(OBJS)
	$(CC) $(CFLAGS) $(OBJS) $(OUTPUT) $(PROJECT) $(LFLAGS)
# ===============================================================

# Install the new binaries
# ===============================================================
install:
	mkdir -p ${NWPSdir}/exec
	cp $(PROJECT) ${NWPSdir}/exec/$(PROJECT)
	chmod 755 ${NWPSdir}/exec/$(PROJECT)

# Remove object files and the executable after running make 
# ===============================================================
clean:
	echo Removing all OBJECT files from working directory...
	rm -f *.o 

	echo Removing EXECUTABLE file from working directory...
	rm -f $(PROJECT)
# --------------------------------------------------------------- 
#####################
#### End of File ####
#####################

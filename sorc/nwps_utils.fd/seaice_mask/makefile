#######################
#### Start of File ####
#######################
# --------------------------------------------------------------- 
# Makefile
# C/C++ Compiler : GNU, Intel, Cray
# Orginal Author: Douglas.Gaer@noaa.gov
# File Creation Date: 04/18/2011
# Date Last Modified: 06/03/2016
#
# Version: 4.01
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
PROJECT = seaice_mask

# Release version = 1
# Debug version = 0
FINAL = 1

BUILD := $(BUILD)
COMPILER := $(COMPILER)

# Library paths
APP_PATH = .

# Setup our build environment
include ../env/build_c.env

# Build dependency rules
# ===============================================================
PROJECT_DEP = ../3plibs/direct_io/direct_io.h

# ===============================================================

# Compile the files and build the executable
# ===============================================================
all:	$(PROJECT) 

seaice_mask.o:	seaice_mask.c $(PROJECT_DEP)
	$(CC) $(COMPILE_ONLY) $(COMPILE_FLAGS) seaice_mask.c

direct_io.o:	../3plibs/direct_io/direct_io.c $(PROJECT_DEP)
	$(CC) $(COMPILE_ONLY) $(COMPILE_FLAGS) ../3plibs/direct_io/direct_io.c

OBJECTS = seaice_mask.o direct_io.o

$(PROJECT):	$(OBJECTS)
	$(CC) $(COMPILE_FLAGS) $(OBJECTS) $(LINK_LIBRARIES) -lm \
	$(OUTPUT) $(PROJECT) $(LINKER_FLAGS)
# ===============================================================

# Install the new binaries
# ===============================================================
install:
	mkdir -p ../../../exec
	cp -fv $(PROJECT) ../../../exec/$(PROJECT)
	chmod 755 ../../../exec/$(PROJECT)

# Remove object files and the executable after running make 
# ===============================================================
clean:
	echo Removing all OBJECT files from working directory...
	rm -f *.o 

	echo Removing EXECUTABLE file from working directory...
	rm -f $(PROJECT)

	echo Cleaning test data
	rm -f testdata/*.stdout
	rm -f testdata/*.stderr
# --------------------------------------------------------------- 
#####################
#### End of File ####
#####################

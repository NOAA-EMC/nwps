#######################
#### Start of File ####
#######################
# --------------------------------------------------------------- 
# Makefile Contents: Makefile for command line builds
# C/C++ Compiler Used: DJGPP gcc 2.7.2.1 compiled for MSDOS 
# Produced By: DataReel Software Development Team
# File Creation Date: 03/19/2002
# Date Last Modified: 10/19/2005
# --------------------------------------------------------------- 
# Define a name for the executable
PROJECT = testprog

PROJECT_INCLUDE_PATH = ../../include
PROJECT_SRC_PATH = ../../sorc
OBJ_EXT = .o
PATHSEP = /

ADD_INC_PATHS = -I$(PROJECT_INCLUDE_PATH)

# 64BIT_DEFMACS = -D__64_BIT_DATABASE_ENGINE__ -D_LARGEFILE64_SOURCE
ANSI_DEFMACS = -D__USE_ANSI_CPP__
BTREE_DEFMACS = -D__USE_BINARY_SEARCH__ -D__USE_SINGLE_COMPARE__ -D__USE_BTREE_CACHE__
CPP_DEFMACS = -D__USE_CPP_IOSTREAM__ -D__CPP_EXCEPTIONS__
DEBUG_DEFMACS = -D__USE_NATIVE_INT_TYPES__
DISPLAY_DEFMACS = -D__CONSOLE__
FILESYS_DEFMACS =
TESTCODE_DEFMACS = -D__USE_CRC32_TABLE_FUNCTIONS__ -D__USE_EDS_TEST_FUNCTIONS__
PS_DEFMACS = -D__USE_POSTSCRIPT_PRINTING__ 
HTM_DEFMACS = -D__USE_HTM_PRINTING__ 
TXT_DEFMACS = -D__USE_TEXT_PRINTING__
# IO_DEFMACS = -D__USE_SIGNAL_IO__

# Setup define macros
DEFMACS = -D__DOS__ -D__X86__ \
$(64BIT_DEFMACS) $(ANSI_DEFMACS) $(BTREE_DEFMACS) $(CPP_DEFMACS) \
$(DEBUG_DEFMACS) $(DISPLAY_DEFMACS) $(FILESYS_DEFMACS) $(TESTCODE_DEFMACS) \
$(PS_DEFMACS) $(HTM_DEFMACS) $(TXT_DEFMACS) $(IO_DEFMACS)

# Define macros for compiler and linker
CC = gcc
CPP = gcc 
LINKER = ld

# Define compiler and linker flags macros
COMPILE_FLAGS = -fhandle-exceptions -Wall $(DEFMACS) $(ADD_INC_PATHS)
COMPILE_ONLY = -c
OUTPUT = -o
CPP_FLAG = -lgpp -lstdcx -lm        
LFLAGS =  

# Set the path to the DataReel library
GCODE_LIB_DIR = ../..

# Set the project dependencies  
# ===============================================================
include ../../env/glibdeps.mak
# ===============================================================

# Compile the files and build the executable
# ===============================================================
all:	$(PROJECT)$(EXE_EXT)

include ../../env/glibobjs.mak
include project.mak

$(PROJECT):	$(OBJECTS)
	$(CC) $(CFLAGS) $(OBJECTS) $(OUTPUT) $(PROJECT) $(CPP_FLAG)
# ===============================================================

# Remove object files and the executable after running make 
# ===============================================================
clean:
	echo Removing all OBJECT files from working directory...
	rm -f *.o 

	echo Removing COFF file from working directory...
	rm -f $(PROJECT)

	echo Removing EXECUTABLE file from working directory...
	rm -f $(PROJECT).exe

	echo Removing all test LOG files from working directory...
	rm -f *.log 

	echo Removing all test OUT files from working directory...
	rm -f *.out 

	echo Removing all test EDS files from working directory...
	rm -f *.eds 

	echo Removing all test DATABASE files from working directory...
	rm -f *.gxd 

	echo Removing all test INDEX files from working directory...
	rm -f *.btx 
	rm -f *.gix

	echo Removing all test InfoHog files from working directory...
	rm -f *.ihd 
	rm -f *.ihx 
# --------------------------------------------------------------- 
#####################
#### End of File ####
#####################

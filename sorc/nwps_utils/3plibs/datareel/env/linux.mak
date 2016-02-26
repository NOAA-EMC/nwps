#######################
#### Start of File ####
#######################
# --------------------------------------------------------------- 
# Makefile Contents: Makefile for command line builds
# C/C++ Compiler Used: gcc version 3.4.4
# Produced By: DataReel Software Development Team
# File Creation Date: 05/25/2001
# Date Last Modified: 10/19/2005
# --------------------------------------------------------------- 
# Setup my path to the gxcode library
GCODE_LIB_DIR = ../..

include $(GCODE_LIB_DIR)/unixlib/linux.env

# Define a name for the executable
# PROJECT = 

# Compile the files and build the executable
# ===============================================================
all:	$(PROJECT)

include project.mak

# Setup the path to the gxcode library
GXCODE_LIB_PATH = -L$(GCODE_LIB_DIR)$(PATHSEP)unixlib
LIB_GXCODE = -lgxcode
# LIB_GXCODE = -lgxcode64

$(PROJECT):	$(OBJECTS)
	$(CXX) $(COMPILE_FLAGS) $(OBJECTS) \
	$(GXCODE_LIB_PATH) $(LIB_GXCODE) $(LIBRARIES) \
	$(OUTPUT) \
	$(PROJECT) $(LINKER_FLAGS)
# ===============================================================

# Remove object files and the executable after running make 
# ===============================================================
clean:
	echo Removing all OBJECT files from working directory...
	rm -f *.o 

	echo Removing EXECUTABLE file from working directory...
	rm -f $(PROJECT)

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

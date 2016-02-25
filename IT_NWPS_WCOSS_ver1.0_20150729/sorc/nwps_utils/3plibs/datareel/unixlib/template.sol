#######################
#### Start of File ####
#######################
# --------------------------------------------------------------- 
# Makefile Contents: Makefile for command line builds
# C/C++ Compiler Used: Sun WorkShop C++ 5.0 (4.2 compatibility mode)
# Produced By: DataReel Software Development Team
# File Creation Date: 05/25/2001
# Date Last Modified: 10/19/2005
# --------------------------------------------------------------- 
# Setup my path to the gxcode library
GCODE_LIB_DIR = #--> Set the absolute path here

include $(GCODE_LIB_DIR)/unix/solaris.env

# Define a name for the executable
PROJECT = testprog

# Build dependency rules
# ===============================================================
PROJECT_DEP =
# ===============================================================

# Compile the files and build the executable
# ===============================================================
all:	$(PROJECT)

$(PROJECT)$(OBJ_EXT):	$(PROJECT).cpp $(PROJECT_DEP)
	$(CXX) $(COMPILE_ONLY) $(COMPILE_FLAGS) $(PROJECT).cpp

# Object files
OBJECTS = $(PROJECT)$(OBJ_EXT)

# Library files
LIBRARIES = -lgxcode
# LIBRARIES = -lgxcode64 # 64-bit gxcode library

$(PROJECT):	$(OBJECTS)
	$(CXX) $(COMPILE_FLAGS) $(OBJECTS) \
	-L$(GCODE_LIB_DIR)$(PATHSEP)dlib $(LIBRARIES) \
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
# --------------------------------------------------------------- 
#####################
#### End of File ####
#####################

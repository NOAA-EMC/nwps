#######################
#### Start of File ####
#######################
# ---------------------------------------------------------------
# Makefile
# C/C++ Compiler Used: gcc version 4.4 or higher
# ---------------------------------------------------------------
# Define a name for the executable
PROJECT = read_awips_windfile
64BITCFG = 0
FINAL = 1

# Library paths
APP_PATH = ./
PROJCPPLIB = ../projection_cpp_lib

# GXD/GXS/GXT CPP library path
GCODE_LIB_DIR = ../3plibs/datareel

include ${PROJCPPLIB}/linux.env

PROJECT_DEP = 

# Compile the files and build the executable
# ===============================================================
all:    $(PROJECT)

include ${PROJCPPLIB}/project.mak

$(PROJECT):	$(OBJECTS)
	$(CXX) $(COMPILE_FLAGS) $(OBJECTS) $(LINK_LIBRARIES) \
	$(OUTPUT) $(PROJECT) $(LINKER_FLAGS)

# ===============================================================
# Set to your installation directory
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

	echo Removing all test LOG files from working directory...
	rm -f *.log

	echo Removing all test OUT files from working directory...
	rm -f *.out 

# ---------------------------------------------------------------
#####################
#### End of File ####
#####################

#######################
#### Start of File ####
#######################
# ---------------------------------------------------------------
# Makefile
# C/C++ Compiler Used: gcc version 4.4 or higher
# ---------------------------------------------------------------
# Define a name for the executable
PROJECT = fix_ascii_point_data
64BITCFG = 0
FINAL = 1

# Library paths
APP_PATH = ./
G2CPPLIB = ../grib2_cpp_lib

# GXD/GXS/GXT CPP library path
GCODE_LIB_DIR = ../3plibs/datareel

include ${G2CPPLIB}/linux.env

PROJECT_DEP = $(G2CPPLIB)/g2_cpp_headers.h \
$(G2CPPLIB)/g2_utils.h \
$(G2CPPLIB)/g2_meta_file.h

# Compile the files and build the executable
# ===============================================================
all:    $(PROJECT)

include ${G2CPPLIB}/project.mak

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

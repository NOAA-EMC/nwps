#######################
#### Start of File ####
#######################
# --------------------------------------------------------------- 
# Makefile Contents: Makefile for utility program
# C/C++ Compiler Used: GNU, Intel, Cray
# --------------------------------------------------------------- 
# Define a name for the executable
PROJECT = wave_runup_to_bin

# Release version = 1
# Debug version = 0
FINAL = 1

BUILD := $(BUILD)
COMPILER := $(COMPILER)

# Library paths
G2CPPLIB = ../grib2_cpp_lib
APP_PATH = .

# GXD/GXS/GXT library path
GCODE_LIB_DIR = ../3plibs/datareel

# Setup our build environment
include ../env/build_cpp.env

# Setup additional project DEPs for additional LIBs
include ../3plibs/datareel/env/glibdeps_min.mak
include ../grib2_cpp_lib/g2_deps.mak

PROJECT_DEP = $(G2CPPLIB)/g2_cpp_headers.h \
$(G2CPPLIB)/g2_utils.h \
$(G2CPPLIB)/g2_meta_file.h 

# Compile the files and build the executable
# ===============================================================
all:    $(PROJECT)

# Setup build rules for additional LIBs
include ../3plibs/datareel/env/glibobjs_min.mak
include ../grib2_cpp_lib/g2_objs.mak

$(PROJECT)$(OBJ_EXT):	$(APP_PATH)/$(PROJECT).cpp $(PROJECT_DEP)
	$(CXX) $(COMPILE_ONLY) $(COMPILE_FLAGS) $(APP_PATH)/$(PROJECT).cpp

# Make the executable
OBJECTS = $(PROJECT)$(OBJ_EXT) \
$(G2_OBJECTS) \
dfileb$(OBJ_EXT) \
futils$(OBJ_EXT) \
gxdfp64$(OBJ_EXT) \
gxdfptr$(OBJ_EXT) \
gxdlcode$(OBJ_EXT) \
gxlistb$(OBJ_EXT) \
membuf$(OBJ_EXT) \
strutil$(OBJ_EXT) \
gxconfig$(OBJ_EXT) \
ustring$(OBJ_EXT) \
gxint32$(OBJ_EXT) \
gxuint32$(OBJ_EXT) \
gxint64$(OBJ_EXT) \
gxuint64$(OBJ_EXT)

$(PROJECT):	$(OBJECTS)
	$(CXX) $(COMPILE_FLAGS) $(OBJECTS) $(LINK_LIBRARIES) \
	$(OUTPUT) $(PROJECT) $(LINKER_FLAGS)

# ===============================================================
# Set to your installation directory
install:
	mkdir -pv ../../../exec
	cp -fpv $(PROJECT)  ../../../exec/$(PROJECT)
	chmod 775   ../../../exec/$(PROJECT)

# Remove object files and the executable after running make 
# ===============================================================
clean:
	echo Removing all OBJECT files from working directory...
	rm -fv *.o 

	echo Removing EXECUTABLE file from working directory...
	rm -fv $(PROJECT)

	echo Removing all test LOG files from working directory...
	rm -f *.log 

	echo Removing all test OUT files from working directory...
	rm -f *.out 

	echo Cleaning test data
	rm -f testdata/*.stdout
	rm -f testdata/*.stderr

	echo Removing core files
	rm -f core.*
	rm -f vgcore.*
# --------------------------------------------------------------- 
#####################
#### End of File ####
#####################

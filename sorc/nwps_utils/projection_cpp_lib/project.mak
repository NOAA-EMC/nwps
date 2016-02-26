# Include file for makefiles

PROJECTION_UTILS_DEP = $(PROJCPPLIB)$(PATHSEP)projection_utils.h

PROJECTION_CPP_LIB_DEP = $(PROJCPPLIB)$(PATHSEP)projection_cpp_lib.h \
$(PROJCPPLIB)$(PATHSEP)projection_utils.h

AWIPS_GRIDS_DEP = $(PROJCPPLIB)$(PATHSEP)projection_cpp_lib.h \
$(PROJCPPLIB)$(PATHSEP)awips_grids.h \
$(PROJCPPLIB)$(PATHSEP)projection_utils.h

AWIPS_NETCDF_DEP = $(PROJCPPLIB)$(PATHSEP)projection_cpp_lib.h \
$(PROJCPPLIB)$(PATHSEP)awips_netcdf.h \
$(PROJCPPLIB)$(PATHSEP)awips_grids.h \
$(PROJCPPLIB)$(PATHSEP)projection_utils.h

INTERPOLATE_DEP = $(PROJCPPLIB)$(PATHSEP)interpolate.h \
$(PROJCPPLIB)$(PATHSEP)projection_cpp_lib.h \
$(PROJCPPLIB)$(PATHSEP)awips_netcdf.h \
$(PROJCPPLIB)$(PATHSEP)awips_grids.h \
$(PROJCPPLIB)$(PATHSEP)projection_utils.h

WIND_FILE_DEP = $(PROJCPPLIB)$(PATHSEP)projection_cpp_lib.h \
$(PROJCPPLIB)$(PATHSEP)awips_netcdf.h\
$(PROJCPPLIB)$(PATHSEP)wind_file.h \
$(PROJCPPLIB)$(PATHSEP)awips_grids.h \
$(PROJCPPLIB)$(PATHSEP)projection_utils.h

# Compile the files and build the executable
# ===============================================================
all:	$(PROJECT)$(EXE_EXT)

projection_cpp_lib$(OBJ_EXT):	$(PROJCPPLIB)$(PATHSEP)projection_cpp_lib.cpp $(PROJECTION_CPP_LIB_DEP)
	$(CXX) $(COMPILE_ONLY) $(COMPILE_FLAGS) \
	$(PROJCPPLIB)$(PATHSEP)projection_cpp_lib.cpp

projection_utils$(OBJ_EXT):	$(PROJCPPLIB)$(PATHSEP)projection_utils.cpp $(PROJECTION_UTILS_DEP)
	$(CXX) $(COMPILE_ONLY) $(COMPILE_FLAGS) \
	$(PROJCPPLIB)$(PATHSEP)projection_utils.cpp

awips_netcdf$(OBJ_EXT):	$(PROJCPPLIB)$(PATHSEP)awips_netcdf.cpp $(AWIPS_NETCDF_DEP)
	$(CXX) $(COMPILE_ONLY) $(COMPILE_FLAGS) \
	$(PROJCPPLIB)$(PATHSEP)awips_netcdf.cpp

awips_grids$(OBJ_EXT):	$(PROJCPPLIB)$(PATHSEP)awips_grids.cpp $(AWIPS_GRIDS_DEP)
	$(CXX) $(COMPILE_ONLY) $(COMPILE_FLAGS) \
	$(PROJCPPLIB)$(PATHSEP)awips_grids.cpp

interpolate$(OBJ_EXT):	$(PROJCPPLIB)$(PATHSEP)interpolate.cpp $(INTERPOLATE_DEP)
	$(CXX) $(COMPILE_ONLY) $(COMPILE_FLAGS) \
	$(PROJCPPLIB)$(PATHSEP)interpolate.cpp

wind_file$(OBJ_EXT):	$(PROJCPPLIB)$(PATHSEP)wind_file.cpp $(WIND_FILE_DEP)
	$(CXX) $(COMPILE_ONLY) $(COMPILE_FLAGS) \
	$(PROJCPPLIB)$(PATHSEP)wind_file.cpp

$(PROJECT)$(OBJ_EXT):	$(APP_PATH)$(PATHSEP)$(PROJECT).cpp $(PROJECT_DEP)
	$(CXX) $(COMPILE_ONLY) $(COMPILE_FLAGS) $(APP_PATH)$(PATHSEP)$(PROJECT).cpp

# Make the executable
OBJECTS = $(PROJECT)$(OBJ_EXT) \
projection_cpp_lib$(OBJ_EXT) \
projection_utils$(OBJ_EXT) \
awips_grids$(OBJ_EXT) \
interpolate$(OBJ_EXT) \
awips_netcdf$(OBJ_EXT) \
wind_file$(OBJ_EXT)

# ===============================================================

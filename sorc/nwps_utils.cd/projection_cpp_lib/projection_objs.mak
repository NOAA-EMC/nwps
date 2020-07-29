# AWIPS projection LIB build rules
# ===============================================================

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

# Make the executable
PROJECTION_OBJECTS = projection_cpp_lib$(OBJ_EXT) \
projection_utils$(OBJ_EXT) \
awips_grids$(OBJ_EXT) \
interpolate$(OBJ_EXT) \
awips_netcdf$(OBJ_EXT) \
wind_file$(OBJ_EXT)

# ===============================================================

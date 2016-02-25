# Include file for makefiles

# Setup additional paths for includes and source code
include $(GCODE_LIB_DIR)/env/glibdeps.mak

G2_CPP_HEADERS_DEP = $(G2CPPLIB)$(PATHSEP)g2_cpp_headers.h \
$(G2CPPLIB)$(PATHSEP)g2_utils.h

G2_UTILS_DEP = $(G2CPPLIB)$(PATHSEP)g2_cpp_headers.h \
$(G2CPPLIB)$(PATHSEP)g2_utils.h

G2_META_FILE_DEP = $(G2CPPLIB)$(PATHSEP)g2_cpp_headers.h \
$(G2CPPLIB)$(PATHSEP)g2_utils.h\
$(G2CPPLIB)$(PATHSEP)g2_meta_file.h

G2_PRINT_SEC_CPP = $(G2CPPLIB)$(PATHSEP)g2_cpp_headers.h \
$(G2CPPLIB)$(PATHSEP)g2_utils.h\
$(G2CPPLIB)$(PATHSEP)g2_print_sec.h

# Compile the files and build the executable
# ===============================================================
all:	$(PROJECT)$(EXE_EXT)

include $(GCODE_LIB_DIR)/env/glibobjs.mak

g2_cpp_headers$(OBJ_EXT):	$(G2CPPLIB)$(PATHSEP)g2_cpp_headers.cpp $(G2_CPP_HEADERS_DEP)
	$(CXX) $(COMPILE_ONLY) $(COMPILE_FLAGS) \
	$(G2CPPLIB)$(PATHSEP)g2_cpp_headers.cpp

g2_utils$(OBJ_EXT):	$(G2CPPLIB)$(PATHSEP)g2_utils.cpp $(G2_UTILS_DEP)
	$(CXX) $(COMPILE_ONLY) $(COMPILE_FLAGS) \
	$(G2CPPLIB)$(PATHSEP)g2_utils.cpp

g2_meta_file$(OBJ_EXT):	$(G2CPPLIB)$(PATHSEP)g2_meta_file.cpp $(G2_META_FILE_DEP)
	$(CXX) $(COMPILE_ONLY) $(COMPILE_FLAGS) \
	$(G2CPPLIB)$(PATHSEP)g2_meta_file.cpp

g2_print_sec$(OBJ_EXT):	$(G2CPPLIB)$(PATHSEP)g2_print_sec.cpp $(G2_PRINT_SEC_DEP)
	$(CXX) $(COMPILE_ONLY) $(COMPILE_FLAGS) \
	$(G2CPPLIB)$(PATHSEP)g2_print_sec.cpp

$(PROJECT)$(OBJ_EXT):	$(APP_PATH)$(PATHSEP)$(PROJECT).cpp $(PROJECT_DEP)
	$(CXX) $(COMPILE_ONLY) $(COMPILE_FLAGS) $(APP_PATH)$(PATHSEP)$(PROJECT).cpp

# Make the executable
OBJECTS = $(PROJECT)$(OBJ_EXT) \
g2_cpp_headers$(OBJ_EXT) \
g2_utils$(OBJ_EXT) \
g2_meta_file$(OBJ_EXT) \
g2_print_sec$(OBJ_EXT)

# ===============================================================

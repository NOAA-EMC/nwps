# Make file include for G2 CPP Library
# ===============================================================

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

G2_OBJECTS = g2_cpp_headers$(OBJ_EXT) \
g2_utils$(OBJ_EXT) \
g2_meta_file$(OBJ_EXT) \
g2_print_sec$(OBJ_EXT)

# ===============================================================

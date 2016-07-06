# AWIPS projection LIB deps
# ===============================================================

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
# ===============================================================

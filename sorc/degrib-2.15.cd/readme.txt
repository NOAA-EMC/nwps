This was copied from "degrib's trunk revision 1256 on 12/19/2017

Changes - 
  1) Removed NetCDF calls in command.c to avoid needing NetCDF library
  2) Copied ioapi.[ch] and zip.[ch] from degrib/src/zlib/contrib/minizip
     Added a #define NOCRYPT to top of zip.c
  3) Copied engribapi.c, grib2api.c, mdl_g2c.h from degrib/src/mdl_g2c
  4) Copied libaat.h, libaat_type.h, mycomplex.h from degrib/src/libaat

This should be as capable as the current degrib(2.15) but without
  1) NetCDF capability
  2) DWML / XML capability

Arthur

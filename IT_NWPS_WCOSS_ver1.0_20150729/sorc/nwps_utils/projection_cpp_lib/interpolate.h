// ------------------------------- //
// -------- Start of File -------- //
// ------------------------------- //
// ---------------------------------------------------------------- // 
// C++ Header File
// C++ Compiler Used: MSVC, GCC
// Produced By: Douglas.Gaer@noaa.gov
// File Creation Date: 06/30/2011
// Date Last Modified: 04/22/2013
// ---------------------------------------------------------------- // 
// ------------- Include File Description and Details ------------- // 
// ---------------------------------------------------------------- // 
/*
This software and documentation was produced within NOAA 
and is intended for internal agency use only. Please don't 
distribute any part of this software or documentation without 
first contacting the original author or NOAA agency that 
produced this software. All third party libraries used to 
build this application are subject to the licensing agreement 
stated within the source code and any documentation supplied 
with the third party library.

Interpolation routines for re-projected AWIPS grids.

*/
// ----------------------------------------------------------- // 
#ifndef __M_INTERPOLATE_HPP__
#define __M_INTERPOLATE_HPP__

#include "projection_cpp_lib.h"
#include "projection_utils.h"
#include "awips_grids.h"
#include "awips_netcdf.h"

enum InterpolationType {
  NO_INTERP = 0,
  NEAREST_INTERP,
  LINEAR_INTERP,
  BILINEAR_INTERP,
  REMAPTEST_INTERP,
};

struct InterpolateGrid 
{
  InterpolateGrid(netCDFVariables &ncv) { 
    interpolated_grid = 0;
    Reset(); 
    interpolated_grid = create_latlon_grid(ncv);
  }
  ~InterpolateGrid() { Reset(); }

  void Reset();
  int WriteInterpolatedGrid(netCDFVariables &ncv, const gxString &bin_filename, gxString &out_filename);

  // Driver functions used for all routines
  PointData *create_latlon_grid(netCDFVariables &ncv);
  int write_interpolated_grid(netCDFVariables &ncv, const gxString &bin_filename, gxString &out_filename);

  // Projection specific routines
  int write_interpolated_lambert_grid(netCDFVariables &ncv, const gxString &bin_filename, gxString &out_filename);
  int interpolate_lambert_awips_grid(netCDFVariables &ncv);
  int write_interpolated_mercator_grid(netCDFVariables &ncv, const gxString &bin_filename, gxString &out_filename);
  int interpolate_mercator_awips_grid(netCDFVariables &ncv);
  int write_interpolated_polar_grid(netCDFVariables &ncv, const gxString &bin_filename, gxString &out_filename);
  int interpolate_polar_awips_grid(netCDFVariables &ncv);

  gxString error_string; 
  float missing_value;
  InterpolationType itype;
  PointData *interpolated_grid;
};

// Standalone functions
PointData *CreateLatLonGrid(netCDFVariables &ncv, float missing_value);

#endif // __M_INTERPOLATE_HPP__
// ----------------------------------------------------------- //
// ------------------------------- //
// --------- End of File --------- //
// ------------------------------- //

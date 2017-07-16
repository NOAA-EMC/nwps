// ------------------------------- //
// -------- Start of File -------- //
// ------------------------------- //
// ---------------------------------------------------------------- // 
// C++ Header File
// C++ Compiler Used: MSVC, GCC
// Produced By: Douglas.Gaer@noaa.gov
// File Creation Date: 06/14/2011
// Date Last Modified: 01/04/2017
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

AWIPS netCDF classes and functions

*/
// ----------------------------------------------------------- // 
#ifndef __M_AWIPS_NETCDF_HEADERS_HPP__
#define __M_AWIPS_NETCDF_HEADERS_HPP__

#include "projection_cpp_lib.h"
#include "projection_utils.h"
#include "awips_grids.h"

#include "gxstring.h"

struct NCDumpStrings {
  NCDumpStrings() { }
  ~NCDumpStrings() { }

  void Copy(const NCDumpStrings &ob);
  void Reset();

  gxString netcdf_name;
  gxString dims;
  gxString vars;
  gxString global;
  gxString data;
  gxString error_string;
};

struct netCDFVariables {

  netCDFVariables() { 
    start_time = end_time = 0;
    num_time_vals = 0;
    time_vals = 0;
    time_step = 0;
    num_hours = 0;
    fillValue = stdParallelOne = stdParallelTwo = 0;
    gridtype = AWIPS_Unknown;
    gridname = "Unknown";
    grid = 0;
  }

  ~netCDFVariables() { 
    if((time_vals) && (num_time_vals > 0)) delete[] time_vals;
    if(grid) delete grid;
  }

  int SetVariables(const char *vname, NCDumpStrings &nc);
  void CleanString(gxString &s);
  int SetString(NCDumpStrings &nc, const char *n, gxString &s, int error_level = 1);
  int SetCoordPair(NCDumpStrings &nc, const char *n, CoordPair &v, int error_level = 1);
  int SetTime(const char *vname, NCDumpStrings &nc);
  void Print(gxString &mesg);

  gxString error_string;
  gxString variable_name;
  gxString descriptiveName;
  CoordPair gridSize;
  CoordPair domainOrigin;
  CoordPair domainExtent;
  CoordPair minMaxAllowedValues;
  gxString gridType;
  gxString databaseID;
  gxString siteID;
  gxString units;
  gxString level;
  CoordPair latLonLL;
  CoordPair latLonUR;
  CoordPair gridPointLL;
  CoordPair gridPointUR;
  gxString projectionType;
  float fillValue;
  float stdParallelOne;
  float stdParallelTwo;
  unsigned num_time_vals;
  time_t *time_vals;
  time_t start_time;
  time_t end_time;
  unsigned time_step;
  unsigned num_hours;
  gxString start_time_str;
  AWIPSGridTypes gridtype;
  gxString gridname;
  AWIPSGrid *grid;
  AWIPSdomain domain;
};

// Standalone functions shared by all classes 
int ParseNCDumpVars(char *fname, NCDumpStrings &nc);
gxString *GetVars(NCDumpStrings &nc, const gxString &var_str_name, unsigned &numvars);
int WriteNCDumpData(char *netcdf_filename, const gxString &data_var_name, 
		    const gxString &output_bin_filename,
		    unsigned &num_points, gxString &error_string);
float *WriteNCDumpDataToMembuf(char *netcdf_filename, const gxString &data_var_name, 
			       float *mbuf, const int &expected_num_points,
			       int &read_num_points, gxString &error_string);

#endif // __M_AWIPS_NETCDF_HEADERS_HPP__
// ----------------------------------------------------------- //
// ------------------------------- //
// --------- End of File --------- //
// ------------------------------- //

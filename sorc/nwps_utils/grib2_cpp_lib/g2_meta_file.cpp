// ------------------------------- //
// -------- Start of File -------- //
// ------------------------------- //
// ----------------------------------------------------------- // 
// C++ Source Code File
// Compiler Used: MSVC, GCC
// Produced By: Douglas.Gaer@noaa.gov
// File Creation Date: 03/01/2011
// Date Last Modified: 02/19/2013
// ----------------------------------------------------------- // 
// ------------- Program Description and Details ------------- // 
// ----------------------------------------------------------- // 
/*
This software and documentation was produced within NOAA 
and is intended for internal agency use only. Please don't 
distribute any part of this software or documentation without 
first contacting the original author or NOAA agency that 
produced this software. All third party libraries used to 
build this application are subject to the licensing agreement 
stated within the source code and any documentation supplied 
with the third party library.

Code used to create, modify, and read META data files used with
GRIB2 and SWAN utils built for NWPS project.

*/
// ----------------------------------------------------------- // 

// GNU C/C++ include files
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#if defined (__USE_ANSI_CPP__) // Use the ANSI Standard C++ library
#include <iostream>
using namespace std; // Use unqualified names for Standard C++ library
#else // Use the old iostream library by default
#include <iostream.h>
#endif // __USE_ANSI_CPP__

// 3plibs include files
#include "gxdlcode.h"
#include "gxstring.h"
#include "dfileb.h"
#include "futils.h"
#include "gxconfig.h"
#include "systime.h"
#include "gxlist.h"

// Our API include files
#include "g2_cpp_headers.h"
#include "g2_meta_file.h"
#include "g2_utils.h"

int BuildMetaFile(char *fname , GRIB2Message *g2message, int debug)
{
  DiskFileB dfile(fname, DiskFileB::df_READWRITE,  DiskFileB::df_CREATE);
  if(!dfile) {
    std::cout << "ERROR - Cannot write to meta file " << fname << "\n";
    return 0;
  }
  
  char sbuf[81];

  dfile << "#  META data config file for SWAN GRIB2 encoding version 1.14" << "\n";
  dfile << "#" << "\n";
  dfile << "\n";
  dfile << "# GRIB2 Section 0 meta data" << "\n";
  dfile << "#" << "\n";
  dfile << "discipline = " << g2_get_int(g2message->sec0.discipline, sizeof(g2message->sec0.discipline), sbuf) << "\n";
  dfile << "\n";
  dfile << "# GRIB2 Section 1  meta data" << "\n";
  dfile << "#" << "\n";
  dfile << "# originating_center: Octets 6-7" << "\n";
  dfile << "originating_center = " << g2_get_int(g2message->sec1.originating_center, sizeof(g2message->sec1.originating_center), sbuf) << "\n";
  dfile << "# originating_subcenter: Octets 8-9" << "\n";
  dfile << "originating_subcenter = " << g2_get_int(g2message->sec1.originating_subcenter, sizeof(g2message->sec1.originating_subcenter), sbuf) << "\n";
  dfile << "# master_table_version: Octet 10" << "\n";
  dfile << "master_table_version = " << g2_get_int(g2message->sec1.master_table_version, sizeof(g2message->sec1.master_table_version), sbuf) << "\n";
  dfile << "# grib_local_table_ver: Octet 11" << "\n";
  dfile << "grib_local_table_ver = " << g2_get_int(g2message->sec1.grib_local_table_ver, sizeof(g2message->sec1.grib_local_table_ver), sbuf) << "\n";
  dfile << "# time_reference: Octet 12: 0 = Analysis, 1 = Start of Forecast" << "\n";
  dfile << "time_reference = " << g2_get_int(g2message->sec1.time_reference, sizeof(g2message->sec1.time_reference), sbuf) << "\n";
  dfile << "# year: Octets 13-14" << "\n";
  dfile << "year = " << g2_get_int(g2message->sec1.year, sizeof(g2message->sec1.year), sbuf) << "\n";
  dfile << "# month: Octet 16" << "\n";
  dfile << "month = " << g2_get_int(g2message->sec1.month, sizeof(g2message->sec1.month), sbuf) << "\n";
  dfile << "# day: Octet 16" << "\n";
  dfile << "day = " << g2_get_int(g2message->sec1.day, sizeof(g2message->sec1.day), sbuf) << "\n";
  dfile << "# hour: Octet 17" << "\n";
  dfile << "hour = " << g2_get_int(g2message->sec1.hour, sizeof(g2message->sec1.hour), sbuf) << "\n";
  dfile << "# minute: Octet 18" << "\n";
  dfile << "minute = " << g2_get_int(g2message->sec1.minute, sizeof(g2message->sec1.minute), sbuf) << "\n";
  dfile << "# second: Octet 19" << "\n";
  dfile << "second = " << g2_get_int(g2message->sec1.second, sizeof(g2message->sec1.second), sbuf) << "\n";
  dfile << "# production_status: Octet 20" << "\n";
  dfile << "production_status = " << g2_get_int(g2message->sec1.production_status, sizeof(g2message->sec1.production_status), sbuf) << "\n";
  dfile << "# type_of_data: Octet 21: 0 = Analysis Products, 1 = Forecast Products" << "\n";
  dfile << "type_of_data = " << g2_get_int(g2message->sec1.type_of_data, sizeof(g2message->sec1.type_of_data), sbuf) << "\n";
  dfile << "\n";

  dfile << "# GRIB2 Section 2  meta data" << "\n";
  dfile << "#" << "\n";
  dfile << "## local_data = " << "\n";
  dfile << "\n";

  dfile << "# GRIB2 Section 3  meta data" << "\n";
  dfile << "#" << "\n";
  dfile << "# source_of_grid_def: Octet 6" << "\n";
  dfile << "source_of_grid_def = " << g2_get_int(g2message->sec3.source_of_grid_def, sizeof(g2message->sec3.source_of_grid_def), sbuf) << "\n";
  dfile << "# num_grid_data_points: Octets 7-10" << "\n";
  dfile << "num_grid_data_points = " << g2_get_int(g2message->sec3.num_data_points, sizeof(g2message->sec3.num_data_points), sbuf) << "\n";
  dfile << "# num_non_rect_points: Octet 11" << "\n";
  dfile << "num_non_rect_points = " << g2_get_int(g2message->sec3.num_non_rect_points, sizeof(g2message->sec3.num_non_rect_points), sbuf) << "\n";
  dfile << "# appended_point_list: Octet 12" << "\n";
  dfile << "appended_point_list = " << g2_get_int(g2message->sec3.appended_point_list, sizeof(g2message->sec3.appended_point_list), sbuf) << "\n";
  dfile << "# grid_def_template: Octets 13-14: Grid Definition " << "\n";
  dfile << "grid_def_template = " << g2_get_int(g2message->sec3.grid_def_template, sizeof(g2message->sec3.grid_def_template), sbuf) << "\n";
  dfile << "\n";

  dfile << "# GRIB2 grid definition template 3.0 meta data" << "\n";
  dfile << "#" << "\n";
  dfile << "# shape_of_earth: Octets 15: Shape of the earth (see Code Table 3.2)" << "\n";
  dfile << "shape_of_earth = " << g2_get_int(g2message->templates.gt30.shape_of_earth, sizeof(g2message->templates.gt30.shape_of_earth), sbuf) << "\n";
  dfile << "# radius_scale_factor: Octets 16: Scale factor of radius of spherical earth" << "\n";
  dfile << "radius_scale_factor = " << g2_get_int(g2message->templates.gt30.radius_scale_factor, sizeof(g2message->templates.gt30.radius_scale_factor), sbuf) << "\n";
  dfile << "# radius_scale_value: Octets 17-20: Scaled value of radius of spherical earth" << "\n";
  dfile << "radius_scale_value = " << g2_get_int(g2message->templates.gt30.radius_scale_value, sizeof(g2message->templates.gt30.radius_scale_value), sbuf) << "\n";
  dfile << "# major_axis_scale_factor: Octets 21: Scale factor of major axis of oblate spheroid earth" << "\n";
  dfile << "major_axis_scale_factor = " << g2_get_int(g2message->templates.gt30.major_axis_scale_factor, sizeof(g2message->templates.gt30.major_axis_scale_factor), sbuf) << "\n";
  dfile << "# major_axis_scale_value: Octets 22-25: Scaled value of major axis of oblate spheroid earth" << "\n";
  dfile << "major_axis_scale_value = " << g2_get_int(g2message->templates.gt30.major_axis_scale_value, sizeof(g2message->templates.gt30.major_axis_scale_value), sbuf) << "\n";
  dfile << "# minor_axis_scale_factor: Octets 26: Scale factor of minor axis of oblate spheroid earth" << "\n";
  dfile << "minor_axis_scale_factor = " << g2_get_int(g2message->templates.gt30.minor_axis_scale_factor, sizeof(g2message->templates.gt30.minor_axis_scale_factor), sbuf) << "\n";
  dfile << "# minor_axis_scale_value: Octets 27-30: Scaled value of minor axis of oblate spheroid earth" << "\n";
  dfile << "minor_axis_scale_value = " << g2_get_int(g2message->templates.gt30.minor_axis_scale_value, sizeof(g2message->templates.gt30.minor_axis_scale_value), sbuf) << "\n";
  dfile << "# nx: Octets 31-34: Nx – number of points along X-axis" << "\n";
  dfile << "nx = " << g2_get_int(g2message->templates.gt30.nx, sizeof(g2message->templates.gt30.nx), sbuf) << "\n";
  dfile << "# ny: Octets 35-38: Ny – number of points along Y-axis" << "\n";
  dfile << "ny = " << g2_get_int(g2message->templates.gt30.ny, sizeof(g2message->templates.gt30.ny), sbuf) << "\n";
  dfile << "# basic_angle: 39-42 - Basic angle of the initial production domain" << "\n";
  dfile << "basic_angle = " << g2_get_int(g2message->templates.gt30.basic_angle, sizeof(g2message->templates.gt30.basic_angle), sbuf) << "\n";
  dfile << "# subdivisions_of_basic_angle: 43-46 Subdivisions of basic angle used to define extreme longitudes and latitudes, and direction increments" << "\n";
  dfile << "subdivisions_of_basic_angle = " << g2_get_int(g2message->templates.gt30.subdivisions_of_basic_angle, sizeof(g2message->templates.gt30.subdivisions_of_basic_angle), sbuf) << "\n";
  dfile << "# la1: Octets 47-50: La1 – latitude of first grid point" << "\n";
  dfile << "la1 = " << g2_get_int(g2message->templates.gt30.la1, sizeof(g2message->templates.gt30.la1), sbuf) << "\n";
  dfile << "# lo1: Octets 51-54: Lo1 – longitude of first grid point" << "\n";
  dfile << "lo1 = " << g2_get_int(g2message->templates.gt30.lo1, sizeof(g2message->templates.gt30.lo1), sbuf) << "\n";
  dfile << "# res_and_comp_flag: Octet 55: Resolution and component flag (see Flag Table 3.3)" << "\n";
  dfile << "res_and_comp_flag = " << g2_get_int(g2message->templates.gt30.res_and_comp_flag, sizeof(g2message->templates.gt30.res_and_comp_flag), sbuf) << "\n";
  dfile << "# la2: Octets 56-59: La2 – latitude of last grid point" << "\n";
  dfile << "la2 = " << g2_get_int(g2message->templates.gt30.la2, sizeof(g2message->templates.gt30.la2), sbuf) << "\n";
  dfile << "# lo2: Octets 60-63: Lo2 – longitude of last grid point" << "\n";
  dfile << "lo2 = " << g2_get_int(g2message->templates.gt30.lo2, sizeof(g2message->templates.gt30.lo2), sbuf) << "\n";
  dfile << "# dx: Octets 64-67: Dx – X direction grid length" << "\n";
  dfile << "dx = " << g2_get_int(g2message->templates.gt30.dx, sizeof(g2message->templates.gt30.dx), sbuf) << "\n";
  dfile << "# dy: Octets 68-71: Dy – Y direction grid length" << "\n";
  dfile << "dy = " << g2_get_int(g2message->templates.gt30.dy, sizeof(g2message->templates.gt30.dy), sbuf) << "\n";
  dfile << "# scanning_mode: Octet 72: Scanning mode (see Flag Table 3.4)" << "\n";
  dfile << "scanning_mode = " << g2_get_int(g2message->templates.gt30.scanning_mode, sizeof(g2message->templates.gt30.scanning_mode), sbuf) << "\n";
  dfile << "\n";

  dfile << "# GRIB2 Section 4  meta data" << "\n";
  dfile << "#" << "\n";
  dfile << "# num_coords: Octets 6-7" << "\n";
  dfile << "num_coords = " << g2_get_int(g2message->sec4.num_coords, sizeof(g2message->sec4.num_coords), sbuf) << "\n";
  dfile << "# product_def_number: Octets 8-9" << "\n";
  dfile << "product_def_number = " << g2_get_int(g2message->sec4.product_def_number, sizeof(g2message->sec4.product_def_number), sbuf) << "\n";
  dfile << "\n";

  dfile << "# GRIB2 product template 4.0 meta data" << "\n";
  dfile << "#" << "\n";
  dfile << "# parameter_category: Octets 10: Parameter category (see Code table 4.1)" << "\n";
  dfile << "parameter_category = " << g2_get_int(g2message->templates.pt40.parameter_category, sizeof(g2message->templates.pt40.parameter_category), sbuf) << "\n";
  dfile << "# parameter_number: Octets 11: Parameter number (see Code table 4.2)" << "\n";
  dfile << "parameter_number = " << g2_get_int(g2message->templates.pt40.parameter_number, sizeof(g2message->templates.pt40.parameter_number), sbuf) << "\n";
  dfile << "# process_type: Octets 12: Type of generating process (see Code table 4.3)" << "\n";
  dfile << "process_type = " << g2_get_int(g2message->templates.pt40.process_type, sizeof(g2message->templates.pt40.process_type), sbuf) << "\n";
  dfile << "# process_id: Octets 13: Background generating process identifier (defined by originating center)" << "\n";
  dfile << "process_id = " << g2_get_int(g2message->templates.pt40.process_id, sizeof(g2message->templates.pt40.process_id), sbuf) << "\n";
  dfile << "# forecast_process: Octets 14: Analysis or forecast generating process identified (see Code ON388 Table A)" << "\n";
  dfile << "forecast_process = " << g2_get_int(g2message->templates.pt40.forecast_process, sizeof(g2message->templates.pt40.forecast_process), sbuf) << "\n";
  dfile << "# hours: Octets 15-16: Hours of observational data cutoff after reference time (see Note)" << "\n";
  dfile << "hours = " << g2_get_int(g2message->templates.pt40.hours, sizeof(g2message->templates.pt40.hours), sbuf) << "\n";
  dfile << "# minutes: Octets 17: Minutes of observational data cutoff after reference time (see Note)" << "\n";
  dfile << "minutes = " << g2_get_int(g2message->templates.pt40.minutes, sizeof(g2message->templates.pt40.minutes), sbuf) << "\n";
  dfile << "# time_range_unit: Octets 18: Indicator of unit of time range (see Code table 4.4)" << "\n";
  dfile << "time_range_unit = " << g2_get_int(g2message->templates.pt40.time_range_unit, sizeof(g2message->templates.pt40.time_range_unit), sbuf) << "\n";
  dfile << "# forecast_time: Octets 19-22: Forecast time in units defined by octet 18" << "\n";
  dfile << "forecast_time = " << g2_get_int(g2message->templates.pt40.forecast_time, sizeof(g2message->templates.pt40.forecast_time), sbuf) << "\n";
  dfile << "# surface_type: Octets 23: Type of first fixed surface (see Code table 4.5)" << "\n";
  dfile << "surface_type = " << g2_get_int(g2message->templates.pt40.surface_type, sizeof(g2message->templates.pt40.surface_type), sbuf) << "\n";
  dfile << "# surface_scale_factor: Octets 24: Scale factor of first fixed surface" << "\n";
  dfile << "surface_scale_factor = " << g2_get_int(g2message->templates.pt40.surface_scale_factor, sizeof(g2message->templates.pt40.surface_scale_factor), sbuf) << "\n";
  dfile << "# surface_scale_value: Octets 25-28: Scaled value of first fixed surface" << "\n";
  dfile << "surface_scale_value = " << g2_get_int(g2message->templates.pt40.surface_scale_value, sizeof(g2message->templates.pt40.surface_scale_value), sbuf) << "\n";
  dfile << "# surface_type2: Octets 29: Type of second fixed surfaced (see Code table 4.5)" << "\n";
  dfile << "surface_type2 = " << g2_get_int(g2message->templates.pt40.surface_type2, sizeof(g2message->templates.pt40.surface_type2), sbuf) << "\n";
  dfile << "# surface_scale_factor2: Octets 30: Scale factor of second fixed surface" << "\n";
  dfile << "surface_scale_factor2 = " << g2_get_int(g2message->templates.pt40.surface_scale_factor2, sizeof(g2message->templates.pt40.surface_scale_factor2), sbuf) << "\n";
  dfile << "# surface_scale_value2: Octets 31-34: Scaled value of second fixed surfaces" << "\n";
  dfile << "surface_scale_value2 = " << g2_get_int(g2message->templates.pt40.surface_scale_value2, sizeof(g2message->templates.pt40.surface_scale_value2), sbuf) << "\n";
  dfile << "\n";

  dfile << "# GRIB2 Section 5  meta data" << "\n";
  dfile << "#" << "\n";
  dfile << "# num_rep_data_points: Octets 6-9 " << "\n";
  dfile << "num_rep_data_points = " << g2_get_int(g2message->sec5.num_data_points, sizeof(g2message->sec5.num_data_points), sbuf) << "\n";
  dfile << "# data_rep_template_num: Octets 10-11" << "\n";
  dfile << "data_rep_template_num = " << g2_get_int(g2message->sec5.data_rep_template_num, sizeof(g2message->sec5.data_rep_template_num), sbuf) << "\n";

  dfile << "\n";

  dfile << "# GRIB2 grid template 5.0 meta data" << "\n";
  dfile << "#" << "\n";
  dfile << "# ref_value: Octets 12-15: Reference value (R) (IEEE 32-bit floating-point value)" << "\n";
  dfile << "ref_value = " << g2_get_int(g2message->templates.gt50.ref_value, sizeof(g2message->templates.gt50.ref_value), sbuf) << "\n";
  dfile << "# bin_scale_factor: Octets 16-17: Binary scale factor (E)" << "\n";
  dfile << "bin_scale_factor = " << g2_get_int(g2message->templates.gt50.bin_scale_factor, sizeof(g2message->templates.gt50.bin_scale_factor), sbuf) << "\n";
  dfile << "# dec_scale_factor: Octets 18-19: Decimal scale factor (D)" << "\n";
  dfile << "dec_scale_factor = " << g2_get_int(g2message->templates.gt50.dec_scale_factor, sizeof(g2message->templates.gt50.dec_scale_factor), sbuf) << "\n";
  dfile << "# num_bits: Octet 20: Number of bits used for each packed value for simple packing, or for each group reference value for complex packing or spatial differencing" << "\n";
  dfile << "num_bits = " << g2_get_int(g2message->templates.gt50.num_bits, sizeof(g2message->templates.gt50.num_bits), sbuf) << "\n";
  dfile << "# org_field_val: Octet 21: Type of original field values (see Code Table 5.1)" << "\n";
  dfile << "org_field_val = " << g2_get_int(g2message->templates.gt50.org_field_val, sizeof(g2message->templates.gt50.org_field_val), sbuf) << "\n";
  dfile << "\n";

  dfile << "# GRIB2 Section 6  meta data" << "\n";
  dfile << "#" << "\n";
  dfile << "# bit_map_indicator: Octet 6" << "\n";
  dfile << "bit_map_indicator = " << g2_get_int(g2message->sec6.bit_map_indicator, sizeof(g2message->sec6.bit_map_indicator), sbuf) << "\n";
  dfile << "\n";

  dfile << "# GRIB2 Section 7 meta data" << "\n";
  dfile << "#" << "\n";
  dfile << "\n";
  
  dfile << "\n";
  dfile << "# End of meta data" << "\n";
  dfile << "\n";
  return 1;
}

int LoadOrBuildMetaFile(char *fname, GRIB2Message *g2message, int debug)
{
  gxConfig CfgData;
  char *str = 0;
  int ival = 0;
  double fval;
  gxString fstr;
  gxString sbuf;

  std::cout << "Loading meta file " << fname << "\n";

  if(!CfgData.Load(fname)) {
    std::cout << "INFO - Meta file does not exist" << "\n";
    std::cout << "INFO - Creating new meta file and exiting program" << "\n";
    BuildMetaFile(fname, g2message, debug);
    return 0;
  }

  str = CfgData.GetStrValue("discipline");
  if(!str) {
    if(debug) std::cout << "INFO: discipline parameter missing from meta file" << "\n";
  }
  else {
    ival = atoi(str);
    g2_set_int(ival, g2message->sec0.discipline, sizeof(g2message->sec0.discipline));
  }

  str = CfgData.GetStrValue("originating_center");
  if(!str) {
    if(debug) std::cout << "INFO: originating_center parameter missing from meta file" << "\n";
  }
  else {
    ival = atoi(str);
    g2_set_int(ival, g2message->sec1.originating_center, sizeof(g2message->sec1.originating_center));
  }

  str = CfgData.GetStrValue("originating_subcenter");
  if(!str) {
    if(debug) std::cout << "INFO: originating_subcenter parameter missing from meta file" << "\n";
  }
  else {
    ival = atoi(str);
    g2_set_int(ival, g2message->sec1.originating_subcenter, sizeof(g2message->sec1.originating_subcenter));
  }

  str = CfgData.GetStrValue("master_table_version");
  if(!str) {
    if(debug) std::cout << "INFO: master_table_version parameter missing from meta file" << "\n";
  }
  else {
    ival = atoi(str);
    g2_set_int(ival, g2message->sec1.master_table_version, sizeof(g2message->sec1.master_table_version));
  }

  str = CfgData.GetStrValue("grib_local_table_ver");
  if(!str) {
    if(debug) std::cout << "INFO: grib_local_table_ver parameter missing from meta file" << "\n";
  }
  else {
    ival = atoi(str);
    g2_set_int(ival, g2message->sec1.grib_local_table_ver, sizeof(g2message->sec1.grib_local_table_ver));
  }

  str = CfgData.GetStrValue("time_reference");
  if(!str) {
    if(debug) std::cout << "INFO: time_reference parameter missing from meta file" << "\n";
  }
  else {
    ival = atoi(str);
    g2_set_int(ival, g2message->sec1.time_reference, sizeof(g2message->sec1.time_reference));
  }

  str = CfgData.GetStrValue("year");
  if(!str) {
    if(debug) std::cout << "INFO: year parameter missing from meta file" << "\n";
  }
  else {
    ival = atoi(str);
    g2_set_int(ival, g2message->sec1.year, sizeof(g2message->sec1.year));
  }

  str = CfgData.GetStrValue("month");
  if(!str) {
    if(debug) std::cout << "INFO: month parameter missing from meta file" << "\n";
  }
  else {
    ival = atoi(str);
    g2_set_int(ival, g2message->sec1.month, sizeof(g2message->sec1.month));
  }

  str = CfgData.GetStrValue("day");
  if(!str) {
    if(debug) std::cout << "INFO: day parameter missing from meta file" << "\n";
  }
  else {
    ival = atoi(str);
    g2_set_int(ival, g2message->sec1.day, sizeof(g2message->sec1.day));
  }

  str = CfgData.GetStrValue("hour");
  if(!str) {
    if(debug) std::cout << "INFO: hour parameter missing from meta file" << "\n";
  }
  else {
    ival = atoi(str);
    g2_set_int(ival, g2message->sec1.hour, sizeof(g2message->sec1.hour));
  }

  str = CfgData.GetStrValue("minute");
  if(!str) {
    if(debug) std::cout << "INFO: minute parameter missing from meta file" << "\n";
  }
  else {
    ival = atoi(str);
    g2_set_int(ival, g2message->sec1.minute, sizeof(g2message->sec1.minute));
  }

  str = CfgData.GetStrValue("second");
  if(!str) {
    if(debug) std::cout << "INFO: second parameter missing from meta file" << "\n";
  }
  else {
    ival = atoi(str);
    g2_set_int(ival, g2message->sec1.second, sizeof(g2message->sec1.second));
  }

  str = CfgData.GetStrValue("production_status");
  if(!str) {
    if(debug) std::cout << "INFO: production_status parameter missing from meta file" << "\n";
  }
  else {
    ival = atoi(str);
    g2_set_int(ival, g2message->sec1.production_status, sizeof(g2message->sec1.production_status));
  }

  str = CfgData.GetStrValue("type_of_data");
  if(!str) {
    if(debug) std::cout << "INFO: type_of_data parameter missing from meta file" << "\n";
  }
  else {
    ival = atoi(str);
    g2_set_int(ival, g2message->sec1.type_of_data, sizeof(g2message->sec1.type_of_data));
  }

  str = CfgData.GetStrValue("source_of_grid_def");
  if(!str) {
    if(debug) std::cout << "INFO: source_of_grid_def parameter missing from meta file" << "\n";
  }
  else {
    ival = atoi(str);
    g2_set_int(ival, g2message->sec3.source_of_grid_def, sizeof(g2message->sec3.source_of_grid_def));
  }

  str = CfgData.GetStrValue("num_grid_data_points");
  if(!str) {
    if(debug) std::cout << "INFO: num_grid_data_points parameter missing from meta file" << "\n";
  }
  else {
    ival = atoi(str);
    g2_set_int(ival, g2message->sec3.num_data_points, sizeof(g2message->sec3.num_data_points));
  }

  str = CfgData.GetStrValue("num_non_rect_points");
  if(!str) {
    if(debug) std::cout << "INFO: num_non_rect_points parameter missing from meta file" << "\n";
  }
  else {
    ival = atoi(str);
    g2_set_int(ival, g2message->sec3.num_non_rect_points, sizeof(g2message->sec3.num_non_rect_points));
  }

  str = CfgData.GetStrValue("appended_point_list");
  if(!str) {
    if(debug) std::cout << "INFO: appended_point_list parameter missing from meta file" << "\n";
  }
  else {
    ival = atoi(str);
    g2_set_int(ival, g2message->sec3.appended_point_list, sizeof(g2message->sec3.appended_point_list));
  }

  str = CfgData.GetStrValue("grid_def_template");
  if(!str) {
    if(debug) std::cout << "INFO: grid_def_template parameter missing from meta file" << "\n";
  }
  else {
    ival = atoi(str);
    g2_set_int(ival, g2message->sec3.grid_def_template, sizeof(g2message->sec3.grid_def_template));
  }

  str = CfgData.GetStrValue("shape_of_earth");
  if(!str) {
    if(debug) std::cout << "INFO: shape_of_earth parameter missing from meta file" << "\n";
  }
  else {
    ival = atoi(str);
    g2_set_int(ival, g2message->templates.gt30.shape_of_earth, sizeof(g2message->templates.gt30.shape_of_earth));
  }

  str = CfgData.GetStrValue("radius_scale_factor");
  if(!str) {
    if(debug) std::cout << "INFO: radius_scale_factor parameter missing from meta file" << "\n";
  }
  else {
    ival = atoi(str);
    g2_set_int(ival, g2message->templates.gt30.radius_scale_factor, sizeof(g2message->templates.gt30.radius_scale_factor));
  }

  str = CfgData.GetStrValue("radius_scale_value");
  if(!str) {
    if(debug) std::cout << "INFO: radius_scale_value parameter missing from meta file" << "\n";
  }
  else {
    sbuf = str;
    sbuf.FilterChar('.');
    ival = atoi(sbuf.c_str());
    g2_set_int(ival, g2message->templates.gt30.radius_scale_value, sizeof(g2message->templates.gt30.radius_scale_value));
  }

  str = CfgData.GetStrValue("major_axis_scale_factor");
  if(!str) {
    if(debug) std::cout << "INFO: major_axis_scale_factor parameter missing from meta file" << "\n";
  }
  else {
    ival = atoi(str);
    g2_set_int(ival, g2message->templates.gt30.major_axis_scale_factor, sizeof(g2message->templates.gt30.major_axis_scale_factor));
  }

  str = CfgData.GetStrValue("major_axis_scale_value");
  if(!str) {
    if(debug) std::cout << "INFO: major_axis_scale_value parameter missing from meta file" << "\n";
  }
  else {
    ival = atoi(str);
    g2_set_int(ival, g2message->templates.gt30.major_axis_scale_value, sizeof(g2message->templates.gt30.major_axis_scale_value));
  }

  str = CfgData.GetStrValue("minor_axis_scale_factor");
  if(!str) {
    if(debug) std::cout << "INFO: minor_axis_scale_factor parameter missing from meta file" << "\n";
  }
  else {
    ival = atoi(str);
    g2_set_int(ival, g2message->templates.gt30.minor_axis_scale_factor, sizeof(g2message->templates.gt30.minor_axis_scale_factor));
  }

  str = CfgData.GetStrValue("minor_axis_scale_value");
  if(!str) {
    if(debug) std::cout << "INFO: minor_axis_scale_value parameter missing from meta file" << "\n";
  }
  else {
    ival = atoi(str);
    g2_set_int(ival, g2message->templates.gt30.minor_axis_scale_value, sizeof(g2message->templates.gt30.minor_axis_scale_value));
  }

  int NX = 0;
  int NY = 0;

  str = CfgData.GetStrValue("nx");
  if(!str) {
    if(debug) std::cout << "INFO: nx parameter missing from meta file" << "\n";
  }
  else {
    ival = atoi(str);
    g2_set_int(ival, g2message->templates.gt30.nx, sizeof(g2message->templates.gt30.nx));
    NX = ival;
  }

  str = CfgData.GetStrValue("ny");
  if(!str) {
    if(debug) std::cout << "INFO: ny parameter missing from meta file" << "\n";
  }
  else {
    ival = atoi(str);
    g2_set_int(ival, g2message->templates.gt30.ny, sizeof(g2message->templates.gt30.ny));
    NY = ival;
  }

  str = CfgData.GetStrValue("basic_angle");
  if(!str) {
    if(debug) std::cout << "INFO: basic_angle parameter missing from meta file" << "\n";
  }
  else {
    ival = atoi(str);
    g2_set_int(ival, g2message->templates.gt30.basic_angle, sizeof(g2message->templates.gt30.basic_angle));
  }

  str = CfgData.GetStrValue("subdivisions_of_basic_angle");
  if(!str) {
    if(debug) std::cout << "INFO: subdivisions_of_basic_angle parameter missing from meta file" << "\n";
  }
  else {
    ival = atoi(str);
    g2_set_int(ival, g2message->templates.gt30.subdivisions_of_basic_angle, sizeof(g2message->templates.gt30.subdivisions_of_basic_angle));
  }

  int NORTHEASTLAT = 0;
  int SOUTHWESTLAT = 0;
  int NORTHEASTLON = 0;
  int SOUTHWESTLON = 0;
  gxString sphere_lon_offset_str = "360";
  g2_fix_floating_point_values(sphere_lon_offset_str, 9);
  int sphere_lon_offset = sphere_lon_offset_str.Atoi();
  gxString fbuf;
  int i_rep = 0;
  int f_rep = 0;
  gxString f_rep_str;

  // Must use the input LAT/LON values to encode DX and DY
  double input_NORTHEASTLAT = 0.0;
  double input_SOUTHWESTLAT = 0.0;
  double input_NORTHEASTLON = 0.0;
  double input_SOUTHWESTLON = 0.0;

  str = CfgData.GetStrValue("la1");
  if(!str) {
    if(debug) std::cout << "INFO: la1 parameter missing from meta file" << "\n";
  }
  else {
    sbuf = str;
    input_SOUTHWESTLAT = sbuf.Atof();
    fbuf = sbuf;
    fbuf.DeleteAfterIncluding("."); fbuf.FilterChar('-');
    // 02/19/2012: Fix for non conus sites
    if(fbuf.Atoi() < 10) {
      g2_fix_floating_point_values(sbuf, 7);
    }
    else if(fbuf.Atoi() < 100) {
      g2_fix_floating_point_values(sbuf, 8);
    }
    else {
      g2_fix_floating_point_values(sbuf, 9);
    }
    ival = atoi(sbuf.c_str());
    SOUTHWESTLAT = ival;
    g2_set_int(ival, g2message->templates.gt30.la1, sizeof(g2message->templates.gt30.la1));
  }

  str = CfgData.GetStrValue("lo1");
  if(!str) {
    if(debug) std::cout << "INFO: lo1 parameter missing from meta file" << "\n";
  }
  else {
    sbuf = str;
    input_SOUTHWESTLON = sbuf.Atof();
    fbuf = sbuf;
    fbuf.DeleteAfterIncluding("."); fbuf.FilterChar('-');
    // 02/19/2012: Fix for non conus sites
    if(fbuf.Atoi() < 10) {
      g2_fix_floating_point_values(sbuf, 7);
    }
    else if(fbuf.Atoi() < 100) {
      g2_fix_floating_point_values(sbuf, 8);
    }
    else {
      g2_fix_floating_point_values(sbuf, 9);
    }
    ival = atoi(sbuf.c_str());
    SOUTHWESTLON = ival;
    ival = sphere_lon_offset - SOUTHWESTLON; 
    g2_set_int(ival, g2message->templates.gt30.lo1, sizeof(g2message->templates.gt30.lo1));
  }

  str = CfgData.GetStrValue("res_and_comp_flag");
  if(!str) {
    if(debug) std::cout << "INFO: res_and_comp_flag parameter missing from meta file" << "\n";
  }
  else {
    ival = atoi(str);
    g2_set_int(ival, g2message->templates.gt30.res_and_comp_flag, sizeof(g2message->templates.gt30.res_and_comp_flag));
  }

  str = CfgData.GetStrValue("la2");
  if(!str) {
    if(debug) std::cout << "INFO: la2 parameter missing from meta file" << "\n";
  }
  else {
    sbuf = str;
    input_NORTHEASTLAT = sbuf.Atof();
    fbuf = sbuf;
    fbuf.DeleteAfterIncluding("."); fbuf.FilterChar('-');
    // 02/19/2012: Fix for non conus sites
    if(fbuf.Atoi() < 10) {
      g2_fix_floating_point_values(sbuf, 7);
    }
    else if(fbuf.Atoi() < 100) {
      g2_fix_floating_point_values(sbuf, 8);
    }
    else {
      g2_fix_floating_point_values(sbuf, 9);
    }
    ival = atoi(sbuf.c_str());
    NORTHEASTLAT = ival;
    g2_set_int(ival, g2message->templates.gt30.la2, sizeof(g2message->templates.gt30.la2));
  }

  str = CfgData.GetStrValue("lo2");
  if(!str) {
    if(debug) std::cout << "INFO: lo2 parameter missing from meta file" << "\n";
  }
  else {
    sbuf = str;
    input_NORTHEASTLON = sbuf.Atof();
    fbuf = sbuf;
    fbuf.DeleteAfterIncluding("."); fbuf.FilterChar('-');
    // 02/19/2012: Fix for non conus sites
    if(fbuf.Atoi() < 10) {
      g2_fix_floating_point_values(sbuf, 7);
    }
    else if(fbuf.Atoi() < 100) {
      g2_fix_floating_point_values(sbuf, 8);
    }
    else {
      g2_fix_floating_point_values(sbuf, 9);
    }
    ival = atoi(sbuf.c_str());
    NORTHEASTLON = ival;
    ival = sphere_lon_offset - NORTHEASTLON; 
    g2_set_int(ival, g2message->templates.gt30.lo2, sizeof(g2message->templates.gt30.lo2));
  }
  
  str = CfgData.GetStrValue("dx");
  if(!str) {
    if(debug) std::cout << "INFO: dx parameter missing from meta file" << "\n";
  }
  else {
    fstr.Clear();
    fstr.Precision(6);
    fstr = str;
    if(atof(fstr.c_str()) <= 0) {
      if(input_NORTHEASTLON > input_SOUTHWESTLON) {
	fval = (input_NORTHEASTLON - input_SOUTHWESTLON)/(NX-1);
      }
      else {
	fval = (input_SOUTHWESTLON - input_NORTHEASTLON)/(NX-1);
      }
      g2_split_float(fval, i_rep, f_rep, 1000000);
      fstr.Clear();
      fstr << i_rep << ".";
      f_rep_str << clear << f_rep;
      while(f_rep_str.length() < 6) f_rep_str.InsertAt(0, "0");
      fstr << f_rep_str;
    }
    g2_fix_floating_point_values(fstr, 6);
    ival = fstr.Atoi();
    g2_set_int(ival, g2message->templates.gt30.dx, sizeof(g2message->templates.gt30.dx));
  }

  str = CfgData.GetStrValue("dy");
  if(!str) {
    if(debug) std::cout << "INFO: dy parameter missing from meta file" << "\n";
  }
  else {
    fstr.Clear();
    fstr.Precision(6);
    fstr = str;
    if(atof(fstr.c_str()) <= 0) {
      if(input_NORTHEASTLAT > input_SOUTHWESTLAT) { 
	fval = (input_NORTHEASTLAT-input_SOUTHWESTLAT)/(NY-1);
      }
      else {
	fval = (input_SOUTHWESTLAT-input_NORTHEASTLAT)/(NY-1);
      }
      g2_split_float(fval, i_rep, f_rep, 1000000);
      fstr.Clear();
      fstr << i_rep << ".";
      f_rep_str << clear << f_rep;
      while(f_rep_str.length() < 6) f_rep_str.InsertAt(0, "0");
      fstr << f_rep_str;
    }

    g2_fix_floating_point_values(fstr, 6);
    ival = fstr.Atoi();
    g2_set_int(ival, g2message->templates.gt30.dy, sizeof(g2message->templates.gt30.dy));
  }

  str = CfgData.GetStrValue("scanning_mode");
  if(!str) {
    if(debug) std::cout << "INFO: scanning_mode parameter missing from meta file" << "\n";
  }
  else {
    ival = atoi(str);
    g2_set_int(ival, g2message->templates.gt30.scanning_mode, sizeof(g2message->templates.gt30.scanning_mode));
  }

  str = CfgData.GetStrValue("num_coords");
  if(!str) {
    if(debug) std::cout << "INFO: num_coords parameter missing from meta file" << "\n";
  }
  else {
    ival = atoi(str);
    g2_set_int(ival, g2message->sec4.num_coords, sizeof(g2message->sec4.num_coords));
  }

  str = CfgData.GetStrValue("product_def_number");
  if(!str) {
    if(debug) std::cout << "INFO: product_def_number parameter missing from meta file" << "\n";
  }
  else {
    ival = atoi(str);
    g2_set_int(ival, g2message->sec4.product_def_number, sizeof(g2message->sec4.product_def_number));
  }

  str = CfgData.GetStrValue("parameter_category");
  if(!str) {
    if(debug) std::cout << "INFO: parameter_category parameter missing from meta file" << "\n";
  }
  else {
    ival = atoi(str);
    g2_set_int(ival, g2message->templates.pt40.parameter_category, sizeof(g2message->templates.pt40.parameter_category));
  }

  str = CfgData.GetStrValue("parameter_number");
  if(!str) {
    if(debug) std::cout << "INFO: parameter_number parameter missing from meta file" << "\n";
  }
  else {
    ival = atoi(str);
    g2_set_int(ival, g2message->templates.pt40.parameter_number, sizeof(g2message->templates.pt40.parameter_number));
  }

  str = CfgData.GetStrValue("process_type");
  if(!str) {
    if(debug) std::cout << "INFO: process_type parameter missing from meta file" << "\n";
  }
  else {
    ival = atoi(str);
    g2_set_int(ival, g2message->templates.pt40.process_type, sizeof(g2message->templates.pt40.process_type));
  }

  str = CfgData.GetStrValue("process_id");
  if(!str) {
    if(debug) std::cout << "INFO: process_id parameter missing from meta file" << "\n";
  }
  else {
    ival = atoi(str);
    g2_set_int(ival, g2message->templates.pt40.process_id, sizeof(g2message->templates.pt40.process_id));
  }

  str = CfgData.GetStrValue("forecast_process");
  if(!str) {
    if(debug) std::cout << "INFO: forecast_process parameter missing from meta file" << "\n";
  }
  else {
    ival = atoi(str);
    g2_set_int(ival, g2message->templates.pt40.forecast_process, sizeof(g2message->templates.pt40.forecast_process));
  }

  str = CfgData.GetStrValue("hours");
  if(!str) {
    if(debug) std::cout << "INFO: hours parameter missing from meta file" << "\n";
  }
  else {
    ival = atoi(str);
    g2_set_int(ival, g2message->templates.pt40.hours, sizeof(g2message->templates.pt40.hours));
  }

  str = CfgData.GetStrValue("minutes");
  if(!str) {
    if(debug) std::cout << "INFO: minutes parameter missing from meta file" << "\n";
  }
  else {
    ival = atoi(str);
    g2_set_int(ival, g2message->templates.pt40.minutes, sizeof(g2message->templates.pt40.minutes));
  }

  str = CfgData.GetStrValue("time_range_unit");
  if(!str) {
    if(debug) std::cout << "INFO: time_range_unit parameter missing from meta file" << "\n";
  }
  else {
    ival = atoi(str);
    g2_set_int(ival, g2message->templates.pt40.time_range_unit, sizeof(g2message->templates.pt40.time_range_unit));
  }

  str = CfgData.GetStrValue("forecast_time");
  if(!str) {
    if(debug) std::cout << "INFO: forecast_time parameter missing from meta file" << "\n";
  }
  else {
    ival = atoi(str);
    g2_set_int(ival, g2message->templates.pt40.forecast_time, sizeof(g2message->templates.pt40.forecast_time));
  }

  str = CfgData.GetStrValue("surface_type");
  if(!str) {
    if(debug) std::cout << "INFO: surface_type parameter missing from meta file" << "\n";
  }
  else {
    ival = atoi(str);
    g2_set_int(ival, g2message->templates.pt40.surface_type, sizeof(g2message->templates.pt40.surface_type));
  }

  str = CfgData.GetStrValue("surface_scale_factor");
  if(!str) {
    if(debug) std::cout << "INFO: surface_scale_factor parameter missing from meta file" << "\n";
  }
  else {
    ival = atoi(str);
    g2_set_int(ival, g2message->templates.pt40.surface_scale_factor, sizeof(g2message->templates.pt40.surface_scale_factor));
  }

  str = CfgData.GetStrValue("surface_scale_value");
  if(!str) {
    if(debug) std::cout << "INFO: surface_scale_value parameter missing from meta file" << "\n";
  }
  else {
    ival = atoi(str);
    g2_set_int(ival, g2message->templates.pt40.surface_scale_value, sizeof(g2message->templates.pt40.surface_scale_value));
  }

  str = CfgData.GetStrValue("surface_type2");
  if(!str) {
    if(debug) std::cout << "INFO: surface_type2 parameter missing from meta file" << "\n";
  }
  else {
    ival = atoi(str);
    g2_set_int(ival, g2message->templates.pt40.surface_type2, sizeof(g2message->templates.pt40.surface_type2));
  }

  str = CfgData.GetStrValue("surface_scale_factor2");
  if(!str) {
    if(debug) std::cout << "INFO: surface_scale_factor2 parameter missing from meta file" << "\n";
  }
  else {
    ival = atoi(str);
    g2_set_int(ival, g2message->templates.pt40.surface_scale_factor2, sizeof(g2message->templates.pt40.surface_scale_factor2));
  }

  str = CfgData.GetStrValue("surface_scale_value2");
  if(!str) {
    if(debug) std::cout << "INFO: surface_scale_value2 parameter missing from meta file" << "\n";
  }
  else {
    ival = atoi(str);
    g2_set_int(ival, g2message->templates.pt40.surface_scale_value2, sizeof(g2message->templates.pt40.surface_scale_value2));
  }

  str = CfgData.GetStrValue("num_rep_data_points");
  if(!str) {
    if(debug) std::cout << "INFO: num_rep_data_points parameter missing from meta file" << "\n";
  }
  else {
    ival = atoi(str);
    g2_set_int(ival, g2message->sec5.num_data_points, sizeof(g2message->sec5.num_data_points));
  }

  str = CfgData.GetStrValue("data_rep_template_num");
  if(!str) {
    if(debug) std::cout << "INFO: data_rep_template_num parameter missing from meta file" << "\n";
  }
  else {
    ival = atoi(str);
    g2_set_int(ival, g2message->sec5.data_rep_template_num, sizeof(g2message->sec5.data_rep_template_num));
  }

  str = CfgData.GetStrValue("ref_value");
  if(!str) {
    if(debug) std::cout << "INFO: ref_value parameter missing from meta file" << "\n";
  }
  else {
    ival = atoi(str);
    g2_set_int(ival, g2message->templates.gt50.ref_value, sizeof(g2message->templates.gt50.ref_value));
  }

  str = CfgData.GetStrValue("bin_scale_factor");
  if(!str) {
    if(debug) std::cout << "INFO: bin_scale_factor parameter missing from meta file" << "\n";
  }
  else {
    ival = atoi(str);
    g2_set_int(ival, g2message->templates.gt50.bin_scale_factor, sizeof(g2message->templates.gt50.bin_scale_factor));
  }

  str = CfgData.GetStrValue("dec_scale_factor");
  if(!str) {
    if(debug) std::cout << "INFO: dec_scale_factor parameter missing from meta file" << "\n";
  }
  else {
    ival = atoi(str);
    g2_set_int(ival, g2message->templates.gt50.dec_scale_factor, sizeof(g2message->templates.gt50.dec_scale_factor));
  }

  str = CfgData.GetStrValue("num_bits");
  if(!str) {
    if(debug) std::cout << "INFO: num_bits parameter missing from meta file" << "\n";
  }
  else {
    ival = atoi(str);
    g2_set_int(ival, g2message->templates.gt50.num_bits, sizeof(g2message->templates.gt50.num_bits));
  }

  str = CfgData.GetStrValue("org_field_val");
  if(!str) {
    if(debug) std::cout << "INFO: org_field_val parameter missing from meta file" << "\n";
  }
  else {
    ival = atoi(str);
    g2_set_int(ival, g2message->templates.gt50.org_field_val, sizeof(g2message->templates.gt50.org_field_val));
  }

  str = CfgData.GetStrValue("bit_map_indicator");
  if(!str) {
    if(debug) std::cout << "INFO: bit_map_indicator parameter missing from meta file" << "\n";
  }
  else {
    ival = atoi(str);
    g2_set_int(ival, g2message->sec6.bit_map_indicator, sizeof(g2message->sec6.bit_map_indicator));
  }

  return 1;
}

void g2_fix_floating_point_values(gxString &sbuf, int width)
{
  if((sbuf[0] == '0') && (sbuf[1] == '.')) {
    sbuf.DeleteAt(0, 2);
  }
  sbuf.TrimLeadingSpaces();
  sbuf.TrimTrailingSpaces();
  sbuf.FilterChar('.');
  sbuf.FilterChar('-');

  // 09/14/2011: Added to account for leading zeros
  int num_attempts = 10;
  while(sbuf[0] == '0') {
    sbuf.DeleteAt(0, 1);
    width--;
    num_attempts--;
    if(num_attempts <= 0) break;
  }

  // 02/19/2013: Debug code only
  // std::cout << "In val = " << sbuf.c_str() << "\n";

  int i;
  if((width > 0) && (sbuf.length() < width)) {
    int fill_width =  width - sbuf.length();
    for(i = 0; i < fill_width; i++) {
      sbuf << "0";
    }
  }
  
  num_attempts = 10;
  while(sbuf.length() > width) {
    char s[2];
    s[0] = sbuf[sbuf.length()-1];
    s[1] = 0;
    gxString last_str = s;
    int last = last_str.Atoi();
    sbuf.DeleteAt(sbuf.length()-1, 1);
    num_attempts--;
    if(num_attempts <= 0) break;
    int val = sbuf.Atoi();
    if(last >= 5) val++;
    sbuf << clear << val;
  }

  // 02/19/2013: Debug code only
  // std::cout << "Out val = " << sbuf.c_str() << "\n";
}
// ----------------------------------------------------------- //
// ------------------------------- //
// --------- End of File --------- //
// ------------------------------- //

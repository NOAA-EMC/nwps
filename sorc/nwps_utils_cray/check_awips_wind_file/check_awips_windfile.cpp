// ------------------------------- //
// -------- Start of File -------- //
// ------------------------------- //
// ----------------------------------------------------------- // 
// C++ Source Code File
// Compiler Used: GNU, Intel, Cray
// Produced By: Douglas.Gaer@noaa.gov
// File Creation Date: 01/03/2017
// Date Last Modified: 01/04/2017
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

Program used to check AWIPS netCDF wind files for bad wind speed 
values.
*/
// ----------------------------------------------------------- // 

#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>

#include "dfileb.h"
#include "gxstring.h"

#include "projection_cpp_lib.h"
#include "awips_netcdf.h"
#include "wind_file.h"
#include "awips_grids.h"
#include "interpolate.h"

const char *version_string = "4.04";
const char *program_name = "check_awips_windfile";
const char *program_description = "Program used check ncdump of GFE wind file for bad values";
const char *project_acro = "NWPS";
const char *produced_by = "Douglas.Gaer@noaa.gov";
const char *default_input_fname = "windfile.txt";

int debug = 0;
int debug_level = 0;
int verbose = 0;
gxString netcdf_filename = default_input_fname;
int num_command_line_args = 0;
gxString process_name;
float missing_value = 9999.0;
float min_value = 0.0;
float max_speed = 200.0;

int ProcessArgs(int argc, char *argv[]);
int ProcessDashDashArg(gxString &arg);
void HelpMessage();
void VersionMessage();
int CheckNCDumpDataFile(char *netcdf_filename, const gxString &data_var_name,  netCDFVariables &ncv);

int main(int argc, char *argv[])
{
  // Process command ling arguments and files 
  int narg;
  char *arg = argv[narg = 1];
  int num_files = 0;
  gxString sbuf;

  process_name = argv[0];
  while(narg < argc) {
    if(arg[0] != '\0') {
      if(arg[0] == '-') { // Look for command line arguments
	// Exit if argument is not valid or argument signals program to exit
	if(!ProcessArgs(argc, argv)) return 1; 
      }
      
      else {
	if(num_files == 0) netcdf_filename = arg;
	num_files++;
      }
    }
    arg = argv[++narg];
  }

  if(num_files == 0) {
    std::cout << "ERROR - You must provide an input filename" << "\n" << std::flush;
    VersionMessage();
    HelpMessage();
    return 1;
  }

  if(verbose) VersionMessage();
  NCDumpStrings nc;

  std::cout << "Checking GFE wind file: " << netcdf_filename.c_str() << "\n" << std::flush;

  if(!ParseNCDumpVars(netcdf_filename.c_str(), nc)) {
    std::cout << nc.error_string.c_str() << "\n" << std::flush;
    return 1;
  }

  gxString mesg;
  netCDFVariables ncv;
  if(!ncv.SetVariables("Wind_Mag_SFC", nc)) {
    ncv.Print(mesg);
    std::cout << "\n" << std::flush;
    std::cout << ncv.error_string.c_str() << "\n" << std::flush;
    return 1;
  }

  ncv.Print(mesg);
  if(verbose) std::cout << "\n" << mesg.c_str() << "\n" << std::flush;

  int num_grid_points = ncv.gridSize[0] * ncv.gridSize[1];
  int grid_time_step = ncv.time_step;
  int grid_num_hours = ncv.num_hours;
  int expected_number_of_points = (ncv.num_hours/ncv.time_step) * num_grid_points;

  if(verbose) {
    std::cout << "Number of grid points: " <<  num_grid_points << "\n" << std::flush;
    std::cout << "Time step: " <<  grid_time_step << "\n" << std::flush;
    std::cout << "Number of hours: " <<  grid_num_hours << "\n" << std::flush;
    std::cout << "Expected number of points: " << expected_number_of_points << "\n" << std::flush;
  }

  int error_level = 0;

  if(num_grid_points <= 0) {
    std::cout << "ERROR - Bad number of grid points" << "\n" << std::flush;
    error_level++;
  }
  if(grid_time_step <= 0) {
    std::cout << "ERROR - Bad time step" << "\n" << std::flush;
    error_level++;
  }
  if(grid_num_hours <= 0) {
    std::cout << "ERROR - Bad number of hours" << "\n" << std::flush;
    error_level++;
  }
  if(expected_number_of_points <= 0) {
    std::cout << "ERROR - Bad number of total grid points" << "\n" << std::flush;
    error_level++;
  }

  if(error_level != 0) return 1;

  gxString data_var_name;
  unsigned i = 0;
  const unsigned num_elements = 2;
  gxString elements[num_elements];
  elements[0] = "Wind_Mag_SFC";
  elements[1] = "Wind_Dir_SFC";

  for(i = 0; i < num_elements; i++) {
    data_var_name = elements[i];
    if(!CheckNCDumpDataFile(netcdf_filename.c_str(), data_var_name, ncv)) {
      error_level++;
      if(!debug) break;
    }
  }

  if(error_level != 0) {
    std::cout << "ERROR - netCDF wind file has errors and cannot be used for SWAN input winds" << "\n" << std::flush;
    return 1;
  }
  
  std::cout << "netCDF wind file checks good" << "\n" << std::flush;
  return 0;
}

void VersionMessage()
{
  std::cout << "\n" << std::flush;
  std::cout << program_name << " version " << version_string << "\n" << std::flush; 
  std::cout << program_description << "\n" << std::flush; 
  std::cout <<  "Produced for: " << project_acro << " project" << "\n" << std::flush; 
  std::cout <<  "Produced by: " << produced_by << "\n" << std::flush; 
  std::cout << "\n" << std::flush;
}

void HelpMessage()
{
  std::cout << "Usage:" << "\n" << std::flush;
  std::cout << "        " << process_name.c_str() << " [args] windfile.txt" << "\n" << std::flush;
  std::cout << "\n" << std::flush;
  std::cout << "args = Optional dash arguments" << "\n" << std::flush;
  std::cout << "windfile.txt = Input ncdump file" << "\n" << std::flush;
  std::cout << "\n" << std::flush;
  std::cout << "args: " << "\n" << std::flush;
  std::cout << "     --help                      Print help message and exit" << "\n" << std::flush;
  std::cout << "     --version                   Print version number and exit" << "\n" << std::flush;
  std::cout << "     --debug                     Enable debug mode default level --debug=1" << "\n" << std::flush;
  std::cout << "     --debug-level=5             Set debugging level" << "\n" << std::flush;
  std::cout << "     --verbose                   Turn on verbose messaging" << "\n" << std::flush;
  std::cout << "     --max-speed=n               Set max wind speed in knots, default is 200.0" << "\n" << std::flush;
  std::cout << "\n" << std::flush;
  std::cout << "Example1: " << process_name.c_str() << " 201101251431_WIND.txt" << "\n" << std::flush;
  std::cout << "Example2: " << process_name.c_str() << " --max-speed=185 201101251431_WIND.txt" << "\n" << std::flush;
  std::cout << "\n" << std::flush;
}

int ProcessDashDashArg(gxString &arg)
{
  gxString sbuf, equal_arg;
  int has_valid_args = 0;
  
  if(arg.Find("=") != -1) {
    // Look for equal arguments
    // --config-file="/etc/program.cfg"
    equal_arg = arg;
    equal_arg.DeleteBeforeIncluding("=");
    arg.DeleteAfterIncluding("=");
    equal_arg.TrimLeading(' '); equal_arg.TrimTrailing(' ');
    equal_arg.TrimLeading('\"'); equal_arg.TrimTrailing('\"');
    equal_arg.TrimLeading('\''); equal_arg.TrimTrailing('\'');
  }
  
  arg.ToLower();
  
  // Process all -- arguments here
  if(arg == "help") {
    has_valid_args = 1;
    VersionMessage();
    HelpMessage();
    return 0; // Signal program to exit
  }
  if(arg == "?") {
    has_valid_args = 1;
    VersionMessage();
    HelpMessage();
    return 0; // Signal program to exit
  }
  if((arg == "version") || (arg == "ver")) {
    has_valid_args = 1;
    VersionMessage();
    return 0; // Signal program to exit
  }

  if(arg == "verbose") {
    has_valid_args = 1;
    verbose = 1;
  }

  if(arg == "debug") {
    has_valid_args = 1;
    debug = 1;
    if(!equal_arg.is_null()) { 
      debug_level = equal_arg.Atoi(); 
      if(debug_level <= 0) debug_level = 1;
    }
  }

  if(arg == "debug-level") {
    if(equal_arg.is_null()) { 
      std::cout << "Error no debug level supplied with the --debug-level swtich" 
		  << "\n" << std::flush;
      return 0;
    }
    has_valid_args = 1;
    debug = 1;
    if(!equal_arg.is_null()) { 
      debug_level = equal_arg.Atoi(); 
      if(debug_level <= 0) debug_level = 1;
    }
  }

  if(arg == "missing-value") {
    if(equal_arg.is_null()) { 
      std::cout << "Error no missing value supplied with the --missing-value" 
		  << "\n" << std::flush;
      return 0;
    }
    has_valid_args = 1;
    if(!equal_arg.is_null()) { 
      missing_value = (float)equal_arg.Atof(); 
    }
  }

  if(arg == "max-speed") {
    if(equal_arg.is_null()) { 
      std::cout << "Error no min value supplied with the --max-speed" 
		  << "\n" << std::flush;
      return 0;
    }
    has_valid_args = 1;
    if(!equal_arg.is_null()) { 
      max_speed = (float)equal_arg.Atof(); 
    }
  }


  arg.Clear();
  return has_valid_args;
}

int ProcessArgs(int argc, char *argv[])
{
  // process the program's argument list
  int i;
  gxString sbuf;
  num_command_line_args = 0;

  for(i = 1; i < argc; i++ ) {
    if(*argv[i] == '-') {
      char sw = *(argv[i] +1);
      switch(sw) {

	case '-':
	  sbuf = &argv[i][2]; 
	  // Add all -- prepend filters here
	  sbuf.TrimLeading('-');
	  if(!ProcessDashDashArg(sbuf)) return 0;
	  break;

	case '?':
	  VersionMessage();
	  HelpMessage();
	  return 0; // Signal program to exit
	  
	case 'v': case 'V': 
	  verbose = 1;
	  break;

	case 'd': case 'D':
	  debug = 1;
	  break;

	default:
	  std::cout << "\n" << std::flush;
	  std::cout << "Unknown command line arg " << argv[i] << "\n" << std::flush;
	  std::cout << "Exiting..." << "\n" << std::flush;
	  std::cout << "\n" << std::flush;
	  return 0;
      }
      num_command_line_args++;
    }
  }

  return 1; // All command line arguments were valid
}

int CheckNCDumpDataFile(char *netcdf_filename, const gxString &data_var_name,  netCDFVariables &ncv)
{
  char sbuf[1024];
  gxString data_var_name_str;
  DiskFileB dfile;

  // Open the current product file
  dfile.df_Open(netcdf_filename);
  if(!dfile) {
    std::cout << "ERROR - Cannot open product input file: " << netcdf_filename << "\n";
    return 0;
  }

  data_var_name_str << clear << data_var_name << " =";

  int has_start = 0;
  int has_end = 0;
  int has_data_section = 0;
  int data_start = 0;
  int line_number = 0;
  gxString *vals = 0;
  gxString delimiter = ",";
  unsigned num_arr = 0;
  unsigned i = 0;
  int num_grid_points = ncv.gridSize[0] * ncv.gridSize[1];
  int grid_time_step = ncv.time_step;
  int expected_number_of_points = (ncv.num_hours/ncv.time_step) * num_grid_points;
  int read_number_of_points = 0;
  int number_of_points_per_hour = 0;
  int current_forecast_hour = 0;
  int error_level = 0;
  int forecast_hour = 1;

  if(verbose) std::cout << "Checking " << data_var_name.c_str() << "\n";

  while(!dfile.df_EOF()) {
    // Get each line of the file and trim the line feeds
    dfile.df_GetLine(sbuf, sizeof(sbuf), '\n');
    if(dfile.df_GetError() != DiskFileB::df_NO_ERROR) {
      std::cout << "ERROR - Fatal I/O error occurred reading " << netcdf_filename << "\n";
      return 0;
    }
    line_number++;

    UString info_line(sbuf);
    info_line.FilterChar('\n');
    info_line.FilterChar('\r');
    info_line.TrimLeadingSpaces();
    info_line.TrimTrailingSpaces();

    if(info_line.is_null()) continue;
    if((data_start) > 0 && (has_data_section > 0)) {
      if(info_line.Find(";") != -1) {
	info_line.TrimLeading(',');
	info_line.TrimTrailing(',');
	info_line.FilterChar(';');
	vals = ParseStrings(info_line, delimiter, num_arr, 1, 1);
	for(i = 0; i < num_arr; i++) {
	  float f = 0;
	  sscanf(vals[i].c_str(), "%f", &f);
	  if(read_number_of_points > expected_number_of_points) {
	    std::cout << "ERROR - Expected " << expected_number_of_points << " points, read " 
		      <<  read_number_of_points << " points" << "\n"; 
	    dfile.df_Close();
	    return 0;
	  }
	  if(read_number_of_points == 0) {
	    if(verbose) std::cout << "Processing " << data_var_name.c_str() << " for forecast hour 1" << "\n" << std::flush;
	  }
	  number_of_points_per_hour++;
	  if(number_of_points_per_hour == num_grid_points) {
	    number_of_points_per_hour = 1;
	    current_forecast_hour++;
	    forecast_hour = current_forecast_hour * grid_time_step;
	    if(verbose) {
	      std::cout << "Processing " << data_var_name.c_str() << " for forecast hour " 
			<< forecast_hour << "\n" << std::flush;
	    }
	  }
	  if(FloatEqualTo(f, ncv.fillValue)) {
	     read_number_of_points++;
	    continue;
	  }
	  if(FloatLessThan(f, 0.0)) {
	    std::cout << "ERROR - Forecast hour " << forecast_hour << " has bad " << data_var_name.c_str() 
		      << " value" << "\n" << std::flush;
	    std::cout << "ERROR - Bad value is: " << f << " at grid point: " 
		      << number_of_points_per_hour << "\n" << std::flush;
	    error_level++;
	    if(!debug) { dfile.df_Close(); return 0; }
	  }
	  if(data_var_name == "Wind_Mag_SFC") {
	    if(debug && debug_level == 5) {
	      std::cout << "Wind Speed = " <<  f << " knots at grid point: " << number_of_points_per_hour << "\n" << std::flush;
	    }
	    if( FloatEqualToOrGreaterThan(f, max_speed)) {
	      std::cout << "ERROR - Forecast hour " << forecast_hour << " has wind speed value equal to or greater than " 
			<<  (int)max_speed << " knots" << "\n" << std::flush;
	      std::cout << "ERROR - Bad value is: " << f << " knots at grid point: " << number_of_points_per_hour 
			<< "\n" << std::flush;
	      error_level++;
	      if(!debug) { dfile.df_Close(); return 0; }
	    }
	  }
	  read_number_of_points++;
	}
	if(vals) { 
	  delete[] vals;
	  vals = 0;
	}
	has_end = line_number;
	data_start = 0;
	break;
      }
    }

    // Check to make sure we have a data section 
    if(info_line.Find("data:") != -1) {
      has_data_section = line_number;
    }

    // Check for the specified data array
    if(info_line.Find(data_var_name_str) != -1) {
      gxString exact_var_name = info_line;
      gxString var_name = data_var_name_str;
      exact_var_name.DeleteAfterIncluding("=");
      exact_var_name.FilterString(" ");
      exact_var_name.FilterString("\n"); exact_var_name.FilterString("\r");
      var_name.DeleteAfterIncluding("=");
      var_name.FilterString(" ");
      if(exact_var_name == var_name) {
	has_start = line_number;
	data_start = line_number;
	continue;
      }
    }
    if((data_start) > 0 && (has_data_section > 0)) {
      info_line.TrimLeading(',');
      info_line.TrimTrailing(',');
      info_line.FilterChar(';');
      vals = ParseStrings(info_line, delimiter, num_arr, 1, 1);
      for(i = 0; i < num_arr; i++) {
	float f = 0;
	sscanf(vals[i].c_str(), "%f", &f);

	if(read_number_of_points > expected_number_of_points) {
	  std::cout << "ERROR - Expected " << expected_number_of_points << " points, read " <<  read_number_of_points << " points" << "\n"; 
	  dfile.df_Close();
	  return 0;
	}
	if(read_number_of_points == 0) {
	  if(verbose) std::cout << "Processing " << data_var_name.c_str() << " for forecast hour 1" << "\n" << std::flush;
	}
	number_of_points_per_hour++;
	if(number_of_points_per_hour == num_grid_points) {
	  number_of_points_per_hour = 1;
	  current_forecast_hour++;
	  forecast_hour = current_forecast_hour * grid_time_step;
	  if(verbose) {
	    std::cout << "Processing " << data_var_name.c_str() << " for forecast hour " 
		      << forecast_hour << "\n" << std::flush;
	  }
	}
	if(FloatEqualTo(f, ncv.fillValue)) {
	  read_number_of_points++;
	  continue;
	}
	if(FloatLessThan(f, 0.0)) {
	  std::cout << "ERROR - Forecast hour " << forecast_hour << " has bad " << data_var_name.c_str() 
		    << " value" << "\n" << std::flush;
	  std::cout << "ERROR - Bad value is: " << f << " at grid point: " 
		    << number_of_points_per_hour << "\n" << std::flush;
	  error_level++;
	  if(!debug) { dfile.df_Close(); return 0; }
	}
	if(data_var_name == "Wind_Mag_SFC") {
	  if(debug && debug_level == 5) {
	    std::cout << "Wind Speed = " <<  f << " knots at grid point: " << number_of_points_per_hour << "\n" << std::flush;
	  }
	  if( FloatEqualToOrGreaterThan(f, max_speed)) {
	    std::cout << "ERROR - Forecast hour " << forecast_hour << " has wind speed value equal to or greater than " 
		      <<  (int)max_speed << " knots" << "\n" << std::flush;
	    std::cout << "ERROR - Bad value is: " << f << " knots at grid point: " 
		      << number_of_points_per_hour << "\n" << std::flush;
	    error_level++;
	    if(!debug) { dfile.df_Close(); return 0; }
	  }
	}
	read_number_of_points++;
      }
      if(vals) { 
	delete[] vals;
	vals = 0;
      }
    }
  }
  dfile.df_Close();

  if(!has_start) {
    std::cout << "ERROR - Error parsing ncdump file. No start tag " 
	      << data_var_name_str.c_str() << " found" << "\n";
    return 0;
  }
  if(!has_end) {
    std::cout << "ERROR - Error parsing ncdump file. No end tag ; found" << "\n";
    return 0;
  }
  if(!has_data_section) {
    std::cout << "ERROR - Error parsing ncdump file. No end tag data: section" << "\n";
    return 0;
  }

  if(error_level != 0) return 0;

  return 1;
}
// ----------------------------------------------------------- //
// ------------------------------- //
// --------- End of File --------- //
// ------------------------------- //

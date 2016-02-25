// ------------------------------- //
// -------- Start of File -------- //
// ------------------------------- //
// ----------------------------------------------------------- // 
// C++ Source Code File
// Compiler Used: MSVC, GCC
// Produced By: Douglas.Gaer@noaa.gov
// Projection Algorithms by: Thomas.J.Lefebvre@noaa.gov Mike.Romberg@noaa.gov
// File Creation Date: 06/14/2011
// Date Last Modified: 04/22/2013
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

Program used to read AWIPS netCDF wind files and re-project.

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

const char *version_string = "1.65";
const char *program_name = "read_awips_windfile";
const char *program_description = "Program used to read an ncdump of an AWIPS wind file from GFE";
const char *project_acro = "NWPS";
const char *produced_by = "Douglas.Gaer@noaa.gov";
const char *contributors = "Projection Algorithms by: Thomas.J.Lefebvre@noaa.gov Mike.Romberg@noaa.gov\n\
Interpolation Algorithms by: Douglas.Gaer@noaa.gov";

/* Default global settings */
const char *default_input_fname = "windfile.txt";

/* Global variables */
int debug = 0;
int debug_level = 0;
int verbose = 0;
gxString output_dir = "./";
gxString netcdf_filename = default_input_fname;
int custom_timestep = 0;
int grads_output = 0;
int num_command_line_args = 0;
gxString process_name;
float missing_value = 9999.0;
InterpolationType itype = BILINEAR_INTERP;
gxString itype_string = "bilinear";
float min_value = 0;

// Function declarations
int WriteGradsOutput(netCDFVariables &ncv, const gxString &mag_filename, const gxString &dir_filename, 
		     const gxString &outdir);
int ProcessArgs(int argc, char *argv[]);
int ProcessDashDashArg(gxString &arg);
void HelpMessage();
void VersionMessage();

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
	if(num_files == 1) output_dir = arg;
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

  VersionMessage();

  NCDumpStrings nc;

  std::cout << "Processing ncdump file vars for: " << netcdf_filename.c_str() << "\n" << std::flush;
  std::cout << "Writing output files to: " << output_dir.c_str() << "\n" << std::flush;
  if(output_dir[output_dir.length()-1] != '/') output_dir << "/";

  if(custom_timestep > 0) {
    std::cout << "User has specified a custom timestep of " << custom_timestep << "\n" << std::flush;
  }
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
  std::cout << "\n" << mesg.c_str() << "\n" << std::flush;

  gxString line1, line2, windfile_name, input_date;
  MakeWindinputCGLines(ncv, line1, line2, windfile_name, input_date, custom_timestep, missing_value);

  std::cout << "\n" << std::flush;
  std::cout << line1.c_str() << "\n" << line2.c_str() << "\n" << std::flush;
  std::cout << "\n" << std::flush;

  gxString swan_app_file, swan_perl_input_file;
  DiskFileB app_fp, perl_input_fp;

  swan_app_file << clear << output_dir << "inputCG.app.txt";
  std::cout << "Writing SWAN inputCG append file " << swan_app_file.c_str() << "\n" << std::flush;
  app_fp.df_Create(swan_app_file.c_str());
  if(app_fp.df_GetError() != DiskFileB::df_NO_ERROR) {
    std::cout << "ERROR - Cannot create file " <<  swan_app_file.c_str() << "\n" << std::flush;
    return 1;
  }
  app_fp << line1.c_str() << "\n" << line2.c_str() << "\n";

  if(app_fp.df_GetError() != DiskFileB::df_NO_ERROR) {
    std::cout << "ERROR - Cannot write to file " <<  swan_app_file.c_str() << "\n" << std::flush;
    return 1;
  }
  app_fp.df_Close();


  swan_perl_input_file << clear << output_dir << "perl_input.txt";
  std::cout << "Writing SWAN perl_input file " << swan_perl_input_file.c_str() << "\n" << std::flush;
  perl_input_fp.df_Create(swan_perl_input_file.c_str());
  if(perl_input_fp.df_GetError() != DiskFileB::df_NO_ERROR) {
    std::cout << "ERROR - Cannot create file " <<  swan_perl_input_file.c_str() << "\n" << std::flush;
    return 1;
  }

  perl_input_fp << "DATE:" << input_date.c_str() << "\n";
  perl_input_fp << "INPUTGRID:" << line1.c_str() << "\n";
  perl_input_fp << "FILENAME:" << windfile_name.c_str() << "\n";

  if(perl_input_fp.df_GetError() != DiskFileB::df_NO_ERROR) {
    std::cout << "ERROR - Cannot write to file " <<  swan_perl_input_file.c_str() << "\n" << std::flush;
    return 1;
  }
  perl_input_fp.df_Close();

  gxString output_bin_filename;
  gxString error_string;
  gxString data_var_name;
  unsigned num_points = 0;
  unsigned i = 0;
  const unsigned num_elements = 2;
  gxString elements[num_elements];
  elements[0] = "Wind_Mag_SFC";
  elements[1] = "Wind_Dir_SFC";

  // Write our netCDF data arrays to BIN files
  for(i = 0; i < num_elements; i++) {
    data_var_name = elements[i];
    num_points = 0;
    output_bin_filename << clear << output_dir << data_var_name << ".bin"; 

    std::cout << "Processing ncdump " << data_var_name.c_str() << " values for: " 
	      << netcdf_filename.c_str() << "\n" << std::flush;
    std::cout << "Writing output BIN file " << output_bin_filename.c_str() << "\n" << std::flush;
    if(!WriteNCDumpData(netcdf_filename.c_str(), data_var_name, output_bin_filename, 
			num_points, error_string)) {
      std::cout << "ERROR - Error making output BIN file" << "\n" << std::flush;
      std::cout << error_string << "\n" << std::flush;
      return 1;
    }
    std::cout << "Processed " << num_points << " data points" << "\n" << std::flush;
  }

  gxString mag_filename, dir_filename;
  gxString magX_filename, magY_filename;
  DiskFileB mag_fp, dir_fp, magX_fp, magY_fp;
  int convert_to_knots = 0;
  int convert_to_ms = 1;

  mag_filename << clear << output_dir <<  "Wind_Mag_SFC" << ".bin";
  dir_filename << clear << output_dir << "Wind_Dir_SFC" << ".bin";
  magX_filename << clear << output_dir << "wind_u" << ".bin";
  magY_filename << clear << output_dir << "wind_v" << ".bin";

  // Create our U and V wind files from the netCDF files
  std::cout << "Opening file " << mag_filename.c_str() << "\n" << std::flush;
  std::cout << "Opening file " << dir_filename.c_str() << "\n" << std::flush;
  mag_fp.df_Open(mag_filename.c_str());
  if(mag_fp.df_GetError() != DiskFileB::df_NO_ERROR) {
    std::cout << "ERROR - Cannot open file " <<  mag_filename.c_str() << "\n" << std::flush;
    return 1;
  }
  dir_fp.df_Open(dir_filename.c_str());
  if(dir_fp.df_GetError() != DiskFileB::df_NO_ERROR) {
    std::cout << "ERROR - Cannot open file " <<  dir_filename.c_str() << "\n" << std::flush;
    return 1;
  }
      
  std::cout << "Creating file " << magX_filename.c_str() << "\n" << std::flush;
  magX_fp.df_Create(magX_filename.c_str());
  if(magX_fp.df_GetError() != DiskFileB::df_NO_ERROR) {
    std::cout << "ERROR - Cannot create file " <<  magX_filename.c_str() << "\n" << std::flush;
    return 1;
  }
  std::cout << "Creating file " << magY_filename.c_str() << "\n" << std::flush;
  magY_fp.df_Create(magY_filename.c_str());
  if(magY_fp.df_GetError() != DiskFileB::df_NO_ERROR) {
    std::cout << "ERROR - Cannot create file " <<  magY_filename.c_str() << "\n" << std::flush;
    return 1;
  }

  float mag, dir, magX, magY;
  char fbuf[255];
  int error_flag = 0;

  while(!mag_fp.df_EOF() && !dir_fp.df_EOF()) {
    mag_fp.df_Read((unsigned char *)&mag, sizeof(float));
    if(mag_fp.df_GetError() != DiskFileB::df_NO_ERROR) {
      std::cout << "ERROR - Cannot read from file " <<  mag_filename.c_str() << "\n" << std::flush;
      error_flag = 1;
      break;
    }
    dir_fp.df_Read((unsigned char *)&dir, sizeof(float));
    if(dir_fp.df_GetError() != DiskFileB::df_NO_ERROR) {
      std::cout << "ERROR - Cannot read from file " <<  dir_filename.c_str() << "\n" << std::flush;
      error_flag = 1;
      break;
    }

    // Reset netCDF fill values to missing values 
    if(FloatEqualTo(mag, ncv.fillValue)) mag = missing_value;
    if(FloatEqualTo(dir, ncv.fillValue)) dir = missing_value;

    // 08/23/2011: NDFD grids have MAG values less than 0 but not equal to netCDF fill value
    if(FloatLessThan(min_value, 1)) { // If min_value is greater then 0 do not set a min value
      if(FloatLessThan(mag, min_value)) mag = missing_value;
      if(FloatLessThan(dir, min_value)) dir = missing_value;
    }

    if((mag != missing_value) && (dir != missing_value)) {
      FindXYMag(mag, dir, magX, magY, convert_to_knots, convert_to_ms);
    }
    else if((mag == missing_value) && (dir != missing_value)) {
      mag = 0;
      FindXYMag(mag, dir, magX, magY, convert_to_knots, convert_to_ms);
    }
    else if((mag != missing_value) && (dir == missing_value)) {
      dir = 0;
      FindXYMag(mag, dir, magX, magY, convert_to_knots, convert_to_ms);
    }
    else {
      magX = magY = missing_value;
    }

    magX_fp.df_Write(&magX, sizeof(magX));
    if(magX_fp.df_GetError() != DiskFileB::df_NO_ERROR) {
      std::cout << "ERROR - Cannot write to file " <<  magX_filename.c_str() << "\n" << std::flush;
      error_flag = 1;
      break;
    }

    magY_fp.df_Write(&magY, sizeof(magY));
    if(magY_fp.df_GetError() != DiskFileB::df_NO_ERROR) {
      std::cout << "ERROR - Cannot write to file " <<  magY_filename.c_str() << "\n" << std::flush;
      error_flag = 1;
      break;
    }
  } 
      
  mag_fp.df_Close();
  dir_fp.df_Close();
  magX_fp.df_Close();
  magY_fp.df_Close();

  if(error_flag > 0) {
    return 1;
  }

  // Interpolate the wind using our U and V files
  if(ncv.projectionType == "LATLON") {
    std::cout << "INFO - No interpolation needed for LATLON input grid" << "\n" << std::flush;
  }
  else {
    std::cout << "INFO - Starting interpolation routine for projected AWIPS grid" << "\n" << std::flush;
    std::cout << "Interpolating the projected grid to a LATLON grid" << "\n" << std::flush;

    gxString out_filename;
    InterpolateGrid interp(ncv);
    interp.missing_value = missing_value;
    interp.itype = itype;

    switch(itype) {
      case NO_INTERP:
	std::cout << "WARNING - Interpolation type is set to none, output can only be used for testing" << "\n" << std::flush;
	break;
      case REMAPTEST_INTERP:
	std::cout << "WARNING - Interpolation type is set to remaptest, output can only be used for testing" << "\n" << std::flush;
	break;
      case NEAREST_INTERP:
	std::cout << "INFO - Interpolation type is set to nearest neighbor" << "\n" << std::flush;
	break;
      case LINEAR_INTERP:
	std::cout << "INFO - Interpolation type is set to linear" << "\n" << std::flush;
	break;
      case BILINEAR_INTERP:
	std::cout << "INFO - Interpolation type is set to bilinear" << "\n" << std::flush;
	break;
      default: // Our default is nearest neighbor
	std::cout << "INFO - Interpolation type is set to nearest neighbor" << "\n" << std::flush;
	break;
    }

    std::cout << "Interpolating wind U projected data onto the LATLON grid" << "\n" << std::flush;
    out_filename << clear << output_dir << "wind_u_interpolated" << ".bin";
    if(!interp.WriteInterpolatedGrid(ncv, magX_filename, out_filename)) {
      std::cout << interp.error_string.c_str() << "\n" << std::flush;
      return 1;
    }

    std::cout << "Interpolating wind V projected data onto the LATLON grid" << "\n" << std::flush;
    out_filename << clear << output_dir << "wind_v_interpolated" << ".bin";
    if(!interp.WriteInterpolatedGrid(ncv, magY_filename, out_filename)) {
      std::cout << interp.error_string.c_str() << "\n" << std::flush;
      return 1;
    }

    magX_filename << clear << output_dir << "wind_u_interpolated" << ".bin";
    magY_filename << clear << output_dir << "wind_v_interpolated" << ".bin";
  }

  unsigned nx = (unsigned)ncv.domain.gridSize[0];
  unsigned ny = (unsigned)ncv.domain.gridSize[1];

  gxString full_windfile_name;
  full_windfile_name << clear << output_dir << windfile_name;
  std::cout << "Writing U/V wind file for SWAN " << full_windfile_name.c_str() << "\n" << std::flush;
  const unsigned total_grid_points = nx * ny;
  std::cout << "Number of points per forecast hour = " << total_grid_points << "\n" << std::flush;
  
  DiskFileB windfile_fp;
  windfile_fp.df_Create(full_windfile_name.c_str());
  if(windfile_fp.df_GetError() != DiskFileB::df_NO_ERROR) {
    std::cout << "ERROR - Cannot create file " <<  full_windfile_name.c_str() << "\n" << std::flush;
    return 1;
  }

  magX_fp.df_Open(magX_filename.c_str());
  if(magX_fp.df_GetError() != DiskFileB::df_NO_ERROR) {
    std::cout << "ERROR - Cannot open file " <<  magX_filename.c_str() << "\n" << std::flush;
    return 1;
  }

  magY_fp.df_Open(magY_filename.c_str());
  if(magY_fp.df_GetError() != DiskFileB::df_NO_ERROR) {
    std::cout << "ERROR - Cannot open file " <<  magY_filename.c_str() << "\n" << std::flush;
    return 1;
  }

  num_points = 0;
  error_flag = 0;
  unsigned num_forecast_hours = 0;

  while(!magX_fp.df_EOF() && !magY_fp.df_EOF()) {
    for(i = 0; i < total_grid_points; i++) {
      magX_fp.df_Read((unsigned char *)&magX, sizeof(magX));
      if(magX_fp.df_GetError() != DiskFileB::df_NO_ERROR) {
	std::cout << "ERROR - Cannot read from file " <<  magX_filename.c_str() << "\n" << std::flush;
	error_flag = 1;
	break;
      }
      memset(fbuf, 0, sizeof(fbuf));
      sprintf(fbuf, "%.2f", magX);
      windfile_fp << fbuf << "\n";
      num_points++;
    }
    if(error_flag > 0) break;

    for(i = 0; i < total_grid_points; i++) {
      magY_fp.df_Read((unsigned char *)&magY, sizeof(magY));
      if(magY_fp.df_GetError() != DiskFileB::df_NO_ERROR) {
	std::cout << "ERROR - Cannot read from file " <<  magY_filename.c_str() << "\n" << std::flush;
	error_flag = 1;
	break;
      }
      memset(fbuf, 0, sizeof(fbuf));
      sprintf(fbuf, "%.2f", magY);
      windfile_fp << fbuf << "\n";
      num_points++;
    }
     if(error_flag > 0) break;
     num_forecast_hours++;
  }

  magX_fp.df_Close();
  magY_fp.df_Close();
  windfile_fp.df_Close();
  
  if(error_flag > 0) return 1;

  std::cout << "Wind file complete with " << num_points << " U and V data points" << "\n" << std::flush;
  std::cout << "Number of forecast hours " << num_forecast_hours << "\n" << std::flush;

  if(grads_output) {
    gxString outfile = "wind";
    if(!WriteGradsOutput(ncv, magX_filename, magY_filename, output_dir)) return 1;
  }

  return 0;
}

void VersionMessage()
{
  std::cout << "\n" << std::flush;
  std::cout << program_name << " version " << version_string << "\n" << std::flush; 
  std::cout << program_description << "\n" << std::flush; 
  std::cout <<  "Produced for: " << project_acro << " project" << "\n" << std::flush; 
  std::cout <<  "Produced by: " << produced_by << "\n" << std::flush; 
  if(contributors) std::cout << contributors << "\n" << std::flush; 
  std::cout << "\n" << std::flush;
}

void HelpMessage()
{
  std::cout << "Usage:" << "\n" << std::flush;
  std::cout << "        " << process_name.c_str() << " [args] windfile.txt [output_directory]" << "\n" << std::flush;
  std::cout << "\n" << std::flush;
  std::cout << "args = Optional dash arguments" << "\n" << std::flush;
  std::cout << "windfile.txt = Input ncdump file" << "\n" << std::flush;
  std::cout << "output_directory = Optional output directory to write program output" << "\n" << std::flush;
  std::cout << "\n" << std::flush;
  std::cout << "args: " << "\n" << std::flush;
  std::cout << "     --help                      Print help message and exit" << "\n" << std::flush;
  std::cout << "     --version                   Print version number and exit" << "\n" << std::flush;
  std::cout << "     --debug                     Enable debug mode default level --debug=1" << "\n" << std::flush;
  std::cout << "     --debug-level=3             Set debugging level" << "\n" << std::flush;
  std::cout << "     --verbose                   Turn on verbose messaging to stderr" << "\n" << std::flush;
  std::cout << "     --timestep=n                Specify time step, defaults to netCDF value" << "\n" << std::flush;
  std::cout << "     --itype=\"type\"              Specify interpolation type for projected grids" << "\n" << std::flush;
  std::cout << "                                 itype can be: nearest, linear, bilinear, none, or remaptest" 
	    << "\n" << std::flush;
  std::cout << "     --missing-value=n           Specify missing value, defaults to 9999.0" << "\n" << std::flush;
  std::cout << "     --min-value=n               Specify minimum value, defaults to 0" << "\n" << std::flush;
  std::cout << "     --grads                     Write GRADS plotting output BIN files" << "\n" << std::flush;
  std::cout << "\n" << std::flush;
  std::cout << "Example1: " << process_name.c_str() << " 201101251431_WIND.txt" << "\n" << std::flush;
  std::cout << "Example2: " << process_name.c_str() << " 201101251431_WIND.txt /tmp" << "\n" << std::flush;
  std::cout << "Example3: " << process_name.c_str() << " --timestep=3 201101251431_WIND.txt /tmp" << "\n" << std::flush;
  std::cout << "Example4: " << process_name.c_str() << " --itype=bilinear 201101251431_WIND.txt /tmp" << "\n" << std::flush;
  std::cout << "Example5: " << process_name.c_str() << " --itype=bilinear --grads 201101251431_WIND.txt /tmp" << "\n" << std::flush;
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

  if(arg == "timestep") {
    if(equal_arg.is_null()) { 
      std::cout << "Error no time step number supplied with the --timestep" 
		  << "\n" << std::flush;
      return 0;
    }
    has_valid_args = 1;
    if(!equal_arg.is_null()) { 
      custom_timestep = equal_arg.Atoi(); 
      if(custom_timestep <= 0) custom_timestep = 0;
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

  if(arg == "min-value") {
    if(equal_arg.is_null()) { 
      std::cout << "Error no min value supplied with the --missing-value" 
		  << "\n" << std::flush;
      return 0;
    }
    has_valid_args = 1;
    if(!equal_arg.is_null()) { 
      min_value = (float)equal_arg.Atof(); 
    }
  }

  if(arg == "grads") {
    has_valid_args = 1;
    grads_output = 1;
  }


  if(arg == "itype") {
    if(equal_arg.is_null()) { 
      std::cout << "Error no interpolation type supplied with the --itype swtich" 
		  << "\n" << std::flush;
      return 0;
    }
    has_valid_args = 1;
    itype_string = equal_arg;
    itype_string.ToLower();
    if(itype_string == "none") {
      itype = NO_INTERP;
    }
    else if(itype_string == "nearest") {
      itype = NEAREST_INTERP;
    }
    else if(itype_string == "linear") {
      itype = LINEAR_INTERP;
    }
    else if(itype_string == "bilinear") {
      itype = BILINEAR_INTERP;
    }
    else if(itype_string == "remaptest") {
      itype = REMAPTEST_INTERP;
    }
    else {
      std::cout << "Bad interpolation type supplied with the --itype swtich" 
		  << "\n" << std::flush;
      return 0;
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

int WriteGradsOutput(netCDFVariables &ncv, const gxString &magX_filename, const gxString &magY_filename, 
		     const gxString &outdir)
{
  DiskFileB magX_fp, magY_fp, grads_fp, ctl_fp, inventory_fp, siteid_fp;  
  std::cout << "Writing GRADS output files to plot wind grid" << "\n" << std::flush;
  gxString my_outdir = outdir;
  if(my_outdir[my_outdir.length()-1] != '/') my_outdir << "/";

  std::cout << "Opening file " << magX_filename.c_str() << "\n" << std::flush;
  std::cout << "Opening file " << magY_filename.c_str() << "\n" << std::flush;
  magX_fp.df_Open(magX_filename.c_str());
  if(magX_fp.df_GetError() != DiskFileB::df_NO_ERROR) {
    std::cout << "ERROR - Cannot open file " <<  magX_filename.c_str() << "\n" << std::flush;
    return 0;
  }
  magY_fp.df_Open(magY_filename.c_str());
  if(magY_fp.df_GetError() != DiskFileB::df_NO_ERROR) {
    std::cout << "ERROR - Cannot open file " <<  magY_filename.c_str() << "\n" << std::flush;
    return 0;
  }

  float magX, magY;
  unsigned i, cur_hour;
  unsigned nx = (unsigned)ncv.domain.gridSize[0];
  unsigned ny = (unsigned)ncv.domain.gridSize[1];
  const unsigned gridsize = nx * ny;
  gxString fname;
  gxString inventory_fname, siteid_fname;
  gxString sbuf;
  int error_flag = 0;
  time_t start_time = 0;
  const time_t time_inc = 3600;
  inventory_fname << clear << my_outdir << "inventory" << ".txt";
  siteid_fname << clear << my_outdir << "siteid" << ".txt";
  char hour[25]; char day[25]; char month[25]; char year[25];
  memset(month, 0, sizeof(month));
  memset(day, 0, sizeof(day));
  memset(year, 0, sizeof(year));
  memset(hour, 0, sizeof(hour));
  struct tm *TimeBuffer;
  struct tm tbuf;
  float *dir_vals = new float[gridsize];

  inventory_fp.df_Create(inventory_fname.c_str());
  if(inventory_fp.df_GetError() != DiskFileB::df_NO_ERROR) {
    std::cout << "ERROR - Cannot create file " <<  inventory_fname.c_str() << "\n" << std::flush;
    return 0;
  }

  siteid_fp.df_Create(siteid_fname.c_str());
  if(siteid_fp.df_GetError() != DiskFileB::df_NO_ERROR) {
    std::cout << "ERROR - Cannot create file " <<  siteid_fname.c_str() << "\n" << std::flush;
    return 0;
  }
  siteid_fp << ncv.siteID.c_str();

  std::cout << "Number of points per forecast hour = " << gridsize << "\n" << std::flush;
  cur_hour = 0;
  while(!magX_fp.df_EOF() && !magY_fp.df_EOF()) {
    if(cur_hour < 100) {
      if(cur_hour < 10) {
	fname << clear << my_outdir << "wind_f00" << cur_hour << ".bin";
      }
      else {
	fname << clear << my_outdir << "wind_f0" << cur_hour << ".bin";
      }
    }
    else {
      fname << clear << my_outdir << "wind_f" << cur_hour << ".bin";
    }
    start_time = ncv.start_time + (time_inc * cur_hour);

    memset(&tbuf, 0, sizeof(tbuf));
    TimeBuffer = gmtime(&start_time);
    memcpy((unsigned char *)&tbuf, (unsigned char *)TimeBuffer, sizeof(tbuf));
    strftime(month, 25, "%b", &tbuf);
    strftime(day, 25, "%d", &tbuf);
    strftime(year, 25, "%Y", &tbuf);
    strftime(hour, 25, "%H", &tbuf);

    std::cout << "Writing wind file for GRADS " << fname.c_str() << "\n" << std::flush;
    sbuf << clear << start_time; 
    inventory_fp << fname.c_str() <<  ":" << sbuf.c_str() << ":" << hour << "z" << day << month << year << "\n"; 
 
    grads_fp.df_Create(fname.c_str());
    if(grads_fp.df_GetError() != DiskFileB::df_NO_ERROR) {
      std::cout << "ERROR - Cannot create file " <<  fname.c_str() << "\n" << std::flush;
      error_flag = 1;
      break;
    }

    float mag, dir;
    int convert_to_knots = 1;
    int convert_to_ms = 0;

    for(i = 0; i < gridsize; i++) {
      magX_fp.df_Read((unsigned char *)&magX, sizeof(float));
      if(magX_fp.df_GetError() != DiskFileB::df_NO_ERROR) {
	std::cout << "ERROR - Cannot read from file " <<  magX_filename.c_str() << "\n" << std::flush;
	error_flag = 1;
	break;
      }
      magY_fp.df_Read((unsigned char *)&magY, sizeof(float));
      if(magY_fp.df_GetError() != DiskFileB::df_NO_ERROR) {
	std::cout << "ERROR - Cannot read from file " <<  magY_filename.c_str() << "\n" << std::flush;
	error_flag = 1;
	break;
      }

      if((magX != missing_value) && (magY != missing_value)) {
	FindWindSpeedAndDir(magX, magY, mag, dir, convert_to_knots, convert_to_ms);
      }
      else if((magX == missing_value) && (magY != missing_value)) {
	magX = 0;
	FindWindSpeedAndDir(magX, magY, mag, dir, convert_to_knots, convert_to_ms);
      }
      else if((magX != missing_value) && (magY == missing_value)) {
	magY = 0;
	FindWindSpeedAndDir(magX, magY, mag, dir, convert_to_knots, convert_to_ms);
      }
      else {
	mag = dir = missing_value;
      }

      grads_fp.df_Write(&mag, sizeof(mag));
      if(grads_fp.df_GetError() != DiskFileB::df_NO_ERROR) {
	std::cout << "ERROR - Cannot write to file " <<  fname.c_str() << "\n" << std::flush;
	error_flag = 1;
	break;
      }
      dir_vals[i] = dir;
    }


    if(error_flag > 0) break;
    for(i = 0; i < gridsize; i++) {
      grads_fp.df_Write(&dir_vals[i], sizeof(dir_vals[i]));
      if(grads_fp.df_GetError() != DiskFileB::df_NO_ERROR) {
	std::cout << "ERROR - Cannot write to file " <<  fname.c_str() << "\n" << std::flush;
	error_flag = 1;
	break;
      }
    }

    if(error_flag > 0) break;
    cur_hour += ncv.time_step;
    grads_fp.df_Close();
  } 

  delete [] dir_vals;
  magX_fp.df_Close();
  magY_fp.df_Close();

  if(error_flag > 0) return 0;

  gxString grads_ctl_fname;
  gxString ctl;

  ctl.Clear();
  ctl << "DSET wind.bin\n";
  ctl << "TITLE AWIPS re-projected wind grid\n";
  ctl << "UNDEF " << missing_value << "\n";
  ctl.Precision(6);

  ctl << "xdef " << (int)(ncv.domain.gridSize[0]) << " linear " 
      << ncv.domain.SOUTHWESTLON << " " << ncv.domain.EWR << "\n";
  ctl << "ydef " << (int)(ncv.domain.gridSize[1]) << " linear "
      << ncv.domain.SOUTHWESTLAT << " " << ncv.domain.NSR << "\n";
  ctl << "zdef 1 linear 1 1\n";

  memset(&tbuf, 0, sizeof(tbuf));
  TimeBuffer = gmtime(&ncv.start_time);
  memcpy((unsigned char *)&tbuf, (unsigned char *)TimeBuffer, sizeof(tbuf));

  strftime(month, 25, "%b", &tbuf);
  strftime(day, 25, "%d", &tbuf);
  strftime(year, 25, "%Y", &tbuf);
  strftime(hour, 25, "%H", &tbuf);

  ctl << "tdef 1 linear " << hour << "z" << day << month << year << " " << ncv.time_step << "hr\n";
  ctl << "vars 2\n";
  ctl << "  Wind_Mag_SFC=>wndspd 0 t,z,y,x wind speed (kt)\n";
  ctl << "  Wind_Dir_SFC=>wnddir 0 t,z,y,x wind direction (degrees)\n";
  ctl << "endvars\n";

  std::cout << "\n" << ctl.c_str() << "\n" << std::flush;

  grads_ctl_fname << clear << my_outdir << "wind.ctl"; 
  std::cout << "Writing GRADS control file " << grads_ctl_fname.c_str() << "\n" << std::flush;

  ctl_fp.df_Create(grads_ctl_fname.c_str());
  if(ctl_fp.df_GetError() != DiskFileB::df_NO_ERROR) {
    std::cout << "ERROR - Cannot create file " <<  grads_ctl_fname.c_str() << "\n" << std::flush;
    return 0;
  }
  ctl_fp << ctl.c_str();

  return 1;
}
// ----------------------------------------------------------- //
// ------------------------------- //
// --------- End of File --------- //
// ------------------------------- //

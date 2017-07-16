// ------------------------------- //
// -------- Start of File -------- //
// ------------------------------- //
// ----------------------------------------------------------- // 
// C++ Source Code File
// Compiler Used: MSVC, GCC
// Produced By: Douglas.Gaer@noaa.gov
// File Creation Date: 03/01/2011
// Date Last Modified: 01/06/2017
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

Program used to convert raw SWAN output to a fortan BIN file
that can be plotted in GRADS and encoded in to a GRIB2 message
using WGRIB2.  

*/
// ----------------------------------------------------------- // 

// GNU C/C++ include files
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>

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
#include "membuf.h"
#include "gxlist.h"

// Our API include files
#include "g2_cpp_headers.h"
#include "g2_utils.h"
#include "g2_meta_file.h"

const char *version_string = "5.03";
const char *program_name = "swan_out_to_bin";
const char *program_description = "Program used convert raw SWAN output to a fortan BIN file";
const char *project_acro = "NWPS";
const char *produced_by = "Douglas.Gaer@noaa.gov";

// Default global settings
const char *default_outfile_name = "swanout.bin";

// Global variables
int debug = 0;
int debug_level = 1;
int verbose = 0;
int num_command_line_args;
gxString process_name;
gxString meta_template;
gxString meta_template1;
gxString meta_template2;

// Default exception values
const float default_nan = 9.999e+20;
float input_nan = .0;
float input_lt_nan = .0;
float input_gt_nan = .0;
int user_input_nan = 0;
int user_input_lt_nan = 0;
int user_input_gt_nan = 0;
float nan_value = default_nan;

// Functions
void program_version();
void HelpMessage();
int ProcessArgs(int argc, char *argv[]);
int ProcessDashDashArg(gxString &arg);
int findSpeedAndDir(float x, float y, float &mag, float &theta, int convert_to_knots = 0);
int CreateGrib2TemplateFile(gxString &tfname, DiskFileB &tfile);
int WriteGrib2Template(gxString *meta_fname, const int forecast_time, MemoryBuffer *obuf);
int WriteGrib2Message2Buffer(GRIB2Message &g2message, MemoryBuffer *obuf);
int WriteGrib2TemplateFile(gxString &tfname, DiskFileB &tfile, MemoryBuffer &g2_templates);

int main(int argc, char **argv)
{
  process_name = argv[0];
  int error_level = 0;
  int narg = 1;
  char *arg = argv[narg = 1];
  int argc_count = 0;
  gxString fname;
  int num_data_points = 0;
  int time_step = 0;
  int num_of_comps = 0;
  int run_len = 0;
  gxString element_1, element_2;
  gxString comp_type = "vector";

  while(narg < argc) {
    if(arg[0] != '\0') {
      if(arg[0] == '-') { // Look for command line arguments
	// Exit if argument is not valid or argument signals program to exit
	if(!ProcessArgs(argc, argv)) return 1;
      }
      else {
	// Our arguments to program 
	if(argc_count == 0) fname = arg;
	if(argc_count == 1) num_data_points = atoi(arg);
	if(argc_count == 2) time_step = atoi(arg);
	if(argc_count == 3) num_of_comps = atoi(arg);
	if(argc_count == 4) run_len = atoi(arg);
	if(argc_count == 5) element_1 = arg;
	if(argc_count == 6) element_2 = arg;
	if(argc_count == 7) comp_type = arg;
	argc_count++;
      }
    }
    arg = argv[++narg];
  }

  if(argc < 5) {
    std::cout << "ERROR - You must provide a filename, num_data_points, time_step, number_of_components, and run_length" << "\n";
    program_version();
    HelpMessage();
    return 1;
  }
  
  if(verbose) program_version();
  comp_type.ToLower();

  if(element_1.is_null()) element_1 = "1";
  if(element_2.is_null()) element_2 = "2";

  int convert_to_knots = 0;
  if(comp_type == "speeddirknots") {
    convert_to_knots = 1;
    comp_type = "speeddir";
  }

  if(verbose == 1) {
    std::cout << "Verbose mode is on" << "\n";
    std::cout << "\n";
  }

  if(debug == 1) {
    std::cout << "Debug mode is on" << "\n";
    std::cout << "debug_level = " << debug_level << "\n";
    std::cout << "\n";
  }

  int total_num_of_points = num_data_points * ((run_len/time_step) +1);
  if(total_num_of_points <= 0) {
    std::cout << "ERROR - Bad total number of data points " << total_num_of_points << "\n";
    return 1;
  }
  unsigned membuf_size = total_num_of_points * sizeof(float);

  if(verbose == 1) {
    std::cout << "fname = " << fname.c_str() << "\n";
    std::cout << "num_data_points = " << num_data_points << "\n";
    std::cout << "time_step = " << time_step << "\n";
    std::cout << "num_of_comps = " << num_of_comps << "\n";
    std::cout << "run_len = " << run_len << "\n";
    std::cout << "element_1 = " << element_1.c_str() << "\n";
    std::cout << "element_2 = " << element_2.c_str() << "\n";
    std::cout << "comp_type = " << comp_type << "\n";

    if((user_input_nan == 0) && (user_input_lt_nan == 0) && (user_input_gt_nan == 0)) {
      std::cout << "Using SWAN default exception values" << "\n";
    }
    else {
      if(user_input_nan) {
	std::cout << "Replacing SWAN default execption values" << "\n";
	std::cout << "Input value = ";
	printf("%E\n", input_nan);
	std::cout << "Replacement value = ";
	printf("%E\n", nan_value);
      }
      if(user_input_lt_nan) {
	std::cout << "Replacing SWAN execption values with less than value" << "\n";
	std::cout << "Less than value = ";
	printf("%E\n", input_lt_nan);
	std::cout << "Replacement value = ";
	printf("%E\n", nan_value);
      }
      if(user_input_gt_nan) {
	std::cout << "Replacing SWAN execption values with greater than value" << "\n";
	std::cout << "Greater than value = ";
	printf("%E\n", input_gt_nan);
	std::cout << "Replacement value = ";
	printf("%E\n", nan_value);
      }
    }
    std::cout << "\n";
  }

  char sbuf[8192]; // Allow really long lines
  gxString ofname, tfname;
  DiskFileB ifile, ofile, tfile;

  ifile.df_Open(fname.c_str());
  if(!ifile) {
    std::cout << "ERROR - Cannot open SWAN output file " << fname.c_str() << "\n";
    std::cout << ifile.df_ExceptionMessage() << "\n";
    error_level++;
  }

  if(!meta_template.is_null()) {
    if(!futils_exists(meta_template.c_str())) {
      std::cout << "ERROR - Meta template does not exist " << meta_template.c_str() << "\n";
      error_level++;
    }
    else {
      if(num_of_comps == 2) {
	std::cout << "ERROR - You must supply 2 meta templates for both components" << "\n";
	error_level++;
      }
    }
  }

  if(num_of_comps == 2) {
    if(!meta_template1.is_null()) {
      if(!futils_exists(meta_template1.c_str())) {
	std::cout << "ERROR - Meta template does not exist " << meta_template1.c_str() << "\n";
	error_level++;
      }
      if(meta_template2.is_null()) {
	std::cout << "ERROR - Missing meta template 2 for component 2" << "\n";
	error_level++;
      } 
    }
    if(!meta_template2.is_null()) {
      if(!futils_exists(meta_template2.c_str())) {
	std::cout << "ERROR - Meta template does not exist " << meta_template2.c_str() << "\n";
	error_level++;
      }
      if(meta_template1.is_null()) {
	std::cout << "ERROR - Missing meta template 1 for component 1" << "\n";
	error_level++;
      } 
    }
  }

  if(error_level != 0) {
    ifile.df_Close();
    return 1;
  }

  int point_number = 0;
  gxString delimiter = " ";
  int curr_hour = 0;
  MemoryBuffer point_array1;
  MemoryBuffer point_array2;

  // Pre-allocate memory for the point arrays
  point_array1.Alloc(membuf_size);
  point_array1.Clear();

  if(num_of_comps == 2) {
    point_array2.Alloc(membuf_size);
    point_array2.Clear();
  }

  ofname << clear << fname << ".bin";
  tfname << clear << fname << "_template.grib2";

  std::cout << "Writing merged output file " << ofname.c_str() << "\n";
  ofile.df_Create(ofname.c_str());
  if(!ofile) {
    std::cout << "ERROR - Cannot create merged BIN output file " << ofname.c_str() << "\n";
    std::cout << ofile.df_ExceptionMessage() << "\n";
    return 1;
  }

  int comp_number = 1;
  gxString *vals = 0;
  const unsigned template_size = 179 * 156;
  MemoryBuffer g2_templates1;
  MemoryBuffer g2_templates2;

  // Pre-allocate memory for the point arrays
  g2_templates1.Alloc(template_size);
  g2_templates1.Clear();
  if(num_of_comps == 2) {
    g2_templates2.Alloc(template_size);
    g2_templates2.Clear();
  }

  MemoryBuffer *g2_templates = &g2_templates1;
  MemoryBuffer *points_ptr = &point_array1;
  gxString *meta_fname = &meta_template;
  if(num_of_comps == 2) meta_fname = &meta_template1;

  while(!ifile.df_EOF()) {
    // Get each line of the file and trim the line feeds
    ifile.df_GetLine(sbuf, sizeof(sbuf), '\n');
    if(ifile.df_GetError() != DiskFileB::df_NO_ERROR) {
      std::cout << "ERROR - A fatal I/O error reading SWAN output file" << "\n";
      std::cout << "ERROR - Cannot read file " <<  fname.c_str() << "\n";
      std::cout << ifile.df_ExceptionMessage() << "\n";
      error_level = 1;
      break;
    }

    UString info_line(sbuf);
    info_line.FilterChar('\n');
    info_line.FilterChar('\r');
    info_line.TrimLeadingSpaces();
    info_line.TrimTrailingSpaces();

    if(info_line.is_null()) continue;
    
    // Skip remark lines
    if(info_line[0] == '#') continue; 
    if(info_line[0] == ';') continue; 

    // Replace multiple spaces in between point values
    while(info_line.IFind("  ") != -1) info_line.ReplaceString("  ", " ");  
    unsigned num_arr = 0;
    unsigned i = 0;

    if(num_of_comps == 1) {
      vals = ParseStrings(info_line, delimiter, num_arr);
      for(i = 0; i < num_arr; i++) {
	float f = 0;
	sscanf(vals[i].c_str(), "%f", &f);
	if(user_input_nan == 1) {
	  if(f == input_nan) f = nan_value;
	}
	if(user_input_lt_nan == 1) {
	  if(f < input_lt_nan) f = nan_value;
	}
	if(user_input_gt_nan == 1) {
	  if(f > input_gt_nan) f = nan_value;
	}
	points_ptr->Cat(&f, sizeof(f));
	point_number++;
	if(point_number == num_data_points) {
	  if(verbose) {
	    std::cout << "Time step complete for hour " << curr_hour << "\n";
	    std::cout << "Number of data points = " << point_number << "\n";
	  }
	  if(!meta_template.is_null()) {
	    if(WriteGrib2Template(meta_fname, curr_hour, g2_templates) != 0) {
	      error_level++;
	      break;
	    } 
	  }
	  if(ifile.df_EOF()) break;
	  point_number = 0;
	  curr_hour += time_step;
	}
      }
    }
    else {
      vals = ParseStrings(info_line, delimiter, num_arr);
      for(i = 0; i < num_arr; i++) {
	float f = 0;
	sscanf(vals[i].c_str(), "%f", &f);
	if(user_input_nan == 1) {
	  if(f == input_nan) f = nan_value;
	}
	if(user_input_lt_nan == 1) {
	  if(f < input_lt_nan) f = nan_value;
	}
	if(user_input_gt_nan == 1) {
	  if(f > input_gt_nan) f = nan_value;
	}
	points_ptr->Cat(&f, sizeof(f));
	point_number++;
      
	if(point_number == num_data_points) {
	  if(verbose) {
	    std::cout << "Time step complete for hour " << curr_hour << "\n";
	    std::cout << "Number of data points = " << point_number << "\n";
	  }
	  if(!meta_template1.is_null() && !meta_template2.is_null()) {
	    if(WriteGrib2Template(meta_fname, curr_hour, g2_templates) != 0) {
	      error_level++;
	      break;
	    } 
	  }
	  if(ifile.df_EOF()) break;
	  point_number = 0;

	  if(comp_number == 1) { 
	    comp_number = 2;
	    points_ptr = &point_array2;
	    g2_templates = &g2_templates2;
	    meta_fname = &meta_template2;
	  }
	  else if(comp_number == 2) {
	    comp_number = 1;
	    points_ptr = &point_array1;
	    g2_templates = &g2_templates1;
	    meta_fname = &meta_template1;
	    curr_hour += time_step;
	  }

      	}
      }
    }
    if(vals) { delete[] vals; vals = 0; }
  }
  ifile.df_Close();
  if(vals) { delete[] vals; vals = 0; }

  if(point_array1.length() != membuf_size) {
    std::cout << "ERROR - Bad SWAN input file, read " 
	      << point_array1.length() << " points, expected "
	      << membuf_size << "\n";
    error_level++;
  }
  if(num_of_comps == 2) {
    if(point_array1.length() != point_array2.length()) {
      std::cout << "ERROR - Bad 2nd component from SWAN input file, read " 
		<< point_array2.length() << " points, expected "
		<< membuf_size << "\n";
      error_level++;
    }
  }
  if(error_level != 0) {
    ofile.df_Close();
    std::cout << "ERROR - Error creating merged BIN file" << "\n";
    return 1;
  }

  if(comp_type != "speeddir") {
    ofile.df_Write(point_array1.m_buf(), point_array1.length()); 
    if(ofile.df_GetError() != DiskFileB::df_NO_ERROR) {
      std::cout << "ERROR - A fatal I/O error writing points to BIN file" << "\n" << std::flush;
      std::cout << "ERROR - Cannot write to file " <<  ofname.c_str() << "\n" << std::flush;
      std::cout << ofile.df_ExceptionMessage() << "\n" << std::flush;
      error_level++;
    }
    if(num_of_comps == 2) {
      ofile.df_Write(point_array2.m_buf(), point_array2.length()); 
      if(ofile.df_GetError() != DiskFileB::df_NO_ERROR) {
	std::cout << "ERROR - A fatal I/O error writing points to BIN file" << "\n" << std::flush;
	std::cout << "ERROR - Cannot write to file " <<  ofname.c_str() << "\n" << std::flush;
	std::cout << ofile.df_ExceptionMessage() << "\n" << std::flush;
	error_level++;
	
      }
    }
  }
  if(error_level != 0) {
    ofile.df_Close();
    std::cout << "ERROR - Error creating merged BIN file" << "\n";
    return 1;
  }

  if((comp_type == "speeddir") && (error_level == 0)) {
    std::cout << "Converting vector MAG and DIR to speed and direction" << "\n";
    unsigned i;
    for(i = 0; i < membuf_size; i+=sizeof(float)) {
      float datax_val, datay_val, mag, theta;
      memcpy(&datax_val, (point_array1.m_buf()+i), sizeof(float));
      memcpy(&datay_val, (point_array2.m_buf()+i), sizeof(float));
      
      findSpeedAndDir(datax_val, datay_val, mag, theta, convert_to_knots);
      memcpy((point_array1.m_buf()+i), &theta, sizeof(float));
      memcpy((point_array2.m_buf()+i), &mag, sizeof(float));
      if(error_level == 1) break;
    }
    
    ofile.df_Write(point_array1.m_buf(), point_array1.length()); 
    if(ofile.df_GetError() != DiskFileB::df_NO_ERROR) {
      std::cout << "ERROR - A fatal I/O error writing points to BIN file" << "\n" << std::flush;
      std::cout << "ERROR - Cannot write to file " <<  ofname.c_str() << "\n" << std::flush;
      std::cout << ofile.df_ExceptionMessage() << "\n" << std::flush;
      error_level++;
    }
    ofile.df_Write(point_array2.m_buf(), point_array2.length()); 
    if(ofile.df_GetError() != DiskFileB::df_NO_ERROR) {
      std::cout << "ERROR - A fatal I/O error writing points to BIN file" << "\n" << std::flush;
      std::cout << "ERROR - Cannot write to file " <<  ofname.c_str() << "\n" << std::flush;
      std::cout << ofile.df_ExceptionMessage() << "\n" << std::flush;
      error_level++;
    }
  }

  ofile.df_Close();

  if(error_level == 0) {
    if(!meta_template.is_null()) {
      error_level = CreateGrib2TemplateFile(tfname, tfile);
      if(error_level == 0) error_level = WriteGrib2TemplateFile(tfname, tfile, g2_templates1); 
      tfile.df_Close();
    }
    if(!meta_template1.is_null()) {
      error_level = CreateGrib2TemplateFile(tfname, tfile);
      if(error_level == 0) error_level = WriteGrib2TemplateFile(tfname, tfile, g2_templates1); 
    }
    if(!meta_template2.is_null()) {
      if(error_level == 0) error_level = WriteGrib2TemplateFile(tfname, tfile, g2_templates2); 
      tfile.df_Close();
    }
  }

  if(error_level != 0) {
    std::cout << "ERROR - Error creating merged BIN file" << "\n";
  }

  return error_level;
}

int findSpeedAndDir(float x, float y, float &mag, float &theta, int convert_to_knots)
{
  mag = 0;   // The magnitude of the vector is given by:
  theta = 0; // Direction angle

  float mag_vect = x*x + y*y;
  if(mag_vect < 0) {
    mag_vect -= mag_vect*2;
  }
  mag = sqrt(mag_vect);
  float pi = atan(1)*4;
 
  // The direction angle is assumed to be relative to north with a clockwise
  // direction being positive. Assuming meteorologic convention (direction from)
  if(x==0 && y==0) theta = 0;
  if(x==0 && y>0) theta = 180;
  if(x==0 && y<0) theta = 0;
  if(y==0 && x>0) theta = 270;
  if(y==0 && x<0) theta = 90;
  if(x>0 && y>0) theta = 270-atan(y/x)*180/pi;
  if(x<0 && y>0) theta = 90-atan(y/x)*180/pi;
  if(x<0 && y<0) theta = 90-atan(y/x)*180/pi;
  if(x>0 && y<0) theta = 270-atan(y/x)*180/pi;

  // NOTE: In this AWIPS I netCDF version we convert m/s to knots
  if(convert_to_knots) mag *= 1.94384; 

   return 1;
} 

void program_version()
{
  printf("\n");
  printf("%s version %s\n", program_name, version_string);
  printf("%s\n", program_description);
  printf("Produced for: %s project\n", project_acro);
  printf("Produced by: %s\n", produced_by);
  printf("\n");
}

int ProcessArgs(int argc, char *argv[])
{
  // process the program's argument list
  int i;
  char sbuf[255];
  gxString inbuf;
  char sw;
  num_command_line_args = 0;
  memset(sbuf, 0, sizeof(sbuf));
  
  for(i = 1; i < argc; i++ ) {
    if(*argv[i] == '-') {
      sw = *(argv[i] +1);
      switch(sw) {
	case '-':
	  inbuf = &argv[i][2]; 
	  // Add all -- prepend filters here
	  inbuf.TrimLeading('-');
	  if(!ProcessDashDashArg(inbuf)) return 0;
	  break;
	case '?':
	  program_version();
	  HelpMessage();
	  return 0; // Signal program to exit
	case 'v': case 'V': 
	  verbose = 1;
	  break;
	case 'd': case 'D':
	  debug = 1;
	  break;
	case 'n': case 'N':
	  strncpy(sbuf, &argv[i][2], (sizeof(sbuf)-1));
	  input_nan = atof(sbuf);
	  user_input_nan = 1;
	  break;
	case 'l': case 'L':
	  strncpy(sbuf, &argv[i][2], (sizeof(sbuf)-1));
	  input_lt_nan = atof(sbuf);
	  user_input_lt_nan = 1;
	  break;
	case 'g': case 'G':
	  strncpy(sbuf, &argv[i][2], (sizeof(sbuf)-1));
	  input_gt_nan = atof(sbuf);
	  user_input_gt_nan = 1;
	  break;
	case 'e': case 'E':
	  strncpy(sbuf, &argv[i][2], (sizeof(sbuf)-1));
	  nan_value = atof(sbuf);
	  break;
	default:
	  fprintf(stderr, "ERROR - Unknown - arg %s, use --help or -? for all options\n", argv[i]);
	  return 0;
      }
      num_command_line_args++;
    }
  }
  return 1; // All command line arguments were valid
}

void HelpMessage()
{
    std::cout << "Usage:" << "\n" << std::flush;
    std::cout << "        " << process_name << " [args] filename  num_points timestep num_elements run_len [dir] [mag] [speeddir]" << "\n";
    std::cout << "\n" << std::flush;
    std::cout << "args: " << "\n" << std::flush;
    std::cout << "     -? or --help                Print help message and exit" << "\n" << std::flush;
    std::cout << "     -v or --version             Print version number and exit" << "\n" << std::flush;
    std::cout << "     -d or --debug               Enable debug mode default level --debug=1" << "\n" << std::flush;
    std::cout << "     -D5 or--debug-level=5       Set debugging level" << "\n" << std::flush;
    std::cout << "     --verbose                   Turn on verbose messaging" << "\n" << std::flush;
    std::cout << "     -n\"-999.0\"              Define an input exception value" << "\n" << std::flush;
    std::cout << "     -e\"9.999e+20\"           Define replacment exception value" << "\n" << std::flush;
    std::cout << "     -l\"-1000\"               Define an input exception less than specified value" << "\n" << std::flush;
    std::cout << "     -g\"1000\"                Define an input exception greater than specified value" << "\n" << std::flush;
    std::cout << "     --meta-template=fname        File name of meta template for single component" << "\n" << std::flush;
    std::cout << "     --meta-template1=fname       File name of meta template for component one" << "\n" << std::flush;
    std::cout << "     --meta-template2=fname       File name of meta template for component two" << "\n" << std::flush;
    std::cout << "\n" << std::flush;
    std::cout << "Example1:" << "\n";
    std::cout << "           " << process_name << " HSIG.CG1.CGRID.YY11.MO01.DD25.HH00 627 3 1 24" << "\n";
    std::cout << "Example2:" << "\n";
    std::cout << "           " << process_name << " WIND.CG1.CGRID.YY11.MO01.DD25.HH00 627 3 2 24 dir mag speeddir" << "\n";
    std::cout << "Example3:" << "\n";
    std::cout << "           " << process_name << " WIND.CG1.CGRID.YY11.MO01.DD25.HH00 627 3 2 24 dir mag vector" << "\n";
    std::cout << "Example4:" << "\n";
    std::cout << "           " << process_name << " VARNAME.CG1.CGRID.YY11.MO01.DD25.HH00 627 3 2 24 u v uv" << "\n";
    std::cout << "Example5:" << "\n";
    std::cout << "           " << process_name << " WIND.CG1.CGRID.YY11.MO01.DD25.HH00 627 3 2 24 dir mag" << "\n";
    std::cout << "\n";
    std::cout << "Usage2: - Enable verbose debugging" << "\n";
    std::cout << "         " << process_name << " -v -d filename  num_points timestep num_elements run_len" << "\n";
    std::cout << "\n";
    std::cout << "Usage3 - Define an input exception value:" << "\n";
    std::cout << "         " << process_name << " -n\"-999\" filename  num_points timestep num_elements run_len" << "\n";
    std::cout << "\n";
    std::cout << "Usage3 - Define an input exception value and a replacment exception value:" << "\n";
    std::cout << "         " << process_name << " -n\"-999\" -e\"9.999e+20\" filename  num_points timestep num_elements run_len" << "\n";
    std::cout << "Usage4 - Define an input exception less than specified value:" << "\n";
    std::cout << "         " << process_name << " -l\"-1000\" filename  num_points timestep num_elements run_len" << "\n";
    std::cout << "Usage5 - Define an input exception greater than specified value:" << "\n";
    std::cout << "         " << process_name << " -g\"1000\" filename  num_points timestep num_elements run_len" << "\n";
    std::cout << "Usage6 - Define an input exception value range:" << "\n";
    std::cout << "         " << process_name << "-l\"-1000\" -g\"1000\" filename  num_points timestep num_elements run_len" << "\n";
    std::cout << "\n";
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
    program_version();
    HelpMessage();
    return 0; // Signal program to exit
  }
  if(arg == "?") {
    has_valid_args = 1;
    program_version();
    HelpMessage();
    return 0; // Signal program to exit
  }
  if((arg == "version") || (arg == "ver")) {
    has_valid_args = 1;
    program_version();
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
      std::cout << "ERROR - No debug level supplied with the --debug-level switch" 
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

  if(arg == "meta-template") {
    if(equal_arg.is_null()) { 
      std::cout << "ERROR - No file name supplied with the --meta-template switch" 
		  << "\n" << std::flush;
      return 0;
    }
    has_valid_args = 1;
    meta_template = equal_arg;
  }

  if(arg == "meta-template1") {
    if(equal_arg.is_null()) { 
      std::cout << "ERROR - No file name supplied with the --meta-template1 switch" 
		  << "\n" << std::flush;
      return 0;
    }
    has_valid_args = 1;
    meta_template1 = equal_arg;
  }

  if(arg == "meta-template2") {
    if(equal_arg.is_null()) { 
      std::cout << "ERROR - No file name supplied with the --meta-template2 switch" 
		  << "\n" << std::flush;
      return 0;
    }
    has_valid_args = 1;
    meta_template2 = equal_arg;
  }

  if(!has_valid_args) {
    std::cout << "ERROR - Unknown arg --" << arg.c_str() << ", use --help or -? for all options" 
	      << "\n" << std::flush;
    return 0;
  }

  arg.Clear();
  return has_valid_args;
}

int WriteGrib2Template(gxString *meta_fname, const int forecast_time, MemoryBuffer *obuf)
{
  GRIB2Message g2message;
  int type_of_data = 0;

  if(!LoadOrBuildMetaFile(meta_fname->c_str(), &g2message, debug)) {
    std::cout << "ERROR - Error loading meta data template file " << meta_fname->c_str() << "\n" << std::flush;
    return 1;
  }
  if(forecast_time == 0) {
    type_of_data = 0; // Analysis Products
    g2_set_int(type_of_data, g2message.sec1.type_of_data, sizeof(g2message.sec1.type_of_data));
  }
  else {
    type_of_data = 1; // Forecast Products
    g2_set_int(type_of_data, g2message.sec1.type_of_data, sizeof(g2message.sec1.type_of_data));
  }
  g2_set_int(forecast_time, g2message.templates.pt40.forecast_time, sizeof(g2message.templates.pt40.forecast_time));

  return WriteGrib2Message2Buffer(g2message, obuf);
}

// Append all the GRIB2 meassages to a memory buffer, return 0 if pass or 1 if fail
int WriteGrib2Message2Buffer(GRIB2Message &g2message, MemoryBuffer *obuf)
{
  unsigned char *buf = 0; // Memory representation buffer
  __g2ULLWORD__ message_length = 0; // Total length of GRIB2 message
  int write_sec7_withdata = 0;
  // Allocate and install template for Sec3
  g2message.sec3.AllocTemplate(sizeof(g2message.templates.gt30));
  g2message.templates.gt30.SetFileBuf();
  memcpy(g2message.sec3.grid_def, (unsigned char *)&g2message.templates.gt30, sizeof(g2message.templates.gt30));

  // Allocate and install template for Sec4
  g2message.sec4.AllocTemplate(sizeof(g2message.templates.pt40));
  g2message.templates.pt40.SetFileBuf();
  memcpy(g2message.sec4.product_def, (unsigned char *)&g2message.templates.pt40, sizeof(g2message.templates.pt40));

  // Allocate and install template for Sec5
  g2message.sec5.AllocTemplate(sizeof(g2message.templates.gt50));
  g2message.templates.gt50.SetFileBuf();
  memcpy(g2message.sec5.data_rep_template, (unsigned char *)&g2message.templates.gt50, sizeof(g2message.templates.gt50));

  // Alloc all zeros for section 7
  int num_data_points = g2_get_int(g2message.sec5.num_data_points, sizeof(g2message.sec5.num_data_points));
  if(num_data_points > 0) {
    if((debug) && (debug_level == 5)) {
      std::cout << "Allocating " << (unsigned)num_data_points << " data points for section 7" 
		<< "\n" << std::flush;
    }
    g2message.sec7.AllocData(num_data_points);
  }

  // Calculate size of GRIB2 message
  message_length = g2message.sec0.GetSize();
  message_length += g2message.sec1.GetSize();
  message_length += g2message.sec3.GetSize();
  message_length += g2message.sec4.GetSize();
  message_length += g2message.sec5.GetSize();
  message_length += g2message.sec6.GetSize();
  message_length += g2message.sec7.GetSize(write_sec7_withdata);
  message_length += sizeof(g2message.sec8);

  if(debug) {
    std::cout << "GRIB2 message length = " << (unsigned)message_length << "\n" << std::flush;
  }
  // Write the messages sections to the GRIB2 file
  buf = g2message.sec0.GetFileBuf(message_length);
  obuf->Cat(buf, g2message.sec0.GetSize());
  delete buf;

  buf = g2message.sec1.GetFileBuf();
  obuf->Cat(buf, g2message.sec1.GetSize());
  delete buf;

  buf = g2message.sec3.GetFileBuf();
  obuf->Cat(buf, g2message.sec3.GetSize());
  delete buf;

  buf = g2message.sec4.GetFileBuf();
  obuf->Cat(buf, g2message.sec4.GetSize());
  delete buf;

  buf = g2message.sec5.GetFileBuf();
  obuf->Cat(buf, g2message.sec5.GetSize());
  delete buf;

  buf = g2message.sec6.GetFileBuf();
  obuf->Cat(buf, g2message.sec6.GetSize());
  delete buf;

  buf = g2message.sec7.GetFileBuf(write_sec7_withdata);
  if(debug) {
    std::cout << "Writing " << (unsigned)g2message.sec7.GetSize(write_sec7_withdata) 
	      << " bytes section 7" << "\n" << std::flush;
  }
  obuf->Cat(buf, g2message.sec7.GetSize(write_sec7_withdata));
  delete buf;

  obuf->Cat((const unsigned char *)&g2message.sec8, sizeof(g2message.sec8));

  return 0;
}

int CreateGrib2TemplateFile(gxString &tfname, DiskFileB &tfile)
{
  std::cout << "Writing grib2 template file " << tfname.c_str() << "\n";

  tfile.df_Create(tfname.c_str());
  if(!tfile) {
    std::cout << "ERROR - Cannot create grib2 template file " 
	      << tfname.c_str() << "\n";
    std::cout << tfile.df_ExceptionMessage() << "\n";
    return 1;
  }

  return 0;
}

int WriteGrib2TemplateFile(gxString &tfname, DiskFileB &tfile, MemoryBuffer &g2_templates) 
{
  int error_level = 0;

  tfile.df_Write(g2_templates.m_buf(), g2_templates.length());
  if(tfile.df_GetError() != DiskFileB::df_NO_ERROR) {
    std::cout << "ERROR - A fatal I/O error to grib2 template file" << "\n" << std::flush;
    std::cout << "ERROR - Error write to file " <<  tfname.c_str() << "\n" << std::flush;
    std::cout << tfile.df_ExceptionMessage() << "\n" << std::flush;
    error_level = 1;
  }
  if(debug) std::cout << "Wrote " << g2_templates.length() << " bytes to " << tfname.c_str() << "\n" << std::flush;

  return error_level;
}
// ----------------------------------------------------------- //
// ------------------------------- //
// --------- End of File --------- //
// ------------------------------- //

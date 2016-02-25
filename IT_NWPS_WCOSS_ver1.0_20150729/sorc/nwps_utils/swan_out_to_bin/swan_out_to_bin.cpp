// ------------------------------- //
// -------- Start of File -------- //
// ------------------------------- //
// ----------------------------------------------------------- // 
// C++ Source Code File
// Compiler Used: MSVC, GCC
// Produced By: Douglas.Gaer@noaa.gov
// File Creation Date: 03/01/2011
// Date Last Modified: 06/02/2011
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

// Our API include files
#include "g2_cpp_headers.h"
#include "g2_meta_file.h"
#include "g2_utils.h"

const char *version_string = "1.22";
const char *program_name = "swan_out_to_bin";
const char *program_description = "Program used convert raw SWAN output to a fortan BIN file";
const char *project_acro = "NWPS";
const char *produced_by = "Douglas.Gaer@noaa.gov";

// Default global settings
const char *default_outfile_name = "swanout.bin";

// Global variables
int debug = 0;
int debug_level = 0;
int verbose = 0;

// Functions
void program_version();
int findSpeedAndDir(float x, float y, float &mag, float &theta, int convert_to_knots = 0);

int main(int argc, char *argv[])
{
  if(argc < 6) {
    std::cout << "ERROR - You must provide a filename, num_data_points, time_step, number_of_components, and run_length" << "\n";
    program_version();
    std::cout << "Usage:" << "\n";
    std::cout << "        " << argv[0] << " filename  num_points timestep num_elements run_len" << "\n";
    std::cout << "Example1:" << "\n";
    std::cout << "           " << argv[0] << " HSIG.CG1.CGRID.YY11.MO01.DD25.HH00 627 3 1 24" << "\n";
    std::cout << "Example2:" << "\n";
    std::cout << "           " << argv[0] << " WIND.CG1.CGRID.YY11.MO01.DD25.HH00 627 3 2 24 dir mag speeddir" << "\n";
    std::cout << "Example3:" << "\n";
    std::cout << "           " << argv[0] << " WIND.CG1.CGRID.YY11.MO01.DD25.HH00 627 3 2 24 dir mag vector" << "\n";
    std::cout << "Example4:" << "\n";
    std::cout << "           " << argv[0] << " VARNAME.CG1.CGRID.YY11.MO01.DD25.HH00 627 3 2 24 u v uv" << "\n";
    std::cout << "Example5:" << "\n";
    std::cout << "           " << argv[0] << " WIND.CG1.CGRID.YY11.MO01.DD25.HH00 627 3 2 24 dir mag" << "\n";
    std::cout << "\n";
    return 1;
  }

  program_version();

  // Our arguments to program 
  gxString fname = argv[1];
  int num_data_points = atoi(argv[2]);
  int time_step = atoi(argv[3]);
  int num_of_comps = atoi(argv[4]);
  int run_len = atoi(argv[5]);

  gxString element_1, element_2;
  if(argc >= 8) {
    element_1 = argv[6];
    element_2 = argv[7];
  }
  gxString comp_type = "vector";
  if(argc >= 9) {
    comp_type = argv[8];
  }
  comp_type.ToLower();

  if(element_1.is_null()) element_1 = "1";
  if(element_2.is_null()) element_2 = "2";

  int convert_to_knots = 0;
  if(comp_type == "speeddirknots") {
    convert_to_knots = 1;
    comp_type = "speeddir";
  }

  char sbuf[1024];
  gxString ofname;
  DiskFileB ifile, ofile;

  ifile.df_Open(fname.c_str());
  if(!ifile) {
    std::cout << "ERROR - Cannot open SWAN output file " << fname.c_str() << "\n";
    std::cout << ifile.df_ExceptionMessage() << "\n";
    return 1;
  }

  int point_number = 0;
  gxString delimiter = " ";
  int curr_hour = 0;

  if(num_of_comps == 2) {
    if(element_1.is_null()) {
      ofname << clear << curr_hour << "_1_" << fname << ".bin";
    }
    else {
      ofname << clear << curr_hour << "_" << element_1 << "_" << fname << ".bin";
    }
  }
  else {
    ofname << clear << curr_hour << "_" << fname << ".bin";
  }
  std::cout << "Writing output file " << ofname.c_str() << "\n";
  ofile.df_Create(ofname.c_str());
  if(!ofile) {
    std::cout << "ERROR - Cannot create BIN output file " << ofname.c_str() << "\n";
    std::cout << ofile.df_ExceptionMessage() << "\n";
    return 1;
  }

  int error_flag = 0;
  int comp_number = 1;
  int prev_hour = 0;
  gxString *vals;

  while(!ifile.df_EOF()) {
    // Get each line of the file and trim the line feeds
    ifile.df_GetLine(sbuf, sizeof(sbuf), '\n');
    if(ifile.df_GetError() != DiskFileB::df_NO_ERROR) {
      std::cout << "ERROR - A fatal I/O error reading SWAN output file" << "\n";
      std::cout << "ERROR - Cannot read file " <<  fname.c_str() << "\n";
      std::cout << ifile.df_ExceptionMessage() << "\n";
      error_flag = 1;
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
    info_line.ReplaceString("  ", " ");
    info_line.ReplaceString("   ", " ");
    info_line.ReplaceString("    ", " ");
    info_line.ReplaceString("      ", " ");
    info_line.ReplaceString("        ", " ");

    unsigned num_arr = 0;
    unsigned i = 0;
    vals = ParseStrings(info_line, delimiter, num_arr);
    if(comp_type == "uv") {
      for(i = 0; i < num_arr; i++) {
	float f = 0;
	sscanf(vals[i].c_str(), "%f", &f);
	ofile.df_Write(&f, sizeof(f));
	point_number++;
	if(point_number == num_data_points) {
	  std::cout << "Time step complete for hour " << curr_hour << "\n";
	  std::cout << "Number of data points = " << point_number << "\n";
	  ofile.df_Close();
	  if(ifile.df_EOF()) break;
	  point_number = 0;
	  if(num_of_comps == 2) {
	    if(comp_number == 1) {
	      curr_hour += time_step;
	      ofname << clear << curr_hour << "_" << element_1 << "_" << fname << ".bin";
	    }
	    else {
	      if(prev_hour != run_len) curr_hour += time_step;
	      ofname << clear << curr_hour << "_2_" << fname << ".bin";
	      prev_hour = curr_hour;
	    }
	    if(curr_hour == run_len) {
	      prev_hour = run_len;
	      curr_hour = 0;
	      comp_number = 2;
	    }
	  }
	  else {
	    curr_hour += time_step;
	    ofname << clear << curr_hour << "_" << fname << ".bin";
	  }
	  std::cout << "Writing output file " << ofname.c_str() << "\n";
	  ofile.df_Create(ofname.c_str());
	  if(!ofile) {
	    std::cout << "ERROR - Cannot create BIN output file " << ofname.c_str() << "\n";
	    std::cout << ofile.df_ExceptionMessage() << "\n";
	    error_flag = 1;
	    break;
	  }
	}
      }
    }
    else {
      for(i = 0; i < num_arr; i++) {
	float f = 0;
	sscanf(vals[i].c_str(), "%f", &f);
	ofile << f;
	point_number++;
	if(point_number == num_data_points) {
	  std::cout << "Time step complete for hour " << curr_hour << "\n";
	  std::cout << "Number of data points = " << point_number << "\n";
	  ofile.df_Close();
	  if(ifile.df_EOF()) break;
	  point_number = 0;
	  if(num_of_comps == 2) {
	    if(comp_number == 2) {
	      // Keep the current time step for next component
	      comp_number = 1;
	      ofname << clear << curr_hour << "_" << element_2 << "_" << fname << ".bin";
	    }
	    else if((comp_number == 1) && (curr_hour == 0)) {
	      ofname << clear << curr_hour << "_" << element_2 << "_" << fname << ".bin";
	      curr_hour += time_step;
	      comp_number = 1;
	      prev_hour = 0;
	    }
	    else {
	      // Start a new timestep series
	      if(prev_hour != 0) {
		prev_hour = curr_hour;
		curr_hour += time_step;
	      }	    
	      else {
		prev_hour = curr_hour;
	      }
	      ofname << clear << curr_hour << "_" << element_1 << "_" << fname << ".bin";
	      comp_number = 2;
	    }
	  }
	  else {
	    curr_hour += time_step;
	    ofname << clear << curr_hour << "_" << fname << ".bin";
	  }

	  ofile.df_Close();
	  std::cout << "Writing output file " << ofname.c_str() << "\n";
	  ofile.df_Create(ofname.c_str());
	  if(!ofile) {
	    std::cout << "ERROR - Cannot create BIN output file " << ofname.c_str() << "\n";
	    std::cout << ofile.df_ExceptionMessage() << "\n";
	    error_flag = 1;
	    break;
	  }
	}
      }
    }

    if(vals) { 
      delete[] vals;
      vals = 0;
    }
  }

  if(vals) { 
    delete[] vals;
    vals = 0;
  }
  ifile.df_Close();
  ofile.df_Close();

  if((comp_type == "speeddir") && (error_flag == 0)) {
    std::cout << "Converting vector MAG and DIR to speed and direction" << "\n";
    gxString datax_filename, datay_filename;
    gxString speed_filename, dir_filename;
    DiskFileB datax_fp, datay_fp, speed_fp, dir_fp;

    int files = (run_len/time_step) + 1;
    int i;
    int hour = 0;
    error_flag = 0;

    for(i = 0; i < files; i++) {
      hour = i * time_step;
      datax_filename << clear << hour << "_" << element_1 << "_" << fname << ".bin";
      datay_filename << clear << hour << "_" << element_2 << "_" << fname << ".bin";
      speed_filename << clear << hour << "_" << "speed" << "_" << fname << ".bin";
      dir_filename << clear << hour << "_" << "direction" << "_" << fname << ".bin";

      std::cout << "Opening file " << datax_filename.c_str() << "\n";
      std::cout << "Opening file " << datay_filename.c_str() << "\n";
      datax_fp.df_Open(datax_filename.c_str());
      if(datax_fp.df_GetError() != DiskFileB::df_NO_ERROR) {
	std::cout << "ERROR - Cannot open file " <<  datax_filename.c_str() << "\n";
	error_flag = 1;
	break;
      }
      datay_fp.df_Open(datay_filename.c_str());
      if(datay_fp.df_GetError() != DiskFileB::df_NO_ERROR) {
	std::cout << "ERROR - Cannot open file " <<  datay_filename.c_str() << "\n";
	error_flag = 1;
	break;
      }
      
      std::cout << "Creating file " << speed_filename.c_str() << "\n";
      speed_fp.df_Create(speed_filename.c_str());
      if(speed_fp.df_GetError() != DiskFileB::df_NO_ERROR) {
	std::cout << "ERROR - Cannot create file " <<  speed_filename.c_str() << "\n";
	error_flag = 1;
	break;
      }
      std::cout << "Creating file " << dir_filename.c_str() << "\n";
      dir_fp.df_Create(dir_filename.c_str());
      if(dir_fp.df_GetError() != DiskFileB::df_NO_ERROR) {
	std::cout << "ERROR - Cannot create file " <<  dir_filename.c_str() << "\n";
	error_flag = 1;
	break;
      }

      float datax_val, datay_val, mag, theta;
      while(!datax_fp.df_EOF() && !datay_fp.df_EOF()) {
	datax_fp.df_Read((unsigned char *)&datax_val, sizeof(float));
	if(datax_fp.df_GetError() != DiskFileB::df_NO_ERROR) {
	  std::cout << "ERROR - Cannot read from file " <<  datax_filename.c_str() << "\n";
	  error_flag = 1;
	  break;
	}
	datay_fp.df_Read((unsigned char *)&datay_val, sizeof(float));
	if(datay_fp.df_GetError() != DiskFileB::df_NO_ERROR) {
	  std::cout << "ERROR - Cannot read from file " <<  datay_filename.c_str() << "\n";
	  error_flag = 1;
	  break;
	}

	findSpeedAndDir(datax_val, datay_val, mag, theta, convert_to_knots);
	speed_fp << mag;
	if(speed_fp.df_GetError() != DiskFileB::df_NO_ERROR) {
	  std::cout << "ERROR - Cannot write to file " <<  speed_filename.c_str() << "\n";
	  error_flag = 1;
	  break;
	}
	dir_fp << theta;
	if(dir_fp.df_GetError() != DiskFileB::df_NO_ERROR) {
	  std::cout << "ERROR - Cannot write to file " <<  dir_filename.c_str() << "\n";
	  error_flag = 1;
	  break;
	}
      } 
      
      datax_fp.df_Close();
      datay_fp.df_Close();
      speed_fp.df_Close();
      dir_fp.df_Close();
      if(error_flag == 1) break;
    }
  }

  return error_flag;
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

// ----------------------------------------------------------- //
// ------------------------------- //
// --------- End of File --------- //
// ------------------------------- //

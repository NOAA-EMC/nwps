// ------------------------------- //
// -------- Start of File -------- //
// ------------------------------- //
// ----------------------------------------------------------- // 
// C++ Source Code File
// Compiler Used: GNU, Intel, Cray
// Produced By: Douglas.Gaer@noaa.gov
// File Creation Date: 01/12/2017
// Date Last Modified: 01/13/2017
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

Program used to create a BIN file from SWAN ship route output.

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
#include "gxconfig.h"

const char *version_string = "4.03";
const char *program_name = "ship_route_to_bin";
const char *program_description = "Program used convert SWAN ship route output to a Fortran BIN file";
const char *project_acro = "NWPS";
const char *produced_by = "Douglas.Gaer@noaa.gov";

// Global variables
int debug = 0;
int debug_level = 1;
int verbose = 0;
gxString process_name;
int num_command_line_args;

// Default exception values
const float default_nan = 9.999e+20;

void program_version();
void HelpMessage();
int ProcessArgs(int argc, char *argv[]);
int findSpeedAndDir(float x, float y, float &mag, float &theta, int convert_to_knots);

int main(int argc, char **argv)
{
  process_name = argv[0];

  int narg = 1;
  char *arg = argv[narg = 1];
  int argc_count = 0;
  gxList<gxString> cont_file;
  gxString fname;
  gxString ofname;

  while(narg < argc) {
    if(arg[0] != '\0') {
      if(arg[0] == '-') { // Look for command line arguments
	// Exit if argument is not valid or argument signals program to exit
	if(!ProcessArgs(argc, argv)) return 1;
      }
      else {
	// Our arguments to program 
	if(argc_count == 0) fname = arg;
	if(argc_count == 1) ofname = arg;
	argc_count++;
      }
    }
    arg = argv[++narg];
  }

  if(argc < 2) {
    std::cout << "ERROR - Need SWAN SHIPRT input and output BIN file name" << "\n";
    HelpMessage();
    return 1;
  }

  char sbuf[8192]; // Allow really long lines for all SWAN output files
  gxString info_line;
  gxString delimiter = " ";
  DiskFileB ifile, ofile;
  int error_level = 0;
  gxList<float> Hsig;
  gxList<float> TPsmoo;
  gxList<float> PkDir;
  gxList<float> XWindv;
  gxList<float> YWindv;

  std::cout << "Opening SWAN SHIPRT file " << fname.c_str() << "\n";
  ifile.df_Open(fname.c_str());
  if(!ifile) {
    std::cout << "ERROR - Cannot open SWAN SHIPRT file " 
	      << fname.c_str() << "\n";
    std::cout << ifile.df_ExceptionMessage() << "\n";
    return 1;
  }

  std::cout << "Creating output file " << ofname.c_str() << "\n";
  ofile.df_Create(ofname.c_str());
  if(!ofile) {
    std::cout << "ERROR - Cannot create BIN output file " 
	      << ofname.c_str() << "\n";

    std::cout << ofile.df_ExceptionMessage() << "\n";
    return 1;
  }

  while(!ifile.df_EOF()) {
    if(error_level > 0) break;
    ifile.df_GetLine(sbuf, sizeof(sbuf), '\n');
    if(ifile.df_GetError() != DiskFileB::df_NO_ERROR) {
      std::cout << "ERROR - A fatal I/O error reading SWAN RIP current output file" 
		<< "\n" << std::flush;
      std::cout << "ERROR - Cannot read file " <<  fname.c_str() << "\n";
      std::cout << ifile.df_ExceptionMessage() << "\n";
      error_level = 1;
      break;
    }

    info_line = sbuf;
    info_line.FilterChar('\n'); info_line.FilterChar('\r');
    info_line.TrimLeadingSpaces(); info_line.TrimTrailingSpaces();
    
    // Skip blank lines
    if(info_line.is_null()) continue;
    
    // Skip remark lines
    if(info_line[0] == '%') continue; 
    if(info_line[0] == '#') continue; 
    if(info_line[0] == ';') continue; 
    if(info_line[0] == ' ') continue; 

    // Replace multiple spaces in between values
    while(info_line.IFind("  ") != -1) info_line.ReplaceString("  ", " ");

    if(debug) std::cout << info_line.c_str() << "\n";
    unsigned num_arr = 0;
    unsigned i = 0;
    gxString *vals = ParseStrings(info_line, delimiter, num_arr);
    // Time Xp Yp Hsig TPsmoo PkDir X-Windv Y-Windv
    //   1  2  3   4     5     6     7       8
    //   0  1  2   3     4     5     6       7
    if(num_arr < 8) {
      std::cout << "ERROR - Missing values in SWAN SHIPRT file" << "\n" << std::flush;
      std::cout << "ERROR - Error parsing line: " <<  info_line.c_str() << "\n";
      error_level = 1;
      if(vals) delete vals;
      break;
    }
    float f = 0.0;

    sscanf(vals[3].c_str(), "%f", &f);
    Hsig.Add(f);

    sscanf(vals[4].c_str(), "%f", &f);
    TPsmoo.Add(f);

    sscanf(vals[5].c_str(), "%f", &f);
    PkDir.Add(f);

    sscanf(vals[6].c_str(), "%f", &f);
    XWindv.Add(f);

    sscanf(vals[7].c_str(), "%f", &f);
    YWindv.Add(f);

    delete [] vals;
    vals = 0;
  }
  ifile.df_Close();

  if(error_level != 0) {
    ofile.df_Close(); 
    return 1;
  }
  
  // Fix NAN values
  gxListNode<float> *ptr = Hsig.GetHead();
  while(ptr) {
    if(ptr->data == -9.0) ptr->data = default_nan;
    ptr = ptr->next;
  }
  ptr = TPsmoo.GetHead();
  while(ptr) {
    if(ptr->data == -9.0) ptr->data = default_nan;
    ptr = ptr->next;
  }
  ptr = PkDir.GetHead();
  while(ptr) {
    if(ptr->data == -999.0) ptr->data = default_nan;
    ptr = ptr->next;
  }

  // Do not convert wind X/Y to speed to knots, must be in M/S
  float mag, theta;
  int convert_to_knots = 0;

  gxListNode<float> *ptr_x = XWindv.GetHead();
  gxListNode<float> *ptr_y = YWindv.GetHead();

  gxList<float> wind;

  while(ptr_x && ptr_y) {
    findSpeedAndDir(ptr_x->data, ptr_y->data, mag, theta, convert_to_knots);
    wind.Add(mag);
    ptr_x = ptr_x->next;
    ptr_y = ptr_y->next;
  }

  // BIN file = HTSGW DIRPW WIND PERPW 
  //            Hsig  PkDir wind TPsmoo
  std::cout << "Writing points to ouput file " << ofname.c_str() << "\n";
  ptr = Hsig.GetHead();
  int num_points = 0;
  if(verbose) std::cout << "Writing HTSGW/Hsig points" << "\n";
  while(ptr) {
    ofile.df_Write(&ptr->data, sizeof(float)); 
    if(ofile.df_GetError() != DiskFileB::df_NO_ERROR) {
      std::cout << "ERROR - Error writing to " <<  ofname.c_str() << "\n";
      std::cout << ofile.df_ExceptionMessage() << "\n";
      error_level = 1;
      break;
    }
    num_points++;
    ptr = ptr->next;
  }
  ptr = PkDir.GetHead();
  if(verbose) std::cout << "Writing DRIPW/PkDir points" << "\n";
  while(ptr) {
    ofile.df_Write(&ptr->data, sizeof(float)); 
    if(ofile.df_GetError() != DiskFileB::df_NO_ERROR) {
      std::cout << "ERROR - Error writing to " <<  ofname.c_str() << "\n";
      std::cout << ofile.df_ExceptionMessage() << "\n";
      error_level = 1;
      break;
    }
    num_points++;
    ptr = ptr->next;
  }
  ptr = wind.GetHead();
  if(verbose) std::cout << "Writing WIND points" << "\n";
  while(ptr) {
    ofile.df_Write(&ptr->data, sizeof(float)); 
    if(ofile.df_GetError() != DiskFileB::df_NO_ERROR) {
      std::cout << "ERROR - Error writing to " <<  ofname.c_str() << "\n";
      std::cout << ofile.df_ExceptionMessage() << "\n";
      error_level = 1;
      break;
    }
    num_points++;
    ptr = ptr->next;
  }
  ptr = TPsmoo.GetHead();
  if(verbose) std::cout << "Writing  PERPW/TPsmoo points" << "\n";
  while(ptr) {
    ofile.df_Write(&ptr->data, sizeof(float));
    if(ofile.df_GetError() != DiskFileB::df_NO_ERROR) {
      std::cout << "ERROR - Error writing to " <<  ofname.c_str() << "\n";
      std::cout << ofile.df_ExceptionMessage() << "\n";
      error_level = 1;
      break;
    }
    num_points++;
    ptr = ptr->next;
  }

  if(error_level != 0) {
    std::cout << "ERROR - Error creating output bin file" << "\n" << std::flush;
  }
  else {
    std::cout << "BIN file complete, wrote, " << num_points << " points" << "\n" << std::flush;
  }
  ofile.df_Close(); 
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

  // NOTE: For output plot we need to convert m/s to knots
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
  char sw;
  num_command_line_args = 0;
  memset(sbuf, 0, sizeof(sbuf));
  
  for(i = 1; i < argc; i++ ) {
    if(*argv[i] == '-') {
      sw = *(argv[i] +1);

      switch(sw) {
	case '?':
	  program_version();
	  HelpMessage();
	  return 0; // Signal program to exit
	case 'v': case 'V': 
	  verbose = 1;
	  break;
	case 'd':
	  debug = 1;
	  break;
	case 'D':
	  debug = 1;
	  strncpy(sbuf, &argv[i][2], (sizeof(sbuf)-1));
	  debug_level = atoi(sbuf);
	  break;
	default:
	  fprintf(stderr, "ERROR - Unknown arg %s\n", argv[i]);
	  return 0;
      }
      num_command_line_args++;
    }
  }
  return 1; // All command line arguments were valid
}

void HelpMessage()
{
    program_version();
    std::cout << "Usage:" << "\n";
    std::cout << "          " << process_name << "SHIPRT points.bin" << "\n";
    std::cout << "args:" << "\n";
    std::cout << "       -v    Enable verbose output mode" << "\n";
    std::cout << "       -d    Enable debug mode" << "\n";
    std::cout << "       -D    Set debug level -D1 -D2 -D3 -D4 -D5" << "\n";
    std::cout << "Example:" << "\n";
    std::cout << "           " << process_name << " SHIPRT1.YY17.MO01.DD13.HH00 points.bin" << "\n";
    std::cout << "\n";
    std::cout << "Usage1: - Enable verbose, debug, and debug levels" << "\n";
    std::cout << "         " << process_name << " -v -d SHIPRT1.YY17.MO01.DD13.HH00 points.bin" << "\n";
    std::cout << "         " << process_name << " -v -D5 SHIPRT1.YY17.MO01.DD13.HH00 points.bin" << "\n";
    std::cout << "\n";
    std::cout << "\n";
}
// ----------------------------------------------------------- //
// ------------------------------- //
// --------- End of File --------- //
// ------------------------------- //

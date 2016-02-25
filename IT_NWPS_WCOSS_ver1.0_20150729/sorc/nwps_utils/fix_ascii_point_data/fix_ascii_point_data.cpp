// ------------------------------- //
// -------- Start of File -------- //
// ------------------------------- //
// ----------------------------------------------------------- // 
// C++ Source Code File
// Compiler Used: MSVC, GCC
// Produced By: Douglas.Gaer@noaa.gov
// File Creation Date: 05/28/2011
// Date Last Modified: 05/30/2011
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

Program used to change floating point values in ASCII point data
files.

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

// Our API include files
#include "g2_cpp_headers.h"
#include "g2_meta_file.h"
#include "g2_utils.h"

const char *version_string = "1.05";
const char *program_name = "fix_ascii_point_data";
const char *program_description = "Program used change floating point values in ASCII point data files";
const char *project_acro = "NWPS";
const char *produced_by = "Douglas.Gaer@noaa.gov";

// Global variables
int debug = 0;
int debug_level = 0;
int verbose = 0;

// Functions
void program_version();
int write_values(char *sbuf, DiskFileB *ofile, const gxString &value, const gxString &new_value);

int main(int argc, char *argv[])
{
  if(argc < 4) {
    std::cout << "ERROR - You must provide an input filename, value to change and new value" << "\n";
    program_version();
    std::cout << "Usage:" << "\n";
    std::cout << "           " << argv[0] << " filename value new_value [outfile]" << "\n";
    std::cout << "Example1:" << "\n";
    std::cout << "           " << argv[0] << " 2011012500_CG1.cur 9999 0" << "\n";
    std::cout << "Example2:" << "\n";
    std::cout << "           " << argv[0] << " 2011012500_CG1.cur 9999 0 newvals_2011012500_CG1.cur" << "\n";
      std::cout << "\n";
    return 1;
  }

  program_version();

  gxString ofname;
  gxString fname = argv[1];
  gxString value = argv[2];
  gxString new_value = argv[3];

  value.TrimLeadingSpaces(); value.TrimTrailingSpaces();
  new_value.TrimLeadingSpaces(); new_value.TrimTrailingSpaces();
  value << " ";
  new_value << " ";

  ofname << clear << "newvals_" << fname;
  if(argc >= 5) ofname << clear << argv[4]; 

  DiskFileB ifile, ofile;

  ifile.df_Open(fname.c_str());
  if(!ifile) {
    std::cout << "ERROR - Cannot open ASCII input file " << fname.c_str() << "\n";
    std::cout << ifile.df_ExceptionMessage() << "\n";
    return 1;
  }

  std::cout << "Writing output file " << ofname.c_str() << "\n";
  ofile.df_Create(ofname.c_str());
  if(!ofile) {
    std::cout << "ERROR - Cannot create output file " << ofname.c_str() << "\n";
    std::cout << ofile.df_ExceptionMessage() << "\n";
    return 1;
  }

  int error_flag = 0;
  const unsigned read_size = 1024;
  const unsigned buf_size = read_size * 2;
  char rbuf[buf_size];
  unsigned bytes_read = 0;

  while(!ifile.df_EOF()) {
    memset(rbuf, 0, buf_size);
    ifile.df_Read(rbuf, read_size);
    if(ifile.df_GetError() != DiskFileB::df_NO_ERROR) {
      if(ifile.df_GetError() == DiskFileB::df_EOF_ERROR) {
	bytes_read = ifile.df_BytesRead();
	rbuf[bytes_read] = 0;
	if(write_values(rbuf, &ofile, value, new_value) < 0) {
	  std::cout << "ERROR - Error writing to output file " <<  ofname.c_str() << "\n";
	  std::cout << ofile.df_ExceptionMessage() << "\n";
	  error_flag = 1;
	  break;
	}
	error_flag = 0;
	break;
      } 
      std::cout << "ERROR - A fatal I/O error ASCII input file" << "\n";
      std::cout << "ERROR - Cannot read file " <<  fname.c_str() << "\n";
      std::cout << ifile.df_ExceptionMessage() << "\n";
      error_flag = 1;
      break;
    }
    bytes_read = ifile.df_BytesRead();
    bytes_read--;
    while(rbuf[bytes_read] != '\n') {
      char c;
      ifile.df_Get(c);
      if(ifile.df_GetError() != DiskFileB::df_NO_ERROR) {
	if(ifile.df_GetError() == DiskFileB::df_EOF_ERROR) {
	  bytes_read = ifile.df_BytesRead();
	  rbuf[bytes_read] = 0;
	  if(write_values(rbuf, &ofile, value, new_value) < 0) {
	    std::cout << "ERROR - Error writing to output file " <<  ofname.c_str() << "\n";
	    std::cout << ofile.df_ExceptionMessage() << "\n";
	    error_flag = 1;
	    break;
	  }
	  error_flag = 0;
	  break;
	} 
	std::cout << "ERROR - A fatal I/O error ASCII input file" << "\n";
	std::cout << "ERROR - Cannot read file " <<  fname.c_str() << "\n";
	std::cout << ifile.df_ExceptionMessage() << "\n";
	error_flag = 1;
	break;
      }
      bytes_read++;
      if(bytes_read > buf_size) {
	std::cout << "ERROR - Input file is not a valid ASCII file " <<  fname.c_str() << "\n";
	error_flag = 1;
	break;
      }
      rbuf[bytes_read] = c;
      if(rbuf[bytes_read] == ' ') break;
    }

    bytes_read++;
    rbuf[bytes_read] = 0;
    if(write_values(rbuf, &ofile, value, new_value) < 0) {
      std::cout << "ERROR - Error writing to output file " <<  ofname.c_str() << "\n";
      std::cout << ofile.df_ExceptionMessage() << "\n";
      error_flag = 1;
      break;
    }
  }

  if(error_flag == 0) {
    std::cout << "Fix point values complete to " << ofname.c_str() << "\n";
  }

  ifile.df_Close();
  ofile.df_Close();

  return error_flag;
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

int write_values(char *sbuf, DiskFileB *ofile, const gxString &value, const gxString &new_value)
{
  UString info_line(8192);
  gxString delimiter = " ";
  info_line = sbuf;
  
  info_line.ReplaceChar('\n', ' ');
  info_line.ReplaceChar('\r', ' ');

  // Skip remark lines
  if(info_line[0] == '#') return 0;
  if(info_line[0] == ';') return 0;

  // Replace multiple spaces in between point values
  info_line.ReplaceString("  ", " ");
  info_line.ReplaceString("   ", " ");
  info_line.ReplaceString("    ", " ");
  info_line.ReplaceString("      ", " ");
  info_line.ReplaceString("        ", " ");

  if(info_line.is_null()) return 0;

  info_line << " ";
  info_line.ReplaceString(value, new_value);
  info_line.TrimLeadingSpaces();
  info_line.TrimTrailingSpaces();
  info_line.ReplaceChar(' ', '\n');

  if(info_line[info_line.length()-1] != '\n')  info_line << "\n";
  if(ofile->df_Write(info_line.c_str(), info_line.length()) != DiskFileB::df_NO_ERROR) {
    return -1;
  }

  return 1;
}

// ----------------------------------------------------------- //
// ------------------------------- //
// --------- End of File --------- //
// ------------------------------- //

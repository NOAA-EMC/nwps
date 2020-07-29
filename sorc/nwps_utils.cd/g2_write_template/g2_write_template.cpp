// ------------------------------- //
// -------- Start of File -------- //
// ------------------------------- //
// ----------------------------------------------------------- // 
// C++ Source Code File
// Compiler Used: MSVC, GCC
// Produced By: Douglas.Gaer@noaa.gov
// File Creation Date: 03/01/2011
// Date Last Modified: 06/03/2016
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

Program used to make a GRIB2 template file

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

// Our API include files
#include "g2_cpp_headers.h"
#include "g2_utils.h"
#include "g2_meta_file.h"

const char *version_string = "4.01";
const char *program_name = "g2_write_template";
const char *program_description = "Program used to make a GRIB2 template file";
const char *project_acro = "NWPS";
const char *produced_by = "Douglas.Gaer@noaa.gov";

// Default global settings
const char *default_outfile_name = "template.grb2";

// Global variables
int debug = 0;
int debug_level = 0;
int verbose = 0;
int num_command_line_args;
gxString process_name;
int write_sec7_withdata = 0;

// Functions
void program_version();
void HelpMessage();
int ProcessArgs(int argc, char *argv[]);

int main(int argc, char *argv[])
{
  process_name = argv[0];

  if(argc < 3) {
    std::cout << "ERROR - You must provide a template meta file and output file name" << "\n";
    HelpMessage();
    return 1;
  }

  char config_file_name[255];
  char outfile_name[255];
  FILE *outfile;
  size_t bytes;
  unsigned char *buf = 0; // File representation buffer
  __g2ULLWORD__ message_length = 0; // Total length of GRIB2 message

  // GRIB2 message
  GRIB2Message g2message;

  memset(config_file_name, 0, sizeof(config_file_name));
  memset(outfile_name, 0, sizeof(outfile_name));
  int narg = 1;
  char *arg = argv[narg = 1];
  int argc_count = 0;

  while(narg < argc) {
    if(arg[0] != '\0') {
      if(arg[0] == '-') { // Look for command line arguments
	// Exit if argument is not valid or argument signals program to exit
	if(!ProcessArgs(argc, argv)) return 1;
      }
      else {
	// Our arguments to program 
	if(argc_count == 0) strcpy(config_file_name, arg);
	if(argc_count == 1)   strcpy(outfile_name, arg);
	argc_count++;
      }
    }
    arg = argv[++narg];
  }

  if(argc_count < 2) {
    std::cout << "ERROR - You must provide a template meta file and output file name" << "\n";
    HelpMessage();
    return 1;
  }

  program_version();
    
  if(!LoadOrBuildMetaFile(config_file_name, &g2message, debug)) return 1;
    
  std::cout << "Creating new GRIB2 template file " << outfile_name << "\n";
  std::cout << "\n";
  outfile = fopen(outfile_name, "w+b");
  if(!outfile) {
    printf("ERROR - Could not create output file %s\n", outfile_name);
    return 1;
  }

  // Allocate and set templates for all sections

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
    std::cout << "Allocating " << (unsigned)num_data_points << " data points for section 7" << "\n";
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

  std::cout << "GRIB2 message length = " << (unsigned)message_length << "\n";

  // Write the messages sections to the GRIB2 file
  buf = g2message.sec0.GetFileBuf(message_length);
  bytes = fwrite(buf, 1, g2message.sec0.GetSize(), outfile);
  if(bytes != g2message.sec0.GetSize()) {
    printf("ERROR - Could not section 0 write to output file %s\n", outfile_name);
    fclose(outfile);
  }
  delete buf;

  buf = g2message.sec1.GetFileBuf();
  bytes = fwrite(buf, 1, g2message.sec1.GetSize(), outfile);
  if(bytes != g2message.sec1.GetSize()) {
    printf("ERROR - Could not section 1 write to output file %s\n", outfile_name);
    fclose(outfile);
  }
  delete buf;

  buf = g2message.sec3.GetFileBuf();
  bytes = fwrite(buf, 1, g2message.sec3.GetSize(), outfile);
  if(bytes != g2message.sec3.GetSize()) {
    printf("ERROR - Could not section 3 write to output file %s\n", outfile_name);
    fclose(outfile);
  }
  delete buf;

  buf = g2message.sec4.GetFileBuf();
  bytes = fwrite(buf, 1, g2message.sec4.GetSize(), outfile);
  if(bytes != g2message.sec4.GetSize()) {
    printf("ERROR - Could not section 4 write to output file %s\n", outfile_name);
    fclose(outfile);
  }
  delete buf;

  buf = g2message.sec5.GetFileBuf();
  bytes = fwrite(buf, 1, g2message.sec5.GetSize(), outfile);
  if(bytes != g2message.sec5.GetSize()) {
    printf("ERROR - Could not section 5 write to output file %s\n", outfile_name);
    fclose(outfile);
  }
  delete buf;

  buf = g2message.sec6.GetFileBuf();
  bytes = fwrite(buf, 1, g2message.sec6.GetSize(), outfile);
  if(bytes != g2message.sec6.GetSize()) {
    printf("ERROR - Could not section 6 write to output file %s\n", outfile_name);
    fclose(outfile);
  }
  delete buf;

  // 04/11/2016: Fix for wgrib2 #define CHECK
  buf = g2message.sec7.GetFileBuf(write_sec7_withdata);
  std::cout << "Writing " << (unsigned)g2message.sec7.GetSize(write_sec7_withdata) << " bytes section 7" << "\n";
  bytes = fwrite(buf, 1, g2message.sec7.GetSize(write_sec7_withdata), outfile);
  if(bytes != g2message.sec7.GetSize(write_sec7_withdata)) {
    printf("ERROR - Could not write section 7 header to output file %s\n", outfile_name);
    fclose(outfile);
  }
  delete buf;

  bytes = fwrite((const unsigned char *)&g2message.sec8, 1, sizeof(g2message.sec8), outfile);
  if(bytes != sizeof(g2message.sec8)) {
    printf("ERROR - Could not section 8 write to output file %s\n", outfile_name);
    fclose(outfile);
  }

  if(fclose(outfile) != 0) {
    printf("ERROR - Could not close output file %s\n", outfile_name);
    return 1;
  }
  
  return 0;
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
	case 'd': case 'D':
	  debug = 1;
	  break;
	case 'w': case 'W':
	  write_sec7_withdata = 1;
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
    std::cout << "Usage1:" << "\n";
    std::cout << "          " << process_name << " varname.meta outfile.grb2" << "\n";
    std::cout << "\n";
    std::cout << "Usage2: - Enable verbose debugging" << "\n";
    std::cout << "           " << process_name << "-v -d DEPTH.meta DEPTH_template.grib2" << "\n"; 
    std::cout << "\n";
    std::cout << "Usage3: - Write section 7 with zero-fill data" << "\n";
    std::cout << "           " << process_name << "-w DEPTH.meta DEPTH_template.grib2" << "\n"; 
    std::cout << "\n";
}
// ----------------------------------------------------------- //
// ------------------------------- //
// --------- End of File --------- //
// ------------------------------- //

// ------------------------------- //
// -------- Start of File -------- //
// ------------------------------- //
// ----------------------------------------------------------- // 
// C++ Source Code File
// Compiler Used: MSVC, GCC
// Produced By: Douglas.Gaer@noaa.gov
// File Creation Date: 03/01/2011
// Date Last Modified: 09/15/2011
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

Program used to read GRIB2 template files for testing

*/
// ----------------------------------------------------------- // 

#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include "g2_cpp_headers.h"
#include "g2_utils.h"
#include "g2_print_sec.h"

const char *version_string = "1.19";
const char *program_name = "g2_read_template";
const char *program_description = "Program used to read GRIB2 template files for testing";
const char *project_acro = "NWPS";
const char *produced_by = "Douglas.Gaer@noaa.gov";

/* Default global settings */
const char *default_input_fname = "template.grb2";

/* Global variables */
int debug = 0;
int debug_level = 0;
int verbose = 0;
char input_fname[255];

// Function declarations
void program_version();

int main(int argc, char *argv[])
{
  if(argc < 2) {
    std::cout << "ERROR - You must provide an input GRIB2 file to read" << "\n";
    program_version();
    std::cout << "Usage:" << "\n";
    std::cout << "        " << argv[0] << " infile.grb2" << "\n";
    return 1;
  }

  size_t bytes = 0;
  memset(input_fname, 0, sizeof(input_fname));
  strncpy(input_fname, argv[1], (sizeof(input_fname)-1));

  program_version();
  std::cout << "Opening GRIB2 file " << input_fname << "\n";
  std::cout << "\n";
  
  FILE *fp;
  fp = fopen(input_fname, "rb");
  if(!fp) {
    std::cout << "ERROR - Cannot open file " << input_fname << "\n";
    return 1;
  }

  g2Section0 sec0;
  bytes = fread(&sec0, 1, sizeof(sec0), fp);
  if(bytes != sizeof(sec0)) {
    std::cout << "ERROR - Error reading SEC0 from file " << input_fname << "\n";
    fclose(fp);
    return 1;
  }

  char grib_id[4] = { 'G', 'R', 'I', 'B' };
  char grib_end[4] = { '7', '7', '7', '7' };

  if(memcmp(sec0.grib_id, grib_id, 4) != 0) {
    std::cout << "ERROR- Error decoding GRIB2 file " << input_fname << "\n";
    std::cout << "ERROR - GRIB ID is not valid, this is not a GRIB file" << "\n";
    fclose(fp);
    return 1;
  }
  if((int)sec0.edition_number[0] != 2) {
    std::cout << "ERROR - Not a GRIB2 file " << input_fname << "\n";
    fclose(fp);
    return 1;
  }
  __g2ULLWORD__ message_len = 0;
  g2_reverse_byte_order((unsigned char *)sec0.message_length, 8);
  memmove(&message_len, sec0.message_length, 8);

  // Print Sec0
  g2_reverse_byte_order((unsigned char *)sec0.message_length, 8);
  PrintSec0(&sec0);

  int section_len = 0;
  char readbuf[4];
  int error_flag = 0;
  g2SectionID id;
  unsigned curr_len = message_len;
  int at_end_of_message = 0;

  while(!feof(fp)) {
    if(ftell(fp) == (curr_len - 4)) {
      bytes = fread(readbuf, 1, sizeof(readbuf), fp);
      if(bytes != sizeof(readbuf)) {
	  std::cout << "ERROR - Error end of section from " << input_fname 
		    << "\n";
	if(feof(fp)) {
	  std::cout << "ERROR - Reached end of file before 7777" << input_fname 
		    << "\n";

	}
	error_flag = 1;
	break;
      }
      if(memcmp(readbuf, grib_end, 4) == 0) {
	if(feof(fp)) {
	  // We are at the end of the GRIB2 file
	  error_flag = 0;
	  break;
	}
	bytes = fread(&sec0, 1, sizeof(sec0), fp);
	if(bytes != sizeof(sec0)) {
	  if(feof(fp)) {
	    // We are at the end of the GRIB2 file
	    error_flag = 0;
	    break;
	  }
	  else {
	  std::cout << "ERROR - Error reading SEC0 at start to new message " << input_fname 
		    << "\n";
	  error_flag = 1;
	  break;
	  }
	}

	g2_reverse_byte_order((unsigned char *)sec0.message_length, 8);
	memmove(&message_len, sec0.message_length, 8);
	curr_len += message_len;
	at_end_of_message = 1;
	// Print Sec0
	g2_reverse_byte_order((unsigned char *)sec0.message_length, 8);
	PrintSec0(&sec0);
      }
    }
    
    memset(&id, 0 , sizeof(id));
    bytes = fread(&id, 1, sizeof(id), fp);
    if(bytes != sizeof(id)) {
      if(feof(fp)) {
	if((memcmp(id.section_length, grib_end, 4) == 0) || (at_end_of_message = 1)) {
	  error_flag = 0;
	  break;
	}
	else {
	  std::cout << "ERROR - End of file before end section " << input_fname 
		    << "\n";
	  error_flag = 1;
	  break;
	}
      }

      std::cout << "ERROR - Error reading section ID from " << input_fname 
		<< "\n";
      fclose(fp);
      return 1;
    }
    at_end_of_message = 0;

    g2_reverse_byte_order((unsigned char *)id.section_length, 4);
    memmove(&section_len, id.section_length, 4);
    size_t buf_len = section_len-5;
    unsigned char *section_buf = new unsigned char[buf_len];
    memset(section_buf, 0, buf_len);
    bytes = fread(section_buf, 1, buf_len, fp);
    if(bytes != buf_len) {
      if(feof(fp)) {
	std::cout << "ERROR - End of file before end section " << input_fname 
		  << "\n";
      }
      else {
	std::cout << "ERROR - Error reading file from " << input_fname 
		  << "\n";
      }
      delete section_buf;
      error_flag = 1;
      break;
    }

    if((int)id.section[0] == 1) {
      g2Section1 sec1; g2Section1 *sec1p = &sec1;
      memcpy((unsigned char *)sec1p+5, section_buf, buf_len);
      sec1.id = id;
      g2_reverse_byte_order((unsigned char *)sec1.id.section_length, 4);
      PrintSec1(sec1p);
   }
    else if((int)id.section[0] == 2) {
      g2Section2 sec2;
      sec2.id = id;
      g2_reverse_byte_order((unsigned char *)sec2.id.section_length, 4);
      PrintSec2(&sec2);
    }
    else if((int)id.section[0] == 3) {
      g2Section3 sec3; g2Section3 *sec3p = &sec3;
      memcpy((unsigned char *)sec3p+5, section_buf, 9); 
      g2_reverse_byte_order((unsigned char *)sec3.id.section_length, 4);
      PrintSec3(sec3p);
      GridDefTemplate30 grid_template; GridDefTemplate30 *grid_templatep = &grid_template;
      int template_len = buf_len - 9;
      if(template_len > 0) {
	memcpy((unsigned char *)grid_templatep, section_buf+9, template_len);
	PrintGridDefTemplate30(grid_templatep);
      }
    }
    else if((int)id.section[0] == 4) {
      g2Section4 sec4; g2Section4 *sec4p = &sec4;
      memcpy((unsigned char *)sec4p+5, section_buf, 4); 
      sec4.id = id;
      g2_reverse_byte_order((unsigned char *)sec4.id.section_length, 4);
      PrintSec4(sec4p);
      ProductTemplate40 pt40; ProductTemplate40 *pt40p = &pt40;
      int template_len = buf_len - 4;
      if(template_len > 0) {
	memcpy((unsigned char *)pt40p, section_buf+4, buf_len);
	PrintProductTemplate40(pt40p);
      }
    }
    else if((int)id.section[0] == 5) {
      g2Section5 sec5; g2Section5 *sec5p = &sec5;
      memcpy((unsigned char *)sec5p+5, section_buf, 6); 
      sec5.id = id;
      g2_reverse_byte_order((unsigned char *)sec5.id.section_length, 4);
      PrintSec5(sec5p);
      GridTemplate50 gt50; GridTemplate50 *gt50p = &gt50;
      int template_len = buf_len - 6;
      if(template_len > 0) {
	memcpy((unsigned char *)gt50p, section_buf+6, buf_len);
	PrintGridTemplate50(gt50p);
      }
    }
    else if((int)id.section[0] == 6) {
      g2Section6 sec6; g2Section6 *sec6p = &sec6;
      memcpy((unsigned char *)sec6p+5, section_buf, 1); 
      sec6.id = id;
      g2_reverse_byte_order((unsigned char *)sec6.id.section_length, 4);
      PrintSec6(sec6p);
    }
    else if((int)id.section[0] == 7) {
      g2Section7 sec7;
      sec7.id = id;
      g2_reverse_byte_order((unsigned char *)sec7.id.section_length, 4);
      PrintSec7(&sec7);
    }
    else {
      std::cout << "ERROR - Bad section ID " << input_fname 
		<< "\n";
      error_flag = 1;
      break;
    }
    delete section_buf;
  }

  fclose(fp);
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

// ----------------------------------------------------------- //
// ------------------------------- //
// --------- End of File --------- //
// ------------------------------- //

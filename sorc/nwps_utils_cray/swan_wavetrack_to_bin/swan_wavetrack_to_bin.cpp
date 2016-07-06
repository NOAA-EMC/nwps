// ------------------------------- //
// -------- Start of File -------- //
// ------------------------------- //
// ----------------------------------------------------------- // 
// C++ Source Code File
// Compiler Used: GNU, Intel, Cray
// Produced By: Douglas.Gaer@noaa.gov
// File Creation Date: 05/09/2016
// Date Last Modified: 06/13/2016
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

Program used to convert SWAN wave tracking output to a fortan 
BIN file for use with grib2 encoding.

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

const char *version_string = "4.22";
const char *program_name = "swan_wavetrack_to_bin";
const char *program_description = "Program used convert SWAN wave tracking output to a fortan BIN file";
const char *project_acro = "NWPS";
const char *produced_by = "Douglas.Gaer@noaa.gov";

// Global variables
int debug = 0;
int debug_level = 1;
int verbose = 0;
int num_command_line_args;
gxString process_name;
gxString syscoords_file;
int has_syscoords_file = 0;

// Default exception values
const float default_nan = 9.999e+20;
float input_nan = .0;
int user_input_nan = 0;
float nan_value = default_nan;

// Default wave tracking settings
int IDLA = 1;
// IDLA=1 (NW to SE) we need to flip the grid points
// IDLA=3 (SW to NE)

int wave_type = 0;
// HSIGN = 8
// DIR = 7
// TP = 9

int time_step = 3; // Default time step
int run_len = 102; // Default run length
int preallocate = 1; // Pre allocate memory buffers

// Functions
void program_version();
void HelpMessage();
int ProcessArgs(int argc, char *argv[]);
int WriteGrib2Message2Buffer(GRIB2Message &g2message, MemoryBuffer &obuf);

struct SysCoords 
{
  SysCoords() { 
    SWLAT = 0.0;
    SWCLON = 0.0;
    NELAT = 0.0;
    NECLON = 0.0;
    SWLON = 0.0;
    NELON = 0.0;
    NSR = 0.0;
    EWR = 0.0;
    NX = 0;
    NY = 0;
    DX = 0.0;
    DY = 0.0;
    has_coords = 0; 
  }

  int has_coords;
  double SWLAT, SWCLON, NELAT, NECLON, SWLON, NELON;
  double NSR, EWR, DX, DY;
  unsigned NX, NY;
};

int GetSystemCoords(gxString fname, SysCoords &coords);
int SetGrib2Message2Coords(GRIB2Message &g2message, SysCoords &coords);

struct WaveSystem
{
  WaveSystem() {
    system_number = 0;
  }

  unsigned system_number;
  MemoryBuffer points;
  MemoryBuffer grib2_templates;
};

struct node_f
{
  node_f() { data = 0; num = 0; }
  ~node_f() { if(data) delete[] data; }
  float *data;
  unsigned num;
};

int main(int argc, char **argv)
{
  process_name = argv[0];

  if(argc < 6) {
    std::cout << "ERROR - Need SYS_${TYPE}.OUT outfile.bin partition.meta templates.grib2 and ${WAVETYPE}" << "\n";
    HelpMessage();
    return 1;
  }

  int narg = 1;
  char *arg = argv[narg = 1];
  int argc_count = 0;
  gxString fname;
  gxString ofname;
  gxString meta_fname;
  gxString tfname;
  gxString WAVETYPE;
  gxList<node_f *> list;

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
	if(argc_count == 2) meta_fname = arg;
	if(argc_count == 3) tfname = arg;
	if(argc_count == 4) WAVETYPE = arg;
	argc_count++;
      }
    }
    arg = argv[++narg];
  }

  if(argc < 5) {
    std::cout << "ERROR - Need SYS_${TYPE}.OUT outfile.bin partition.meta templates.grib2 and ${WAVETYPE}" << "\n";
    HelpMessage();
    return 1;
  }
  
  WAVETYPE.ToUpper();
  if(WAVETYPE == "HSIGN") wave_type = 8;
  if(WAVETYPE == "DIR") wave_type = 7;
  if(WAVETYPE == "TP") wave_type = 9;

  if(wave_type == 0) {
    std::cout << "ERROR - WAVETYPE must be HSIGN, DIR, or TP" << "\n";
    HelpMessage();
    return 1;
  }

  if(IDLA != 1) {
    if(IDLA != 3) {
      std::cout << "ERROR - IDLA can only be 1 or 3" << "\n";
      HelpMessage();
      return 1;
    }
  }

  if(time_step == 0) {
    std::cout << "ERROR - Our input time step cannot be 0" << "\n";
    HelpMessage();
    return 1;
  }

  if(run_len == 0) {
    std::cout << "ERROR - Our run length cannot be 0" << "\n";
    HelpMessage();
    return 1;
  }

  SysCoords coords;
  coords.has_coords = 0;
  if(has_syscoords_file) {
    // Read the system coordinates file if specified
    if(GetSystemCoords(syscoords_file, coords) != 0) return 1;
  }

  char sbuf[8192]; // Allow really long lines
  DiskFileB ifile, ofile, tfile, mfile;

  if(verbose == 1) {
    std::cout << "Verbose mode is on" << "\n";
    std::cout << "\n";
  }
  if(debug == 1) {
    std::cout << "Debug mode is on" << "\n";
    std::cout << "debug_level = " << debug_level << "\n";
    std::cout << "\n";
  }

  std::cout << "Opening SWAN output file " << fname.c_str() << "\n";
  ifile.df_Open(fname.c_str());
  if(!ifile) {
    std::cout << "ERROR - Cannot open SWAN wave tracking output file " << fname.c_str() << "\n";
    std::cout << ifile.df_ExceptionMessage() << "\n";
    return 1;
  }
  std::cout << "Writing output file " << ofname.c_str() << "\n";
  ofile.df_Create(ofname.c_str());
  if(!ofile) {
    std::cout << "ERROR - Cannot create BIN output file " << ofname.c_str() << "\n";
    std::cout << ofile.df_ExceptionMessage() << "\n";
    return 1;
  }
  
  std::cout << "Our meta data file is " << meta_fname.c_str() << "\n";
  if(!mfile.df_Exists(meta_fname.c_str())) {
    std::cout << "ERROR - Input meta data file does not exist " << meta_fname.c_str() << "\n";
    return 1;
  }

  std::cout << "Writing grib2 template file " << tfname.c_str() << "\n";
  tfile.df_Create(tfname.c_str());
  if(!tfile) {
    std::cout << "ERROR - Cannot create grib2 template file " << tfname.c_str() << "\n";
    std::cout << tfile.df_ExceptionMessage() << "\n";
    return 1;
  }

  if(IDLA == 1) {
    std::cout << "IDLA = 1 (NW to SE) we will flip the grid points" << "\n";
  }
  if(IDLA == 3) {
    std::cout << "IDLA = 3 (SW to NE)" << "\n";
  }
  if(user_input_nan == 1) {
    std::cout << "Exception values are " << input_nan << "\n";
    std::cout << "NAN value for execption value is " << nan_value << "\n";
  }

  std::cout << "Using " << time_step << " hour time step" << "\n";
  std::cout << "Using " << run_len << " hours run length" << "\n";

  if(preallocate == 1) {
    std::cout << "Pre allocating memory buffers" << "\n";
  }
  else {
    std::cout << "Not pre allocating memory buffers" << "\n";
  }

  UString info_line;
  int error_level = 0;
  int has_header = 0;
  int start_section = 0;
  int num_rows = 0;
  int num_cols = 0;
  gxString time;
  int num_systems = 0;
  int system_num = 0;
  int points = -1;
  unsigned num_data_points = 0;
  unsigned data_point_count = 0;
  gxString *vals;
  gxString delimiter = " ";
  int num_time_steps = 0;
  unsigned byte_count = 0;
  unsigned i = 0;

  ifile.df_GetLine(sbuf, sizeof(sbuf), '\n');
  if(ifile.df_GetError() != DiskFileB::df_NO_ERROR) {
    std::cout << "ERROR - A fatal I/O error reading SWAN wave tracking output file" << "\n";
    std::cout << "ERROR - Cannot read file " <<  fname.c_str() << "\n";
    std::cout << ifile.df_ExceptionMessage() << "\n";
    error_level = 1; // Signal any threads
    ifile.df_Close();
    return error_level;
  }
  info_line = sbuf;
  info_line.TrimLeadingSpaces();
  if(info_line.IFind("Number of rows") != -1) {
    info_line.DeleteAfterIncluding(" ");
    num_rows = info_line.Atoi();
  }
  else {
    std::cout << "ERROR - File missing Number of rows" << "\n";
    std::cout << "ERROR - Bad wave tracking file " <<  fname.c_str() << "\n";
    error_level = 1; // Signal any threads
    ifile.df_Close();
    return error_level;
  }
  ifile.df_GetLine(sbuf, sizeof(sbuf), '\n');
  if(ifile.df_GetError() != DiskFileB::df_NO_ERROR) {
    std::cout << "ERROR - A fatal I/O error reading SWAN wave tracking output file" << "\n";
    std::cout << "ERROR - Cannot read file " <<  fname.c_str() << "\n";
    std::cout << ifile.df_ExceptionMessage() << "\n";
    error_level = 1; // Signal any threads
    ifile.df_Close();
    return error_level;
  }
  info_line = sbuf;
  info_line.TrimLeadingSpaces();
  if(info_line.IFind("Number of cols") != -1) {
    info_line.DeleteAfterIncluding(" ");
    num_cols = info_line.Atoi();
  }
  else {
    std::cout << "ERROR - File missing Number of cols" << "\n";
    std::cout << "ERROR - Bad wave tracking file " <<  fname.c_str() << "\n";
    error_level = 1; // Signal any threads
    ifile.df_Close();
    return error_level;
  }
  
  std::cout << "Number of rows = " << num_rows  << "\n";
  std::cout << "Number of cols = " << num_cols  << "\n";
  num_data_points = num_rows * num_cols;
  std::cout << "Number data points per system = " << num_data_points << "\n";

  FAU_t pos = ifile.df_Tell();
  
  ifile.df_GetLine(sbuf, sizeof(sbuf), '\n');
  if(ifile.df_GetError() != DiskFileB::df_NO_ERROR) {
    std::cout << "ERROR - A fatal I/O error reading SWAN wave tracking output file" << "\n";
    std::cout << "ERROR - Cannot read file " <<  fname.c_str() << "\n";
    std::cout << ifile.df_ExceptionMessage() << "\n";
    error_level = 1; // Signal any threads
    ifile.df_Close();
    return error_level;
  }
  info_line = sbuf;
  info_line.TrimLeadingSpaces();
  if(info_line.IFind("Time") != -1) {
    info_line.DeleteAfterIncluding(" ");
    num_cols = info_line.Atoi();
  }
  else {
    std::cout << "ERROR - File missing Time" << "\n";
    std::cout << "ERROR - Bad wave tracking file " <<  fname.c_str() << "\n";
    error_level = 1; // Signal any threads
    ifile.df_Close();
    return error_level;
  }
  info_line.DeleteAfterIncluding(" ");
  time = info_line;
  // Time = 20160421.030000
  gxString start_year(time, 0, 4);
  gxString start_month(time, 4, 2);
  gxString start_day(time, 6, 2);
  gxString start_hour(time, 9, 2);
  gxString start_min(time, 11, 2);
  gxString start_sec(time, 13, 2);
  std::cout << "Model start time = " << start_year.c_str() << start_month.c_str() << start_day.c_str() << "." 
	    << start_hour.c_str() << start_min.c_str() << start_sec.c_str() << "\n" << std::flush;

  ifile.df_GetLine(sbuf, sizeof(sbuf), '\n');
  if(ifile.df_GetError() != DiskFileB::df_NO_ERROR) {
    std::cout << "ERROR - A fatal I/O error reading SWAN wave tracking output file" << "\n";
    std::cout << "ERROR - Cannot read file " <<  fname.c_str() << "\n";
    std::cout << ifile.df_ExceptionMessage() << "\n";
    error_level = 1; // Signal any threads
    ifile.df_Close();
    return error_level;
  }
  info_line = sbuf;
  info_line.TrimLeadingSpaces();
  if(info_line.IFind("Tot number of systems") != -1) {
    info_line.DeleteAfterIncluding(" ");
    num_cols = info_line.Atoi();
  }
  else {
    std::cout << "ERROR - File missing Tot number of systems" << "\n";
    std::cout << "ERROR - Bad wave tracking file " <<  fname.c_str() << "\n";
    error_level = 1; // Signal any threads
    ifile.df_Close();
    return error_level;
  }
  info_line.DeleteAfterIncluding(" ");
  num_systems = info_line.Atoi();
  std::cout << "Total Number of systems = " << num_systems  << "\n" << std::flush;

  WaveSystem *wave_systems = new WaveSystem[num_systems];

  if(preallocate == 1) {
    // Pre allocate out memory buffers
    unsigned point_buf_size =  (num_data_points * sizeof(float)) * ((run_len/time_step) + 1);
    unsigned g2_buf_size =  179 * ((run_len/time_step) + 1);
    if(debug) std::cout << "Pre allocating " << point_buf_size << " bytes for each system" << "\n";
    if(debug) std::cout << "Pre allocating " << g2_buf_size << " bytes for each system's grib2 template" << "\n";
    for(i = 0; i < num_systems; i++) {
      wave_systems[i].points.Alloc(point_buf_size);
      wave_systems[i].points.Clear();
      wave_systems[i].grib2_templates.Alloc(g2_buf_size);
      wave_systems[i].grib2_templates.Clear();
    }
    if(debug) std::cout << "Pre allocated " << (point_buf_size * num_systems) << " bytes for all systems" << "\n";
    if(debug) std::cout << "Pre allocated " << (g2_buf_size * num_systems) << " bytes for all grib2 templates" << "\n";
  }

  ifile.df_Seek(pos);
  while(!ifile.df_EOF()) {
    if(error_level > 0) break;
    ifile.df_GetLine(sbuf, sizeof(sbuf), '\n');
    if(ifile.df_GetError() != DiskFileB::df_NO_ERROR) {
      std::cout << "ERROR - A fatal I/O error reading SWAN wave tracking output file" << "\n" << std::flush;
      std::cout << "ERROR - Cannot read file " <<  fname.c_str() << "\n";
      std::cout << ifile.df_ExceptionMessage() << "\n";
      error_level = 1;
      break;
    }

    info_line = sbuf;
    info_line.FilterChar('\n');
    info_line.FilterChar('\r');
    info_line.TrimLeadingSpaces();
    info_line.TrimTrailingSpaces();

    if(info_line.is_null()) continue;
    
    // Skip remark lines
    if(info_line[0] == '#') continue; 
    if(info_line[0] == ';') continue; 
    
    if(has_header == 0) {
      if(info_line.IFind("Time") != -1) {
	info_line.DeleteAfterIncluding(" ");
	time = info_line;
	continue;
      }
      if(info_line.IFind("Tot number of systems") != -1) {
	info_line.DeleteAfterIncluding(" ");
	num_systems = info_line.Atoi();
      }
      if((!time.is_null()) && (num_systems > 0)) {
	has_header = 1;
      }
      else {
	std::cout << "ERROR - File missing Time and Tot number of systems" << "\n" << std::flush;
	std::cout << "ERROR - Bad wave tracking file " <<  fname.c_str() << "\n" << std::flush;
	std::cout << info_line.c_str() << "\n";
	error_level = 1;
	break;
      }
      std::cout << "Starting new wave group" << "\n" << std::flush;
      std::cout << "Time = " << time.c_str()  << "\n" << std::flush;
      if(verbose) {
	std::cout << "Total Number of systems = " << num_systems  << "\n" << std::flush;
      }
      num_time_steps++;
      start_section = 0;
      points = -1;
      continue;
    }

    if(start_section == 0) { 
      //   1                                                                      System number
      // 3345                                                                     Number of points in system
      if(info_line.IFind("System number") != -1) {
	info_line.DeleteAfterIncluding(" ");
	system_num = info_line.Atoi();
	continue;
      }
      if(info_line.IFind("Number of points in system") != -1) {
	info_line.DeleteAfterIncluding(" ");
	points = info_line.Atoi();
      }
      if((system_num > 0) && (points > -1)) {
	start_section = 1;
      }
      else {
	std::cout << "ERROR - File missing System number and Number of points in system" << "\n" << std::flush;
	std::cout << "ERROR - Bad wave tracking file " <<  fname.c_str() << "\n" << std::flush;
	std::cout << info_line.c_str() << "\n";
	error_level = 1;
	break;
      }
      std::cout << "System number " << system_num  << "\n" << std::flush;
      if(verbose) {
	std::cout << "Number of points in system = " << points  << "\n" << std::flush;
      }
      data_point_count = 0;
      continue;
    }
    
    if(start_section) {
      if((debug) && (debug_level == 5)) {
	std::cout << "Line length = " << info_line.length() << "\n";
      }
      
      // Replace multiple spaces in between point values
      while(info_line.IFind("  ") != -1) info_line.ReplaceString("  ", " ");

      unsigned num_arr = 0;
      unsigned i = 0;
      vals = ParseStrings(info_line, delimiter, num_arr);
      node_f *n = new node_f;
      n->data = new float[num_arr];
      n->num = num_arr;

      for(i = 0; i < num_arr; i++) {
	float f = 0;
	sscanf(vals[i].c_str(), "%f", &f);
	if(user_input_nan == 1) {
	  if(f == input_nan) f = nan_value;
	}
	n->data[i] = f;
	if((debug) && (debug_level == 5)) {
	  std::cout << "count: " << data_point_count << " read: " << vals[i].c_str() 
		    << " " << f << " array: " << n->data[i] << "\n" << std::flush;
	}
	data_point_count++;
      } // End data point read loop
      
      delete[] vals;
      vals = 0;
      list.Add(n);

      if(data_point_count > num_data_points) {
	std::cout << "ERROR - Expected " <<  num_data_points << " points for group " 
		  << system_num << " read " << data_point_count << "\n" << std::flush;
	error_level = 1;
	break;
      }

      if(data_point_count == num_data_points) {
	byte_count += num_data_points;
	if(debug) {
	  std::cout << "Point count = " << data_point_count << "\n" << std::flush;
	  std::cout << "Num data points = " << num_data_points << "\n" << std::flush;
	}
	gxListNode<node_f *> *ptr;
	if (IDLA == 3) {
	  ptr = list.GetHead();
	  while(ptr) {
	    wave_systems[system_num-1].points.Cat(ptr->data->data, (ptr->data->num*sizeof(float)));
	    ptr = ptr->next;
	  }
	}
	if(IDLA == 1) {
	  ptr = list.GetTail();
	  while(ptr) {
	    wave_systems[system_num-1].points.Cat(ptr->data->data, (ptr->data->num*sizeof(float)));
	    ptr = ptr->prev;
	  }
	}

	ptr = list.GetHead();
	while(ptr) {
	  delete ptr->data->data;
	  ptr->data->data = 0;
	  ptr = ptr->next;
	}
	list.ClearList();

	GRIB2Message g2message;
	if(!LoadOrBuildMetaFile(meta_fname.c_str(), &g2message, debug)) {
	  std::cout << "ERROR - Cannot load meta data template file " << meta_fname.c_str() << "\n" << std::flush;
	  break;
	}
	
	// Write our grib2 template for this system
	// Time = 20160421.030000
	gxString year(time, 0, 4);
	gxString month(time, 4, 2);
	gxString day(time, 6, 2);
	gxString hour(time, 9, 2);
	gxString min(time, 11, 2);
	gxString sec(time, 13, 2);
	if((debug) && (debug_level > 1)) {
	  std::cout << "Parsed time = " << year.c_str() << month.c_str() << day.c_str() << "." 
		    << hour.c_str() << min.c_str() << sec.c_str() << "\n" << std::flush;
	}

	// NOTE: All time will use the model start time parsed before while loop starts
	g2_set_int(start_year.Atoi(), g2message.sec1.year, sizeof(g2message.sec1.year));
	g2_set_int(start_month.Atoi(), g2message.sec1.month, sizeof(g2message.sec1.month));
	g2_set_int(start_day.Atoi(), g2message.sec1.day, sizeof(g2message.sec1.day));
	g2_set_int(start_hour.Atoi(), g2message.sec1.hour, sizeof(g2message.sec1.hour));
	g2_set_int(start_min.Atoi(), g2message.sec1.minute, sizeof(g2message.sec1.minute));
	g2_set_int(start_sec.Atoi(), g2message.sec1.second, sizeof(g2message.sec1.second));
	g2_set_int(num_data_points, g2message.sec3.num_data_points, sizeof(g2message.sec3.num_data_points));
	g2_set_int(num_data_points, g2message.sec5.num_data_points, sizeof(g2message.sec5.num_data_points));

	// Increment out forecast time
	int forecast_time = time_step * (num_time_steps -1);
	if(debug) std::cout << "Forecast time " << forecast_time << "\n";

	g2_set_int(forecast_time, g2message.templates.pt40.forecast_time, sizeof(g2message.templates.pt40.forecast_time));
	g2_set_int(system_num, g2message.templates.pt40.surface_scale_value, sizeof(g2message.templates.pt40.surface_scale_value));
	g2_set_int(wave_type, g2message.templates.pt40.parameter_number, sizeof(g2message.templates.pt40.parameter_number));

	if(coords.has_coords == 1) {
	  if(SetGrib2Message2Coords(g2message, coords) != 0) {
	    std::cout << "ERROR - Error setting system coords for GRIB2 template" << "\n" << std::flush;
	    error_level = 1;
	    break;
	  }
	}

	WriteGrib2Message2Buffer(g2message, wave_systems[system_num-1].grib2_templates);
	start_section = 0;
	points = -1;
	if(system_num == num_systems) {
	  has_header = 0;  
	  if(debug) std::cout << "Reached " << num_systems << " systems." << "\n" << std::flush;
	}
	if(debug) std::cout << "Starting new section for system number " << (system_num+1) << "\n" << std::flush;
      }
    } // End of wave group section
  } // End of while loop
  std::cout << "\n" << std::flush;
  if(error_level != 0) {
    std::cout << "ERROR - Problem encoding wave tracking file" << "\n";
    std::cout << "ERROR - Exiting with error level " << error_level << "\n";
    ifile.df_Close();
    ofile.df_Close();
    tfile.df_Close();
    delete[] wave_systems;
    return error_level;
  }

  for(i = 0; i < num_systems; i++) {
    std::cout << "Writing points for system " << (i+1) << "\n" << std::flush;
    ofile.df_Write(wave_systems[i].points.m_buf(), wave_systems[i].points.length()); 
    if(ofile.df_GetError() != DiskFileB::df_NO_ERROR) {
      std::cout << "ERROR - A fatal I/O error writing points to BIN file" << "\n" << std::flush;
      std::cout << "ERROR - Cannot write to file " <<  ofname.c_str() << "\n" << std::flush;
      std::cout << ofile.df_ExceptionMessage() << "\n" << std::flush;
      error_level = 1; // Signal any threads
      break;
    }
    std::cout << "Wrote " << wave_systems[i].points.length() << " bytes to " << ofname.c_str() << "\n" << std::flush;
    std::cout << "Writing grib2 template for system " << (i+1) << "\n" << std::flush;
    tfile.df_Write(wave_systems[i].grib2_templates.m_buf(), wave_systems[i].grib2_templates.length());
    if(tfile.df_GetError() != DiskFileB::df_NO_ERROR) {
      std::cout << "ERROR - A fatal I/O error to grib2 template file" << "\n" << std::flush;
      std::cout << "ERROR - Cannot write to file " <<  tfname.c_str() << "\n" << std::flush;
      std::cout << tfile.df_ExceptionMessage() << "\n" << std::flush;
      error_level = 1; // Signal any threads
      break;
    }
    std::cout << "Wrote " << wave_systems[i].grib2_templates.length() << " bytes to " << tfname.c_str() << "\n" << std::flush;
  }

  delete[] wave_systems;
  ifile.df_Close();
  ofile.df_Close();
  ifile.df_Close();


  if(error_level) {
    std::cout << "ERROR - " << process_name.c_str() << " process failed" << "\n";
    return error_level;
  }

  std::cout << "Reached end of wave tracking file" << "\n";
  std::cout << "Total number of time steps = " << num_time_steps << "\n";
  std::cout << "Total number of points = " << byte_count << "\n";
  std::cout << "Wrote " << (byte_count*sizeof(float)) << " bytes to " << ofname.c_str() << "\n";
  std::cout << process_name.c_str() << " process complete." << "\n";
  std::cout << "\n" << std::flush;
  return error_level;
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
	case 'p': case 'P':
	  preallocate = 0;
	  break;
	case 'c': case 'C':
	  strncpy(sbuf, &argv[i][2], (sizeof(sbuf)-1));
	  syscoords_file = sbuf;
	  has_syscoords_file = 1;
	  break;
	case 'n': case 'N':
	  strncpy(sbuf, &argv[i][2], (sizeof(sbuf)-1));
	  input_nan = atof(sbuf);
	  user_input_nan = 1;
	  break;
	case 'e': case 'E':
	  strncpy(sbuf, &argv[i][2], (sizeof(sbuf)-1));
	  nan_value = atof(sbuf);
	  break;
	case 't': case 'T':
	  strncpy(sbuf, &argv[i][2], (sizeof(sbuf)-1));
	  time_step = atoi(sbuf);
	  break;
	case 'i': case 'I':
	  strncpy(sbuf, &argv[i][2], (sizeof(sbuf)-1));
	  IDLA = atoi(sbuf);
	  break;
	case 'r': case 'R':
	  strncpy(sbuf, &argv[i][2], (sizeof(sbuf)-1));
	  run_len = atoi(sbuf);
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
    std::cout << "          " << process_name << " SYS_${TYPE}.OUT outfile.bin partition.meta templates.grib2 and ${WAVETYPE}" << "\n";
    std::cout << "args:" << "\n";
    std::cout << "       -v    Enable verbose output mode" << "\n";
    std::cout << "       -d    Enable debug mode" << "\n";
    std::cout << "       -D    Set debug level -D1 -D2 -D3 -D4 -D5" << "\n";
    std::cout << "       -i    Specifiy IDLA -i1 or -i3 (program default is 1)" << "\n";
    std::cout << "       -t    Specifiy time step -t1 -t3 -t6 (program default is 3)" << "\n";
    std::cout << "       -n    Input value to treat as nan -n9999 -n999 -n99" << "\n";
    std::cout << "       -c    Specify a SYS_COORDS.OUT file -c\"SYS_COORDS.OUT\"" << "\n";
    std::cout << "       -e    nan value -e\"9.999e+20\" (program default is 9.999e+20)"  << "\n";
    std::cout << "       -r    Specify a run length -r\"102\" (default is 102 hours)"  << "\n";
    std::cout << "       -p    Do not pre-allocate memory buffer (default is to pre-allocate)"  << "\n";
    std::cout << "\n";
    std::cout << "Example:" << "\n";
    std::cout << "           " << process_name << " SYS_DIR.OUT points.bin partition.meta templates.grib2 DIR" << "\n";
    std::cout << "\n";
    std::cout << "Usage1: - Enable verbose, debug, and debug levels" << "\n";
    std::cout << "         " << process_name << " -v -d SYS_DIR.OUT points.bin partition.meta templates.grib2 DIR" << "\n";
    std::cout << "         " << process_name << " -v -D5 SYS_DIR.OUT points.bin partition.meta templates.grib2 DIR" << "\n";
    std::cout << "\n";
    std::cout << "Usage2 - Define an input exception:" << "\n";
    std::cout << "         " << process_name << " -n\"-9999\" SYS_DIR.OUT points.bin partition.meta templates.grib2 DIR" << "\n";
    std::cout << "\n";
    std::cout << "Usage3 - Define an input exception and time step:" << "\n";
    std::cout << "         " << process_name << " -n\"-9999\" -t3 SYS_DIR.OUT points.bin partition.meta templates.grib2 DIR" << "\n";
    std::cout << "\n";
    std::cout << "Usage4 - Define an input exception, time step, and IDLA:" << "\n";
    std::cout << "         " << process_name << " -n\"-9999\" -t3 -i1 SYS_DIR.OUT points.bin partition.meta templates.grib2 DIR" << "\n";
    std::cout << "\n";
    std::cout << "\n";
}

// Append all the GRIB2 meassages to a memory buffer, return 0 if pass or 1 if fail
int WriteGrib2Message2Buffer(GRIB2Message &g2message, MemoryBuffer &obuf)
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
  obuf.Cat(buf, g2message.sec0.GetSize());
  delete buf;

  buf = g2message.sec1.GetFileBuf();
  obuf.Cat(buf, g2message.sec1.GetSize());
  delete buf;

  buf = g2message.sec3.GetFileBuf();
  obuf.Cat(buf, g2message.sec3.GetSize());
  delete buf;

  buf = g2message.sec4.GetFileBuf();
  obuf.Cat(buf, g2message.sec4.GetSize());
  delete buf;

  buf = g2message.sec5.GetFileBuf();
  obuf.Cat(buf, g2message.sec5.GetSize());
  delete buf;

  buf = g2message.sec6.GetFileBuf();
  obuf.Cat(buf, g2message.sec6.GetSize());
  delete buf;

  buf = g2message.sec7.GetFileBuf(write_sec7_withdata);
  if(debug) {
    std::cout << "Writing " << (unsigned)g2message.sec7.GetSize(write_sec7_withdata) 
	      << " bytes section 7" << "\n" << std::flush;
  }
  obuf.Cat(buf, g2message.sec7.GetSize(write_sec7_withdata));
  delete buf;

  obuf.Cat((const unsigned char *)&g2message.sec8, sizeof(g2message.sec8));

  return 0;
}

int GetSystemCoords(gxString fname, SysCoords &coords)
{
  int error_level = 0;
  DiskFileB ifile;
  char sbuf[8192];
  gxString info_line;
  unsigned nx, ny;
  float *LATS = 0;
  float *LONS = 0;
  coords.has_coords = 0;

  std::cout << "Opening SWAN SYS_COORD file " << fname.c_str() << "\n";
  ifile.df_Open(fname.c_str());
  if(!ifile) {
    std::cout << "ERROR - Cannot open SWAN SYS COORD file " << fname.c_str() << "\n";
    std::cout << ifile.df_ExceptionMessage() << "\n";
    return 1;
  }

  //    85                                                                     Number of rows
  //    51                                                                     Number of cols
  // Longitude =
  // ...
  // 
  // Latitude =
  // ...

  ifile.df_GetLine(sbuf, sizeof(sbuf), '\n');
  if(ifile.df_GetError() != DiskFileB::df_NO_ERROR) {
    std::cout << "ERROR - A fatal I/O error reading SWAN SYS COORD file" << "\n";
    std::cout << "ERROR - Cannot read file " <<  fname.c_str() << "\n";
    std::cout << ifile.df_ExceptionMessage() << "\n";
    error_level = 1;
    ifile.df_Close();
    return error_level;
  }
  info_line = sbuf;
  info_line.TrimLeadingSpaces();
  if(info_line.IFind("Number of rows") != -1) {
    info_line.DeleteAfterIncluding(" ");
    ny = info_line.Atoi();
  }
  else {
    std::cout << "ERROR - File missing Number of rows" << "\n";
    std::cout << "ERROR - Bad wave tracking file " <<  fname.c_str() << "\n";
    error_level = 1;
    ifile.df_Close();
    return error_level;
  }

  ifile.df_GetLine(sbuf, sizeof(sbuf), '\n');
  if(ifile.df_GetError() != DiskFileB::df_NO_ERROR) {
    std::cout << "ERROR - A fatal I/O error reading SWAN SYS COORD file" << "\n";
    std::cout << "ERROR - Cannot read file " <<  fname.c_str() << "\n";
    std::cout << ifile.df_ExceptionMessage() << "\n";
    error_level = 1;
    ifile.df_Close();
    return error_level;
  }
  info_line = sbuf;
  info_line.TrimLeadingSpaces();
  if(info_line.IFind("Number of cols") != -1) {
    info_line.DeleteAfterIncluding(" ");
    nx = info_line.Atoi();
  }
  else {
    std::cout << "ERROR - File missing Number of cols" << "\n";
    std::cout << "ERROR - Bad wave tracking file " <<  fname.c_str() << "\n";
    error_level = 1;
    ifile.df_Close();
    return error_level;
  }

  ifile.df_GetLine(sbuf, sizeof(sbuf), '\n');
  if(ifile.df_GetError() != DiskFileB::df_NO_ERROR) {
    std::cout << "ERROR - A fatal I/O error reading SWAN SYS COORD file" << "\n";
    std::cout << "ERROR - Cannot read file " <<  fname.c_str() << "\n";
    std::cout << ifile.df_ExceptionMessage() << "\n";
    error_level = 1;
    ifile.df_Close();
    return error_level;
  }
  info_line = sbuf;
  info_line.TrimLeadingSpaces();
  if(info_line.IFind("Longitude") == -1) {
    std::cout << "ERROR - File missing Longitude" << "\n";
    std::cout << "ERROR - Bad wave tracking file " <<  fname.c_str() << "\n";
    error_level = 1;
    ifile.df_Close();
    return error_level;
  }

  unsigned num_points = nx * ny;
  LATS = new float[num_points];
  memset(LATS, 0, num_points);
  LONS = new float[num_points];
  memset(LONS, 0, num_points);

  std::cout << "NX = " << nx << "\n";
  std::cout << "NY = " << ny << "\n";

  float *fbuf = LONS;
  int read_lons = 1;
  unsigned point_count = 0;
  gxString delimiter = " ";

  while(!ifile.df_EOF()) {
    if(error_level > 0) break;
    ifile.df_GetLine(sbuf, sizeof(sbuf), '\n');
    if(ifile.df_GetError() != DiskFileB::df_NO_ERROR) {
      std::cout << "ERROR - A fatal I/O error reading SWAN SYS COORD file" << "\n" << std::flush;
      std::cout << "ERROR - Cannot read file " <<  fname.c_str() << "\n";
      std::cout << ifile.df_ExceptionMessage() << "\n";
      error_level = 1;
      break;
    }
    info_line = sbuf;
    info_line.FilterChar('\n');
    info_line.FilterChar('\r');
    info_line.TrimLeadingSpaces();
    info_line.TrimTrailingSpaces();

    if(info_line.is_null()) continue;
    
    // Skip remark lines
    if(info_line[0] == '#') continue; 
    if(info_line[0] == ';') continue; 

    if(info_line.IFind("Latitude") != -1) { 
      float *fbuf = LATS;
      read_lons = 0;
      std::cout << "Read " << point_count << " LON points" << "\n" << std::flush; 
      point_count = 0;
      continue;
    }

    // Replace multiple spaces in between point values
    while(info_line.IFind("  ") != -1) info_line.ReplaceString("  ", " ");
    
    unsigned num_arr = 0;
    unsigned i = 0;
    gxString *vals = ParseStrings(info_line, delimiter, num_arr);
    for(i = 0; i < num_arr; i++) {
      float f = 0;
      sscanf(vals[i].c_str(), "%f", &f);
      if(read_lons) {
	LONS[point_count] = f;
      }
      else {
	LATS[point_count] = f;
      }
      point_count++;
    }
    delete[] vals;
    vals = 0;
  }
  std::cout << "Read " << point_count << " LAT points" << "\n" << std::flush; 

  double SWLAT, SWCLON, NELAT, NECLON;

  SWLAT = SWCLON = NELAT = NECLON = 0.0;

  SWCLON = LONS[0];
  NECLON = LONS[num_points-1];

  if(IDLA == 1) {
    NELAT = LATS[0];
    SWLAT = LATS[num_points-1];
  }
  if(IDLA == 3) {
    NELAT = LATS[num_points-1];
    SWLAT = LATS[0];
  }
  if((NELAT == 0.0) || (NECLON == 0.0) || (SWLAT == 0.0) || (SWCLON == 0.0)) {
    std::cout << "ERROR - Bad LAT/LON values reading COORDS" << "\n";
    delete[] LONS;
    delete[] LATS;
    return 1;
  }

  double SWLON, NELON;
  SWLON = SWCLON - 360.00;
  NELON = NECLON - 360.00;

  std::cout << "NELAT = " << NELAT << "\n";
  if(verbose == 1) {
    std::cout << "NECLON = " << NECLON << " NELON = " << NELON << "\n";
  }
  else {
    std::cout << "NELON = " << NELON << "\n";
  }
  std::cout << "SWLAT = " << SWLAT << "\n";
  if(verbose == 1) {
    std::cout << "SWCLON = " << SWCLON << " SWLON = " << SWLON << "\n";
  }
  else {
    std::cout << "SWLON = " << SWLON << "\n";
  }

  double NSR = NELAT - SWLAT;
  if(SWLAT > NELAT) NSR =  SWLAT - NELAT;
  double EWR = SWCLON - NECLON; 
  if(NECLON > SWCLON) EWR = NECLON - SWCLON;

  if(verbose) {
    std::cout << "NSR = " << NSR << "\n";
    std::cout << "EWR = " << EWR << "\n";
  }

  double dx, dy;
  dy = NSR/double(ny-1);
  dx = EWR/double(nx-1);

  std::cout << "DX = " << std::setprecision(10) << dx << "\n";
  std::cout << "DY = " << std::setprecision(10) << dy << "\n";

  delete[] LONS;
  delete[] LATS;

  // Check for errors
  if((nx == 0) || (ny == 0)) error_level = 1;
  if((SWCLON <= 0.0) || (NECLON <= 0.0)) error_level = 1;

  if(error_level == 0) {
    coords.SWLAT = SWLAT;
    coords.SWCLON = SWCLON;
    coords.NELAT = NELAT;
    coords.NECLON = NECLON;
    coords.SWLON = SWLON ;
    coords.NELON = NELON;
    coords.NSR = NSR ;
    coords.EWR = EWR;
    coords.NX = nx ;
    coords.NY = ny;
    coords.DX = dx;
    coords.DY = dy;
    coords.has_coords = 1; // Signal caller we have the system coords
  }
  else {
    coords.SWLAT = 0.0;
    coords.SWCLON = 0.0;
    coords.NELAT = 0.0;
    coords.NECLON = 0.0;
    coords.SWLON = 0.0;
    coords.NELON = 0.0;
    coords.NSR = 0.0;
    coords.EWR = 0.0;
    coords.NX = 0;
    coords.NY = 0;
    coords.DX = 0.0;
    coords.DY = 0.0;
    coords.has_coords = 0; // Signal caller we do not have the system coords
    std::cout << "ERROR - Problem calculation system coords" << "\n";
  }

  return error_level;
}

int SetGrib2Message2Coords(GRIB2Message &g2message, SysCoords &coords)
{
  if(coords.has_coords != 1) return 1;

  char *str = 0;
  int ival = 0;
  double fval;
  gxString fstr;
  gxString sbuf;
  int NX = 0;
  int NY = 0;

  // Set NX value
  ival = coords.NX;
  g2_set_int(ival, g2message.templates.gt30.nx, sizeof(g2message.templates.gt30.nx));
  NX = ival;

  // Set NY value
  ival = coords.NY;
  g2_set_int(ival, g2message.templates.gt30.ny, sizeof(g2message.templates.gt30.ny));
  NY = ival;

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

  // For domains below the equator
  const unsigned setmsb = 2147483648;
  int lat_is_neg = 0;

  // Use the input LAT/LON values to encode DX and DY
  double input_NORTHEASTLAT = 0.0;
  double input_SOUTHWESTLAT = 0.0;
  double input_NORTHEASTLON = 0.0;
  double input_SOUTHWESTLON = 0.0;

  // Set LA1 -SW LAT
  sbuf.Clear();
  sbuf.Precision(2);
  sbuf << coords.SWLAT;

  input_SOUTHWESTLAT = sbuf.Atof();
  fbuf = sbuf;
  fbuf.DeleteAfterIncluding("."); fbuf.FilterChar('-');
  
  // Domains that span the equator
  if(sbuf[0] == '-') {
    lat_is_neg = 1;
  }

  // Fix for non conus sites
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

  // Domains below the equator
  if(lat_is_neg == 1) {
    ival += setmsb;
  }

  SOUTHWESTLAT = ival;
  g2_set_int(ival, g2message.templates.gt30.la1, sizeof(g2message.templates.gt30.la1));
  lat_is_neg = 0;


  // Set LO1 - SW LON
  sbuf.Clear();
  sbuf.Precision(2);
  sbuf << coords.SWLON;

  input_SOUTHWESTLON = sbuf.Atof();
  fbuf = sbuf;
  fbuf.DeleteAfterIncluding("."); fbuf.FilterChar('-');

  // For non conus sites
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
  g2_set_int(ival, g2message.templates.gt30.lo1, sizeof(g2message.templates.gt30.lo1));
  
  // Set LA2 - NELAT
  sbuf.Clear();
  sbuf.Precision(2);
  sbuf << coords.NELAT;

  input_NORTHEASTLAT = sbuf.Atof();
  fbuf = sbuf;
  fbuf.DeleteAfterIncluding("."); fbuf.FilterChar('-');
  
  // Domains that span the equator
  if(sbuf[0] == '-') {
    lat_is_neg = 1;
  }
  
  // For non conus sites
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

  // Domains below the equator
  if(lat_is_neg == 1) {
    ival += setmsb;
  }
  
  NORTHEASTLAT = ival;
  g2_set_int(ival, g2message.templates.gt30.la2, sizeof(g2message.templates.gt30.la2));
  lat_is_neg = 0;

  // Set LO2 - NE LON
  sbuf.Clear();
  sbuf.Precision(2);
  sbuf << coords.NELON;

  input_NORTHEASTLON = sbuf.Atof();
  fbuf = sbuf;
  fbuf.DeleteAfterIncluding("."); fbuf.FilterChar('-');

  // For non conus sites
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
  g2_set_int(ival, g2message.templates.gt30.lo2, sizeof(g2message.templates.gt30.lo2));


  // Calculate and set DX value
  fstr.Clear();
  fstr.Precision(6);
  fstr << coords.DX;
  if(atof(fstr.c_str()) <= 0) {
    if(input_NORTHEASTLON > input_SOUTHWESTLON) {
      fval = (input_NORTHEASTLON - input_SOUTHWESTLON)/(NX-1);
    }
    else {
      fval = (input_SOUTHWESTLON - input_NORTHEASTLON)/(NX-1);
    }
    g2_split_float(coords.DX, i_rep, f_rep, 1000000);
    fstr.Clear();
    fstr << i_rep << ".";
    f_rep_str << clear << f_rep;
    while(f_rep_str.length() < 6) f_rep_str.InsertAt(0, "0");
    fstr << f_rep_str;
  }
  g2_fix_floating_point_values(fstr, 6);
  ival = fstr.Atoi();
  g2_set_int(ival, g2message.templates.gt30.dx, sizeof(g2message.templates.gt30.dx));

  // Calculate and set DY value
  fstr.Clear();
  fstr.Precision(6);
  fstr << coords.DY;
  if(atof(fstr.c_str()) <= 0) {
    if(input_NORTHEASTLAT > input_SOUTHWESTLAT) { 
      fval = (input_NORTHEASTLAT-input_SOUTHWESTLAT)/(NY-1);
    }
    else {
      fval = (input_SOUTHWESTLAT-input_NORTHEASTLAT)/(NY-1);
    }
    g2_split_float(coords.DY, i_rep, f_rep, 1000000);
    fstr.Clear();
    fstr << i_rep << ".";
    f_rep_str << clear << f_rep;
    while(f_rep_str.length() < 6) f_rep_str.InsertAt(0, "0");
    fstr << f_rep_str;
  }

  g2_fix_floating_point_values(fstr, 6);
  ival = fstr.Atoi();
  g2_set_int(ival, g2message.templates.gt30.dy, sizeof(g2message.templates.gt30.dy));

  return 0;
}
// ----------------------------------------------------------- //
// ------------------------------- //
// --------- End of File --------- //
// ------------------------------- //

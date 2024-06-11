// ------------------------------- //
// -------- Start of File -------- //
// ------------------------------- //
// ----------------------------------------------------------- // 
// C++ Source Code File
// Compiler Used: GNU, Intel, Cray
// Produced By: Douglas.Gaer@noaa.gov
// File Creation Date: 11/10/2016
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

Program used to convert SWAN wave runup output to a Fortran
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
#include "gxconfig.h"

// Our API include files
#include "g2_cpp_headers.h"
#include "g2_utils.h"
#include "g2_meta_file.h"

const char *version_string = "4.03";
const char *program_name = "wave_runup_to_bin";
const char *program_description = "Program used convert SWAN wave runup output to a Fortran BIN file";
const char *project_acro = "NWPS";
const char *produced_by = "Douglas.Gaer@noaa.gov";

// Global variables
int debug = 0;
int debug_level = 1;
int verbose = 0;
gxString process_name;
int num_command_line_args;
int fill_only = 0;
int use_cluster_points = 0;
gxString kml_string;
int gen_kml_template = 0;
gxString kml_template_file = "runup_points_template.kml";
gxString runup_type;

// Constants
const unsigned num_cluster_points = 9;
const float default_nan = 9.999e+20;
const float fill_value = 99.0;
const int num_runup_types = 19;

gxString runup_types[num_runup_types] = {  
  "Hs",
  "pp",
  "slope",
  "twl",
  "twl95",
  "twl05",
  "runup",
  "runup95",
  "runup05",
  "setup",
  "swash",
  "inc_swash",
  "infrag_swash",
  "dune_crest",
  "dune_toe",
  "overwash",
  "erosion",
  "owash_flag",
  "erosion_flag",
};

struct GridPoint
{
  GridPoint() {
    lat = lon = 0.0;
    x = y = grid_point_number = 0;
    data = default_nan;
  }
  
  float lat, lon;
  unsigned x, y;
  unsigned grid_point_number;
  float data;
};

struct GridCoords 
{
  GridCoords() { 
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
    num_points = 0;
  }

  int has_coords;
  double SWLAT, SWCLON, NELAT, NECLON, SWLON, NELON;
  double NSR, EWR, DX, DY;
  unsigned NX, NY;
  unsigned num_points;
};

struct RUNUP_t {
  RUNUP_t() {
    file_pos = -1;
    Hs = 0.0;
    pp = 0.0;
    slope = 0.0;
    twl = 0.0;
    twl95 = 0.0;
    twl05 = 0.0;
    runup = 0.0;
    runup95 = 0.0;
    runup05 = 0.0;
    setup = 0.0;
    swash = 0.0;
    inc_swash = 0.0;
    infrag_swash = 0.0;
    dune_crest = 0.0;
    dune_toe = 0.0;
    overwash = 0.0;
    erosion = 0.0;
    owash_flag = 0.0;
    erosion_flag = 0.0;
  }
  RUNUP_t(const RUNUP_t &ob) {
    Copy(ob);
  }
  RUNUP_t &operator=(const RUNUP_t &ob) {
    if(&ob != this) Copy(ob);
    return *this;
  }
  void Copy(const RUNUP_t &ob) {
    file_pos = ob.file_pos;
    Hs = ob.Hs;
    pp = ob.pp;
    slope = ob.slope;
    twl = ob.twl;
    twl95 = ob.twl95;
    twl05 = ob.twl05;
    runup = ob.runup;
    runup95 = ob.runup95;
    runup05 = ob.runup05;
    setup = ob.setup;
    swash = ob.swash;
    inc_swash = ob.inc_swash;
    infrag_swash = ob.infrag_swash;
    dune_crest = ob.dune_crest;
    dune_toe = ob.dune_toe;
    overwash = ob.overwash;
    erosion = ob.erosion;
    owash_flag = ob.owash_flag;
    erosion_flag = ob.erosion_flag;
  }
  
  float GetVal(const gxString type) {
    if(type == "Hs") return Hs;
    if(type == "pp") return pp;
    if(type == "slope") return slope;
    if(type == "twl") return twl;
    if(type == "twl95") return twl95;
    if(type == "twl05") return twl05;
    if(type == "runup") return runup;
    if(type == "runup95") return runup95;
    if(type == "runup05") return runup05;
    if(type == "setup") return setup;
    if(type == "swash") return swash;
    if(type == "inc_swash") return inc_swash;
    if(type == "infrag_swash") return infrag_swash;
    if(type == "dune_crest") return dune_crest;
    if(type == "dune_toe") return dune_toe;
    if(type == "overwash") return overwash;
    if(type == "erosion") return erosion;
    if(type == "owash_flag") return owash_flag;
    if(type == "erosion_flag") return erosion_flag;
    return 0.0;
  }

  int file_pos;
  float Hs;
  float pp;
  float slope;
  float twl;
  float twl95;
  float twl05;
  float runup;
  float runup95;
  float runup05;
  float setup;
  float swash;
  float inc_swash;
  float infrag_swash;
  float dune_crest;
  float dune_toe;
  float overwash;
  float erosion;
  float owash_flag;
  float erosion_flag;
};

struct RUNUP_points {
  RUNUP_points() { }
  ~RUNUP_points() {
    DATE.Clear();
    points.ClearList();
  }

  gxString DATE;
  gxList<RUNUP_t> points;
};

void program_version();
void HelpMessage();
int ProcessArgs(int argc, char *argv[]);
unsigned GetFilePostion(float Xp, float Yp, 
			GridCoords &grid_coords, GridPoint *latlon_grid);
int GetClusterPointsFilePostion(float Xp, float Yp, GridCoords &grid_coords, 
				RUNUP_t *cluster_points, RUNUP_t &runup_t);
int SetGridCoords(char *fname, GridCoords &grid_coords);
GridPoint *MakeEmptyLatLonGrid(GridCoords &grid_coords, GridPoint *latlon_grid = 0);
int SetGrib2Message2Coords(GRIB2Message &g2message, GridCoords &coords);
int WriteGrib2Message2Buffer(GRIB2Message &g2message, MemoryBuffer &obuf);

int main(int argc, char **argv)
{
  process_name = argv[0];

  if(argc < 5) {
    std::cout << "ERROR - Need SWAN_RUNUP_OUTPUT_FILE runup.meta templates.grib2 points.bin" << "\n";
    HelpMessage();
    return 1;
  }

  int narg = 1;
  char *arg = argv[narg = 1];
  int argc_count = 0;
  gxList<gxString> cont_file;
  gxString fname;
  gxString meta_fname;
  gxString ofname;
  gxString tfname;

  while(narg < argc) {
    if(arg[0] != '\0') {
      if(arg[0] == '-') { // Look for command line arguments
	// Exit if argument is not valid or argument signals program to exit
	if(!ProcessArgs(argc, argv)) return 1;
      }
      else {
	// Our arguments to program 
	if(argc_count == 0) fname = arg;
	if(argc_count == 1) runup_type = arg;
	if(argc_count == 2) meta_fname = arg;
	if(argc_count == 3) tfname = arg;
	if(argc_count == 4) ofname = arg;
	argc_count++;
      }
    }
    arg = argv[++narg];
  }

  if(argc < 5) {
    std::cout << "ERROR - Need SWAN_RUNUP_OUTPUT_FILE runup_type runup_type.meta templates.grib2 points.bin" << "\n";
    HelpMessage();
    return 1;
  }

  int has_runup_type = 0;
  for(int t = 0; t < num_runup_types; t++) {
    if(runup_type == runup_types[t].c_str()) {
      has_runup_type = 1;
      break;
    }
  }

  if(!has_runup_type) {
    std::cout << "ERROR - Bad runup type specified" << "\n";
    HelpMessage();
    return 1;
  }  

  char sbuf[8192]; // Allow really long lines for all SWAN output files
  gxString info_line;
  gxString delimiter = " ";
  DiskFileB ifile, ofile, tfile;
  int error_level = 0;
  GridCoords grid_coords;
  gxListNode<RUNUP_points *> *points_ptr, *points_ptr_next;
  int num_time_steps = 0;

  if(SetGridCoords(meta_fname.c_str(), grid_coords) != 0) return 1;

  std::cout << "Opening SWAN wave RUNUP file " << fname.c_str() << "\n";
  ifile.df_Open(fname.c_str());
  if(!ifile) {
    std::cout << "ERROR - Cannot open SWAN wave RUNUP file " 
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

  std::cout << "Creating grib2 template file " << tfname.c_str() << "\n";
  tfile.df_Create(tfname.c_str());
  if(!tfile) {
    std::cout << "ERROR - Cannot create grib2 template file " 
	      << tfname.c_str() << "\n";
    std::cout << tfile.df_ExceptionMessage() << "\n";
    return 1;
  }

  while(!ifile.df_EOF()) {
    if(error_level > 0) break;
    ifile.df_GetLine(sbuf, sizeof(sbuf), '\n');
    if(ifile.df_GetError() != DiskFileB::df_NO_ERROR) {
      std::cout << "ERROR - A fatal I/O error reading SWAN wave RUNUP output file" 
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

    // Replace multiple spaces in between values
    while(info_line.IFind("  ") != -1) info_line.ReplaceString("  ", " ");

    cont_file.Add(info_line);
  }
  ifile.df_Close();

  if(error_level != 0) {
    ofile.df_Close(); 
    tfile.df_Close();
    return 1;
  }
  
  GridPoint *latlon_grid = MakeEmptyLatLonGrid(grid_coords);
  if(!latlon_grid) {
    std::cout << "ERROR - Error making empty LAT/LON grid" << "\n";
    ofile.df_Close(); 
    tfile.df_Close();
    return 1;
  }

  gxListNode<gxString> *ptr = cont_file.GetHead();
  gxList<RUNUP_points *> runup_points_list;
  gxListNode<RUNUP_t> *grid_points;

  int run_len_count = 0;
  while(ptr) {
    unsigned num_arr = 0;
    unsigned i = 0;
    gxString *vals = ParseStrings(ptr->data, delimiter, num_arr);
    // %DATE
    // Xp [m]
    // Yp [m] 
    // Hs [m]
    // pp [s]
    // slope
    // twl [m]
    // twl95 [m]
    // twl05 [m]
    // runup [m]
    // runup95 [m]
    // runup05 [m]
    // setup [m]
    // swash [m]
    // inc_swash [m]
    // infrag_swash [m]
    // dune_crest [m]
    // dune_toe [m]
    // overwash [m]
    // erosion [m] 
    // owash_flag [-]
    // erosion_flag [-]

    if(num_arr < 22) {
      std::cout << "ERROR - Missing data from SWAN wave RUNUP file" << "\n" << std::flush;
      std::cout << "ERROR - Error parsing line: " <<  ptr->data.c_str() << "\n";
      error_level = 1;
      if(vals) { delete vals; vals = 0; }
      break;
    }

    gxString DATE = vals[0];
    float Xp = 0.0;
    float Yp = 0.0;

    RUNUP_t runup_t;

    sscanf(vals[1].c_str(), "%f", &Xp);
    sscanf(vals[2].c_str(), "%f", &Yp);
    sscanf(vals[3].c_str(), "%f", &runup_t.Hs);
    sscanf(vals[4].c_str(), "%f", &runup_t.pp);
    sscanf(vals[5].c_str(), "%f", &runup_t.slope);
    sscanf(vals[6].c_str(), "%f", &runup_t.twl);
    sscanf(vals[7].c_str(), "%f", &runup_t.twl95);
    sscanf(vals[8].c_str(), "%f", &runup_t.twl05);
    sscanf(vals[9].c_str(), "%f", &runup_t.runup);
    sscanf(vals[10].c_str(), "%f", &runup_t.runup95);
    sscanf(vals[11].c_str(), "%f", &runup_t.runup05);
    sscanf(vals[12].c_str(), "%f", &runup_t.setup);
    sscanf(vals[13].c_str(), "%f", &runup_t.swash);
    sscanf(vals[14].c_str(), "%f", &runup_t.inc_swash);
    sscanf(vals[15].c_str(), "%f", &runup_t.infrag_swash);
    sscanf(vals[16].c_str(), "%f", &runup_t.dune_crest);
    sscanf(vals[17].c_str(), "%f", &runup_t.dune_toe);
    sscanf(vals[18].c_str(), "%f", &runup_t.overwash);
    sscanf(vals[19].c_str(), "%f", &runup_t.erosion);
    sscanf(vals[20].c_str(), "%f", &runup_t.owash_flag);
    sscanf(vals[21].c_str(), "%f", &runup_t.erosion_flag);
    delete [] vals;
    vals = 0;

    if(debug) {
      std::cout << DATE.c_str() << " " << std::setprecision(7) << Xp
		<< " " << std::setprecision(6) << Yp << " "
		<< runup_t.GetVal(runup_type) << "\n";
    }

    unsigned file_pos = GetFilePostion(Xp, Yp, grid_coords, latlon_grid);
    if(file_pos >= grid_coords.num_points) {
      std::cout << "ERROR - Bad X/Y point " << file_pos << " is past the end of grid zero offset " << (grid_coords.num_points-1) << "\n";
      error_level = 1;
      break;
    }

    runup_t.file_pos = (int)file_pos;

    RUNUP_t cluster_points[num_cluster_points];
    // cluster_points[0] = (i-1,j+1)    
    // cluster_points[1] = (i,j+1)
    // cluster_points[2] = (i+1,j+1)
    // cluster_points[3] = (i-1,j)
    // cluster_points[4] = (i,j)
    // cluster_points[5] = (i+1,j)
    // cluster_points[6] = (i-1,j-1)
    // cluster_points[7] = (i,j-1)
    // cluster_points[8] = (i+1,j-1)
    if(GetClusterPointsFilePostion(Xp, Yp, grid_coords, cluster_points, runup_t) != 0) {
      std::cout << "ERROR - Bad cluster center point, Runup LAT/LON grid point is outside of CG grid" 
		<< "\n";
      error_level = 1;
      break;
    }

    points_ptr = runup_points_list.GetHead();
    while(points_ptr) {
      if(points_ptr->data->DATE == DATE) break;
      points_ptr = points_ptr->next;
    }

    if(!points_ptr) {
      RUNUP_points *runup_point = new RUNUP_points; 
      runup_point->DATE = DATE;

      if(use_cluster_points) {
	for(int ncp = 0; ncp < num_cluster_points; ncp++) {
	  runup_point->points.Add(cluster_points[ncp]);
	}
      }
      else {
	runup_point->points.Add(runup_t);
      }
      runup_points_list.Add(runup_point);
      num_time_steps++;
    }
    else {
      if(use_cluster_points) {
	for(int ncp = 0; ncp < num_cluster_points; ncp++) {
	  points_ptr->data->points.Add(cluster_points[ncp]);
	}
      }
      else {
	points_ptr->data->points.Add(runup_t);
      }
    }

    ptr = ptr->next;
  }

  points_ptr_next = 0;
  points_ptr = runup_points_list.GetHead();
  if(points_ptr) points_ptr_next = points_ptr->next;
  
  if(error_level != 0 || !points_ptr || !points_ptr_next) {
    ofile.df_Close();
    tfile.df_Close();
    points_ptr = runup_points_list.GetHead();
    while(points_ptr) {
      delete points_ptr->data;
      points_ptr->data = 0;
      points_ptr = points_ptr->next;
    }
    runup_points_list.ClearList();
    delete[] latlon_grid;
    std::cout << "ERROR - Encoding error, exiting program" << "\n";
    return 1;
  }
  
  gxString starting_hour(points_ptr->data->DATE, 9, 2);
  gxString next_hour(points_ptr_next->data->DATE, 9, 2);
  int fhour = starting_hour.Atoi();
  int next_fhour = next_hour.Atoi();
  int time_step = next_fhour - fhour;
  if (time_step < 0) {
	   time_step += 24;
  } 

  std::cout << "Number of time steps = " << num_time_steps << "\n";
  std::cout << "Time step = " << time_step << "\n";
  std::cout << "Number of forecast hours = " << num_time_steps << "\n";

  int num_points_per_grid = 0;
  grid_points = points_ptr->data->points.GetHead();
  while(grid_points) {
    num_points_per_grid++;
    grid_points = grid_points->next;
  }
  std::cout << "Number of LAT/LON points per grid = " << num_points_per_grid << "\n";

  gxString start_year(points_ptr->data->DATE, 0, 4);
  gxString start_month(points_ptr->data->DATE, 4, 2);
  gxString start_day(points_ptr->data->DATE, 6, 2);
  gxString start_hour(points_ptr->data->DATE, 9, 2);
  gxString start_min(points_ptr->data->DATE, 11, 2);
  gxString start_sec = "00";
  MemoryBuffer g2_templates;

  int num_hours = 0;
  unsigned bytes_moved = 0;

  while(points_ptr) {
    GRIB2Message g2message;
    if(!LoadOrBuildMetaFile(meta_fname.c_str(), &g2message, debug)) {
      std::cout << "ERROR - Error loading meta data template file " << meta_fname.c_str() << "\n" << std::flush;
      error_level = 1;
      break;
    }

    g2_set_int(start_year.Atoi(), g2message.sec1.year, sizeof(g2message.sec1.year));
    g2_set_int(start_month.Atoi(), g2message.sec1.month, sizeof(g2message.sec1.month));
    g2_set_int(start_day.Atoi(), g2message.sec1.day, sizeof(g2message.sec1.day));
    g2_set_int(start_hour.Atoi(), g2message.sec1.hour, sizeof(g2message.sec1.hour));
    g2_set_int(start_min.Atoi(), g2message.sec1.minute, sizeof(g2message.sec1.minute));
    g2_set_int(start_sec.Atoi(), g2message.sec1.second, sizeof(g2message.sec1.second));
    g2_set_int(grid_coords.num_points, g2message.sec3.num_data_points, sizeof(g2message.sec3.num_data_points));
    g2_set_int(grid_coords.num_points, g2message.sec5.num_data_points, sizeof(g2message.sec5.num_data_points));
   
    // Increment out forecast time
    int forecast_time = time_step * num_hours;
    num_hours++;
    int type_of_data = 0;
    if(debug) std::cout << "hour = " << num_hours << " forcast time = " << forecast_time << "\n"; 

    if(forecast_time == 0) {
      type_of_data = 0; // Analysis Products
      g2_set_int(type_of_data, g2message.sec1.type_of_data, sizeof(g2message.sec1.type_of_data));
    }
    else {
      type_of_data = 1; // Forecast Products
      g2_set_int(type_of_data, g2message.sec1.type_of_data, sizeof(g2message.sec1.type_of_data));
    }
    g2_set_int(forecast_time, g2message.templates.pt40.forecast_time, sizeof(g2message.templates.pt40.forecast_time));

    if(SetGrib2Message2Coords(g2message, grid_coords) != 0) {
      std::cout << "ERROR - Error setting system coords for GRIB2 template" << "\n" << std::flush;
      error_level = 1;
      break;
    }
    
    WriteGrib2Message2Buffer(g2message, g2_templates);

    // Clear the LAT/LON grid and write the data points
    MakeEmptyLatLonGrid(grid_coords, latlon_grid); 
    grid_points = points_ptr->data->points.GetHead();

    while(grid_points) {
      latlon_grid[grid_points->data.file_pos].data = grid_points->data.GetVal(runup_type);

      // Creating template to verify all grib points in the file
      if(fill_only) latlon_grid[grid_points->data.file_pos].data = fill_value;

      if(debug) {
	gxString year(points_ptr->data->DATE, 0, 4);
	gxString month(points_ptr->data->DATE, 4, 2);
	gxString day(points_ptr->data->DATE, 6, 2);
	gxString hour(points_ptr->data->DATE, 9, 2);
	gxString min(points_ptr->data->DATE, 11, 2);
	std::cout << "Runup points = " << year.c_str() << month.c_str() << day.c_str() 
		  << "." << hour.c_str() << min.c_str() << " "
		  << std::setprecision(7) << latlon_grid[grid_points->data.file_pos].lon 
		  << " " << std::setprecision(7) << latlon_grid[grid_points->data.file_pos].lat 
		  << " " << std::setprecision(6) << latlon_grid[grid_points->data.file_pos].data 
		  << " X/Y = " << latlon_grid[grid_points->data.file_pos].x 
		  << "/" << latlon_grid[grid_points->data.file_pos].y 
		  << " file address = " << grid_points->data.file_pos << "\n";
      }

      if(num_hours == 1 && gen_kml_template) { 
	kml_string << "     <Placemark>\n";
	kml_string << "      <Point>\n";
	kml_string.Precision(7);
	kml_string << "        <coordinates>" 
		   << (latlon_grid[grid_points->data.file_pos].lon - 360.00)
		   << ",";
 	kml_string.Precision(7);
	kml_string << latlon_grid[grid_points->data.file_pos].lat
		   << ",0</coordinates>\n";
	kml_string << "      </Point>\n";
	kml_string << "     </Placemark>\n";
      }

      grid_points = grid_points->next;
    }

    unsigned i, sizeof_parray;
    sizeof_parray = grid_coords.num_points * sizeof(float);

    float *parray = new float[sizeof_parray];
    memset(parray, 0, sizeof_parray);
    for(i = 0; i < grid_coords.num_points; i++) {
      parray[i] = latlon_grid[i].data;
    }
    ofile.df_Write(parray, sizeof_parray); 
    delete [] parray;
    if(ofile.df_GetError() != DiskFileB::df_NO_ERROR) {
      std::cout << "ERROR - A fatal I/O error writing points to BIN file" << "\n" << std::flush;
      std::cout << "ERROR - Cannot write to file " <<  ofname.c_str() << "\n" << std::flush;
      std::cout << ofile.df_ExceptionMessage() << "\n" << std::flush;
      error_level = 1;
      break;
    }
    if(debug) std::cout << "Writing " << sizeof_parray << " bytes to " << ofname.c_str() << "\n" << std::flush;
    bytes_moved +=  sizeof_parray;

    if(num_time_steps == num_hours) num_hours == 0;
    points_ptr = points_ptr->next;
  }

  if(debug) {
    std::cout << "Wrote " << bytes_moved << " bytes to " << ofname.c_str() << "\n" << std::flush;
    std::cout << "Expected " << (sizeof(float) * (grid_coords.num_points * num_time_steps)) << "\n" << std::flush;
  }

  if(error_level == 0) {
    tfile.df_Write(g2_templates.m_buf(), g2_templates.length());
    if(tfile.df_GetError() != DiskFileB::df_NO_ERROR) {
      std::cout << "ERROR - A fatal I/O error to grib2 template file" << "\n" << std::flush;
      std::cout << "ERROR - Error write to file " <<  tfname.c_str() << "\n" << std::flush;
      std::cout << tfile.df_ExceptionMessage() << "\n" << std::flush;
      error_level = 1;
    }
    if(debug) std::cout << "Wrote " << g2_templates.length() << " bytes to " << tfname.c_str() << "\n" << std::flush;
  }

  points_ptr = runup_points_list.GetHead();
  while(points_ptr) {
    delete points_ptr->data;
    points_ptr->data = 0;
    points_ptr = points_ptr->next;
  }
  tfile.df_Close();
  ofile.df_Close();
  runup_points_list.ClearList();
  delete[] latlon_grid;

  if(error_level != 0) { 
    std::cout << "ERROR - No usable grib2 output produced, exiting program with errors" << "\n"; 
  }
  else {
    std::cout << "INFO - Generated grib2 output files" << "\n"; 
    std::cout << "INFO: To endocde run the following command: " << "\n";
    std::cout << "INFO: ${WGRIB2} " << tfname.c_str() << " -no_header -import_bin " << ofname.c_str() << " -grib_out final_runup.grib2" << "\n";
  }

  if(gen_kml_template && error_level == 0) {
    kml_string << "\n";
    kml_string << "  </Folder>\n";
    kml_string << "</kml>\n";
    DiskFileB kfile;
    std::cout << "Creating KML template file " << kml_template_file.c_str() << "\n";
    kfile.df_Create(kml_template_file.c_str());
    if(kfile) {
      kfile.df_Write(kml_string.c_str(), kml_string.length()); 
      kfile.df_Close();
    }
    else {
      std::cout << "ERROR - Cannot create KML template file " 
		<< kml_template_file.c_str() << "\n";
      std::cout << kfile.df_ExceptionMessage() << "\n";
      error_level = 1;
    }
  }

  return error_level;
}

GridPoint *MakeEmptyLatLonGrid(GridCoords &grid_coords, GridPoint *latlon_grid) 
{
  if(!grid_coords.has_coords) return 0;

  if(!latlon_grid) {
    latlon_grid = new GridPoint[grid_coords.num_points];
  }

  unsigned x = 0;
  unsigned y = 0;
  unsigned i = 0;
  unsigned curr_point_number = 0;
  float lat = grid_coords.SWLAT;
  float lon = grid_coords.SWCLON;

  // GRIB2 scanning mode 64
  for(y = 0; y < grid_coords.NY; y++) {
    for(x = 0; x < grid_coords.NX; x++) {
      latlon_grid[curr_point_number].lat = lat;
      latlon_grid[curr_point_number].lon = lon;
      latlon_grid[curr_point_number].x = x;
      latlon_grid[curr_point_number].y = y;
      latlon_grid[curr_point_number].grid_point_number = curr_point_number;
      latlon_grid[curr_point_number].data = default_nan;
      lon += grid_coords.DX;
      curr_point_number++;
    }
    lat += grid_coords.DY;
    lon = grid_coords.SWCLON;
  }

  return latlon_grid;
}

int SetGridCoords(char *fname, GridCoords &grid_coords)
{
  int error_level = 0;
  gxConfig CfgData;
  char *str = 0;

  grid_coords.has_coords = 1; 

  if(debug) std::cout << "Loading meta file " << fname << "\n";

  if(!CfgData.Load(fname)) {
    std::cout << "ERROR - Error Loading meta file " << fname << "\n";
    return 1;
  }

  str = CfgData.GetStrValue("nx");
  if(!str) {
    std::cout << "ERROR: nx parameter missing from meta file" << "\n";
    error_level = 1;
  }
  else {
    grid_coords.NX = atoi(str);
  }

  str = CfgData.GetStrValue("ny");
  if(!str) {
    std::cout << "ERROR: ny parameter missing from meta file" << "\n";
    error_level = 1;
  }
  else {
    grid_coords.NY = atoi(str);
  }

  str = CfgData.GetStrValue("la1");
  if(!str) {
    std::cout << "ERROR: la1 parameter missing from meta file" << "\n";
    error_level = 1;
  }
  else {
    grid_coords.SWLAT = atof(str);
  }

  str = CfgData.GetStrValue("lo1");
  if(!str) {
    std::cout << "ERROR: lo1 parameter missing from meta file" << "\n";
    error_level = 1;
  }
  else {
    grid_coords.SWLON = atof(str);
  }

  str = CfgData.GetStrValue("la2");
  if(!str) {
    std::cout << "ERROR: la2 parameter missing from meta file" << "\n";
    error_level = 1;
  }
  else {
    grid_coords.NELAT = atof(str);
  }

  str = CfgData.GetStrValue("lo2");
  if(!str) {
    std::cout << "ERROR: lo2 parameter missing from meta file" << "\n";
    error_level = 1;
  }
  else {
    grid_coords.NELON = atof(str);
  }

  if(error_level != 0) return error_level;

  grid_coords.SWCLON = 360 - grid_coords.SWLON;
  if(grid_coords.SWLON < 0.0)  grid_coords.SWCLON = 360 + grid_coords.SWLON;
  grid_coords.NECLON = 360 - grid_coords.NELON;
  if(grid_coords.NELON < 0.0) grid_coords.NECLON = 360 + grid_coords.NELON;

  grid_coords.NSR = grid_coords.NELAT - grid_coords.SWLAT;
  if(grid_coords.SWLAT > grid_coords.NELAT) grid_coords.NSR =  grid_coords.SWLAT - grid_coords.NELAT;
  grid_coords.EWR = grid_coords.SWCLON - grid_coords.NECLON; 
  if(grid_coords.NECLON > grid_coords.SWCLON) grid_coords.EWR = grid_coords.NECLON - grid_coords.SWCLON;

  grid_coords.DY = grid_coords.NSR/double(grid_coords.NY-1);
  grid_coords.DX = grid_coords.EWR/double(grid_coords.NX-1);
  grid_coords.num_points = grid_coords.NX * grid_coords.NY;

  std::cout << "CG coords set using meta data" << "\n";
  std::cout << "NELAT = " << std::setprecision(6) << grid_coords.NELAT << "\n";
  std::cout << "NECLON = " << std::setprecision(7) << grid_coords.NECLON << " NELON = " << grid_coords.NELON << "\n";
  std::cout << "SWLAT = " << std::setprecision(6) << grid_coords.SWLAT << "\n";
  std::cout << "SWCLON = " << std::setprecision(7) << grid_coords.SWCLON << " SWLON = " << grid_coords.SWLON << "\n";
  std::cout << "NX = " << grid_coords.NX << "\n";
  std::cout << "NY = " << grid_coords.NY << "\n";
  std::cout << "POINTS = " << grid_coords.num_points << "\n";
  std::cout << "NSR = " << std::setprecision(3) << grid_coords.NSR << "\n";
  std::cout << "EWR = " << std::setprecision(3) << grid_coords.EWR << "\n";
  std::cout << "DX = " << std::setprecision(10) << grid_coords.DX << "\n";
  std::cout << "DY = " << std::setprecision(10) << grid_coords.DY << "\n";
  grid_coords.has_coords = 1; 

  if(gen_kml_template) {
    kml_string.Clear();
    kml_string << "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
    kml_string << "<kml xmlns=\"http://www.opengis.net/kml/2.2\">\n";
    kml_string << "  <Folder>\n";
    kml_string << "    <name>SITEID CGNUM RUNUP Points</name>\n";
    kml_string << "    <description>SITEID CGNUM RUNUP Points</description>\n";
    kml_string << "    <GroundOverlay>\n";
    kml_string << "      <name>SITEID CGNUM RUNUP Points</name>\n";
    kml_string << "      <description>CGNUM</description>\n";
    kml_string << "      <LatLonBox>\n";
    kml_string.Precision(2);
    kml_string << "        <north>" << grid_coords.NELAT << "</north>\n";
    kml_string << "        <south>" << grid_coords.SWLAT << "</south>\n";
    kml_string << "        <east>" << grid_coords.NELON << "</east>\n";
    kml_string << "        <west>" << grid_coords.SWLON << "</west>\n";
    kml_string << "        <rotation>-0</rotation>\n";
    kml_string << "      </LatLonBox>\n";
    kml_string << "    </GroundOverlay>\n";
    kml_string << "\n";
  }

  return error_level;
}

int GetClusterPointsFilePostion(float Xp, float Yp, GridCoords &grid_coords, 
				RUNUP_t *cluster_points, RUNUP_t &runup_t)
{
  unsigned gridsize = grid_coords.NX * grid_coords.NY;
  float DXp = Xp - grid_coords.SWCLON;
  float DYp = Yp - grid_coords.SWLAT;
  int CartX = roundf(DXp/grid_coords.DX);
  int CartY = roundf(DYp/grid_coords.DY);
  int error_level = 0;
  int i, j, cur_point;
  
  int center_point = (CartY * grid_coords.NX) + CartX;

  // cluster_points[0] = (i-1,j+1)    
  i = CartX; j = CartY;
  if(i <= 0) i = 1;
  cur_point = ((j+1) * grid_coords.NX) + (i -1);
  if(cur_point >= gridsize) cur_point = center_point;
  if(cur_point < 0) cur_point = center_point;
  cluster_points[0].Copy(runup_t);
  cluster_points[0].file_pos = cur_point; 

  // cluster_points[1] = (i,j+1)
  i = CartX; j = CartY;
  cur_point = ((j+1) * grid_coords.NX) + i;
  if(cur_point >= gridsize) cur_point = center_point;
  if(cur_point < 0) cur_point = center_point;
  cluster_points[1].Copy(runup_t);
  cluster_points[1].file_pos = cur_point;

  // cluster_points[2] = (i+1,j+1)
  i = CartX; j = CartY;
  cur_point = ((j+1) * grid_coords.NX) + (i+1);
  if(cur_point >= gridsize) cur_point = center_point;
  if(cur_point < 0) cur_point = center_point;
  cluster_points[2].Copy(runup_t);
  cluster_points[2].file_pos = cur_point;

  // cluster_points[3] = (i-1,j)
  i = CartX; j = CartY;
  if(i <= 0) i = 1;
  cur_point = (j * grid_coords.NX) + (i-1);
  if(cur_point >= gridsize) cur_point = center_point;
  if(cur_point < 0) cur_point = center_point;
  cluster_points[3].Copy(runup_t);
  cluster_points[3].file_pos = cur_point;

  // cluster_points[4] = (i,j)
  i = CartX; j = CartY;
  cur_point = (j * grid_coords.NX) + i;
  if(cur_point >= gridsize) { cur_point = gridsize-1; error_level = 1; }
  if(cur_point < 0) { cur_point = 0; error_level = 1; }
  cluster_points[4].Copy(runup_t);
  cluster_points[4].file_pos = cur_point;

  // cluster_points[5] = (i+1,j)
  i = CartX; j = CartY;
  cur_point = (j * grid_coords.NX) + (i+1);
  if(cur_point >= gridsize) cur_point = center_point;
  if(cur_point < 0) cur_point = center_point;
  cluster_points[5].Copy(runup_t);
  cluster_points[5].file_pos = cur_point;

  // cluster_points[6] = (i-1,j-1)
  i = CartX; j = CartY;
  if(i <= 0) i = 1;
  if(j <= 0) j = 1;
  cur_point = ((j-1) * grid_coords.NX) + (i-1);
  if(cur_point >= gridsize) cur_point = center_point;
  if(cur_point < 0) cur_point = center_point;
  cluster_points[6].Copy(runup_t);
  cluster_points[6].file_pos = cur_point;

  // cluster_points[7] = (i,j-1)
  i = CartX; j = CartY;
  if(j <= 0) j = 1;
  cur_point = ((j-1) * grid_coords.NX) + i;
  if(cur_point >= gridsize) cur_point = center_point;
  if(cur_point < 0) cur_point = center_point;
  cluster_points[7].Copy(runup_t);
  cluster_points[7].file_pos = cur_point;

  // cluster_points[8] = (i+1,j-1)
  i = CartX; j = CartY;
  if(j <= 0) j = 1;
  cur_point = ((j-1) * grid_coords.NX) + (i+1);
  if(cur_point >= gridsize) cur_point = center_point;
  if(cur_point < 0) cur_point = center_point;
  cluster_points[8].Copy(runup_t);
  cluster_points[8].file_pos = cur_point;

  return error_level;
}

unsigned GetFilePostion(float Xp, float Yp, 
			GridCoords &grid_coords, GridPoint *latlon_grid)
{
  unsigned gridsize = grid_coords.NX * grid_coords.NY;
  float DXp = Xp - grid_coords.SWCLON;
  float DYp = Yp - grid_coords.SWLAT;
  unsigned CartX = roundf(DXp/grid_coords.DX);
  unsigned CartY = roundf(DYp/grid_coords.DY);
  if(debug && debug_level >= 5) {
    unsigned pos = (CartY * grid_coords.NX) + CartX;
    std::cout << "File pos " << pos << " to LAT/LON = " << std::setprecision(7) << latlon_grid[pos].lat
	      << "/" <<  latlon_grid[pos].lon << "\n";
  }
  return (CartY * grid_coords.NX) + CartX;
} 

int SetGrib2Message2Coords(GRIB2Message &g2message, GridCoords &coords)
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
	case 'f':
	  fill_only = 1;
	  break;
	case 'c':
	  use_cluster_points = 1;
	  break;
	case 'k':
	  gen_kml_template = 1;
	  strncpy(sbuf, &argv[i][2], (sizeof(sbuf)-1));
	  kml_template_file = sbuf;
	  if(kml_template_file.is_null()) kml_template_file = "runup_points_template.kml";
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
    std::cout << "          " << process_name << " SWAN_RUNUP_OUTPUT_FILE runup_type runup_type.meta templates.grib2 points.bin" << "\n";
    std::cout << "args:" << "\n";
    std::cout << "       -v    Enable verbose output mode" << "\n";
    std::cout << "       -d    Enable debug mode" << "\n";
    std::cout << "       -D    Set debug level -D1 -D2 -D3 -D4 -D5" << "\n";
    std::cout << "       -c    Create a cluster of grid points for each data point" << "\n";
    std::cout << "       -f    Use fill values only to verify all grid points" << "\n";
    std::cout << "       -k\"template.kml\"    Create a KML template to verify RUNUP points" << "\n";
    std::cout << "\n";
    std::cout << "Example:" << "\n";
    std::cout << "           " << process_name << " tbw_nwps_20m_CG2_runup.20161206_1800 owash_flag owash_flag.meta templates.grib2 points.bin" << "\n";
    std::cout << "\n";
    std::cout << "Usage1: - Enable verbose, debug, and debug levels" << "\n";
    std::cout << "         " << process_name << " -v -d tbw_nwps_20m_CG2_runup.20161206_1800 owash_flag owash_flag.meta templates.grib2 points.bin" << "\n";
    std::cout << "         " << process_name << " -v -D5 tbw_nwps_20m_CG2_runup.20161206_1800 owash_flag owash_flag.meta templates.grib2 points.bin" << "\n";
    std::cout << "\n";
    std::cout << "Runup types = \n";
    for(int i = 0; i < num_runup_types; i++) {
      std::cout << "               " << runup_types[i].c_str() << "\n";
    }
    std::cout << "\n";
}
// ----------------------------------------------------------- //
// ------------------------------- //
// --------- End of File --------- //
// ------------------------------- //

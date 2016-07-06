// ------------------------------- //
// -------- Start of File -------- //
// ------------------------------- //
// ----------------------------------------------------------- // 
// C++ Source Code File
// Compiler Used: MSVC, GCC
// Produced By: Douglas.Gaer@noaa.gov
// File Creation Date: 06/14/2011
// Date Last Modified: 04/18/2012
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

AWIPS netCDF classes and functions

*/
// ----------------------------------------------------------- // 

// STDLIB includes
#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>

// 3pLIBS includes
#include "dfileb.h"
#include "gxstring.h"

// Our project includes
#include "awips_netcdf.h"
#include "wind_file.h"

void NCDumpStrings::Copy(const NCDumpStrings &ob) 
{
  netcdf_name = ob.netcdf_name;
  dims = ob.dims;
  vars = ob.vars;
  global = ob.global;
  data = ob.data;
  error_string = ob.error_string;
}

void NCDumpStrings::Reset() 
{
  netcdf_name.Clear();
  dims.Clear();
  vars.Clear();
  global.Clear();
  data.Clear();
  error_string.Clear();
}

void netCDFVariables::CleanString(gxString &s) 
{
  s.FilterChar('\"');
  s.TrimLeadingSpaces();
  s.TrimTrailingSpaces();
}

int netCDFVariables::SetVariables(const char *vname, NCDumpStrings &nc) 
{ 
  error_string.Clear();
  variable_name = vname;
  
  if(!SetTime(vname, nc)) return 0;
  SetString(nc, "descriptiveName", descriptiveName, 0);
  if(!SetCoordPair(nc, "gridSize", gridSize)) return 0;
  if(!SetCoordPair(nc, "domainOrigin", domainOrigin)) return 0;
  if(!SetCoordPair(nc, "domainExtent", domainExtent)) return 0;
  gxString stdParallel;
  SetString(nc, "stdParallelOne", stdParallel, 0);
  stdParallelOne = stdParallel.Atof();
  SetString(nc, "stdParallelTwo", stdParallel, 0);
  stdParallelTwo = stdParallel.Atof();
  
  if(!SetCoordPair(nc, "minMaxAllowedValues", minMaxAllowedValues)) return 0;
  if(!SetString(nc, "gridType", gridType)) return 0;
  SetString(nc, "databaseID", databaseID, 0);
  if(!SetString(nc, "units", units)) return 0;
  SetString(nc, "level", level, 0);
  SetString(nc, "siteID", siteID, 0);
  if(!SetCoordPair(nc, "latLonLL", latLonLL)) return 0;
  if(!SetCoordPair(nc, "latLonUR", latLonUR)) return 0;
  if(!SetCoordPair(nc, "gridPointLL", gridPointLL)) return 0;
  if(!SetCoordPair(nc, "gridPointUR", gridPointUR)) return 0;
  if(!SetString(nc, "projectionType", projectionType)) return 0;

  gridtype = FindGridType(gridPointLL, gridPointUR, latLonLL, latLonUR);

  if(gridtype == AWIPS_NCEP1) {
    // NOTE: Reset any normalized values in the NCEP grid
    NCEP1 ncep1grid;
    latLonLL = ncep1grid.grid.latLonLL;
  }

  // NOTE: We must check for generic LATLON grid in order to support            
  // NOTE: old non-baseline IFPS server wind files files from SR-SWAN           
  // NOTE: and IFP-SWAN.                                                        
  if((gridtype == AWIPS_Unknown) && (projectionType == "LATLON")) {
    gridtype = AWIPS_CustomLatLon;
  }

  if(gridtype == AWIPS_Unknown) {
    error_string << clear << "ERROR - Unknown AWIPS grid or type not supported";
    return 0;
  }

  gridname = GetAWIPSGridName(gridtype);
  grid = SetGrid(gridtype);
  if(!grid) {
    error_string << clear << "ERROR - Error setting grid for AWIPS grid " << gridname;
    return 0;
  }

  if(gridtype == AWIPS_CustomLatLon) {
    grid->SetCustomGrid(latLonLL, latLonUR, gridPointLL, gridPointUR);
  }

  domain.Set(domainOrigin, domainExtent, gridSize); 
  grid->AWIPSDomainToLatLon(domain);

  gxString fill;
  if(!SetString(nc, "fillValue", fill)) return 0;
  fillValue = fill.Atof();
  return 1;
}

int netCDFVariables::SetString(NCDumpStrings &nc, const char *n, gxString &s, int error_level) 
{
  gxString varname;
  gxString *vars;
  unsigned numvars = 0;
  
  varname << clear <<  variable_name << ":" <<  n;
  vars = GetVars(nc, varname, numvars);
  if((!vars) || (numvars < 1)) {
    if(error_level > 0) {
      error_string << clear << "ERROR - No values found for " << varname.c_str();
    }
    else {
      // NOTE: This is not a fatal error so just post a warning
      error_string << clear << "WARNING - No values found for " << varname.c_str();
    }
    return 0;
  }
  else {
    s << clear << vars[0];
    CleanString(s);
  }
  if((vars) && (numvars >= 1)) {
    delete[] vars;
    vars = 0;
    numvars = 0;
  }
  
  return 1;
}

int netCDFVariables::SetCoordPair(NCDumpStrings &nc, const char *n, CoordPair &v, int error_level) 
{
  gxString varname;
  gxString *vars;
  unsigned numvars = 0;
  
  varname << clear <<  variable_name <<  ":" << n;
  vars = GetVars(nc, varname, numvars);
  if((!vars) || (numvars < 2)) {
    if(error_level > 0) {
      error_string << clear << "ERROR - No values found for " << varname.c_str();
    }
    else {
      // NOTE: This is not a fatal error so just post a warning
      error_string << clear << "WARNING - No values found for " << varname.c_str();
    }
    return 0;
  }
  CleanString(vars[0]); CleanString(vars[1]); 
  v.Set(vars[0].Atof(), vars[1].Atof());
  if((vars) && (numvars >= 1)) {
    delete[] vars;
    vars = 0;
    numvars = 0;
  }
  return 1;
}

int netCDFVariables::SetTime(const char *vname, NCDumpStrings &nc) 
{
  error_string.Clear();
  variable_name = vname;
  unsigned numvars = 0;
  unsigned i;
  
  gxString varname; // Full name for this variable
  varname << clear <<  variable_name << ":validTimes";
  gxString *vars = GetVars(nc, varname, numvars);
  if((!vars) || (numvars < 1)) {
    error_string << clear << "ERROR - No values found for " << varname.c_str();
    return 0;
  }
  
  start_time = (time_t)vars[0].Atoi();
  end_time = (time_t)vars[numvars-1].Atoi();

  time_vals = new time_t[numvars];
  memset(time_vals, 0, (numvars * sizeof(time_t)));
  
  time_t curr_val, prev_val;
  
  for(i = 0; i < numvars; i++) {
    curr_val = (time_t)vars[i].Atoi();
    if(i == 0) {
      time_vals[0] = (time_t)vars[0].Atoi();
    }
    else {
      if(curr_val != prev_val) time_vals[i] = (time_t)vars[i].Atoi(); 
    }
    prev_val = (time_t)vars[i].Atoi();
  }
  if(vars) delete[] vars;
  
  num_time_vals = -1;
  for(i = 0; i < numvars; i++) {
    if(time_vals[i] > 0) {
      num_time_vals++;
    }
  }
  if(num_time_vals < 0) num_time_vals = 0;

  time_t t1 = time_vals[0];
  time_t t2 = time_vals[1];
  time_step = (t2  - t1)/3600;
  num_hours = (end_time - start_time) / 3600;
  
  return 1;
}

void netCDFVariables::Print(gxString &mesg) 
{
  char month[25]; char day[25]; char year[25];
  char hour[25]; char minutes[25];
  char start_time_str[255];
  memset(start_time_str, 0, sizeof(start_time_str));
  char end_time_str[255];
  memset(end_time_str, 0, sizeof(end_time_str));

  epoch_time_to_str(start_time, month, day, year, hour, minutes);
  sprintf(start_time_str, "%s/%s/%s %s:%s", month, day, year, hour, minutes);
  epoch_time_to_str(end_time, month, day, year, hour, minutes);
  sprintf(end_time_str, "%s/%s/%s %s:%s", month, day, year, hour, minutes);

  mesg.Clear();
  mesg.Precision(3);
  mesg << "netCDF variables for: " << variable_name << "\n";
  mesg << "descriptiveName: " << descriptiveName << "\n";
  mesg << "Number of forecast times: " << num_time_vals << "\n";
  mesg << "Time step: " << time_step << "\n";
  mesg << "Start time: " << start_time << "\n";
  mesg << "Start time string: " << start_time_str << "\n";
  mesg << "End time: " << end_time << "\n";
  mesg << "End time string: " << end_time_str << "\n";
  mesg << "Number Hours: " << num_hours << "\n";
  mesg << "gridSize: " << (unsigned)gridSize[0] << ", " << (unsigned)gridSize[1] << "\n";
  mesg << "domainOrigin: " << domainOrigin[0] << ", " << domainOrigin[1] << "\n";
  mesg << "domainExtent: " << domainExtent[0] << ", " << domainExtent[1] << "\n";
  mesg << "minMaxAllowedValues: " << minMaxAllowedValues[0] << ", " << minMaxAllowedValues[1] << "\n";
  mesg << "gridType: " << gridType << "\n";
  mesg << "databaseID: " << databaseID << "\n";
  mesg << "siteID: " << siteID << "\n";
  mesg << "units: " << units << "\n";
  mesg << "level: " << level << "\n";
  mesg << "latLonLL: " << latLonLL[0] << ", " << latLonLL[1] << "\n";
  mesg << "latLonUR: " << latLonUR[0] << ", " << latLonUR[1] << "\n";
  mesg << "gridPointLL: " << gridPointLL[0] << ", " << gridPointLL[1] << "\n";
  mesg << "gridPointUR: " << gridPointUR[0] << ", " << gridPointUR[1] << "\n";
  mesg << "gridName: " << gridname << "\n";
  mesg << "projectionType: " << projectionType << "\n";
  mesg << "stdParallelOne: " << stdParallelOne << "\n";
  mesg << "stdParallelTwo: " << stdParallelTwo << "\n";
  mesg << "fillValue: " << fillValue << "\n";
  mesg << "\n";

  mesg.Precision(6);
  mesg << "AWIPS projected GRID info:" << "\n";
  mesg << "AWIPS x resolution: " << domain.awips_resolution_x_km << "\n";
  mesg << "AWIPS y resolution: " << domain.awips_resolution_y_km << "\n";
  mesg << "AWIPS upper left: " << domain.upper_left.lat << "/" << domain.upper_left.lon << "\n";
  mesg << "AWIPS lower right: " << domain.lower_right.lat << "/" << domain.lower_right.lon << "\n";
  mesg << "AWIPS upper right: " << domain.upper_right.lat << "/" << domain.upper_right.lon << "\n";
  mesg << "AWIPS lower left: " << domain.lower_left.lat << "/" << domain.lower_left.lon << "\n";
  mesg << "\n";
  mesg << "LATLON re-projected GRID info:" << "\n";
  mesg << "NUMMESHESLAT: " << (int)domain.NUMMESHESLAT << "\n";
  mesg << "NUMMESHESLON: " << (int)domain.NUMMESHESLON << "\n";
  mesg << "NORTHEASTLAT: " << domain.NORTHEASTLAT << "\n";
  mesg << "NORTHEASTLON: " << domain.NORTHEASTLON << "\n";
  mesg << "SOUTHWESTLAT: " << domain.SOUTHWESTLAT << "\n";
  mesg << "SOUTHWESTLON: " << domain.SOUTHWESTLON << "\n";
  mesg << "NORTH-SOUTH DEGREES: " << domain.NSD << "\n";
  mesg << "NORTH-SOUTH RESOLUTION: " << domain.NSR << "\n";
  mesg << "EAST-WEST DEGREES: " << domain.EWD << "\n";
  mesg << "EAST-WEST RESOLUTION: " << domain.EWR << "\n";
}

int ParseNCDumpVars(char *fname, NCDumpStrings &nc)
{
  char sbuf[1024];
  DiskFileB dfile;
  nc.Reset();

  // Open the current product file
  dfile.df_Open(fname);
  if(!dfile) {
    nc.error_string << clear << "ERROR - Cannot open product input file: " 
		    << fname << "\n" << dfile.df_ExceptionMessage();
    return 0;
  }

  int has_start = 0;
  int has_end = 0;
  int dim_start = 0;
  int var_start = 0;
  int global_start = 0;
  int line_number = 0;

  while(!dfile.df_EOF()) {
    // Get each line of the file and trim the line feeds
    dfile.df_GetLine(sbuf, sizeof(sbuf), '\n');
    if(dfile.df_GetError() != DiskFileB::df_NO_ERROR) {
      nc.error_string << clear << "ERROR - A fatal error reading file: " 
		      << fname << "\n" << dfile.df_ExceptionMessage();
      return 0;
    }
    line_number++;

    UString info_line(sbuf);
    info_line.FilterChar('\n');
    info_line.FilterChar('\r');
    info_line.TrimLeadingSpaces();
    info_line.TrimTrailingSpaces();

    if(info_line.is_null()) continue;

    if(!has_start) {
      if(info_line.Find("{") != -1) {
	has_start = line_number;
	info_line.DeleteAfterIncluding("{");
	info_line.TrimTrailingSpaces();
	nc.netcdf_name = info_line;
      }
    } 
    if(info_line.Find("}") != -1) {
      has_end = line_number;
      dim_start = var_start = global_start = 0;
      break;
    }

    if(info_line.Find("dimensions:") != -1) {
      dim_start = var_start = global_start = 0;
      dim_start = line_number;
      continue;
    }
    if(info_line.Find("variables:") != -1) {
      dim_start = var_start = global_start = 0;
      var_start = line_number;
      continue;
    }
    if(info_line.Find("global attributes:") != -1) {
      dim_start = var_start = global_start = 0;
      global_start = line_number;
      continue;
    }
    if(info_line.Find("data:") != -1) {
      dim_start = var_start = global_start = 0;
      has_end = line_number;
      // NOTE: The data arrays are very large so do not process here
      break;
    }
    if(dim_start > 0) {
      nc.dims << info_line.c_str() << "\n";
    }
    if(var_start > 0) {
      nc.vars << info_line.c_str() << "\n";
    }
    if(global_start > 0) {
      nc.global << info_line.c_str() << "\n";
    }
  }
  dfile.df_Close();

  if(!has_start) {
    nc.error_string << clear << "ERROR - Error parsing ncdump file. No start tag { found";
    return 0;
  }
  if(!has_end) {
    nc.error_string << clear << "ERROR - Error parsing ncdump file. No data: start or end tag } found";
    return 0;
  }
  
  return 1;
}

gxString *GetVars(NCDumpStrings &nc, const gxString &var_str_name, unsigned &numvars) 
{
  int offset1, offset2;
  nc.error_string.Clear();
  int found_var = 0;
  unsigned curr_offset = 0;

  while(curr_offset < (nc.vars.length()-1)) {
    offset1 = nc.vars.Find(var_str_name, curr_offset);
    if(offset1 == -1) {
      nc.error_string << clear << "ERROR - No " << var_str_name << " start tag found"; 
      return 0;
    }
    // 04/09/2013: Added check for correct variable name
    int tmpoffset = offset1;
    if(tmpoffset > 0) tmpoffset--;
    gxString found_var_str(nc.vars, tmpoffset, var_str_name.length());
    if(found_var_str[0] != '\n') {
      curr_offset = offset1+1;
      continue;
    }

    offset2 = nc.vars.Find(";", offset1);
    if(offset2 == -1) {
      nc.error_string << clear << "ERROR - No ; end tag found for " << var_str_name;
      return 0;
    }
    offset1--;
    if(offset1 < 0) {
      nc.error_string << clear << "ERROR - No " << var_str_name << " start tag found";
      return 0;
    }

    gxString exact_var_name(nc.vars, offset1, (offset2-offset1));
    exact_var_name.DeleteAfterIncluding("=");
    exact_var_name.FilterString(" ");
    exact_var_name.FilterString("\n"); exact_var_name.FilterString("\r");
    offset1++;

    if(exact_var_name == var_str_name) {
      found_var = 1; 
      break;
    }
    curr_offset += offset1;
  }

  if(!found_var) {
    nc.error_string << clear << "ERROR - No " << var_str_name << " start tag found"; 
    return 0;
  }

  gxString var_str(nc.vars, offset1, (offset2-offset1));
  var_str.DeleteBeforeIncluding("=");
  var_str.DeleteAfterIncluding(";");
  var_str.TrimLeadingSpaces(); var_str.TrimTrailingSpaces();
  var_str.FilterString("\n"); var_str.FilterString("\r");

  gxString delimiter = ",";
  int trim_spaces = 1;
  int trim_quotes = 1;
  numvars = 0;

  if(var_str.is_null()) {
    nc.error_string << clear << "ERROR - No data found for " << var_str_name;
    return 0;
  }

  return ParseStrings(var_str, delimiter, numvars, trim_spaces, trim_quotes);
}

int WriteNCDumpData(char *netcdf_filename, const gxString &data_var_name, const gxString &output_bin_filename,
		    unsigned &num_points, gxString &error_string)
{
  char sbuf[1024];
  gxString data_var_name_str;
  DiskFileB dfile;
  num_points = 0;
  error_string.Clear();


  data_var_name_str << clear << data_var_name << " =";

  // Open the current product file
  dfile.df_Open(netcdf_filename);
  if(!dfile) {
    error_string << clear << "ERROR - Cannot open product input file: " 
		 << netcdf_filename;
    return 0;
  }

  // Open a output file
  DiskFileB ofile;

  ofile.df_Create(output_bin_filename.c_str());
  if(!ofile) {
    error_string << clear << "ERROR - Cannot create BIN output file " << output_bin_filename.c_str();
    return 0;
  }

  int has_start = 0;
  int has_end = 0;
  int has_data_section = 0;
  int data_start = 0;
  int line_number = 0;
  gxString *vals = 0;
  gxString delimiter = ",";
  unsigned num_arr = 0;
  unsigned i = 0;

  while(!dfile.df_EOF()) {
    // Get each line of the file and trim the line feeds
    dfile.df_GetLine(sbuf, sizeof(sbuf), '\n');
    if(dfile.df_GetError() != DiskFileB::df_NO_ERROR) {
      error_string << clear << "ERROR - Fatal I/O error occurred reading " << netcdf_filename;
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
	  ofile.df_Write(&f, sizeof(f));
	  if(ofile.df_GetError() != DiskFileB::df_NO_ERROR) {
	    error_string << clear << "ERROR - Fatal I/O error occurred writing to " << output_bin_filename;
	      dfile.df_Close();
	      ofile.df_Close();
	      return 0;
	  }
	  num_points++;
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
	ofile.df_Write(&f, sizeof(f));
	if(ofile.df_GetError() != DiskFileB::df_NO_ERROR) {
	  error_string << clear << "ERROR - Fatal I/O error occurred writing to " << output_bin_filename;
	  dfile.df_Close();
	  ofile.df_Close();
	  return 0;
	}
	num_points++;
      }
      if(vals) { 
	delete[] vals;
	vals = 0;
      }
    }
  }
  dfile.df_Close();
  ofile.df_Close();

  if(!has_start) {
    error_string << clear << "ERROR - Error parsing ncdump file. No start tag " 
		 << data_var_name_str.c_str() << " found";
    ofile.df_remove(output_bin_filename.c_str());
    return 0;
  }
  if(!has_end) {
    error_string << clear << "ERROR - Error parsing ncdump file. No end tag ; found";
    ofile.df_remove(output_bin_filename.c_str());
    return 0;
  }
  if(!has_data_section) {
    error_string << clear << "ERROR - Error parsing ncdump file. No end tag data: section";
    ofile.df_remove(output_bin_filename.c_str());
    return 0;
  }

  return 1;
}

// ----------------------------------------------------------- //
// ------------------------------- //
// --------- End of File --------- //
// ------------------------------- //

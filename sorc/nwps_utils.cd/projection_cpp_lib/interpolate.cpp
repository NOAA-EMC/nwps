// ------------------------------- //
// -------- Start of File -------- //
// ------------------------------- //
// ----------------------------------------------------------- // 
// C++ Source Code File
// Compiler Used: MSVC, GCC
// Produced By: Douglas.Gaer@noaa.gov
// File Creation Date: 06/30/2011
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

Interpolation routines for re-projected AWIPS grids.

Interpolation example:

Find the 4 neighbors of each grid point from the projected grid, for example:

              *  *  *
              *  *  *
  north west  *-----* north east
              |  *  |
  south west  *-----* south east
              *  *  * 
              *  *  *

We will traverse the grid starting from the southwest LAT/LON.

This program offers 3 interpolation methods and 1 testing mode:

- NONE: Will not apply any interpolation, used for testing only. 

- NEAREST: Find the nearest neighbor of each grid point and rotate 
           each data point counterclockwise wise along the X axis 
           of the output grid.

- LINEAR: Find 4 neighbors of each grid point and take an average 
          of the grid point plus its 4 neighbors.

- BILINEAR: Find 4 neighbors of each grid point a determine a weight 
            value based on the distance to each neighbor. The distance, 
            in KM, cannot exceed the grid spacing in the X or Y direction. 
            The weight value is inversely proportional to distance divided 
            by the sum of all 4 weights resulting in a 1 or 0 value. The 
            output point is equal to the sum of each grid point value 
            multiplied by its weight.                                          

NOTE: For wind and current we can only interpolate U/V vectors.
NOTE: Speed (MAG) and direction (DIR) must be converted for U/V 
NOTE: before interploating.

*/
// ----------------------------------------------------------- // 

// STDLIB includes
#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

// 3pLIBS includes
#include "dfileb.h"
#include "gxstring.h"

// Our project includes
#include "interpolate.h"

void InterpolateGrid::Reset()
{
  error_string.Clear(); 
  missing_value = 9999.0;
  itype = BILINEAR_INTERP;
  interpolated_grid = 0;
  if(interpolated_grid) delete [] interpolated_grid;
  interpolated_grid = 0;
}

int InterpolateGrid::WriteInterpolatedGrid(netCDFVariables &ncv, const gxString &bin_filename, gxString &out_filename)
{
  if(ncv.projectionType == "LATLON") {
    return 1;
  }

  if(ncv.projectionType == "MERCATOR") {
    return write_interpolated_mercator_grid(ncv, bin_filename, out_filename);
  }
  if(ncv.projectionType == "LAMBERT_CONFORMAL") {
    return write_interpolated_lambert_grid(ncv, bin_filename, out_filename);
  }
  if(ncv.projectionType == "POLAR_STEREOGRAPHIC") {
    return write_interpolated_polar_grid(ncv, bin_filename, out_filename);
  }

  error_string << clear << "ERROR - Unknown AWIPS grid or type not supported";
  return 0;
}

PointData *InterpolateGrid::create_latlon_grid(netCDFVariables &ncv)
{
  return CreateLatLonGrid(ncv, missing_value);
}

int InterpolateGrid::write_interpolated_lambert_grid(netCDFVariables &ncv, const gxString &bin_filename, gxString &out_filename)
{
  return write_interpolated_grid(ncv, bin_filename, out_filename);
}

int InterpolateGrid::write_interpolated_mercator_grid(netCDFVariables &ncv, const gxString &bin_filename, gxString &out_filename)
{
  return write_interpolated_grid(ncv, bin_filename, out_filename);
}


int InterpolateGrid::write_interpolated_polar_grid(netCDFVariables &ncv, const gxString &bin_filename, gxString &out_filename)
{
  return write_interpolated_grid(ncv, bin_filename, out_filename);
}


PointData *CreateLatLonGrid(netCDFVariables &ncv, float missing_value)
{
  unsigned nx = (unsigned)ncv.gridSize[0];
  unsigned ny = (unsigned)ncv.gridSize[1];

  const unsigned gridsize = nx * ny;
  PointData *latlon_grid = new PointData[gridsize];
  unsigned x = 0;
  unsigned y = 0;
  unsigned curr_point_number = 0;
  float lat = ncv.domain.SOUTHWESTLAT;
  float lon = ncv.domain.SOUTHWESTLON;

  // Create a LATLON grid to re-project and/or interploate projected grid
  for(x = 0; x < nx; x++) {
    for(y = 0; y < ny; y++) {
      latlon_grid[curr_point_number].lat = lat;
      latlon_grid[curr_point_number].lon = lon;
      latlon_grid[curr_point_number].x = x;
      latlon_grid[curr_point_number].y = y;
      latlon_grid[curr_point_number].grid_point_number = curr_point_number;
      latlon_grid[curr_point_number].data = missing_value;
      lat += ncv.domain.NSR;
      curr_point_number++;
    }
    lon += ncv.domain.EWR;
    lat = ncv.domain.SOUTHWESTLAT;
  }

  return latlon_grid;
}

int InterpolateGrid::write_interpolated_grid(netCDFVariables &ncv, const gxString &bin_filename, gxString &out_filename)
{
  DiskFileB bin_fp, interpolated_fp;
  error_string.Clear();
  error_string.Precision(4);

  bin_fp.df_Open(bin_filename.c_str());
  if(bin_fp.df_GetError() != DiskFileB::df_NO_ERROR) {
    error_string << "ERROR - Cannot open file " <<  bin_filename.c_str();
    return 0;
  }

  float data;
  unsigned i;
  unsigned nx = (unsigned)ncv.gridSize[0];
  unsigned ny = (unsigned)ncv.gridSize[1];
  int error_flag = 0;
  PointData *awips_grid = ncv.grid->GetPointData(); 

  interpolated_fp.df_Create(out_filename.c_str());
  if(interpolated_fp.df_GetError() != DiskFileB::df_NO_ERROR) {
    error_string << "ERROR - Cannot create file " <<  out_filename.c_str();
    bin_fp.df_Close();
    delete[] interpolated_grid;
    return 0;
  }

  unsigned x, y;
  unsigned current_point = 0;
  unsigned point_location = 0;

  while(!bin_fp.df_EOF()) {
    // Load the first hour of data from the AWIPS grid
    current_point = 0;
    for(x = 0; x < nx; x++) {
      for(y = 0; y < ny; y++) {
	bin_fp.df_Read((unsigned char *)&data, sizeof(data));
	if(bin_fp.df_GetError() != DiskFileB::df_NO_ERROR) {
	  error_string << "ERROR - Cannot read from file " 
		       <<  bin_filename.c_str();
	  error_flag = 1;
	  break;
	}
	point_location = (x * ny) + y;
	if(point_location > ((nx * ny)-1)) point_location = (nx * ny)-1;

	// Set the data points in our AWIPS grid
	awips_grid[point_location].data = data;
	if(FloatEqualTo(awips_grid[point_location].data, ncv.fillValue)) awips_grid[point_location].data = missing_value;

	// Reset the data points in the interpolated grid
	interpolated_grid[current_point].data = missing_value;
	current_point++;
      }
      if(error_flag > 0) break;
    }

    if(error_flag > 0) break;

    int rv;
    if(ncv.projectionType == "MERCATOR") {
      rv = interpolate_mercator_awips_grid(ncv);
    }
    else if(ncv.projectionType == "LAMBERT_CONFORMAL") {
      rv = interpolate_lambert_awips_grid(ncv);
    }
    else if(ncv.projectionType == "POLAR_STEREOGRAPHIC") {
      rv = interpolate_polar_awips_grid(ncv);
    }
    else {
      error_string << "ERROR - Cannot interpolate projection " <<  ncv.projectionType.c_str();
      error_flag = 1;
      break;
    }

    if(!rv) {
      error_flag = 1;
      break;
    }
    
    for(i = 0; i < (nx*ny); i++) {
      interpolated_fp.df_Write(&interpolated_grid[i].data, sizeof(interpolated_grid[i].data));
      if(interpolated_fp.df_GetError() != DiskFileB::df_NO_ERROR) {
	error_string << "ERROR - Cannot write to file " <<  out_filename.c_str();
	error_flag = 1;
	break;
      }
    }

    if(error_flag > 0) break;
    interpolated_fp.df_Flush(); // Flush this hour to disk

    // This hour of data is complete, Continue to next hour or break after all hours are complete
  }
  
  bin_fp.df_Close();
  interpolated_fp.df_Close();
  if(error_flag > 0) return 0;
  
  return 1;
}

int InterpolateGrid::interpolate_polar_awips_grid(netCDFVariables &ncv)
{
  unsigned nx = (unsigned)ncv.gridSize[0];
  unsigned ny = (unsigned)ncv.gridSize[1];
  unsigned x, y;
  unsigned point_location = 0;
  int nw_x, nw_y, ne_x, ne_y;
  int sw_x, sw_y, se_x, se_y;
  float nw_dist, sw_dist, ne_dist, se_dist;
  float d0, d1, d2, d3, d4;
  float sum_of_weights = 0;
  float nw_weight = 0;
  float sw_weight = 0;
  float ne_weight = 0;
  float se_weight = 0;
  float interpolated_point, point_average;
  unsigned neighboring_point_location = 0;
  unsigned neighboring_point_dataloc = 0;
  PointData *awips_grid = ncv.grid->GetPointData(); 

  PointData north_west_neighbor; // (x-1/y+1)
  PointData north_east_neighbor; // (x+1/y+1)
  PointData south_west_neighbor; // (x-1/y-1)
  PointData south_east_neighbor; // (x+1/y-1)
  
  float lat_origin = ncv.domain.SOUTHWESTLAT;
  float lon_origin = ncv.domain.SOUTHWESTLON;

  unsigned curr_point = 0;

  for(x = 0; x < nx; x++) {
    for(y = 0; y < ny; y++) {
      point_location = (x * ny) + y;
      if(point_location > ((nx * ny)-1)) point_location = (nx * ny)-1;

      // Calculate the data point value to overlay onto the re-mapped point location
      // This will rotate each data point counter clock-wise along the X axis
      unsigned dataloc = (y * nx) + x;
      if(dataloc > (nx*ny)-1) continue;

      // Calculate the i and j grid point values for each AWIPS point
      double j = (awips_grid[point_location].lon - lon_origin) / ncv.domain.EWR;
      double i = (awips_grid[point_location].lat - lat_origin) / ncv.domain.NSR;

      int int_i, int_j;
      if(x > ny) {
	Float2Int(i, int_i, 10000, 0);
	Float2Int(j, int_j, 10, 0);
      }
      else {
	Float2Int(i, int_i, 10000, 1);
	Float2Int(j, int_j, 10, 1);
      }
      if(int_i < 0) int_i -= int_i*2;
      if(int_j < 0) int_j -= int_j*2;

      // This is our re-mapped point location
      unsigned loc = (int_i * nx) + int_j;
      if(loc > (nx*ny)-1) continue;

      // Calculate the data point of our 4 neighbors
      nw_x = x-1;
      nw_y = y+1;
      ne_x = x+1;
      ne_y = y+1;
      sw_x = x-1;
      sw_y = y-1;
      se_x = x+1;
      se_y = y-1;

      nw_dist = sw_dist = ne_dist = se_dist = 0;
      nw_weight = 0; sw_weight = 0; ne_weight = 0; se_weight = 0;
      point_average = 0;
      interpolated_point = 0;
      sum_of_weights = 0;
      d0 = d1 = d2 = d3 = d4 = awips_grid[dataloc].data;

      // Set our grid spacing
      float max_grid_spacing = ncv.domain.awips_resolution_x_km + ncv.domain.awips_resolution_y_km;
      if(FloatEqualToOrLessThan(max_grid_spacing, 0)) {
	// Grid spacing info is missing so estimate the resolution
	max_grid_spacing = (ncv.domain.awips_resolution_x_deg * 100) + (ncv.domain.awips_resolution_y_deg * 100); 
      }

      if((nw_x > 0 && nw_y > 0) && (nw_x < (int)nx && nw_y < (int)ny)) {
	neighboring_point_location = (nw_x * ny) + nw_y;
	neighboring_point_dataloc = (nw_y * nx) + nw_x;
	if((neighboring_point_location < (nx * ny)) && (neighboring_point_dataloc < (nx*ny))) {
	  north_west_neighbor = awips_grid[neighboring_point_location];
	  if(FloatNotEqualTo(north_west_neighbor.data, missing_value)) {
	    if(FloatNotEqualTo(north_west_neighbor.data, ncv.fillValue)) {
	      d1 = awips_grid[neighboring_point_dataloc].data;
	      nw_dist = LatLonDistance(north_west_neighbor, awips_grid[point_location]); 
	      if((FloatGreaterThan(nw_dist, max_grid_spacing)) || 
		 (FloatEqualTo(d1, missing_value)) || (FloatEqualTo(d1, ncv.fillValue))) {
		nw_dist = 0;
		d1 = d0; 
	      }
	    }
	  }
	}
      }
      if((ne_x > 0 && ne_y > 0) && (ne_x < (int)nx && ne_y < (int)ny)) {
	neighboring_point_location = (ne_x * ny) + ne_y;
	neighboring_point_dataloc = (ne_y * nx) + ne_x;
	if((neighboring_point_location < (nx * ny)) && (neighboring_point_dataloc < (nx*ny))) {
	  north_east_neighbor = awips_grid[neighboring_point_location];
	  if(FloatNotEqualTo(north_east_neighbor.data, missing_value)) {
	    if(FloatNotEqualTo(north_east_neighbor.data, ncv.fillValue)) {
	      d2 = awips_grid[neighboring_point_dataloc].data;
	      ne_dist = LatLonDistance(north_east_neighbor, awips_grid[point_location]);  
	      if((FloatGreaterThan(ne_dist, max_grid_spacing)) ||
		 (FloatEqualTo(d2, missing_value)) || (FloatEqualTo(d2, ncv.fillValue))) {
		ne_dist = 0;
		d2 = d0;
	      }
	    }
	  }
	}
      }
      if((sw_x > 0 && sw_y > 0) && (sw_x < (int)nx && sw_y < (int)ny)) {
	neighboring_point_location = (sw_x * ny) + sw_y;
	neighboring_point_dataloc = (sw_y * nx) + sw_x;
	if((neighboring_point_location < (nx * ny)) && (neighboring_point_dataloc < (nx*ny))) {
	  south_west_neighbor = awips_grid[neighboring_point_location];
	  if(FloatNotEqualTo(south_west_neighbor.data, missing_value)) {
	    if(FloatNotEqualTo(south_west_neighbor.data, ncv.fillValue)) {
	      d3 = awips_grid[neighboring_point_dataloc].data;
	      sw_dist = LatLonDistance(south_west_neighbor, awips_grid[point_location]);  
	      if((FloatGreaterThan(sw_dist, max_grid_spacing)) ||
		 (FloatEqualTo(d3, missing_value)) || (FloatEqualTo(d3, ncv.fillValue))) {
		sw_dist = 0;
		d3 = d0;
	      }
	    }
	  }
	}
      }
      if((se_x > 0 && se_y > 0) && (se_x < (int)nx && se_y < (int)ny)) {
	neighboring_point_location = (se_x * ny) + se_y;
	neighboring_point_dataloc = (se_y * nx) + se_x;
	if((neighboring_point_location < (nx * ny)) && (neighboring_point_dataloc < (nx*ny))) {
	  south_east_neighbor = awips_grid[neighboring_point_location];
	  if(FloatNotEqualTo(south_east_neighbor.data, missing_value)) {
	    if(FloatNotEqualTo(south_east_neighbor.data, ncv.fillValue)) {
	      d4 = awips_grid[neighboring_point_dataloc].data;
	      se_dist = LatLonDistance(south_east_neighbor, awips_grid[point_location]);
	      if((FloatGreaterThan(se_dist, max_grid_spacing)) ||
		 (FloatEqualTo(d4, missing_value)) || (FloatEqualTo(d4, ncv.fillValue))) {
		se_dist = 0;
		d4 = d0;
	      }
	    }
	  }
	}
      }

      // Calculate weight values for bilinear interpolation
      sum_of_weights = nw_weight = sw_weight = ne_weight = se_weight = 0;
      
      if(FloatGreaterThan(nw_dist, 0)) sum_of_weights += 1/nw_dist;
      if(FloatGreaterThan(sw_dist, 0)) sum_of_weights += 1/sw_dist;
      if(FloatGreaterThan(ne_dist, 0)) sum_of_weights += 1/ne_dist;
      if(FloatGreaterThan(se_dist, 0)) sum_of_weights += 1/se_dist;
      
      if(FloatGreaterThan(nw_dist, 0) && FloatGreaterThan(sum_of_weights, 0)) {
	nw_weight = 1/nw_dist / sum_of_weights; 
      }
      if(FloatGreaterThan(sw_dist, 0) && FloatGreaterThan(sum_of_weights, 0)) {
	sw_weight = 1/sw_dist / sum_of_weights; 
      }
      if(FloatGreaterThan(ne_dist, 0) && FloatGreaterThan(sum_of_weights, 0)) {
	ne_weight = 1/ne_dist / sum_of_weights; 
      }
      if(FloatGreaterThan(se_dist, 0) && FloatGreaterThan(sum_of_weights, 0)) {
	se_weight = 1/se_dist / sum_of_weights; 
      }
      
      int points_to_average = 5;
      if((FloatEqualTo(d0, missing_value)) || (FloatEqualTo(d0, ncv.fillValue))) {
	points_to_average--;
	d0 = 0;
      }
      if((FloatEqualTo(d1, missing_value)) || (FloatEqualTo(d1, ncv.fillValue))) {
	points_to_average--;
	d1 = 0;
      }
      if((FloatEqualTo(d2, missing_value)) || (FloatEqualTo(d2, ncv.fillValue))) {
	points_to_average--;
	d2 = 0;
      }
      if((FloatEqualTo(d3, missing_value)) || (FloatEqualTo(d3, ncv.fillValue))) {
	points_to_average--;
	d3 = 0;
      }
      if((FloatEqualTo(d4, missing_value)) || (FloatEqualTo(d4, ncv.fillValue))) {
	points_to_average--;
	d4 = 0;
      }

      // Linear interpolation 
      if(points_to_average > 0) {
	point_average = (d0 + d1 + d2 + d3 + d4) / points_to_average;
      }
      else {
	point_average = missing_value;
      }

      // Bilinear interpolation
      interpolated_point = (nw_weight * d1) + (sw_weight * d2) + (ne_weight * d3) + (se_weight * d4);
      if(FloatEqualTo(interpolated_point, 0) && FloatNotEqualTo(awips_grid[dataloc].data, 0)) {
	interpolated_point = awips_grid[dataloc].data;
      }

      // Remove any fill values
      if(FloatEqualTo(interpolated_point, ncv.fillValue)) interpolated_point = missing_value;
      if(FloatEqualTo(point_average, ncv.fillValue)) point_average = missing_value;

      switch(itype) {
	case NO_INTERP:
	  if(curr_point < (nx*ny)) interpolated_grid[curr_point].data = awips_grid[curr_point].data;
	  break;
	case NEAREST_INTERP:
	  if(FloatEqualTo(interpolated_grid[loc].data, missing_value)) { 
	    interpolated_grid[loc].data = awips_grid[dataloc].data;
	  }
	  if(ncv.projectionType == "POLAR_STEREOGRAPHIC") {
	    loc++;
	    if(loc > (nx*ny)-1) break;
	    if(y > (ny/2)) {
	      if(FloatEqualTo(interpolated_grid[loc].data, missing_value)) { 
		interpolated_grid[loc].data = awips_grid[dataloc].data;
	      }
	    }
	  }
	  break;
	case LINEAR_INTERP:
	  if(FloatEqualTo(interpolated_grid[loc].data, missing_value)) {
	    interpolated_grid[loc].data = point_average;
	  }
	  loc++;
	  if(loc > (nx*ny)-1) break;
	  if(y > (ny/2)) { 
	    if(FloatEqualTo(interpolated_grid[loc].data, missing_value)) {
	      interpolated_grid[loc].data = point_average; 
	    }
	  }
      	  break;
	case BILINEAR_INTERP:
	  if(FloatEqualTo(interpolated_grid[loc].data, missing_value)) {
	    interpolated_grid[loc].data = interpolated_point;
	  }
	  loc++;
	  if(loc > (nx*ny)-1) break;
	  if(y > (ny/2)) {
	    if(FloatEqualTo(interpolated_grid[loc].data, missing_value)) { 
	      interpolated_grid[loc].data = interpolated_point; 
	    }
	  }
      	  break;
	case REMAPTEST_INTERP:
	  // Special testing mode used for viewing remapped grid points
	  if(FloatEqualTo(interpolated_grid[loc].data, missing_value)) { 
	    interpolated_grid[loc].data = 5;
	  }
	  loc++;
	  if(loc > (nx*ny)-1) break;
	  if(y > (ny/2)) {
	    if(FloatEqualTo(interpolated_grid[loc].data, missing_value)) { 
	      interpolated_grid[loc].data = 5;
	    }
	  }
	  break;
	default: // Default to nearest neighbor interploation
	  if(FloatEqualTo(interpolated_grid[loc].data, missing_value)) { 
	    interpolated_grid[loc].data = awips_grid[dataloc].data;
	  }
	  loc++;
	  if(loc > (nx*ny)-1) break;
	  if(y > (ny/2)) {
	    interpolated_grid[loc].data = awips_grid[dataloc].data;
	  }
	  break;
      }
      curr_point++;
    }
  }

  return 1;
}

int InterpolateGrid::interpolate_lambert_awips_grid(netCDFVariables &ncv)
{
  unsigned nx = (unsigned)ncv.gridSize[0];
  unsigned ny = (unsigned)ncv.gridSize[1];
  unsigned x, y;
  unsigned point_location = 0;
  int nw_x, nw_y, ne_x, ne_y;
  int sw_x, sw_y, se_x, se_y;
  float nw_dist, sw_dist, ne_dist, se_dist;
  float d0, d1, d2, d3, d4;
  float sum_of_weights = 0;
  float nw_weight = 0;
  float sw_weight = 0;
  float ne_weight = 0;
  float se_weight = 0;
  float interpolated_point, point_average;
  unsigned neighboring_point_location = 0;
  unsigned neighboring_point_dataloc = 0;
  PointData *awips_grid = ncv.grid->GetPointData(); 

  // Set our grid spacing
  float max_grid_spacing = ncv.domain.awips_resolution_x_km + ncv.domain.awips_resolution_y_km;
  if(FloatEqualToOrLessThan(max_grid_spacing, 0)) {
    // Grid spacing info is missing so estimate the resolution
    max_grid_spacing = (ncv.domain.awips_resolution_x_deg * 100) + (ncv.domain.awips_resolution_y_deg * 100); 
  }

  PointData north_west_neighbor; // (x-1/y+1)
  PointData north_east_neighbor; // (x+1/y+1)
  PointData south_west_neighbor; // (x-1/y-1)
  PointData south_east_neighbor; // (x+1/y-1)
  
  float lat_origin = ncv.domain.SOUTHWESTLAT;
  float lon_origin = ncv.domain.SOUTHWESTLON;

  unsigned curr_point = 0;

  for(x = 0; x < nx; x++) {
    for(y = 0; y < ny; y++) {
      point_location = (x * ny) + y;
      if(point_location > ((nx * ny)-1)) point_location = (nx * ny)-1;

      // Calculate the data point value to overlay onto the re-mapped point location
      // This will rotate each data point counter clock-wise along the X axis
      unsigned dataloc = (y * nx) + x;
      if(dataloc > (nx*ny)-1) continue;

      // Calculate the i and j grid point values for each AWIPS point
      double j = (awips_grid[point_location].lon - lon_origin) / ncv.domain.EWR;
      double i = (awips_grid[point_location].lat - lat_origin) / ncv.domain.NSR;

      int int_i, int_j;
      Float2Int(i, int_i, 10, 1);
      Float2Int(j, int_j, 10, 1);
      if(int_i < 0) int_i -= int_i*2;
      if(int_j < 0) int_j -= int_j*2;

      // This is our re-mapped point location for point 1
      unsigned loc1 = (int_i * nx) + int_j;
      if(loc1 > (nx*ny)-1) continue;

      Float2Int(i, int_i, 10, 0);
      Float2Int(j, int_j, 10, 0);

      // This is our re-mapped point location for point 2
      unsigned loc2 = (int_i * nx) + int_j;
      if(loc2 > (nx*ny)-1) continue;

      // NOTE: The order for remap Lambert is write LOC1 for missings
      // NOTE: and write LOC2 for data location.

      // Calculate the data point of our 4 neighbors
      nw_x = x-1;
      nw_y = y+1;
      ne_x = x+1;
      ne_y = y+1;
      sw_x = x-1;
      sw_y = y-1;
      se_x = x+1;
      se_y = y-1;

      nw_dist = sw_dist = ne_dist = se_dist = 0;
      nw_weight = 0; sw_weight = 0; ne_weight = 0; se_weight = 0;
      point_average = 0;
      interpolated_point = 0;
      sum_of_weights = 0;
      d0 = d1 = d2 = d3 = d4 = awips_grid[dataloc].data;

      if((nw_x > 0 && nw_y > 0) && (nw_x < (int)nx && nw_y < (int)ny)) {
	neighboring_point_location = (nw_x * ny) + nw_y;
	neighboring_point_dataloc = (nw_y * nx) + nw_x;
	if((neighboring_point_location < (nx * ny)) && (neighboring_point_dataloc < (nx*ny))) {
	  north_west_neighbor = awips_grid[neighboring_point_location];
	  if(FloatNotEqualTo(north_west_neighbor.data, missing_value)) {
	    if(FloatNotEqualTo(north_west_neighbor.data, ncv.fillValue)) {
	      d1 = awips_grid[neighboring_point_dataloc].data;
	      nw_dist = LatLonDistance(north_west_neighbor, awips_grid[point_location]); 
	      if((FloatGreaterThan(nw_dist, max_grid_spacing)) || 
		 (FloatEqualTo(d1, missing_value)) || (FloatEqualTo(d1, ncv.fillValue))) {
		nw_dist = 0;
		d1 = d0; 
	      }
	    }
	  }
	}
      }
      if((ne_x > 0 && ne_y > 0) && (ne_x < (int)nx && ne_y < (int)ny)) {
	neighboring_point_location = (ne_x * ny) + ne_y;
	neighboring_point_dataloc = (ne_y * nx) + ne_x;
	if((neighboring_point_location < (nx * ny)) && (neighboring_point_dataloc < (nx*ny))) {
	  north_east_neighbor = awips_grid[neighboring_point_location];
	  if(FloatNotEqualTo(north_east_neighbor.data, missing_value)) {
	    if(FloatNotEqualTo(north_east_neighbor.data, ncv.fillValue)) {
	      d2 = awips_grid[neighboring_point_dataloc].data;
	      ne_dist = LatLonDistance(north_east_neighbor, awips_grid[point_location]);  
	      if((FloatGreaterThan(ne_dist, max_grid_spacing)) ||
		 (FloatEqualTo(d2, missing_value)) || (FloatEqualTo(d2, ncv.fillValue))) {
		ne_dist = 0;
		d2 = d0;
	      }
	    }
	  }
	}
      }
      if((sw_x > 0 && sw_y > 0) && (sw_x < (int)nx && sw_y < (int)ny)) {
	neighboring_point_location = (sw_x * ny) + sw_y;
	neighboring_point_dataloc = (sw_y * nx) + sw_x;
	if((neighboring_point_location < (nx * ny)) && (neighboring_point_dataloc < (nx*ny))) {
	  south_west_neighbor = awips_grid[neighboring_point_location];
	  if(FloatNotEqualTo(south_west_neighbor.data, missing_value)) {
	    if(FloatNotEqualTo(south_west_neighbor.data, ncv.fillValue)) {
	      d3 = awips_grid[neighboring_point_dataloc].data;
	      sw_dist = LatLonDistance(south_west_neighbor, awips_grid[point_location]);  
	      if((FloatGreaterThan(sw_dist, max_grid_spacing)) ||
		 (FloatEqualTo(d3, missing_value)) || (FloatEqualTo(d3, ncv.fillValue))) {
		sw_dist = 0;
		d3 = d0;
	      }
	    }
	  }
	}
      }
      if((se_x > 0 && se_y > 0) && (se_x < (int)nx && se_y < (int)ny)) {
	neighboring_point_location = (se_x * ny) + se_y;
	neighboring_point_dataloc = (se_y * nx) + se_x;
	if((neighboring_point_location < (nx * ny)) && (neighboring_point_dataloc < (nx*ny))) {
	  south_east_neighbor = awips_grid[neighboring_point_location];
	  if(FloatNotEqualTo(south_east_neighbor.data, missing_value)) {
	    if(FloatNotEqualTo(south_east_neighbor.data, ncv.fillValue)) {
	      d4 = awips_grid[neighboring_point_dataloc].data;
	      se_dist = LatLonDistance(south_east_neighbor, awips_grid[point_location]);
	      if((FloatGreaterThan(se_dist, max_grid_spacing)) ||
		 (FloatEqualTo(d4, missing_value)) || (FloatEqualTo(d4, ncv.fillValue))) {
		se_dist = 0;
		d4 = d0;
	      }
	    }
	  }
	}
      }

      // Calculate weight values for bilinear interpolation
      sum_of_weights = nw_weight = sw_weight = ne_weight = se_weight = 0;
      
      if(FloatGreaterThan(nw_dist, 0)) sum_of_weights += 1/nw_dist;
      if(FloatGreaterThan(sw_dist, 0)) sum_of_weights += 1/sw_dist;
      if(FloatGreaterThan(ne_dist, 0)) sum_of_weights += 1/ne_dist;
      if(FloatGreaterThan(se_dist, 0)) sum_of_weights += 1/se_dist;
      
      if(FloatGreaterThan(nw_dist, 0) && FloatGreaterThan(sum_of_weights, 0)) {
	nw_weight = 1/nw_dist / sum_of_weights; 
      }
      if(FloatGreaterThan(sw_dist, 0) && FloatGreaterThan(sum_of_weights, 0)) {
	sw_weight = 1/sw_dist / sum_of_weights; 
      }
      if(FloatGreaterThan(ne_dist, 0) && FloatGreaterThan(sum_of_weights, 0)) {
	ne_weight = 1/ne_dist / sum_of_weights; 
      }
      if(FloatGreaterThan(se_dist, 0) && FloatGreaterThan(sum_of_weights, 0)) {
	se_weight = 1/se_dist / sum_of_weights; 
      }
      
      int points_to_average = 5;
      if((FloatEqualTo(d0, missing_value)) || (FloatEqualTo(d0, ncv.fillValue))) {
	points_to_average--;
	d0 = 0;
      }
      if((FloatEqualTo(d1, missing_value)) || (FloatEqualTo(d1, ncv.fillValue))) {
	points_to_average--;
	d1 = 0;
      }
      if((FloatEqualTo(d2, missing_value)) || (FloatEqualTo(d2, ncv.fillValue))) {
	points_to_average--;
	d2 = 0;
      }
      if((FloatEqualTo(d3, missing_value)) || (FloatEqualTo(d3, ncv.fillValue))) {
	points_to_average--;
	d3 = 0;
      }
      if((FloatEqualTo(d4, missing_value)) || (FloatEqualTo(d4, ncv.fillValue))) {
	points_to_average--;
	d4 = 0;
      }

      // Linear interpolation 
      if(points_to_average > 0) {
	point_average = (d0 + d1 + d2 + d3 + d4) / points_to_average;
      }
      else {
	point_average = missing_value;
      }

      // Bilinear interpolation
      interpolated_point = (nw_weight * d1) + (sw_weight * d2) + (ne_weight * d3) + (se_weight * d4);
      if(FloatEqualTo(interpolated_point, 0) && FloatNotEqualTo(awips_grid[dataloc].data, 0)) {
	interpolated_point = awips_grid[dataloc].data;
      }

      // Remove any fill values
      if(FloatEqualTo(interpolated_point, ncv.fillValue)) interpolated_point = missing_value;
      if(FloatEqualTo(point_average, ncv.fillValue)) point_average = missing_value;

      switch(itype) {
	case NO_INTERP:
	  if(curr_point < (nx*ny)) interpolated_grid[curr_point].data = awips_grid[curr_point].data;
	  break;
	case NEAREST_INTERP:
	  if(FloatEqualTo(interpolated_grid[loc1].data, missing_value)) { 
	    interpolated_grid[loc1].data = awips_grid[dataloc].data;
	  }
	  if(FloatEqualTo(interpolated_grid[loc2].data, missing_value)) {  
	    interpolated_grid[loc2].data = awips_grid[dataloc].data;
	  }
	  break;
	case LINEAR_INTERP:
	  if(FloatEqualTo(interpolated_grid[loc1].data, missing_value)) { 
	    interpolated_grid[loc1].data = point_average;
	  }
	  if(FloatEqualTo(interpolated_grid[loc2].data, missing_value)) { 
	    interpolated_grid[loc2].data = point_average;
	  }
	  break;
	case BILINEAR_INTERP:
	  if(FloatEqualTo(interpolated_grid[loc1].data, missing_value)) { 
	    interpolated_grid[loc1].data = interpolated_point;
	  }
	  if(FloatEqualTo(interpolated_grid[loc2].data, missing_value)) { 
	    interpolated_grid[loc2].data = interpolated_point;
	  }
	  break;
	case REMAPTEST_INTERP:
	  // Special testing mode used for viewing remapped grid points
	  if(FloatEqualTo(interpolated_grid[loc1].data, missing_value)) { 
	    interpolated_grid[loc1].data = 5.0;
	  }
	  if(FloatEqualTo(interpolated_grid[loc2].data, missing_value)) { 
	    interpolated_grid[loc2].data = 5.0;
	  }
	  break;
	default: // Default to nearest neighbor interploation
	  if(FloatEqualTo(interpolated_grid[loc1].data, missing_value)) { 
	    interpolated_grid[loc1].data = awips_grid[dataloc].data;
	  }
	  if(FloatEqualTo(interpolated_grid[loc2].data, missing_value)) { 
	    interpolated_grid[loc2].data = awips_grid[dataloc].data;
	  }
	  break;
      }
      curr_point++;
    }
  }

  return 1;
}

int InterpolateGrid::interpolate_mercator_awips_grid(netCDFVariables &ncv)
{
  unsigned nx = (unsigned)ncv.gridSize[0];
  unsigned ny = (unsigned)ncv.gridSize[1];
  unsigned x, y;
  unsigned point_location = 0;
  int nw_x, nw_y, ne_x, ne_y;
  int sw_x, sw_y, se_x, se_y;
  float nw_dist, sw_dist, ne_dist, se_dist;
  float d0, d1, d2, d3, d4;
  float sum_of_weights = 0;
  float nw_weight = 0;
  float sw_weight = 0;
  float ne_weight = 0;
  float se_weight = 0;
  float interpolated_point, point_average;
  unsigned neighboring_point_location = 0;
  unsigned neighboring_point_dataloc = 0;
  PointData *awips_grid = ncv.grid->GetPointData(); 

  PointData north_west_neighbor; // (x-1/y+1)
  PointData north_east_neighbor; // (x+1/y+1)
  PointData south_west_neighbor; // (x-1/y-1)
  PointData south_east_neighbor; // (x+1/y-1)
  
  float lat_origin = ncv.domain.SOUTHWESTLAT;
  float lon_origin = ncv.domain.SOUTHWESTLON;

  unsigned curr_point = 0;

  for(x = 0; x < nx; x++) {
    for(y = 0; y < ny; y++) {
      point_location = (x * ny) + y;
      if(point_location > ((nx * ny)-1)) point_location = (nx * ny)-1;

      // Calculate the data point value to overlay onto the re-mapped point location
      // This will rotate each data point counter clock-wise along the X axis
      unsigned dataloc = (y * nx) + x;
      if(dataloc > (nx*ny)-1) continue;

      // Calculate the i and j grid point values for each AWIPS point
      double j = (awips_grid[point_location].lon - lon_origin) / ncv.domain.EWR;
      double i = (awips_grid[point_location].lat - lat_origin) / ncv.domain.NSR;

      int epsilon_rep = 0;
      int ceil_value = 0;

      int epsilon_rep_i_loc1 = 0;
      int epsilon_rep_j_loc1 = 0;

      int epsilon_rep_i_loc2 = 0;
      int epsilon_rep_j_loc2 = 10;

      int epsilon_rep_i_loc3 = 0;
      int epsilon_rep_j_loc3 = 100;

      int epsilon_rep_i_loc4 = 0;
      int epsilon_rep_j_loc4 = 1000;

      int epsilon_rep_i_loc5 = 0;
      int epsilon_rep_j_loc5 = 10000;

      int epsilon_rep_i_loc6 = 10;
      int epsilon_rep_j_loc6 = 10;

      int epsilon_rep_i_loc7 = 100;
      int epsilon_rep_j_loc7 = 10;

      int epsilon_rep_i_loc8 = 1000;
      int epsilon_rep_j_loc8 = 10;

      int epsilon_rep_i_loc9 = 10000;
      int epsilon_rep_j_loc9 = 100;

      int epsilon_rep_i_loc10 = 100000;
      int epsilon_rep_j_loc10 = 1000;

      int int_i, int_j;
      Float2Int(i, int_i, epsilon_rep_i_loc1, ceil_value);
      Float2Int(j, int_j, epsilon_rep_j_loc1, ceil_value);
      if(int_i < 0) int_i -= int_i*2;
      if(int_j < 0) int_j -= int_j*2;
      // This is our re-mapped point location for point 1
      unsigned loc1 = (int_i * nx) + int_j;
      if(loc1 > (nx*ny)-1) continue;

      Float2Int(i, int_i, epsilon_rep_i_loc2, ceil_value);
      Float2Int(j, int_j, epsilon_rep_j_loc2, ceil_value);
      // This is our re-mapped point location for point 2
      unsigned loc2 = (int_i * nx) + int_j;
      if(loc2 > (nx*ny)-1) continue;

      Float2Int(i, int_i, epsilon_rep_i_loc3, ceil_value);
      Float2Int(j, int_j, epsilon_rep_j_loc3, ceil_value);
      // This is our re-mapped point location for point 3
      unsigned loc3 = (int_i * nx) + int_j;
      if(loc3 > (nx*ny)-1) continue;

      Float2Int(i, int_i, epsilon_rep_i_loc4, ceil_value);
      Float2Int(j, int_j, epsilon_rep_j_loc4, ceil_value);
      // This is our re-mapped point location for point 4
      unsigned loc4 = (int_i * nx) + int_j;
      if(loc4 > (nx*ny)-1) continue;

      Float2Int(i, int_i, epsilon_rep_i_loc5, ceil_value);
      Float2Int(j, int_j, epsilon_rep_j_loc5, ceil_value);
      // This is our re-mapped point location for point 5
      unsigned loc5 = (int_i * nx) + int_j;
      if(loc5 > (nx*ny)-1) continue;

      Float2Int(i, int_i, epsilon_rep_i_loc6, ceil_value);
      Float2Int(j, int_j, epsilon_rep_j_loc6, ceil_value);
      // This is our re-mapped point location for point 6
      unsigned loc6 = (int_i * nx) + int_j;
      if(loc6 > (nx*ny)-1) continue;
    
      Float2Int(i, int_i, epsilon_rep_i_loc7, ceil_value);
      Float2Int(j, int_j, epsilon_rep_j_loc7, ceil_value);
      // This is our re-mapped point location for point 7
      unsigned loc7 = (int_i * nx) + int_j;
      if(loc7 > (nx*ny)-1) continue;

      Float2Int(i, int_i, epsilon_rep_i_loc8, ceil_value);
      Float2Int(j, int_j, epsilon_rep_j_loc8, ceil_value);
      // This is our re-mapped point location for point 8
      unsigned loc8 = (int_i * nx) + int_j;
      if(loc8 > (nx*ny)-1) continue;

      Float2Int(i, int_i, epsilon_rep_i_loc9, ceil_value);
      Float2Int(j, int_j, epsilon_rep_j_loc9, ceil_value);
      // This is our re-mapped point location for point 9
      unsigned loc9 = (int_i * nx) + int_j;
      if(loc9 > (nx*ny)-1) continue;

      Float2Int(i, int_i, epsilon_rep_i_loc10, ceil_value);
      Float2Int(j, int_j, epsilon_rep_j_loc10, ceil_value);
      // This is our re-mapped point location for point 10
      unsigned loc10 = (int_i * nx) + int_j;
      if(loc10 > (nx*ny)-1) continue;

      // Calculate the data point of our 4 neighbors
      nw_x = x-1;
      nw_y = y+1;
      ne_x = x+1;
      ne_y = y+1;
      sw_x = x-1;
      sw_y = y-1;
      se_x = x+1;
      se_y = y-1;

      nw_dist = sw_dist = ne_dist = se_dist = 0;
      nw_weight = 0; sw_weight = 0; ne_weight = 0; se_weight = 0;
      point_average = 0;
      interpolated_point = 0;
      sum_of_weights = 0;
      d0 = d1 = d2 = d3 = d4 = awips_grid[dataloc].data;

      // Set our grid spacing
      float max_grid_spacing = ncv.domain.awips_resolution_x_km + ncv.domain.awips_resolution_y_km;
      if(FloatEqualToOrLessThan(max_grid_spacing, 0, epsilon_rep)) {
	// Grid spacing info is missing so estimate the resolution
	max_grid_spacing = (ncv.domain.awips_resolution_x_deg * 100) + (ncv.domain.awips_resolution_y_deg * 100); 
      }

      if((nw_x > 0 && nw_y > 0) && (nw_x < (int)nx && nw_y < (int)ny)) {
	neighboring_point_location = (nw_x * ny) + nw_y;
	neighboring_point_dataloc = (nw_y * nx) + nw_x;
	if((neighboring_point_location < (nx * ny)) && (neighboring_point_dataloc < (nx*ny))) {
	  north_west_neighbor = awips_grid[neighboring_point_location];
	  if(FloatNotEqualTo(north_west_neighbor.data, missing_value, epsilon_rep)) {
	    if(FloatNotEqualTo(north_west_neighbor.data, ncv.fillValue, epsilon_rep)) {
	      d1 = awips_grid[neighboring_point_dataloc].data;
	      nw_dist = LatLonDistance(north_west_neighbor, awips_grid[point_location]); 
	      if((FloatGreaterThan(nw_dist, max_grid_spacing, epsilon_rep)) || 
		 (FloatEqualTo(d1, missing_value, epsilon_rep)) || (FloatEqualTo(d1, ncv.fillValue, epsilon_rep))) {
		nw_dist = 0;
		d1 = d0; 
	      }
	    }
	  }
	}
      }
      if((ne_x > 0 && ne_y > 0) && (ne_x < (int)nx && ne_y < (int)ny)) {
	neighboring_point_location = (ne_x * ny) + ne_y;
	neighboring_point_dataloc = (ne_y * nx) + ne_x;
	if((neighboring_point_location < (nx * ny)) && (neighboring_point_dataloc < (nx*ny))) {
	  north_east_neighbor = awips_grid[neighboring_point_location];
	  if(FloatNotEqualTo(north_east_neighbor.data, missing_value, epsilon_rep)) {
	    if(FloatNotEqualTo(north_east_neighbor.data, ncv.fillValue, epsilon_rep)) {
	      d2 = awips_grid[neighboring_point_dataloc].data;
	      ne_dist = LatLonDistance(north_east_neighbor, awips_grid[point_location]);  
	      if((FloatGreaterThan(ne_dist, max_grid_spacing, epsilon_rep)) ||
		 (FloatEqualTo(d2, missing_value, epsilon_rep)) || (FloatEqualTo(d2, ncv.fillValue, epsilon_rep))) {
		ne_dist = 0;
		d2 = d0;
	      }
	    }
	  }
	}
      }
      if((sw_x > 0 && sw_y > 0) && (sw_x < (int)nx && sw_y < (int)ny)) {
	neighboring_point_location = (sw_x * ny) + sw_y;
	neighboring_point_dataloc = (sw_y * nx) + sw_x;
	if((neighboring_point_location < (nx * ny)) && (neighboring_point_dataloc < (nx*ny))) {
	  south_west_neighbor = awips_grid[neighboring_point_location];
	  if(FloatNotEqualTo(south_west_neighbor.data, missing_value, epsilon_rep)) {
	    if(FloatNotEqualTo(south_west_neighbor.data, ncv.fillValue, epsilon_rep)) {
	      d3 = awips_grid[neighboring_point_dataloc].data;
	      sw_dist = LatLonDistance(south_west_neighbor, awips_grid[point_location]);  
	      if((FloatGreaterThan(sw_dist, max_grid_spacing, epsilon_rep)) ||
		 (FloatEqualTo(d3, missing_value, epsilon_rep)) || (FloatEqualTo(d3, ncv.fillValue, epsilon_rep))) {
		sw_dist = 0;
		d3 = d0;
	      }
	    }
	  }
	}
      }
      if((se_x > 0 && se_y > 0) && (se_x < (int)nx && se_y < (int)ny)) {
	neighboring_point_location = (se_x * ny) + se_y;
	neighboring_point_dataloc = (se_y * nx) + se_x;
	if((neighboring_point_location < (nx * ny)) && (neighboring_point_dataloc < (nx*ny))) {
	  south_east_neighbor = awips_grid[neighboring_point_location];
	  if(FloatNotEqualTo(south_east_neighbor.data, missing_value, epsilon_rep)) {
	    if(FloatNotEqualTo(south_east_neighbor.data, ncv.fillValue, epsilon_rep)) {
	      d4 = awips_grid[neighboring_point_dataloc].data;
	      se_dist = LatLonDistance(south_east_neighbor, awips_grid[point_location]);
	      if((FloatGreaterThan(se_dist, max_grid_spacing, epsilon_rep)) ||
		 (FloatEqualTo(d4, missing_value, epsilon_rep)) || (FloatEqualTo(d4, ncv.fillValue, epsilon_rep))) {
		se_dist = 0;
		d4 = d0;
	      }
	    }
	  }
	}
      }

      // Calculate weight values for bilinear interpolation
      sum_of_weights = nw_weight = sw_weight = ne_weight = se_weight = 0;
      
      if(FloatGreaterThan(nw_dist, 0, epsilon_rep)) sum_of_weights += 1/nw_dist;
      if(FloatGreaterThan(sw_dist, 0, epsilon_rep)) sum_of_weights += 1/sw_dist;
      if(FloatGreaterThan(ne_dist, 0, epsilon_rep)) sum_of_weights += 1/ne_dist;
      if(FloatGreaterThan(se_dist, 0, epsilon_rep)) sum_of_weights += 1/se_dist;
      
      if(FloatGreaterThan(nw_dist, 0, epsilon_rep) && FloatGreaterThan(sum_of_weights, 0, epsilon_rep)) {
	nw_weight = 1/nw_dist / sum_of_weights; 
      }
      if(FloatGreaterThan(sw_dist, 0, epsilon_rep) && FloatGreaterThan(sum_of_weights, 0, epsilon_rep)) {
	sw_weight = 1/sw_dist / sum_of_weights; 
      }
      if(FloatGreaterThan(ne_dist, 0, epsilon_rep) && FloatGreaterThan(sum_of_weights, 0, epsilon_rep)) {
	ne_weight = 1/ne_dist / sum_of_weights; 
      }
      if(FloatGreaterThan(se_dist, 0, epsilon_rep) && FloatGreaterThan(sum_of_weights, 0, epsilon_rep)) {
	se_weight = 1/se_dist / sum_of_weights; 
      }
      
      int points_to_average = 5;
      if((FloatEqualTo(d0, missing_value, epsilon_rep)) || (FloatEqualTo(d0, ncv.fillValue, epsilon_rep))) {
	points_to_average--;
	d0 = 0;
      }
      if((FloatEqualTo(d1, missing_value, epsilon_rep)) || (FloatEqualTo(d1, ncv.fillValue, epsilon_rep))) {
	points_to_average--;
	d1 = 0;
      }
      if((FloatEqualTo(d2, missing_value, epsilon_rep)) || (FloatEqualTo(d2, ncv.fillValue, epsilon_rep))) {
	points_to_average--;
	d2 = 0;
      }
      if((FloatEqualTo(d3, missing_value, epsilon_rep)) || (FloatEqualTo(d3, ncv.fillValue, epsilon_rep))) {
	points_to_average--;
	d3 = 0;
      }
      if((FloatEqualTo(d4, missing_value, epsilon_rep)) || (FloatEqualTo(d4, ncv.fillValue, epsilon_rep))) {
	points_to_average--;
	d4 = 0;
      }

      // Linear interpolation 
      if(points_to_average > 0) {
	point_average = (d0 + d1 + d2 + d3 + d4) / points_to_average;
      }
      else {
	point_average = missing_value;
      }

      // Bilinear interpolation
      interpolated_point = (nw_weight * d1) + (sw_weight * d2) + (ne_weight * d3) + (se_weight * d4);
      if(FloatEqualTo(interpolated_point, 0, epsilon_rep) && 
	 FloatNotEqualTo(awips_grid[dataloc].data, 0, epsilon_rep)) {
	interpolated_point = awips_grid[dataloc].data;
      }

      // Remove any fill values
      if(FloatEqualTo(interpolated_point, ncv.fillValue, epsilon_rep)) interpolated_point = missing_value;
      if(FloatEqualTo(point_average, ncv.fillValue, epsilon_rep)) point_average = missing_value;

      switch(itype) {
	case NO_INTERP:
	  if(curr_point < (nx*ny)) interpolated_grid[curr_point].data = awips_grid[curr_point].data;
	  break;
	case NEAREST_INTERP:
	  if(FloatEqualTo(interpolated_grid[loc1].data, missing_value)) 
	    interpolated_grid[loc1].data = awips_grid[dataloc].data;
	  if(FloatEqualTo(interpolated_grid[loc2].data, missing_value)) 
	    interpolated_grid[loc2].data = awips_grid[dataloc].data;
	  if(FloatEqualTo(interpolated_grid[loc3].data, missing_value)) 
	    interpolated_grid[loc3].data = awips_grid[dataloc].data;
	  if(FloatEqualTo(interpolated_grid[loc4].data, missing_value)) 
	    interpolated_grid[loc4].data = awips_grid[dataloc].data;
	  if(FloatEqualTo(interpolated_grid[loc5].data, missing_value)) 
	    interpolated_grid[loc5].data = awips_grid[dataloc].data;
	  if(FloatEqualTo(interpolated_grid[loc6].data, missing_value)) 
	    interpolated_grid[loc6].data = awips_grid[dataloc].data;
	  if(FloatEqualTo(interpolated_grid[loc7].data, missing_value)) 
	    interpolated_grid[loc7].data = awips_grid[dataloc].data;
	  if(FloatEqualTo(interpolated_grid[loc8].data, missing_value)) 
	    interpolated_grid[loc8].data = awips_grid[dataloc].data;
	  if(FloatEqualTo(interpolated_grid[loc9].data, missing_value)) 
	    interpolated_grid[loc9].data = awips_grid[dataloc].data;
	  if(FloatEqualTo(interpolated_grid[loc10].data, missing_value)) 
	    interpolated_grid[loc10].data = awips_grid[dataloc].data;
	  break;

	case LINEAR_INTERP:
	  if(FloatEqualTo(interpolated_grid[loc1].data, missing_value)) 
	    interpolated_grid[loc1].data = point_average;
	  if(FloatEqualTo(interpolated_grid[loc2].data, missing_value)) 
	    interpolated_grid[loc2].data = point_average;
	  if(FloatEqualTo(interpolated_grid[loc3].data, missing_value)) 
	    interpolated_grid[loc3].data = point_average;
	  if(FloatEqualTo(interpolated_grid[loc4].data, missing_value)) 
	    interpolated_grid[loc4].data = point_average;
	  if(FloatEqualTo(interpolated_grid[loc5].data, missing_value)) 
	    interpolated_grid[loc5].data = point_average;
	  if(FloatEqualTo(interpolated_grid[loc6].data, missing_value)) 
	    interpolated_grid[loc6].data = point_average;
	  if(FloatEqualTo(interpolated_grid[loc7].data, missing_value)) 
	    interpolated_grid[loc7].data = point_average;
	  if(FloatEqualTo(interpolated_grid[loc8].data, missing_value)) 
	    interpolated_grid[loc8].data = point_average;
	  if(FloatEqualTo(interpolated_grid[loc9].data, missing_value)) 
	    interpolated_grid[loc9].data = point_average;
	  if(FloatEqualTo(interpolated_grid[loc10].data, missing_value)) 
	    interpolated_grid[loc10].data = point_average;
	  break;

	case BILINEAR_INTERP:
	  if(FloatEqualTo(interpolated_grid[loc1].data, missing_value)) 
	    interpolated_grid[loc1].data = interpolated_point;
	  if(FloatEqualTo(interpolated_grid[loc2].data, missing_value)) 
	    interpolated_grid[loc2].data = interpolated_point;
	  if(FloatEqualTo(interpolated_grid[loc3].data, missing_value)) 
	    interpolated_grid[loc3].data = interpolated_point;
	  if(FloatEqualTo(interpolated_grid[loc4].data, missing_value)) 
	    interpolated_grid[loc4].data = interpolated_point;
	  if(FloatEqualTo(interpolated_grid[loc5].data, missing_value)) 
	    interpolated_grid[loc5].data = interpolated_point;
	  if(FloatEqualTo(interpolated_grid[loc6].data, missing_value)) 
	    interpolated_grid[loc6].data = interpolated_point;
	  if(FloatEqualTo(interpolated_grid[loc7].data, missing_value)) 
	    interpolated_grid[loc7].data = interpolated_point;
	  if(FloatEqualTo(interpolated_grid[loc8].data, missing_value)) 
	    interpolated_grid[loc8].data = interpolated_point;
	  if(FloatEqualTo(interpolated_grid[loc9].data, missing_value)) 
	    interpolated_grid[loc9].data = interpolated_point;
	  if(FloatEqualTo(interpolated_grid[loc10].data, missing_value)) 
	    interpolated_grid[loc10].data = interpolated_point;
	  break;

	case REMAPTEST_INTERP:
	  // Special testing mode used for viewing remapped grid points
	  if(FloatEqualTo(interpolated_grid[loc1].data, missing_value)) interpolated_grid[loc1].data = 5;
	  if(FloatEqualTo(interpolated_grid[loc2].data, missing_value)) interpolated_grid[loc2].data = 5;
	  if(FloatEqualTo(interpolated_grid[loc3].data, missing_value)) interpolated_grid[loc3].data = 5;
	  if(FloatEqualTo(interpolated_grid[loc4].data, missing_value)) interpolated_grid[loc4].data = 5;
	  if(FloatEqualTo(interpolated_grid[loc5].data, missing_value)) interpolated_grid[loc5].data = 5;
	  if(FloatEqualTo(interpolated_grid[loc6].data, missing_value)) interpolated_grid[loc6].data = 5;
	  if(FloatEqualTo(interpolated_grid[loc7].data, missing_value)) interpolated_grid[loc7].data = 5;
	  if(FloatEqualTo(interpolated_grid[loc8].data, missing_value)) interpolated_grid[loc8].data = 5;
	  if(FloatEqualTo(interpolated_grid[loc9].data, missing_value)) interpolated_grid[loc9].data = 5;
	  if(FloatEqualTo(interpolated_grid[loc10].data, missing_value)) interpolated_grid[loc10].data = 5;
	  break;

	default: // Default to nearest neighbor interploation
	  if(FloatEqualTo(interpolated_grid[loc1].data, missing_value)) 
	    interpolated_grid[loc1].data = awips_grid[dataloc].data;
	  if(FloatEqualTo(interpolated_grid[loc2].data, missing_value)) 
	    interpolated_grid[loc2].data = awips_grid[dataloc].data;
	  if(FloatEqualTo(interpolated_grid[loc3].data, missing_value)) 
	    interpolated_grid[loc3].data = awips_grid[dataloc].data;
	  if(FloatEqualTo(interpolated_grid[loc4].data, missing_value)) 
	    interpolated_grid[loc4].data = awips_grid[dataloc].data;
	  if(FloatEqualTo(interpolated_grid[loc5].data, missing_value)) 
	    interpolated_grid[loc5].data = awips_grid[dataloc].data;
	  if(FloatEqualTo(interpolated_grid[loc6].data, missing_value)) 
	    interpolated_grid[loc6].data = awips_grid[dataloc].data;
	  if(FloatEqualTo(interpolated_grid[loc7].data, missing_value)) 
	    interpolated_grid[loc7].data = awips_grid[dataloc].data;
	  if(FloatEqualTo(interpolated_grid[loc8].data, missing_value)) 
	    interpolated_grid[loc8].data = awips_grid[dataloc].data;
	  if(FloatEqualTo(interpolated_grid[loc9].data, missing_value)) 
	    interpolated_grid[loc9].data = awips_grid[dataloc].data;
	  if(FloatEqualTo(interpolated_grid[loc10].data, missing_value)) 
	    interpolated_grid[loc10].data = awips_grid[dataloc].data;
	  break;
      }
      curr_point++;
    }
  }

  return 1;
}
// ----------------------------------------------------------- //
// ------------------------------- //
// --------- End of File --------- //
// ------------------------------- //

// ------------------------------- //
// -------- Start of File -------- //
// ------------------------------- //
// ----------------------------------------------------------- // 
// C++ Source Code File
// Compiler Used: MSVC, GCC
// Produced By: Douglas.Gaer@noaa.gov
// Projection Algorithms By: Thomas.J.Lefebvre@noaa.gov Mike.Romberg@noaa.gov
// File Creation Date: 06/14/2011
// Date Last Modified: 04/18/2013
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

Projection libraries used to re-project AWIPS grids.

*/
// ----------------------------------------------------------- // 

#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#include "projection_cpp_lib.h"

Projection::~Projection() 
{ 
  DeleteLatLonArrays();
}

void Projection::DeleteLatLonArrays() {
  if(point_data) {
    delete[]point_data;
    point_data = 0;
  }
}

void Projection::Reset() 
{
  memset(proj_name, 0 , sizeof(proj_name));
  memset(grid_name, 0 , sizeof(grid_name));
  pi = PI_DEF;
  n = F = rhoOrigin = minLat = maxLat = minLon = maxLon = 0;
  minX = minY = maxX = maxY = xGridsPerRad = yGridsPerRad = 0;
  stdParallel_1 = stdParallel_2 = 0;
  lonOrigin = 0;
  lonCenter = 0;
  deltaX = deltaY = 0;
  grid_spacing = 0;
}

void Projection::latLonToGrid(AWIPSdomain &domain, float lat, float lon, int &x, int &y)
{
  float xwc, ywc;
  latLonToAWIPS(lat, lon, xwc, ywc);
  x = int(((xwc - domain.origin[0]) / domain.extent[0] * (domain.gridSize[0] - 1)) + 0.5);
  y = int(((ywc - domain.origin[1]) / domain.extent[1] * (domain.gridSize[1] - 1)) + 0.5);
}

void Projection::AWIPSDomainToLatLon(AWIPSdomain &domain)
{
  int x = 0;
  int y = 0;
  float lat, lon;

  DeleteLatLonArrays();

  unsigned numpoints = (unsigned)(domain.gridSize[0] * domain.gridSize[1]);
  point_data = new PointData[numpoints];

  unsigned nx = (unsigned)domain.gridSize[0];
  unsigned ny = (unsigned)domain.gridSize[1];

  // Map the AWIPS grid
  unsigned curr_point_number = 0;
  for(x = 0; x < (int)nx; x++) {
    for(y = 0; y < (int)ny; y++) {
      float awipsX = (x * domain.extent[0] / (domain.gridSize[0] - 1)) + domain.origin[0];
      float awipsY = (y * domain.extent[1] / (domain.gridSize[1] - 1)) + domain.origin[1];
      AWIPSToLatLon(awipsX, awipsY, lat, lon);
      point_data[curr_point_number].lat = lat;
      point_data[curr_point_number].lon = lon;
      point_data[curr_point_number].x = x;
      point_data[curr_point_number].y = y;
      point_data[curr_point_number].grid_point_number = curr_point_number;
      point_data[curr_point_number].data = 0;
      curr_point_number++;
    }
  }

  float lat_min = point_data[0].lat;
  float lon_min = point_data[0].lon;
  float lat_max = point_data[numpoints-1].lat;
  float lon_max = point_data[numpoints-1].lon;

  // AWIPS projected resolution
  domain.awips_resolution_x_deg = domain.extent[0] / (domain.gridSize[0] - 1);
  domain.awips_resolution_y_deg = domain.extent[1] / (domain.gridSize[1] - 1);

  unsigned lower_right_point = numpoints - domain.gridSize[1];
  unsigned upper_right_point = numpoints -1;
  unsigned lower_left_point = 0;
  unsigned upper_left_point = domain.gridSize[1]-1;

  // AWIPS projected corner points
  domain.upper_left = point_data[upper_left_point];
  domain.lower_right = point_data[lower_right_point];
  domain.upper_right = point_data[upper_right_point];
  domain.lower_left = point_data[lower_left_point];

  unsigned i;
  for(i = 0; i < numpoints; i++) {
    if(FloatGreaterThan(point_data[i].lat, lat_max)) lat_max = point_data[i].lat;  
    if(FloatLessThan(point_data[i].lat, lat_min)) lat_min = point_data[i].lat;
    if(FloatGreaterThan(point_data[i].lon, lon_max)) lon_max = point_data[i].lon;
    if(FloatLessThan(point_data[i].lon, lon_min)) lon_min = point_data[i].lon;
  }

  // LATLON corner points
  domain.NORTHEASTLAT = lat_max;
  domain.NORTHEASTLON = lon_max;
  domain.SOUTHWESTLAT = lat_min;
  domain.SOUTHWESTLON = lon_min;

  domain.NUMMESHESLAT = domain.gridSize[1] - 1;
  domain.NUMMESHESLON = domain.gridSize[0] - 1;

  float nelat_temp = domain.NORTHEASTLAT;
  float swlat_temp = domain.SOUTHWESTLAT;
  if(FloatLessThan(nelat_temp, 0)) nelat_temp -= nelat_temp*2;
  if(FloatLessThan(swlat_temp, 0)) swlat_temp -= swlat_temp*2;
  domain.NSD = nelat_temp - swlat_temp; 
  domain.NSR = domain.NSD/domain.NUMMESHESLAT;
  
  float nelon_temp = domain.NORTHEASTLON;
  float swlon_temp = domain.SOUTHWESTLON;
  if(FloatLessThan(nelon_temp, 0)) nelon_temp -= nelon_temp*2;
  if(FloatLessThan(swlon_temp, 0)) swlon_temp -= swlon_temp*2;
  domain.EWD = swlon_temp  - nelon_temp;
  domain.EWR = domain.EWD/domain.NUMMESHESLON;

  domain.awips_resolution_x_km = domain.awips_resolution_x_deg * grid_spacing;
  domain.awips_resolution_y_km = domain.awips_resolution_y_deg * grid_spacing;
}

LambertConformal::~LambertConformal() 
{ 

}

void LambertConformal::SetValues() 
{
  pi = PI_DEF;
  float denominator;
  float numerator;
  
  if(FloatNotEqualTo(stdParallel_1, stdParallel_2)) {
    numerator = log(cos(stdParallel_1 * DEG_TO_RAD) / cos(stdParallel_2 * DEG_TO_RAD));
    denominator = log(tan(pi/4 + stdParallel_2 * DEG_TO_RAD/2) / tan(pi/4 + stdParallel_1 * DEG_TO_RAD/2));
    n = numerator / denominator;
  }
  else {
    n = sin(stdParallel_1 * DEG_TO_RAD);
  }
  
  F = cos(stdParallel_1 * DEG_TO_RAD) * pow(tan(pi/4 + stdParallel_1 * DEG_TO_RAD/2), n) / n;
  rhoOrigin = F / pow(tan(pi/4 + latLonOrigin[1] * DEG_TO_RAD/2), n);
  minLat = latLonLL[1];
  maxLat = latLonUR[1];
  minLon = latLonLL[0];
  maxLon = latLonUR[0];
  latLonToXY(latLonLL[1], latLonLL[0], minX, minY);
  latLonToXY(latLonUR[1], latLonUR[0], maxX, maxY);
  xGridsPerRad = (gridPointUR[0] - gridPointLL[0]) / (maxX - minX);
  yGridsPerRad = (gridPointUR[1] - gridPointLL[1]) / (maxY - minY);
}

void LambertConformal::latLonToXY(float lat, float lon, float &x, float &y) 
{
  float rho = F / pow(tan(pi/4 + lat * DEG_TO_RAD/2), n);
  
  // Calculate polar coordinate for minLat, minLon
  float theta = n * (lon - latLonOrigin[0]);
  
  // Compute x, y
  x = rho * sin(theta * DEG_TO_RAD);
  y = rhoOrigin - rho * cos(theta * DEG_TO_RAD);
}

void LambertConformal::Print() 
{
  std::cout << "Projection name = " << proj_name << "\n";
  if(grid_name[0] != 0) std::cout << "Grid name = " << grid_name << "\n";
  std::cout << "latLonLL = " << latLonLL[0] << "," << latLonLL[1] << "\n";
  std::cout << "latLonUR = " << latLonUR[0] << "," << latLonUR[1] << "\n";
  std::cout << "latLonOrigin = " << latLonOrigin[0] << "," << latLonOrigin[1] << "\n";
  std::cout << "stdParallel_1 = " << stdParallel_1 << "\n";
  std::cout << "stdParallel_2 = " << stdParallel_2 << "\n";
  std::cout << "gridPointLL = " << gridPointLL[0] << "," << gridPointLL[1] << "\n";
  std::cout << "gridPointUR = " << gridPointUR[0] << "," << gridPointUR[1] << "\n";
  std::cout << "poleCoord = " << poleCoord[0] << "," << poleCoord[1] << "\n";
  std::cout << "pi = " << pi << "\n";
  std::cout << "n = " << n << "\n";
  std::cout << "F = " << F << "\n";
  std::cout << "rhoOrigin = " << rhoOrigin << "\n";
  std::cout << "minLat = " << minLat << "\n";
  std::cout << "maxLat = " << maxLat << "\n";
  std::cout << "minLon = " << minLon << "\n";
  std::cout << "maxLon = " << maxLon << "\n";
  std::cout << "minX = " << minX << "\n";
  std::cout << "minY = " << minY << "\n";
  std::cout << "maxX = " << maxX << "\n";
  std::cout << "maxY = " << maxY << "\n";
  std::cout << "xGridsPerRad = " << xGridsPerRad << "\n";
  std::cout << "yGridsPerRad = " << yGridsPerRad << "\n";
}

void LambertConformal::AWIPSToLatLon(float xwc, float ywc, float &lat, float &lon) 
{
  float x = ((xwc - gridPointLL[0]) / xGridsPerRad) + minX;
  float y = ((ywc - gridPointLL[1]) / yGridsPerRad) + minY;
  float p = sqrt(pow(x, 2.0) + pow((rhoOrigin - y), 2));
  float theta = atan(x / (rhoOrigin - y));
  lon = theta / n + latLonOrigin[0] * DEG_TO_RAD;
  lat = 2 * atan(pow((F / p), 1 / n)) - pi / 2;
  lat *= RAD_TO_DEG;
  lon *= RAD_TO_DEG;
}

void LambertConformal::latLonToAWIPS(float lat, float lon, float &xwc, float &ywc)
{
  float x, y;
  latLonToXY(lat, lon, x, y);
  xwc = gridPointLL[0] + (x - minX) * xGridsPerRad;
  ywc = gridPointLL[1] + (y - minY) * yGridsPerRad;
}

PolarStereographic::~PolarStereographic() 
{ 

}

void PolarStereographic::SetValues() 
{
  pi = PI_DEF;
  minLat = latLonLL[1];
  maxLat = latLonUR[1];
  minLon = latLonLL[0];
  maxLon = latLonUR[0];
  latLonToXY(latLonLL[1], latLonLL[0], minX, minY);
  latLonToXY(latLonUR[1], latLonUR[0], maxX, maxY);
  xGridsPerRad = (gridPointUR[0] - gridPointLL[0]) / (maxX - minX);
  yGridsPerRad = (gridPointUR[1] - gridPointLL[1]) / (maxY - minY);
}

void PolarStereographic::latLonToXY(float lat, float lon, float &x, float &y)
{
  x = 2 * tan(pi/4.0 - lat * DEG_TO_RAD / 2.0) * sin(lon * DEG_TO_RAD - lonOrigin * DEG_TO_RAD);
  y = -2 * tan(pi/4.0 - lat * DEG_TO_RAD / 2.0) * cos(lon * DEG_TO_RAD - lonOrigin * DEG_TO_RAD);
}

void PolarStereographic::latLonToAWIPS(float lat, float lon, float &xwc, float &ywc)
{
  while(FloatLessThan(lon, minLon)) {
    lon += 360.0;
  }	
  while(FloatGreaterThan(lon, maxLon)) {
    lon -= 360.0;
  }
  lon = lon * DEG_TO_RAD;
  lat = lat * DEG_TO_RAD;

  float x = 2 * tan(pi / 4 - lat / 2) * sin(lon - lonOrigin * DEG_TO_RAD);
  float y = -2 * tan(pi / 4 - lat / 2) * cos(lon - lonOrigin * DEG_TO_RAD);

  xwc = gridPointLL[0] + (x - minX) * xGridsPerRad;
  ywc = gridPointLL[1] + (y - minY) * yGridsPerRad;
}

void PolarStereographic::AWIPSToLatLon(float xwc, float ywc, float &lat, float &lon)
{
  float x = ((xwc - gridPointLL[0]) / xGridsPerRad) + minX;
  float y = ((ywc - gridPointLL[1]) / yGridsPerRad) + minY;

  lon = (lonOrigin * DEG_TO_RAD + atan2(x, -y)) * RAD_TO_DEG;
  lat = (asin(cos(2 * atan2(sqrt(x * x + y * y) , 2)))) * RAD_TO_DEG;
}

void PolarStereographic::Print() 
{
  std::cout << "Projection name = " << proj_name << "\n";
  if(grid_name[0] != 0) std::cout << "Grid name = " << grid_name << "\n";
  std::cout << "latLonLL = " << latLonLL[0] << "," << latLonLL[1] << "\n";
  std::cout << "latLonUR = " << latLonUR[0] << "," << latLonUR[1] << "\n";
  std::cout << "gridPointLL = " << gridPointLL[0] << "," << gridPointLL[1] << "\n";
  std::cout << "gridPointUR = " << gridPointUR[0] << "," << gridPointUR[1] << "\n";
  std::cout << "lonOrigin = " << lonOrigin << "\n";
  std::cout << "poleCoord = " << poleCoord[0] << "," << poleCoord[1] << "\n";
  std::cout << "pi = " << pi << "\n";
  std::cout << "minLat = " << minLat << "\n";
  std::cout << "maxLat = " << maxLat << "\n";
  std::cout << "minLon = " << minLon << "\n";
  std::cout << "maxLon = " << maxLon << "\n";
  std::cout << "minX = " << minX << "\n";
  std::cout << "minY = " << minY << "\n";
  std::cout << "maxX = " << maxX << "\n";
  std::cout << "maxY = " << maxY << "\n";
  std::cout << "xGridsPerRad = " << xGridsPerRad << "\n";
  std::cout << "yGridsPerRad = " << yGridsPerRad << "\n";
}

Mercator::~Mercator() 
{ 

}

void Mercator::SetValues() 
{
  pi = PI_DEF;
  minLat = latLonLL[1];
  maxLat = latLonUR[1];
  minLon = latLonLL[0];
  maxLon = latLonUR[0];
  latLonToXY(latLonLL[1], latLonLL[0], minX, minY);
  latLonToXY(latLonUR[1], latLonUR[0], maxX, maxY);
  xGridsPerRad = (gridPointUR[0] - gridPointLL[0]) / (maxX - minX);
  yGridsPerRad = (gridPointUR[1] - gridPointLL[1]) / (maxY - minY);
}

void Mercator::latLonToXY(float lat, float lon, float &x, float &y)
{
  x = lon * DEG_TO_RAD - lonCenter * DEG_TO_RAD;
  y = log(tan(pi / 4 + lat * DEG_TO_RAD / 2));
}

void Mercator::latLonToAWIPS(float lat, float lon, float &xwc, float &ywc)
{
  lon = lon * DEG_TO_RAD;
  lat = lat * DEG_TO_RAD;
  float x = lon - lonCenter * DEG_TO_RAD;
  float y = log(tan(pi / 4 + lat / 2));
  xwc = gridPointLL[0] + (x - minX) * xGridsPerRad;
  ywc = gridPointLL[1] + (y - minY) * yGridsPerRad;
}

void Mercator::AWIPSToLatLon(float xwc, float ywc, float &lat, float &lon)
{
  float x = ((xwc - gridPointLL[0]) / xGridsPerRad) + minX;
  float y = ((ywc - gridPointLL[1]) / yGridsPerRad) + minY;

  lat = 2 * atan(exp(y)) - pi / 2;
  lon = x + lonCenter * DEG_TO_RAD;

  lat *= RAD_TO_DEG;
  lon *= RAD_TO_DEG;
}

void Mercator::Print() 
{
  std::cout << "Projection name = " << proj_name << "\n";
  if(grid_name[0] != 0) std::cout << "Grid name = " << grid_name << "\n";
  std::cout << "latLonLL = " << latLonLL[0] << "," << latLonLL[1] << "\n";
  std::cout << "latLonUR = " << latLonUR[0] << "," << latLonUR[1] << "\n";
  std::cout << "gridPointLL = " << gridPointLL[0] << "," << gridPointLL[1] << "\n";
  std::cout << "gridPointUR = " << gridPointUR[0] << "," << gridPointUR[1] << "\n";
  std::cout << "lonCenter = " << lonCenter << "\n";
  std::cout << "pi = " << pi << "\n";
  std::cout << "minLat = " << minLat << "\n";
  std::cout << "maxLat = " << maxLat << "\n";
  std::cout << "minLon = " << minLon << "\n";
  std::cout << "maxLon = " << maxLon << "\n";
  std::cout << "minX = " << minX << "\n";
  std::cout << "minY = " << minY << "\n";
  std::cout << "maxX = " << maxX << "\n";
  std::cout << "maxY = " << maxY << "\n";
  std::cout << "xGridsPerRad = " << xGridsPerRad << "\n";
  std::cout << "yGridsPerRad = " << yGridsPerRad << "\n";
}

LatLon::~LatLon()
{


}

void LatLon::SetValues() 
{
  if(FloatLessThan(latLonUR[0], latLonLL[0])) {
    maxLon = latLonUR[0] + 360.0;
  }
  else {
    maxLon = latLonUR[0];
  }

  minLat = latLonLL[1];
  maxLat = latLonUR[1];
  minLon = latLonLL[0];

  deltaX = (maxLon - latLonLL[0]) / (gridPointUR[0] - gridPointLL[0]);
  deltaY = (latLonUR[1] - latLonLL[1]) / (gridPointUR[1] - gridPointLL[1]);
}

void LatLon::latLonToAWIPS(float lat, float lon, float &xwc, float &ywc)
{
  while(FloatLessThan(lon, latLonLL[0])) {
    lon = lon + 360.0;
  }
  while(FloatGreaterThan(lon, maxLon)) {
    lon = lon - 360.0;
  }
  
  ywc = (lat - latLonLL[1]) / deltaY + gridPointLL[1];
  xwc = (lon - latLonLL[0]) / deltaX + gridPointLL[0];
}

void LatLon::Print() 
{
  std::cout << "Projection name = " << proj_name << "\n";
  if(grid_name[0] != 0) std::cout << "Grid name = " << grid_name << "\n";
  std::cout << "latLonLL = " << latLonLL[0] << "," << latLonLL[1] << "\n";
  std::cout << "latLonUR = " << latLonUR[0] << "," << latLonUR[1] << "\n";
  std::cout << "gridPointLL = " << gridPointLL[0] << "," << gridPointLL[1] << "\n";
  std::cout << "gridPointUR = " << gridPointUR[0] << "," << gridPointUR[1] << "\n";
  std::cout << "maxLon = " << maxLon << "\n";
  std::cout << "deltaX = " << deltaX << "\n";
  std::cout << "deltaY = " << deltaY << "\n";
}

void LatLon::AWIPSToLatLon(float xwc, float ywc, float &lat, float &lon)
{
  lat = latLonLL[1] + ((ywc - gridPointLL[1]) *	deltaY);
  lon = latLonLL[0] + ((xwc - gridPointLL[0]) *	deltaX);

  while(FloatGreaterThan(lon, 180.0)) {
    lon = lon - 360.0;
  }
  while(FloatLessThan(lon, -180.0)) {
    lon = lon + 360.0;
  }
}

void LatLon::latLonToXY(float lat, float lon, float &x, float &y)
{
  x = y = 0;
  // NOTE: This function is not used but must be define to 
  // NOTE: override pure virtual base class function.
}

void AWIPSdomain::Reset() 
{
  NUMMESHESLAT = 0;
  NUMMESHESLON = 0;
  NORTHEASTLAT = 0;
  NORTHEASTLON = 0;
  SOUTHWESTLAT = 0;
  SOUTHWESTLON = 0;
  NSD = 0;
  NSR = 0;
  EWD = 0;
  EWR = 0;
  upper_left.Reset();
  lower_right.Reset();
  upper_right.Reset();
  lower_left.Reset();
  awips_resolution_x_km = 0;
  awips_resolution_y_km = 0;
  awips_resolution_x_deg = 0;
  awips_resolution_y_deg = 0;
  diff_upper_lat = 0;
  diff_lower_lat = 0;
  diff_upper_lon = 0;
  diff_lower_lon = 0;
  ny_extra_points = 0;
  nx_extra_points = 0;
}

void AWIPSdomain::Print() 
{
  std::cout << "AWIPS projected grid info:" << "\n";
  std::cout << "AWIPS x resolution = " << awips_resolution_x_km << "\n";
  std::cout << "AWIPS y resolution = " << awips_resolution_y_km << "\n";
  std::cout << "AWIPS upper left = " << upper_left.lat << "/" << upper_left.lon << "\n";
  std::cout << "AWIPS lower right = " << lower_right.lat << "/" << lower_right.lon << "\n";
  std::cout << "AWIPS upper right = " << upper_right.lat << "/" << upper_right.lon << "\n";
  std::cout << "AWIPS lower left = " << lower_left.lat << "/" << lower_left.lon << "\n";
  std::cout << "\n";
  std::cout << "LATLON re-projected grid info:" << "\n";
  std::cout << "NUMMESHESLAT = " << NUMMESHESLAT << "\n";
  std::cout << "NUMMESHESLON = " << NUMMESHESLON << "\n";
  std::cout << "NORTHEASTLAT = " << NORTHEASTLAT << "\n";
  std::cout << "NORTHEASTLON = " << NORTHEASTLON << "\n";
  std::cout << "SOUTHWESTLAT = " << SOUTHWESTLAT << "\n";
  std::cout << "SOUTHWESTLON = " << SOUTHWESTLON << "\n";
  std::cout << "NORTH-SOUTH DEGREES = " << NSD << "\n";
  std::cout << "NORTH-SOUTH RESOLUTION = " << NSR << "\n";
  std::cout << "EAST-WEST DEGREES = " << EWD << "\n";
  std::cout << "EAST-WEST RESOLUTION = " << EWR << "\n";
}
// ----------------------------------------------------------- //
// ------------------------------- //
// --------- End of File --------- //
// ------------------------------- //

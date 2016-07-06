// ------------------------------- //
// -------- Start of File -------- //
// ------------------------------- //
// ---------------------------------------------------------------- // 
// C++ Header File
// C++ Compiler Used: MSVC, GCC
// Produced By: Douglas.Gaer@noaa.gov
// Projection Algorithms By: Thomas.J.Lefebvre@noaa.gov Mike.Romberg@noaa.gov
// File Creation Date: 06/14/2011
// Date Last Modified: 04/18/2013
// ---------------------------------------------------------------- // 
// ------------- Include File Description and Details ------------- // 
// ---------------------------------------------------------------- // 
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
#ifndef __M_PROJECTION_CPP_LIB_HPP__
#define __M_PROJECTION_CPP_LIB_HPP__

#include "projection_utils.h"

struct AWIPSdomain 
{
  AWIPSdomain() { Reset(); }
  AWIPSdomain(CoordPair org, CoordPair ext, CoordPair gsize) { 
    Set(org, ext, gsize); 
  }

  void Set(CoordPair org, CoordPair ext, CoordPair gsize) {
    origin = org;
    extent = ext;
    gridSize = gsize;
    Reset();
  }
  void Print(); 
  void Reset(); 

  // AWIPS Projected Grid
  CoordPair origin;
  CoordPair extent;
  CoordPair gridSize;

  // Projected grid corner points
  PointData upper_left;
  PointData lower_right;
  PointData upper_right;
  PointData lower_left;
  float awips_resolution_x_km;
  float awips_resolution_y_km;
  float awips_resolution_x_deg;
  float awips_resolution_y_deg;
  float diff_upper_lat;
  float diff_lower_lat;
  float diff_upper_lon;
  float diff_lower_lon;
  float ny_extra_points;
  float nx_extra_points;

  // Re-projected LAT/LOT Grid
  float NUMMESHESLAT;
  float NUMMESHESLON;
  float NORTHEASTLAT;
  float NORTHEASTLON;
  float SOUTHWESTLAT;
  float SOUTHWESTLON;
  float NSD; // NORTH-SOUTH DEGREES
  float NSR; // NORTH-SOUTH RESOLUTION
  float EWD; // EAST-WEST DEGREES
  float EWR; // EAST-WEST RESOLUTION
};

struct Projection
{
  Projection() { point_data = 0; }
  virtual ~Projection();

  void Reset();
  void AWIPSDomainToLatLon(AWIPSdomain &domain);
  void latLonToGrid(AWIPSdomain &domain, float lat, float lon, int &x, int &y);
  void DeleteLatLonArrays();

  virtual void SetValues() = 0;
  virtual void latLonToXY(float lat, float lon, float &x, float &y) = 0;
  virtual void Print() = 0; 
  virtual void AWIPSToLatLon(float xwc, float ywc, float &lat, float &lon) = 0; 
  virtual void latLonToAWIPS(float lat, float lon, float &xwc, float &ywc) = 0;
  
  char proj_name[255];
  char grid_name[255];
  CoordPair latLonLL;
  CoordPair latLonUR;
  CoordPair latLonOrigin;
  float stdParallel_1;
  float stdParallel_2;
  CoordPair gridPointLL;
  CoordPair gridPointUR;
  CoordPair poleCoord;
  float pi;
  float n;
  float F;
  float rhoOrigin; // Radius of the Earth origin
  float minLat;
  float maxLat;
  float minLon;
  float maxLon;
  float minX, minY;
  float maxX, maxY;
  float xGridsPerRad;
  float yGridsPerRad;
  float lonOrigin; // Polar
  float lonCenter; // Mercator
  float deltaX; // LatLon
  float deltaY; // LatLon
  PointData *point_data;
  float grid_spacing; // Grid spacing in KM
};

struct LambertConformal : public Projection
{
  LambertConformal() {   
    strncpy(proj_name, "LAMBERT_CONFORMAL", (sizeof(proj_name)-1)); 
  }
  virtual ~LambertConformal();

  void SetValues();
  void latLonToXY(float lat, float lon, float &x, float &y);
  void Print(); 
  void AWIPSToLatLon(float xwc, float ywc, float &lat, float &lon); 
  void latLonToAWIPS(float lat, float lon, float &xwc, float &ywc);
};

struct PolarStereographic  : public Projection
{
  PolarStereographic() { 
    strncpy(proj_name, "POLAR_STEREOGRAPHIC", (sizeof(proj_name)-1));
  }
  virtual ~PolarStereographic();

  void SetValues();
  void latLonToXY(float lat, float lon, float &x, float &y);
  void Print();
  void AWIPSToLatLon(float xwc, float ywc, float &lat, float &lon);
  void latLonToAWIPS(float lat, float lon, float &xwc, float &ywc);
};

struct Mercator : public Projection
{
  Mercator() { 
    strncpy(proj_name, "MERCATOR", (sizeof(proj_name)-1));
  }
  virtual ~Mercator();

  void SetValues();
  void latLonToXY(float lat, float lon, float &x, float &y);
  void Print();
  void AWIPSToLatLon(float xwc, float ywc, float &lat, float &lon);
  void latLonToAWIPS(float lat, float lon, float &xwc, float &ywc);
};

struct LatLon : public Projection
{
  LatLon() { 
    strncpy(proj_name, "LATLON", (sizeof(proj_name)-1));
  }
  virtual ~LatLon();

  void SetValues();
  void latLonToXY(float lat, float lon, float &x, float &y);
  void Print();
  void AWIPSToLatLon(float xwc, float ywc, float &lat, float &lon);
  void latLonToAWIPS(float lat, float lon, float &xwc, float &ywc);
};

#endif // __M_PROJECTION_CPP_LIB_HPP__
// ----------------------------------------------------------- //
// ------------------------------- //
// --------- End of File --------- //
// ------------------------------- //

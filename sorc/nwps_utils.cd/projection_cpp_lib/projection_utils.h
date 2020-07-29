// ------------------------------- //
// -------- Start of File -------- //
// ------------------------------- //
// ---------------------------------------------------------------- // 
// C++ Header File
// C++ Compiler Used: MSVC, GCC
// Produced By: Douglas.Gaer@noaa.gov
// File Creation Date: 06/14/2011
// Date Last Modified: 08/17/2011
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

Utils used with projection libraries.

*/
// ----------------------------------------------------------- // 
#ifndef __M_PROJECTION_UTILS_HPP__
#define __M_PROJECTION_UTILS_HPP__

#include <math.h>

// Global constants 
const float PI_DEF = atan(1)*4;
const float RAD_TO_DEG = 360.0 / 2.0 / PI_DEF;
const float DEG_TO_RAD = 1 / RAD_TO_DEG;

struct CoordPair 
{
  CoordPair() { Reset(); }
  CoordPair(float v1, float v2) { Set(v1, v2); }
  CoordPair(const CoordPair &ob) { Copy(ob); }
  CoordPair &operator=(const CoordPair &ob);

  void Copy(const CoordPair &ob) { f[0] = ob.f[0]; f[1] = ob.f[1]; }
  void Set(float v1, float v2) { f[0] = v1; f[1] = v2; }
  void Reset() { f[0] = 0.0; f[1] = 0.0; }

  // Overloaded operators
  float &operator[](unsigned i);
  const float &operator[](unsigned i) const;
  int operator==(const CoordPair &ob);

  float f[2];
};

struct PointData
{
  PointData() { Reset(); }
  ~PointData() { }
  PointData(const PointData &ob) { Copy(ob); }
  PointData &operator=(const PointData &ob);

  // Overloaded operators
  int operator==(const PointData &ob);
  int operator!=(const PointData &ob);
  int operator<(const PointData &ob);
  int operator>(const PointData &ob);

  void Copy(const PointData &ob);
  void Reset();

  float lat, lon;
  unsigned x, y;
  unsigned grid_point_number;
  float data;
};

// Compiler independent floating point functions
void SplitFloat(double fval, int &i_rep, int &f_rep, int epsilon_rep = 0);
int FloatCompare(double a, double b, int epsilon_rep = 0);
int FloatCompare(float a, float b, int epsilon_rep = 0);
int FloatEqualTo(float a, float b, int epsilon_rep = 0);
int FloatNotEqualTo(float a, float b, int epsilon_rep = 0);
int FloatEqualToOrLessThan(float a, float b, int epsilon_rep = 0);
int FloatEqualToOrGreaterThan(float a, float b, int epsilon_rep = 0);
int FloatGreaterThan(float a, float b, int epsilon_rep = 0);
int FloatLessThan(float a, float b, int epsilon_rep = 0);
void Float2Int(double fval, int &ival, int epsilon_rep = 0, int ceil_value = 1);
void Float2Int(float fval, int &ival, int epsilon_rep = 0, int ceil_value = 1);

// LAT/LON functions for calculating distance
void LatLonDirection(double lat1, double lon1, double lat2, double lon2, char &dir);
void LatLonDirection(PointData &p1, PointData &p2, char &dir);
double LatLonDistance(double lat1, double lon1, double lat2, double lon2, char unit);
double LatLonDistance(double lat1, double lon1, double lat2, double lon2, char &dir, char unit);
double LatLonDistance(PointData &p1,PointData &p2, char unit = 'K');
double LatLonDistance(PointData &p1,PointData &p2, char &dir, char unit = 'K');

double Deg2Rad(double deg);
double Rad2Deg(double rad);

#endif // __M_PROJECTION_UTILS_HPP__
// ----------------------------------------------------------- //
// ------------------------------- //
// --------- End of File --------- //
// ------------------------------- //

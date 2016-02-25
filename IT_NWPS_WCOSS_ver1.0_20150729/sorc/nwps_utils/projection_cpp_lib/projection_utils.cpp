// ------------------------------- //
// -------- Start of File -------- //
// ------------------------------- //
// ----------------------------------------------------------- // 
// C++ Source Code File
// Compiler Used: MSVC, GCC
// Produced By: Douglas.Gaer@noaa.gov
// File Creation Date: 06/14/2011
// Date Last Modified: 08/17/2011
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

Utils used with projection libraries.

*/
// ----------------------------------------------------------- // 

#include "projection_utils.h"

CoordPair &CoordPair::operator=(const CoordPair &ob) 
{
  if(&ob != this) Copy(ob);
  return *this;
}

float &CoordPair::operator[](unsigned i) {
  if(i > 1) i = 1;
  return f[i];
}
 
const float &CoordPair::operator[](unsigned i) const {
  if(i > 1) i = 1;
  return f[i];
}

int CoordPair::operator==(const CoordPair &ob) {
  if((FloatEqualTo(f[0], ob[0])) && (FloatEqualTo(f[1], ob[1]))) return 1; 
  return 0;
}

PointData &PointData::operator=(const PointData &ob) 
{
  if(&ob != this) Copy(ob);
  return *this;
}

int PointData::operator==(const PointData &ob) 
{
  if((FloatEqualTo(lat, ob.lat)) && (FloatEqualTo(lon, ob.lon))) return 1;
  return 0;
}

int PointData::operator!=(const PointData &ob) 
{
  if((FloatNotEqualTo(lat, ob.lat, 1000)) && (FloatNotEqualTo(lon, ob.lon, 1000))) return 1;
  return 0;
}

int PointData::operator<(const PointData &ob) 
{
  if((FloatLessThan(lat, ob.lat)) && (FloatLessThan(lon, ob.lon))) return 1;
  return 0;
}

int PointData::operator>(const PointData &ob) 
{
  if((FloatGreaterThan(lat, ob.lat)) && (FloatGreaterThan(lon, ob.lon))) return 1;
  return 0;
}

void PointData::Copy(const PointData &ob) 
{
  lat = ob.lat;
  lon = ob.lon;
  x = ob.x;
  y = ob.y;
  grid_point_number = ob.grid_point_number;
  data = ob.data;
}

void PointData::Reset() 
{
  lat = lon = data = 0;
  x = y = grid_point_number = 0;
}

// Compiler independant floating point to int function
void SplitFloat(double fval, int &i_rep, int &f_rep, int epsilon_rep)
{
  if(epsilon_rep <= 0) epsilon_rep = 10;
  double param, fractpart, intpart;
  param = fval;
  fractpart = modf(param , &intpart);
  i_rep = (int)intpart;
  f_rep = ceil(fractpart*epsilon_rep);
  if(f_rep < 0) f_rep -= f_rep*2;
}

void Float2Int(double fval, int &ival, int epsilon_rep, int ceil_value)
{
  if(epsilon_rep <= 0) epsilon_rep = 10;

  double param, fractpart, intpart;
  param = fval;
  fractpart = modf(param , &intpart);

  int i_rep = (int)intpart;

  int f_rep = 0;
  if(ceil_value == 1) {
    f_rep = ceil(fractpart*epsilon_rep);
  }
  else {
    f_rep = floor(fractpart*epsilon_rep);
  }

  if(f_rep < 0) f_rep -= f_rep*2;
  ival = i_rep;
  if((f_rep >= 5) && (ival >= 0)) ival++;
  if((f_rep >= 5) && (ival < 0)) ival--;
}

void Float2Int(float fval, int &ival, int epsilon_rep, int ceil_value)
{
  Float2Int(double(fval), ival, epsilon_rep, ceil_value);
}

// Compiler independant floating point compare function
int FloatCompare(double a, double b, int epsilon_rep)
{
  if(epsilon_rep <= 0) epsilon_rep = 1000000;

  double param, fractpart, intpart;
  param = a;
  fractpart = modf(param , &intpart);

  int i_rep_a = (int)intpart;
  int f_rep_a = ceil(fractpart*epsilon_rep);

  param = b;
  fractpart = modf(param , &intpart);

  int i_rep_b = (int)intpart;
  int f_rep_b = ceil(fractpart*epsilon_rep);

  if(i_rep_a == i_rep_b) {
    if(f_rep_a == f_rep_b) return 0;
    if(f_rep_a > f_rep_b) return 1;
    if(f_rep_a < f_rep_b) return -2;
  }

  if(i_rep_a > i_rep_b) return 1;
  if(i_rep_a < i_rep_b) return -1;

  return -1;
}

int FloatCompare(float a, float b, int epsilon_rep)
{
  return FloatCompare((double)a, (double)b, epsilon_rep);
}

int FloatEqualTo(float a, float b, int epsilon_rep)
{
  return FloatCompare(a, b, epsilon_rep) == 0 ? 1 : 0;
}

int FloatEqualToOrLessThan(float a, float b, int epsilon_rep)
{
  if(FloatCompare(a, b, epsilon_rep) == 0) return 1;
  if(FloatCompare(a, b, epsilon_rep) < 0) return 1;
  return 0;
}

int FloatEqualToOrGreaterThan(float a, float b, int epsilon_rep)
{
  if(FloatCompare(a, b, epsilon_rep) == 0) return 1;
  if(FloatCompare(a, b, epsilon_rep) > 0) return 1;
  return 0;
}

int FloatGreaterThan(float a, float b, int epsilon_rep)
{
  return FloatCompare(a, b, epsilon_rep) > 0 ? 1 : 0;
}

int FloatLessThan(float a, float b, int epsilon_rep)
{
  return FloatCompare(a, b, epsilon_rep) < 0 ? 1 : 0;
}

int FloatNotEqualTo(float a, float b, int epsilon_rep) 
{
  return FloatCompare(a, b, epsilon_rep) != 0 ? 1 : 0;
}

void LatLonDirection(double lat1, double lon1, double lat2, double lon2, char &dir)
{
  dir = '\0';
  if(FloatGreaterThan(lat2, lat1)) dir = 'N';
  if(FloatLessThan(lat2, lat1)) dir = 'S';
  if(FloatGreaterThan(lon2, lon1)) dir = 'W';
  if(FloatLessThan(lon2, lon1)) dir = 'E';
}

void LatLonDirection(PointData &p1, PointData &p2, char &dir)
{
  LatLonDirection((float)p1.lat, (float)p1.lon, (float)p2.lat, (float)p2.lon, dir);
}

double LatLonDistance(PointData &p1,PointData &p2, char unit)
{
  return LatLonDistance((float)p1.lat, (float)p1.lon, (float)p2.lat, (float)p2.lon, unit);
}

double LatLonDistance(PointData &p1,PointData &p2, char &dir, char unit)
{
  double dist = LatLonDistance((float)p1.lat, (float)p1.lon, (float)p2.lat, (float)p2.lon, unit);
  LatLonDirection(p1, p2, dir);
  return dist;
}

double LatLonDistance(double lat1, double lon1, double lat2, double lon2, char &dir, char unit)
{
  double dist = LatLonDistance(lat1, lon1, lat2, lon2, unit);
  LatLonDirection(lat1, lon1, lat2, lon2, dir);
  return dist;
}

double LatLonDistance(double lat1, double lon1, double lat2, double lon2, char unit)
// This routine calculates the distance between two points (given the
// latitude/longitude of those points).
//
// South latitudes are negative, east longitudes are positive     
//
// lat1, lon1 = Latitude and Longitude of point 1 (in decimal degrees)
// lat2, lon2 = Latitude and Longitude of point 2 (in decimal degrees)
// unit = 'M' is statute miles
//        'K' is kilometers (default)
//        'N' is nautical miles
{
  double theta, dist;
  theta = lon1 - lon2;
  dist = sin(Deg2Rad(lat1)) * sin(Deg2Rad(lat2)) + cos(Deg2Rad(lat1)) * cos(Deg2Rad(lat2)) * cos(Deg2Rad(theta));
  dist = acos(dist);
  dist = Rad2Deg(dist);
  dist = dist * 60 * 1.1515;
  switch(unit) {
    case 'M': case 'm':
      break;
    case 'K': case 'k':
      dist = dist * 1.609344;
      break;
    case 'N': case 'n':
      dist = dist * 0.8684;
      break;
    default:
      dist = dist * 1.609344;
      break;
  }

  return (dist);
}              

double Deg2Rad(double deg) 
// This function converts decimal degrees to radians
{
  return (deg * PI_DEF / 180);
}

double Rad2Deg(double rad) 
// This function converts radians to decimal degrees
{
  return (rad * 180 / PI_DEF);
}                   
// ----------------------------------------------------------- //
// ------------------------------- //
// --------- End of File --------- //
// ------------------------------- //

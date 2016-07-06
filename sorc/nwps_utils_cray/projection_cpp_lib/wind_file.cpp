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

Wind file classes and functions

*/
// ----------------------------------------------------------- // 

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include "wind_file.h"

// Function used to convert AWIPS MAG/DIR values to corresponding to U/V vectors for the SWAN model.
// xMag and yMag represents coords of the magnitude vector depending on the direction.
int FindXYMag(float Mag, float Dir, float &xMag, float &yMag, int convert_to_knots, int convert_to_ms)	
{
  float pi = atan(1)*4;
  // If our input is in m/s to and we want to convert to knots
  if(convert_to_knots) Mag *= 1.94384; 
  
  // If our input is in knots and we want to convert to meters per second
  if(convert_to_ms) Mag *= 0.514444;
  
  Mag *= -1;

  // magnitude for the x direction
  xMag = Mag * sin(Dir * (pi/180));
  // magnitude for the y direction
  yMag = Mag * cos(Dir * (pi/180));

  return 1;
}

// Function used to convert a vector U/V wind value into speed (MAG) and direction (DIR)
int FindWindSpeedAndDir(float x, float y, float &mag, float &dir, int convert_to_knots, int convert_to_ms)
{
  mag = 0;   // The magnitude of the vector is given by:
  dir = 0; // Direction angle

  float mag_vect = x*x + y*y;
  if(FloatLessThan(mag_vect, 0)) {
    mag_vect -= mag_vect*2;
  }
  mag = sqrt(mag_vect);
  float pi = atan(1)*4;
 
  // The direction angle is assumed to be relative to north with a clockwise
  // direction being positive. Assuming meteorologic convention (direction from)
  if((FloatEqualTo(x, 0)) && (FloatEqualTo(y, 0))) dir = 0;
  if((FloatEqualTo(x, 0)) && (FloatGreaterThan(y, 0))) dir = 180;
  if((FloatEqualTo(x, 0)) && (FloatLessThan(y, 0))) dir = 0;
  if((FloatEqualTo(y, 0)) && (FloatGreaterThan(x, 0))) dir = 270;
  if((FloatEqualTo(y, 0)) && (FloatLessThan(x, 0))) dir = 90;
  if((FloatGreaterThan(x, 0)) && (FloatGreaterThan(y, 0))) dir = 270-atan(y/x)*180/pi;
  if((FloatLessThan(x, 0)) && (FloatGreaterThan(y, 0))) dir = 90-atan(y/x)*180/pi;
  if((FloatLessThan(x, 0)) && (FloatLessThan(y , 0))) dir = 90-atan(y/x)*180/pi;
  if((FloatGreaterThan(x, 0)) && (FloatLessThan(y, 0))) dir = 270-atan(y/x)*180/pi;

  // If our input is in m/s to and we want to convert to knots
  if(convert_to_knots) mag *= 1.94384; 

  // If our input is in knots and we want to convert to meters per second
  if(convert_to_ms) mag *= 0.514444;

   return 1;
} 

int MakeWindinputCGLines(netCDFVariables &ncv, gxString &line1, gxString &line2, 
			 gxString &windfile_name, gxString &input_date, int custom_timestep,
			 float exception_value)
{
  line1.Clear();
  line2.Clear();
  windfile_name.Clear();
  input_date.Clear();

  float sphere_lon = ncv.domain.SOUTHWESTLON;
  if(FloatLessThan(sphere_lon, 0)) sphere_lon -= sphere_lon * 2;
  sphere_lon = 360 - sphere_lon;

  char start_time[255];
  memset(start_time, 0, sizeof(start_time));

  char windfilenametime[255];
  memset(windfilenametime, 0 , sizeof(windfilenametime));

  char end_time[255];
  memset(end_time, 0, sizeof(end_time));

  char input_date_time[255];
  memset(input_date_time, 0, sizeof(input_date_time));

  char month[25]; char day[25]; char year[25];
  char hour[25]; char minutes[25];
  epoch_time_to_str(ncv.start_time, month, day, year, hour, minutes);
  sprintf(start_time, "%s%s%s.%s%s", year, month, day, hour, minutes);
  sprintf(windfilenametime, "%s%s%s%s", year, month, day, hour);
  sprintf(input_date_time, "%s%s%s%s", year, month, day, hour);
  epoch_time_to_str(ncv.end_time, month, day, year, hour, minutes);
  sprintf(end_time, "%s%s%s.%s%s", year, month, day, hour, minutes);

  windfile_name << clear <<  windfilenametime << ".wnd";
  input_date << clear << input_date_time;

  int timestep = ncv.time_step;
  if(custom_timestep > 0) timestep = custom_timestep;

  line1.Precision(6);
  line1 << "INPGRID WIND " << sphere_lon << " " << ncv.domain.SOUTHWESTLAT << " 0. " 
	<< (int)ncv.domain.NUMMESHESLON << " " << (int)ncv.domain.NUMMESHESLAT
    	<< " " << ncv.domain.EWR << " " << ncv.domain.NSR;
  if(FloatNotEqualTo(exception_value, 0)) {
    int i_rep = 0;
    int f_rep = 0;
    SplitFloat(exception_value, i_rep, f_rep, 100);
    line1 << " EXC " << i_rep;
    if(f_rep > 0) line1 << "." << f_rep;
  }
  line1 << " NONSTAT " << start_time << " " << timestep << ".0 HR " << end_time;
  line2 << clear << "READINP WIND 1.0 \'" << windfile_name << "\' 3 0 0 0 FREE";

  return 1;
}

int epoch_time_to_str(time_t epoch_time, char month[25], char day[25], char year[25],
		      char hour[25], char minutes[25])
{
  memset(month, 0, sizeof(month));
  memset(day, 0, sizeof(day));
  memset(year, 0, sizeof(year));
  memset(hour, 0, sizeof(hour));
  memset(minutes, 0, sizeof(minutes));

  struct tm *TimeBuffer;
  struct tm tbuf;
  memset(&tbuf, 0, sizeof(tbuf));
  TimeBuffer = gmtime(&epoch_time);
  memcpy((unsigned char *)&tbuf, (unsigned char *)TimeBuffer, sizeof(tbuf));

  strftime(month, 25, "%m", &tbuf);
  strftime(day, 25, "%d", &tbuf);
  strftime(year, 25, "%Y", &tbuf);
  strftime(hour, 25, "%H", &tbuf);
  strftime(minutes, 25, "%M", &tbuf);

  return 1;
}

// ----------------------------------------------------------- //
// ------------------------------- //
// --------- End of File --------- //
// ------------------------------- //

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

Wind file classes and functions

*/
// ----------------------------------------------------------- // 
#ifndef __M_WIND_FILE_HPP__
#define __M_WIND_FILE_HPP__

#include "projection_cpp_lib.h"
#include "awips_netcdf.h"

// Function used to gen MAG and DIR values from U and V components
int FindWindSpeedAndDir(float x, float y, float &mag, float &dir, 
			int convert_to_knots, int convert_to_ms);

// Function used to gen U and V components from MAG and DIR
int FindXYMag(float Mag, float Dir, float &xMag, float &yMag, 
	      int convert_to_knots, int convert_to_ms);

int MakeWindinputCGLines(netCDFVariables &ncv, gxString &line1, gxString &line2, 
			 gxString &windfile_name, gxString &input_date, 
			 int custom_timestep = 0, float exception_value = 0);

int epoch_time_to_str(time_t epoch_time, char month[25], char day[25], char year[25],
		      char hour[25], char minutes[25]);

#endif // __M_WIND_FILE_HPP__
// ----------------------------------------------------------- //
// ------------------------------- //
// --------- End of File --------- //
// ------------------------------- //

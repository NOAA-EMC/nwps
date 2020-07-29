// ------------------------------- //
// -------- Start of File -------- //
// ------------------------------- //
// ---------------------------------------------------------------- // 
// C++ Header File
// C++ Compiler Used: MSVC, GCC
// Produced By: Douglas.Gaer@noaa.gov
// File Creation Date: 03/01/2011
// Date Last Modified: 09/15/2011
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

Code used to create, modify, and read META data files used with
GRIB2 and SWAN utils built for NWPS project.
*/
// ----------------------------------------------------------- // 
#ifndef __M_G2_META_FILE_HPP__
#define __M_G2_META_FILE_HPP__

// Our API include files
#include "g2_cpp_headers.h"

// 3plib include file
#include "gxstring.h"

int LoadOrBuildMetaFile(char *fname, GRIB2Message *g2message, int debug);
int BuildMetaFile(char *fname, GRIB2Message *g2message, int debug);
void g2_fix_floating_point_values(gxString &sbuf, int width);

#endif // __M_G2_META_FILE_HPP__
// ----------------------------------------------------------- //
// ------------------------------- //
// --------- End of File --------- //
// ------------------------------- //

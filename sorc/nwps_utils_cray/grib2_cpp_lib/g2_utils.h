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

GRIB2 utility functions built for NWPS project.

*/
// ----------------------------------------------------------- // 
#ifndef __M_G2_UTILS_HPP__
#define __M_G2_UTILS_HPP__

#include "g2_cpp_headers.h"

// Utility functions
void g2_reverse_byte_order(unsigned char *ptr, int length); 
int g2_get_int(const unsigned char *ptr, int length, int byteflip = 0); 
char *g2_get_int(const unsigned char *ptr, int length, char sbuf[81], int byteflip = 0);
void g2_set_int(int ival, unsigned char *ptr, int length, int byteflip = 0);
void g2_set_int(char *str, unsigned char *ptr, int length, int byteflip = 0);
void g2_split_float(double fval, int &i_rep, int &f_rep, int epsilon_rep = 0);

#endif // __M_G2_UTILS_HPP__
// ----------------------------------------------------------- //
// ------------------------------- //
// --------- End of File --------- //
// ------------------------------- //

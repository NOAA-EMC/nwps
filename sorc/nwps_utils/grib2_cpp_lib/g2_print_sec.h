// ------------------------------- //
// -------- Start of File -------- //
// ------------------------------- //
// ---------------------------------------------------------------- // 
// C++ Header File
// C++ Compiler Used: MSVC, GCC
// Produced By: Douglas.Gaer@noaa.gov
// File Creation Date: 03/01/2011
// Date Last Modified: 05/20/2011
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

Util functions used to print GRIB2 message sections.

*/
// ----------------------------------------------------------- // 
#ifndef __M_G2_PRINT_SEC_HPP__
#define __M_G2_PRINT_SEC_HPP__

// Our API include files
#include "g2_cpp_headers.h"

int PrintSec0(g2Section0 *sec0);
int PrintSec1(g2Section1 *sec1);
int PrintSec2(g2Section2 *sec2);
int PrintSec3(g2Section3 *sec3);
int PrintSec4(g2Section4 *sec4);
int PrintSec5(g2Section5 *sec5);
int PrintSec6(g2Section6 *sec6);
int PrintSec7(g2Section7 *sec7);
int PrintGridDefTemplate30(GridDefTemplate30 *gt);
int PrintProductTemplate40(ProductTemplate40 *pt);
int PrintGridTemplate50(GridTemplate50 *pt);

#endif // __M_G2_PRINT_SEC_HPP__
// ----------------------------------------------------------- //
// ------------------------------- //
// --------- End of File --------- //
// ------------------------------- //

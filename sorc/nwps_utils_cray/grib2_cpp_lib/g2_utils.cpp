// ------------------------------- //
// -------- Start of File -------- //
// ------------------------------- //
// ----------------------------------------------------------- // 
// C++ Source Code File
// Compiler Used: MSVC, GCC
// Produced By: Douglas.Gaer@noaa.gov
// File Creation Date: 03/01/2011
// Date Last Modified: 09/15/2011
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

GRIB2 utility functions built for NWPS project.

*/
// ----------------------------------------------------------- // 

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>

#include "g2_cpp_headers.h"
#include "g2_utils.h"

void g2_reverse_byte_order(unsigned char *ptr, int length)
{
  unsigned char ch;
  for(unsigned short i = 0; i < length/2; ++i){
    ch = ptr[(length)-(i+1)];
    ptr[(length)-(i+1)] = ptr[i]; 
    ptr[i] = ch; 
  }
}

int g2_get_int(const unsigned char *ptr, int length, int byteflip)
{
  short sval = 0;
  int val = 0;
  __g2LLWORD__ lval = 0;

  if((!ptr) || (length <= 0)) return 0;

  unsigned char *buf = new unsigned char[length];
  memset(buf, 0, length);
  memcpy(buf, ptr, length);
  if((length > 1) && (byteflip == 1)) g2_reverse_byte_order(buf, length);
  switch(length) {
    case 1:
      val = (int)buf[0];
      break;

    case 2:
      memcpy((unsigned char *)&sval, buf, length);
      val = sval;
      if(sval == -1) val = -1;
      break;

    case 4:
      memcpy((unsigned char *)&val, buf, length);
      break;
      
    case 8:
      memcpy((unsigned char *)&lval, buf, length);
      val = lval;
      if(lval == -1) val = -1;
      break;

    default:
      val = 0;
      break;
  }

  delete buf;
  return val;
}

char *g2_get_int(const unsigned char *ptr, int length, char sbuf[81], int byteflip)
{
  memset(sbuf, 0, 25);
  int val = g2_get_int(ptr, length, byteflip);
  sprintf(sbuf, "%d", val);
  return sbuf;
}

void g2_set_int(int ival, unsigned char *ptr, int length, int byteflip)
{
  char cval = 0;
  short sval = 0;
  int val = 0;
  __g2LLWORD__ lval = 0;
  
  if((!ptr) || (length <= 0)) return;

  switch(length) {
    case 1:
      cval = (char)ival;
      memcpy(ptr, (unsigned char *)&cval, 1);
      break;

    case 2:
      sval = ival;
      if(ival >= 65535) sval = -1;
      memcpy(ptr, (unsigned char *)&sval, 2);
      if(byteflip == 1) g2_reverse_byte_order(ptr, 2);
      break;

    case 4:
      val = ival;
      memcpy(ptr, (unsigned char *)&val, 4);
      if(byteflip == 1) g2_reverse_byte_order(ptr, 4);
      break;
      
    case 8:
      lval = ival;
      if(ival == -1) lval = -1;
      memcpy(ptr, (unsigned char *)&lval, 8);
      if(byteflip == 1) g2_reverse_byte_order(ptr, 8);
      break;

    default:
      break;
  }

  return;
}

void g2_set_int(char *str, unsigned char *ptr, int length, int byteflip)
{
  if(!str) return;
  int ival = atoi(str);
  g2_set_int(ival, ptr, length, byteflip);
}

void g2_split_float(double fval, int &i_rep, int &f_rep, int epsilon_rep)
{
  if(epsilon_rep <= 0) epsilon_rep = 10;
  double param, fractpart, intpart;
  param = fval;
  fractpart = modf(param , &intpart);
  i_rep = (int)intpart;
  f_rep = ceil(fractpart*epsilon_rep);
  if(f_rep < 0) f_rep -= f_rep*2;
}
// ----------------------------------------------------------- //
// ------------------------------- //
// --------- End of File --------- //
// ------------------------------- //

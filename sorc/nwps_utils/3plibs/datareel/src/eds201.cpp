// ------------------------------- //
// -------- Start of File -------- //
// ------------------------------- //
// ----------------------------------------------------------- // 
// C++ Source Code File Name: eds201.cpp
// Compiler Used: MSVC, BCC32, GCC, HPUX aCC, SOLARIS CC
// Produced By: DataReel Software Development Team
// File Creation Date: 04/30/2001
// Date Last Modified: 01/01/2009
// Copyright (c) 2001-2009 DataReel Software Development
// ----------------------------------------------------------- // 
// ------------- Program Description and Details ------------- // 
// ----------------------------------------------------------- // 
/*
This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.
 
This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  
USA

Code used to generate platform dependent randomly encoded 
data sets.

NOTE: Data encoding is a very weak form of asymmetric encryption 
and can be cracked more readily than stronger forms of asymmetric 
encryption. The data encoding routines provided with this library 
should not be implemented in any measure to stop malicious hackers 
on the Internet from breaking into communication systems or from 
compromising encoded data files. The data encoding routines are an 
alternative to sending plain text messages or writing plain text to 
database or configuration files. These routines are simple, fast, 
and integrated into the library so you do not need to include any 
other third party libraries when building code using this library. 
If you need a comprehensive strong encryption toolkit please visit 
the http://www.openssl.org Website to download the latest version 
of OpenSSL.      
*/
// ----------------------------------------------------------- // 
#include "gxdlcode.h"

#include <string.h>
#include <stdlib.h>
#include <time.h>
#include "eds201.h"

#ifdef __BCC32__
#pragma warn -8071
#pragma warn -8080
#endif

eds2String::eds2String(eds2MagicNumber_t magic_num)
{
  InitDynamicTable(magic_num);
}

eds2String::eds2String(const eds2String &ob)
{
  eds2Copy(ob);
}

eds2String eds2String::operator=(const eds2String &ob)
{
  if(this != &ob) { // PC-lint 05/25/2002: Prevent self assignment 
    eds2Copy(ob);
  }
  return *this;
}

void eds2String::eds2Copy(const eds2String &ob)
{
  eds2_magic_number = ob.eds2_magic_number;
  for(unsigned i = 0; i < eds2TableSize; i++) 
    eds2_table[i] = ob.eds2_table[i];
}

eds2WORD eds2String::EncodeString(unsigned char c)
// Return a encoded value for the specified character.
{
  return eds2_table[(unsigned)c];
}

int eds2String::DecodeString(eds2WORD val, unsigned char &c)
// Decode the specified value and pass back the character in "c."
// Returns false if the decoded value is not found in the
// encoding table.
{
  for(unsigned i = 0; i < eds2TableSize; i++) {
    if(eds2_table[i] == val) { // Found a match
      c = (unsigned char)i;
      return 1;
    }
  }
  return 0; // No match was found
}

void eds2String::InitDynamicTable(eds2MagicNumber_t magic_num)
// Initialize the dynamic magic number table. The dynamic table allows 
// applications to change the encoding codes as the program is running.
// Table values are calculated by a byte-wise 16-bit operation based on 
// a specified polynomial. NOTE: In this representation the coefficient 
// of x^0 is stored in the MSB of the 16-bit word and the coefficient of 
// x^15 is stored in the LSB.
{
  eds2_magic_number = magic_num;

  // Ignore all BCC32 conversion warnings
  int i, n;
  eds2WORD_t val_16;

  for (i = 0; i < (int)eds2TableSize; i++) {
    val_16 = i;
    for (n = 1; n < 9; n++) {
      if (val_16 & 1)
	val_16 = (val_16 >> 1) ^ eds2_magic_number;
      else
	val_16 = val_16 >> 1;
    }
    eds2_table[i] = val_16;
  }
}


#ifdef __BCC32__
#pragma warn .8071
#pragma warn .8080
#endif
// ----------------------------------------------------------- //
// ------------------------------- //
// --------- End of File --------- //
// ------------------------------- //

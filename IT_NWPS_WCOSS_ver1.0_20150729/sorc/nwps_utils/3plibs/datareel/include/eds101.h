// ------------------------------- //
// -------- Start of File -------- //
// ------------------------------- //
// ----------------------------------------------------------- // 
// C++ Header File Name: eds101.h
// C++ Compiler Used: MSVC, BCC32, GCC, HPUX aCC, SOLARIS CC
// Produced By: DataReel Software Development Team
// File Creation Date: 10/15/1999 
// Date Last Modified: 07/29/2009
// Copyright (c) 2001-2009 DataReel Software Development
// ----------------------------------------------------------- // 
// ---------- Include File Description and Details  ---------- // 
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

Changes:
==============================================================
10/12/2005: Depreciated all references to encrypt and decrypt 
function names. In future releases only the encode and decode 
functions will be available.
==============================================================
*/
// ----------------------------------------------------------- // 
#ifndef __GX_EDS101_HPP__
#define __GX_EDS101_HPP__

#include "gxdlcode.h"

// ---------------------------------------------------------------------
// Global and type defines constants for current EDS version 
// ---------------------------------------------------------------------
typedef unsigned short edsWORD; // Data type used for encodeded characters
const unsigned long edsRandomSeed = 123494; // Default random seed
const unsigned edsTableSize = 256;          // Size of EDS tables
const unsigned edsMaxLine = 255;            // Max chars per line
const edsWORD edsEOT = 0x0000;              // End of text marker

// Ignore BCC32 unused variable warning for version number
const double edsVersionNumber = 4630.101;   // Current version number

// Class used to read and write encoded data sets strings
class GXDLCODE_API edsString
{
public:
  edsString();
  virtual ~edsString();
  edsString(const edsString &ob);
  edsString operator=(const edsString &ob);
  
public:
  edsWORD GenRandomNumber();
  void InitDynamicTable(unsigned long r_seed = edsRandomSeed);
  void LoadStaticTable();
  edsWORD EncodeString(unsigned char c);
  int DecodeString(edsWORD val, unsigned char &c);

public: // Depreciated function names 
  edsWORD EncryptString(unsigned char c) {
    return EncodeString(c);
  }
  int DecryptString(edsWORD val, unsigned char &c) {
    return DecodeString(val, c);
  }
  
protected:
  void TestDynamicTable();
  void edsCopy(const edsString &ob);
  
public:
  edsWORD eds_table[edsTableSize]; // Dynamic table
};

#ifdef __USE_EDS_TEST_FUNCTIONS__
// Standalone functions used to create and test static encryption tables
#if defined (__USE_ANSI_CPP__) // Use the ANSI Standard C++ library
#include <iostream>
#include <iomanip>
#else // Use the old iostream library by default
#include <iostream.h>
#include <iomanip.h>
#endif // __USE_ANSI_CPP__

GXDLCODE_API int edsPrintStaticEncodingTable(GXSTD::ostream &stream);
GXDLCODE_API int edsTestStaticEncodingTable(GXSTD::ostream &stream);
#endif // __USE_EDS_TEST_FUNCTIONS__

#endif // __GX_EDS101_HPP__
// ----------------------------------------------------------- //
// ------------------------------- //
// --------- End of File --------- //
// ------------------------------- //

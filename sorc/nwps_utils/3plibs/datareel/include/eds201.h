// ------------------------------- //
// -------- Start of File -------- //
// ------------------------------- //
// ----------------------------------------------------------- // 
// C++ Header File Name: eds201.h
// C++ Compiler Used: MSVC, BCC32, GCC, HPUX aCC, SOLARIS CC
// Produced By: DataReel Software Development Team
// File Creation Date: 04/30/2001
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

Code used to generate platform independent encoded data sets
used in cross-platform communication applications.

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
#ifndef __GX_EDS201_HPP__
#define __GX_EDS201_HPP__

#include "gxdlcode.h"

#include "gxuint16.h"

// ---------------------------------------------------------------------
// Global and type defines constants for EDS version 2 data sets 
// ---------------------------------------------------------------------
typedef gxUINT16 eds2WORD;     // Data type used for encoded characters
typedef __USWORD__ eds2WORD_t; // Native type used for encoded characters
typedef __USWORD__ eds2MagicNumber_t;            // Magic number native type 
const eds2MagicNumber_t eds2MagicNumber = 34881; // Default magic number
const unsigned eds2TableSize = 256;              // Size of EDS tables
const unsigned eds2MaxLine = 255;                // Max chars per line
const eds2WORD eds2EOT = (gxUINT16)0x0000;       // End of text marker

// Ignore BCC32 unused variable warning for version number
const double eds2VersionNumber = 4630.101;       // Current version number

// Class used to read and write encoded data sets strings
class GXDLCODE_API eds2String
{
public:
  eds2String(eds2MagicNumber_t magic_num = eds2MagicNumber);
  ~eds2String() { }
  eds2String(const eds2String &ob);
  eds2String operator=(const eds2String &ob);
  
public:
  void InitDynamicTable(eds2MagicNumber_t magic_num = eds2MagicNumber);
  eds2WORD EncodeString(unsigned char c);
  int DecodeString(eds2WORD val, unsigned char &c);
  void eds2Copy(const eds2String &ob);

public: // Depreciated function names 
  eds2WORD EncryptString(unsigned char c) {
    return EncodeString(c);
  }
  int DecryptString(eds2WORD val, unsigned char &c) {
    return DecodeString(val, c);
  }
  
public:
  eds2WORD eds2_magic_number; // EDS2 magic number use to encode strings  
  eds2WORD eds2_table[eds2TableSize]; // EDS2 Dynamic table
};

#endif // __GX_EDS201_HPP__
// ----------------------------------------------------------- //
// ------------------------------- //
// --------- End of File --------- //
// ------------------------------- //

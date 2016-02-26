// ------------------------------- //
// -------- Start of File -------- //
// ------------------------------- //
// ----------------------------------------------------------- // 
// C++ Header File Name: sreg101.h
// C++ Compiler Used: MSVC, BCC32, GCC, HPUX aCC, SOLARIS CC
// Produced By: DataReel Software Development Team
// File Creation Date: 10/13/1999 
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

Code used to generate software registration numbers using A-C-E
level one encoding and a magic number sequence.

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
#ifndef __GX_SREG101_HPP__
#define __GX_SREG101_HPP__

#include "gxdlcode.h"

#include "ustring.h"

// ---------------------------------------------------------------------
// Global constants for current srnGenerator version 
// ---------------------------------------------------------------------
// NOTE: !!! If any of these values are modified the software registration
// numbers will be changed. This will effect all applications using the
// srnGenerator class to generate registration codes. !!!
// Ignore BCC32 unused variable warning for version number
const double srnVersionNumber = 4630.101; // Current version 
const char srnSegmentSeparator = '-';     // Separator character
const int srnMaxStringLength = 255;       // Max chars per string
const int srnTableSize = 256;             // Table size for magic numbers
const int srnMaxNameChars = 8;            // Max chars per program name

// Type defines
typedef unsigned long srnIntType; // Integer type use for magic numbers

// This value is used to calculate a magic number based on a string value
const srnIntType srnPolynomial = 0xbca44105;
                                    
// Software registration number generator class
class GXDLCODE_API srnGenerator
{
public:
  srnGenerator();
  srnGenerator(const UString &pname, const UString &user_name);
  srnGenerator(char *pname, char *user_name);
  srnGenerator(const char *pname, const char *user_name);
  ~srnGenerator();
  srnGenerator(const srnGenerator &ob);
  srnGenerator operator=(const srnGenerator &ob);

public:
  char *GetRegString();
  const char *GetRegString() const;
  char *GetRegCode();
  const char *GetRegCode() const;
  srnIntType GetMagicNumber();
  void GenRegString(const UString &pname, const UString &user_name);
  void GenRegString(const char *pname, const char *user_name);
  void GenRegString(char *pname, char *user_name);
  srnIntType GenMagicNumber(const UString &pname, const UString &user_name);
  srnIntType GenMagicNumber(const char *pname, const char *user_name);
  srnIntType GenMagicNumber(char *pname, char *user_name);
  int Validate(const UString &regCode, const UString &pname,
	       const UString &user_name);
  int Validate(const char *regCode, const char *pname,
	       const char *user_name);
  int Validate(char *regCode, char *pname, char *user_name);
  
private:
  int ACE1encode(unsigned char &c, int offset=0);
  int ACE1Aencode(unsigned char &c, int offset=0);
  void srnCopy(const srnGenerator &ob);
  void srnInit();
  void srnTableInit();
  void ClearRegString();
  void GenRegCode();

private:
  srnIntType magic_number;
  UString reg_code;
  char reg_string[srnMaxNameChars];
  srnIntType srn_table[srnTableSize];
};

#endif // __GX_SREG101_HPP__
// ----------------------------------------------------------- //
// ------------------------------- //
// --------- End of File --------- //
// ------------------------------- //

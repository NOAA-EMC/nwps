// ------------------------------- //
// -------- Start of File -------- //
// ------------------------------- //
// ----------------------------------------------------------- // 
// C++ Source Code File Name: eds101.cpp
// Compiler Used: MSVC, BCC32, GCC, HPUX aCC, SOLARIS CC
// Produced By: DataReel Software Development Team
// File Creation Date: 10/15/1999 
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

Changes:
==============================================================
08/12/2002: Modified the edsString::GenRandomNumber() function 
to use the reentrant rand_r() function instead of the srand()
function under UNIX.

08/12/2002: Modified the edsString::InitDynamicTable() function 
to use the reentrant rand_r() function instead of the srand()
function under UNIX.

09/04/2002: The __REENTRANT__ preprocessor directive must be 
defined during UNIX builds to enable the use of reentrant
rand_r calls within the edsString::GenRandomNumber() and
edsString::InitDynamicTable() functions.
==============================================================
*/
// ----------------------------------------------------------- // 
#include "gxdlcode.h"

#include <string.h>
#include <stdlib.h>
#include <time.h>
#include "eds101.h"
#include "edst101.h"

#ifdef __BCC32__
#pragma warn -8080
#endif

edsString::edsString()
{
  LoadStaticTable(); // Load the static table values by default
}

edsString::~edsString()
{

}

edsString::edsString(const edsString &ob)
{
  edsCopy(ob);
}

edsString edsString::operator=(const edsString &ob)
{
  if(this != &ob) { // PC-lint 05/25/2002: Prevent self assignment 
    edsCopy(ob);
  }
  return *this;
}

void edsString::edsCopy(const edsString &ob)
{
  for(unsigned i = 0; i < edsTableSize; i++) 
    eds_table[i] = ob.eds_table[i];
}

edsWORD edsString::EncodeString(unsigned char c)
// Return a encoded value for the specified character.
{
  return eds_table[(unsigned)c];
}

int edsString::DecodeString(edsWORD val, unsigned char &c)
// Decode the specified value and pass back the character in "c."
// Returns false if the encoded value is not found in the
// encoding table.
{
  for(unsigned i = 0; i < edsTableSize; i++) {
    if(eds_table[i] == val) { // Found a match
      c = (unsigned char)i;
      return 1;
    }
  }
  return 0; // No match was found
}

void edsString::LoadStaticTable()
{
  for(unsigned i = 0; i < edsTableSize; i++) 
    eds_table[i] = (edsWORD)edsStaticTable[i]; // Load the table values
}

edsWORD edsString::GenRandomNumber()
// Generate a random pad value. 
{
  // Seed the random number generator with the current time
  // so that the numbers will be different each time this
  // function is called.
#if defined (__WIN32__)
  // PC-lint 09/08/2005: Ignore null pointer to time() function
  srand((unsigned)time(0));
  return (edsWORD)rand();
#elif defined (__HPUX10__) && defined (__REENTRANT__)
  // Reentrant UNIX call added to replace srand() and rand()
  long seed = time(0); int result;
  return (edsWORD)rand_r(&seed, &result);
#elif defined (__UNIX__) && defined (__REENTRANT__)
  // Reentrant UNIX call added to replace srand() and rand()
  unsigned int seed = time(0);
  return (edsWORD)rand_r(&seed);
#else // Default to the using the srand() function 
  srand((unsigned)time(0));
  return (edsWORD)rand();
#endif
}

void edsString::InitDynamicTable(unsigned long r_seed)
// Initialize the dynamic table. The dynamic table allows the application
// to change the encoding codes as the program is running.
{
#if defined (__WIN32__)
  srand(r_seed); // Seed the random number generator
  for(unsigned i = 0; i < edsTableSize; i++) {
    eds_table[i] = (edsWORD)(rand() + i);
  }
#elif defined (__HPUX10__) && defined (__REENTRANT__)
  // Reentrant safe UNIX call added to replace srand() and rand()
  long l_seed = r_seed; // Seed the random number generator
  int result;
  for(unsigned i = 0; i < edsTableSize; i++) {
    eds_table[i] = (edsWORD)((rand_r((&l_seed + i), &result)));
  }
#elif defined (__UNIX__) && defined (__REENTRANT__)
  // Reentrant safe UNIX call added to replace srand() and rand()
  unsigned l_seed = r_seed; // Seed the random number generator
  for(unsigned i = 0; i < edsTableSize; i++) {
    eds_table[i] = (edsWORD)(rand_r(&l_seed) + i);
  }
#else // Default to the using the srand() function 
  srand(r_seed); // Seed the random number generator
  for(unsigned i = 0; i < edsTableSize; i++) {
    eds_table[i] = (edsWORD)(rand() + i);
  }
#endif
  TestDynamicTable();
}

void edsString::TestDynamicTable()
// Test the table for duplicate matches and automatically correct.
{
  edsWORD table[edsTableSize];
  unsigned i, j, matches, total_matches;

  while(1) { // PC-lint 05/24/2002: while(1) loop
    for(i = 0; i < edsTableSize; i++) 
      table[i] = eds_table[i]; // Load the table values
    total_matches = 0;
    for(i = 0; i < edsTableSize; i++) {
      matches = 0;
      for(j = 0; j < edsTableSize; j++) {
	// Looking for duplicate entries
	if(eds_table[i] == table[j]) matches++;
	if(matches > 1) { // Found duplicate entry
	  eds_table[i] = GenRandomNumber();
	  total_matches++;
	}
      }
    }
    if(total_matches == 0) break;
  }
}

#ifdef __USE_EDS_TEST_FUNCTIONS__
GXDLCODE_API int edsTestStaticEncodingTable(GXSTD::ostream &stream)
// Test the static encoding table for duplicate entries.
{
  edsWORD table[edsTableSize];
  unsigned i, j, matches;

  for(i = 0; i < edsTableSize; i++) 
    table[i] = edsStaticTable[i]; // Load the table values

  for(i = 0; i < edsTableSize; i++) {
    matches = 0;
    for(j = 0; j < edsTableSize; j++) {
      // Looking for duplicate entries
      if(edsStaticTable[i] == table[j]) matches++;
      if(matches > 1) {
	stream << "\n";
	stream << "Duplicate table entry:" << "  0x" << GXSTD::setfill('0')
	     << GXSTD::setw(4) << GXSTD::hex << edsStaticTable[i];
	stream << "\n";
	return 0;
      }
    }
    if(i % 5)
      stream << ", 0x" << GXSTD::setfill('0') << GXSTD::setw(4) << GXSTD::hex 
	     << edsStaticTable[i];
    else
      stream << "," << "\n" << "  0x" << GXSTD::setfill('0') 
	     << GXSTD::setw(4) << GXSTD::hex << edsStaticTable[i];
  }
  return 1;
}

GXDLCODE_API int edsPrintStaticEncodingTable(GXSTD::ostream &stream)
// Prints the static encoding table to the specified stream.
// Returns false if a duplicate table entry exists. NOTE: This
// function is used for test purposes only. 
{
  edsString eds1, eds2;
  eds1.InitDynamicTable();
  eds2.InitDynamicTable();

  unsigned matches, i, j;  
  for(i = 0; i < edsTableSize; i++) {
    matches = 0;
    for(j = 0; j < edsTableSize; j++) {
      // Looking for duplicate entries
      if(eds1.eds_table[i] == eds2.eds_table[j]) matches++;
      if(matches > 1) {
	stream << "\n";
	stream << "Duplicate table entry:" << "  0x" << GXSTD::setfill('0')
	     << GXSTD::setw(4) << GXSTD::hex << eds1.eds_table[i];
	stream << "\n";
	return 0;
      }
    }
    if(i % 5)
      stream << ", 0x" << GXSTD::setfill('0') << GXSTD::setw(4) 
	     << GXSTD::hex << eds1.eds_table[i];
    else
      stream << "," << "\n" << "  0x" << GXSTD::setfill('0') 
	     << GXSTD::setw(4) << GXSTD::hex << eds1.eds_table[i];
  }
  return 1;
}
#endif // __USE_EDS_TEST_FUNCTIONS__

#ifdef __BCC32__
#pragma warn .8080
#endif
// ----------------------------------------------------------- //
// ------------------------------- //
// --------- End of File --------- //
// ------------------------------- //

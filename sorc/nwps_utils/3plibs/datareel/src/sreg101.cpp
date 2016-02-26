// ------------------------------- //
// -------- Start of File -------- //
// ------------------------------- //
// ----------------------------------------------------------- // 
// C++ Source Code File Name: sreg101.cpp
// Compiler Used: MSVC, BCC32, GCC, HPUX aCC, SOLARIS CC
// Produced By: DataReel Software Development Team
// File Creation Date: 10/13/1999 
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
#include "gxdlcode.h"

#include <string.h>
#include <stdio.h>
#include <ctype.h>
#include "sreg101.h"

#ifdef __BCC32__
#pragma warn .8080
#pragma warn -8071
#endif

srnGenerator::srnGenerator()
{
  // PC-lint 05/02/2005: Members not initialized by constructor
  magic_number = 0;
  int i;
  for(i = 0; i < srnMaxNameChars; i++) reg_string[i] = '\0';
  for(i = 0; i < srnTableSize; i++) srn_table[i] = 0;
}

srnGenerator::srnGenerator(const UString &pname, const UString &user_name)
{
  GenRegString(pname, user_name);
} 

srnGenerator::srnGenerator(char *pname, char *user_name)
{
  GenRegString(pname, user_name);
} 

srnGenerator::srnGenerator(const char *pname, const char *user_name)
{ 
  GenRegString(pname, user_name);
}

srnGenerator::~srnGenerator()
{

}

srnGenerator::srnGenerator(const srnGenerator &ob)
{
  srnCopy(ob);
}

srnGenerator srnGenerator::operator=(const srnGenerator &ob)
{
  // PC-lint 05/02/2005: Check for self assignment
  if(this != &ob) {
    srnCopy(ob);
  }
  return *this;
}

srnIntType srnGenerator::GetMagicNumber()
{
  return magic_number;
}

char *srnGenerator::GetRegString()
{
  // PC-lint 05/02/2005: Exposing low access member
  return (char *)reg_string;
}

const char *srnGenerator::GetRegString() const
{
  return (const char *)reg_string;
}

char *srnGenerator::GetRegCode()
{
  return reg_code.c_str();
}

const char *srnGenerator::GetRegCode() const
{
  return reg_code.c_str();
}

void srnGenerator::srnCopy(const srnGenerator &ob)
{
  magic_number = ob.magic_number;
  reg_code = ob.reg_code;
  int i;
  for(i = 0; i < srnMaxNameChars; i++) reg_string[i] = ob.reg_string[i];
  for(i = 0; i < srnTableSize; i++) srn_table[i] = ob.srn_table[i];
}


void srnGenerator::srnInit()
// Set initial values for the srnGenerator.
{
  srnTableInit();
  ClearRegString();
}

void srnGenerator::ClearRegString()
{
  for(int i = 0; i < srnMaxNameChars; i++) reg_string[i] = '\0';
}

void srnGenerator::srnTableInit()
// Initialize the table used to generate magic numbers. Table
// values are calculated by a byte-wise 32-bit operation based
// on a specified polynomial. NOTE: In this representation the
// coefficient of x^0 is stored in the MSB of the 32-bit word
// and the coefficient of x^31 is stored in the LSB. 
{
  int i,n;
  srnIntType val32;
  for (i = 0; i < srnTableSize; i++) {
    val32=i;
    for (n = 1; n < 9; n++) {
      if (val32 & 1)
	val32 = (val32 >> 1) ^ srnPolynomial;
      else
	val32 = val32 >> 1;
    }
    srn_table[i] = val32;
  }
}

void srnGenerator::GenRegString(const char *pname, const char *user_name)
{
  srnInit(); // Reset all values
  int len = strlen(pname);
  unsigned char sbuf[srnMaxNameChars];

  // Ensure the maximum number of characters are used per name
  if(len >= srnMaxNameChars) {
    memmove(sbuf, pname, srnMaxNameChars);
    len = srnMaxNameChars;
  }
  else {
    memmove(sbuf, pname, len);
    while(len < srnMaxNameChars) {
      // Ignore BCC32 conversion warning
      sbuf[len] = sbuf[0]+len; // Fill in the missing characters
      len++;
    }
  }

  int i;
  int offset = 15;
  unsigned random_offset = (unsigned)sbuf[strlen(pname)]/8;

  // Generate a magic number based on the user name
  magic_number = GenMagicNumber(pname, user_name);
  
  // Encode once using random and non-random offsets
  for(i = 0; i < len; i++) {
    // Ignore BCC32 conversion warning
    sbuf[i] = sbuf[i]+random_offset; 
    ACE1encode(sbuf[i], offset++);
  }

  // Encode again without offsets to remove any non-alphanumerics
  for(i = 0; i < len; i++) {
    ACE1encode(sbuf[i]);
    reg_string[i] = sbuf[i];  
  }

  // PC-lint 05/02/2005: Possible access of out-of-bounds pointer
  reg_string[srnMaxNameChars-1] = 0; // Ensure null termination

  // Generate a composite string that includes the Registration
  // String and the Magic Number Sequence
  GenRegCode(); 
}

void srnGenerator::GenRegString(char *pname, char *user_name)
{
  GenRegString((const char *)pname, (const char *)user_name);
}

void srnGenerator::GenRegString(const UString &pname, const UString &user_name)

{
  GenRegString(pname.c_str(), user_name.c_str());
}

srnIntType srnGenerator::GenMagicNumber(const UString &pname,
					const UString &user_name)
// Generate a magic number based on the program's name. This
// function is called by the srnGenerator::GenRegString() but
// can be used by the application to validate magic numbers.
{
  UString sbuf(pname); sbuf += user_name;
  srnIntType val32 = 0xffffffffL;
  unsigned n = sbuf.length();
  char *p = sbuf.c_str();
  
  while(n--) {
    val32 = srn_table[(val32 ^ (*p++)) & 0xFF] ^ ((val32>>8) & 0x00ffffffL);
  }
  return val32 ^ 0xffffffffL;
}

srnIntType srnGenerator::GenMagicNumber(const char *pname,
					   const char *user_name)
{
  UString pn(pname); UString un(user_name);
  return GenMagicNumber(pn, un);
}

srnIntType srnGenerator::GenMagicNumber(char *pname, char *user_name)
{
  UString pn(pname); UString un(user_name);
  return GenMagicNumber(pn, un);
}

int srnGenerator::Validate(const UString &regCode, const UString &pname,
			   const UString &user_name)
// Validate a software registration string and magic number. Returns
// true if the software registration string matches the program name,
// user name, and the magic number sequence.
{
  UString rs(regCode); UString mn(regCode);
  // PC-lint 05/02/2005: Possible access of out-of-bounds pointer
  char sep[2]; sep[0] = srnSegmentSeparator; sep[1] = 0;
  int offset = rs.Find((char *)sep);
  if(offset == -1) return 0;
  rs.DeleteAt(offset, (rs.length() - offset));
  mn.DeleteAt(0, (offset + 1));
  GenRegString(pname, user_name);
  unsigned long m_number;

  // 05/30/2002: Using type cast to int type to eliminate
  // warning: int format, long int arg (arg 3) when compiled
  // under Linux gcc.
  sscanf(mn.c_str(), "%u", (unsigned int *)&m_number);
  if(strcmp(reg_string, rs.c_str()) != 0) return 0;
  if(m_number != magic_number) return 0;
  return 1;
}

int srnGenerator::Validate(const char *regCode, const char *pname,
			   const char *user_name)
{
  UString rc(regCode); UString pn(pname); UString un(user_name);
  return Validate(rc, pn, un);
}
  
int srnGenerator::Validate(char *regCode, char *pname, char *user_name)
{
  UString rc(regCode); UString pn(pname); UString un(user_name);
  return Validate(rc, pn, un);
}

void srnGenerator::GenRegCode()
// Generate a registration code that contains the
// registration string, segment separator, and magic
// number sequence. This function is called by the
// srnGenerator::GenRegString() function.
{
  char mn_str[255];
  reg_code.DeleteAt(0, reg_code.length());
  reg_code += GetRegString();
  reg_code += srnSegmentSeparator;

  // 05/30/2002: Using type cast to int type to eliminate
  // warning: int format, long int arg (arg 3) when compiled
  // under Linux gcc.
  sprintf(mn_str, "%u", (unsigned int)GetMagicNumber());
  reg_code += mn_str;
}

// ---------------------------------------------------------------------
// A-C-E encoding routines.
// ---------------------------------------------------------------------
int srnGenerator::ACE1encode(unsigned char &c, int offset)
// ---------------------------------------------------------------------
// A-C-E level one alphanumeric encoding.
// ---------------------------------------------------------------------
// A-C-E alphanumeric encoding routine rules: (1) All non-printable chars
// will be treated as letter 'g' or disallowed depending on the application.
// (2) All letters will be evaluated according to case during the
// encoding process. (3) All even numbers will be converted to odd
// numbers: 0=9, 2=7, 4=5, 6=3, 8=1. (4) Odd numbers (except 5) will be 
// converted to letters: 1='o', 3='I', 7='q', 9=W'. (4) Every other letter
// from the beginning of the alphabet will be converted to even numbered
// letters starting from 'Y' to 'O': B=Y, b=k , D=W, d=i, F=U, f=g , H=S,
// h=e, J=Q, j=c, L=O, l=a, and from 'A' to 'K': Z=A, z=o , X=C, x=q , V=E,
// v=s , T=G, t=u ,R=I, r=w, P=K, p=y. (6) The letter 'N' will be converted
// to the number 7. (7) The number 5 will be converted to letter 'G'. (8)
// All omitted letters will retain the case of the letters they have been
// substituted with. (9) The letters A, C, E, G, I, K, M, O, Q, S, U, W,
// and Y will be retain their original case in reverse order: A=Y, C=W, E=U,
// G=S, I=Q, K=O, M=7, O=K, Q=I, S=G, U=E, W=C, and Y=A. (10) The letters a,
// c, e, g, i, k, m, o, q, s, u, w, and y will be converted to odd numbers:
// a=9, c=7, e=3, g=1, i=5, k=5, m=5, o=5, q=5, s=9, u=7, w=3, and y=1. (11)
// All final values will be offset by a random value according to the number
// of times it occurs in the string. 
{
  switch(c) {
    case 'a':
      // Ignore BCC32 conversion warning
      c = '9' + offset; 
      break;
    case 'A':
      // Ignore BCC32 conversion warning
      c = 'Y' + offset; 
      break;
    case 'B':
      // Ignore BCC32 conversion warning
      c = 'Y' + offset; 
      break;
    case 'b':
      // Ignore BCC32 conversion warning
      c = 'k' + offset; 
      break;
    case 'c':
      // Ignore BCC32 conversion warning
      c = '7' + offset; 
      break;
    case 'C':
      // Ignore BCC32 conversion warning
      c = 'W' + offset; 
      break;
    case 'D':
      // Ignore BCC32 conversion warning
      c = 'W' + offset; 
      break;
    case 'd':
      // Ignore BCC32 conversion warning
      c = 'i' + offset; 
      break;
    case 'e':
      // Ignore BCC32 conversion warning
      c = '3' + offset;
      break;
    case 'E':
      // Ignore BCC32 conversion warning
      c = 'U' + offset;
      break;
    case 'F': 
      // Ignore BCC32 conversion warning
      c = 'U' + offset;
      break;
    case 'f': 
      // Ignore BCC32 conversion warning
      c = 'g' + offset;
      break;
    case 'g':
      // Ignore BCC32 conversion warning
      c = '1' + offset;
      break;
    case 'G':
      // Ignore BCC32 conversion warning
      c = 'S' + offset;
      break;
    case 'H':
      // Ignore BCC32 conversion warning
      c = 'S' + offset;
      break;
    case 'h':
      // Ignore BCC32 conversion warning
      c = 'e' + offset;
      break;
    case 'i':
      // Ignore BCC32 conversion warning
      c = '5' + offset;
      break;
    case 'I':
      // Ignore BCC32 conversion warning
      c = 'Q' + offset;
      break;
    case 'J':
      // Ignore BCC32 conversion warning
      c = 'Q' + offset;
      break;
    case 'j':
      // Ignore BCC32 conversion warning
      c = 'c' + offset;
      break;
    case 'k':
      // Ignore BCC32 conversion warning
      c = '5' + offset;
      break;
    case 'K':
      // Ignore BCC32 conversion warning
      c = 'O' + offset;
      break;
    case 'L':
      // Ignore BCC32 conversion warning
      c = 'O' + offset;
      break;
    case 'l':
      // Ignore BCC32 conversion warning
      c = 'a' + offset;
      break;
    case 'm':
      // Ignore BCC32 conversion warning
      c = '5' + offset;
      break;
    case 'M':
      // Ignore BCC32 conversion warning
      c = '7' + offset;
      break;
    case 'n':
      // Ignore BCC32 conversion warning
      c = '7' + offset;
      break;
    case 'N':
      // Ignore BCC32 conversion warning
      c = '7' + offset;
      break;
    case 'o':
      // Ignore BCC32 conversion warning
      c = '5' + offset;
      break;
    case 'O':
      // Ignore BCC32 conversion warning
      c = 'K' + offset;
      break;
    case 'P':
      // Ignore BCC32 conversion warning
      c = 'k' + offset;
      break;
    case 'p':
      // Ignore BCC32 conversion warning
      c = 'y' + offset;
      break;
    case 'q':
      // Ignore BCC32 conversion warning
      c = '5' + offset;
      break;
    case 'Q':
      // Ignore BCC32 conversion warning
      c = 'I' + offset;
      break;
    case 'R':
      // Ignore BCC32 conversion warning
      c = 'I' + offset;
      break;
    case 'r':
      // Ignore BCC32 conversion warning
      c = 'w' + offset;
      break;
    case 's':
      // Ignore BCC32 conversion warning
      c = '9' + offset;
      break;
    case 'S':
      // Ignore BCC32 conversion warning
      c = 'G' + offset;
      break;
    case 'T':
      // Ignore BCC32 conversion warning
      c = 'G' + offset;
      break;
    case 't':
      // Ignore BCC32 conversion warning
      c = 'u' + offset;
      break;
    case 'u':
      // Ignore BCC32 conversion warning
      c = '7' + offset;
      break;
    case 'U':
      // Ignore BCC32 conversion warning
      c = 'E' + offset;
      break;
    case 'V':
      // Ignore BCC32 conversion warning
      c = 'E' + offset;
      break;
    case 'v':
      // Ignore BCC32 conversion warning
      c = 's' + offset;
      break;
    case 'w':
      // Ignore BCC32 conversion warning
      c = '3' + offset;
      break;
    case 'W':
      // Ignore BCC32 conversion warning
      c = 'C' + offset;
      break;
    case 'X': 
      // Ignore BCC32 conversion warning
      c = 'C' + offset;
      break;
    case 'x': 
      // Ignore BCC32 conversion warning
      c = 'q' + offset;
      break;
    case 'y':
      // Ignore BCC32 conversion warning
      c = '1' + offset;
      break;
    case 'Y':
      // Ignore BCC32 conversion warning
      c = 'A' + offset;
      break;
    case 'Z':
      // Ignore BCC32 conversion warning
      c = 'A' + offset;
      break;
    case 'z':
      // Ignore BCC32 conversion warning
      c = 'o' + offset;
      break;
    case '1':
      // Ignore BCC32 conversion warning
      c = 'o' + offset;
      break;
    case '3':
      // Ignore BCC32 conversion warning
      c = 'I' + offset;
      break;
    case '7':
      // Ignore BCC32 conversion warning
      c = 'q' + offset;
      break;
    case '9':
      // Ignore BCC32 conversion warning
      c ='W' + offset;
      break;
    case '5':
      // Ignore BCC32 conversion warning
      c = 'G' + offset;
      break;
    case '0':
      // Ignore BCC32 conversion warning
      c = '9' + offset;
      break;
    case '2':
      // Ignore BCC32 conversion warning
      c = '7' + offset;
      break;
    case '4':
      // Ignore BCC32 conversion warning
      c = '5' + offset;
      break;
    case '6':
      // Ignore BCC32 conversion warning
      c = '3' + offset;
      break;
    case '8':
      // Ignore BCC32 conversion warning
      c = '1' + offset;
      break;
    default:
      break;
  }

  if(!isalnum(c)) return ACE1Aencode(c, offset);
  return 1;
}

int srnGenerator::ACE1Aencode(unsigned char &c, int offset)
// Special rules for non-alphanumerics: (1) All non-alphanumeric
// characters will be converted to even numbers or ever other letter
// of the alphabet depending on its keyboard location: !=Z, @=x, #=U,
// $=t, %=R, ^=p, &=B, *=d, (=F, )=h, -=J, _=l, ==N, +=0, [=8, {=4, ]=2,
// }=z, \=X, |=u, ;=T, :=r, '=P, "=b, <=D, ,=f, >=H, .=j, `=L, ~=n, /=0,
// ?=8. 
{
  int is_printable = 1; // Return true if 'c' is printable
  switch(c) {
    case '!':
      // Ignore BCC32 conversion warning
      c = 'Z' + offset;
      break;
    case '@':
      // Ignore BCC32 conversion warning
      c = 'x' + offset;
      break;
    case '#':
      // Ignore BCC32 conversion warning
      c = 'U' + offset;
      break;
    case '$':
      // Ignore BCC32 conversion warning
      c = 't' + offset;
      break;
    case '%':
      // Ignore BCC32 conversion warning
      c = 'R' + offset;
      break;
    case '^':
      // Ignore BCC32 conversion warning
      c = 'p' + offset;
      break;
    case '&':
      // Ignore BCC32 conversion warning
      c = 'B' + offset;
      break;
    case '*':
      // Ignore BCC32 conversion warning
      c = 'd' + offset;
      break;
    case '(':
      // Ignore BCC32 conversion warning
      c = 'F' + offset;
      break;
    case ')':
      // Ignore BCC32 conversion warning
      c = 'h' + offset;
      break;
    case '-':
      // Ignore BCC32 conversion warning
      c = 'J' + offset;
      break;
    case '_':
      // Ignore BCC32 conversion warning
      c = 'l' + offset;
      break;
    case '=':
      // Ignore BCC32 conversion warning
      c = 'N' + offset;
      break;
    case '+':
      // Ignore BCC32 conversion warning
      c = '0' + offset;
      break;
    case '[':
      // Ignore BCC32 conversion warning
      c = '8' + offset;
      break;
    case '{':
      // Ignore BCC32 conversion warning
      c = '4' + offset;
      break;
    case ']':
      // Ignore BCC32 conversion warning
      c = '2' + offset;
      break;
    case '}':
      // Ignore BCC32 conversion warning
      c = 'z' + offset;
      break;
    case '\\':
      // Ignore BCC32 conversion warning
      c = 'X' + offset;
      break;
    case '|':
      // Ignore BCC32 conversion warning
      c = 'u' + offset;
      break;
    case ';':
      // Ignore BCC32 conversion warning
      c = 'T' + offset;
      break;
    case ':':
      // Ignore BCC32 conversion warning
      c = 'r' + offset;
      break;
    case '\'':
      // Ignore BCC32 conversion warning
      c = 'P' + offset;
      break;
    case '\"':
      // Ignore BCC32 conversion warning
      c = 'b' + offset;
      break;
    case '<':
      // Ignore BCC32 conversion warning
      c = 'D' + offset;
      break;
    case ',':
      // Ignore BCC32 conversion warning
      c = 'f' + offset;
      break;
    case '>':
      // Ignore BCC32 conversion warning
      c = 'H' + offset;
      break;
    case '.':
      // Ignore BCC32 conversion warning
      c = 'j' + offset;
      break;
    case '`':
      // Ignore BCC32 conversion warning
      c = 'L' + offset;
      break;
    case '~':
      // Ignore BCC32 conversion warning
      c = 'n' + offset;
      break;
    case '/':
      // Ignore BCC32 conversion warning
      c = '0' + offset;
      break;
    case '?':
      // Ignore BCC32 conversion warning
      c = '8' + offset;
      break;
    default:
      // Ignore BCC32 conversion warning
      c = 'g' + offset;
      is_printable = 0;
      break;
  }
  return is_printable;
}

#ifdef __BCC32__
#pragma warn .8080
#pragma warn .8071
#endif
// ----------------------------------------------------------- //
// ------------------------------- //
// --------- End of File --------- //
// ------------------------------- //

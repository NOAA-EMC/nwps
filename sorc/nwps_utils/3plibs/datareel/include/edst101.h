// ------------------------------- //
// -------- Start of File -------- //
// ------------------------------- //
// ----------------------------------------------------------- // 
// C++ Header File Name: edst101.h
// C++ Compiler Used: MSVC, BCC32, GCC, HPUX aCC, SOLARIS CC
// Produced By: DataReel Software Development Team
// File Creation Date: 10/15/1999 
// Date Last Modified: 01/01/2009
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

Encoded data set static table.

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
#ifndef __GX_EDS_TABLE__HPP____
#define __GX_EDS_TABLE__HPP____

#include "gxdlcode.h"

// ---------------------------------------------------------------------
// Static EDS table used to encode string for EDS version 3001.101
// ---------------------------------------------------------------------
// NOTE: !!! If any of these values are modified the static encoding
// values will be changed. This will effect all applications using the
// EDS class to encode strings. !!! This table was generated with a
// random seed of "123494." All duplicate entries were automatically
// corrected by the edsString::TestDynamicTable() function.
const unsigned short edsStaticTable[256] = { 
  0x2776, 0x149a, 0x035f, 0x327a, 0x1930,
  0x1675, 0x2233, 0x6d4f, 0x1635, 0x3d58,
  0x6132, 0x6dd8, 0x538c, 0x62fd, 0x08c2,
  0x1a2d, 0x20fb, 0x51e6, 0x4bea, 0x618e,
  0x57d4, 0x48e7, 0x4dc0, 0x7c02, 0x2c12,
  0x57e4, 0x1b25, 0x4d3d, 0x13a4, 0x79dc,
  0x6caf, 0x6ec7, 0x3809, 0x1026, 0x44e7,
  0x255b, 0x261d, 0x22fb, 0x3eb5, 0x458e,
  0x3033, 0x0b35, 0x2018, 0x4bb1, 0x3663,
  0x6956, 0x051a, 0x2af7, 0x4926, 0x0dcc,
  0x3704, 0x17db, 0x5a20, 0x3674, 0x03ce,
  0x51bc, 0x6f3c, 0x455c, 0x29d9, 0x2fca,
  0x0bfe, 0x54cd, 0x2be1, 0x7526, 0x4515,
  0x4c89, 0x212d, 0x3045, 0x3230, 0x5c51,
  0x5608, 0x2996, 0x3213, 0x7faa, 0x5075,
  0x2564, 0x34ea, 0x6ee1, 0x0d1f, 0x7cfd,
  0x00dd, 0x214d, 0x088f, 0x5314, 0x24e4,
  0x44d4, 0x68a1, 0x6764, 0x0ddd, 0x4eb0,
  0x5a39, 0x4d96, 0x71dc, 0x0973, 0x7732,
  0x0b65, 0x05c2, 0x4449, 0x4897, 0x6200,
  0x3111, 0x077e, 0x3916, 0x46af, 0x33fe,
  0x7240, 0x0bb1, 0x4eba, 0x73c8, 0x25a5,
  0x2ab7, 0x1287, 0x6149, 0x60f0, 0x62f3,
  0x4c02, 0x2dcb, 0x3310, 0x5f23, 0x3441,
  0x421c, 0x6569, 0x77ac, 0x6469, 0x2be5,
  0x03d7, 0x2a8b, 0x3dcb, 0x7537, 0x25f0,
  0x4f8f, 0x1d53, 0x1a67, 0x5d8a, 0x5cc5,
  0x5e23, 0x121c, 0x6e7e, 0x4f34, 0x6f7b,
  0x1ba6, 0x33ab, 0x0bcb, 0x01dc, 0x4791,
  0x553d, 0x4c98, 0x0f6d, 0x6e7a, 0x342f,
  0x6e3b, 0x439d, 0x0a22, 0x2f0e, 0x6959,
  0x060a, 0x24c1, 0x2400, 0x45d5, 0x2ca2,
  0x529d, 0x5406, 0x2e7c, 0x1907, 0x69da,
  0x0b7e, 0x59ff, 0x4538, 0x6c94, 0x33ec,
  0x7c67, 0x036f, 0x592b, 0x32f9, 0x0244,
  0x7545, 0x54de, 0x3abc, 0x2fe6, 0x7e1c,
  0x649c, 0x6f39, 0x40d0, 0x34be, 0x2816,
  0x0527, 0x1b6a, 0x1842, 0x4b19, 0x3df7,
  0x6cf6, 0x0c30, 0x211b, 0x6511, 0x41c5,
  0x5fe5, 0x1f14, 0x3261, 0x6dab, 0x6538,
  0x278f, 0x3612, 0x58b0, 0x5a5d, 0x5d00,
  0x695d, 0x0408, 0x2b0a, 0x6e58, 0x01f6,
  0x5b46, 0x4cd9, 0x11d7, 0x7f36, 0x25cc,
  0x3aee, 0x2221, 0x753d, 0x2c86, 0x54d9,
  0x1195, 0x19c2, 0x67d8, 0x24bd, 0x27da,
  0x239b, 0x49d4, 0x50b2, 0x3dba, 0x673b,
  0x78b1, 0x3b69, 0x6b34, 0x1c79, 0x0d78,
  0x180f, 0x5bcc, 0x3193, 0x2b01, 0x7573,
  0x3d26, 0x4f72, 0x011e, 0x046a, 0x7bd3,
  0x732f, 0x1016, 0x1d73, 0x426b, 0x40d7,
  0x4055, 0x4997, 0x6edc, 0x736b, 0x2261,
  0x5293
};

#endif // __GX_EDS_TABLE__HPP____
// ----------------------------------------------------------- //
// ------------------------------- //
// --------- End of File --------- //
// ------------------------------- //

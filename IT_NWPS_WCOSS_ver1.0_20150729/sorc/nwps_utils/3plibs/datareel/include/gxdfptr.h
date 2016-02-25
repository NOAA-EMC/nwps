// ------------------------------- //
// -------- Start of File -------- //
// ------------------------------- //
// ----------------------------------------------------------- //
// C++ Header File Name: gxdfptr.h
// Compiler Used: MSVC, HPUX aCC, SOLARIS CC
// Produced By: DataReel Software Development Team
// File Creation Date: 02/04/1997 
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

The gxDatabase file pointer routines are a collection of classes 
and standalone functions used to define the underlying file system
used by the gxDatabase class. NOTE: None of the data structures
and functions defined here are intended to be used directly. They
are used by the gxDatabase class to call the correct native file
API function for each supported platform.

Changes:
==============================================================
02/01/2002: Add enhanced NTFS compatibility to all WIN32 functions 
by adding WIN32 file I/O. Define the __WIN32__ and __NTFS__ 
preprocessor directives to use the WIN32 file I/O API instead of 
the stdio file I/O.  

03/18/2002: Changed the return types for the gxdFPTRRead() and
gxdFPTRWrite() functions to return the number of bytes read and
moved rather than the returning 0/1 to indicate a pass/fail 
condition. This change was made to support additional classes
throughout the library.
==============================================================
*/
// ----------------------------------------------------------- //  
#ifndef __GX_DATABASE_FILE_POINTER_HPP__
#define __GX_DATABASE_FILE_POINTER_HPP__

#include "gxdlcode.h"

// Select the underlying file system used for the database engine
#if defined (__64_BIT_DATABASE_ENGINE__)
#include "gxdfp64.h" // WIN32 will always use NTFS for large files
typedef gxdFPTR64 gxdFPTR;

#elif defined (__WIN32__) && defined (__NTFS__)
// WIN32 file I/O API
#include <windows.h>
#include <io.h>
#include <string.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <stdio.h>
#include "gxdtypes.h"
#include "gxheader.h"

struct GXDLCODE_API gxdFPTR { // Platform specific file pointer type
  HANDLE fptr;
};

#else // Use the stdio version by default. Common to all platforms.
// Non-platform specific stdio include files
#include <string.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <stdio.h>
#include "gxdtypes.h"
#include "gxheader.h"

struct GXDLCODE_API gxdFPTR { // gxDatabase file pointer type
  FILE *fptr;
};
#endif // gxDatabase file system type

// NOTE: Any underlying file system used must provide the basic
// functionality defined here. 
GXDLCODE_API gxdFPTR *gxdFPTRCreate(const char *fname);
GXDLCODE_API gxdFPTR *gxdFPTROpen(const char *fname, 
				  gxDatabaseAccessMode mode);
GXDLCODE_API int gxdFPTRClose(gxdFPTR *stream);
GXDLCODE_API int gxdFPTRFlush(gxdFPTR *stream);
GXDLCODE_API __ULWORD__ gxdFPTRRead(gxdFPTR *stream, void *buf, 
				    __ULWORD__ bytes);
GXDLCODE_API __ULWORD__ gxdFPTRWrite(gxdFPTR *stream, const void *buf, 
				     __ULWORD__ bytes);
GXDLCODE_API FAU_t gxdFPTRSeek(gxdFPTR *stream, FAU_t, 
			       gxDatabaseSeekMode mode);
GXDLCODE_API FAU_t gxdFPTRTell(gxdFPTR *stream);
GXDLCODE_API int gxdFPTRExists(const char *fname);
GXDLCODE_API FAU_t gxdFPTRFileSize(const char *fname);

#endif // __GX_DATABASE_FILE_POINTER_HPP__
// ----------------------------------------------------------- // 
// ------------------------------- //
// --------- End of File --------- //
// ------------------------------- //

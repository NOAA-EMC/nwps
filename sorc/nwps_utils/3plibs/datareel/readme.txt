DataReel 4.X Readme File
DataReel Copyright (c) 2001-2009 DataReel Software Development, All Rights Reserved 
DataReel is a registered trademark (R) of DataReel Software Development

http://www.datareel.com

CONTENTS
--------
Overview 
Features 
License 
Supported Platforms 
Supported Compilers 
Package Map 
Major Library Changes in Release 4.X
Include and Source File Changes in Release 4.X
Outstanding Issues in Release 4.X
Contributions Needed for Next Release
Example Programs 
Documentation 
Unzipping 
Building BCC Static WIN32 Library 
Building MSVC/C++.NET DLL 
Building MSVC Static Library 
Building UNIX Share/Static Libraries 

OVERVIEW
--------
What is DataReel?
Datareel is a comprehensive cross-platform C++ development kit used to
build multi-threaded database and communication applications. C++ is a
programming language that produces fast executing compiled programs
and offers very powerful programming capabilities. Unlike interpreted
languages such as JAVA and PERL the C++ language by itself does not
contain built-in programming interfaces for database, communications,
and multi-threaded programming. By using DataReel you can extend the
power of the C++ programming language by using high-level programming
interfaces for database, communications, and multi-threaded
programming.

The DataReel development package was produced by independent work and
contract work released to the public through non-exclusive license
agreements. The initial work began independently in 1997 and was
augmented from 1999 to 2004 by code produced under contract to support
various applications. Several developers throughout the World have
made contributions to enhance the DataReel code and promote its
stability. In 2005 the DataReel code library underwent intense
analysis to produce a bulletproof code base suitable for use in
complex commercial applications. 

Why Use DataReel?
DataReel simplifies complex time consuming database, socket, and
multi-threaded programming tasks by providing JAVA like programming
interfaces for database, communications, and multi-threaded
programming. Using DataReel you can harness the full power of the C++
programming language and build stable end-user applications, embedded
systems, and reusable libraries for multiple operating systems. 

DataReel is flexible. Using DataReel gives your developers the
flexibility to develop core application components independently of
complex user interfaces. DataReel is portable. DataReel not only
offers portability but also interoperability between multiple
platforms. DataReel is modular. DataReel is a modular approach to
network and database programming making code adaptation and
cross-platform testing easy. 

Who Can Use DataReel?
The DataReel toolkit is available to commercial, individual, and
academic developers. The DataReel code base is distributed to the
public in an open source format. This keeps the code stable through
the continued support of worldwide developers who submit code
enhancements and report potential problems. The open source format is
also intended to promote the C++ programming language as the language
of choice for any programming task. 

Who Can Contribute?
The DataReel project accepts bug fixes, enhancements, and additions
from all developers. Submissions can be sent directly to the DataReel
Software Development Team via email or online using Web forms. Please
visit the DataReel Website at http://www.datareel.com for the current
team contact information. 
 
FEATURES
--------
Database
 WIN32/UNIX Interoperability
 32-Bit DB Engine
 64-Bit DB Engine
 Large file support
 CRC Checking
 Portable File Locking
 Portable Record Locking
 B-tree Indexing
 Persistent Objects
 Supports OODM Design
 Supports RDBMS Design
 Supports Multi-threading
 Supports Client/Server Apps
 Built-in Network Database
 Real-time TCP Streaming
 Real-time UDP Streaming
 RS232 streaming

Sockets
 WIN32/UNIX Interoperability
 Winsock/BSD Wrappers
 Object-Oriented Design
 Stream Sockets
 Datagram Sockets
 RS232 Support
 Supports Multi-threading
 Embedded Ping
 Embedded FTP
 Embedded Telnet
 Embedded SMTP
 Embedded POP3
 Embedded HTTP
 URL Parsing
 HTML Parsing
 HTML Generator
 Embedded SSL
 XML Parsing

Threads
 WIN32/UNIX Interoperability
 Windows/POSIX Wrappers
 Object-Oriented Design 
 Thread Creation/Construction 
 Thread Destruction 
 Cancellation 
 Exit 
 Join 
 Suspend 
 Resume 
 Sleep 
 Priority Functions 
 Thread Specific Storage 
 Thread Pooling
 Mutex Locks 
 Conditional Variables 
 Semaphore Synchronization

General
 String Classes
 Memory Buffers
 Device Caching
 Linked List Classes
 Binary Search Tree
 Stack Classes
 Queue Classes
 Date/Time Classes
 Configuration Manager
 Log Generator
 Postscript Text Generator
 Portable TERM I/O
 Text Utilities
 String Utilities
 Portable Directory Functions
 Portable File Functions

LICENSE
-------
The DataReel open source library is copyrighted by DataReel Software
Development, Copyright (C) 2001-2005, all rights reserved. DataReel is
a registered trademark (R) of DataReel Software Development. DataReel
open source is available to non-profit, commercial, individual, and
academic developers. The open-source archive is distributed under the
OSI approved GNU Lesser General Public License (LGPL) with provisions
for use in commercial and non-commercial applications under the terms
of the LGPL. 

Under the terms of the LGPL you can use the open source code in
commercial applications as a static or dynamically linked
library. This allows commercial developers to compile the library and
link to it without making any changes to the DataReel source code. 

GNU Lesser General Public License 
This library is free software; you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as
published by the Free Software Foundation; either version 2.1 of the
License, or (at your option) any later version.  

This library is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
Lesser General Public License for more details.  

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
USA  

SUPPORTED PLATFORMS
-------------------
The following is the current list of operating systems used for
development and cross-platform testing. If the operating system you
are using is not listed please contact the DataReel support team as
this list may change without notice.  

Original and Supported Platforms 
* HPUX 10.20 
* HPUX 11.0 
* MSDOS 6.22 (Limited Support) 
* RedHat Linux 5.X/6.X/7.X/8.0/9.0/Fedora Core 2-4/Enterprise 2.1-4.0
* Solaris 2.8 
* Windows 95A/95C 
* Windows 98/98SE 
* Windows NT 4.0 SP4-6 
* Windows ME 
* Windows 2000 SP2-SP4
* Windows 2000 Server SP2-SP4
* Windows XP Home/Professional 
* Windows 2003 Server

DataReel release 4.X final deployment UNIX testing was preformed under
RedHat Enterprise Linux 4.0 gcc version 3.4.4 20050721 (Red Hat
3.4.4-2) 2.6.9-22.Elsmp Kernel. Development system used was a RedHat
certified Dell Precision workstation with 1G of system memory. 

DataReel release 4.X final deployment Windows testing was preformed
under Windows XP professional using the Microsoft Visual C++ compiler
version 6.0 SP6 and MS Visual C++ .NET version 7. Development system
used was a Dell Optiplex desktop with 1G of system memory. 
      
SUPPORTED COMPILERS
-------------------
The following is the current list of compilers used for development
and cross-platform testing. If the compiler you are using is not
listed please contact the DataReel support team as this list may
change without notice.  

C++ Compiler list 
* HPUX Native C++ Compiler - HP C++ HPCPLUSPLUS A.10.27
* HPUX Native C++ Compiler - HP aC++ B3910B A.03.30 compiled for HP-UX 11.0 
  HP aC++ B3910B A.03.27 Language Support Library
* 16-Bit MSDOS C++ Compiler - MSVC 1.52 (Limited Support)
* 32-Bit MSDOS C++ Compiler - DJGPP 2.7.2.1 (Limited Support)
* 32-Bit Windows C++ Compiler - MSVC 4.2, MSVC 5.0, MSVC 6.0 SP6, MS Visual C++ .NET, BCC32 5.X, BCC32 6.0 
* gcc version 3.4.4 20050721 (Red Hat 3.4.4-2)
* Solaris Native C++ Compiler - Sun C++ 5.0 (4.2 compatibility mode)

PACKAGE MAP
-----------
The DataReel Windows and UNIX archives are identical and can be
unpacked on either platform depending on the decompression tools
available to you. In order to remain consistent with multiple
archiving schemes all files and directories conform to the ISO 9660
8.3 naming convention. The directory structure for the distribution is
as follows:  

DataReel Directory 
* bin - Empty directory used to install executables
* contrib - Directory used to install contribution packages
* dll - Build directory for WIN32 DLLs
* docs - Directory for all DataReel documentation sets
* env - Makefile includes used to build libraries and example programs
* examples.gen - General support example programs
* examples.db - Database example programs
* examples.mt - Thread example programs
* examples.soc - Socket example programs
* include - DataReel include files
* lib - Empty directory used to install library files
* src - DataReel source code files
* unixlib - Build directory for UNIX static/shared libraries
* utils - DataReel utility programs
* winslib - Build directory for static WIN32 libraries

MAJOR LIBRARY CHANGES IN RELEASE 4.X
------------------------------------
* Added Unicode support to the DataReel string class that allows the
  use of ASCII and Unicode strings 
* Version 4.3.1 includes a new relational database manager and several
  RDBMS classes
* A new gxDatabase debug manager class was added to support database
  debug operations in OODBM and RDBMS implementations 
* Added gxSSL class to support HTTPS client and server applications 

OUTSTANDING ISSUES IN RELEASE 4.X
---------------------------------
Items pending following this public release version. 

CONTRIBUTIONS NEEDED FOR NEXT RELEASE
-------------------------------------
* HPUX and Solaris beta testers 
* Add MSVC project files for the Visual Studio IDE
* Add UNIX configure scripts
* Start IPV6 testing and add the IP128 class

EXAMPLE PROGRAMS
----------------
The DataReel library includes over 100 console-based example
programs. The examples are fully functional programs used to test and
demonstrate each component of the library individually. The example
programs are located within subdirectories of the "examples.gen",
"examples.db", "examples.mt", and "examples.soc" directories. NOTE: In
release 4.X you must build the DataReel library before building any of
the example or utility programs. All examples and utilities are built
using an include makefile located in the env subdirectory. 

WIN32 Makefiles
msvc.mak - Microsoft Visual C/C++ 6.0 SP3 or Microsoft Visual C++ .NET
bcc32.mak - Borland BCC32 5.5

UNIX Makefiles
hpux10.mak - HPUX front-end compiler
hpux11.mak - HPUX aCC compiler
linux.mak - gcc compiler
solaris.mak - Sun WorkShop C++ compiler

DOCUMENTATION
-------------
The complete DataReel 4.X documentation set is available in an HTML
format. The DataReel HTML documentation set is distributed with each
DataReel source code distribution. Updated versions and all changes
are posted to the DataReel Web Site: 

http://www.datareel.com/documentation/

UNZIPPING
---------
The entire DataReel distribution requires approximately 8 MB of free
disk space to unpack. Two distributions are available, one for Windows
and one for UNIX. The DataReel Windows and UNIX archives are identical
and can be unpacked on either platform depending on the decompression
tools available to you.  

Windows Installation
To unpack this distribution on a Windows platform you will need a copy
of PKZIP version 2.03 for DOS or WINZIP version 6.1 or higher for
WIN32. To unzip using PKZIP 2.03 follow these instructions:  

C:\>mkdir datareel
C:\>copy dreelXXX.zip c:\datareel
C:\>cd datareel
C:\datareel>pkunzip -d dreelXXX.zip

UNIX Installation
To unpack this distribution you need a copy GZIP/GUNZIP version 1.2.4
or higher. To unpack using GZIP and the UNIX tar utility follow these
instructions:  

% gzip -d dreelXXX.tgz
% tar xvf dreelXXX.tar

To unpack using GUNZIP and the UNIX tar utility follow these instructions:

% gunzip dreelXXX.tgz 
% tar xvf dreelXXX.tar

To unpack using the UNIX uncompress utility follow these instructions:

% zcat dreelXXX.tar.Z | tar xvf -

NOTE: You can also use the UNIX uncompress utility to unpack GZIP files:

% zcat dreelXXX.tgz | tar xvf -

NOTE: You can also use UNZIP for UNIX version 5.12 or higher to unpack the zip archive: 

% mkdir datareel
% cp dreelXXX.zip datareel/dreelXXX.zip
% cd datareel

% unzip -a -L dreelXXX.zip

The unzip "-a" option will auto-convert all text files to a UNIX
format and the "-L" option will make the directory and file names all
lower case.  

BUILDING THE BCC STATIC WIN32 LIBRARY
-------------------------------------
The BCC32 makefiles requires you to build the BCC static library are
located in the winslib subdirectory. To build the library using the
BCC make utility execute the following command:  

C:\DataReel\winslib>make -f bcc32.mak 

This will build the 32-bit static library. To build the 64-bit library
you must uncomment the following line in the winslib\bcc32.env file
and rebuild the static library: 

64BIT_DEFMACS = -D__64_BIT_DATABASE_ENGINE__

C:\DataReel\winslib>make -f bcc32.mak clean
C:\DataReel\winslib>make -f bcc32.mak

NOTE: Before building the example programs or the utility programs
using the BCC compiler you must set the absolute path to the DataReel
library in the env\bcc.mak file: 
 
GCODE_LIB_DIR = C:\DataReel 

If you are using the Borland IDE to build the library, examples, or
utility programs please refer to the winslib\bcc32.env file for the
required preprocessor directives, library dependencies, compiler and
linker flags.  

BUILDING THE MSVC OR C++.NET DLL
--------------------------------
The MSVC/C++.NET makefiles requires you to build the MSVC DLL are
located in the dll subdirectory. To build the DLL using the MSVC/
C++.NET nmake utility execute the following command:  

C:\DataReel\dll>nmake -f msvc.mak 

The will build both the 32-bit release and debug DLLs and place them
in the C:\DataReel\dll\release and C:\DataReel\dll\debug
directories. If you are using the MSVC or C++.NET Visual Studio to
build the library, examples, or utility programs please refer to the
dll\msvc.env file for the required preprocessor directives, library
dependencies, compiler and linker flags.  

To build the 64-bit DLL execute the following commands:

C:\DataReel\dll>nmake -f msvc.mak clean
C:\DataReel\dll>nmake -f msvc.mak 64BITCFG=1

NOTE: Before any executable can be launched you must install the DLL
or set a path to the DLL. The DLL can be installed in the directory
with the executable, in the Windows system directory, or be visible in
any set path. To set the DLL path for the current console window
execute the following command: 

C:\>set path=%path%;C:\DataReel\dll\release;C:\DataReel\dll\debug

BUILDING THE MSVC OR C++.NET STATIC LIBRARY
-------------------------------------------
To build the static library using the MSVC/C++.NET nmake utility
execute the following command:  

C:\DataReel\winslib\>nmake -f msvc.mak 

This will build the 32-bit debug library. To build the release library
utility execute the following commands: 

C:\DataReel\winslib\>nmake -f msvc.mak clean
C:\DataReel\winslib\>nmake -f msvc.mak FINAL=1

To build the 64-bit static library execute the following commands:

C:\DataReel\winslib\>nmake -f msvc.mak clean
C:\DataReel\winslib\>nmake -f msvc.mak FINAL=1 64BITCFG=1

If you are using the MSVC or C++.NET Visual Studio to build the
library, examples, or utility programs please refer to the
winslib\msvc.env file for the required preprocessor directives,
library dependencies, compiler and linker flags.  

NOTE: None of the example or utility programs will link to the
MSVC/C++.NET static library. If wish to link to the static library
instead of the dynamic one you must modify the msvc include makefile
located in the env subdirectory.  

BUILDING UNIX SHARE AND STATIC LIBRARIES
----------------------------------------
The UNIX makefiles require you to build the UNIX static/shared
libraries located in the unixlib subdirectory. To build the library
using the UNIX make utility execute the following command for one of
the supported UNIX platforms:  

% make -f linux.mak
% make -f solaris.mak
% make -f hpux10.mak
% make -f hpux11.mak 

This will generate the "libgxcode.a" static 32-bit library and the
"libgxcode.so.4.X" shared 32-bit library. To build the 64-bit library
for Linux, Solaris, or HPUX 11 you must uncomment the following line
in the unixlib/linux.mak, unixlib/solaris.mak, or unixlib/hpux11.mak
makefile and rebuild the library: 

64BIT_DEFMACS = -D__64_BIT_DATABASE_ENGINE__ -D_LARGEFILE64_SOURCE

% make -f linux.mak clean
% make -f linux.mak

% make -f solaris.mak clean
% make -f solaris.mak

% make -f hpux11.mak clean
% make -f hpux11.mak

NOTE: By default the example and utility programs will link to the
static version unless the libgxcode.so.4.X is symbolically linked or
renamed to libgxcode.so in the unixlib build directory. Before
executing any executable linked to a shared UNIX library you must make
the library visible to the system's dynamic loader. To do this either
install the library in a default lib directory such as /usr/local/lib,
/usr/lib, or /lib or set the LD_LIBRARY_PATH environment variable
equal to the absolute path of the directory containing the
library. NOTE: Before setting the LD_LIBRARY_PATH check to see if the
variable has already been set: 

echo $LD_LIBRARY_PATH 

If the LD_LIBRARY_PATH variable is not set execute one of the
following commands depending on which shell you are using: 

/bin/csh
setenv LD_LIBRARY_PATH /usr/local/datareel/dreelXXX/lib

/bin/sh
LD_LIBRARY_PATH=/usr/local/datareel/dreelXXX/lib 
export LD_LIBRARY_PATH

If the LD_LIBRARY_PATH variable is set execute one of the following
commands depending on which shell you are using: 

/bin/csh
setenv LD_LIBRARY_PATH /usr/local/datareel/dreelXXX/dlib:${LD_LIBRARY_PATH}
   
/bin/sh   
LD_LIBRARY_PATH=/usr/local/datareel/dreelXXX/dlib:${LD_LIBRARY_PATH}
export LD_LIBRARY_PATH

To install the library in the DataReel lib directory execute a "make
install" from the command line. This will copy the libgxcode.a and
libgxcode.so.4.X files to the DataReel lib directory and create a
symbolic link from libgxcode.so.4.X to libgxcode.so. NOTE: When a UNIX
compiler sees both a static and shared library in the same directory
it will always link to the shared library first.  

DataReel Copyright (c) 2001-2009 DataReel Software Development, All Rights Reserved 
DataReel is a registered trademark (R) of DataReel Software Development

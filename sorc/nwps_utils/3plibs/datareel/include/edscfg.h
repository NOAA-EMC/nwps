// ------------------------------- //
// -------- Start of File -------- //
// ------------------------------- //
// ----------------------------------------------------------- // 
// C++ Header File Name: edscfg.h
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

Code used to generate encoded program configuration files.

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
02/08/2002: All EDS Config functions using non-persistent file 
address units have been modified to use FAU_t data types instead 
of FAU types. FAU_t types are native or built-in integer types 
and require no additional overhead to process. All persistent 
file address units still use the FAU integer type, which is a 
platform independent type allowing database files to be shared 
across multiple platforms.

10/13/2002: Remove all function with non-const char * type
arguments.
==============================================================
*/
// ----------------------------------------------------------- // 
#ifndef __GX_EDSCFG_HPP__
#define __GX_EDSCFG_HPP__

#include "gxdlcode.h"

#include "eds101.h"
#include "gxlistb.h"
#include "ustring.h"
#include "gxdbase.h"

#ifdef __BCC32__
#pragma warn -8022
#endif

// Configuration data nodes 
struct GXDLCODE_API edsConfigNode
{
  edsConfigNode() { }
  edsConfigNode(const UString &s) { str = s; address = gxCurrAddress; }
  edsConfigNode(const UString &s, FAU_t a) { str = s; address = a; }
  edsConfigNode(const edsConfigNode &ob) {
    address = ob.address;    
    str = ob.str;
  }
  edsConfigNode &operator=(const edsConfigNode &ob) {
    address = ob.address;    
    str = ob.str;
    return *this;
  }
  ~edsConfigNode() { }
  
  GXDLCODE_API friend int operator==(const edsConfigNode &a, 
				     const edsConfigNode &b) {
    return a.str == b.str;
  }

  FAU address;    
  UString str;
};

class GXDLCODE_API edsConfigListNode: public gxListNodeB
{
public:
  edsConfigListNode() { data = (void *)&node_data; } 
  edsConfigListNode(const edsConfigNode &X) : node_data(X) {
    data = (void *)&node_data;
  } 

public:
  edsConfigListNode *GetNext() { return (edsConfigListNode *)next; }
  const edsConfigListNode *GetNext() const {
    return (edsConfigListNode *)next;
  }

public:
  edsConfigNode node_data;
};

class GXDLCODE_API edsConfig : public edsString, public gxListB
{
public:
  edsConfig();
  edsConfig(const UString &fname);
  edsConfig(const char *fname);

  // Constructors add to set the parameter ID string
  edsConfig(const UString &fname, const UString &p_id);
  edsConfig(const UString &fname, const char *p_id);
  ~edsConfig();

private:
  edsConfig(const edsConfig &ob) { }      // Disallow copying
  void operator=(const edsConfig &ob) { } // Disallow assignment

public: // Functions used to load and unload config file
  int Load();
  int Load(const char *fname);
  int Load(const UString &fname);
  int ReLoad();
  int ReLoad(const char *fname);
  int ReLoad(const UString &fname);
  void UnLoad();
  char *GetFileName() { return FileName.c_str(); }
  void SetFileName(const UString &s) { FileName = s; }
  void SetFileName(const char *s) { FileName = s; }
 
public: // Formatting functions
  // Treat all characters after the ID string as a parameter value
  void SetParmID(const UString &s) { parm_ID = s; }
  void SetParmID(const char *s) { parm_ID = s; }
  char *GetParmID() { return parm_ID.c_str(); }
  char GetCommentChar() { return comment_char; }
  void SetCommentChar(char c) { comment_char = c; }
  void FilterComments() { filter_comments = 1; }
  void ReadComments() { filter_comments = 0; }
  
public: // Functions used to read config file values
  double GetFloatValue(const char *Name);    
  double GetFloatValue(const UString &Name); 
  char* GetStrValue(const char *Name);    
  char* GetStrValue(const UString &Name); 
  int GetIntValue(const char *Name);      
  int GetIntValue(const UString &Name);   
  long GetLongValue(const char *Name);    
  long GetLongValue(const UString &Name); 

public: // Functions used to write config values
  int WriteConfigLine(const UString &parm, const UString &value);
  int WriteConfigLine(const char *parm, const char *value);
  int WriteCommentLine(const UString &s);
  int WriteCommentLine(const char *s);
  int WriteLine(const UString &s);
  int WriteLine(const char *s);
  int ChangeConfigValue(const UString &parm, const UString &value);
  int ChangeConfigValue(const char *parm, const UString &value);
  int ChangeConfigValue(const UString &parm, const char *value);
  int ChangeConfigValue(const char *parm, const char *value);
  int ChangeConfigValue(const UString &parm, int value);
  int ChangeConfigValue(const char *parm, int value);
  int ChangeConfigValue(const UString &parm, unsigned value);
  int ChangeConfigValue(const char *parm, unsigned value);
  int ChangeConfigValue(const UString &parm, long value);
  int ChangeConfigValue(const char *parm, long value);
  int ChangeConfigValue(const UString &parm, float value);
  int ChangeConfigValue(const char *parm, float value);
  int ChangeConfigValue(const UString &parm, double value);
  int ChangeConfigValue(const char *parm, double value);

public: // Linked list functions
  edsConfigListNode *Find(const edsConfigNode &X, edsConfigListNode *ptr=0);

  // Ignore BCC32 hidden virtual function warning
  edsConfigListNode *Add(const edsConfigNode &X);

private: // Internal processing functions
  int StoreCfgData(const edsWORD *eds_string, FAU_t addr);
  int ChangeConfigLine(const UString &parm, const UString &value);
  int ConnectConfigFile();
  
public: // GXD File functions
  int Write(const char *s, FAU_t addr = (FAU_t)0);
  edsWORD *Read(FAU_t addr = gxCurrAddress);
  gxDatabaseError Open(const UString &fname);
  gxDatabaseError Disconnect();
  gxDatabaseError Create(const UString &fname);
  gxDatabaseError Create(const char *fname);
  gxDatabaseError Flush();
  gxDatabaseError Close() { return Disconnect(); }
  gxDatabase *OpenDatabase() { return opendatabase; }
  gxDatabase *OpenDatabase() const { return opendatabase; }
  int Exists() const { return exists; }
  int Exists() { return exists; }

private:
  gxDatabase *opendatabase; // GXD file pointer to the data file
  int exists;               // True if data file already exists

private: // Config manager members
  UString FileName;    // Name of the configuration file
  UString parm_ID;     // String used identify parameters in the file
  char comment_char;   // Char used to ID comments in the config file
  int filter_comments; // If true all comments will be ignored
};

#ifdef __BCC32__
#pragma warn .8022
#endif

#endif // __GX_EDSCFG_HPP__
// ----------------------------------------------------------- //
// ------------------------------- //
// --------- End of File --------- //
// ------------------------------- //

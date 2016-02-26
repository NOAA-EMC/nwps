// ------------------------------- //
// -------- Start of File -------- //
// ------------------------------- //
// ----------------------------------------------------------- // 
// C++ Source Code File Name: edscfg.cpp
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
10/13/2002: Remove all function with non-const char * type
arguments.
==============================================================
*/
// ----------------------------------------------------------- // 
#include "gxdlcode.h"

#include "stdlib.h"
#include "edscfg.h"

#ifdef __BCC32__
#pragma warn -8080
#endif

edsConfig::edsConfig()
{
  parm_ID = "="; comment_char = '#';
  filter_comments = 1;
  opendatabase = 0;
  exists = 0; // PC-lint 05/25/2002: exists not initialized by constructor
}

edsConfig::edsConfig(const UString &fname)
{
  FileName = fname; parm_ID = "="; comment_char = '#';
  filter_comments = 1;
  opendatabase = 0;
  ConnectConfigFile();
}

edsConfig::edsConfig(const char *fname)
{
  FileName = fname; parm_ID = "="; comment_char = '#';
  filter_comments = 1;
  opendatabase = 0;
  ConnectConfigFile();
}

edsConfig::edsConfig(const UString &fname, const UString &p_id)
{
  FileName = fname; parm_ID = p_id;
  opendatabase = 0;
  ConnectConfigFile();
}

edsConfig::edsConfig(const UString &fname, const char *p_id)
{
  FileName = fname; parm_ID = p_id;
  opendatabase = 0;
  ConnectConfigFile();
}

edsConfig::~edsConfig()
{
  // PC-lint 09/08/2005: Function may throw exception in destructor
  UnLoad();
  Close();
}

void edsConfig::UnLoad()
{
  ClearList();
}

int edsConfig::ReLoad()
{
  UnLoad();
  return Load();
}

int edsConfig::ReLoad(const char *fname)
{
  UnLoad();
  return Load(fname);
}

int edsConfig::ReLoad(const UString &fname)
{
  UnLoad();
  return Load(fname);
}

int edsConfig::Load(const char *fname)
{
  FileName = fname;
  return Load();
}

int edsConfig::Load(const UString &fname)
{
  FileName = fname;
  return Load();
}

int edsConfig::ConnectConfigFile()
// Connects the config file to this eds config object.
// Will create the config file if it does not exist.
// Return false if an error occurred. 
{
  if(!gxDatabase::Exists(FileName.c_str())) {
    if(Create(FileName) != gxDBASE_NO_ERROR) return 0;
    exists = 0;
  }
  else {
    // Open the data file and check for errors
    if(Open(FileName) != gxDBASE_NO_ERROR) return 0; 
    exists = 1;
  }
  return 1;
}

int edsConfig::Load()
// Load the encoded configuration file in memory.
// Return false if an error occurred. 
{
  if(!opendatabase) return 0; // No database is open
  
  // Check for database errors to prevent program crashes
  if(opendatabase->GetDatabaseError() != gxDBASE_NO_ERROR) return 0;
  
  FAU_t oa;           // Object Address
  gxBlockHeader gx; // Block Header
  FAU_t gxdfileEOF = opendatabase->GetEOF();
  FAU_t addr = 0;
  addr = opendatabase->FindFirstBlock(addr); // Search the entire file
 
  edsWORD *eds_string;

  if(addr == (FAU_t)0) return 0; // No database blocks found in file
  
  while(1) { // PC-lint 05/24/2002: while(1) loop
    if(addr >= gxdfileEOF) break;
    if(opendatabase->Read(&gx, sizeof(gxBlockHeader), addr) !=
       gxDBASE_NO_ERROR) {
      return 0;
    }
    if(gx.block_check_word == gxCheckWord) {
      if((__SBYTE__)gx.block_status == gxNormalBlock) {
	oa = addr + (__LWORD__)opendatabase->BlockHeaderSize();
	eds_string = Read(oa);
	if(addr == gxCurrAddress) addr = opendatabase->FilePosition();
        if(!StoreCfgData(eds_string, addr)) {
	  delete eds_string;
	  return 0;
	}
	delete eds_string; // Free the memory allocated for the string
      }
      addr = addr + gx.block_length; // Go to the next database block
    }
    else {
      addr = opendatabase->FindFirstBlock(addr); 
      if(!addr) break;
    }
  }

  return 1;
}

char* edsConfig::GetStrValue(const UString &Name)
// Search for string matching the "Name" variable. 
{
  edsConfigListNode *ptr;
  edsConfigNode node(Name);
  ptr = Find(node);
  if(ptr) return ptr->GetNext()->node_data.str.c_str(); // Return config value
  return 0;
}

char* edsConfig::GetStrValue(const char *Name)
{
  UString buf(Name);
  return GetStrValue(buf);
}

int edsConfig::GetIntValue(const UString &Name)
// Search for string matching the "Name" variable. Will search
// using the full name unless the "fn" variable is false.
{
  edsConfigListNode *ptr;

  ptr = Find(Name);
  if(ptr) return ptr->GetNext()->node_data.str.Atoi();

  //Return NULL if config value is not found
  return 0;
}

int edsConfig::GetIntValue(const char *Name)
{
  UString buf(Name);
  return GetIntValue(buf);
}

double edsConfig::GetFloatValue(const UString &Name)
// Search for string matching the "Name" variable. Will search
// using the full name unless the "fn" variable is false.
{
  edsConfigListNode *ptr;

  ptr = Find(Name);
  if(ptr) return ptr->GetNext()->node_data.str.Atof();

  //Return NULL if config value is not found
  return 0;
}

double edsConfig::GetFloatValue(const char *Name)
{
  UString buf(Name);
  return GetFloatValue(buf);
}

long edsConfig::GetLongValue(const UString &Name)
// Search for string matching the "Name" variable. Will search
// using the full name unless the "fn" variable is false.
{
  edsConfigListNode *ptr;

  ptr = Find(Name);
  if(ptr) return ptr->GetNext()->node_data.str.Atol();

  //Return NULL if config value is not found
  return 0;
}

long edsConfig::GetLongValue(const char *Name)
{
  UString buf(Name);
  return GetLongValue(buf);
}

// Function used to write to the config file
// --------------------------------------------------------------
int edsConfig::WriteConfigLine(const UString &parm, const UString &value)
// Write a line to the config file.  NOTE: All parameter values should
// not contain a parameter ID label at the end of the string. The 
// parameter ID label will be added to mark it as a config file parameter.
// By default an equal sign will be used as a parameter ID.
{
  UString sbuf;
  sbuf += parm; sbuf += parm_ID; sbuf += value;
  return Write(sbuf.c_str());
}  

int edsConfig::WriteConfigLine(const char *parm, const char *value)
{
  UString p(parm); UString v(value);
  return WriteConfigLine(p, v);
}

int edsConfig::WriteCommentLine(const UString &s)
// Write a comment line to the config file.  NOTE: Do not include the
// comment ID character. The comment ID will by automatically inserted.
{
  UString sbuf;
  sbuf += comment_char; sbuf+= " "; sbuf += s;
  return Write(sbuf.c_str());
}  

int edsConfig::WriteCommentLine(const char *s)
{
  UString cm(s);
  return WriteCommentLine(cm);
}

int edsConfig::WriteLine(const UString &s)
// Write a line of text to the config file.  
{
  return Write(s.c_str());
}  

int edsConfig::WriteLine(const char *s)
{
  return Write(s);
}

int edsConfig::ChangeConfigLine(const UString &parm, const UString &value)
// This function is used to replace strings in the config file.
{
  edsConfigListNode *ptr = 0;
  edsConfigNode node(parm);
  ptr = Find(node);
  if(!ptr) return 0;
  FAU_t addr = ptr->GetNext()->node_data.address;
  UString sbuf;
  sbuf += parm; sbuf += parm_ID; sbuf += value;
  return Write(sbuf.c_str(), addr); // Overwrite the existing value
}

int edsConfig::ChangeConfigValue(const UString &parm, const UString &value)
// Modify the config file. NOTE: All parameter values should not contain 
// a parameter ID label at the end of the string. The parameter ID label
// will be added to mark it as a config file parameter. By default an
// equal sign will be used as a parameter ID.
{
  int rv = ChangeConfigLine(parm, value);

  // Write the parameter if it does not exist
  if(!rv) return WriteConfigLine(parm, value);

  return rv;
}

int edsConfig::ChangeConfigValue(const UString &parm, const char *value)
{
  UString v(value);
  return ChangeConfigValue(parm, v);
}

int edsConfig::ChangeConfigValue(const char *parm, const UString &value)
{
  UString p(parm);
  return ChangeConfigValue(p, value);
}

int edsConfig::ChangeConfigValue(const char *parm, const char *value)
{
  UString p(parm); UString v(value);
  return ChangeConfigValue(p, v);
}

int edsConfig::ChangeConfigValue(const UString &parm, int value)
{
  UString val;
  val << value;
  return ChangeConfigValue(parm, val);
}

int edsConfig::ChangeConfigValue(const char *parm, int value)
{
  UString p(parm);
  return ChangeConfigValue(p, value);
}

int edsConfig::ChangeConfigValue(const UString &parm, unsigned value)
{
  UString val;
  val << value;
  return ChangeConfigValue(parm, val);
}

int edsConfig::ChangeConfigValue(const char *parm, unsigned value)
{
  UString p(parm);
  return ChangeConfigValue(p, value);
}

int edsConfig::ChangeConfigValue(const UString &parm, long value)
{
  UString val;
  val << value;
  return ChangeConfigValue(parm, val);
}

int edsConfig::ChangeConfigValue(const char *parm, long value)
{
  UString p(parm);
  return ChangeConfigValue(p, value);
}

int edsConfig::ChangeConfigValue(const UString &parm, float value)
{
  UString val;
  val << value;
  return ChangeConfigValue(parm, val);
}

int edsConfig::ChangeConfigValue(const char *parm, float value)
{
  UString p(parm);
  return ChangeConfigValue(p, value);
}
  
int edsConfig::ChangeConfigValue(const UString &parm, double value)
{
  UString val;
  val << value;
  return ChangeConfigValue(parm, val);
}

int edsConfig::ChangeConfigValue(const char *parm, double value)
{
  UString p(parm);
  return ChangeConfigValue(p, value);
}

gxDatabaseError edsConfig::Open(const UString &fname)
{
  gxDatabaseError err = Disconnect();
  if(err != gxDBASE_NO_ERROR) return err;

  // PC-lint 05/25/2002: PC-lint warns of potential memory leak
  // but any heap space memory is freed by the Disconnect() call
  // made prior to allocating memory for the open database variable.
  opendatabase = new gxDatabase;
  if(!opendatabase) return gxDBASE_MEM_ALLOC_ERROR;
  return opendatabase->Open(fname.c_str(), gxDBASE_READWRITE);
}

gxDatabaseError edsConfig::Create(const char *fname)
{
  UString sbuf(fname);
  return Create(sbuf);
}

gxDatabaseError edsConfig::Create(const UString &fname)
{
  gxDatabaseError err = Disconnect();
  if(err != gxDBASE_NO_ERROR) return err;

  // PC-lint 09/08/2005: PC-lint warns of potential memory leak
  // but any heap space memory is freed by the Disconnect() call
  // made prior to allocating memory for the open database variable.
  opendatabase = new gxDatabase;
  if(!opendatabase) return gxDBASE_MEM_ALLOC_ERROR;
  return opendatabase->Create(fname.c_str());
}

edsWORD *edsConfig::Read(FAU_t addr)
{
  edsWORD *eds_string = new edsWORD[edsMaxLine];
  unsigned eds_length = sizeof(edsWORD) * edsMaxLine;

  eds_string[0] = 0;
  
  if(opendatabase) {
    // Check for database errors to prevent program crashes
    if(opendatabase->GetDatabaseError() == gxDBASE_NO_ERROR) 
      opendatabase->Read(eds_string, eds_length, addr);
  }
  
  return eds_string;
}

int edsConfig::Write(const char *s, FAU_t addr)
// Write an encoded string to a database block.
// NOTE: The block size for encoded strings is fixed
// length. The block size is set by the edsMaxLine
// constant. Additionally, no blocks will be deleted.
// Blocks that need to be changed will be overwritten.
// Blocks that need to be deleted will be removed with
// a comment character starting at the beginning of the
// string.
{
  if(!opendatabase) return 0; // No database is open
  
  // Check for database errors to prevent program crashes
  if(opendatabase->GetDatabaseError() != gxDBASE_NO_ERROR) return 0;

  char *p = (char *)s;
  unsigned len = strlen(s);
  if(len > edsMaxLine)  // Compensate for buffer overflows
    len = edsMaxLine-1; // Leave room for end of text marker
  unsigned i = 0;

  // Allocate an array of eds words
  edsWORD *eds_string = new edsWORD[edsMaxLine];
  unsigned eds_length = sizeof(edsWORD) * edsMaxLine;

  // Clear the encoded data set
  for(i = 0; i < edsMaxLine; i++) { 
    eds_string[i] = edsEOT; // Insert the end of text markers
  }
  
  // Encode the string
  for(i = 0; i < len; i++) {
    eds_string[i] = EncodeString((unsigned char)*p++);
  }

  if(addr == (FAU_t)0) { // Allocated new block
    addr = opendatabase->Alloc(eds_length);
    if(opendatabase->Write(eds_string, eds_length) != gxDBASE_NO_ERROR) {
      // PC-lint 05/25/2002: Must free eds_string before returning
      delete[] eds_string;
      return 0;
    }
  }
  else { // Write the block to the specified address
    // Do not overwrite existing GX header
    addr += (__LWORD__)opendatabase->BlockHeaderSize(); 
    if(opendatabase->Write(eds_string, eds_length, addr) != gxDBASE_NO_ERROR) {
      // PC-lint 05/25/2002: Must free eds_string before returning
      delete[] eds_string;
      return 0;
    }
  }

  // PC-lint 05/25/2002: Must call edsWORD destructor for each element
  // of the array.
  delete[] eds_string;
  return 1;
}

gxDatabaseError edsConfig::Disconnect()
// Disconnects the database from the file.
{
  if(opendatabase) {
    if(opendatabase->GetDatabaseError() == gxDBASE_NO_ERROR){
      gxDatabaseError err = opendatabase->Close();
      if(err != gxDBASE_NO_ERROR) return err;
    }
    delete opendatabase;
  }
  opendatabase = 0;
  return gxDBASE_NO_ERROR;
}

int edsConfig::StoreCfgData(const edsWORD *eds_string, FAU_t addr)
// Store the configuration data in memory after decoding the
// encoded data set. Returns false if memory allocation fails.
{
  char str[edsMaxLine];
  unsigned i = 0;
  for(i = 0; i < edsMaxLine; i++) str[i] = 0; // Clear the string buffer

  for(i = 0; i < edsMaxLine; i++) {
    unsigned char c;
    if(eds_string[i] == edsEOT) break;
    if(DecodeString(eds_string[i], c)) str[i] = c;
  }
  edsConfigListNode *chsptr;
  UString buf(str);
  edsConfigNode eds_node;
  
  // Remove any leading space 
  int offset = buf.Find(" ");
  if(offset == 0) buf.DeleteAt(offset, 1);

  if(filter_comments) { // Ignore all lines starting with a comment ID
    if(buf[0] == comment_char)
      return 1; 
  }
  
  // Look for lines containing a parm ID string
  offset = buf.Find(parm_ID.c_str());
  if(offset != -1) {
    UString Name(buf);
    UString Value(buf);

    // Separate the parameter name and value
    Name.DeleteAt(offset, (Name.length() - offset));
    offset = Name.Find(" "); // Remove any trailing spaces
    if(offset != -1) Name.DeleteAt(offset, 1);
    eds_node.str = Name; eds_node.address = addr;
    chsptr = Add(eds_node); // Store the parameter name
    if(!chsptr) return 0;

    // Store the config file parameter value 
    offset = Value.Find(parm_ID.c_str());
    Value.DeleteAt(0, (offset+parm_ID.length()));
    offset = Value.Find(" "); // Remove any leading spaces
    if(offset == 0) Value.DeleteAt(offset, 1);
    offset = Value.Find(" "); // Look for any trailing spaces or other chars
    if(offset != -1) {
      // Remove any comments following a space but leave long
      // character strings for values such as file names with
      // white spaces or multiple config values on one line
      if(filter_comments) {
      if(Value[offset+1] == comment_char) 
	Value.DeleteAt(offset, (Value.length() - offset));
      }
    }
    eds_node.str = Value; eds_node.address = addr;
    chsptr = Add(eds_node);
    if(!chsptr) return 0;
  }

  return 1; // Indicate success
}

gxDatabaseError edsConfig::Flush()
{
  if(opendatabase) {
    if(opendatabase->GetDatabaseError() == gxDBASE_NO_ERROR) {
      if(opendatabase->ReadyForWriting()) {
	return opendatabase->Flush();
      }
    }
  }
  return gxDBASE_NO_ERROR;
}

edsConfigListNode *edsConfig::Find(const edsConfigNode &X,
				   edsConfigListNode *ptr)
// Returns the first node having an element that matched X
{
  if(ptr == 0) ptr = (edsConfigListNode *)GetHead();

  while(ptr) { // Scan until end of list
    if(ptr->node_data == X) return ptr; // Match found
    ptr = ptr->GetNext();
  }
  return 0; // No match
}

edsConfigListNode *edsConfig::Add(const edsConfigNode &X)
{
  edsConfigListNode *node = new edsConfigListNode(X);
  if(!node) return 0; // Could not allocate memory for the node
  InsertAtTail((gxListNodeB *)node);
  return node;
}

#ifdef __BCC32__
#pragma warn .8080
#endif
// ----------------------------------------------------------- //
// ------------------------------- //
// --------- End of File --------- //
// ------------------------------- //

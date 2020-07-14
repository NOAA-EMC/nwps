/************************************/
/*********** Start of File **********/
/************************************/
/* ----------------------------------------------------------- */
/* C Source Code File */
/* C Compiler Used: GNU, Intel, Cray */
/* Produced By: Douglas.Gaer@noaa.gov */
/* File Creation Date: 01/22/2016 */
/* Date Last Modified: 06/03/2016 */
/* - */
/* Version control: 4.01 */
/* Support Team: */
/* Contributors: */
/* ----------------------------------------------------------- */
/* ------------- Program Description and Details ------------- */
/* ----------------------------------------------------------- */
/*
This software and documentation was produced within NOAA
and is intended for internal agency use only. Please don't
distribute any part of this software or documentation without
first contacting the original author or NOAA agency that
produced this software. All third party libraries used to
build this application are subject to the licensing agreement
stated within the source code and any documentation supplied
with the third party library.

NWPS utiltiy used create a sea ice mask for waterlevels

*/
/* ----------------------------------------------------------- */

#include <stdio.h>
#include <string.h>
#include <math.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <math.h>

#if defined (_USE_DIRECT_IO_)
#include "direct_io.h"
#endif

/* Global defines */
#define PROGRAM_NAME "SEAICE_MASK"
#define VERSION_STRING "4.01"

/* Global variables */
int debug;
int debug_level;
int verbose;
float mask_value;
int num_command_line_args;
char process_name[255];
char program_name[255];
char version_string[255];
char fnameout[1024];
int writebinout;

int ProcessArgs(int argc, char *argv[]);
void HelpMessage();
void VersionMessage();

int main(int argc, char **argv)
{
#if defined (_USE_DIRECT_IO_)
  DIOFILE *fp, *fp_mask, *fpout;
#else
  FILE *fp, *fp_mask, *fpout;
#endif
  char fname1[1024];
  char fname2[1024];
  float f;
  float f_mask;
  float new_value;
  size_t bytes;
  int error_flag = 0;
  unsigned points = 0;
  int num_files = 0;
  int narg = 1;
  char *arg = argv[narg = 1];

  fpout = NULL;
  memset(program_name, 0, sizeof(program_name));
  memset(version_string, 0, sizeof(version_string));
  memset(process_name, 0, sizeof(process_name));
  mask_value = 0.0f;
  num_command_line_args = 0;
  debug = 0;
  debug_level = 0;
  verbose = 0;
  memset(fname1, 0 , sizeof(fname1));
  memset(fname2, 0 , sizeof(fname2));
  memset(fnameout, 0 , sizeof(fnameout));
  writebinout = 0;
  
  /* Set program info here */
  strncpy(program_name, PROGRAM_NAME, (sizeof(program_name)-1));
  strncpy(version_string, VERSION_STRING, (sizeof(version_string)-1));
  strncpy(process_name, argv[0], (sizeof(process_name)-1));
  
  while(narg < argc) {
    if(arg[0] != '\0') {
      if(arg[0] == '-') { // Look for command line arguments
	// Exit if argument is not valid or argument signals program to exit
	if(!ProcessArgs(argc, argv)) return 1;
      }
      else {
	if(num_files == 0)   strncpy(fname1, arg, (sizeof(fname1)-1));
	if(num_files == 1)   strncpy(fname2, arg, (sizeof(fname2)-1));
	num_files++;
      }
    }
    arg = argv[++narg];
  }

  if(num_files != 2) {
    fprintf(stderr, "ERROR - You must specify input BIN files\n");
    VersionMessage();
    HelpMessage();
    return 1;
  }
  
  fprintf(stderr, "Opening input bin file %s\n", fname1);
#if defined (_USE_DIRECT_IO_)
  fp = dio_fopen(fname1);
#else
  fp = fopen(fname1, "rb");
#endif
  if(!fp) {
    fprintf(stderr, "ERROR - Cannot open BIN file %s\n", fname1);
    return 1;
  }

  fprintf(stderr, "Opening input bin file %s\n", fname2);
#if defined (_USE_DIRECT_IO_)
  fp_mask = dio_fopen(fname2);
#else
  fp_mask = fopen(fname2, "rb");
#endif
  if(!fp_mask) {
    fprintf(stderr, "ERROR - Cannot open BIN file %s\n", fname2);
    return 1;
  }

  if(writebinout == 1) {
    fprintf(stderr, "Opening output bin file %s\n", fnameout);
#if defined (_USE_DIRECT_IO_)
    fpout = dio_fcreate(fnameout);
#else
    fpout = fopen(fnameout, "wb");
#endif
    if(!fpout) {
      fprintf(stderr, "ERROR - Cannot output BIN file %s\n", fnameout);
      return 1;
    }
  }

  if(mask_value != 0.0f) {
    fprintf(stderr, "INFO - User-defined mask criterion is set to %f\n", mask_value);
  }

#if defined (_USE_DIRECT_IO_)
    while(fp->read_eof != 0) {
      bytes = dio_read(fp, (void *)&f, sizeof(f));
#else
    while(!feof(fp)) {
      bytes = fread((unsigned char *)&f, 1, sizeof(f), fp);
#endif
	
      if(bytes != sizeof(f)) {
#if defined (_USE_DIRECT_IO_)
	if(fp->read_eof == 0) {
#else
        if(feof(fp)) {
#endif
	  error_flag = 0;
	  break;
	}
	else {
	  fprintf(stderr, "ERROR - Error reading from input BIN file %s\n", fname1);
	  error_flag = 1;
	  break;
	}
       }
	
#if defined (_USE_DIRECT_IO_)	
      bytes = dio_read(fp_mask, (void *)&f_mask, sizeof(f_mask));
#else
      bytes = fread((unsigned char *)&f_mask, 1, sizeof(f_mask), fp_mask);
#endif

      if(bytes != sizeof(f)) {
#if defined (_USE_DIRECT_IO_)	
	if(fp_mask->read_eof == 0) {
#else
        if(feof(fp_mask)) {
#endif
	  error_flag = 0;
	  break;
	}
	else {
	  fprintf(stderr, "ERROR - Error reading from input BIN file %s\n", fname2);
	  error_flag = 1;
	  break;
	}
      }
	
    if(debug == 1) {
      if((f_mask != 0.0f) && (f != 9.999e+20f)) {
	fprintf(stderr, "\nestofs val = %f\nice value = %f\n", f, f_mask);
	fprintf(stderr, "ice value round = %f\n", round(f_mask));
      }
    }
    
    new_value = f;
    if(f == 9.999e+20f) new_value = 0;
    if(mask_value != 0.0f) {
      if(f_mask > mask_value) new_value = -9999.0;
    }
    else {
      if(round(f_mask) >= 1) new_value = -9999.0;
    }
    
    points++;

    if(writebinout == 1) {
#if defined (_USE_DIRECT_IO_)	
      bytes = dio_write(fpout, (void *)&new_value, sizeof(new_value));
#else
      bytes = fwrite((unsigned char *)&new_value, 1, sizeof(new_value), fpout);
#endif
      if(bytes != sizeof(new_value)) {
	fprintf(stderr, "ERROR - Error writing to output BIN file %s\n", fnameout);
	error_flag = 1;
	break;

      }
    }
    else {
      printf("%f\n", new_value);
    }
  }
  
  if(error_flag == 0) {
    fprintf(stderr, "BIN file read complete, read %u data points\n", points);
  }

#if defined (_USE_DIRECT_IO_)	
  dio_close(fp);
  dio_close(fp_mask);
  if(writebinout == 1) dio_close(fpout);
#else
  fclose(fp);
  fclose(fp_mask);
  if(writebinout == 1) fclose(fpout);
#endif
  
  return error_flag;
}

int ProcessArgs(int argc, char *argv[])
{
  // process the program's argument list
  int i;
  char sbuf[255];
  char sw;
  num_command_line_args = 0;
  memset(sbuf, 0, sizeof(sbuf));
  
  for(i = 1; i < argc; i++ ) {
    if(*argv[i] == '-') {
      sw = *(argv[i] +1);

      switch(sw) {
	case '?':
	  VersionMessage();
	  HelpMessage();
	  return 0; // Signal program to exit
	case 'v': case 'V': 
	  verbose = 1;
	  break;
	case 'd': case 'D':
	  debug = 1;
	  break;
	case 'm': case 'M':
	  strncpy(sbuf, &argv[i][2], (sizeof(sbuf)-1));
	  mask_value = atof(sbuf);
	  break;
	case 'o': case 'O':
	  strncpy(fnameout, &argv[i][2], (sizeof(fnameout)-1));
	  writebinout = 1;
	  break;
	default:
	  fprintf(stderr, "ERROR - Unknown arg %s\n", argv[i]);
	  return 0;
      }
      num_command_line_args++;
    }
  }
  return 1; // All command line arguments were valid
}

void HelpMessage()
{
  fprintf(stderr, "Example: %s filetomask.bin maskfile.bin\n", process_name);
  fprintf(stderr, "Example: %s estofs_clip.bin seaice_clip.bin\n", process_name);
  fprintf(stderr, "Change mask density: %s -m.5 estofs_clip.bin seaice_clip.bin\n", process_name);
  fprintf(stderr, "Write bin out: %s -m.5 -omasked.bin estofs_clip.bin seaice_clip.bin\n", process_name);
  fprintf(stderr, "\n");
}

void VersionMessage()
{
  fprintf(stderr, "\n%s version %s\n", program_name, version_string);
}
/* ----------------------------------------------------------- */
/************************************/
/************ End of File ***********/
/************************************/

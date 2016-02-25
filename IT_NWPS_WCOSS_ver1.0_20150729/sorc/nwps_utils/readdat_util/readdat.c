/************************************/
/*********** Start of File **********/
/************************************/
/* ----------------------------------------------------------- */
/* C Source Code File */
/* C Compiler Used: GCC 4.4.4 */
/* Produced By: Douglas.Gaer@noaa.gov */
/* File Creation Date: 04/18/2011 */
/* Date Last Modified: 12/01/2011 */
/* - */
/* Version control: 1.07 */
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

GRADS utiltiy used to read BIN dat created for GRADS.

*/
/* ----------------------------------------------------------- */

#include <stdio.h>
#include <string.h>

/* Global defines */
#define PROGRAM_NAME "READDAT"
#define VERSION_STRING "1.07"

/* Global variables */
int debug;
int debug_level;
int verbose;
int num_skip_points;
int num_command_line_args;
unsigned skip_address;
char process_name[255];
char program_name[255];
char version_string[255];

int ProcessArgs(int argc, char *argv[]);
void HelpMessage();
void VersionMessage();

int main(int argc, char **argv)
{
  FILE *fp, *fpout;
  char fname[1024];
  float f;
  size_t bytes;
  int error_flag = 0;
  unsigned points = 0;
  int num_files = 0;
  int num_skip_points_org = 0;
  int narg = 1;
  char *arg = argv[narg = 1];
  
  memset(program_name, 0, sizeof(program_name));
  memset(version_string, 0, sizeof(version_string));
  memset(process_name, 0, sizeof(process_name));
  num_skip_points = 0;
  skip_address = 0;
  num_command_line_args = 0;
  debug = 0;
  debug_level = 0;
  verbose = 0;
  memset(fname, 0 , sizeof(fname));

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
	if(num_files == 0)   strncpy(fname, arg, (sizeof(fname)-1));
	num_files++;
      }
    }
    arg = argv[++narg];
  }

  if(num_files == 0) {
    fprintf(stderr, "ERROR - You must specify an input BIN file\n");
    VersionMessage();
    HelpMessage();
    return 1;
  }
  
  fprintf(stderr, "Opening input bin file %s\n", fname);
  fp = fopen(fname, "rb");
  if(!fp) {
    fprintf(stderr, "ERROR - Cannot open BIN file %s\n", fname);
    return 1;
  }

  if(num_skip_points > 0) {
    fprintf(stderr, "INFO - Setting skip points to %d\n", num_skip_points);
  }
  if(skip_address > 0) {
    fprintf(stderr, "INFO - Setting skip address to %u\n", num_skip_points);
  }
  
  num_skip_points_org = num_skip_points;
  while(!feof(fp)) {
    bytes = fread((unsigned char *)&f, 1, sizeof(f), fp);
    if(bytes != sizeof(f)) {
      if(feof(fp)) {
	error_flag = 0;
	break;
      }
      else {
	fprintf(stderr, "ERROR - Error reading from input BIN file %s\n", fname);
	error_flag = 1;
	break;
      }
    }
   
    if(num_skip_points > 0) {
      num_skip_points--;
      continue;
    }

    points++;
    printf("%f\n", f);

    if(skip_address > 0) {
      if(points == skip_address) {
	num_skip_points = num_skip_points_org;
	fprintf(stderr, "At address %u, skipping %d more data points\n", skip_address, num_skip_points_org);
	skip_address = 0; /* Reset the skip address */
      }
    }
  }
  
  if(error_flag == 0) {
    fprintf(stderr, "BIN file read complete, read %u data points\n", points);
  }
  fclose(fp);
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
	case 'a': case 'A':
	  strncpy(sbuf, &argv[i][2], (sizeof(sbuf)-1));
	  skip_address = atoi(sbuf);
	  if(skip_address == 0) {
	    fprintf(stderr, "ERROR - Invalid skip address\n");
	    return 0;
	  }
	  break;
	case 's': case 'S':
	  strncpy(sbuf, &argv[i][2], (sizeof(sbuf)-1));
	  num_skip_points = atoi(sbuf);
	  if(num_skip_points <= 0) {
	    fprintf(stderr, "ERROR - Invalid number of skip points\n");
	    return 0;
	  }
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
  fprintf(stderr, "Example: %s binfile.dat\n", process_name);
  fprintf(stderr, "Fortan read example: %s -s4 binfile.dat\n", process_name);
  fprintf(stderr, "U/V Fortan read: %s -s4 -a253393 binfile.dat\n", process_name);
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

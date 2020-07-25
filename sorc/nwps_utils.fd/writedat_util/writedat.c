/************************************/
/*********** Start of File **********/
/************************************/
/* ----------------------------------------------------------- */
/* C Source Code File */
/* C Compiler Used: GNU, Intel, Cray */
/* Produced By: Douglas.Gaer@noaa.gov */
/* File Creation Date: 04/18/2011 */
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

NWPS utiltiy used to write ASCII point file to Fortran BIN file.

*/
/* ----------------------------------------------------------- */

#include <stdio.h>
#include <string.h>
#include <malloc.h>
#include <stdlib.h>
#include <ctype.h>
#include <sys/stat.h>
#include <fcntl.h>

#if defined (_USE_DIRECT_IO_)
#include "direct_io.h"
#endif

int main(int argc, char *argv[])
{
#if defined (_USE_DIRECT_IO_)
  DIOFILE *fp, *fpout;
#else
  FILE *fp, *fpout;
#endif
  char fname[1024];
  char outfile_name[1024];
  char sbuf[255];
  float f;
  size_t bytes;
  int error_flag = 0;
  unsigned points = 0;
  char *line = NULL;
  char *linedup = NULL;
  size_t len = 0;
  char* word;
  ssize_t read;

  if(argc < 3) {
    printf("ERROR - You must specify an input and output file\n");
    printf("Example: %s textdata.txt binfile.dat\n", argv[0]);
    return 1;
  }
  
  memset(fname, 0 , sizeof(fname));
  memset(outfile_name, 0, sizeof(outfile_name));
  memset(sbuf, 0 , sizeof(sbuf));
  
  strncpy(fname, argv[1], (sizeof(fname)-1));
  strncpy(outfile_name, argv[2], (sizeof(outfile_name)-1));
  
  printf("Opening input text file %s\n", fname);
#if defined (_USE_DIRECT_IO_)
  fp = dio_fopen(fname);
#else 
  fp = fopen(fname, "rb");
#endif
  if(!fp) {
    printf("ERROR - Cannot open file %s\n", fname);
    return 1;
  }

  printf("Creating output binary data file %s\n", outfile_name);
#if defined (_USE_DIRECT_IO_)
  fpout = dio_fcreate(outfile_name);
#else 
  fpout = fopen(outfile_name, "w+b");
#endif
  if(!fpout) {
    printf("ERROR - Cannot create file %s\n", outfile_name);
    return 1;
  }

  printf("Writing output data, size of float is %lu\n", sizeof(f));
  memset(&f, 0, sizeof(f));

#if defined (_USE_DIRECT_IO_)
  while ((read = dio_getline(fp, &line, &len)) != -1) {
#else
   while ((read = getline(&line, &len, fp)) != -1) {
#endif
    
     if(*line) {
       if(isalpha(line[0])) { free(line); line = NULL; continue; }
       if(line[strlen(line)-1] == '\n') line[strlen(line)-1] = '\0';
       linedup = strdup(line);
       for (word = strtok(linedup," "); word != NULL; word = strtok(NULL, " ")) {
	 f = atof(word);
	 points++;
#if defined (_USE_DIRECT_IO_)
	 bytes = dio_write(fpout, (void *)&f, sizeof(f));
#else
	 bytes = fwrite((const void *)&f, 1, sizeof(f), fpout);
#endif
	 if(bytes != sizeof(f)) {
	   printf("ERROR - Error writing to data file %s\n", outfile_name);
	   error_flag = 1;
	    break;
	 }
	 memset(&f, 0, sizeof(f));
	}
       free(linedup);
     }
     free(line); line = NULL;
   }

   printf("BIN file complete, wrote %u data points\n", points);
   
#if defined (_USE_DIRECT_IO_)
   dio_close(fp);
   dio_close(fpout);
#else
   fclose(fp);
   fclose(fpout);
#endif

   return error_flag;
}

/* ----------------------------------------------------------- */
/************************************/
/************ End of File ***********/
/************************************/

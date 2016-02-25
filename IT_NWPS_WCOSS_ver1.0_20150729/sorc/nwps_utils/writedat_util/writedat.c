/************************************/
/*********** Start of File **********/
/************************************/
/* ----------------------------------------------------------- */
/* C Source Code File */
/* C Compiler Used: GCC 4.4.4 */
/* Produced By: Douglas.Gaer@noaa.gov */
/* File Creation Date: 04/18/2011 */
/* Date Last Modified: 08/23/2011 */
/* - */
/* Version control: 1.04 */
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

GRADS utiltiy used to write ASCII point file to BIN dat file
for GRADS.

*/
/* ----------------------------------------------------------- */

#include <stdio.h>
#include <string.h>

int main(int argc, char *argv[])
{
  FILE *fp, *fpout;
  char fname[1024];
  char outfile_name[1024];
  char sbuf[255];
  float f;
  size_t bytes;
  int error_flag = 0;
  unsigned points = 0;
  
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
  fp = fopen(fname, "rb");
  if(!fp) {
    printf("ERROR - Cannot open file %s\n", fname);
    return 1;
  }

  printf("Creating output binary data file %s\n", outfile_name);
  fpout = fopen(outfile_name, "w+b");
  if(!fpout) {
    printf("ERROR - Cannot create file %s\n", outfile_name);
    return 1;
  }

  printf("Writing output data, size of float is %u\n", sizeof(f));
  memset(&f, 0, sizeof(f));

  while(fscanf(fp, "%f%*[^\n]", &f) != EOF) {
    points++;
    bytes = fwrite((const void *)&f, 1, sizeof(f), fpout);
    if(bytes != sizeof(f)) {
      printf("ERROR - Error writing to data file %s\n", outfile_name);
      error_flag = 1;
      break;
    }
    memset(&f, 0, sizeof(f));
  } 
  
  printf("BIN file complete, wrote %u data points\n", points);
  
  fclose(fp);
  fclose(fpout);
  return error_flag;
}

/* ----------------------------------------------------------- */
/************************************/
/************ End of File ***********/
/************************************/

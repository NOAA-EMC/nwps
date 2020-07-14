/************************************/
/*********** Start of File **********/
/************************************/
/* ----------------------------------------------------------- */
/* C Source Code File */
/* C Compiler Used: GNU, Intel, Cray */
/* Produced By: Douglas.Gaer@noaa.gov */
/* File Creation Date: 05/01/2016 */
/* Date Last Modified: 05/24/2016 */
/* ----------------------------------------------------------- */
/* ------------- Program Description and Details ------------- */
/* ----------------------------------------------------------- */
/*
Direct file I/O test program used to test IOBUF functions.
*/
/* ----------------------------------------------------------- */

#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/types.h>
#include <string.h>
#include <malloc.h>
#include <stdlib.h>

#include "direct_io.h"

int main()
{
  DIOFILE *fp;

  float *data;
  float fbuf;
  int data_len;
  int bytes;
  off_t offset;
  int i, rv;
  int count;
  char filename[255];
  unsigned char readbuf[255];
  off_t filesize;
  
  memset(filename, 0, sizeof(filename));
  strcpy(filename, "test_create.dat");
  
  fp = dio_fcreate(filename);
  if(!fp) {
    printf("ERROR - Could not create file: %s\n", filename);
    return 1;
  }

  data_len = 1024;
  data = (float *)malloc(data_len * sizeof(float));
  memset(data, 0, data_len);
  data[127] = 128.00;
  data[255] = 256.0;
  data[511] = 512.0;
  data[1023] = 1024.00;

  printf("Writing %d bytes\n", (data_len * sizeof(float)));
  bytes = dio_write(fp, (void *)data, (data_len * sizeof(float)));
  if(bytes != (data_len * sizeof(float))) {
    printf("ERROR - Error writing to file, wrote %d bytes\n", bytes);
  }
  offset = dio_tell(fp);
  printf("Our file offset is %d\n", offset);
  
  /* First file offset is 0 */
  printf("Testing random file seeks\n");
  for(i = 1; i < 12; i*=2) {
    /* {127,255,511,1023} * sizeof(float) */
    offset = (off_t)(((i * 128)-1)*sizeof(float));
    dio_seek(fp, offset, SEEK_SET);
    dio_read(fp, (void *)&fbuf, sizeof(float));
    printf("Float value at file address %d = %f\n", offset, fbuf);
    offset = dio_tell(fp);
    /* ({127,255,511,1023} * sizeof(float)) + sizeof(float) */
    printf("Our file offset after read is %d\n", offset);
  }

  filesize = dio_eof(fp);
  printf("File size = %d\n", filesize);
  
  printf("Rewinding file and testing read to EOF\n");
  dio_seek(fp, 0, SEEK_SET);
  offset = dio_tell(fp);
  printf("Our file offset is %d\n", offset);
  
  // Test EOF marker
  while(fp->read_eof != 0) {
    bytes = dio_read(fp, (void *)readbuf, sizeof(readbuf));
    if(bytes == 0) break; /* We reached the end of the file */
  }
  offset = dio_tell(fp);
  printf("Our file offset is %d\n", offset);

  dio_close(fp);
  return 0;
}

/* ----------------------------------------------------------- */
/************************************/
/************ End of File ***********/
/************************************/

/************************************/
/*********** Start of File **********/
/************************************/
/* ----------------------------------------------------------- */
/* C Source Code File */
/* C Compiler Used: GNU, Intel, Cray */
/* Produced By: Douglas.Gaer@noaa.gov */
/* File Creation Date: 05/01/2016 */
/* Date Last Modified: 05/25/2016 */
/* ----------------------------------------------------------- */
/* ------------- Program Description and Details ------------- */
/* ----------------------------------------------------------- */
/*
Direct file I/O code used to replace calls to STDIO file
functions.

Changes:
-------
05/24/2016: Modified read() to return number of bytes read
or 0 at end of file or pipe.

*/
/* ----------------------------------------------------------- */
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <malloc.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <errno.h>

#include "direct_io.h"

#if defined USE_IOBUF_MACROS
#include <iobuf.h>
#endif

DIOFILE * dio_open(char  *filename,  int  access,  int  permission)
{
  DIOFILE *fp;
  int fd;
  fd = POSIX_OPEN(filename, access, permission);
  if(fd < 0) return NULL;
  fp = (DIOFILE *)malloc(sizeof(DIOFILE));
  fp->fd = fd;
  fp->access = access;
  fp->perm = permission;
  fp->fname = (char *)malloc(strlen(filename)+1);
  fp->read_eof = -1;
  fp->seek_past_eof = -1;
  fp->fill_holes = 0;
  memset(fp->fname,0,strlen(filename)+1);
  strcpy(fp->fname, filename); 
  fp->error_flag = 0;
  return fp;
}

int dio_close(DIOFILE *fp)
{
  int rv;
  if(fp == NULL) return -1;
  rv = POSIX_CLOSE(fp->fd);
  if(rv < 0) return rv;
  if(fp->fname != NULL) free(fp->fname);
  free(fp);
  fp = NULL;
  return 0;
}

DIOFILE * dio_fopen(char  *filename)
{
  return dio_open(filename, O_RDONLY, 0444);
}

DIOFILE * dio_fopenrw(char  *filename)
{
  return dio_open(filename, O_RDWR, 0644);
}

DIOFILE * dio_fcreate(char  *filename)
{
  return dio_open(filename, O_RDWR|O_CREAT|O_TRUNC, 0644);
}

int dio_seterrno(DIOFILE *fp)
{
  if(fp == NULL) return -1;
  fp->error_flag = errno;
  return fp->error_flag;
}

int dio_read(DIOFILE *fp, void *buf, int nbytes)
{
  int rv;
  if(fp == NULL) return -1;
  if(buf == NULL) return -1;
  fp->read_eof = -1;
  fp->error_flag = 0;
  rv = POSIX_READ(fp->fd, buf, nbytes);
  if(rv == 0) fp->read_eof = 0;
  if(rv < 0) fp->error_flag = -1;
  return rv;
}

int dio_write(DIOFILE *fp, void *buf, int nbytes)
{
  int rv;
  if(fp == NULL) return -1;
  if(buf == NULL) return -1;
  rv = POSIX_WRITE(fp->fd, buf, nbytes);
  if(rv < 0) fp->error_flag = -1;
  return rv;
}

off_t dio_seek(DIOFILE *fp, off_t offset, int whence)
{
  int nbytes;
  char *buf;
  off_t rv;
  if(fp == NULL) return -1;
  fp->seek_past_eof = -1;
  if(offset > dio_eof(fp)) {
    fp->seek_past_eof = 0;
    if(fp->fill_holes == 1) {
      if((fp->access && O_RDWR) || (fp->access && O_WRONLY)) {
	nbytes = offset - dio_eof(fp);
	buf = (char *)malloc(nbytes);
	memset(buf, 0, nbytes);
	dio_write(fp, (void *)buf, nbytes);
	free(buf);
      }
    }
  }
  rv = POSIX_LSEEK(fp->fd, offset, whence);
  if(rv < 0) fp->error_flag = -1;
  return rv;
}

off_t dio_tell(DIOFILE *fp)
{
  if(fp == NULL) return -1;
  /* Seek 0 btyes from current postion to get our position */
  return dio_seek(fp, 0, SEEK_CUR );
}

/* Flush file buffers and return 0 on success, -1 on fail */
int dio_flush(DIOFILE *fp)
{
  int rv;
  if(fp == NULL) return -1;
  rv = POSIX_FSYNC(fp->fd);
  if(rv < 0) fp->error_flag = -1;
  return rv;
}

off_t dio_eof(DIOFILE *fp)
{
  struct stat buf;
  if(fp == NULL) return -1;
  memset(&buf, 0, sizeof(buf));
  if(fstat(fp->fd, &buf) != 0) {
    fp->error_flag = -1;
    return -1;
  }
  return buf.st_size;
}

off_t dio_rewind(DIOFILE *fp)
{
  if(fp == NULL) return -1;
 return dio_seek(fp, 0, SEEK_SET); 
}

int dio_fputc(DIOFILE *fp, int c)
{
  int rv;
  unsigned char ch;
  ch = c;
  rv = dio_write(fp, (void *)&ch, 1);
  if(rv < 0) {
    fp->error_flag = -1;
    return -1;
  }
  return(c);
}

int dio_fgetc(DIOFILE *fp)
{
  int cnt;
  unsigned char c;
  cnt = dio_read(fp, (void *)&c, 1);
  if (cnt <= 0) {
    fp->error_flag = -1;
    return -1;
  }
  return c;
}

ssize_t dio_getdelim(DIOFILE *fp, char **buf, size_t *bufsiz, int delimiter)
{
   char *ptr, *eptr;
   int c;
   char *nbuf;
   size_t nbufsiz;
   ssize_t d;

   if (*buf == NULL || *bufsiz == 0) {
     *bufsiz = BUFSIZ;
     if ((*buf = malloc(*bufsiz)) == NULL) return -1;
   }
   for (ptr = *buf, eptr = *buf + *bufsiz;;) {
     c = dio_fgetc(fp);
     if(fp->read_eof == 0) {
       return ptr == *buf ? -1 : ptr - *buf;
     }
     if(fp->error_flag != 0) {
       return -1;
     }
     *ptr++ = c;
     if (c == delimiter) {
       *ptr = '\0';
       return ptr - *buf;
     }
     if (ptr + 2 >= eptr) {
       nbufsiz = *bufsiz * 2;
       d = ptr - *buf;
       if ((nbuf = realloc(*buf, nbufsiz)) == NULL) return -1;
       *buf = nbuf;
       *bufsiz = nbufsiz;
       eptr = nbuf + nbufsiz;
       ptr = nbuf + d;
     }
   }

   fp->error_flag = -1;
   return -1;
}

ssize_t dio_getline(DIOFILE *fp, char **buf, size_t *bufsiz)
{
  return dio_getdelim(fp, buf, bufsiz, '\n');
}

/* ----------------------------------------------------------- */
/************************************/
/************ End of File ***********/
/************************************/

/************************************/
/*********** Start of File **********/
/************************************/
/* ----------------------------------------------------------- */
/* C Header File */
/* C Compiler Used: GNU, Intel, Cray */
/* Produced By: Douglas.Gaer@noaa.gov  */
/* File Creation Date: 05/01/2016 */
/* Date Last Modified: 05/25/2016 */
/* ----------------------------------------------------------- */
/* ---------- Include File Description and Details ----------- */
/* ----------------------------------------------------------- */
/*
Direct file I/O code used to replace calls to STDIO file
functions.
*/
/* ----------------------------------------------------------- */
#ifdef __cplusplus /* Allow use with C++ */
extern "C" { 
#endif

#ifndef __DIRECT_IO_H
#define __DIRECT_IO_H

#include <stdio.h>
#include <sys/types.h>

typedef struct DIOFILE {
  int fd;       /* File handle of open file */
  int access;   /* Access mode used when opening the file */
  int perm;     /* Permissions used to open the file */
  char *fname;  /* String name of the file */
  int read_eof; /* Check after each read, 0 is at EOF or -1 */
  int seek_past_eof; /* Check after each file seek 0 is EOF or -1 */
  int fill_holes; /* By default set to 0 not to autofill data holes */
  int error_flag; /* Will be non-zero value is any error was detected */
} DIOFILE;

#if defined USE_IOBUF_MACROS
#define POSIX_OPEN iobuf_open
#define POSIX_CREAT iobuf_creat
#define POSIX_CLOSE iobuf_close
#define POSIX_READ iobuf_read
#define POSIX_WRITE iobuf_write
#define POSIX_READV iobuf_readv
#define POSIX_WRITEV iobuf_writev
#define POSIX_PREAD iobuf_pread
#define POSIX_PWRITE iobuf_pwrite
#define POSIX_LSEEK iobuf_lseek
#define POSIX_FTRUNCATE iobuf_ftruncate
#define POSIX_DUP iobuf_dup
#define POSIX_DUP2 iobuf_dup2
#define POSIX_FSYNC iobuf_fsync
#define POSIX_FATASYNC iobuf_fdatasync
#else
#define POSIX_OPEN open
#define POSIX_CREAT creat
#define POSIX_CLOSE close
#define POSIX_READ read
#define POSIX_WRITE write
#define POSIX_READV readv
#define POSIX_WRITEV writev
#define POSIX_PREAD pread
#define POSIX_PWRITE pwrite
#define POSIX_LSEEK lseek
#define POSIX_FTRUNCATE ftruncate
#define POSIX_DUP dup
#define POSIX_DUP2 dup2
#define POSIX_FSYNC fsync
#define POSIX_FATASYNC fdatasync
#endif

/* Open file, returns DIOFILE pointer or NULL if file open files */
DIOFILE * dio_open(char  *filename,  int  access,  int  permission);

/*
Access modes
O_RDONLY Open the file so that it is read only.
O_WRONLY Open the file so that it is write only.
O_RDWR   Open the file so that it can be read from and written to.
O_APPEND Append new information to the end of the file.
O_TRUNC  Initially clear all data from the file.
O_CREAT  If the file does not exist, create it.

Permissions
S_IRUSR  Set read rights for the owner to true.
S_IWUSR  Set write rights for the owner to true.
S_IXUSR  Set execution rights for the owner to true.
S_IRGRP  Set read rights for the group to true.
S_IWGRP  Set write rights for the group to true.
S_IXGRP  Set execution rights for the group to true.
S_IROTH  Set read rights for other users to true.
S_IWOTH  Set write rights for other users to true.
S_IXOTH  Set execution rights for other users to true.
*/

/* Open existing file as read only, returns NULL on error */
DIOFILE * dio_fopen(char  *filename);

/* Create new new file, and truncate file if exists, returns NULL on error */
DIOFILE * dio_fcreate(char  *filename);

/* Open existing file as read/write without truncating, returns NULL on error */
DIOFILE * dio_fopenrw(char  *filename);

/* Close the file and free the DIOFILE pointer */
int dio_close(DIOFILE *fp);

/* Read nbytes into buf, returns the number of bytes read */
/* On read error will return value not equal to nbytes */
/* After each read check fp->read_eof. If 0 the read is at EOF */
int dio_read(DIOFILE *fp, void *buf, int nbytes);

/* Write buf of nbytes to file, returns nbytes */
/* On write error will return value not equal to nbytes */
int dio_write(DIOFILE *fp, void *buf, int nbytes);

/* SEEK_SET  Offset is to be in absolute terms. */
/* SEEK_CUR  Offset relative to the current location of the pointer. */
/* SEEK_END  Offset relative to the end of the file. */
/* If whence is 0, the pointer is set to offset bytes */
/* If whence is 1, the pointer is set to its current location plus offset */
/* If whence is 2, the pointer is set to the size of the file plus offset */
off_t dio_seek(DIOFILE *fp, off_t offset, int whence);

/* Get the current file position */
off_t dio_tell(DIOFILE *fp);

/* Get EOF/size of file */
off_t dio_eof(DIOFILE *fp);

/* Rewind file pointer to zero */
off_t dio_rewind(DIOFILE *fp);

/* Flush file buffers and return 0 on success, -1 on fail */
int dio_flush(DIOFILE *fp);

 /*
Read from fp until character matching the delimiter character. Returns 
number of characters written into the buffer, including the delimiter 
character if one was encountered before EOF, but excluding the 
terminating NUL character. Return -1. If an error occurs.
*/
ssize_t dio_getdelim(DIOFILE *fp, char **buf, size_t *bufsiz, int delimiter);

/* Read line from file using dio_getdelim() call */
ssize_t dio_getline(DIOFILE *fp, char **buf, size_t *bufsiz);

/* Get or put a char in a file stream, returns get or put char or -1 on error */
int dio_fgetc(DIOFILE *fp);
int dio_fputc(DIOFILE *fp, int c);

/* Set fp->error_flag = errno */ 
/* Usage for debugging: 
   char sbuf[255];
   ...
   memset(sbuf, 0, sizeof(sbuf);
   strerror_r(dio_seterrno(fp), sbuf, sizeof(sbuf));
   fprintf(stderr, "%s\n", sbuf);
*/
int dio_seterrno(DIOFILE *fp);

#endif  /* __DIRECT_IO_H */

#ifdef __cplusplus /* Allow use with C++ */
  }
#endif
/* ----------------------------------------------------------- */
/************************************/
/************ End of File ***********/
/************************************/


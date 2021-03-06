#include "cfi.h"
#include <sys/stat.h>
#include <sys/types.h>
#include <stdlib.h>
#include <string.h>

void f_makedir(char* path, int len)
{
  char *dirnm;

  dirnm = (char *) malloc(len+1);
  memcpy(dirnm, path, len);

  dirnm[len] = '\0';

  mkdir(dirnm, 0755);

  free(dirnm);
}

void MAKEDIR(protoFSTRING(fpath) protoLenFSTRING(fpath))
{
  char *path  = FCD2CP(fpath);
  int   len   = FCDLEN(fpath);

  f_makedir(path, len);
}

void makedir(protoFSTRING(fpath) protoLenFSTRING(fpath))
{
  char *path  = FCD2CP(fpath);
  int   len   = FCDLEN(fpath);

  f_makedir(path, len);
}

void makedir_(protoFSTRING(fpath) protoLenFSTRING(fpath))
{
  char *path  = FCD2CP(fpath);
  int   len   = FCDLEN(fpath);

  f_makedir(path, len);
}

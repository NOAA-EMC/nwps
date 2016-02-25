/*****************************************************************************
 * myutil.c
 *
 * DESCRIPTION
 *    This file contains some simple utility functions.
 *
 * HISTORY
 * 12/2002 Arthur Taylor (MDL / RSIS): Created.
 *
 * NOTES
 ****************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <math.h>
#include <errno.h>
#include "libaat.h"

#ifdef MEMWATCH
#include "memwatch.h"
#endif

/*****************************************************************************
 * reallocFGets() -- Arthur Taylor / MDL
 *
 * PURPOSE
 *    Read in data from file until a \n is read.  Reallocate memory as needed.
 * Similar to fgets, except we don't know ahead of time that the line is a
 * specific length.
 *    Assumes that S is either NULL, or points to Len memory.  Responsibility
 * of caller to free the memory.
 *
 * ARGUMENTS
 *    S = The string of size Size to store data in. (Input/Output)
 * Size = The allocated length of S. (Input/Output)
 *   fp = Input file stream (Input)
 *
 * RETURNS: int
 * -1 = Memory allocation error.
 *  0 = we read only EOF
 * strlen (*S) (0 = Read only EOF, 1 = Read "\nEOF" or "<char>EOF")
 *
 * HISTORY
 * 12/2002 Arthur Taylor (MDL/RSIS): Created.
 *  2/2007 AAT (MDL): Updated.
 *
 * NOTES
 *  1) Based on getline (see K&R C book (2nd edition) p 29) and on the
 *     behavior of Tcl's gets routine.
 *  2) Choose STEPSIZE = 80 because pages are usually 80 columns.
 ****************************************************************************/
#define STEPSIZE 80
int reallocFGets(char **S, size_t *Size, FILE *fp)
{
   char *str = *S;      /* Local copy of string. */
   int c;               /* Current char read from stream. */
   int i;               /* Where to store c. */

   myAssert(sizeof(char) == 1);
   for (i = 0; ((c = getc(fp)) != EOF) && (c != '\n'); ++i) {
      if (i >= *Size) {
         if ((str = (char *)realloc((void *)*S, *Size + STEPSIZE)) == NULL) {
            myWarn_Err1Arg("Ran out of memory\n");
            return -1;
         }
         *S = str;
         *Size = *Size + STEPSIZE;
      }
      str[i] = (char)c;
   }
   if (c == '\n') {
      /* Make room for \n\0. */
      if (*Size < i + 2) {
         if ((str = (char *)realloc((void *)*S, i + 2)) == NULL) {
            myWarn_Err1Arg("Ran out of memory\n");
            return -1;
         }
         *S = str;
         *Size = i + 2;
      }
      str[i] = (char)c;
      ++i;
   } else {
      /* Make room for \0. */
      if (*Size < i + 1) {
         if ((str = (char *)realloc((void *)*S, i + 1)) == NULL) {
            myWarn_Err1Arg("Ran out of memory\n");
            return -1;
         }
         *S = str;
         *Size = i + 1;
      }
   }
   str[i] = '\0';
   return i;
}
#undef STEPSIZE

/*****************************************************************************
 * strncpyTrim() -- Arthur Taylor / MDL
 *
 * PURPOSE
 *    Perform a strncpy, but only copy the non-white space.  It looks at the
 * first n bytes of src, and removes white space from left and right sides,
 * copying the result to dst.
 *    Unlike strncpy, it doesn't fill with '\0'.
 *    Also, it adds a '\0' to end of dst, so it assumes dst is allocated to at
 * least (n+1).
 *
 * ARGUMENTS
 * dst = The resulting string (Output)
 * src = The string to copy/trim (Input)
 *   n = The number of bytes to copy/trim (Input/Output)
 *
 * RETURNS: char *
 *    returns "dst"
 *
 * HISTORY
 *  3/2007 Arthur Taylor (MDL/RSIS): Created.
 *
 * NOTES
 ****************************************************************************/
char *strncpyTrim(char *dst, const char *src, size_t n)
{
   const char *ptr;     /* Pointer to where first non-white space is. */
   const char *ptr2;    /* Pointer to last non-white space. */

   if (src == NULL) {
      *dst = '\0';
      return dst;
   }
   for (ptr = src; (isspace(*ptr) && (ptr < src + n)); ++ptr) {
   }
   /* Did we hit the end of an all space string? */
   if ((*ptr == '\0') || (ptr == src + n)) {
      *dst = '\0';
      return dst;
   }
   for (ptr2 = src + n - 1; isspace(*ptr2); --ptr2) {
   }
   strncpy(dst, ptr, ptr2 - ptr + 1);
   dst[ptr2 - ptr + 1] = '\0';
   return dst;
}

#ifdef OLD
/*****************************************************************************
 * mySplit() -- Arthur Taylor / MDL
 *
 * PURPOSE
 *    Split a character array according to a given symbol.  Responsibility of
 * caller to free the memory.
 *    Assumes that argc is either 0, or is the number of entries allocated in
 * argv.
 *
 * ARGUMENTS
 *   data = character string to look through. (Input)
 * symbol = character to split based on. (Input)
 *   argc = number of groupings found. (Input/Output)
 *   argv = characters in each grouping. (Input/Output)
 * f_trim = Should trim the white space from each element in list? (Input)
 *
 * RETURNS: int
 * -1 = Memory allocation error.
 *  0 = Ok
 *
 * HISTORY
 *  5/2004 Arthur Taylor (MDL/RSIS): Created.
 *  3/2007 AAT (MDL): Updated.
 *
 * NOTES
 ****************************************************************************/
int mySplit(const char *data, char symbol, size_t *Argc, char ***Argv,
            char f_trim)
{
   const char *head;    /* The head of the current string */
   const char *ptr;     /* a pointer to walk over the data. */
   size_t argc;         /* number of symbols in data + 1 */
   char **argv;         /* Local copy of Argv */
   size_t len;          /* length of current string. */
   size_t i;            /* loop counter over Argc */

   /* Free data from previous call. */
   for (i = 0; i < *Argc; i++) {
      free((*Argv)[i]);
   }

   /* Count number of breaks */
   argc = 0;
   head = data;
   while (head != NULL) {
      ptr = strchr(head, symbol);
      if (ptr != NULL) {
         head = ptr + 1;
         /* The following is in case data is not '\0' terminated */
         if ((head != NULL) && (*head == '\0')) {
            head = NULL;
         }
      } else {
         head = NULL;
      }
      ++argc;
   }

   /* Allocate memory once */
   if (*Argc == 0) {
      if ((argv = (char **)malloc(argc * sizeof(char *))) == NULL) {
         myWarn_Err1Arg("Ran out of memory\n");
         return -1;
      }
   } else if (*Argc != argc) {
      argv = (char **)realloc((void *)(*Argv), argc * sizeof(char *));
      if (argv == NULL) {
         myWarn_Err1Arg("Ran out of memory\n");
         return -1;
      }
   } else {
      argv = *Argv;
   }

   /* Store memory */
   head = data;
   i = 0;
   while (head != NULL) {
      ptr = strchr(head, symbol);
      if (ptr != NULL) {
         len = ptr - head;
         if ((argv[i] = (char *)malloc(len + 1)) == NULL) {
            myWarn_Err1Arg("Ran out of memory\n");
            return -1;
         }
         if (f_trim) {
            strncpyTrim(argv[i], head, len);
         } else {
            strncpy(argv[i], head, len);
            argv[i][len] = '\0';
         }
         head = ptr + 1;
         /* The following is in case data is not '\0' terminated */
         if ((head != NULL) && (*head == '\0')) {
            head = NULL;
         }
      } else {
         /* Handle from here to end of text. */
         len = strlen(head);
         if ((argv[i] = (char *)malloc(len + 1)) == NULL) {
            myWarn_Err1Arg("Ran out of memory\n");
            return -1;
         }
         if (f_trim) {
            strncpyTrim(argv[i], head, len);
         } else {
            strcpy(argv[i], head);
         }
         head = NULL;
      }
      ++i;
   }

   /* Set results */
   *Argc = argc;
   *Argv = argv;
   return 0;
}
#endif

/*****************************************************************************
 * mySplit() -- Arthur Taylor / MDL
 *
 * PURPOSE
 *    Split a character array according to a given symbol.  Responsibility of
 * caller to free the memory (see ASSUMPTIONS).
 *    The original code copied from data to a 2 dimmensional list.  This is
 * slower than it needs to be since repeated calls would have to free the
 * 2d list and allocated a new one, resulting in lots of allocs and frees.
 *    The new code mimics the reallocFgets idea by using spData.  spData is
 * of size lenSpData, and is large enough to hold the user's 1d 'data' array.
 * It will increase to meet demand.
 *    The Argv data can now point to the spData memory so one doesn't have to
 * repeatedly free / alloc the memory.  Improvements for a simple project went
 * from 14 sec to 4 sec run time, with a massive reduction (2,217,893 -> 3) in
 * the number of alloc requests.
 *
 * ASSUMPTIONS
 * 1) argc = 0 (argv = NULL), or is the number of entries allocated in argv.
 * 2) lenSpData = 0 (spData = NULL), or is the allocated length for spData.
 * 3) User free's the data via: free(Argv); free(spData);
 *
 * ARGUMENTS
 *      data = character string to look through. (Input)
 *    symbol = character to split based on. (Input)
 * lenSpData = allocated length of spData (Input/Output)
 *    spData = copy of data with symbol replaced with \0 and trimmed (In/Out)
 *      Argc = number of list elements. (Input/Output)
 *      Argv = pointers into spData for start of each list element. (In/Out)
 *    f_trim = Should trim the white space from each element in list? (Input)
 *
 * RETURNS: int
 * -1 = Memory allocation error.
 *  0 = Ok
 *
 * HISTORY
 *  5/2004 Arthur Taylor (MDL/RSIS): Created.
 *  3/2007 AAT (MDL): Updated.
 * 11/2007 AAT (MDL): Updated.
 *  5/2008 AAT: Bug fix.  If buffer ends in a <symbol> then it doesn't count
 *         that symbol in argc, but then tries to store the '\0' in the argv
 *         array, causing a segfault.  Chose to count the symbol.  So if argc
 *         is always 1 more than the number of symbols in buffer.
 *
 * NOTES
 *   Example upgrade from old call...
 * Old:
 *   size_t numCol = 0;
 *   char **col = NULL;
 *   if (mySplit(buffer, ',', &numCol, &col, 1) != 0) {
 *      goto error;
 *   }
 *   if (numCol != 0) {
 *      for (i = 0; i < numCol; ++i) {
 *         free(col[i]);
 *      }
 *      free(col);
 *   }
 * New
 *   size_t spBuffLen = 0;
 *   char *spBuff = NULL;
 *   size_t numCol = 0;
 *   char **col = NULL;
 *   if (mySplit(buffer, ',', &spBuffLen, &spBuff, &numCol, &col, 1) != 0) {
 *      goto error;
 *   }
 *   if (spBuff != NULL) {
 *      free(spBuff);
 *   }
 *   if (col != NULL) {
 *      free(col);
 *   }
 ****************************************************************************/
int mySplit(const char *data, char symbol, size_t *lenSpData,
            char **SpData, size_t *Argc, char ***Argv, char f_trim)
{
   size_t dataLen;      /* String length of data */
   const char *head;    /* The head of the current string */
   const char *ptr;     /* a pointer to walk over the data. */
   size_t argc;         /* number of symbols in data + 1 */
   size_t cnt;          /* Current list element we are working on */
   char **argv;         /* Local copy of Argv */
   size_t i;            /* loop counter over Argc */
   char *spData;        /* Local copy of SpData */

   /* Count number of breaks */
   argc = 0;
   head = data;
   while (head != NULL) {
      ptr = strchr(head, symbol);
      if (ptr != NULL) {
         head = ptr + 1;
         /* The following is in case data is not '\0' terminated */
         if ((head != NULL) && (*head == '\0')) {
            head = NULL;
            ++argc;
         }
      } else {
         head = NULL;
      }
      ++argc;
   }

   /* Allocate memory for Argv */
   if (*Argc != argc) {
      /* Try to protect *Argv from bad realloc */
      argv = (char **)realloc((void *)(*Argv), argc * sizeof(char *));
      if (argv == NULL) {
         myWarn_Err1Arg("Ran out of memory\n");
         return -1;
      }
      /* Good realloc, so set *Argv */
      *Argv = argv;
      *Argc = argc;
   } else {
      argv = *Argv;
   }

   /* Allocated memory for spData. */
   dataLen = strlen(data);
   if (*lenSpData < dataLen + 1) {
      /* Try to protect *SpData from bad realloc */
      spData = (char *)realloc((void *)(*SpData), (dataLen + 1) * sizeof(char));
      if (spData == NULL) {
         myWarn_Err1Arg("Ran out of memory\n");
         return -1;
      }
      /* Good realloc, so set *SpData */
      *SpData = spData;
      *lenSpData = dataLen + 1;
   } else {
      spData = *SpData;
   }

   /* Update argv by pointing to spData, and copy data to spData. */
   cnt = 0;
   argv[cnt] = spData;
   for (i = 0; i < dataLen; ++i) {
      if (data[i] == symbol) {
         spData[i] = '\0';
         if (f_trim) {
            strTrim (argv[cnt]);
         }
         ++cnt;
         argv[cnt] = spData + (i + 1);
      } else {
         spData[i] = data[i];
      }
   }
   spData[dataLen] = '\0';
   if (f_trim) {
      strTrim (argv[cnt]);
   }
   return 0;
}

/*****************************************************************************
 * myAtoI() -- Arthur Taylor / MDL
 *
 * PURPOSE
 *    Returns true if all char are digits except a leading + or -, or a
 * trailing ','.  Ignores leading or trailing white space.  Value is set to
 * atoi(s).
 *
 * ARGUMENTS
 *     s = character string to look at. (Input)
 * value = the converted value of 's', if 's' is a number. (Output)
 *
 * RETURNS: int
 *   0 = Not an integer
 *   1 = Integer
 *
 * HISTORY
 *  2/2007 Arthur Taylor (MDL): Commented
 *
 * NOTES
 ****************************************************************************/
int myAtoI(const char *s, sInt4 *value)
{
   char *extra = NULL;  /* The data after the end of the integer. */

   *value = 0;
   myAssert(s != NULL);
   if (s == NULL) {
      return 0;
   }
   while (*s != '\0') {
      if (isdigit(*s) || (*s == '+') || (*s == '-')) {
         *value = strtol(s, &extra, 10);
         if (errno == ERANGE) {
            return 0;
         }
         myAssert(extra != NULL);
         if (*extra == '\0') {
            return 1;
         }
         /* First trailing char should be space or ',' */
         if ((!isspace(*extra)) && (*extra != ',')) {
            *value = 0;
            return 0;
         }
         ++extra;
         /* The rest should all be white space. */
         while (*extra != '\0') {
            if (!isspace(*extra)) {
               *value = 0;
               return 0;
            }
            ++extra;
         }
         return 1;
      } else if (!isspace(*s)) {
         return 0;
      }
      ++s;
   }
   return 0;
}


/*****************************************************************************
 * myAtoI_Len() -- Arthur Taylor / MDL
 *
 * PURPOSE
 *    Returns true if "len" char are digits except a leading + or -, or a
 * trailing ','.  Ignores leading or trailing white space.  Value is set to
 * atoi(s).
 *
 * ARGUMENTS
 *     s = character string to look at. (Input)
 *   len = number of characters to pay attention to. (Input)
 * value = the converted value of 's', if 's' is a number. (Output)
 *
 * RETURNS: int
 *   0 = Not an integer
 *   1 = Integer
 *
 * HISTORY
 *  4/2007 Arthur Taylor (MDL): Created
 *
 * NOTES
 *    Tried to modify myAtoI for efficiency sake, but ran into problems since
 * strtol doesn't have a "str_n_tol" version.  So I would have had to pass in
 * a "char *s" instead of a "const char *s".  Figured I'd do the quick way
 * with calls to myAtoI, and re-visit to see if I could get a const char
 * implementation.
 ****************************************************************************/
int myAtoI_Len(char *s, size_t len, sInt4 *value)
{
   char c_temp;         /* Value which is temporarily replaced with a \0 */
   int ierr;            /* Error code (aka is 's' a float or not?) */

   if (strlen(s) <= len) {
      return myAtoI(s, value);
   } else {
      c_temp = s[len];
      s[len] = '\0';
      ierr = myAtoI(s, value);
      s[len] = c_temp;
      return ierr;
   }
}

/*****************************************************************************
 * myAtoF() -- Arthur Taylor / MDL
 *
 * PURPOSE
 *    Returns true if all char are digits except a leading + or -, or a
 * trailing ',' and up to one '.'.  Ignores leading or trailing white space.
 * Value is set to atof(s).
 *
 * ARGUMENTS
 *     s = character string to look at. (Input)
 * value = the converted value of 's', if 's' is a number. (Output)
 *
 * RETURNS: int
 *   0 = Not a real number,
 *   1 = Real number.
 *
 * HISTORY
 *  7/2004 Arthur Taylor (MDL): Updated
 *  4/2005 AAT (MDL): Did a code walk through.
 *  2/2007 Arthur Taylor (MDL): Commented
 *
 * NOTES
 * Used to be myIsReal()
 ****************************************************************************/
int myAtoF(const char *s, double *value)
{
   char *extra;         /* The data after the end of the double. */

   *value = 0;
   myAssert(s != NULL);
   if (s == NULL) {
      return 0;
   }
   while (*s != '\0') {
      if (isdigit(*s) || (*s == '+') || (*s == '-') || (*s == '.')) {
         *value = strtod(s, &extra);
         if (errno == ERANGE) {
            return 0;
         }
         myAssert(extra != NULL);
         if (*extra == '\0') {
            return 1;
         }
         /* Allow first trailing char for ',' */
         if ((!isspace(*extra)) && (*extra != ',')) {
            *value = 0;
            return 0;
         }
         ++extra;
         /* Make sure the rest is all white space. */
         while (*extra != '\0') {
            if (!isspace(*extra)) {
               *value = 0;
               return 0;
            }
            ++extra;
         }
         return 1;
      } else if (!isspace(*s)) {
         return 0;
      }
      ++s;
   }
   return 0;
}

/*****************************************************************************
 * myAtoF_Len() -- Arthur Taylor / MDL
 *
 * PURPOSE
 *    Returns true if "len" char are digits except a leading + or -, or a
 * trailing ',' and up to one '.'.  Ignores leading or trailing white space.
 * Value is set to atof(s).
 *
 * ARGUMENTS
 *     s = character string to look at. (Input)
 *   len = number of characters to pay attention to. (Input)
 * value = the converted value of 's', if 's' is a number. (Output)
 *
 * RETURNS: int
 *   0 = Not a real number,
 *   1 = Real number.
 *
 * HISTORY
 *  4/2007 Arthur Taylor (MDL): Created
 *
 * NOTES
 *    Tried to modify myAtoF for efficiency sake, but ran into problems since
 * strtod doesn't have a "str_n_tod" version.  So I would have had to pass in
 * a "char *s" instead of a "const char *s".  Figured I'd do the quick way
 * with calls to myAtoF, and re-visit to see if I could get a const char
 * implementation.
 ****************************************************************************/
int myAtoF_Len(char *s, size_t len, double *value)
{
   char c_temp;         /* Value which is temporarily replaced with a \0 */
   int ierr;            /* Error code (aka is 's' a float or not?) */

   if (strlen(s) <= len) {
      return myAtoF(s, value);
   } else {
      c_temp = s[len];
      s[len] = '\0';
      ierr = myAtoF(s, value);
      s[len] = c_temp;
      return ierr;
   }
}

/*****************************************************************************
 * myRound() -- Arthur Taylor / MDL
 *
 * PURPOSE
 *    Round a number to a given number of decimal places.
 *
 * ARGUMENTS
 *     x = number to round (Input)
 * place = How many decimals to round to (Input)
 *
 * RETURNS: double (rounded value)
 *
 * HISTORY
 *  5/2003 Arthur Taylor (MDL/RSIS): Created.
 *  2/2006 AAT (MDL): Added the (double) (.5) cast, and the mult by
 *         POWERS_OVER_ONE instead of division.
 *
 * NOTES
 *    It is probably inadvisable to make a lot of calls to this routine,
 * considering the fact that a context swap is made, so this is provided
 * primarily as an example, but it can be used for some rounding.
 ****************************************************************************/
static double POWERS_ONE[] = {
   1e0, 1e1, 1e2, 1e3, 1e4, 1e5, 1e6, 1e7, 1e8, 1e9,
   1e10, 1e11, 1e12, 1e13, 1e14, 1e15, 1e16, 1e17
};
double myRound(double x, uChar place)
{
   if (place > 17) {
      place = 17;
   }
   return (floor(x * POWERS_ONE[place] + 5e-1)) / POWERS_ONE[place];
   /* Have tried the following options to see if I could get some of the
    * degrib regression test 40 to work on linux, but it appears to cause
    * other tests to fail on other OS's. */
/*   return (((sInt4) (x * POWERS_ONE[place] + .5)) / POWERS_ONE[place]);*/
/*   return (floor (x * POWERS_ONE[place] + .5)) / POWERS_ONE[place];*/
/*   modf(x * POWERS_ONE[place] + 5e-1, &d_temp); */
/*   return (d_temp / POWERS_ONE[place]);*/
}

/*****************************************************************************
 * myDoubleEq() -- Arthur Taylor / MDL
 *
 * PURPOSE
 *    Determine if 2 doubles are equal to a given number of decimal places.
 *
 * ARGUMENTS
 *     x = 1st number to compare (Input)
 *     y = 2nd number to compare (Input)
 * place = How many decimals to round to (Input)
 *
 * RETURNS: int
 * True if x == y, false if x != y
 *
 * HISTORY
 *  4/2007 Arthur Taylor (MDL): Created.
 *
 * NOTES
 *    It is probably inadvisable to make a lot of calls to this routine,
 * considering the fact that a context swap is made, so this is provided
 * primarily as an example, but it can be used for some rounding.
 ****************************************************************************/
int myDoubleEq(double x, double y, uChar place)
{
   if (place > 17) {
      place = 17;
   }
   return (fabs(x - y) < 1. / POWERS_ONE[place]);
}

/*****************************************************************************
 * strTrim() -- Arthur Taylor / MDL
 *
 * PURPOSE
 *    Trim the white space from both sides of a char string.
 *
 * ARGUMENTS
 * str = The string to trim (Input/Output)
 *
 * RETURNS: void
 *
 * HISTORY
 * 10/2003 Arthur Taylor (MDL/RSIS): Created.
 * 11/2006 Joe Lang and Arthur Taylor (MDL): Modified for all space error.
 *
 * NOTES
 *   See K&R p106 for strcpy part.
 *   Also: http://icecube.wisc.edu/~dglo/c_class/strmemfunc.html
 *   Also: google with "strcpy memory overlap"
 ****************************************************************************/
void strTrim(char *str)
{
   char *ptr;           /* Pointer to where first non-white space is. */
   char *ptr2;          /* Pointer to just past last non-white space. */

   if (str == NULL) {
      return;
   }
   /* Trim the string to the left first. */
   for (ptr = str; isspace(*ptr); ++ptr) {
   }
   /* Did we hit the end of an all space string? */
   if (*ptr == '\0') {
      *str = '\0';
      return;
   }
   /* now work on the right side. */
   for (ptr2 = ptr + (strlen(ptr) - 1); isspace(*ptr2); ptr2--) {
   }

   /* adjust the pointer to add the null byte. */
   ptr2++;
   *ptr2 = '\0';

   if (ptr != str) {
      /* Can't do a strcpy here since we don't know that they start at left
       * and go right. */
      while ((*str++ = *ptr++) != '\0') {
      }
      *str = '\0';
   }
}

/*****************************************************************************
 * strToLower() -- Arthur Taylor / MDL
 *
 * PURPOSE
 *   Convert a string to all lowercase.
 *
 * ARGUMENTS
 * s = The string to adjust (Input/Output)
 *
 * RETURNS: void
 *
 * HISTORY
 *  5/2004 Arthur Taylor (MDL/RSIS): Created.
 *  2/2007 AAT (MDL): Updated.
 *
 * NOTES
 ****************************************************************************/
void strToLower(char *s)
{
   char *p = s;         /* Used to traverse s. */

   myAssert(s != NULL);
   if (s == NULL) {
      return;
   }
   while ((*p++ = tolower(*s++)) != '\0') {
   }
}

/*****************************************************************************
 * strToUpper() -- Arthur Taylor / MDL
 *
 * PURPOSE
 *   Convert a string to all uppercase.
 *
 * ARGUMENTS
 * s = The string to adjust (Input/Output)
 *
 * RETURNS: void
 *
 * HISTORY
 *  10/2003 Arthur Taylor (MDL/RSIS): Created.
 *   8/2007 AAT (MDL): Updated.
 *
 * NOTES
 ****************************************************************************/
void strToUpper(char *s)
{
   char *p = s;         /* Used to traverse s. */

   myAssert(s != NULL);
   if (s == NULL) {
      return;
   }
   while ((*p++ = toupper(*s++)) != '\0') {
   }
}

/*****************************************************************************
 * ListSearch() -- Arthur Taylor / MDL
 *
 * PURPOSE
 *    Looks through a list of strings for a given string.  Returns the index
 * where it found it.
 *    Originally "GetIndexFromStr(cur, UsrOpt, &index);"
 * now becomes "index = ListSearch(UsrOpt, sizeof(UsrOpt), cur);"
 * Advantage is that UsrOpt doesn't need a NULL last element.
 *
 * ARGUMENTS
 * List = The list to look for s in. (Input)
 *    N = The length of the List. (Input)
 *    s = The string to look for. (Input)
 *
 * RETURNS: int
 *   # = Where s is in List.
 *  -1 = Couldn't find it.
 *
 * HISTORY
 *  9/2002 Arthur Taylor (MDL/RSIS): Created.
 * 12/2002 (TK,AC,TB,&MS): Code Review.
 *  2/2007 AAT (MDL): Updated.
 * 10/2007 AAT: Added check to see if *List was NULL before the strcmp
 *
 * NOTES
 *    Originally: GetIndexFromStr (cur, UsrOpt, &index)
 * => index = ListSearch (UsrOpt, sizeof (UsrOpt), cur);
 ****************************************************************************/
int ListSearch(char **List, size_t N, const char *s)
{
   int cnt = 0;         /* Current Count in List. */

   myAssert(s != NULL);
   if (s == NULL) {
      return -1;
   }
   myAssert(List != NULL);
   for (; cnt < N; ++List, ++cnt) {
      if (*List == NULL) {
         break;
      }
      if (strcmp(s, *List) == 0) {
         return cnt;
      }
   }
   return -1;
}

/*****************************************************************************
 * fileAllocNewExten() -- Arthur Taylor / MDL
 *
 * PURPOSE
 *    Replace the extension of a filename with the given extension, by copying
 * the old filename, without the extension (if there is one), to newly
 * allocated memory, and then strcat the extension on.
 *
 * ARGUMENTS
 *    name = The orignal filename to work with. (Input)
 *     ext = The file extension to replace the old one with, or add (Input)
 * newName = The newly allocated and copied to memory (Output)
 *
 * RETURNS: int
 *  0 = OK
 * -1 = Memory allocation error.
 *
 * HISTORY
 *  3/2007 Arthur Taylor (MDL): Created.
 *
 * NOTES
 ****************************************************************************/
int fileAllocNewExten(const char *name, const char *ext, char **newName)
{
   char *ptr;           /* Used to find the last '.' in the filename */

   if ((ptr = strrchr(name, '.')) == NULL) {
      *newName = (char *)malloc((strlen(name) + strlen(ext) + 1) *
                                sizeof(char));
      if (*newName == NULL) {
         myWarn_Err1Arg("Ran out of memory\n");
         return -1;
      }
      strcpy(*newName, name);
   } else {
      *newName = (char *)malloc(((ptr - name) + strlen(ext) + 1) *
                                sizeof(char));
      if (*newName == NULL) {
         myWarn_Err1Arg("Ran out of memory\n");
         return -1;
      }
      strncpy(*newName, name, ptr - name);
      (*newName)[ptr - name] = '\0';
   }
   strcat(*newName, ext);
   return 0;
}

/*****************************************************************************
 * myCyclicBounds() -- Arthur Taylor / MDL
 *
 * PURPOSE
 *    Retun a value within the bounds of [min...max] by adding or subtracting
 * the range of max - min.
 *
 * ARGUMENTS
 * value = The orignal filename to work with. (Input)
 *   min = The minimum value of the range. (Input)
 *   max = The maximum value of the range. (Input)
 *
 * RETURNS: double
 *   The value that falls in the range of [min..max]
 *
 * HISTORY
 *  3/2007 Arthur Taylor (MDL): Created.
 *
 * NOTES
 ****************************************************************************/
double myCyclicBounds(double value, double min, double max)
{
   while (value < min) {
      value += max - min;
   }
   while (value > min) {
      value -= max - min;
   }
   return value;
}

/*****************************************************************************
 * myCntNumLines() -- Arthur Taylor / MDL
 *
 * PURPOSE
 *    Counts the number of new lines in an open file, then rewinds to the
 * beginning of the file, and returns the count + 1, since the last line
 * might not have a new line.
 *
 * ARGUMENTS
 * fp = An open file pointer to look at. (Input)
 *
 * RETURNS: size_t
 * The number of new lines in the file + 1.
 *
 * HISTORY
 *  3/2007 Arthur Taylor (MDL): Created.
 *
 * NOTES
 ****************************************************************************/
size_t myCntNumLines(FILE *fp)
{
   int c;               /* Current char read from stream. */
   size_t ans = 1;      /* Current count of number of lines in the file. */

   while ((c = getc(fp)) != EOF) {
      if (c == '\n') {
         ans++;
      }
   }
   rewind(fp);
   return ans;
}

#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ(2.59)
AC_INIT([memwatch], [2.71], [arthur.taylor@noaa.gov])
# AM_INIT_AUTOMAKE([-Wall -Werror])
AC_CONFIG_SRCDIR([memwatch.c])
# AC_CONFIG_HEADER([config.h])

# Checks for programs.
AC_PROG_CC
AC_PROG_RANLIB
AC_CHECK_PROG(AR,ar,ar,:)
AC_ARG_VAR([ARFLAGS])
AC_ARG_ENABLE(aixsize,
  [  --enable-aixsize=val    build 32bit or 64bit (default 64) libraries for aix],
   [if test "$enableval" = 32; then
      if test "$ac_compiler_gnu" = yes; then
        CFLAGS="${CFLAGS} -maix32"
      else
        CFLAGS="${CFLAGS} -q32"
      fi
      FFLAGS="${FFLAGS} -q32"
      ARFLAGS="${ARFLAGS} -X32"
    else
      if test "$ac_compiler_gnu" = yes; then
        CFLAGS="${CFLAGS} -maix64"
      else
        CFLAGS="${CFLAGS} -q64"
      fi
      FFLAGS="${FFLAGS} -q64"
      ARFLAGS="${ARFLAGS} -X64"
    fi
    ],
    )
AC_SUBST(ARFLAGS,)

# Checks for libraries.

# Checks for header files.
AC_HEADER_STDC
AC_CHECK_HEADERS([limits.h stdlib.h string.h])

# Checks for typedefs, structures, and compiler characteristics.
AC_C_CONST
AC_TYPE_SIZE_T

# Checks for library functions.
AC_FUNC_MALLOC
AC_FUNC_REALLOC
AC_TYPE_SIGNAL
AC_FUNC_VPRINTF
AC_CHECK_FUNCS([atexit memset])

AC_CONFIG_FILES([Makefile])
AC_OUTPUT

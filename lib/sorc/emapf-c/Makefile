#!/bin/make
SHELL=/bin/bash

######################################################################
# Makefile for psurge_nhctrk
# Usage:
#   make         - Build the executable
#   make clean   - Start with a clean slate
#   make install - Install the exectuable 
#   make strip   - Strip debug code from executable (smaller/faster)
#                  No Debug flags.
######################################################################

######################################################################
# Variables that might be in a module file.
######################################################################
f_HasICC=$(shell which icc &> /dev/null ; if [[ $$? -ne "0" ]] ; then echo NO ; else echo YES ; fi)
ifeq ($(f_HasICC),YES)
#  C_COMP=icc
#CFLAGS=-strict-ansi
else
#  C_COMP=gcc
  LIBS=-lm
  CFLAGS=-fsigned-char
  CFLAGS+=-pedantic -Wextra
# Library doesn't compile with the -ansi flag.
#  CFLAGS+=-ansi
endif

######################################################################
# Directories (BINDIR, LIBDIR, INCDIR)
#   BINDIR= Where to store the executable
#   RANLIB generates an index of each symbol of an archive.  The index
#     speeds up the linking to the library and allows routines in the
#     library to call each other without regard to their placement
######################################################################
STRIP=/usr/bin/strip
RANLIB=/usr/bin/ranlib  # Ranlib generate
BINDIR=../..

######################################################################
# Set compiler and compiler options (includes, defines, libraries)
#   CC= Name of C compiler to use (set to ${COMP})
#   DEF= Any #defines
#   INC= Any header directories to include
#   CFLAGS= Options for the compiler
#   LIBS= List of necessary libraries
#   LDFLAGS= Options for the linker
######################################################################
CC=$(C_COMP)  # Use Intel FORTRAN C compiler: icc
DEF=
INC=
CFLAGS+=-O2 -g $(DEF) $(INC)
LIBS+=
LDFLAGS+=
AR=ar
ARFLAGS=r

######################################################################
# Set source code dependencies and headers
#   SOURCE= Extra .c or .f files 
#   HEADERS= Any .h files to match the .c files
#   OBJS= Extra .o files (compiled from the SOURCE files)
#   MAIN= Source code that contains the 'main' procedure
#   MAINFLAGS= Any extra flags to provide main
#   CMD Name of the executable
######################################################################
SOURCE=cc2gll.c
SOURCE+=cc2gxy.c
SOURCE+=ccurv.c
SOURCE+=cg2cll.c
SOURCE+=cgszll.c
SOURCE+=cgszxy.c
SOURCE+=cpolll.c
SOURCE+=cpolxy.c
SOURCE+=eqvlat.c
SOURCE+=logabova.c
SOURCE+=mkgeoid.c
SOURCE+=stcm1p.c
SOURCE+=stcm2p.c
SOURCE+=stlmbr.c 
SOURCE+=ymercfns.c

HEADERS=cmapf.h

OBJS=$(SOURCE:.c=.o)
#MAIN=nhctrk.c
#MAINFLAGS=$(CFLAGS) -DPKGVERS=\"1.1\" -DPKGDATE=\"2015-02-17\"
LIBNAME=emapf
CMD=lib$(LIBNAME).a

######################################################################
# Rules to build the program
######################################################################
all: check_prereqs $(CMD)

$(CMD): $(OBJS) $(HEADERS)
	$(AR) $(ARFLAGS) $(CMD) $?
	- $(RANLIB) $(CMD)

clean:
	-rm -f $(OBJS) $(CMD)

install: $(CMD)
	mv $(CMD) ${BINDIR}/

check_prereqs:

# Following strips the debug codes from the executable (faster/smaller)
strip: $(CMD)
	$(STRIP) -s $(CMD)

.c.o: $(HEADERS)
	$(CC) -c $(CFLAGS) $<

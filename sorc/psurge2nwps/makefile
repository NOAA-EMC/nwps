#!/bin/make
SHELL = /bin/bash

############################
# This makefile is intended to create the Linux executable.
#
# USAGE:
#    make MEM=false, DEBUG=false, BIT=32 | 64
############################
MEM=true
DEBUG=true

# Determine platform specific options
UNAME := $(shell uname)
ifeq ($(UNAME), Linux)
  BINDIR=/usr/bin
  SUFFIX=
  BIT=64
endif
ifeq ($(UNAME), CYGWIN_NT-6.1)
  BINDIR=/cygdrive/k/MinGW/MinGW-4.5.0/bin
  SUFFIX=.exe
  BIT=32
endif

############################
# Set up the path.
############################
PATH:=$(BINDIR)

############################
# Set up the binary files and version info.
############################
HEAD=/usr/bin/head
CUT=/bin/cut
CP=/bin/cp
RM=/bin/rm
CC=gcc
STRIP=strip

############################
# Set up Targets
############################
NAME=psurge2nwps
PRJ_NAME=$(NAME)_$(BIT)$(SUFFIX)
TARGETS=$(PRJ_NAME)

############################
# Set up Compiler flags...
#   CFLAGS (via STD_DEF and STD_INC)
############################
# _LINUX_ ==> Indicates this is linux (vs aix)
STD_DEF=-D_LINUX_

# _GCC_ ==> Means use GCC wrappings for connecting to fortran.
STD_DEF += -D_GCC_

# SIZEOF_LONG_INT ==> long int is 8 vs 4 bytes (file I/O)
ifeq ($(BIT),64)
  STD_DEF += -DSIZEOF_LONG_INT=8
endif

# CC_VER ==> embeds the compiler version into exectuable.
CC_VER := $(shell $(BINDIR)/$(CC) --version | $(HEAD) -n1 | $(CUT) -d' ' -f2,3 --output-delimiter='-')
STD_DEF += -DCC_VER="\"$(CC_VER)\""

# Allow for MemWatch diagnostics.
ifeq ($(MEM),true)
  STD_DEF += -DMEMWATCH -DMEMWATCH_STDIO -DDEBUG
  MEMWATCH = memwatch.o
  STD_INC = -I../memwatch-2.71
else
  ifeq ($(DEBUG),true)
    STD_DEF += -DDEBUG
  endif
  MEMWATCH =
endif

STD_INC += -I.

# Default compiler flags
CFLAGS = -O3 -Wall -Wextra -pedantic -ansi -pthread

# Enhance compiler flags
ifeq ($(BIT),32)
  CFLAGS += -m32
endif
CFLAGS += $(STD_DEF) $(STD_INC)

############################
# Set up Linker flags...
#    STD_LIB and LD_FLAGS
############################
LD_FLAGS= -static
STD_LIB=

# Add libaat to Build path
STD_INC += -I../libaat
STD_LIB += -L../libaat -laat

# Add emapf-c to Build path
STD_INC += -I../emapf-c
STD_LIB += -L../emapf-c -lemapf

ifeq ($(BIT),32)
  STD_LIB += -L/usr/lib -lm
else
  STD_LIB += -L/usr/lib64 -lm
endif

############################
# FILES
############################
SOURCE = mymapf.c

OBJECTS = $(SOURCE:.c=.o) \
          /opt/cray/iobuf/2.0.8/lib/iobuf.o \
          $(MEMWATCH)

HEADERS = mymapf.h 

C_MAIN = psurge2nwps.c

############################
# TARGETS
############################
.PHONY: all
all: $(TARGETS)
	@echo ""

.PHONY: help
help:
	@echo "make MEM=false, DEBUG=false, BIT=(32 | 64)"

$(PRJ_NAME): $(OBJECTS) $(C_MAIN) $(HEADERS)
	$(CC) $(C_MAIN) $(CFLAGS) $(LD_FLAGS) $(OBJECTS) $(STD_LIB) -o $(PRJ_NAME)
#	$(STRIP) -s $(PRJ_NAME)

.PHONY: install
install: $(TARGETS)
	$(CP) $(PRJ_NAME) ../../bin
	$(CP) $(PRJ_NAME) ../../bin/$(NAME)$(SUFFIX)

.PHONY: clean
clean:
	$(RM) -f *.o *.bak *.BAK $(PRJ_NAME)

############################
# SUFFIXES
############################
.c.o : $(HEADERS)
	$(CC) -c $(CFLAGS) $<

############################
# Dependencies
############################
memwatch.o: ../memwatch-2.71/memwatch.c ../memwatch-2.71/memwatch.h
	$(CC) -c $(CFLAGS) ../memwatch-2.71/memwatch.c

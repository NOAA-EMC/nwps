#######################
#### Start of File ####
#######################
# --------------------------------------------------------------- 
# Makefile
# C/C++ Compiler: GNU
# Orginal Author: Douglas.Gaer@noaa.gov
# File Creation Date: 04/13/2016
# Date Last Modified: 06/29/2016
#
# Version: 1.02
#
# Contributors:
# --------------------------------------------------------------- 
# --------------- Makefile Description and Details -------------- 
# --------------------------------------------------------------- 
#
# Makefile to libxml2 for degrib
#
# --------------------------------------------------------------- 
SHELL = /bin/bash

# Define a name for the executable
PROJECT = libxml2.a

# Additional C/C++ libraries
CLIBS =

# Additional Fortran libraries
FLIBS = 

# Define compiler and linker flags macros
##CFLAGS := $(CFLAGS)
CFLAGS = -v -Wall -O2 -Wall -fsigned-char -pedantic -W -Wformat -Wunused -Wimplicit -Wreturn-type -Wswitch -Wcomment -Wtrigraphs -Wformat -Wchar-subscripts -Wuninitialized -Wparentheses -Wshadow -Wpointer-arith -Wcast-align -Wwrite-strings -Waggregate-return -Wstrict-prototypes -Wmissing-prototypes -Wnested-externs -Winline -Wredundant-decls
#FFLAGS := $(FFLAGS)
FFLAGS = -v -Wall -O2
COMPILE_ONLY = -c
OUTPUT = -o
LFLAGS := $(LFLAGS)

LIBUTIL = ar
RANLIB_UTIL = ranlib
SHARED_LIBUTIL = cc -shared
LIBUTIL_FLAGS = ruv

ADD_INC_PATHS = -I. -I./include/libxml -I./include
DEFMACS = -D_GNU

RELEASE_LIBCOMPILE_FLAGS = -fPIC $(ADD_INC_PATHS) $(DEFMACS)
DEBUG_LIBCOMPILE_FLAGS = -fPIC -g -O0 -v -da -Q $(ADD_INC_PATHS) $(DEFMACS)
LIBCOMPILE_FLAGS = $(RELEASE_LIBCOMPILE_FLAGS)
COMPILE_FLAGS = $(CFLAGS) $(ADD_INC_PATHS) $(DEFMACS)

# Build dependency rules
# ===============================================================
PROJECT_DEPs = acconfig.h \
	config.h \
	elfgcchack.h \
	libxml.h \
	triodef.h \
	trio.h \
	trionan.h \
	triop.h \
	triostr.h

# ===============================================================

# Compile the files and build the executable
# ===============================================================
all:	CREATE_ALL_LIBS 

c14n.o:	c14n.c $(PROJECT_DEPS)
	$(CC) $(COMPILE_ONLY) $(COMPILE_FLAGS) c14n.c

catalog.o:	catalog.c $(PROJECT_DEPS)
	$(CC) $(COMPILE_ONLY) $(COMPILE_FLAGS) catalog.c

chvalid.o:	chvalid.c $(PROJECT_DEPS)
	$(CC) $(COMPILE_ONLY) $(COMPILE_FLAGS) chvalid.c

debugXML.o:	debugXML.c $(PROJECT_DEPS)
	$(CC) $(COMPILE_ONLY) $(COMPILE_FLAGS) debugXML.c

dict.o:	dict.c $(PROJECT_DEPS)
	$(CC) $(COMPILE_ONLY) $(COMPILE_FLAGS) dict.c

DOCBparser.o:	DOCBparser.c $(PROJECT_DEPS)
	$(CC) $(COMPILE_ONLY) $(COMPILE_FLAGS) DOCBparser.c

encoding.o:	encoding.c $(PROJECT_DEPS)
	$(CC) $(COMPILE_ONLY) $(COMPILE_FLAGS) encoding.c

entities.o:	entities.c $(PROJECT_DEPS)
	$(CC) $(COMPILE_ONLY) $(COMPILE_FLAGS) entities.c

error.o:	error.c $(PROJECT_DEPS)
	$(CC) $(COMPILE_ONLY) $(COMPILE_FLAGS) error.c

globals.o:	globals.c $(PROJECT_DEPS)
	$(CC) $(COMPILE_ONLY) $(COMPILE_FLAGS) globals.c

hash.o:	hash.c $(PROJECT_DEPS)
	$(CC) $(COMPILE_ONLY) $(COMPILE_FLAGS) hash.c

HTMLparser.o:	HTMLparser.c $(PROJECT_DEPS)
	$(CC) $(COMPILE_ONLY) $(COMPILE_FLAGS) HTMLparser.c

HTMLtree.o:	HTMLtree.c $(PROJECT_DEPS)
	$(CC) $(COMPILE_ONLY) $(COMPILE_FLAGS) HTMLtree.c

legacy.o:	legacy.c $(PROJECT_DEPS)
	$(CC) $(COMPILE_ONLY) $(COMPILE_FLAGS) legacy.c

list.o:	list.c $(PROJECT_DEPS)
	$(CC) $(COMPILE_ONLY) $(COMPILE_FLAGS) list.c

parser.o:	parser.c $(PROJECT_DEPS)
	$(CC) $(COMPILE_ONLY) $(COMPILE_FLAGS) parser.c

parserInternals.o:	parserInternals.c $(PROJECT_DEPS)
	$(CC) $(COMPILE_ONLY) $(COMPILE_FLAGS) parserInternals.c

pattern.o:	pattern.c $(PROJECT_DEPS)
	$(CC) $(COMPILE_ONLY) $(COMPILE_FLAGS) pattern.c

relaxng.o:	relaxng.c $(PROJECT_DEPS)
	$(CC) $(COMPILE_ONLY) $(COMPILE_FLAGS) relaxng.c

SAX2.o:	SAX2.c $(PROJECT_DEPS)
	$(CC) $(COMPILE_ONLY) $(COMPILE_FLAGS) SAX2.c

SAX.o:	SAX.c $(PROJECT_DEPS)
	$(CC) $(COMPILE_ONLY) $(COMPILE_FLAGS) SAX.c

threads.o:	threads.c $(PROJECT_DEPS)
	$(CC) $(COMPILE_ONLY) $(COMPILE_FLAGS) threads.c

tree.o:	tree.c $(PROJECT_DEPS)
	$(CC) $(COMPILE_ONLY) $(COMPILE_FLAGS) tree.c

trio.o:	trio.c $(PROJECT_DEPS)
	$(CC) $(COMPILE_ONLY) $(COMPILE_FLAGS) trio.c

trionan.o:	trionan.c $(PROJECT_DEPS)
	$(CC) $(COMPILE_ONLY) $(COMPILE_FLAGS) trionan.c

triostr.o:	triostr.c $(PROJECT_DEPS)
	$(CC) $(COMPILE_ONLY) $(COMPILE_FLAGS) triostr.c

uri.o:	uri.c $(PROJECT_DEPS)
	$(CC) $(COMPILE_ONLY) $(COMPILE_FLAGS) uri.c

valid.o:	valid.c $(PROJECT_DEPS)
	$(CC) $(COMPILE_ONLY) $(COMPILE_FLAGS) valid.c

xinclude.o:	xinclude.c $(PROJECT_DEPS)
	$(CC) $(COMPILE_ONLY) $(COMPILE_FLAGS) xinclude.c

xlink.o:	xlink.c $(PROJECT_DEPS)
	$(CC) $(COMPILE_ONLY) $(COMPILE_FLAGS) xlink.c

xmlIO.o:	xmlIO.c $(PROJECT_DEPS)
	$(CC) $(COMPILE_ONLY) $(COMPILE_FLAGS) xmlIO.c

xmlmemory.o:	xmlmemory.c $(PROJECT_DEPS)
	$(CC) $(COMPILE_ONLY) $(COMPILE_FLAGS) xmlmemory.c

xmlmodule.o:	xmlmodule.c $(PROJECT_DEPS)
	$(CC) $(COMPILE_ONLY) $(COMPILE_FLAGS) xmlmodule.c

xmlregexp.o:	xmlregexp.c $(PROJECT_DEPS)
	$(CC) $(COMPILE_ONLY) $(COMPILE_FLAGS) xmlregexp.c

xmlsave.o:	xmlsave.c $(PROJECT_DEPS)
	$(CC) $(COMPILE_ONLY) $(COMPILE_FLAGS) xmlsave.c

xmlschemas.o:	xmlschemas.c $(PROJECT_DEPS)
	$(CC) $(COMPILE_ONLY) $(COMPILE_FLAGS) xmlschemas.c

xmlschemastypes.o:	xmlschemastypes.c $(PROJECT_DEPS)
	$(CC) $(COMPILE_ONLY) $(COMPILE_FLAGS) xmlschemastypes.c

xmlstring.o:	xmlstring.c $(PROJECT_DEPS)
	$(CC) $(COMPILE_ONLY) $(COMPILE_FLAGS) xmlstring.c

xmlunicode.o:	xmlunicode.c $(PROJECT_DEPS)
	$(CC) $(COMPILE_ONLY) $(COMPILE_FLAGS) xmlunicode.c

xmlwriter.o:	xmlwriter.c $(PROJECT_DEPS)
	$(CC) $(COMPILE_ONLY) $(COMPILE_FLAGS) xmlwriter.c

xpath.o:	xpath.c $(PROJECT_DEPS)
	$(CC) $(COMPILE_ONLY) $(COMPILE_FLAGS) xpath.c

xpointer.o:	xpointer.c $(PROJECT_DEPS)
	$(CC) $(COMPILE_ONLY) $(COMPILE_FLAGS) xpointer.c

OBJECTS = c14n.o \
	catalog.o \
	chvalid.o \
	debugXML.o \
	dict.o \
	DOCBparser.o \
	encoding.o \
	entities.o \
	error.o \
	globals.o \
	hash.o \
	HTMLparser.o \
	HTMLtree.o \
	legacy.o \
	list.o \
	parser.o \
	parserInternals.o \
	pattern.o \
	relaxng.o \
	SAX2.o \
	SAX.o \
	threads.o \
	tree.o \
	trio.o \
	trionan.o \
	triostr.o \
	uri.o \
	valid.o \
	xinclude.o \
	xlink.o \
	xmlIO.o \
	xmlmemory.o \
	xmlmodule.o \
	xmlregexp.o \
	xmlsave.o \
	xmlschemas.o \
	xmlschemastypes.o \
	xmlstring.o \
	xmlunicode.o \
	xmlwriter.o \
	xpath.o \
	xpointer.o

CREATE_ALL_LIBS:	$(OBJECTS)
	echo Building static libary
	$(LIBUTIL) $(LIBUTIL_FLAGS) ./$(PROJECT) $(OBJECTS)
	$(RANLIB_UTIL) ./$(PROJECT)

# ===============================================================

# Install the new binaries
# ===============================================================
install:
	echo "No install for this lib"

# Remove object files and the executable after running make 
# ===============================================================
clean:
	echo Removing all OBJECT files from working directory...
	rm -f $(PROJECT)
	rm -f *.o 

	echo Removing EXECUTABLE file from working directory...
	rm -f $(PROJECT)
# --------------------------------------------------------------- 
#####################
#### End of File ####
#####################

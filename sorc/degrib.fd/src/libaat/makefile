SHELL = /bin/sh

top_srcdir = ..

CC = cc
CFLAGS = -v -Wall -O2 -Wall -fsigned-char -DSIZEOF_LONG_INT=8    
AR = ar
ARFLAGS = 
RANLIB = ranlib

LIBNAME = aat
LIBA = lib$(LIBNAME).a

SOURCE = myopt.c \
         myassert.c \
         allocSprintf.c \
         mywarn.c \
         mycomplex.c \
         tendian.c \
         myutil.c \
         spline.c \
         probability.c \
         sphere.c \
         shpfile.c \
         dbffile.c \
         clock.c

HEADERS = libaat.h \
          libaat_type.h \
          mycomplex.h

DOCS = readme.txt
CONFIG = configure.ac configure Makefile.in
SAMPLE_CONFIG = config-win.sh

library : $(LIBA)
$(LIBA) : $(SOURCE:.c=.o)
	$(AR) $(ARFLAGS) r $(LIBA) $?
	- $(RANLIB) $(LIBA)

.c.o: $(HEADERS)
	$(CC) -c $(CFLAGS) $< -o $@

install:
	echo "No install"

uninstall:

clean:
	rm -f *.o *.a *.bak

distclean: clean
	rm -r -f config.* Makefile autom4te.cache

#ifndef DIST_DIR
#  package = degrib-2.03
#  DIST_DIR = ./$(package)
#  DIST_TARCMD = tar -cf $(package).tar $(DIST_DIR)
#  DIST_RMCMD = rm -r -f $(package)
#  DIST_GZIPCMD = gzip $(package).tar
#endif

DISTRIB = $(SOURCE) $(HEADERS) $(DOCS) $(CONFIG) $(SAMPLE_CONFIG)
dist: $(DISTRIB)
	@if [ ! -d $(DIST_DIR) ]; then mkdir $(DIST_DIR); fi
	@for file in $(DISTRIB); do cp $$file $(DIST_DIR); done
	@$(DIST_TARCMD)
	@$(DIST_RMCMD)
	@$(DIST_GZIPCMD)


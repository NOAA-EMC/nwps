SHELL = /bin/sh

#  Package and Version info:
#      Conformal Map Transforms - ellipsoidal 3.1
#  Report bugs to albion.taylor@noaa.gov

prefix = /lfs/h2/emc/couple/noscrub/saeideh.banihashemi/nwps/nwps.v1.4.6/sorc/emapf-c
exec_prefix = ${prefix}
bindir = ${exec_prefix}/bin
srcdir = .
libdir = ${exec_prefix}/lib
top_srcdir = .

CC = cc
CFLAGS = -O -g -O2 
LDFLAGS = 
AR = ar
ARFLAGS = 
RANLIB = ranlib
EXEEXT = 

INSTALL = /usr/bin/install -c


LIBNAME = emapf
LIBA = lib$(LIBNAME).a

SOURCE = cc2gll.c cc2gxy.c ccurv.c cg2cll.c cgszll.c cgszxy.c cpolll.c \
 cpolxy.c eqvlat.c logabova.c mkgeoid.c stcm1p.c stcm2p.c stlmbr.c ymercfns.c\
 

TESTPROGS = testemapf tseqlat geoidtst tsgridft

all: library

mkgeoid.o : mkgeoid.c geoids.h

library : $(LIBA)
$(LIBA) : $(SOURCE:.c=.o)
	$(AR) $(ARFLAGS) r $(LIBA) $?
	- $(RANLIB) $(LIBA)


tsgridft: tsgridft.c $(LIBA)
	$(CC) $(CFLAGS) -o $@ $@.c -L./ -lemapf -lm

tseqlat: tseqlat.c $(LIBA)
	$(CC) $(CFLAGS) -o $@ $@.c -L./ -lemapf -lm

testemapf: testemapf.c $(LIBA)
	$(CC) $(CFLAGS) -o $@ $@.c -L./ -lemapf -lm

geoidtst: geoidtst.c $(LIBA)
	$(CC) $(CFLAGS) -o $@ $@.c -L./ -lemapf -lm



install: library
	$(INSTALL) -d $(libdir)
	$(INSTALL) -m 644 $(LIBA) $(libdir)
# for use with install-sh, perms 644 must be separated from -m

clean:
	rm -f *.o *.a;for file in $(TESTPROGS);\
 do rm -f $$file$(EXEEXT) $$file.tmp;done

distclean: clean
	rm -r -f config.* Makefile cmapf.h autom4te.cache

test: $(LIBA)  $(TESTPROGS)
	@for file in $(TESTPROGS);do ./$$file > $$file.tmp;\
printf "Testing $$file... ";\
if diff $$file.tmp $$file.txt;then printf "ok.\n";else printf "failed.\n";fi;\
done


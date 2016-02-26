#
# this makefile is for gnu-make on a linux box
# wgrib2 rerequires grib2c (NCEP C grib2), jasper (jpeg), z and png libraries
#
#  REQUIRES GNU make
# mod 1/07 M. Schwarb
# mod 2/07 W. Ebisuzaki changes for *.dat files
# mod 8/07 W. Ebisuzaki cleanup
# mod 4/09 W. Ebisuzaki config.h, netcdf4
#

SHELL=/bin/sh

ifeq ($(64BIT),1)
	LIBDIR = ${NWPSdir}/lib64
else
	LIBDIR = ${NWPSdir}/lib32
endif


ifeq ($(INTEL),1)
        FORTLIB = -lifcore
else
        FORTLIB = -lgfortran
endif

all:=$(patsubst %.c,%.o,$(wildcard *.c))
code:=$(filter-out fnlist.o,$(all))
o=$(wildcard *.o)
h:=grb2.h  wgrib2.h fnlist.h config.h
options=$(wildcard [A-Z]*.c)
CODE_TABLE_DAT=$(wildcard CodeTable_[0-9].[0-9]*.dat)

#FLAGS=${CPPFLAGS} ${CFLAGS} \
#-I$(LIBDIR)/jasper/include -I$(LIBDIR)/libpng/include -I$(LIBDIR)/netcdf/include \
#-I$(LIBDIR)/hdf5/include -I$(LIBDIR)/zlib/include -I$(LIBDIR)/szip/include -I./ -I../g2clib-1.4.0 \
#-I$(LIBDIR)/proj/include -L$(LIBDIR)/proj/lib \
#-L../g2clib-1.4.0 -L$(LIBDIR)/hdf5/lib -L$(LIBDIR)/netcdf/lib -L$(LIBDIR)/libpng/lib \
#-L$(LIBDIR)/jasper/lib -L$(LIBDIR)/zlib/lib -L$(LIBDIR)/szip/lib \
#-I../iplib -L../iplib -I../gctpc/source -L../gctpc/source

FLAGS=${CPPFLAGS} ${CFLAGS} \
-I$(JASPER_INC) -I$(PNG_INC) \
-I$(Z_INC) -I./ -I../g2clib-1.4.0 \
-L../g2clib-1.4.0 -L$(PNG_LIB) \
-L$(JASPER_LIB) -L$(Z_LIB) \
-I../iplib -L../iplib -I../gctpc/source -L../gctpc/source

STATIC_LIBS=../g2clib-1.4.0/libgrib2c.a $(LIBDIR)/hdf5/lib/libhdf5.a $(LIBDIR)/hdf5/lib/libhdf5_hl.a \
$(LIBDIR)/netcdf/lib/libnetcdf_c++.a $(LIBDIR)/netcdf/lib/libnetcdf.a $(LIBDIR)/libpng/lib/libpng.a \
$(LIBDIR)/jasper/lib/libjasper.a $(LIBDIR)/zlib/lib/libz.a $(LIBDIR)/szip/lib/libsz.a \
$(LIBDIR)/proj/lib/libproj.a ../iplib/libipolate.a ../gctpc/source/libgeo.a -lm -static

## LIBS=-lm -lgrib2c -lhdf5 -lhdf5_hl -lnetcdf -lnetcdf_c++ -lpng -ljasper -lz -lsz -lproj -lgeo -lipolate -lgfortran
## LIBS=-lm -lgrib2c -lhdf5 -lhdf5_hl -lnetcdf -lpng -ljasper -lz -lsz -lproj -lgeo -lipolate $(FORTLIB)
##LIBS=-lm -lgrib2c -lpng -ljasper -lz -lgeo -lipolate $(FORTLIB)
LIBS=-lm -lgrib2c -lpng -ljasper -lz -lgeo ../iplib/libipolate.a $(FORTLIB)

wgrib2: $h ${all} fnlist.c
	${CC} -o wgrib2 ${FLAGS} ${all} ${LDFLAGS} $(LIBS)
	rm Config.o

fast:	${code}
	touch fnlist.o fnlist.c fnlist.h
	${CC} -o wgrib2 ${FLAGS} ${all} ${LDFLAGS} $(LIBS)
	rm Config.o

fnlist.c:	${options}
	./function.sh 

fnlist.h:	${options}
	./function.sh

Help.o:	Help.c wgrib2.h
	${CC} -c ${FLAGS} Help.c

CodeTable.o:	CodeTable.c ${CODE_TABLE_DAT}
	${CC} -c ${FLAGS} CodeTable.c

cname.o:	cname.c
	${CC} -c ${FLAGS} cname.c

Sec1.o:	Sec1.c code_table0.dat ncep_tableC.dat
	${CC} -c ${FLAGS} Sec1.c

gribtab.o:	gribtab.c gribtab.dat misc_gribtab.dat NDFD_gribtab.dat
	${CC} -c ${FLAGS} gribtab.c

Mod_grib.o:	Mod_grib.c NCEP_local_levels_test.h
	${CC} -c ${CFLAGS} Mod_grib.c


.c.o:	$(*).c
	$(CC) -c ${FLAGS}  $*.c

install:
	mkdir -p  $(NWPSdir)/exec
	cp wgrib2 $(NWPSdir)/exec/wgrib2
	chmod 755 $(NWPSdir)/exec/wgrib2

clean:
	touch wgrib2
	rm ${o} wgrib2

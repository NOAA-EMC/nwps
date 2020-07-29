SHELL = /bin/sh

top_srcdir = .
abs_top_builddir = /gpfs/td1/emc/marine/save/Douglas.Gaer/WCOSS_incl_rip_shiproute_gfswinds/sorc/degrib_gnu_cray/src
package = degrib-2.03

CC = cc
CFLAGS = -v -Wall -O2 -Wall -fsigned-char
ARFLAGS = 
EXEEXT = 

LIB_DEP1 =  \
           ./libaat/libaat.a

LIB_DEPENDS = $(LIB_DEP1) \
              ./zlib/libz.a \
              ./zlib/contrib/minizip/libminizip.a \
              ./libpng/libpng.a \
              ./jpeg2000/src/libjasper/jpc/.libs/libjpc.a \
              ./jpeg2000/src/libjasper/base/.libs/libbase.a \
              ./mdl_g2c/libmdl_g2c.a \
              ./gd/libgd.a \
              ./emapf-c/libemapf.a \
              ./netcdf/libsrc/libnetcdf.a \
              ./libxml/.libs/libxml2.a

PRJ_NAME = degrib

all_void: $(PRJ_NAME)/$(PRJ_NAME)

$(PRJ_NAME)/$(PRJ_NAME): $(LIB_DEPENDS)
	@echo "-----------------------------"
	@echo "Attempting to compile $(PRJ_NAME)..."
	(cd $(PRJ_NAME) && make)
	@echo "Finished with $(PRJ_NAME)"
	@echo "-----------------------------"
	@echo ""

#####
# LIBRARIES
#####
: ${top_srcdir}//Makefile
	@echo "-----------------------------"
	@echo "Attempting to compile memwatch..."
	(cd ${top_srcdir}/ && make)
	@echo "Finished with memwatch..."
	@echo "-----------------------------"
	@echo ""

./zlib/libz.a: ./zlib/makefile
	@echo "-----------------------------"
	@echo "Attempting to compile Zlib..."
	@echo "You may already have zlib (libz.a).  If so, you could change"
	@echo "   the makefiles in ./degrib to use it, skipping this step"
	(cd ./zlib  && make)
	@echo "Finished with Zlib..."
	@echo "-----------------------------"
	@echo ""

./zlib/contrib/minizip/libminizip.a: ./zlib/contrib/minizip/makefile
	@echo "-----------------------------"
	@echo "Attempting to compile minizip lib (for kmz)..."
	(cd ./zlib/contrib/minizip  && make)
	@echo "Finished with minizip lib..."
	@echo "-----------------------------"
	@echo ""

./libpng/libpng.a: ./libpng/makefile
	@echo "-----------------------------"
	@echo "Attempting to compile libpng..."
	@echo "You may already have libpng (libpng.a).  If so, you could change"
	@echo "   the makefiles in ./degrib to use it, skipping this step"
	(cd ./libpng  && make)
	@echo "Finished with libpng..."
	@echo "-----------------------------"
	@echo ""

./jpeg2000/src/libjasper/jpc/.libs/libjpc.a: ./jpeg2000/makefile
	@echo "-----------------------------"
	@echo "Attempting to compile jpeg2000..."
	@echo "You may already have jasper (libjasper.a).  If so, you could change"
	@echo "   the makefiles in ./degrib to use it, skipping this step"
	@echo "What I have provided is the subset of jasper used by the GRIB2 library"
	@echo "If it doesn't work, try the complete jasper library available at:"
	@echo "   http://www.ece.uvic.ca/~mdadams/jasper/"
	@echo "If you use -ljasper.a, you may need to change the makefiles in ./degrib"
	@echo "-----------------------------"
	(cd ./jpeg2000  && make)
	@echo "Finished with jpeg2000..."
	@echo "-----------------------------"
	@echo ""

./jpeg2000/src/libjasper/base/.libs/libbase.a: ./jpeg2000/makefile
	@echo "-----------------------------"
	@echo "Attempting to compile jpeg2000..."
	@echo "You may already have jasper (libjasper.a).  If so, you could change"
	@echo "   the makefiles in ./degrib to use it, skipping this step"
	@echo "What I have provided is the subset of jasper used by the GRIB2 library"
	@echo "If it doesn't work, try the complete jasper library available at:"
	@echo "   http://www.ece.uvic.ca/~mdadams/jasper/"
	@echo "If you use -ljasper.a, you may need to change the makefiles in ./degrib"
	@echo "-----------------------------"
	(cd ./jpeg2000  && make)
	@echo "Finished with jpeg2000..."
	@echo "-----------------------------"
	@echo ""

./libaat/libaat.a: ./libaat/makefile
	@echo "-----------------------------"
	@echo "Attempting to compile libaat..."
	(cd libaat && make)
	@echo "Finished with libaat..."
	@echo "-----------------------------"
	@echo ""

./mdl_g2c/libmdl_g2c.a: ./mdl_g2c/makefile
	@echo "-----------------------------"
	@echo "Attempting to compile mdl_g2c..."
	(cd mdl_g2c && make)
	@echo "Finished with mdl_g2c..."
	@echo "-----------------------------"
	@echo ""

./gd/libgd.a: ./gd/makefile
	@echo "-----------------------------"
	@echo "Attempting to compile gd..."
	(cd ./gd && make INCLUDES=-I$(abs_top_builddir)/../include/libpng)
	(cd ./gd && make)
	@echo "Finished with gd..."
	@echo "-----------------------------"
	@echo ""

./emapf-c/libemapf.a: ./emapf-c/makefile
	@echo "-----------------------------"
	@echo "Attempting to compile emapf-c..."
	(cd emapf-c &&	make)
	@echo "Finished with emapf-c..."
	@echo "-----------------------------"
	@echo ""

./netcdf/libsrc/libnetcdf.a: ./netcdf/makefile
	@echo "-----------------------------"
	@echo "Attempting to compile netcdf..."
	(cd netcdf && make)
	@echo "Finished with netcdf..."
	@echo "-----------------------------"
	@echo ""

./libxml/.libs/libxml2.a: ./libxml/makefile
	@echo "-----------------------------"
	@echo "Attempting to compile libxml..."
	(cd ./libxml  && make)
	@echo "Finished with libxml..."
	@echo "-----------------------------"
	@echo ""

#####
# Configurables
#####
${top_srcdir}//Makefile: ${top_srcdir}//configure
	@echo "-----------------------------"
	@echo "Attempting to configure memwatch..."
	(cd ${top_srcdir}/ && ./configure)
	@echo "-----------------------------"
	@echo ""

# Following handled by configure.ac
#./zlib/Makefile: ./zlib/configure
#	@echo "-----------------------------"
#	@echo "Attempting to configure Zlib..."
#	(cd ./zlib && ./configure)
#	@echo "-----------------------------"
#	@echo ""

./jpeg2000/Makefile: ./jpeg2000/configure
	@echo "-----------------------------"
	@echo "Attempting to configure jpeg2000..."
#	(cd ./jpeg2000 && export CC="$(CC)" && export CFLAGS="$(CFLAGS)" && ./configure)
	@echo "Finished with jpeg2000..."
	@echo "-----------------------------"
	@echo ""

# Following handled by configure.ac
#./libaat/Makefile: ./libaat/configure
#	@echo "-----------------------------"
#	@echo "Attempting to configure libaat..."
#	(cd ./libaat && ./configure)
#	@echo "-----------------------------"
#	@echo ""

./emapf-c/Makefile: ./emapf-c/configure
	@echo "-----------------------------"
	@echo "Attempting to configure emapf-c..."
	(cd ./emapf-c && ./configure CC="$(CC)" CFLAGS="$(CFLAGS)" ARFLAGS=$(ARFLAGS))
	@echo "Finished with emapf-c..."
	@echo "-----------------------------"
	@echo ""

./netcdf/macros.make: ./netcdf/configure
	@echo "-----------------------------"
	@echo "Attempting to configure netcdf..."
	(cd ./netcdf && export CC="$(CC)" CFLAGS="$(CFLAGS)" ARFLAGS="$(ARFLAGS) cru" CXX="" FC="" F90="" && ./configure)
	@echo "Finished with netcdf..."
	@echo "-----------------------------"
	@echo ""

./libxml/Makefile: ./libxml/configure
	@echo "-----------------------------"
	@echo "Attempting to configure libxml..."
	(cd ./libxml && export CC="$(CC)" && export CFLAGS="$(CFLAGS)" && \
                 ./configure --with-minimum --with-tree --with-output --enable-shared=no \
                 --with-zlib=$(abs_top_builddir)/zlib)
	@echo "Finished with libxml..."
	@echo "-----------------------------"
	@echo ""

#####
# Regular targets
#####
all:
clean:
	cd zlib; make all
	cd jpeg2000; make all
	cd libpng; make all
	cd netcdf; make all
	cd libaat; make all
	cd mdl_g2c; make all
	cd gd; make all
	cd emapf-c; make all
	cd dwmllib; make all
	cd libxml; make all
	cd degrib; make all

install:
	echo "Install NWPS degrib binary"
	cp -fv degrib/degrib ../../../exec/degrib
	chmod 755 ../../../exec/degrib


clean:
	cd ./zlib; make clean
	cd ./zlib/contrib/minizip; make clean
	cd ./netcdf; make clean
	cd ./libaat; make clean
	cd ./libpng; make clean
	cd ./jpeg2000; make clean
	rm -fv ./jpeg2000/configure
	rm -fv ./jpeg2000/config.log
	rm -rfv ./jpeg2000/autom4te.cache
	rm -fv ./jpeg2000/Makefile
	cd ./mdl_g2c; make clean
	cd ./gd; make clean
	cd ./emapf-c; make clean
	cd ./dwmllib; make clean
	cd ./libxml; make clean
	cd ./degrib; make clean

# clean: ./emapf-c/Makefile ./netcdf/Makefile ./jpeg2000/Makefile ./libxml/Makefile
clean_void: ./emapf-c/Makefile ./netcdf/Makefile
	- (cd ./zlib && make clean && rm -f example$(EXEEXT) minigzip$(EXEEXT))
	- (cd ./zlib/contrib/minizip && make clean)
	- (cd ./libpng && make clean)
	(cd ./libaat && make clean)
	(cd ./mdl_g2c && make clean)
	- (cd ./gd && make clean)
	- (cd ./emapf-c && make clean)
	- (cd ./netcdf && make clean)
	(cd ./dwmllib && make clean)
	- (cd ./degrib && make clean)
# Following gave problems in cygwin/mingw environment
#	(cd ./jpeg2000 && make clean)
#	(cd ./libxml && make clean)
	rm -f netcdf/ncdump/ncdump$(EXEEXT)
	rm -f netcdf/ncgen/ncgen$(EXEEXT)
	rm -r -f *.bak

# Note: This depends on the "Configurable's"
#distclean: ./emapf-c/Makefile ./netcdf/Makefile ./jpeg2000/Makefile ./libxml/Makefile
distclean: ./emapf-c/Makefile ./netcdf/Makefile
	- (cd ./zlib && make distclean)
	- (cd ./zlib/contrib/minizip && make distclean)
	- (cd ./libpng && make distclean)
	(cd ./libaat && make distclean)
	(cd ./mdl_g2c && make distclean)
	- (cd ./gd && make distclean)
	- (cd ./emapf-c && make distclean)
	- (cd ./netcdf && make distclean && rm macros.make)
# ./dwmllib didn't implement distclean
	(cd ./dwmllib && make clean)
	- (cd ./degrib && make distclean)
# Following gave problems in cygwin/mingw environment
#	(cd ./jpeg2000 && make distclean)
	(cd ./jpeg2000/ && rm -rf config.log config.status libtool jasper.spec Makefile autom4te.cache)
	(cd ./jpeg2000/src/ && rm -f Makefile)
	(cd ./jpeg2000/src/libjasper/ && rm -rf *.o *.lo *.la .deps .libs Makefile)
	(cd ./jpeg2000/src/libjasper/base && rm -rf *.o *.lo *.la .libs .deps Makefile)
	(cd ./jpeg2000/src/libjasper/jpc && rm -rf *.o *.lo *.la .libs .deps Makefile)
	(cd ./jpeg2000/src/libjasper/include && rm -f Makefile)
	(cd ./jpeg2000/src/libjasper/include/jasper && rm -f Makefile stamp-h1 jas_config.h jas_config.h.in~)
# Following gave problems in cygwin/mingw environment
#	(cd ./libxml && make distclean)
	(cd ./libxml && rm -rf *.o *.lo *.pc config.status xml2-config .deps Makefile libtool config.h COPYING COPYING.lnk config.log *.la .libs stamp-h1 libxml2.spec)
	(cd ./libxml/xstc && rm -f Makefile)
	(cd ./libxml/python && rm -rf setup.py Makefile .deps)
	(cd ./libxml/python/tests && rm -f Makefile)
	(cd ./libxml/example && rm -rf .deps Makefile)
	(cd ./libxml/doc && rm -f Makefile)
	(cd ./libxml/doc/devhelp && rm -f Makefile)
	(cd ./libxml/doc/examples && rm -rf .deps Makefile)
	(cd ./libxml/include && rm -f Makefile)
	(cd ./libxml/include/libxml && rm -f Makefile)
	rm -f netcdf/ncdump/ncdump$(EXEEXT)
	rm -f netcdf/ncgen/ncgen$(EXEEXT)
	rm -r -f *.bak config.status config.log Makefile autom4te.cache


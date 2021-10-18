#######################################################################
# Makefile                                    Arthur.Taylor@noaa.gov
#                              Decision Support Branch, MDL/OSTI/NWS
#                                                       Dec 14, 2017
# Makefile for degrib
# Usage:
#   make         - Build the executable
#   make install - Move the built executable to the exec dir
#   make clean   - Start with a clean slate
#######################################################################
CC      = $(C_COMP)

# Various directories
BINDIR = ../../exec
LIBDIR = ../../lib
EMAPF_SRC = $(LIBDIR)/sorc/emapf-c
GD_SRC = /usr/include

# Compiler flags
CFLAGS = -O3 -Wall
# CFLAGS += -strict-ansi
# CFLAGS += -fsigned-char -Wextra -pedantic -ansi

# Program #defines
CFLAGS += -DSIZEOF_LONG_INT=8# # Compile on a 64 bit platform
CFLAGS += -D__64BIT__#         # Use 64 bit compilation
CFLAGS += -D_LINUX_#           # Assume linux (rather than windows)

# Include paths
INC     = -I$(G2C_INC)
INC    += -I$(EMAPF_SRC)
INC    += -I$(GD_SRC)
CFLAGS += -I. $(INC)

# Libraries and linker flags
EMAPF_LIB = $(LIBDIR)/libemapf.a
GD_LIB = -L /usr/lib64/ -lgd
LIBS    = $(G2C_LIB) $(GD_LIB) $(PNG_LIB) $(Z_LIB) $(JASPER_LIB) $(EMAPF_LIB)
LDFLAGS =

# Source, Headers and Objects
SOURCE=chain.c
SOURCE+=clock.c
SOURCE+=commands.c
SOURCE+=cube.c
SOURCE+=database.c
SOURCE+=degrib1.c
SOURCE+=degrib2.c
SOURCE+=drawgrib.c
SOURCE+=drawlib.c
SOURCE+=engribapi.c
SOURCE+=genprobe.c
SOURCE+=grib1tab.c
SOURCE+=grib2api.c
SOURCE+=grpprobe.c
SOURCE+=hazard.c
SOURCE+=interp.c
SOURCE+=inventory.c
SOURCE+=ioapi.c
SOURCE+=mapini.c
SOURCE+=metaname.c
SOURCE+=metaparse.c
SOURCE+=metaprint.c
SOURCE+=myassert.c
SOURCE+=myerror.c
SOURCE+=mymapf.c
SOURCE+=myutil.c
SOURCE+=myzip.c
SOURCE+=pack.c
SOURCE+=probe.c
# SOURCE+=readnc.c
SOURCE+=scan.c
SOURCE+=sector.c
SOURCE+=solar.c
SOURCE+=split.c
SOURCE+=tdlpack.c
SOURCE+=tendian.c
SOURCE+=userparse.c
SOURCE+=weather.c
SOURCE+=writecsv.c
SOURCE+=writeflt.c
SOURCE+=writegra.c
SOURCE+=writekml.c
# SOURCE+=writenc.c
SOURCE+=writeshp.c
SOURCE+=zip.c

HEADERS=chain.h
HEADERS+=clock.h
HEADERS+=commands.h
# HEADERS+=crypt.h
HEADERS+=cube.h
HEADERS+=database.h
HEADERS+=degrib1.h
HEADERS+=degrib2.h
HEADERS+=drawgrib.h
HEADERS+=drawlib.h
HEADERS+=genprobe.h
HEADERS+=grpprobe.h
HEADERS+=hazard.h
HEADERS+=interp.h
HEADERS+=inventory.h
HEADERS+=ioapi.h
HEADERS+=libaat.h
HEADERS+=libaat_type.h
HEADERS+=mapini.h
HEADERS+=mdl_g2c.h
HEADERS+=meta.h
HEADERS+=metaname.h
HEADERS+=myassert.h
HEADERS+=mycomplex.h
HEADERS+=myerror.h
HEADERS+=mymapf.h
HEADERS+=myutil.h
HEADERS+=myzip.h
HEADERS+=pack.h
HEADERS+=probe.h
HEADERS+=scan.h
HEADERS+=sector.h
HEADERS+=solar.h
HEADERS+=split.h
HEADERS+=tdlpack.h
HEADERS+=tendian.h
HEADERS+=type.h
HEADERS+=userparse.h
HEADERS+=weather.h
HEADERS+=write.h
HEADERS+=zip.h

OBJS=$(SOURCE:.c=.o)

# File with 'main()'
MAIN=cstart.c

CMD     = degrib
# CMDFLAGS  = $(CFLAGS) -DPKGVERS=\"1.1\" -DPKGDATE=\"2016-03-16\"
# CMDFLAGS += $(CFLAGS) -DHOLD_CONSTANT#  # Allow stationary storms during cubic spline

#######################################################################
# Actual rules to build the program
#######################################################################
#all: check_prereqs $(CMD)
all: $(CMD)

$(CMD): $(OBJS) $(HEADERS) $(MAIN)
	$(CC) $(MAIN) $(CMDFLAGS) $(LDFLAGS) $(OBJS) $(LIBS) -o $(CMD)

install: $(CMD)
	mv $(CMD) ${BINDIR}/

clean:
	-rm -f $(OBJS) $(CMD)
#	(cd $(GRIB2_SRC) && make clean)
#	(cd $(EMAPF_SRC) && make clean)
#	(cd $(GD_SRC) && make clean)
#	-rm -f $(GRIB2_LIB)
#	-rm -f $(EMAPF_LIB) $(GD_LIB)

#check_prereqs: $(GRIB2_LIB) $(EMAPF_LIB) $(GD_LIB)
#check_prereqs: $(EMAPF_LIB) $(GD_LIB)
#	$(SPADIR)/check_libs.bash $(LIBS)

.c.o: $(HEADERS)
	$(CC) -c $(CFLAGS) $<

#$(GRIB2_LIB): $(GRIB2_SRC)/Makefile
#	(cd $(GRIB2_SRC) && make clean install)
#
$(EMAPF_LIB): $(EMAPF_SRC)/Makefile
	(cd $(EMAPF_SRC) && make clean install)

$(GD_LIB): $(GD_SRC)/Makefile
	(cd $(GD_SRC) && make clean)
	(cd $(GD_SRC) && make)
	cp $(GD_SRC)/libgd.a $(GD_LIB)

# makefile : makes the program ripforecast.exe
# Author: Andre van der Westhuysen (andre.vanderwesthuysen@noaa.gov)
# File Creation Date: 06/16/2016

FC = ftn
FFLAGS ?= -O2

clean :
	rm ripforecast.exe ripforecast.o bulkmodel.o eventcalc.o read_nwps.o read_shore.o

ripforecast : bulkmodel.o eventcalc.o read_nwps.o read_shore.o ripforecast.o
	$(FC) $(FFLAGS) -o ripforecast.exe ripforecast.o bulkmodel.o eventcalc.o read_nwps.o read_shore.o

ripforecast.o : ripforecast.f
	$(FC) $(FFLAGS) -c ripforecast.f

bulkmodel.o : bulkmodel.f
	$(FC) $(FFLAGS) -c bulkmodel.f

eventcalc.o : eventcalc.f
	$(FC) $(FFLAGS) -c eventcalc.f

read_nwps.o : read_nwps.f
	$(FC) $(FFLAGS) -c read_nwps.f

read_shore.o : read_shore.f
	$(FC) $(FFLAGS) -c read_shore.f

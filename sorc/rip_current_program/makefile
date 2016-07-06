# makefile : makes the program ripforecast.x
# Author: Andre van der Westhuysen (andre.vanderwesthuysen@noaa.gov)
# File Creation Date: 06/16/2016

FC = ftn

clean :
	rm ripforecast.exe ripforecast.o bulkmodel.o eventcalc.o read_nwps.o read_shore.o

ripforecast : bulkmodel.o eventcalc.o read_nwps.o read_shore.o ripforecast.o
	$(FC) -o ripforecast.exe ripforecast.o bulkmodel.o eventcalc.o read_nwps.o read_shore.o

ripforecast.o : ripforecast.f
	$(FC) -c -O ripforecast.f

bulkmodel.o : bulkmodel.f
	$(FC) -c -O bulkmodel.f

eventcalc.o : eventcalc.f
	$(FC) -c -O eventcalc.f

read_nwps.o : read_nwps.f
	$(FC) -c -O read_nwps.f

read_shore.o : read_shore.f
	$(FC) -c -O read_shore.f


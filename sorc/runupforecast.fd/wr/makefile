# makefile : makes the program runupforecast_wr.exe
# Author: Andre van der Westhuysen (andre.vanderwesthuysen@noaa.gov)

FC = ftn
FFLAGS ?= -O2

clean :
	rm runupforecast_wr.exe runupforecast.o read_nwps.o read_slope.o runupcalc.o

runupforecast_wr : read_nwps.o read_slope.o runupcalc.o runupforecast.o
	$(FC) $(FFLAGS) -o runupforecast_wr.exe runupforecast.o read_nwps.o read_slope.o runupcalc.o

runupforecast.o : runupforecast.f
	$(FC) $(FFLAGS) -c runupforecast.f

read_nwps.o : read_nwps.f
	$(FC) $(FFLAGS) -c read_nwps.f

read_slope.o : read_slope.f
	$(FC) $(FFLAGS) -c read_slope.f

runupcalc.o : runupcalc.f
	$(FC) $(FFLAGS) -c runupcalc.f

# makefile : makes the program runupforecast.exe
# Author: Andre van der Westhuysen (andre.vanderwesthuysen@noaa.gov)

FC = ftn

clean :
	rm runupforecast_wr.exe runupforecast.o read_nwps.o read_slope.o runupcalc.o

runupforecast_wr : read_nwps.o read_slope.o runupcalc.o runupforecast.o
	$(FC) -o runupforecast_wr.exe runupforecast.o read_nwps.o read_slope.o runupcalc.o

runupforecast.o : runupforecast.f
	$(FC) -c -O runupforecast.f

read_nwps.o : read_nwps.f
	$(FC) -c -O read_nwps.f

read_slope.o : read_slope.f
	$(FC) -c -O read_slope.f

runupcalc.o : runupcalc.f
	$(FC) -c -O runupcalc.f


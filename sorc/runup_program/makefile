# makefile : makes the program runupforecast.exe
# Author: Andre van der Westhuysen (andre.vanderwesthuysen@noaa.gov)

FC = gfortran

clean :
	rm runupforecast.exe runupforecast.o read_nwps.o read_slope.o runupcalc.o

runupforecast : read_nwps.o read_slope.o runupcalc.o runupforecast.o
	$(FC) -o runupforecast.exe runupforecast.o read_nwps.o read_slope.o runupcalc.o

runupforecast.o : runupforecast.f
	$(FC) -O -c runupforecast.f

read_nwps.o : read_nwps.f
	$(FC) -O -c read_nwps.f

read_slope.o : read_slope.f
	$(FC) -O -c read_slope.f

runupcalc.o : runupcalc.f
	$(FC) -O -c runupcalc.f


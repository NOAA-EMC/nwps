# makefile : makes the program ww3_sysprep.exe
# Author: Andre van der Westhuysen (andre.vanderwesthuysen@noaa.gov)
# File Creation Date: 07/22/2017

FC = ftn

clean :
	rm ww3_sysprep.exe ww3_sysprep.o

ww3_sysprep : ww3_sysprep.o
	$(FC) -o ww3_sysprep.exe ww3_sysprep.o

ww3_sysprep.o : ww3_sysprep.f
	$(FC) -c -O ww3_sysprep.f

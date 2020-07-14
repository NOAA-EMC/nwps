README file for sea ice mask program 
Last modified: 05/23/2016

The sea ice mask program is used block out ice areas in ESTOFS water
level clips. The data points are extracted from grib2 input using
wgrib2. The sea program inputs an ESTOFS BIN file and a sea ice BIN
file. The ouput is a text input for SWAN water level. To test program
modifications:

> cd testdata
> ../seaice_mask -m99999 estofs.bin seaice.bin > waterlevel.dat


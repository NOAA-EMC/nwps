# README file for fix ASCII point data program
# Last modified: 05/24/2016

The fix ASCII point data program is used to change undefined value to
0.0 for SWAN input files. Data points are extracted from clipped grib2
files using wgrib2. This program is a highly optimized text parser
designed for fast file I/O. Using the "sed" command to replace text
data is very slow for large grids. The fix ASCII point data program
reads text files as binary input insead of line by line reads. 

To test program modifications:

> cd testdata
> wgrib2 estofs.pac.t00z.alaska.f000.grib2 -no_header -match var -text estofs_waterlevel.dat
> ../fix_ascii_point_data estofs_waterlevel.dat 9.999e+20 0.0 swan_waterlevel.dat



# README file for read AWIPS wind file program
# Last modified: 05/23/2016

The read AWIPS wind file is used read GFE wind grids, re-project,
and interpolate onto a LAT/LON grid. This input processing is based on
the original Perl code developed at WFO Eureka. The input format is
an AWIPS1 netCDF dump. In AWIPS2 the ifpnetCDF tool is used to
generate netCDF files. The ncdump command is to generate the input to
this program.

To test program modifications:

> cd testdata
> ./test_input_winds.sh MFL_Wind_hurricane_testcase.txt.gz

To test program modifications and plot results:

> cd testdata
> ./plot_input_winds.sh MFL_Wind_hurricane_testcase.txt.gz

NOTE: The plotting routine requires the GRADS module. The output plots
represent the wind grid that will be fed into SWAN.


# README file for write grib2 template program
# Last modified: 05/21/2016

This program is use to write a grib2 template using a meta data file
to setup the grid parms. To test program modifications:

> cd testdata
> ../g2_write_template DEPTH.meta.current_hour DEPTH_template.grib2
> wgrib2 -V DEPTH_template.grib2
 

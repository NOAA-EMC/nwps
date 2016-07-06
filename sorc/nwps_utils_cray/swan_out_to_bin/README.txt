# README file for SWAN output to BIN program
# Last modified: 05/23/2016

This program is used to read SWAN output files and create an output
Fortran binary file of the data points. The BIN file is use with a
grib2 template to encode that SWAN output data into a grib2 file. To
test program modifications:

>  ../swan_out_to_bin -n"-99" DEPTH.CG1.CGRID.YY11.MO01.DD25.HH00 627 3 1 24
>  wgrib2 DEPTH_template.grib2 -no_header -import_bin 24_DEPTH.CG1.CGRID.YY11.MO01.DD25.HH00.bin -grib_out DEPTH.grib2
>  wgrib2 -V DEPTH.grib2 

To plot with GRADS:

> g2ctl DEPTH.grib2 > DEPTH.ctl
> gribmap -i DEPTH.ctl
> grads
> open DEPTH.ctl
> q file
> display dbsssfc


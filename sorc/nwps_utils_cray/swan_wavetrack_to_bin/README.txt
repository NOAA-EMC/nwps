# README file for SWAN wave track to bin 
# Last modified: 05/28/2016

Program used to read SWAN wave tracking output files and copy the
points for all wave groups to a Fortran bin file used by wgrib2 to
encode the points into a grib2 file.

To build:

> make

To test changes to the encoder:

> cd testdata/eka
> ../../swan_wavetrack_to_bin -n"9999" -t3 -i1 SYS_DIR.OUT points.bin partition.meta templates.grib2 DIR
> wgrib2 templates.grib2 -no_header -import_bin points.bin -grib_out final_dir.grib2

To test the results

> wgrib2 -d 1 -V final_dir.grib2
> wgrib2 -d 1 final_dir.grib2 -no_header -text out.dat 
> wgrib2 final_dir.grib2 -no_header -bin out.bin

# Manual packing test using real data.

The data files needed for a manual packing are stored in the NWPS
${VARdir}/wavetraking directory following each model run.

> mkdir -p mfr
> cd mfr
> cp /gpfs/hps/ptmp/Andre.VanderWesthuysen/data/mfr.20160528/var/wavetracking/mfr_tracking_raw_files_20160528_1200.tar.gz .

> for TYPE in HSIGN DIR TP 
> do 
> ../../swan_wavetrack_to_bin -n"9999" -t3 -i1 SYS_${TYPE}.OUT ${TYPE}_points.bin partition.meta ${TYPE}_templates.grib2 ${TYPE}
> $WGRIB2 ${TYPE}_templates.grib2 -no_header -import_bin ${TYPE}_points.bin -grib_out ${TYPE}_final.grib2
> done

> cat /dev/null > mfr_nwps_CG0_Trkng_20160528_1200.grib2
> cat HSIGN_final.grib2 >> mfr_nwps_CG0_Trkng_20160528_1200.grib2
> cat DIR_final.grib2 >> mfr_nwps_CG0_Trkng_20160528_1200.grib2
> cat TP_final.grib2 >> mfr_nwps_CG0_Trkng_20160528_1200.grib2
>  $WGRIB2 mfr_nwps_CG0_Trkng_20160528_1200.grib2







!/bin/bash
# ----------------------------------------------------------- 
# UNIX Shell Script File
# Original Author(s): Andre.VanderWesthuysen@noaa.gov
# File Creation Date: 07/15/2020
# Date Last Modified: 
#
# Version control: 1.3
#
# Support Team:
#
# Contributors: Andre.VanderWesthuysen@noaa.gov
# ------------- Program Description and Details ------------- 
# ----------------------------------------------------------- 
#  Corrections to the SWAN repo for use with NWPS. Specifically, 
#  this script updates the floating point formatting in the 
#  print file PRINTF, to avoid the following Intel compilation error:
#
#  "
#  remark #8291: Recommended relationship between field width 'W' and 
#  the number of fractional digits 'D' in this edit descriptor is 'W>=D+7'
#  "
# ----------------------------------------------------------- 

cd $NWPSdir/sorc/punswan4110.fd
echo 'Script to update the floating point formatting in the print file PRINTF'  

echo 'Backing up original source code files...'
cp -p swancom1.ftn swancom1.ftn.orig_formatting
cp -p swanser.ftn swanser.ftn.orig_formatting
cp -p swanpre1.ftn swanpre1.ftn.orig_formatting
cp -p swancom5.ftn swancom5.ftn.orig_formatting
cp -p swanout1.ftn swanout1.ftn.orig_formatting
cp -p SwanInterpolateAc.ftn90 SwanInterpolateAc.ftn90.orig_formatting
cp -p SwanInterpolateOutput.ftn90 SwanInterpolateOutput.ftn90.orig_formatting

echo 'Replacing PRINTF floating point formatting...'
sed -i 's/E12.6/E13.6/g' swancom1.ftn
sed -i 's/E10.4/E11.4/g' swanser.ftn
sed -i 's/E8.3/E10.3/g' swanpre1.ftn
sed -i 's/E10.4/E11.4/g' swancom5.ftn
sed -i 's/E9.3/E10.3/g' swanout1.ftn
sed -i 's/E10.4/E11.4/g' swanout1.ftn
sed -i 's/e10.4/e11.4/g' SwanInterpolateAc.ftn90
sed -i 's/e10.4/e11.4/g' SwanInterpolateOutput.ftn90

exit 0

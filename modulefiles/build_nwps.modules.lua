--%Module######################################################################
----                                             Andre.VanderWesthuysen@noaa.gov
----                                                           NOAA/NWS/NCEP/EMC
---- NWPS
----_____________________________________________________
--proc ModulesHelp { ")) {
--puts stderr "Set environment veriables for NWPS"
--puts stderr "This module initializes the environment "
--puts stderr "for the Intel Compiler Suite $version\n"
--"))
--whatis(" NWPS whatis description")

--setenv("ver",tostring(os.getenv("nwps_ver")))
setenv("ver",os.getenv("nwps_ver"))

--set sys [uname sysname]
setenv("lname","NWPS")

-- Known conflicts ???

-- Loading Intel Compiler Suite
load("PrgEnv-intel/"..os.getenv("PrgEnv_intel_ver"))
load("intel/"..os.getenv("intel_ver"))
load("craype/"..os.getenv("craype_ver"))
load("cray-mpich/"..os.getenv("cray_mpich_ver"))
--load("hdf5/"..os.getenv("hdf5_ver"))
--load("netcdf/"..os.getenv("netcdf_ver"))
-- used for multiwavegrib2
load("jasper/"..os.getenv("jasper_ver"))
load("libpng/"..os.getenv("libpng_ver"))
load("zlib/"..os.getenv("zlib_ver"))
load("curl/"..os.getenv("curl_ver"))
load("g2/"..os.getenv("g2_ver"))
load("g2c/"..os.getenv("g2c_ver")) 
-- used for multiwavegrib1 and grib2
load("w3nco/"..os.getenv("w3nco_ver"))
load("bacio/"..os.getenv("bacio_ver"))

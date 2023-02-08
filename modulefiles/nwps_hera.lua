help([[
Build environment for NWPS utilities on Hera
]])

prepend_path("MODULEPATH", "/scratch2/NCEPDEV/nwprod/hpc-stack/libs/hpc-stack/modulefiles/stack")

local hpc_ver=os.getenv("hpc_ver") or "1.1.0"
local hpc_intel_ver=os.getenv("hpc_intel_ver") or "18.0.5.274"
local hpc_impi_ver=os.getenv("hpc_impi_ver") or "2018.0.4"
--local cmake_ver=os.getenv("cmake_ver") or "3.20.1"

local jasper_ver=os.getenv("jasper_ver") or "2.0.25"
local zlib_ver=os.getenv("zlib_ver") or "1.2.11"
local libpng_ver=os.getenv("libpng_ver") or "1.6.35"

load(pathJoin("hpc", hpc_ver))
load(pathJoin("hpc-intel", hpc_intel_ver))
load(pathJoin("hpc-impi", hpc_impi_ver))
--load(pathJoin("cmake", cmake_ver))

load(pathJoin("jasper", jasper_ver))
load(pathJoin("zlib", zlib_ver))
load(pathJoin("png", libpng_ver))

load("nwps_common")

prepend_path("MODULEPATH", "/scratch1/NCEPDEV/mdl/apps/modulefiles")
local cfp_ver=os.getenv("cfp_ver") or "2.0.1"
local esmf_ver=os.getenv("esmf_ver") or "8_1_1"
local wgrib2_ver = os.getenv("wgrib2_ver") or "2.0.8"
local prod_util_ver = os.getenv("prod_util_ver") or "1.2.2"
local grib_util_ver = os.getenv("grib_util_ver") or "1.2.4"

load(pathJoin("CFP", cfp_ver))
load(pathJoin("esmf", esmf_ver))
load(pathJoin("wgrib2", wgrib2_ver))
load(pathJoin("prod_util", prod_util_ver))
load(pathJoin("grib_util", grib_util_ver))

whatis("Description: NWPS utilities environment on Hera with Intel Compilers")

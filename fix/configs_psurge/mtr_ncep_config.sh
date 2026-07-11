#!/bin/sh
set -xa

# NCEP Config file for global RTOFS and ESTOF init files

# RTOFS Domain for ocean currents
export RTOFSLON="233.70 239.76"
export RTOFSLAT="34.50  39.90"

# STOFS Domain for water level
export STOFS_REGION="conus"
# ESFOTSDOMAIN="LON LAT 0. NX NY EW-RESOLUTION NS-RESOLUTION"
export STOFSDOMAIN=" 233.70 34.50 0.0 207 200 0.029326 0.027027"
export STOFSNX="208"
export STOFSNY="201"


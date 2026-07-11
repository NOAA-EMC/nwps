#!/bin/sh
set -xa

# NCEP Config file for global RTOFS and ESTOF init files

# RTOFS Domain for ocean currents
export RTOFSLON="283.75 287.25"
export RTOFSLAT="37.60 41.10"

# STOFS Domain for water level
export STOFS_REGION="conus"
# ESFOTSDOMAIN="LON LAT 0. NX NY EW-RESOLUTION NS-RESOLUTION"
export STOFSDOMAIN="283.75 37.60 0. 120 130 0.029326 0.027027"
export STOFSNX="121"
export STOFSNY="131"


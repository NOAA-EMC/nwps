#!/bin/sh
set -xa

# NCEP Config file for global RTOFS and ESTOF init files

# RTOFS Domain for ocean currents
export RTOFSLON="240.30 243.60"
export RTOFSLAT="31.45 34.10"

# STOFS Domain for water level
export STOFS_REGION="conus"
# ESFOTSDOMAIN="LON LAT 0. NX NY EW-RESOLUTION NS-RESOLUTION"
export STOFSDOMAIN="240.30 31.45 0.0 113 99 0.029326 0.027027"
export STOFSNX="114"
export STOFSNY="100"


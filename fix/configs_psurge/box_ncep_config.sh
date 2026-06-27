#!/bin/sh
set -xa

# NCEP Config file for global RTOFS and ESTOF init files

# RTOFS Domain for ocean currents
export RTOFSLON="287.00 291.65"
export RTOFSLAT="39.95 43.75"

# STOFS Domain for water level
export STOFS_REGION="conus"
# ESFOTSDOMAIN="LON LAT 0. NX NY EW-RESOLUTION NS-RESOLUTION"
export STOFSDOMAIN="287.00 39.95 0. 159 141 0.029326 0.027027"
export STOFSNX="160"
export STOFSNY="142"


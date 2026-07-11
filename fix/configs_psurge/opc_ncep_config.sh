#!/bin/sh
set -xa

# NCEP Config file for global RTOFS and ESTOF init files

# RTOFS Domain for ocean currents
export RTOFSLON="277.50 330.50"
export RTOFSLAT="26.50  67.50"

# STOFS Domain for water level
export STOFS_REGION="conus"
# ESFOTSDOMAIN="LON LAT 0. NX NY EW-RESOLUTION NS-RESOLUTION"
export STOFSDOMAIN="277.50 26.50  0.0 1808 1518 0.029326 0.027027"
export STOFSNX="1809"
export STOFSNY="1519"


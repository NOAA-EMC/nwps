#!/bin/sh
set -xa

# NCEP Config file for global RTOFS and ESTOF init files

# RTOFS Domain for ocean currents
export RTOFSLON="277.80 282.40"
export RTOFSLAT="30.17 34.08"

# STOFS Domain for water level
export STOFS_REGION="conus"
# ESFOTSDOMAIN="LON LAT 0. NX NY EW-RESOLUTION NS-RESOLUTION"
export STOFSDOMAIN="277.80 30.17 0. 134 171 0.029326 0.027027"
export STOFSNX="135"
export STOFSNY="172"


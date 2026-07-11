#!/bin/sh
set -xa

# RTOFS Domain for ocean currents
export RTOFSLON="270.80 278.70 "
export RTOFSLAT="28.50 31.5"

# STOFS Domain for water level
export STOFS_REGION="conus"
# ESFOTSDOMAIN="LON LAT 0. NX NY EW-RESOLUTION NS-RESOLUTION"
export STOFSDOMAIN="270.80 28.50 0. 268 110 0.029326 0.027027"
export STOFSNX="269"
export STOFSNY="111"



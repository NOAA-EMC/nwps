#!/bin/sh
set -xa

# RTOFS Domain for ocean currents
export RTOFSLON="262.00 282.00"
export RTOFSLAT="23.0 33.00"

# STOFS Domain for water level
export STOFS_REGION="conus"
# ESFOTSDOMAIN="LON LAT 0. NX NY EW-RESOLUTION NS-RESOLUTION"
export STOFSDOMAIN="262.00 23.0 0. 682 370 0.029326 0.027027"
export STOFSNX="683"
export STOFSNY="371"



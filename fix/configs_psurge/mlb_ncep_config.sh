#!/bin/sh
set -xa

# NCEP Config file for global RTOFS and ESTOF init files

# RTOFS Domain for ocean currents
export RTOFSLON="278.10 282.00"
export RTOFSLAT="26.00 30.50"

# STOFS Domain for water level
export STOFS_REGION="conus"
# ESFOTSDOMAIN="LON LAT 0. NX NY EW-RESOLUTION NS-RESOLUTION"
export STOFSDOMAIN="278.10 26.00 0. 133 167 0.029326 0.027027"
export STOFSNX="134"
export STOFSNY="168"


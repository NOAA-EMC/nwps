#!/bin/sh
set -xa

# NCEP Config file for global RTOFS and ESTOF init files

# RTOFS Domain for ocean currents
export RTOFSLON="183.00 221.50"
export RTOFSLAT="60.50 73.50"

# STOFS Domain for water level
export STOFS_REGION="conus"
# ESFOTSDOMAIN="LON LAT 0. NX NY EW-RESOLUTION NS-RESOLUTION"
export STOFSDOMAIN="183.00 60.50 0.0  1313 482 0.029326 0.027027"
export STOFSNX="1314"
export STOFSNY="483"


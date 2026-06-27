#!/bin/sh
set -xa

# NCEP Config file for global RTOFS and ESTOF init files

# RTOFS Domain for ocean currents
export RTOFSLON="270.40 274.60"
export RTOFSLAT="28.00 31.50"

# STOFS Domain for water level
export STOFS_REGION="conus"
# ESFOTSDOMAIN="LON LAT 0. NX NY EW-RESOLUTION NS-RESOLUTION"
export STOFSDOMAIN="270.40 28.00  0.0 144 130 0.029326 0.027027"
export STOFSNX="145"
export STOFSNY="131"


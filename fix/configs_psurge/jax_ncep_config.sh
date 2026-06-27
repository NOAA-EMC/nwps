#!/bin/sh
set -xa

# NCEP Config file for global RTOFS and ESTOF init files

# RTOFS Domain for ocean currents
export RTOFSLON="277.80 281.20"
export RTOFSLAT="28.20 32.50"

# STOFS Domain for water level
export STOFS_REGION="conus"
# ESFOTSDOMAIN="LON LAT 0. NX NY EW-RESOLUTION NS-RESOLUTION"
export STOFSDOMAIN="277.80 28.20 0. 116 160 0.029326 0.027027"
export STOFSNX="117"
export STOFSNY="161"


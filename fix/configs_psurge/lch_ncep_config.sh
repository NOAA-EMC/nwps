#!/bin/sh
set -xa

# NCEP Config file for global RTOFS and ESTOF init files

# RTOFS Domain for ocean currents
export RTOFSLON="264.54 270.20"
export RTOFSLAT="27.20 30.70"

# STOFS Domain for water level
export STOFS_REGION="conus"
# ESFOTSDOMAIN="LON LAT 0. NX NY EW-RESOLUTION NS-RESOLUTION"
export STOFSDOMAIN="264.54 27.20 0. 194 130 0.029326 0.027027"
export STOFSNX="195"
export STOFSNY="131"


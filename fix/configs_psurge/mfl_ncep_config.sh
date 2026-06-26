#!/bin/sh
set -xa

# NCEP Config file for global RTOFS and ESTOF init files

# RTOFS Domain for ocean currents
export RTOFSLON="275.96 282.09"
export RTOFSLAT="23.60 28.20"

# STOFS Domain for water level
export STOFS_REGION="conus"
# ESFOTSDOMAIN="LON LAT 0. NX NY EW-RESOLUTION NS-RESOLUTION"
export STOFSDOMAIN="275.96 23.60 0. 237 171 0.029326 0.027027"
export STOFSNX="238"
export STOFSNY="172"


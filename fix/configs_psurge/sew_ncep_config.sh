#!/bin/sh
set -xa

# NCEP Config file for global RTOFS and ESTOF init files

# RTOFS Domain for ocean currents
export RTOFSLON="232.50 238.59"
export RTOFSLAT="45.60 49.92"

# STOFS Domain for water level
export STOFS_REGION="conus"
# ESFOTSDOMAIN="LON LAT 0. NX NY EW-RESOLUTION NS-RESOLUTION"
export STOFSDOMAIN="232.50 45.60 0.0 208 160 0.029326 0.027027"
export STOFSNX="209"
export STOFSNY="161"


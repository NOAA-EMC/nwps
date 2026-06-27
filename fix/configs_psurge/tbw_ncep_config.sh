#!/bin/sh
set -xa

# NCEP Config file for global RTOFS and ESTOF init files

# RTOFS Domain for ocean currents
export RTOFSLON="274.70 279.50"
export RTOFSLAT="25.23 30.24"

# STOFS Domain for water level
export STOFS_REGION="conus"
# ESFOTSDOMAIN="LON LAT 0. NX NY EW-RESOLUTION NS-RESOLUTION"
export STOFSDOMAIN="274.70 25.23 0. 164 186 0.029326 0.027027"
export STOFSNX="165"
export STOFSNY="187"


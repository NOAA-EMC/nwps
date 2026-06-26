#!/bin/sh
set -xa

# NCEP Config file for global RTOFS and ESTOF init files

# RTOFS Domain for ocean currents
export RTOFSLON="258.82 265.4997"
export RTOFSLAT="25.2181 31.4307"

# STOFS Domain for water level
export STOFS_REGION="conus"
# ESFOTSDOMAIN="LON LAT 0. NX NY EW-RESOLUTION NS-RESOLUTION"
export STOFSDOMAIN="258.82 25.2181 0. 228  230 0.029326 0.027027"
export STOFSNX="229"
export STOFSNY="231"


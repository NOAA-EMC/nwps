#!/bin/sh
set -xa

# NCEP Config file for global RTOFS and ESTOF init files

# RTOFS Domain for ocean currents
export RTOFSLON="285.05 289.45"
export RTOFSLAT="39.25 41.90"

# STOFS Domain for water level
export STOFS_REGION="conus"
# ESFOTSDOMAIN="LON LAT 0. NX NY EW-RESOLUTION NS-RESOLUTION"
export STOFSDOMAIN="285.05 39.25 0. 151 99 0.029326 0.027027"
export STOFSNX="152"
export STOFSNY="100"


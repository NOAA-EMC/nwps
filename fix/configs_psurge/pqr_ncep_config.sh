#!/bin/sh
set -xa

# NCEP Config file for global RTOFS and ESTOF init files

# RTOFS Domain for ocean currents
export RTOFSLON="233.22 237.20"
export RTOFSLAT="43.00 47.65"

# STOFS Domain for water level
export STOFS_REGION="conus"
# ESFOTSDOMAIN="LON LAT 0. NX NY EW-RESOLUTION NS-RESOLUTION"
export STOFSDOMAIN="233.22 43.00 0.0 136 173 0.029326 0.027027"
export STOFSNX="137"
export STOFSNY="174"


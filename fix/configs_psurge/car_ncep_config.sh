#!/bin/sh
set -xa

# NCEP Config file for global RTOFS and ESTOF init files

# RTOFS Domain for ocean currents
export RTOFSLON="290.30 294.20"
export RTOFSLAT="42.80 45.80"

# STOFS Domain for water level
export STOFS_REGION="conus"
# ESFOTSDOMAIN="LON LAT 0. NX NY EW-RESOLUTION NS-RESOLUTION"
export STOFSDOMAIN="290.30 42.80 0. 133 112 0.029326 0.027027"
export STOFSNX="134"
export STOFSNY="113"


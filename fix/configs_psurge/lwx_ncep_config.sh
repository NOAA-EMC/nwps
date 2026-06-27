#!/bin/sh
set -xa

# NCEP Config file for global RTOFS and ESTOF init files

# RTOFS Domain for ocean currents
export RTOFSLON="281.70 285.10"
export RTOFSLAT="36.25 40.20"

# STOFS Domain for water level
export STOFS_REGION="conus"
# ESFOTSDOMAIN="LON LAT 0. NX NY EW-RESOLUTION NS-RESOLUTION"
export STOFSDOMAIN="281.70 36.25 0. 116 147 0.029326 0.027027"
export STOFSNX="117"
export STOFSNY="148"


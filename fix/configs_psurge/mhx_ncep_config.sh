#!/bin/sh
set -xa

# NCEP Config file for global RTOFS and ESTOF init files

# RTOFS Domain for ocean currents
export RTOFSLON="281.50 285.75"
export RTOFSLAT="33.35 37.10"

# STOFS Domain for water level
export STOFS_REGION="conus"
# ESFOTSDOMAIN="LON LAT 0. NX NY EW-RESOLUTION NS-RESOLUTION"
export STOFSDOMAIN="281.50 33.35 0. 145 139 0.029326 0.027027"
export STOFSNX="146"
export STOFSNY="140"


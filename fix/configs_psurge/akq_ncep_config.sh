#!/bin/sh
set -xa

# NCEP Config file for global RTOFS and ESTOF init files

# RTOFS Domain for ocean currents
export RTOFSLON="282.00 286.25"
export RTOFSLAT="35.30 40.10"

# STOFS Domain for water level
export STOFS_REGION="conus"
# ESFOTSDOMAIN="LON LAT 0. NX NY EW-RESOLUTION NS-RESOLUTION"
export STOFSDOMAIN="282.00 35.30 0. 145 178 0.029326 0.027027"
export STOFSNX="146"
export STOFSNY="179"


#!/bin/sh
set -xa

# NCEP Config file for global RTOFS and ESTOF init files

# RTOFS Domain for ocean currents
export RTOFSLON="201.50 217.50"
export RTOFSLAT="54.50 62.10"

# STOFS Domain for water level
export STOFS_REGION="conus"
# ESFOTSDOMAIN="LON LAT 0. NX NY EW-RESOLUTION NS-RESOLUTION"
export STOFSDOMAIN="201.50 54.50 0.0 546 282 0.029326 0.027027"
export STOFSNX="547"
export STOFSNY="283"


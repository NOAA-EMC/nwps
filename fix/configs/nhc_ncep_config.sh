#!/bin/sh
set -xa

# NCEP Config file for global RTOFS and ESTOF init files

# RTOFS Domain for ocean currents
export RTOFSSECTOR="west_atl"
# RTOFSDOMAIN="LON LAT 0. NX NY EW-RESOLUTION NS-RESOLUTION"
export RTOFSDOMAIN="261.50 2.50 0.0  3035 1111 0.029326 0.027027"
export RTOFSNX="3036"
export RTOFSNY="1112"


# STOFS Domain for water level
export STOFS_REGION="conus"
# ESFOTSDOMAIN="LON LAT 0. NX NY EW-RESOLUTION NS-RESOLUTION"
export STOFSDOMAIN="261.50 2.50 0.0  3035 1111 0.029326 0.027027"
export STOFSNX="3036"
export STOFSNY="1112"


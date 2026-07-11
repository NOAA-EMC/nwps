#!/bin/sh
set -xa

# NCEP Config file for global RTOFS and ESTOF init files

# RTOFS Domain for ocean currents
export RTOFSLON="217.10 229.10"
export RTOFSLAT="54.10 60.10"

# STOFS Domain for water level
export STOFS_REGION="conus"
# ESFOTSDOMAIN="LON LAT 0. NX NY EW-RESOLUTION NS-RESOLUTION"
export STOFSDOMAIN="217.10 54.10 0.0  410 223 0.029326 0.027027"
export STOFSNX="411"
export STOFSNY="224"


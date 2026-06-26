#!/bin/sh
set -xa

# NCEP Config file for global RTOFS and ESTOF init files

# RTOFS Domain for ocean currents
export RTOFSLON="259.23 265.09"
export RTOFSLAT="24.76 30.26"

# STOFS Domain for water level
export STOFS_REGION="conus"
# ESFOTSDOMAIN="LON LAT 0. NX NY EW-RESOLUTION NS-RESOLUTION"
export STOFSDOMAIN="259.23 24.76  0. 200 204 0.029326 0.027027"
export STOFSNX="201"
export STOFSNY="205"

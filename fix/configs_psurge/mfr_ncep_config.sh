#!/bin/sh
set -xa

# NCEP Config file for global RTOFS and ESTOF init files

# RTOFS Domain for ocean currents
export RTOFSLON="232.20 236.85"
export RTOFSLAT="40.50 44.95"

# STOFS Domain for water level
export STOFS_REGION="conus"
# ESFOTSDOMAIN="LON LAT 0. NX NY EW-RESOLUTION NS-RESOLUTION"
export STOFSDOMAIN="232.20 40.50 0.0  159 165 0.029326 0.027027"
export STOFSNX="160"
export STOFSNY="166"


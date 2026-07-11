#!/bin/sh
set -xa

# NCEP Config file for global RTOFS and ESTOF init files

# RTOFS Domain for ocean currents
export RTOFSLON="267.70  273.10"
export RTOFSLAT="27.00   31.10"

# STOFS Domain for water level
export STOFS_REGION="conus"
# ESFOTSDOMAIN="LON LAT 0. NX NY EW-RESOLUTION NS-RESOLUTION"
export STOFSDOMAIN="267.70 27.00 0.0 185  152 0.029326 0.027027"
export STOFSNX="186"
export STOFSNY="153"


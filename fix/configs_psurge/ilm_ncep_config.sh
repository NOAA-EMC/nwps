#!/bin/sh
set -xa

# NCEP Config file for global RTOFS and ESTOF init files

# RTOFS Domain for ocean currents
export RTOFSLON="279.10 284.00"
export RTOFSLAT="32.00 35.30"

# STOFS Domain for water level
export STOFS_REGION="conus"
# ESFOTSDOMAIN="LON LAT 0. NX NY EW-RESOLUTION NS-RESOLUTION"
export STOFSDOMAIN="279.10 32.00 0. 168 123 0.029326 0.027027"
export STOFSNX="169"
export STOFSNY="124"


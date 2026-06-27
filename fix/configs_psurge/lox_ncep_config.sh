#!/bin/sh
set -xa

# NCEP Config file for global RTOFS and ESTOF init files

# RTOFS Domain for ocean currents
export RTOFSLON="236.14 243.20"
export RTOFSLAT="32.10 36.60"

# STOFS Domain for water level
export STOFS_REGION="conus"
# ESFOTSDOMAIN="LON LAT 0. NX NY EW-RESOLUTION NS-RESOLUTION"
export STOFSDOMAIN="236.14 32.10 0.0  241 167 0.029326 0.027027"
export STOFSNX="242"
export STOFSNY="168"


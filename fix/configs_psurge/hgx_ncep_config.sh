#!/bin/sh
set -xa

# NCEP Config file for global RTOFS and ESTOF init files

# RTOFS Domain for ocean currents
export RTOFSLON="262.10 267.13"
export RTOFSLAT="26.50  32.50"

# STOFS Domain for water level
export STOFS_REGION="conus"
# ESFOTSDOMAIN="LON LAT 0. NX NY EW-RESOLUTION NS-RESOLUTION"
export STOFSDOMAIN="262.10 26.50 0. 172  223 0.029326 0.027027"
export STOFSNX="173"
export STOFSNY="224"


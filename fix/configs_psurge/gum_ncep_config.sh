#!/bin/sh
set -xa

# NCEP Config file for global RTOFS and ESTOF init files

# RTOFS Domain for ocean currents
export RTOFSLON="142.99 148.10"
export RTOFSLAT="11.60  17.10"

# STOFS Domain for water level
export STOFS_REGION="conus"
# ESFOTSDOMAIN="LON LAT 0. NX NY EW-RESOLUTION NS-RESOLUTION"
export STOFSDOMAIN="142.99 11.60 0.0 175 204 0.029326 0.027027"
export STOFSNX="176"
export STOFSNY="205"


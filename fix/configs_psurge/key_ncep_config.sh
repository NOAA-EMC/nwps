#!/bin/sh
set -xa

# NCEP Config file for global RTOFS and ESTOF init files

# RTOFS Domain for ocean currents
export RTOFSLON="276.00 281.50"
export RTOFSLAT="22.50 26.50"

# STOFS Domain for water level
export STOFS_REGION="conus"
# ESFOTSDOMAIN="LON LAT 0. NX NY EW-RESOLUTION NS-RESOLUTION"
export STOFSDOMAIN="276.00 22.50 0. 188 149 0.029326 0.027027"
export STOFSNX="189"
export STOFSNY="150"


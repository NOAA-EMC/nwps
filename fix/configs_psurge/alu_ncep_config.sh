#!/bin/sh
set -xa

# NCEP Config file for global RTOFS and ESTOF init files

# RTOFS Domain for ocean currents
export RTOFSLON="182.50 208.10"
export RTOFSLAT="50.50  60.70"

# STOFS Domain for water level
export STOFS_REGION="conus"
# ESFOTSDOMAIN="LON LAT 0. NX NY EW-RESOLUTION NS-RESOLUTION"
export STOFSDOMAIN="182.50 50.50 0.0  873 378 0.029326 0.027027"
export STOFSNX="874"
export STOFSNY="379"


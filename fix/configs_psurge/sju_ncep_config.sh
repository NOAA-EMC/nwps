#!/bin/sh
set -xa

# NCEP Config file for global RTOFS and ESTOF init files

# RTOFS Domain for ocean currents
export RTOFSLON="291.00 297.00"
export RTOFSLAT="16.00 20.50"

# STOFS Domain for water level
export STOFS_REGION="puertori"
# ESFOTSDOMAIN="LON LAT 0. NX NY EW-RESOLUTION NS-RESOLUTION"
export STOFSDOMAIN="291.00 16.00 0. 205 167 0.029326 0.027027"
export STOFSNX="206"
export STOFSNY="168"


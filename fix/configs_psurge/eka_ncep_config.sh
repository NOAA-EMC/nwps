#!/bin/sh
set -xa

# NCEP Config file for global RTOFS and ESTOF init files

# RTOFS Domain for ocean currents
export RTOFSLON="233.23 237.15"
export RTOFSLAT=" 37.9000   42.70"

# STOFS Domain for water level
export STOFS_REGION="conus"
# ESFOTSDOMAIN="LON LAT 0. NX NY EW-RESOLUTION NS-RESOLUTION"
export STOFSDOMAIN="233.23 37.90 0.0  134  178 0.029326 0.027027"
export STOFSNX="135"
export STOFSNY="179"


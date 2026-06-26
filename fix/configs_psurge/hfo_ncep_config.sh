#!/bin/sh
set -xa

# NCEP Config file for global RTOFS and ESTOF init files

# RTOFS Domain for ocean currents
export RTOFSLON="198.03 206.85"
export RTOFSLAT="17.30  23.85"

# STOFS Domain for water level
export STOFS_REGION="conus"
# ESFOTSDOMAIN="LON LAT 0. NX NY EW-RESOLUTION NS-RESOLUTION"
export STOFSDOMAIN="198.03 17.30 0.0 301 243 0.029326 0.027027"
export STOFSNX="302"
export STOFSNY="244"


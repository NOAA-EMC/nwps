#!/bin/sh
set -xa

# NCEP Config file for global RTOFS and ESTOF init files

# RTOFS Domain for ocean currents
export RTOFSSECTOR="west_atl"
# RTOFSDOMAIN="LON LAT 0. NX NY EW-RESOLUTION NS-RESOLUTION"
export RTOFSDOMAIN="270.80 28.50 0. 268 110 0.029326 0.027027"
export RTOFSNX="269"
export RTOFSNY="111"

# STOFS Domain for water level
export STOFS_BASIN="stofs_2d_glo"
export STOFS_REGION="conus.east"
# ESFOTSDOMAIN="LON LAT 0. NX NY EW-RESOLUTION NS-RESOLUTION"
export STOFSDOMAIN="270.80 28.50 0. 268 110 0.029326 0.027027"
export STOFSNX="269"
export STOFSNY="111"
export STOFSUSEICEMASK="FALSE"

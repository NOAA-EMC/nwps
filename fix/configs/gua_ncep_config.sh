# NCEP Config file for global RTOFS and ESTOF init files

# RTOFS Domain for ocean currents
export RTOFSSECTOR="guam"
# RTOFSDOMAIN="LON LAT 0. NX NY EW-RESOLUTION NS-RESOLUTION"
export RTOFSDOMAIN="142.99 11.60 0.0 198 204 0.029326 0.027027"
export RTOFSNX="199"
export RTOFSNY="205"

# ESTOFS Domain for water level
export ESTOFS_BASIN="stofs_2d_glo.mic"
export ESTOFS_REGION="guam"
# ESFOTSDOMAIN="LON LAT 0. NX NY EW-RESOLUTION NS-RESOLUTION"
export ESTOFSDOMAIN="142.99 11.60 0.0 198 329 0.029326 0.027027"
export ESTOFSNX="199"
export ESTOFSNY="330"
export ESTOFSUSEICEMASK="FALSE"

# GFS wind domain settings
# GFSWINDDOMAIN="LON LAT 0. NX NY EW-RESOLUTION NS-RESOLUTION"
export GFSWINDDOMAIN="142.99 11.60 0.0 198 204 0.029326 0.027027"
export GFSWINDNX="199"
export GFSWINDNY="205"
export GFSHOURS="180"
export GFSTIMESTEP="3"


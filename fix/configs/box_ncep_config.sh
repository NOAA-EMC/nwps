# NCEP Config file for global RTOFS and ESTOF init files

# RTOFS Domain for ocean currents
export RTOFSSECTOR="west_atl"
# RTOFSDOMAIN="LON LAT 0. NX NY EW-RESOLUTION NS-RESOLUTION"
export RTOFSDOMAIN="287.00 39.95 0. 159 141 0.029326 0.027027"
export RTOFSNX="160"
export RTOFSNY="142"

# ESTOFS Domain for water level
export ESTOFS_BASIN="stofs_2d_glo"
export ESTOFS_REGION="conus.east"
# ESFOTSDOMAIN="LON LAT 0. NX NY EW-RESOLUTION NS-RESOLUTION"
export ESTOFSDOMAIN="287.00 39.95 0. 159 141 0.029326 0.027027"
export ESTOFSNX="160"
export ESTOFSNY="142"
export ESTOFSUSEICEMASK="FALSE"

# GFS wind domain settings
# GFSWINDDOMAIN="LON LAT 0. NX NY EW-RESOLUTION NS-RESOLUTION"
export GFSWINDDOMAIN="287.00 39.95 0. 159 141 0.029326 0.027027"
export GFSWINDNX="160"
export GFSWINDNY="142"
export GFSHOURS="180"
export GFSTIMESTEP="3"


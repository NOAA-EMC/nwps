# NCEP Config file for global RTOFS and ESTOF init files

# RTOFS Domain for ocean currents
export RTOFSSECTOR="west_atl"
# RTOFSDOMAIN="LON LAT 0. NX NY EW-RESOLUTION NS-RESOLUTION"
export RTOFSDOMAIN="278.10 26.00 0. 133 167 0.029326 0.027027"
export RTOFSNX="134"
export RTOFSNY="168"

# ESTOFS Domain for water level
export ESTOFS_BASIN="estofs"
export ESTOFS_REGION="conus.east"
# ESFOTSDOMAIN="LON LAT 0. NX NY EW-RESOLUTION NS-RESOLUTION"
export ESTOFSDOMAIN="278.10 26.00 0. 133 167 0.029326 0.027027"
export ESTOFSNX="134"
export ESTOFSNY="168"
export ESTOFSUSEICEMASK="FALSE"

# GFS wind domain settings
# GFSWINDDOMAIN="LON LAT 0. NX NY EW-RESOLUTION NS-RESOLUTION"
export GFSWINDDOMAIN="278.10 26.00 0. 133 167 0.029326 0.027027"
export GFSWINDNX="134"
export GFSWINDNY="168"
export GFSHOURS="180"
export GFSTIMESTEP="3"


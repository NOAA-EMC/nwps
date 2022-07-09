# NCEP Config file for global RTOFS and ESTOF init files

# RTOFS Domain for ocean currents
export RTOFSSECTOR="west_conus"
# RTOFSDOMAIN="LON LAT 0. NX NY EW-RESOLUTION NS-RESOLUTION"
export RTOFSDOMAIN="233.22 43.00 0.0 136 173 0.029326 0.027027"
export RTOFSNX="137"
export RTOFSNY="174"

# ESTOFS Domain for water level
export ESTOFS_BASIN="estofs"
export ESTOFS_REGION="conus.west"
# ESFOTSDOMAIN="LON LAT 0. NX NY EW-RESOLUTION NS-RESOLUTION"
export ESTOFSDOMAIN="233.22 43.00 0.0 136 173 0.029326 0.027027"
export ESTOFSNX="137"
export ESTOFSNY="174"
export ESTOFSUSEICEMASK="FALSE"

# ESTOFS Domain for currents
export ESTOFS_BASIN="estofs"
export ESTOFS_REGION="conus.west"
# ESFOTSDOMAIN="LON LAT 0. NX NY EW-RESOLUTION NS-RESOLUTION"
export ESTOFSCURDOMAIN="233.72 43.50 0.0 999 999 0.002980 0.003650" 
export ESTOFSCURNX="999"
export ESTOFSCURNY="999"

# GFS wind domain settings
# GFSWINDDOMAIN="LON LAT 0. NX NY EW-RESOLUTION NS-RESOLUTION"
export GFSWINDDOMAIN="233.22 43.00 0.0 136 173 0.029326 0.027027"
export GFSWINDNX="137"
export GFSWINDNY="174"
export GFSHOURS="180"
export GFSTIMESTEP="3"


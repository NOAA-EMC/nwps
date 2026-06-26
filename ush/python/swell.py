#!/usr/bin/env python
# swell.py script
# Author: Andre van der Westhuysen, 04/28/15
# Ali Salimi-Tarazouj revised it, 09/25/2025
# Purpose: Plots SWAN output parameters from GRIB2.

import cartopy
import cartopy.crs as ccrs
import cartopy.feature as cfeature
import matplotlib
#matplotlib.use('Agg')
import sys
import os
import datetime
import numpy as np
import matplotlib.pyplot as plt
import warnings
warnings.filterwarnings("ignore", message="Shapefile shape has invalid polygon")

print('*** swell.py ***')
TSTART = int(sys.argv[1])
TEND = int(sys.argv[2])
print('TSTART = ' + str(TSTART))
print('TEND = ' + str(TEND))

#HOMEnwps ='/scratch4/NCEPDEV/marine/Ali.Salimi/Hera_Data/NWPS/featureV_1.5'
HOMEnwps = os.environ['HOMEnwps']
cartopy.config['pre_existing_data_dir'] = HOMEnwps + '/lib/cartopy'
print('Reading cartopy shapefiles from:')
print(cartopy.config['pre_existing_data_dir'])

# Parameters
monthstr = ['JAN','FEB','MAR','APR','MAY','JUN','JUL',
            'AUG','SEP','OCT','NOV','DEC']

# Read NOAA and NWS logos
noaa_logo = plt.imread('NOAA-Transparent-Logo.png')
nws_logo = plt.imread('NWS_Logo.png')

# Read control file
if os.path.isfile("swan.ctl"):
    print('Reading: swan.ctl')
    with open("swan.ctl") as f:
        content = f.readlines()
    dummy = content[0].split(" ")
    DSET = dummy[1].rstrip("\n")

    dummy = content[5].split(" ")
    nlon = int(dummy[1])
    x0 = float(dummy[3])
    dx = float(dummy[4])

    dummy = content[6].split(" ")
    nlat = int(dummy[1])
    y0 = float(dummy[3])
    dy = float(dummy[4])

    dummy = content[8].split(" ")
    TDEF = int(dummy[1])
    TINCR = int(dummy[4].rstrip("hr\n"))
    #----- Default to a plotting interval of 3h; adjust TDEF accordingly -----
    TINCR_OLD = TINCR
    TINCR = 3
    TDEF = (TDEF-1)/(TINCR/TINCR_OLD)+1
else:
    print('*** TERMINATING ERROR: Missing control file: swan.ctl')
    sys.exit()

# Load model results
if os.path.isfile(DSET):
    print('Reading: ' + DSET)
else:
    print('*** TERMINATING ERROR: Missing input file: ' + DSET)
    sys.exit()

# Extract GRIB2 files to text
for tstep in range(TSTART, (int(TEND)+1)):
    print('')
    print('Extracting Time step: ' + str(tstep))

    grib2dump = 'SWELL_extract_f' + str((tstep-1)*TINCR).zfill(3) + '.txt'
    if tstep == 1:
        command = '$WGRIB2 ' + DSET + ' -s | grep "SWELL:surface:anl" | $WGRIB2 -i ' + DSET + \
                  ' -rpn "sto_1:-9999:rcl_1:merge" -spread ' + grib2dump
    else:
        command = '$WGRIB2 ' + DSET + ' -s | grep "SWELL:surface:' + str((tstep-1)*TINCR) + \
                  ' hour" | $WGRIB2 -i ' + DSET + \
                  ' -rpn "sto_1:-9999:rcl_1:merge" -spread ' + grib2dump
    os.system(command)

# Set up lon/lat mesh
lons = np.linspace(x0, x0+float(nlon-1)*dx, num=nlon)
lats = np.linspace(y0, y0+float(nlat-1)*dy, num=nlat)
reflon, reflat = np.meshgrid(lons, lats)

# === Find global max once (for fixed colorbar) ===
fieldmax = 'SWELL_extract_fieldmax_TSTART' + str(TSTART) + '.txt'
command = '$WGRIB2 ' + DSET + ' -s | grep "SWELL" | $WGRIB2 -i ' + DSET + ' -max | cat > ' + fieldmax
os.system(command)
temp = np.loadtxt(fieldmax, delimiter='=', usecols=[1])
maxval = max(temp)

unitconvert = 1/0.3048  # meters -> feet
culim = int(unitconvert*maxval) + 1

SITEID = os.environ.get('SITEID')
CGNUMPLOT = os.environ.get('CGNUMPLOT')

plt.figure()
for tstep in range(TSTART, (int(TEND)+1)):
    print('')
    print('Processing Time step: ' + str(tstep))

    par = np.zeros((nlat, nlon))

    # Read dates
    grib2dump = 'SWELL_extract_f' + str((tstep-1)*TINCR).zfill(3) + '.txt'
    with open(grib2dump, "r") as fo:
        line = fo.readline()
    linesplit = line.split()
    if linesplit[3] == 'anl':
        forecastTime = 0
    else:
        forecastTime = int(linesplit[3])
    temp = linesplit[2][2:12]
    date = datetime.datetime(int(temp[0:4]), int(temp[4:6]),
                             int(temp[6:8]), int(temp[8:10]))
    date = date + datetime.timedelta(hours=forecastTime)
    print('Cycle: ' + str(forecastTime) + ', Hour: ' + str(date))

    # Swell
    data = np.loadtxt(grib2dump, delimiter=',', comments='l')
    for lat in range(0, nlat):
        for lon in range(0, nlon):
            par[lat, lon] = data[nlon*lat+lon, 2]
    par[np.where(par == -9999)] = np.nan
    par = unitconvert * par

    # Plot
    ax = plt.axes(projection=ccrs.Mercator())
    cs = ax.pcolormesh(reflon, reflat, par,
                       cmap=plt.cm.jet,
                       vmin=0, vmax=culim,
                       transform=ccrs.PlateCarree())
    plt.colorbar(cs, ax=ax).set_label("", size=8)
    ax.set_aspect('auto', adjustable=None)
    ax.set_extent([lons.min(), lons.max(), lats.min(), lats.max()])

    if (not ((SITEID == 'mfl') & (CGNUMPLOT == '3'))) & \
       (not ((SITEID == 'gyx') & (CGNUMPLOT == '2'))) & \
       (not ((SITEID == 'gyx') & (CGNUMPLOT == '3'))):
        coast = cfeature.GSHHSFeature(scale='high',
                                      edgecolor='black',
                                      facecolor=cfeature.COLORS['land'])
        ax.add_feature(coast)

    gl = ax.gridlines(crs=ccrs.PlateCarree(), draw_labels=True,
                      linewidth=0.5, color='gray', alpha=0.5, linestyle='--')
    gl.top_labels = False
    gl.right_labels = False
    gl.xlabel_style = {'size': 7}
    gl.ylabel_style = {'size': 7}

    # Columbia River Mouth piers
    if ((SITEID == 'pqr') & (CGNUMPLOT == '3')):
        ipierlons = [(235.96161-360),(235.96173-360),(235.95755-360)]
        ipierlats = [46.265216,46.267288,46.276829]
        npierlons = [(235.90511-360),(235.91421-360),(235.91421-360),
                     (235.93265-360),(235.93841-360),(235.94009-360)]
        npierlats = [46.261173,46.264595,46.264595,46.275276,46.279504,46.280726]
        spierlons = [(235.92139-360),(235.92446-360),(235.92598-360),(235.9313-360),
                     (235.95295-360),(235.95676-360),(235.98158-360),(235.99183-360)]
        spierlats = [46.23481,46.234087,46.233942,46.233758,
                     46.232979,46.233316,46.227833,46.224246]
        plt.plot(ipierlons, ipierlats, color="black", linewidth=2.5,
                 linestyle="-", transform=ccrs.PlateCarree())
        plt.plot(npierlons, npierlats, color="black", linewidth=2.5,
                 linestyle="-", transform=ccrs.PlateCarree())
        plt.plot(spierlons, spierlats, color="black", linewidth=2.5,
                 linestyle="-", transform=ccrs.PlateCarree())

    figtitle = 'NWPS Swell (ft): Low-pass filter of wave height at < 0.1 Hz\n Hour ' \
               + str(forecastTime) + ' (' + str(date.hour).zfill(2) + 'Z' \
               + str(date.day).zfill(2) + monthstr[int(date.month)-1] \
               + str(date.year) + ')'
    plt.title(figtitle, fontsize=10)

    plt.axes([0.00,.87,.08,.08])
    plt.axis('off')
    plt.imshow(noaa_logo, interpolation='gaussian')
    plt.axes([.86,.87,.08,.08])
    plt.axis('off')
    plt.imshow(nws_logo, interpolation='gaussian')

    filenm = 'swan_swell_hr' + str(forecastTime).zfill(3) + '.png'
    plt.savefig(filenm, dpi=150, bbox_inches='tight', pad_inches=0.1)
    plt.clf()

# Clean up text dump files
for tstep in range(TSTART, (int(TEND)+1)):
    os.system('rm SWELL_extract_f' + str((tstep-1)*TINCR).zfill(3) + '.txt')


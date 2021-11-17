# wlev.py script
# Author: Andre van der Westhuysen, 04/28/15
# Purpose: Plots SWAN output parameters from GRIB2.

import cartopy
import cartopy.crs as ccrs
import cartopy.feature as cfeature
import matplotlib
#matplotlib.use('Agg',warn=False)
import sys
import os
import datetime
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap

print('*** wlev.py ***')
TSTART = int(sys.argv[1])
TEND = int(sys.argv[2])
print('TSTART = '+str(TSTART))
print('TEND = '+str(TEND))

NWPSdir = os.environ['NWPSdir']
cartopy.config['pre_existing_data_dir'] = NWPSdir+'/lib/cartopy'
print('Reading cartopy shapefiles from:')
print(cartopy.config['pre_existing_data_dir'])

# Parameters
monthstr = ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC']
#clevs = [-3.0,-2.5,-2.0,-1.5,-1.0,-0.5,0.0,0.5,1.0,1.5,2.0,2.5,3.0]
#excpt = -99.0

# Read NOAA and NWS logos
noaa_logo = plt.imread('NOAA-Transparent-Logo.png')
nws_logo = plt.imread('NWS_Logo.png')

# Read control file
if os.path.isfile("swan.ctl"):
   print('Reading: swan.ctl')

   with open("swan.ctl") as f:
       content = f.readlines()
   dummy = content[0]
   dummy2 = dummy.split(" ")
   DSET = dummy2[1].rstrip("\n")

   dummy = content[5]
   dummy2 = dummy.split(" ")
   nlon = int(dummy2[1])
   x0 = float(dummy2[3])
   dx = float(dummy2[4])

   dummy = content[6]
   dummy2 = dummy.split(" ")
   nlat = int(dummy2[1])
   y0 = float(dummy2[3])
   dy = float(dummy2[4])

   dummy = content[8]
   dummy2 = dummy.split(" ")
   TDEF = int(dummy2[1])
   TINCR = int(dummy2[4].rstrip("hr\n"))
   #----- Default to a plotting interval of 3h; adjust TDEF accordingly -----
   TINCR_OLD = TINCR
   TINCR = 3
   TDEF = (TDEF-1)/(TINCR/TINCR_OLD)+1
   #-------------------------------------------------------------------------
else:
   print('*** TERMINATING ERROR: Missing control file: swan.ctl')
   sys.exit()

# Adjust scale bar for higher latitudes (larger tidal amplitudes)
#if y0 > 40.0:
#   clevs = [-10.0,-9.0,-8.0,-7.0,-6.0,-5.0,-4.0,-3.0,-2.0,-1.0,0.0,1.0,2.0,3.0,4.0,5.0,6.0,7.0,8.0,9.0,10.0]

# Load model results
if os.path.isfile(DSET):
   print('Reading: '+DSET)
else:
   print('*** TERMINATING ERROR: Missing input file: '+DSET)
   sys.exit()

# Extract GRIB2 files to text
for tstep in range(TSTART, (int(TEND)+1)):
   print('')
   print('Extracting Time step: '+str(tstep))

   # Deviation of sea level from mean
   grib2dump = 'DSLM_extract_f'+str((tstep-1)*TINCR).zfill(3)+'.txt'
   #fieldmax = 'DSLM_extract_fieldmax.txt'
   #fieldmin = 'DSLM_extract_fieldmin.txt'
   if tstep == 1:
      command = '$WGRIB2 '+DSET+' -s | grep "DSLM:surface:anl" | $WGRIB2 -i '+DSET+' -rpn "sto_1:-9999:rcl_1:merge" -spread '+grib2dump
      #command2 = '$WGRIB2 '+DSET+' -s | grep "DSLM:surface:anl" | $WGRIB2 -i '+DSET+' -max | cat > '+fieldmax
      #command3 = '$WGRIB2 '+DSET+' -s | grep "DSLM:surface:anl" | $WGRIB2 -i '+DSET+' -min | cat > '+fieldmin
   else:
      command = '$WGRIB2 '+DSET+' -s | grep "DSLM:surface:'+str((tstep-1)*TINCR)+' hour" | $WGRIB2 -i '+DSET+' -rpn "sto_1:-9999:rcl_1:merge" -spread '+grib2dump
      #command2 = '$WGRIB2 '+DSET+' -s | grep "DSLM:surface:'+str((tstep-1)*TINCR)+' hour" | $WGRIB2 -i '+DSET+' -max | cat >> '+fieldmax
      #command3 = '$WGRIB2 '+DSET+' -s | grep "DSLM:surface:'+str((tstep-1)*TINCR)+' hour" | $WGRIB2 -i '+DSET+' -min | cat >> '+fieldmin
   os.system(command)
   #os.system(command2)
   #os.system(command3)

# Set up lon/lat mesh
lons=np.linspace(x0,x0+float(nlon-1)*dx,num=nlon)
lats=np.linspace(y0,y0+float(nlat-1)*dy,num=nlat)
reflon,reflat=np.meshgrid(lons,lats)

if (lons.max()-lons.min()) > 15.0:
   dlon = 4.0
elif (lons.max()-lons.min()) > 1.0:
   dlon = 1.0
else:
   dlon = (lons.max()-lons.min())/5.
if (lats.max()-lats.min()) > 0.5:
   dlat = 0.5
else:
   dlat = (lats.max()-lats.min())/5.

SITEID = os.environ.get('SITEID')
CGNUMPLOT = os.environ.get('CGNUMPLOT')
WATERLEVELS = os.environ.get('WATERLEVELS')
EXCD = os.environ.get('EXCD')

fieldmax = 'DSLM_extract_fieldmax_TSTART'+str(TSTART)+'.txt'
command = '$WGRIB2 '+DSET+' -s | grep "DSLM" | $WGRIB2 -i '+DSET+' -max | cat > '+fieldmax
os.system(command)
fieldmin = 'DSLM_extract_fieldmin_TSTART'+str(TSTART)+'.txt'
command = '$WGRIB2 '+DSET+' -s | grep "DSLM" | $WGRIB2 -i '+DSET+' -min | cat > '+fieldmin
os.system(command)
temp=np.loadtxt(fieldmax, delimiter='=', usecols=[1])
maxval=max(temp)
temp=np.loadtxt(fieldmin, delimiter='=', usecols=[1])
minval=min(temp)

plt.figure()
# Read the extracted text file
for tstep in range(TSTART, (int(TEND)+1)):
   print('')
   print('Processing Time step: '+str(tstep))

   # Create a matrices of nlat x nlon initialized to 0
   par = np.zeros((nlat, nlon))
   par2 = np.zeros((nlat, nlon))

   # Read dates
   grib2dump = 'DSLM_extract_f'+str((tstep-1)*TINCR).zfill(3)+'.txt'
   fo = open(grib2dump, "r")
   line = fo.readline()
   linesplit = line.split()
   if linesplit[3] == 'anl':
      forecastTime = 0
   else:
      forecastTime = int(linesplit[3])
   temp = linesplit[2]
   temp = temp[2:12]
   date = datetime.datetime(int(temp[0:4]),int(temp[4:6]),int(temp[6:8]),int(temp[8:10]))
   # Add the forecast hour to the start of the cycle timestamp
   date = date + datetime.timedelta(hours=forecastTime)
   fo.close()
   print('Cycle: '+str(forecastTime)+', Hour: '+str(date))

   # Deviation of sea level from mean
   grib2dump = 'DSLM_extract_f'+str((tstep-1)*TINCR).zfill(3)+'.txt'
   data=np.loadtxt(grib2dump,delimiter=',',comments='l') 

   #lons=np.linspace(x0,x0+float(nlon-1)*dx,num=nlon)
   #lats=np.linspace(y0,y0+float(nlat-1)*dy,num=nlat)
   #reflon,reflat=np.meshgrid(lons,lats)

   # Set up parameter field
   for lat in range(0, nlat):
      for lon in range(0, nlon):
         par[lat,lon] = data[nlon*lat+lon,2:3]

   # Remove exception values
   par[np.where(par==-9999)] = np.nan

   # Convert units to feet
   unit = 'm'
   if unit == 'm':
      unitconvert = 1/0.3048
      par = unitconvert*par

   # Plot data
   ax = plt.axes(projection=ccrs.Mercator())
   # Adjust scale bar for higher latitudes (larger tidal amplitudes)
   if y0 > 40.0:
      #clevs = np.arange(int(round(unitconvert*minval))-1, int(round(unitconvert*maxval))+1, 1.0)
      clevs = np.arange(int(round(-unitconvert*maxval))-1, int(round(unitconvert*maxval))+1, 1.0)  #Omit largest neg vals to deal with ice fields
   else:
      #clevs = np.arange(int(round(unitconvert*minval))-1, int(round(unitconvert*maxval))+1, 0.5)
      clevs = np.arange(int(round(-unitconvert*maxval))-1, int(round(unitconvert*maxval))+1, 0.5)  #Omit largest neg vals to deal with ice fields
   plt.contourf(reflon, reflat, par, clevs, cmap=plt.cm.bwr, transform=ccrs.PlateCarree())
   plt.colorbar(ax=ax).set_label("", size=8)
   ax.set_aspect('auto', adjustable=None)
   ax.set_extent([lons.min(), lons.max(), lats.min(), lats.max()])

   # There is an issue with plotting m.fillcontinents with inland lakes, so omitting it in
   # the case of WFO-GYX, CG2 and CG3 (Lakes Sebago and Winni)
   if (not ((SITEID == 'mfl') & (CGNUMPLOT == '3'))) & \
      (not ((SITEID == 'gyx') & (CGNUMPLOT == '2'))) & \
      (not ((SITEID == 'gyx') & (CGNUMPLOT == '3'))):
      #land_50m = cfeature.NaturalEarthFeature('physical','land','50m',edgecolor='face',facecolor=cfeature.COLORS['land'])
      #ax.add_feature(land_50m)
      coast = cfeature.GSHHSFeature(scale='high',edgecolor='black',facecolor=cfeature.COLORS['land'])
      ax.add_feature(coast)
   #ax.coastlines(resolution='10m', color='black', linewidth=1)
   gl = ax.gridlines(crs=ccrs.PlateCarree(), draw_labels=True,
                  linewidth=0.5, color='gray', alpha=0.5, linestyle='--')
   gl.xlabels_top = False
   gl.ylabels_right = False
   gl.xlabel_style = {'size': 7}
   gl.ylabel_style = {'size': 7}

   # Draw CWA zones from ESRI shapefiles. NB: Make sure the lon convention is -180:180.
   #m.readshapefile('marine_zones','marine_zones')
   #m.drawcounties()

   # Draw Columbia River Mouth piers
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
      plt.plot(ipierlons, ipierlats, color="black", linewidth=2.5, linestyle="-", transform=ccrs.PlateCarree())
      plt.plot(npierlons, npierlats, color="black", linewidth=2.5, linestyle="-", transform=ccrs.PlateCarree())
      plt.plot(spierlons, spierlats, color="black", linewidth=2.5, linestyle="-", transform=ccrs.PlateCarree())

   if WATERLEVELS == 'ESTOFS':
      figtitle = 'NWPS '+WATERLEVELS+' Sea Surface Height rel. to MSL (ft) \n Hour '\
                 +str(forecastTime)+' ('+str(date.hour).zfill(2)+'Z'+str(date.day).zfill(2)\
                 +monthstr[int(date.month)-1]+str(date.year)+')'
   elif WATERLEVELS == 'PSURGE':
      figtitle = 'NWPS '+WATERLEVELS+' EXCD='+str(EXCD)+'% Sea Surface Height rel. to MSL (ft) \n Hour '\
                 +str(forecastTime)+' ('+str(date.hour).zfill(2)+'Z'+str(date.day).zfill(2)\
                 +monthstr[int(date.month)-1]+str(date.year)+')'
   else:
      figtitle = 'NWPS Sea Surface Height rel. to MSL (ft) \n Hour '\
                 +str(forecastTime)+' ('+str(date.hour).zfill(2)+'Z'+str(date.day).zfill(2)\
                 +monthstr[int(date.month)-1]+str(date.year)+')'
   plt.title(figtitle,fontsize=10)
   #plt.figtext(0.40, 0.06, '**EXPERIMENTAL**',fontsize=9)

   # Set up subaxes and plot the logos in them
   plt.axes([0.00,.87,.08,.08])
   plt.axis('off')
   plt.imshow(noaa_logo,interpolation='gaussian')
   plt.axes([.86,.87,.08,.08])
   plt.axis('off')
   plt.imshow(nws_logo,interpolation='gaussian')

   filenm = 'swan_wlev_hr'+str(forecastTime).zfill(3)+'.png'
   plt.savefig(filenm,dpi=150,bbox_inches='tight',pad_inches=0.1)
   plt.clf()

# Clean up text dump files
for tstep in range(TSTART, (int(TEND)+1)):
   os.system('rm DSLM_extract_f'+str((tstep-1)*TINCR).zfill(3)+'.txt')


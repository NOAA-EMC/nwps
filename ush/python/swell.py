# swell.py script
# Author: Andre van der Westhuysen, 04/28/15
# Purpose: Plots SWAN output parameters from GRIB2.

import sys
import os
import datetime
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap
from mpl_toolkits.basemap import Basemap

# Parameters
monthstr = ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC']
clevs = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]
excpt = -9.0

# Read NOAA and NWS logos
noaa_logo = plt.imread('NOAA-Transparent-Logo.png')
nws_logo = plt.imread('NWS_Logo.png')

# Read control file
print '*** swell.py ***'
if os.path.isfile("swan.ctl"):
   print 'Reading: swan.ctl'

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
else:
   print '*** TERMINATING ERROR: Missing control file: swan.ctl'
   sys.exit()

# Load model results
if os.path.isfile(DSET):
   print 'Reading: '+DSET
else:
   print '*** TERMINATING ERROR: Missing input file: '+DSET
   sys.exit()

# Extract GRIB2 files to text
for tstep in range(1, (TDEF+1)):
   print ''
   print 'Extracting Time step: '+str(tstep)

   # Significant height of swell waves
   grib2dump = 'SWELL_extract_f'+str((tstep-1)*TINCR).zfill(3)+'.txt'
   if tstep == 1:
      command = 'wgrib2 '+DSET+' -s | grep "SWELL:surface:anl" | wgrib2 -i '+DSET+' -spread '+grib2dump
   else:
      command = 'wgrib2 '+DSET+' -s | grep "SWELL:surface:'+str((tstep-1)*TINCR)+' hour" | wgrib2 -i '+DSET+' -spread '+grib2dump
   os.system(command)

# Set up lon/lat mesh
lons=np.linspace(x0,x0+float(nlon-1)*dx,num=nlon)
lats=np.linspace(y0,y0+float(nlat-1)*dy,num=nlat)
reflon,reflat=np.meshgrid(lons,lats)

if (lons.max()-lons.min()) > 1.0:
   dlon = 1.0
else:
   dlon = (lons.max()-lons.min())/5.
if (lats.max()-lats.min()) > 0.5:
   dlat = 0.5
else:
   dlat = (lats.max()-lats.min())/5.

SITEID = os.environ.get('SITEID')
CGNUMPLOT = os.environ.get('CGNUMPLOT')

plt.figure()
# Read the extracted text file
for tstep in range(1, (TDEF+1)):
   print ''
   print 'Processing Time step: '+str(tstep)

   # Create a matrices of nlat x nlon initialized to 0
   par = np.zeros((nlat, nlon))
   par2 = np.zeros((nlat, nlon))

   # Read dates
   grib2dump = 'SWELL_extract_f'+str((tstep-1)*TINCR).zfill(3)+'.txt'
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
   print 'Cycle: '+str(forecastTime)+', Hour: '+str(date)

   # Significant height of combined wind waves and swell
   grib2dump = 'SWELL_extract_f'+str((tstep-1)*TINCR).zfill(3)+'.txt'
   data=np.loadtxt(grib2dump,delimiter=',',comments='l') 

   #lons=np.linspace(x0,x0+float(nlon-1)*dx,num=nlon)
   #lats=np.linspace(y0,y0+float(nlat-1)*dy,num=nlat)
   #reflon,reflat=np.meshgrid(lons,lats)

   # Set up parameter field
   for lat in range(0, nlat):
      for lon in range(0, nlon):
         par[lat,lon] = data[nlon*lat+lon,2:3]

   # Remove exception values
   par[np.where(par==excpt)] = 0.

   # Convert units to feet
   unit = 'm'
   if unit == 'm':
      unitconvert = 1/0.3048
      par = unitconvert*par

   # Plot data
   if tstep == 1:
      m=Basemap(projection='merc',llcrnrlon=lons.min(),urcrnrlon=lons.max(),llcrnrlat=lats.min(),urcrnrlat=lats.max(),resolution='h')
      x,y=m(reflon,reflat)
   m.contourf(x,y,par,clevs,cmap=plt.cm.jet)
   #cmap = plt.get_cmap('BlueRed1')
   #m.contourf(x,y,par,clevs,cmap=cmap)
   m.colorbar(location='right',size='2.5%',pad='7%')

   # There is an issue with plotting m.fillcontinents with inland lakes, so omitting it in
   # the case of WFO-GYX, CG2 and CG3 (Lakes Sebago and Winni)
   if (not ((SITEID == 'gyx') & (CGNUMPLOT == '2'))) & \
      (not ((SITEID == 'gyx') & (CGNUMPLOT == '3'))):
      m.fillcontinents()
      m.drawcoastlines()
   m.drawmeridians(np.arange(lons.min(),lons.max(),dlon),labels=[0,0,0,dlon],dashes=[1,3],color='0.50',fontsize=7)   
   m.drawparallels(np.arange(lats.min(),lats.max(),dlat),labels=[dlat,0,0,0],dashes=[1,3],color='0.50',fontsize=7)

   # Draw CWA zones from ESRI shapefiles. NB: Make sure the lon convention is -180:180.
   #m.readshapefile('marine_zones','marine_zones')
   #m.drawcounties()

   figtitle = 'NWPS Swell (ft) \n Hour '\
              +str(forecastTime)+' ('+str(date.hour).zfill(2)+'Z'+str(date.day).zfill(2)\
              +monthstr[int(date.month)-1]+str(date.year)+')'
   plt.title(figtitle,fontsize=14)
   #plt.figtext(0.40, 0.06, '**EXPERIMENTAL**',fontsize=9)

   # Set up subaxes and plot the logos in them
   plt.axes([0.02,.87,.08,.08])
   plt.axis('off')
   plt.imshow(noaa_logo,interpolation='gaussian')
   plt.axes([.92,.87,.08,.08])
   plt.axis('off')
   plt.imshow(nws_logo,interpolation='gaussian')

   filenm = 'swan_swell_hr'+str(forecastTime).zfill(3)+'.png'
   plt.savefig(filenm,dpi=150,bbox_inches='tight',pad_inches=0.1)
   plt.clf()

# Clean up text dump files
os.system('rm *f???.txt')



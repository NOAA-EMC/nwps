##!/usr/bin/python
# *******************************
# ******** Start of File ********
# *******************************
# -----------------------------------------------------------
# Python Script
# Operating System(s): RHEL 6, 7
# Python version used: 2.6.x and 2.7.x
# Original Author(s): Alex Gibbs (Grads Version), 
#                     Andre van der Westhuysen (Python Current Plot)
#                     Douglas Gaer (Grads to Python Adaptation)  
# File Creation Date: 03/15/2016  
# Date Last Modified: 04/07/2016
#
# Version control: 1.04
#
# Support Team:
#
# Contributors: 
# -----------------------------------------------------------
# ------------- Program Description and Details -------------
# -----------------------------------------------------------
#
# Ship route ocean current image plotting script using matplotlib 
# and basemap to replace Grads version written by Alex Gibbs. 
#
# -----------------------------------------------------------
import sys
import os

MODEL="NWPS"
# Output our program setup and ENV
PYTHON = os.environ.get('PYTHON')
PYTHONPATH = os.environ.get('PYTHONPATH')
WGRIB2 = os.environ.get('WGRIB2')
print(MODEL + ' Python ploting program: ' + sys.argv[0])
if not PYTHON:
   print('WARNING - PYTHON variable not set in callers ENV')
else:
   print(MODEL + ' Python interpreter: ' + PYTHON)
if not PYTHONPATH:
   print('WARNING - PYTHONPATH variable not set in callers ENV')
else:
   print(MODEL + ' Python path: ' + PYTHONPATH)
if not WGRIB2:
   print('WARNING - WGRIB2 variable not set in callers ENV')
   WGRIB2 = "wgrib2"
else:
   print(MODEL + ' wgrib2 program: ' + WGRIB2)

import datetime
import numpy as np
#AW import ConfigParser

# 02/26/2016: Generate images without having a window appear
# http://matplotlib.org/faq/howto_faq.html
import matplotlib
matplotlib.use('Agg')

import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap
#AW from mpl_toolkits.basemap import Basemap
import cartopy.crs as ccrs
import cartopy.feature as cfeature

# Parameters
monthstr = ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC']
clevs = [0,0.25,0.50,0.75,1.00,1.25,1.50,1.75,2.00,2.25,2.50,2.75,3.00,3.25,3.50,3.75,4.00,4.25]
excpt = 0.0

# Read NOAA and NWS logos
noaa_logo = plt.imread('NOAA-Transparent-Logo.png')
nws_logo = plt.imread('NWS_Logo.png')


#Config = ConfigParser.ConfigParser()
fname = sys.argv[1] 
if os.path.isfile(fname):
   print("Reading pyplot CFG file: " + fname)
#   Config.read(fname)
else:
   print('ERROR - Cannot open pyplot CFG file ' + fname)
   sys.exit()

#if not Config.has_section("GRIB2"):
#   print('ERROR - Pyplot CFG file missing GRIB2 section')
#   sys.exit()

#if not Config.has_section("SHIPROUTE"):
#   print('ERROR - Pyplot CFG file missing SHIPROUTE section')
#   sys.exit()

#DSET = Config.get('GRIB2', 'DSET')
#nlon = Config.getint('GRIB2', 'NLONS')
#x0 = Config.getfloat('GRIB2', 'LL_LON')
#dx = Config.getfloat('GRIB2', 'DX')
#nlat = Config.getint('GRIB2', 'NLATS')
#y0 = Config.getfloat('GRIB2', 'LL_LAT')
#dy = Config.getfloat('GRIB2', 'DY')
#TDEF = Config.getint('GRIB2', 'NUMTIMESTEPS')
#TINCR = Config.getint('GRIB2', 'TIMESTEP')

DSET = os.popen("grep [[]GRIB2[]] -A 11 pyplot_shiproutes.cfg | grep DSET | sed 's/DSET =  //g'").read().split()
DSET = DSET[0]
nlon = int(os.popen("grep [[]GRIB2[]] -A 11 pyplot_shiproutes.cfg | grep NLONS | sed 's/NLONS = //g'").read())
x0 = float(os.popen("grep [[]GRIB2[]] -A 11 pyplot_shiproutes.cfg | grep LL_LON | sed 's/LL_LON = //g'").read())
dx = float(os.popen("grep [[]GRIB2[]] -A 11 pyplot_shiproutes.cfg | grep DX | sed 's/DX = //g'").read())
nlat = int(os.popen("grep [[]GRIB2[]] -A 11 pyplot_shiproutes.cfg | grep NLATS | sed 's/NLATS = //g'").read())
y0 = float(os.popen("grep [[]GRIB2[]] -A 11 pyplot_shiproutes.cfg | grep LL_LAT | sed 's/LL_LAT = //g'").read())
dy = float(os.popen("grep [[]GRIB2[]] -A 11 pyplot_shiproutes.cfg | grep DY | sed 's/DY = //g'").read())
TDEF = int(os.popen("grep [[]GRIB2[]] -A 11 pyplot_shiproutes.cfg | grep NUMTIMESTEPS | sed 's/NUMTIMESTEPS = //g'").read())
TINCR = int(os.popen("grep [[]GRIB2[]] -A 11 pyplot_shiproutes.cfg | grep 'TIMESTEP ' | sed 's/TIMESTEP = //g'").read())

print('DSET = ' + DSET)
print('nlon = %d' % nlon)
print('x0 = %0.5f' % x0)
print('dx = %0.5f' % dx)
print('nlat = %d' % nlat)
print('y0 = %0.5f' % y0)
print('dy = %0.5f' % dy)
print('TDEF = %d' % TDEF)
print('TINCR = %d' % TINCR)

# Load model results
if os.path.isfile(DSET):
   print('Reading GRIB2 input file ' + DSET)
else:
   print('ERROR - Cannot read file ' + DSET)
   sys.exit()

#if not Config.has_section("GRIB2CLIP"):
#   print('INFO - Pyplot CFG does not have GRIB2CLIP section')
#   print('INFO - No GRIB2 clip will be made for this DSET')
#   PLOTCLIP = False
#else:
#   print('INFO - Pyplot CFG has GRIB2CLIP section')
#   CLIPDSET = Config.get('GRIB2CLIP', 'DSET')
#   PLOTCLIP =  Config.getboolean('GRIB2CLIP', 'PLOT')
#   LL_LON = Config.getfloat('GRIB2CLIP', 'LL_LON')
#   UL_LON = Config.getfloat('GRIB2CLIP', 'UL_LON')
#   LL_LAT = Config.getfloat('GRIB2CLIP', 'LL_LAT')
#   UL_LAT = Config.getfloat('GRIB2CLIP', 'UL_LAT')

CLIPDSET = os.popen("grep [[]GRIB2CLIP[]] -A 6 pyplot_shiproutes.cfg | grep DSET | sed 's/DSET = //g'").read().split()
CLIPDSET = CLIPDSET[0]
PLOTCLIP = os.popen("grep [[]GRIB2CLIP[]] -A 6 pyplot_shiproutes.cfg | grep PLOT | sed 's/PLOT = //g'").read()
LL_LON = float(os.popen("grep [[]GRIB2CLIP[]] -A 6 pyplot_shiproutes.cfg | grep LL_LON | sed 's/LL_LON = //g'").read())
UL_LON = float(os.popen("grep [[]GRIB2CLIP[]] -A 6 pyplot_shiproutes.cfg | grep UL_LON | sed 's/UL_LON = //g'").read())
LL_LAT = float(os.popen("grep [[]GRIB2CLIP[]] -A 6 pyplot_shiproutes.cfg | grep LL_LAT | sed 's/LL_LAT = //g'").read())
UL_LAT = float(os.popen("grep [[]GRIB2CLIP[]] -A 6 pyplot_shiproutes.cfg | grep UL_LAT | sed 's/UL_LAT = //g'").read())

clip_lon_points = np.arange(LL_LON, UL_LON, dx)
clip_lat_points = np.arange(LL_LAT, UL_LAT, dy)
clip_nx = len(clip_lon_points)
clip_ny = len(clip_lat_points)
command = WGRIB2+' ' +DSET+' -new_grid latlon '+str(round(LL_LON,5))+':'+str(clip_nx)+':'+str(round(dx,5))+' '+str(round(LL_LAT,5))+':'+str(clip_ny)+':'+str(round(dy,5))+' '+CLIPDSET
print(command)
os.system(command)
if os.path.isfile(CLIPDSET):
   print('Reading GRIB2 input clip file ' + CLIPDSET)
else:
   print('ERROR - Cannot read clip file ' + CLIPDSET)
   sys.exit()
DSET = CLIPDSET
nlon = clip_nx
x0 = LL_LON
nlat = clip_ny 
y0 = LL_LAT
print('Clip DSET = ' + DSET)
print('Clip nlon = %d' % nlon)
print('Clip x0 = %0.5f' % x0)
print('Clip dx = %0.5f' % dx)
print('Clip nlat = %d' % nlat)
print('Clip y0 = %0.5f' % y0)
print('Clip dy = %0.5f' % dy)
print('Clip TDEF = %d' % TDEF)
print('Clip TINCR = %d' % TINCR)

# Process our ship route config
#SHIPROUTENAME = Config.get('SHIPROUTE', 'NAME')
#IMGFILEPREFIX = Config.get('SHIPROUTE', 'IMGFILEPREFIX')
#SRDSET = Config.get('SHIPROUTE', 'DSET')
#STLAT = Config.getfloat('SHIPROUTE', 'STLAT')
#STLON = Config.getfloat('SHIPROUTE', 'STLON')
#ENDLAT = Config.getfloat('SHIPROUTE', 'ENDLAT')
#ENDLON = Config.getfloat('SHIPROUTE', 'ENDLON')
#RES = Config.getfloat('SHIPROUTE', 'RES')
#NUMSRPOINTS = Config.getint('SHIPROUTE', 'NUMPOINTS')
#PLOTCURRENTS = Config.getboolean('SHIPROUTE', 'PLOTCURRENTS')
#DISTANCE_NM = Config.getint('SHIPROUTE', 'DISTANCE_NM')
#MODEL = Config.get('SHIPROUTE', 'MODEL')
#DPI_IMAGE = Config.getint('SHIPROUTE', 'IMGSIZE')

SHIPROUTENAME = os.popen("grep [[]SHIPROUTE[]] -A 18 pyplot_shiproutes.cfg | grep NAME | sed 's/NAME = //g'").read().split()
SHIPROUTENAME = ' '.join(SHIPROUTENAME[0:])
IMGFILEPREFIX = os.popen("grep [[]SHIPROUTE[]] -A 18 pyplot_shiproutes.cfg | grep IMGFILEPREFIX | sed 's/IMGFILEPREFIX = //g'").read().split()
IMGFILEPREFIX = IMGFILEPREFIX[0]
SRDSET = os.popen("grep [[]SHIPROUTE[]] -A 18 pyplot_shiproutes.cfg | grep DSET | sed 's/DSET = //g'").read().split()
SRDSET = SRDSET[0]
STLAT = float(os.popen("grep [[]SHIPROUTE[]] -A 18 pyplot_shiproutes.cfg | grep STLAT | sed 's/STLAT = //g'").read())
STLON = float(os.popen("grep [[]SHIPROUTE[]] -A 18 pyplot_shiproutes.cfg | grep STLON | sed 's/STLON = //g'").read())
ENDLAT = float(os.popen("grep [[]SHIPROUTE[]] -A 18 pyplot_shiproutes.cfg | grep ENDLAT | sed 's/ENDLAT = //g'").read())
ENDLON = float(os.popen("grep [[]SHIPROUTE[]] -A 18 pyplot_shiproutes.cfg | grep ENDLON | sed 's/ENDLON = //g'").read())
RES = float(os.popen("grep [[]SHIPROUTE[]] -A 18 pyplot_shiproutes.cfg | grep RES | sed 's/RES = //g'").read())
NUMSRPOINTS = int(os.popen("grep [[]SHIPROUTE[]] -A 18 pyplot_shiproutes.cfg | grep NUMPOINTS | sed 's/NUMPOINTS = //g'").read())
PLOTCURRENTS = os.popen("grep [[]SHIPROUTE[]] -A 18 pyplot_shiproutes.cfg | grep PLOTCURRENTS | sed 's/PLOTCURRENTS = //g'").read()
DISTANCE_NM = int(os.popen("grep [[]SHIPROUTE[]] -A 18 pyplot_shiproutes.cfg | grep DISTANCE_NM | sed 's/DISTANCE_NM = //g'").read())
MODEL = str(os.popen("grep [[]SHIPROUTE[]] -A 18 pyplot_shiproutes.cfg | grep MODEL | sed 's/MODEL = //g'").read())
DPI_IMAGE = int(os.popen("grep [[]SHIPROUTE[]] -A 18 pyplot_shiproutes.cfg | grep IMGSIZE | sed 's/IMGSIZE = //g'").read())
DPI = DPI_IMAGE/2

# Extract GRIB2 files to text
for tstep in range(1, (TDEF+1), 3):
   print('')
   print('Extracting Time step: '+str(tstep))

   # Current speed
   grib2dump = 'SPC_extract_f'+str((tstep-1)*TINCR).zfill(3)+'.txt'
   if tstep == 1:
      command = WGRIB2 +' '+DSET+' -s | grep "SPC:surface:anl" | '+WGRIB2+' -i '+DSET+' -spread '+grib2dump
   else:
      command = WGRIB2 +' '+DSET+' -s | grep "SPC:surface:'+str((tstep-1)*TINCR)+' hour" | '+WGRIB2+' -i '+DSET+' -spread '+grib2dump
   os.system(command)

   # Primary wave direction
   grib2dump = 'DIRC_extract_f'+str((tstep-1)*TINCR).zfill(3)+'.txt'
   if tstep == 1:
      command = WGRIB2 +' '+DSET+' -s | grep "DIRC:surface:anl" | '+WGRIB2+' -i '+DSET+' -spread '+grib2dump
   else:
      command = WGRIB2 +' '+DSET+' -s | grep "DIRC:surface:'+str((tstep-1)*TINCR)+' hour" | '+WGRIB2+' -i '+DSET+' -spread '+grib2dump
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
for tstep in range(1, (TDEF+1), 3):
   print('')
   print('Processing Time step: '+str(tstep))

   # Create a matrices of nlat x nlon initialized to 0
   par = np.zeros((nlat, nlon))
   par2 = np.zeros((nlat, nlon))

   # Read dates
   grib2dump = 'SPC_extract_f'+str((tstep-1)*TINCR).zfill(3)+'.txt'
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

   # Current speed
   grib2dump = 'SPC_extract_f'+str((tstep-1)*TINCR).zfill(3)+'.txt'
   data=np.loadtxt(grib2dump,delimiter=',',comments='l') 
   print(data.shape)
   print(nlon, nlat)

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
   unit = 'm s-1'
   if unit == 'm s-1':
      unitconvert = 1/0.514444
      par = unitconvert*par

   # Mean current direction
   grib2dump = 'DIRC_extract_f'+str((tstep-1)*TINCR).zfill(3)+'.txt'
   data=np.loadtxt(grib2dump,delimiter=',',comments='l') 

   # Set up parameter field
   for lat in range(0, nlat):
      for lon in range(0, nlon):
         par2[lat,lon] = data[nlon*lat+lon,2:3]

   u=np.cos(3.1416/180*(270-par2))
   v=np.sin(3.1416/180*(270-par2))

   # Plot data
   #if tstep == 1:
      #m=Basemap(projection='merc',llcrnrlon=lons.min(),urcrnrlon=lons.max(),llcrnrlat=lats.min(),urcrnrlat=lats.max(),resolution='h')
      #x,y=m(reflon,reflat)
   ax = plt.axes(projection=ccrs.Mercator())
   u = par*u
   v = par*v
   maxval=2
   norm = matplotlib.colors.Normalize(vmin=0.,vmax=(int(unitconvert*maxval)+1))
   culim = int(unitconvert*maxval)+1
   clevs = np.arange(0, culim+0.5, 0.5)
   #m.streamplot(x,y,u,v,color=par,density=4,linewidth=0.75,arrowsize=1.5)
   #m.colorbar(location='bottom',size='2.5%',pad='7%')
   #AW plt.contourf(reflon,reflat,par,clevs,cmap=plt.cm.jet,norm=norm)
   #ax.streamplot(reflon,reflat,u,v,color='k',density=4,linewidth=0.75,arrowsize=1.5)
   #AW plt.colorbar() #location='bottom',size='2.5%',pad='7%')

   lw = 1.0*par / max(par.max(),0.0001)
   plt.contourf(reflon,reflat,par,clevs,cmap=plt.cm.jet,norm=norm,transform=ccrs.PlateCarree())
   ax.streamplot(reflon,reflat,u,v,color='k',density=2,linewidth=1.5*lw,arrowsize=0.75,norm=norm,transform=ccrs.PlateCarree())
   plt.colorbar(ax=ax)
   
   ax.set_aspect('auto', adjustable=None)
   ax.set_extent([lons.min(), lons.max(), lats.min(), lats.max()])

   # Draw our ship route path
   xpt1 = STLON
   ypt1 = STLAT
   xpt2 = ENDLON
   ypt2 = ENDLAT
   plt.plot([xpt1,xpt2], [ypt1,ypt2], 'k-', lw=2, markersize=10, marker='D',transform=ccrs.PlateCarree())

   # There is an issue with plotting m.fillcontinents with inland lakes, so omitting it in
   # the case of WFO-GYX, CG2 and CG3 (Lakes Sebago and Winni)
   if (not ((SITEID == 'gyx') & (CGNUMPLOT == '2'))) & \
      (not ((SITEID == 'gyx') & (CGNUMPLOT == '3'))):
   #   plt.fillcontinents()
   #   plt.drawcoastlines()
      coast = cfeature.GSHHSFeature(scale='intermediate',edgecolor='black', facecolor=cfeature.COLORS['land'])
      ax.add_feature(coast)
   #plt.drawmeridians(np.arange(lons.min(),lons.max(),dlon),labels=[0,0,0,dlon],dashes=[1,3],color='0.50',fontsize=10)   
   #plt.drawparallels(np.arange(lats.min(),lats.max(),dlat),labels=[dlat,0,0,0],dashes=[1,3],color='0.50',fontsize=10)
   gl = ax.gridlines(crs=ccrs.PlateCarree(), draw_labels=True,
                  linewidth=0.5, color='gray', alpha=0.5, linestyle='--')
   gl.xlabels_top = False
   gl.ylabels_right = False
   gl.xlabel_style = {'size': 9}
   gl.ylabel_style = {'size': 9}

   # Draw CWA zones from ESRI shapefiles. NB: Make sure the lon convention is -180:180.
   #m.readshapefile('marine_zones','marine_zones')
   #m.drawcounties()

   filenm = 'swan_shiproute_curclip_'+str(tstep)+'.png'
   plt.savefig(filenm,dpi=DPI,bbox_inches='tight',pad_inches=0.1,transparent=True)
   plt.clf()

# Clean up text dump files
os.system('rm -fv DIRC_extract_f*.txt')
os.system('rm -fv SPC_extract_f*.txt')
# -----------------------------------------------------------
# *******************************
# ********* End of File *********
# *******************************


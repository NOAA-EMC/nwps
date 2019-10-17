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
# Date Last Modified: 04/17/2016
#
# Version control: 1.06
#
# Support Team:
#
# Contributors: 
# -----------------------------------------------------------
# ------------- Program Description and Details -------------
# -----------------------------------------------------------
#
# Ship route plotting script using matplotlib and basemap to 
# replace Grads version written by Alex Gibbs. 
#
# NOTE: NWS cannot publish any graphics to the Web that say
# NOTE: ship route plot. The name of this plot has been changed
# NOTE: to Gulf Stream plot.
# -----------------------------------------------------------
import sys
import os
import time

# Output our program setup and ENV
PYTHON = os.environ.get('PYTHON')
PYTHONPATH = os.environ.get('PYTHONPATH')
WGRIB2 = os.environ.get('WGRIB2')
print(' Python ploting program: ' + sys.argv[0])
if not PYTHON:
   print('WARNING - PYTHON variable not set in callers ENV')
else:
   print(' Python interpreter: ' + PYTHON)
if not PYTHONPATH:
   print('WARNING - PYTHONPATH variable not set in callers ENV')
else:
   print(' Python path: ' + PYTHONPATH)
if not WGRIB2:
   print('WARNING - WGRIB2 variable not set in callers ENV')
   WGRIB2 = "wgrib2"
else:
   print(' wgrib2 program: ' + WGRIB2)

import datetime as dt
import numpy as np
#AW import ConfigParser

# Generate images without having a window appear
# http://matplotlib.org/faq/howto_faq.html
import matplotlib
matplotlib.use('Agg')

from pylab import *
import matplotlib.pyplot as plt
from matplotlib.font_manager import fontManager, FontProperties 
from matplotlib.colors import LinearSegmentedColormap
#AW from mpl_toolkits.basemap import Basemap

# Parameters
monthstr = ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC']
clevs = [0,0.25,0.50,0.75,1.00,1.25,1.50,1.75,2.00,2.25,2.50,2.75,3.00,3.25,3.50,3.75,4.00,4.25]
excpt = 0.0

# Read NOAA and NWS logos
noaa_logo = plt.imread('NOAA-Transparent-Logo.png')
nws_logo = plt.imread('NWS_Logo.png')

if len(sys.argv) < 2:
   print('ERROR - You must supply the name of our input control config file')
   print('Usage: ' +  sys.argv[0] + ' pyplot.cfg')
   sys.exit()

#AW Config = ConfigParser.ConfigParser()
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
#DPI = Config.getint('SHIPROUTE', 'IMGSIZE')
#HOUR = Config.get('SHIPROUTE', 'HOUR')
#DAY = Config.get('SHIPROUTE', 'DAY')
#MONTH = Config.get('SHIPROUTE', 'MONTH')
#YEAR = Config.get('SHIPROUTE', 'YEAR')

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
DPI = int(os.popen("grep [[]SHIPROUTE[]] -A 18 pyplot_shiproutes.cfg | grep IMGSIZE | sed 's/IMGSIZE = //g'").read())
HOUR = str(os.popen("grep [[]SHIPROUTE[]] -A 18 pyplot_shiproutes.cfg | grep HOUR | sed 's/HOUR = //g'").read())
DAY = str(os.popen("grep [[]SHIPROUTE[]] -A 18 pyplot_shiproutes.cfg | grep DAY | sed 's/DAY = //g'").read())
MONTH = str(os.popen("grep [[]SHIPROUTE[]] -A 18 pyplot_shiproutes.cfg | grep MONTH | sed 's/MONTH = //g'").read())
YEAR = str(os.popen("grep [[]SHIPROUTE[]] -A 18 pyplot_shiproutes.cfg | grep YEAR | sed 's/YEAR = //g'").read())

if os.path.isfile(SRDSET):
   print('Reading ship route data file ' + SRDSET) 
else:
   print('ERROR - Cannot ship route data file ' + SRDSET)
   sys.exit()

# Fortran BIN of horizontal points for HTSGW DIRPW WIND PERPW
sr_fp =  open(SRDSET, "rb")

str_time_fmt = DAY +' '+ MONTH +' '+ YEAR +' '+ HOUR +' 00'
struct_time = time.strptime(str_time_fmt, "%d %b %Y %H %M")
starttime  = time.mktime(struct_time)

print("Start time = " + time.asctime(struct_time))
print("Epoch start time = " + str(starttime))

# Read our ship route data in this order
htsgw_arr = np.fromfile(sr_fp, dtype=np.float32, count=NUMSRPOINTS*TDEF)
dirpw_arr = np.fromfile(sr_fp, dtype=np.float32, count=NUMSRPOINTS*TDEF)
wind_arr = np.fromfile(sr_fp, dtype=np.float32, count=NUMSRPOINTS*TDEF)
perpw_arr = np.fromfile(sr_fp, dtype=np.float32, count=NUMSRPOINTS*TDEF)

cnt = 0
for tstep in range(1, (TDEF+1)):

   forecastTime = cnt * TINCR
   cnt = cnt+1
   print("Forecast time: "+str(forecastTime))

   # Setup our sub plots
   axmap = plt.subplot2grid((3,4), (0, 0), rowspan=2, colspan=2)
   axmap.get_yaxis().set_visible(False)
   axmap.get_xaxis().set_visible(False)
   axmap.spines['top'].set_visible(False)
   axmap.spines['right'].set_visible(False)
   axmap.spines['bottom'].set_visible(False)
   axmap.spines['left'].set_visible(False)
   ax_chart_top = plt.subplot2grid((3,4), (0, 2),colspan=2)
   ax_chart_middle = plt.subplot2grid((3,4), (1, 2),colspan=2)
   ax_chart_bottom  = plt.subplot2grid((3,4), (2, 2),colspan=2)
   
   print('')
   print('Processing Time step: '+str(tstep))

   cur_image_file = "swan_shiproute_curclip_"+str(tstep)+".png"
   cur_image =  plt.imread(cur_image_file)
   axmap.set_title('Ocean Current (Knots)', size=8, color='black')
   axmap.imshow(cur_image,interpolation='gaussian')

   htsgw = htsgw_arr[(tstep-1)*NUMSRPOINTS:tstep*NUMSRPOINTS]
   dirpw = dirpw_arr[(tstep-1)*NUMSRPOINTS:tstep*NUMSRPOINTS]
   wind = wind_arr[(tstep-1)*NUMSRPOINTS:tstep*NUMSRPOINTS]
   perpw = perpw_arr[(tstep-1)*NUMSRPOINTS:tstep*NUMSRPOINTS]

   # Set our exception values and do our unit conversions
   htsgw[np.where(htsgw==9.999e+20)] = np.nan
   htsgw[np.where(htsgw==9.999e+20)] = np.nan
   hgt = htsgw * 3.28
   dirpw[np.where(dirpw==9.999e+20)] = np.nan
   rad = 4 * np.arctan2(1.0,1.0) / 180
   dirpw_u = -1 * np.sin(rad*dirpw)
   dirpw_v = -1 * np.cos(rad*dirpw)
   wind[np.where(wind==9.999e+20)] = np.nan
   wndspdms_knots = wind * 1.9438444 
   perpw[np.where(perpw==9.999e+20)] = np.nan

   ind = np.arange(NUMSRPOINTS)
   ax_chart_bottom.set_xticks(ind)
   ticklabs = [''] * NUMSRPOINTS
   ticklabs[0] = SHIPROUTENAME.split(" to ",1)[0]
   ticklabs[len(ind[0::3])-1] = SHIPROUTENAME.split(" to ",1)[1]
   ax_chart_bottom.set_xticklabels(ticklabs, fontsize=7)
   ax_chart_bottom.get_yaxis().set_visible(False)
   ax_chart_bottom.get_xaxis().set_visible(True)
   ax_chart_bottom.set_title('Peak Wave Direction', size=8, color='black')
   ax_chart_bottom.quiver(dirpw_u[0::3],dirpw_v[0::3],scale=7.)

   ax_chart_middle.tick_params(axis='y', labelsize=7)
   if ( SHIPROUTENAME.split(" to ",1)[0] == 'Cook Inlet SW' or \
        SHIPROUTENAME.split(" to ",1)[0] == 'Barren Islands SW' or \
        SHIPROUTENAME.split(" to ",1)[0] == 'Whittier' ):
      ax_chart_middle.set_yticks((0,10,20,30,40,50))
      ax_chart_middle.set_ylim([0,50])
      ax_chart_middle.axhline(y=23,xmin=0,xmax=3,c="darkorange",linewidth=1.5,zorder=0,label='Small Craft Advisory')
      ax_chart_middle.axhline(y=33,xmin=0,xmax=3,c="red",linewidth=1.5,zorder=0,label='Gale')
   elif ( SHIPROUTENAME.split(" to ",1)[0] == 'Long Beach' or \
        SHIPROUTENAME.split(" to ",1)[0] == 'Ventura' ):
      ax_chart_middle.set_yticks((0,10,20,30,40))
      ax_chart_middle.set_ylim([0,40])
      ax_chart_middle.axhline(y=21,xmin=0,xmax=3,c="darkorange",linewidth=1.5,zorder=0,label='Small Craft Advisory')
      ax_chart_middle.axhline(y=34,xmin=0,xmax=3,c="red",linewidth=1.5,zorder=0,label='Gale')
   else:
      ax_chart_middle.set_yticks((0,10,20,30,40))
      ax_chart_middle.set_ylim([0,40])
      ax_chart_middle.axhline(y=15,xmin=0,xmax=3,c="gold",linewidth=1.5,zorder=0,label='Small Craft Exercise Caution')
      ax_chart_middle.axhline(y=20,xmin=0,xmax=3,c="darkorange",linewidth=1.5,zorder=0,label='Small Craft Advisory')
      ax_chart_middle.axhline(y=33,xmin=0,xmax=3,c="red",linewidth=1.5,zorder=0,label='Gale')
   wind_bar_width = .8
   font= FontProperties(weight='bold',size=3.7)
   legend = ax_chart_middle.legend(loc='upper right', ncol=3,frameon=False,prop=font)
   ax_chart_middle.set_xticks(ind)
   ax_chart_middle.axes.get_xaxis().set_visible(False)
   ax_chart_middle.set_title('Wind Speed (Knots)', size=8, color='black')
   ax_chart_middle.bar(np.arange(NUMSRPOINTS), wndspdms_knots, wind_bar_width, color='green',alpha=.25)

   ax2_chart_top = ax_chart_top.twinx()
   ax_chart_top.tick_params(axis='y', labelsize=7)
   ax_chart_top.set_yticks((0,4,8,12,16))
   ax_chart_top.set_ylim([0,16])
   ax2_chart_top.tick_params(axis='y', labelsize=7)
   ax2_chart_top.set_yticks((0,5,10,15,20))
   ax2_chart_top.set_ylim([0,20])
   trans = ax_chart_top.get_xaxis_transform()
   hgt_bar_width = 0.7
   perpw_bar_width = 0.5
   ax_chart_top.plot(hgt, color='blue')
   ax_chart_top.axhline(y=7.5,xmin=0,xmax=3,c="red",linewidth=1.5,zorder=0,label='Small Craft Advisory')
   font = FontProperties(weight='bold',size=3.7)
   legend = ax_chart_top.legend(loc='upper right', ncol=1,frameon=False,prop=font)
   ax2_chart_top.bar(ind, perpw, perpw_bar_width, color='green',alpha=.5) 
   ax_chart_top.set_xticks(ind)
   ax2_chart_top.set_xticks(ind)
   ax_chart_top.axes.get_xaxis().set_visible(False)
   ax2_chart_top.axes.get_xaxis().set_visible(False)
   ax_chart_top.set_title('(ft) Significant Wave Height     ', horizontalalignment='right', size=7.5, color='blue')
   ax2_chart_top.set_title('     Peak Wave Period (sec)', horizontalalignment='left', size=7.5, color='green')

   plt.subplots_adjust(hspace=.30, left=.04, bottom=.15, right=.97, top=.82, wspace=.30)

   #MODEL = 'Nearshore Wave Prediction System\n'
   #plottitle =  MODEL + ' Transect Plot - ' + str(TINCR) + 'hr Forecast'
   #plt.figtext(.2,.92, plottitle,fontsize=14, color='black')

   plottitle = 'Experimental Nearshore Wave Prediction System\n                 Transect Forecast Guidance'
   plt.figtext(.15,.92, plottitle,fontsize=14, color='black')

   sbuf = '**EXPERIMENTAL**: The accuracy or reliability of these forecasts are not guaranteed nor warranted in any way.'
   plt.figtext(0.01, 0.06, sbuf, fontsize=9, color='black')
   sbuf = 'Forecast should not be used as the sole resource for decision making. Graphics may not be available at all times.'
   plt.figtext(0.01, 0.03, sbuf, fontsize=9, color='black')
   sbuf =  SHIPROUTENAME
   plt.figtext(.01,.3, sbuf,fontsize=14, color='black')

   esecs = forecastTime * 3600
   etime = starttime + esecs
   datestamp = dt.datetime.fromtimestamp(etime)
   sbuf =  'Hour '  +str(forecastTime)+' ('+datestamp.strftime('%Hz%d%b%Y')+')'
   plt.figtext(.01,.25, sbuf,fontsize=14, color='black')
   sbuf = 'Distance: ' + str(DISTANCE_NM) + 'NM'
   plt.figtext(.01,.20, sbuf,fontsize=14, color='black')

   # Set up subaxes and plot the logos in them
   plt.axes([0.02,.87,.08,.08])
   plt.axis('off')
   plt.imshow(noaa_logo,interpolation='gaussian')
   plt.axes([.92,.87,.08,.08])
   plt.axis('off')
   plt.imshow(nws_logo,interpolation='gaussian')

   filenm = IMGFILEPREFIX + '_hr'+str(forecastTime).zfill(3)+'.png'
   plt.savefig(filenm,dpi=DPI,bbox_inches='tight',pad_inches=0.1)
   plt.clf()

# Clean up
sr_fp.close()
os.system('rm -fv swan_shiproute_curclip_*.png')
# -----------------------------------------------------------
# *******************************
# ********* End of File *********
# *******************************

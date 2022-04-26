#!/usr/bin/env python
# estofs_extend.py script
# Author: Andre van der Westhuysen, 04/19/15
#
# Contributor: Roberto Padilla-Hernandez
#
# Purpose:
#    Extends ESTOFS water level field towards the coast with a nearest neighbor extrapolation
#    method, for a given time level. Uses as input the ESTOFS domain file (estofs_waterlevel_domain.txt)
#    and water level field file (e.g. wave_estofs_waterlevel_1429336800_20150418_06_f000.dat).
#
# Usage:
#    $ python estofs_extend.py [ESTOFS water level field file]
#
#    e.g.
#    $ python estofs_extend.py wave_estofs_waterlevel_1429336800_20150418_06_f000.dat
#

import sys
import os.path
import numpy as np

#--------------- User input ---------------
niter = 4  # Number of extension iterations
pltflag = False  # Flag for plotting figures
#------------------------------------------

if (pltflag):
   import matplotlib.pyplot as plt
   from mpl_toolkits.basemap import Basemap

# Read domain file
domainfile = 'estofs_waterlevel_domain.txt'
if os.path.isfile(domainfile):
   print('*** estofs_extend.py ***')
   print('Reading: '+domainfile)
else:
   print('*** TERMINATING ERROR: Missing ESTOFS domain file: '+domainfile)
   sys.exit()

with open(domainfile) as f:
    content = f.readline()
dummy = content.split()
nlon = int(dummy[3])+1   #SWAN stores nlon as mxc (= nlon-1)
nlat = int(dummy[4])+1   #SWAN stores nlat as myc (= nlat-1)
dummy2 = dummy[0]
x0 = float(dummy2[13:19])
y0 = float(dummy[1])
dx = float(dummy[5])
dy = float(dummy[6])

#print('ESTOFS field dimensions: nlon='+str(nlon)+', nlat='+str(nlat))
#print('x0='+str(x0)+', y0='+str(y0)+', dx='+str(dx)+', dy='+str(dy))

lons=np.linspace(x0,x0+float(nlon-1)*dx,num=nlon)
lats=np.linspace(y0,y0+float(nlat-1)*dy,num=nlat)
# Convert to -180:180 format
lons = lons-360

#print(lons.shape)
#print(lons.min(), lons.max())
#print(lats.shape)
#print(lats.min(), lats.max())

# Read ESTOFS data file
infile = sys.argv[1]
if os.path.isfile(infile):
   print('Reading: '+infile)
else:
   print('*** TERMINATING ERROR: Missing ESTOFS data file: '+infile)
   sys.exit()

data=np.loadtxt(infile)

#print(data.shape)

# Create a matrix of nlat x nlon initialized to 0
rawpar = np.zeros((nlat, nlon))
par = np.zeros((nlat, nlon))
#print(rawpar.shape)

# Set up water level field
for lat in range(0, nlat):
   for lon in range(0, nlon):
      rawpar[lat,lon] = data[nlon*lat+lon]
      par[lat,lon] = data[nlon*lat+lon]

# Plot raw field
if (pltflag):
   fig = plt.figure()
   m=Basemap(projection='merc',llcrnrlon=lons.min(),urcrnrlon=lons.max(),llcrnrlat=lats.min(),urcrnrlat=lats.max(),resolution='h')
   reflon,reflat=np.meshgrid(lons,lats)
   x,y=m(reflon,reflat)
   m.contourf(x,y,rawpar,cmap=plt.cm.jet)
   m.colorbar()

   m.drawcoastlines()
   m.drawmeridians(np.arange(lons.min(),lons.max(),1.0),labels=[0,0,0,0.5],dashes=[1,3],color='0.50',fontsize=7)
   m.drawparallels(np.arange(lats.min(),lats.max(),0.5),labels=[0.5,0,0,0],dashes=[1,3],color='0.50',fontsize=7)

   figtitle = 'ESTOFS water level, before extension (m):\n'+infile
   plt.title(figtitle,fontsize=14)

   filenm = 'estofs.png'
   plt.savefig(filenm,dpi=150,bbox_inches='tight',pad_inches=0.1)
   plt.clf

for iter in range(1,niter+1):
   # Copy water level field from last iteration
   for lat in range(0, nlat):
      for lon in range(0, nlon):
         rawpar[lat,lon] = par[lat,lon]

   # Extrapolate values towards the coast
   #print('Editing field...')
   for lat in reversed(range(1, nlat-1)):
      for lon in range(1, nlon-1):
         nghsum = 0.
         nngh = 0
         if (rawpar[lat,lon] == 0.):
            #print('Testing ('+str(lon)+','+str(lat)+'): par='+str(par[lat,lon])+'; rawpar='+str(rawpar[lat,lon]))
            for ysearch in range(-1, 2):
               for xsearch in range(-1, 2):
                  #print(lon+xsearch,lat+ysearch)
                  if (rawpar[lat+ysearch,lon+xsearch] != 0.): # and not(xsearch==0 and ysearch==0) ):
                     #print('Adding: '+str(rawpar[lat+ysearch,lon+xsearch]))
                     nghsum = nghsum+rawpar[lat+ysearch,lon+xsearch]
                     nngh = nngh+1
            #print('Result: nngh='+str(nngh)+', nghsum='+str(nghsum))
            if nngh >= 3:
               par[lat,lon] = nghsum/nngh
               rawpar[lat,lon] = 0.
               #print('Updating ('+str(lon)+','+str(lat)+'): par='+str(par[lat,lon])+'; rawpar='+str(rawpar[lat,lon]))

   # Plot updated field
   if (pltflag):
      fig = plt.figure()
      m=Basemap(projection='merc',llcrnrlon=lons.min(),urcrnrlon=lons.max(),llcrnrlat=lats.min(),urcrnrlat=lats.max(),resolution='h')
      reflon,reflat=np.meshgrid(lons,lats)
      x,y=m(reflon,reflat)
      m.contourf(x,y,par,cmap=plt.cm.jet)
      m.colorbar()

      m.drawcoastlines()
      m.drawmeridians(np.arange(lons.min(),lons.max(),1.0),labels=[0,0,0,0.5],dashes=[1,3],color='0.50',fontsize=7)
      m.drawparallels(np.arange(lats.min(),lats.max(),0.5),labels=[0.5,0,0,0],dashes=[1,3],color='0.50',fontsize=7)

      figtitle = 'ESTOFS water level, extension iter '+str(iter)+' (m):\n'+infile
      plt.title(figtitle,fontsize=14)

      filenm = 'estofs_iter'+str(iter)+'.png'
      plt.savefig(filenm,dpi=150,bbox_inches='tight',pad_inches=0.1)
      plt.clf

# Write output file
fout = open('extend_'+infile,"w")
print('Writing: '+'extend_'+infile)

for ilat in range(0,nlat):
   for ilon in range(0,nlon):
      #fout.write('  %.5f' % par[ilat,ilon])
      fout.write('%s' % par[ilat,ilon])
      fout.write('\n')

fout.close()

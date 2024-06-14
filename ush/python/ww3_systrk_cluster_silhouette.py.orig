#!/usr/bin/env python
import sys
import os
import time
import datetime
import numpy as np
import numpy.ma as ma
import math
from io import StringIO

from sklearn import cluster
from sklearn.neighbors import kneighbors_graph
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import silhouette_score

print
print('                   *** WAVEWATCH III Wave system tracking ***  ')
print('               ===============================================')
print

NWPSdir = os.environ['NWPSdir']

# Parameters
monthstr = ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC']
wfo = sys.argv[1]
nclust = int(sys.argv[2])
plot_output = True

print('Reading ww3_systrk.inp file...')
fname = 'ww3_systrk.inp'
with open(fname) as ff:
   # Skip header matter
   for iloc in range(0, 10):
        line = ff.readline()

   # Get date
   line = ff.readline()
   yyyymmdd,HHMMSS,delta_t,ntimes = line.split()
   dt = int(delta_t)
   nt = int(ntimes)
   date_time = yyyymmdd+' '+HHMMSS
   pattern = '%Y%m%d %H%M%S'
   startdate = int(time.mktime(time.strptime(date_time, pattern)))
   enddate = startdate + dt*(nt-1)
   print('Start time:',datetime.datetime.fromtimestamp(startdate).strftime('%Y%m%d.%H%M%S'))
   print('End time:',datetime.datetime.fromtimestamp(enddate).strftime('%Y%m%d.%H%M%S'))
   print('Number of time levels being processed:',nt)

   # Skip comment lines
   for iloc in range(0, 4):
        line = ff.readline()

   # Read coordinates
   line = ff.readline()
   dum1,dum2,dum3 = line.split()
   x0=float(dum1)
   xn=float(dum2)
   mxc=int(dum3)
   line = ff.readline()
   dum1,dum2,dum3 = line.split()
   y0=float(dum1)
   yn=float(dum2)
   myc=int(dum3)

   print('LON0,LONN,MXC:',x0,xn,mxc)
   print('LAT0,LATN,MYC:',y0,yn,myc)

   dx = (xn-x0)/mxc
   dy = (yn-y0)/myc
   nlon = mxc+1
   nlat = myc+1
   print('DLON,DLAT,NLON,NLAT:',("%.4f" % dx),("%.4f" % dy),nlon,nlat)

   # Skip comment lines
   for iloc in range(0, 10):
        line = ff.readline()

   # Read output points (for Gerling-Hanson plots)
   print
   print('Output point locations:')
   nloc = 0
   pntlon = []
   pntlat = []   
   while (nloc < 50):
      line = ff.readline()
      dum1,dum2 = line.split()
      if (float(dum1)==0.000)&(float(dum2)==0.000):
         break
      nloc += 1
      pntlon = np.append(pntlon, float(dum1))
      pntlat = np.append(pntlat, float(dum2))
   print(nloc)
   print(pntlon)
   print(pntlat)

print
print('Reading partition.blk.raw file...')
rawdat = np.loadtxt('partition.blk.raw')
print('... finished')
#print(rawdat)

# Select parameters for clustering, omitting first (empty) record
# Contents of partition.blk.raw:
# 20181015.060000  49.420 233.000    1.12   11.85   282.22     9.98   0.00
wavedat = rawdat[1:-1,[4, 5]]
wavedat2 = rawdat[1:-1,[0, 1, 2, 3, 4, 5, 8, 9]]
# Change circular boundary of DIR from N to E for these West Coast WFOs
if ( (wfo == 'sgx') | (wfo == 'lox') | (wfo == 'mtr') | (wfo == 'eka') | \
     (wfo == 'mfr') | (wfo == 'pqr') | (wfo == 'sew') | (wfo == 'alu') ):
   wavedat[:,1] = [ x+360. if x<90. else x for x in wavedat[:,1]]
print('Data used in fit:')
print(wavedat)

#---- Clustering algorithms -----
print
print('Fitting data...')
wavedat = StandardScaler().fit_transform(wavedat)
silhouette_best = -1.
# Compute silhoutte coefficient for trial number of clusters
print('Trying nclust =',nclust)
k_means = cluster.KMeans(n_clusters=nclust, random_state=1)
k_means.fit(wavedat)
label=k_means.labels_.astype(np.float)

print('Calculating fit quality...')
if len(set(label[0:(nlon*nlat*5)])) > 1:
   silhouette_avg = silhouette_score(wavedat[0:(nlon*nlat*5),:], label[0:(nlon*nlat*5)], 
                                     sample_size=min(25000,nlon*nlat*5), random_state=1)
else:
   silhouette_avg = 0.

print('Silhouette Coefficient:',silhouette_avg,'\n')
ofilenm = 'silhouette_coeff_k'+str(nclust)+'.txt'
text_file = open(ofilenm, "w")
text_file.write("%s" % str(silhouette_avg))
text_file.close()
#--------------------------------


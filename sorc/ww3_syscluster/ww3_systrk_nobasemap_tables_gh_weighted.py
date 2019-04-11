import sys
import os
import matplotlib
matplotlib.use('Agg',warn=False)
import time
import datetime
import numpy as np
import numpy.ma as ma
import matplotlib.pyplot as plt
import math
#from mpl_toolkits.basemap import Basemap
from io import StringIO

from sklearn import cluster
from sklearn.neighbors import kneighbors_graph
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import silhouette_score

# Parameters
monthstr = ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC']
wfo = sys.argv[1]
plot_output = True

if (wfo == 'bro'):
   buoy = '42020'
if (wfo == 'crp'):
   buoy = '42019'
if (wfo == 'hgx'):
   buoy = '42019'
if (wfo == 'lch'):
   buoy = '42035'
if (wfo == 'lix'):
   buoy = '42040'
if (wfo == 'mob'):
   buoy = '42040'
if (wfo == 'tae'):
   buoy = '42039'
if (wfo == 'tbw'):
   buoy = '42036'
if (wfo == 'mfl'):
   buoy = '41114'
if (wfo == 'key'):
   buoy = 'GSTRM'
if (wfo == 'mlb'):
   buoy = '41009'
if (wfo == 'jax'):
   buoy = '41112'
if (wfo == 'sju'):
   buoy = '41053'

if (wfo == 'chs'):
   buoy = '41004'
if (wfo == 'ilm'):
   buoy = '41013'
if (wfo == 'mhx'):
   buoy = '41025'
if (wfo == 'akq'):
   buoy = '44093'
if (wfo == 'lwx'):
   buoy = '44062'
if (wfo == 'phi'):
   buoy = '44091'
if (wfo == 'okx'):
   buoy = '44025'
if (wfo == 'box'):
   buoy = '44018'
if (wfo == 'gyx'):
   buoy = '44032'
if (wfo == 'car'):
   buoy = '44034'

if (wfo == 'sew'):
   buoy = '46041'
if (wfo == 'pqr'):
   buoy = '46248'
if (wfo == 'mfr'):
   buoy = '46015'
if (wfo == 'eka'):
   buoy = '46213'
if (wfo == 'mtr'):
   buoy = '46012'
if (wfo == 'lox'):
   buoy = '46069'
if (wfo == 'sgx'):
   buoy = '46086'

if (wfo == 'hfo'):
   buoy = '51003'
if (wfo == 'gum'):
   buoy = '52202'
if (wfo == 'gua'):
   buoy = '52202'

if (wfo == 'ajk'):
   buoy = '46085'
if (wfo == 'aer'):
   buoy = '46080'
if (wfo == 'alu'):
   buoy = '46073'
if (wfo == 'afg'):
   buoy = '48114'

def array2cols(data,filename,cols):
	rows=data.shape[0]
	s=''
	for row in range(rows):
		s+=array_one_row(data[row,],filename,cols)
	with open(filename,'a') as f:                  # append to file
		f.write(s)
	return

def array_one_row(data,filename,cols):
	"""
	Convert numpy masked array to ascii fixed width file
	"""
	rows=int(data.size/cols)                       # calc number of rows needed
	if data.size%cols != 0:                        # add one more for spillover
		rows+=1
	data2=data.filled().copy()                     # convert to filled numpy array
	data2=np.resize(data2,(rows,cols))             # expand to new size and pad with zeros
	spares=cols-data.size%cols                     # compute number of values to blank at end
	if (spares > 0) & (spares < 6):
		data2[-1,-spares:]=-888.               # convert any end zeros to dummy values
	s = StringIO()                                 # create internal file
	np.savetxt(s,data2,fmt='%8.2f',delimiter='')   # save to internal file
	s2=s.getvalue().replace('-8.8800e+02',' '*11)  # replace dummy values
        #del s                                         # Cleans internal file
	return s2

print
print('                   *** WAVEWATCH III Wave system tracking ***  ')
print('               ===============================================')
print

print('Reading spiral track files file...')
print('Read Tp values from spiral track output file...')
fname = '../output/partition/CG1/SYS_TP.OUT.SPRL'
with open(fname) as ff:
   line = ff.readline()
   nrowspl = int(line[0:6])
   line = ff.readline()
   ncolspl = int(line[0:6])
   print(nrowspl,ncolspl)

   datespl = np.empty(145)
   tpspl = np.empty((nrowspl,ncolspl))
   dirspl = np.empty((nrowspl,ncolspl))
   grpspl = np.empty((nrowspl,ncolspl))
   tpvec = np.empty((nrowspl*ncolspl,1))
   dirvec = np.empty((nrowspl*ncolspl,1))
   grpvec = np.empty((nrowspl*ncolspl,1))

   nobs = 0
   for fhour in range(0, 1):
      print(fhour)
      line = ff.readline()
      yyyymmddHHMMSS = line[0:15]
      date_time = yyyymmddHHMMSS
      pattern = '%Y%m%d.%H%M%S'
      datespl[fhour] = int(time.mktime(time.strptime(date_time, pattern)))
      print(yyyymmddHHMMSS)

      line = ff.readline()
      ngrpspl = int(line[0:6])

      for igrp in range(0, ngrpspl):
         print('wave sys:'+str(igrp+1))
         line = ff.readline()
         line = ff.readline()
         nobs = nobs+int(line[0:6])   #Calculate total number of grouped partitions
         print(nobs)

         for irow in range(0, nrowspl):
            line = ff.readline()
            tpspl[irow,0:ncolspl] = np.asarray(line.split())
            grpspl[irow,0:ncolspl] = igrp+1
         #print(tpspl)
         #print(grpspl)

         tp1d = tpspl.reshape((nrowspl*ncolspl,1))
         #print(tp1d.shape)
         #print(tp1d)

         grp1d = grpspl.reshape((nrowspl*ncolspl,1))
         #print(grp1d.shape)
         #print(grp1d)

         tpvec = np.append(tpvec,tp1d,axis=0)
         #print(tpvec.shape)
         #print(tpvec)

         grpvec = np.append(grpvec,grp1d,axis=0)
         #print(grpvec.shape)
         #print(grpvec)
   print(nobs)
 
print('Read Dir values from spiral track output file...')           
fname = '../output/partition/CG1/SYS_DIR.OUT.SPRL'
with open(fname) as ff:
   line = ff.readline()
   nrowspl = int(line[0:6])
   line = ff.readline()
   ncolspl = int(line[0:6])
   print(nrowspl,ncolspl)

   datespl = np.empty(145)
   dirspl = np.empty((nrowspl,ncolspl))
   dirvec = np.empty((nrowspl*ncolspl,1))
    
   for fhour in range(0, 1):
      print(fhour)
      line = ff.readline()
      yyyymmddHHMMSS = line[0:15]
      date_time = yyyymmddHHMMSS
      pattern = '%Y%m%d.%H%M%S'
      datespl[fhour] = int(time.mktime(time.strptime(date_time, pattern)))
      print(yyyymmddHHMMSS)

      line = ff.readline()
      ngrpspl = int(line[0:6])

      for igrp in range(0, ngrpspl):
         print('wave sys:'+str(igrp+1))
         line = ff.readline()
         line = ff.readline()

         for irow in range(0, nrowspl):
            line = ff.readline()
            dirspl[irow,0:ncolspl] = np.asarray(line.split())
         #print(dirspl)

         dir1d = dirspl.reshape((nrowspl*ncolspl,1))
         #print(dir1d.shape)
         #print(dir1d)

         dirvec = np.append(dirvec,dir1d,axis=0)
         #print(dirvec.shape)
         #print(dirvec)

   spldat = np.append(tpvec,dirvec,axis=1)
   spldat = np.append(spldat,grpvec,axis=1)
   spldat = spldat[nrowspl*ncolspl:,:]
   spldat = spldat[spldat[:,0]!=9999.00,:]
   print(spldat.shape)
   #print(spldat[:,0:2])
   #print(spldat[:,2])

   print('Calculating spiral fit quality...')
   if ( len(np.unique(spldat[:,2])) != 1 ):            #To compute metric there must be more than 1 label (wave group)
      silhouette_spl = silhouette_score(spldat[:,0:2], spldat[:,2])
   else:
      print('*** Only one wave group found - SC cannot be computed')
      silhouette_spl = -9.999
   print('Silhouette Coefficient:',silhouette_spl,'\n')
   print(nobs)
   print(nrowspl,ncolspl,ngrpspl)
   sparse_coef = float(nobs)/float(nrowspl*ncolspl*ngrpspl)
   print('Sparseness Coefficient:',sparse_coef,'\n')

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
print('Reading SPC2D spectral file...')
print('wfo, buoy:')
print(wfo, buoy)
fname = '../output/grid/SPC2D.'+buoy+'.CG1'
with open(fname) as ff:
   # Skip header matter
   for iloc in range(0, 7):
        line = ff.readline()

   # Get lon/lat
   line = ff.readline()
   spclon,spclat = line.split()
   spclon = float(spclon)
   spclat = float(spclat)
   print('SPC2D lon/lat:')
   print(spclon,spclat)

   # Get frequencies
   line = ff.readline()
   line = ff.readline()
   nfreq = int(line[0:6])+1
   zeniths = np.zeros(nfreq)
   for ifreq in range(1, nfreq):
       zeniths[ifreq]  = ff.readline()
   zeniths[0] = 0.             #Add zero point to frequency axis (below f_low)
   print('frequencies:')
   print(zeniths)

   # Get directions
   line = ff.readline()
   line = ff.readline()
   ndir = int(line[0:6])+1
   azimuths = np.zeros(ndir)
   for idir in range(0, ndir-1):
       azimuths[idir]  = ff.readline()
   azimuths[(ndir-1)] = azimuths[0]-360.   #Take care of circular boundary
   azimuths = np.radians(azimuths)
   print('directions:')
   print(azimuths)

   # Skip metadata
   for iloc in range(0, 5):
        line = ff.readline()

   vardens = np.zeros((145,nfreq,ndir))
   spcdate = np.zeros(145)

   # Read date and variance density
   for fhour in range(0, 145):
      #print(fhour)
      line = ff.readline()
      yyyymmddHHMMSS = line[0:15]
      date_time = yyyymmddHHMMSS
      pattern = '%Y%m%d.%H%M%S'
      spcdate[fhour] = int(time.mktime(time.strptime(date_time, pattern)))
      print(yyyymmddHHMMSS)
      #print(spcdate[fhour])

      line = ff.readline()
      factor = ff.readline()
      #print(factor)
      for ifreq in range(1, nfreq):
          line = ff.readline()
          vardens[fhour,ifreq,0:(ndir-1)] = line.split()
      vardens[fhour,:,:] = float(factor)*np.asarray(vardens[fhour,:,:])
      vardens[fhour,:,(ndir-1)] = vardens[fhour,:,0]
      vardens[fhour,0,:] = np.zeros(ndir)
      #print('variance density:')
      #print(vardens[fhour,:,:])
      #vardens[vardens < 100.*float(factor)] = np.nan

# Format zeniths/azimuths
r, theta = np.meshgrid(zeniths, azimuths)
#print(r)
#print(theta)

print
print('Reading partition.blk.raw file...')
rawdat = np.loadtxt('partition.blk.raw')
print('... finished')
#print(rawdat)

placemnt_coef = float(nobs)/float(len(rawdat))*145      #Temporarily multiply by 145 to get results for 1st hour
print(nobs)
print(len(rawdat)/145)
print('Placement Coefficient:',placemnt_coef,'\n')

# Select parameters for clustering, omitting first (empty) record
# Contents of partition.blk.raw:
# 20181015.060000  49.420 233.000    1.12   11.85   282.22     9.98   0.00
wavedat = rawdat[1:-1,[4, 5]]
wavedat2 = rawdat[1:-1,[0, 1, 2, 3, 4, 5]]
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
# Test optimal number of clusters (between 2-5)
for nclust in range(2, 6):
   print('Trying nclust =',nclust)
   k_means = cluster.KMeans(n_clusters=nclust)
   k_means.fit(wavedat)
   #affinity_propagation = cluster.AffinityPropagation(damping=.9,preference=-200)
   #affinity_propagation.fit(wavedat)
   label=k_means.labels_.astype(np.float)
   #>label=affinity_propagation.labels_.astype(np.float)

   print('Calculating fit quality...')
   silhouette_avg = silhouette_score(wavedat[0:(nlon*nlat*5),:], label[0:(nlon*nlat*5)], sample_size=min(25000,nlon*nlat*5))
   print('Silhouette Coefficient:',silhouette_avg,'\n')
   #silhouette_avg = 0.
   if silhouette_avg > silhouette_best:
      silhouette_best = silhouette_avg
      nclust_best = nclust
      label_best = label
print('nclust_best = ',nclust_best)
print('silhouette_best = ',silhouette_best)
#--------------------------------

#># connectivity matrix for structured Ward
#>connectivity = kneighbors_graph(wavedat, n_neighbors=10, include_self=False)
#># make connectivity symmetric
#>connectivity = 0.5 * (connectivity + connectivity.T)

#>average_linkage = cluster.AgglomerativeClustering(linkage="average", affinity="cityblock", connectivity=connectivity)
#>average_linkage.fit(wavedat)

#label=average_linkage.labels_.astype(np.float)
#partmax=max(label)
#print(partmax)
#for itime in range(1500328800, 1500350400, 3600):

lons=np.linspace(x0,x0+float(nlon-1)*dx,num=nlon)
lats=np.linspace(y0,y0+float(nlat-1)*dy,num=nlat)
reflon,reflat=np.meshgrid(lons,lats)
#print(lons)
#print(lats)

if (lons.max()-lons.min()) > 15.0:
   dlon = 5.0
elif (lons.max()-lons.min()) > 2.0:
   dlon = 2.0
else:
   dlon = (lons.max()-lons.min())/5.
if (lats.max()-lats.min()) > 1.0:
   dlat = 1.0
else:
   dlat = (lats.max()-lats.min())/5.

convfac = 1/0.3048   #meters to feet

# Find indices of output points for PNT file
pntlat_ind1 = np.zeros(nloc, dtype=np.int)
pntlat_ind2 = np.zeros(nloc, dtype=np.int)
pntlon_ind1 = np.zeros(nloc, dtype=np.int)
pntlon_ind2 = np.zeros(nloc, dtype=np.int)
print('\nFinding indices of output points...')
for iloc in range(0, nloc):
   for ilat in range(0, nlat-1):
      if ( (pntlat[iloc] > lats[ilat]) & (pntlat[iloc] <= lats[ilat+1]) ):
         pntlat_ind1[iloc] = ilat
         pntlat_ind2[iloc] = ilat+1
   for ilon in range(0, nlon-1):
      if ( (pntlon[iloc] > lons[ilon]) & (pntlon[iloc] <= lons[ilon+1]) ):
         pntlon_ind1[iloc] = ilon
         pntlon_ind2[iloc] = ilon+1
   print(int(iloc+1),pntlon_ind1[iloc],pntlon_ind2[iloc],pntlat_ind1[iloc],pntlat_ind2[iloc])
print

# Plot wave systems, and 2D spectra

fname_hs = 'SYS_HSIGN.OUT'
excp_hs = 9999.00
fname_dr = 'SYS_DIR.OUT'
excp_dr = 9999.00
fname_tp = 'SYS_TP.OUT'
excp_tp = 9999.00
fname_pnt = 'SYS_PNT.OUT'
excp_pnt = 9999.00

#HS
#Clean old output file before writing new one
if os.path.isfile(fname_hs):
   os.remove(fname_hs)
# Header info
s = str(nlat).rjust(6)+'                                                                     Number of rows\n'
with open(fname_hs,'a') as f:                  # append to file
    f.write(s)
s = str(nlon).rjust(6)+'                                                                     Number of cols\n'
with open(fname_hs,'a') as f:                  # append to file
    f.write(s)

#DIR
#Clean old output file before writing new one
if os.path.isfile(fname_dr):
   os.remove(fname_dr)
# Header info
s = str(nlat).rjust(6)+'                                                                     Number of rows\n'
with open(fname_dr,'a') as f:                  # append to file
    f.write(s)
s = str(nlon).rjust(6)+'                                                                     Number of cols\n'
with open(fname_dr,'a') as f:                  # append to file
    f.write(s)

#TP
#Clean old output file before writing new one
if os.path.isfile(fname_tp):
   os.remove(fname_tp)
# Header info
s = str(nlat).rjust(6)+'                                                                     Number of rows\n'
with open(fname_tp,'a') as f:                  # append to file
    f.write(s)
s = str(nlon).rjust(6)+'                                                                     Number of cols\n'
with open(fname_tp,'a') as f:                  # append to file
    f.write(s)

#PNT
#Clean old output file before writing new one
if os.path.isfile(fname_pnt):
   os.remove(fname_pnt)
# Header info
s = '%\n'
with open(fname_pnt,'a') as f:                  # append to file
    f.write(s)
s = '%\n'
with open(fname_pnt,'a') as f:                  # append to file
    f.write(s)
s = '% WW3 Wave tracking point output\n'
with open(fname_pnt,'a') as f:                  # append to file
    f.write(s)
s = '%\n'
with open(fname_pnt,'a') as f:                  # append to file
    f.write(s)
s = '%       Xp            Yp            HsSY01        HsSY02        HsSY03        HsSY04        HsSY05        '+\
    'HsSY06        HsSY07        HsSY08        HsSY09        HsSY10        '+\
    'TpSY01        TpSY02        TpSY03        TpSY04        TpSY05        '+\
    'TpSY06        TpSY07        TpSY08        TpSY09        TpSY10        '+\
    'DrSY01        DrSY02        DrSY03        DrSY04        DrSY05        '+\
    'DrSY06        DrSY07        DrSY08        DrSY09        DrSY10\n'
with open(fname_pnt,'a') as f:                  # append to file
    f.write(s)
s = '%       [degr]        [degr]        [m]           [m]           [m]           [m]           [m]           '+\
    '[m]           [m]           [m]           [m]           [m]           '+\
    '[sec]         [sec]         [sec]         [sec]         [sec]         '+\
    '[sec]         [sec]         [sec]         [sec]         [sec]         '+\
    '[degr]        [degr]        [degr]        [degr]        [degr]        '+\
    '[degr]        [degr]        [degr]        [degr]        [degr]\n'
with open(fname_pnt,'a') as f:                  # append to file
    f.write(s)
s = '%\n'
with open(fname_pnt,'a') as f:                  # append to file
    f.write(s)

#--- Read landboundary data (for use without Basemap/Cartopy) ---
landbound = np.loadtxt('coastal_bound_high.txt')
print(landbound[:,0])
print(landbound[:,1])
#----------------------------------------------------------------

#AWfhour = -3*dt/3600
fhour = -1*dt/3600
#AWfor itime in range(startdate, (enddate+3*dt), 3*dt):
for itime in range(startdate, (enddate+1*dt), 1*dt):
   timestr = time.strftime('%Y%m%d.%H', time.localtime(itime))
   print(timestr)
#AW   fhour = int(fhour+3*dt/3600)
   fhour = int(fhour+1*dt/3600)

   #HS
   s = timestr+'0000'+'                                                            Time\n'
   with open(fname_hs,'a') as f:                  # append to file
      f.write(s)
   s = str(nclust_best).rjust(6)+'                                                                     Tot number of systems\n'
   with open(fname_hs,'a') as f:                  # append to file
      f.write(s)

   #DIR
   s = timestr+'0000'+'                                                            Time\n'
   with open(fname_dr,'a') as f:                  # append to file
      f.write(s)
   s = str(nclust_best).rjust(6)+'                                                                     Tot number of systems\n'
   with open(fname_dr,'a') as f:                  # append to file
      f.write(s)

   #TP
   s = timestr+'0000'+'                                                            Time\n'
   with open(fname_tp,'a') as f:                  # append to file
      f.write(s)
   s = str(nclust_best).rjust(6)+'                                                                     Tot number of systems\n'
   with open(fname_tp,'a') as f:                  # append to file
      f.write(s)

   #PNT
   s = 'Time : '+timestr+'0000\n'
   with open(fname_pnt,'a') as f:                  # append to file
      f.write(s)

   hs_pnt = excp_pnt*np.ones((nloc,10))      # Place for Maximum of 10 wave systems in PNT files
   tp_pnt = excp_pnt*np.ones((nloc,10))      # Place for Maximum of 10 wave systems in PNT files
   dr_pnt = excp_pnt*np.ones((nloc,10))      # Place for Maximum of 10 wave systems in PNT files

   if (plot_output) & (fhour % 3 == 0):
      fig = plt.figure(figsize=(16,13))

   for ipart in range(0, nclust_best):
      #print('Wave system:',(ipart+1))
      labelindex = np.where(label_best == ipart)[0]
      #print(labelindex)
      partfield = wavedat2[ labelindex, ]
      #print(partfield)
      #print(len(partfield))
      #print(len(partfield[0]))

      hsmax = convfac*np.max(partfield[:,3])

      dateindex = np.where(partfield[:,0] == float(timestr))[0]
      #print(dateindex)
      partfield2 = partfield[ dateindex, ]
      #print(partfield2)

      # Create a matrices of nlat x nlon initialized to 0
      par = np.zeros((nlat, nlon))
      par.fill(np.nan)
      par2 = np.zeros((nlat, nlon))
      par2.fill(np.nan)
      par3 = np.zeros((nlat, nlon))
      par3.fill(np.nan)

      # Set up parameter field
      for ilat in range(0, nlat):
         for ilon in range(0, nlon):
            #print("grid: ",lat,lon)
            #print((np.where(partfield2[:,1] == lat))
            #print((np.where(partfield2[:,2] == lon))
            llind = np.where( (abs(partfield2[:,1]-lats[ilat]) < 0.005) & (abs(partfield2[:,2]-lons[ilon]) < 0.005) )[0]
            #print(llind)
            #print(partfield2[llind,1])
            #print(partfield2[llind,2])
            if llind.size:
               #AW072417 par[ilat,ilon] = partfield2[ min(llind), 3 ]
               #AW072417 par2[ilat,ilon] = partfield2[ min(llind), 4 ]
               #AW072417 par3[ilat,ilon] = partfield2[ min(llind), 5 ]
               par[ilat,ilon] = 4.*( np.sum((partfield2[ llind, 3 ]/4.)**2.) )**0.5
               #AW par2[ilat,ilon] = np.mean(partfield2[ llind, 4 ])
               #AW par2[ilat,ilon] = np.max(partfield2[ llind, 4 ])
               par2[ilat,ilon] = np.dot(partfield2[ llind, 4 ],(partfield2[ llind, 3 ]/4.)**2.)/np.sum((partfield2[ llind, 3 ]/4.)**2.)
               par3[ilat,ilon] = partfield2[ min(llind), 5 ]
      #print(par)
      #print(par2)
      #print(par3)
      print('Sys, Hs, Tp, Dir:',(ipart+1),("%5.2f" % np.nanmean(par)),("%5.2f" % np.nanmean(par2)),("%6.2f" % np.nanmean(par3)))

      par3ma = ma.masked_where(par3==-9999, par3)
      u=ma.cos(3.1416/180*(270-par3ma))
      v=ma.sin(3.1416/180*(270-par3ma))

      # --- Plot output in separate panels per cluster (every 3 hours) ---------
      if (plot_output) & (fhour % 3 == 0):      
         #if fhour == 0:
            #m=Basemap(projection='merc',llcrnrlon=lons.min(),urcrnrlon=lons.max(),llcrnrlat=lats.min(),urcrnrlat=lats.max(),resolution='h')
         x=reflon-360.
         y=reflat
         xspc=spclon-360.
         yspc=spclat

         if ipart < 3:
            plotloc = ipart+1
         else:
            plotloc = ipart+4         

         plt.subplot(4, 3, plotloc)
         #plt.scatter(partfield2[:, 2], partfield2[:, 1], partfield2[:, 3], edgecolor='none')
         if hsmax > 10.:
            clevs = np.arange(0, int(hsmax)+1,2)
         if hsmax > 5.:
            clevs = np.arange(0, int(hsmax)+1,1)
         if hsmax > 2.:
            clevs = np.arange(0, int(hsmax)+1,0.5)
         if hsmax > 1.:
            clevs = np.arange(0, int(hsmax)+1,0.2)
         if hsmax < 1.:
            clevs = np.arange(0, int(hsmax)+1,0.1)
         plt.contourf(x,y,convfac*np.asarray(par),clevs,cmap=plt.cm.jet)
         plt.colorbar()
         plt.plot(xspc,yspc,'k+',markersize=10,markeredgewidth=2)
         rowskip=int(np.floor(par3.shape[0]/20))
         colskip=int(np.floor(par3.shape[1]/20))
         print(rowskip)
         print(colskip)
         plt.quiver(x[0::rowskip,0::colskip],y[0::rowskip,0::colskip],\
             u[0::rowskip,0::colskip],v[0::rowskip,0::colskip], \
             color='black',pivot='middle',scale=6.,width=0.015,units='inches')
         #m.fillcontinents()
         #m.drawcoastlines()
         #m.drawmeridians(np.arange(lons.min(),lons.max(),dlon),labels=[0,0,0,dlon],dashes=[1,3],color='0.50',fontsize=9)   
         #m.drawparallels(np.arange(lats.min(),lats.max(),dlat),labels=[dlat,0,0,0],dashes=[1,3],color='0.50',fontsize=9)
         plt.plot(landbound[:,0]-360.,landbound[:,1],'k')
         plt.xlim(lons.min()-360.,lons.max()-360.)
         plt.ylim(lats.min(),lats.max())

         plt.subplot(4, 3, plotloc+3)
         #plt.scatter(partfield2[:, 2], partfield2[:, 1], partfield2[:, 3], edgecolor='none')
         clevs2 = np.arange(0, 30+1)
         plt.contourf(x,y,par2,clevs2,cmap=plt.cm.jet)
         plt.colorbar()
         plt.plot(xspc,yspc,'k+',markersize=10,markeredgewidth=2)
         rowskip=int(np.floor(par3.shape[0]/20))
         colskip=int(np.floor(par3.shape[1]/20))
         print(rowskip)
         print(colskip)
         plt.quiver(x[0::rowskip,0::colskip],y[0::rowskip,0::colskip],\
             u[0::rowskip,0::colskip],v[0::rowskip,0::colskip], \
             color='black',pivot='middle',scale=6.,width=0.015,units='inches')
         #m.fillcontinents()
         #m.drawcoastlines()
         #m.drawmeridians(np.arange(lons.min(),lons.max(),dlon),labels=[0,0,0,dlon],dashes=[1,3],color='0.50',fontsize=9)   
         #m.drawparallels(np.arange(lats.min(),lats.max(),dlat),labels=[dlat,0,0,0],dashes=[1,3],color='0.50',fontsize=9)
         plt.plot(landbound[:,0]-360.,landbound[:,1],'k')
         plt.xlim(lons.min()-360.,lons.max()-360.)
         plt.ylim(lats.min(),lats.max())

         # Plot 2d wave spectrum
         vardens_plt = vardens[fhour,:,:]  
         vardens_plt = np.transpose(vardens_plt)
         vardens_plt = np.log10(vardens_plt)
         ax = fig.add_subplot(4, 3, 9, projection='polar')
         ax.contourf(theta[:,0:21],r[:,0:21],vardens_plt[:,0:21],cmap=plt.cm.jet)
         ax.set_theta_zero_location("N")
         ax.set_theta_direction("clockwise")

      # --- Write output to file -----------------------------------------------
      # HS
      s = str(ipart+1).rjust(6)+'                                                                     System number\n'
      with open(fname_hs,'a') as f:                  # append to file
         f.write(s)
      s = str(np.count_nonzero(~np.isnan(par))).rjust(6)+\
         '                                                                     Number of points in system\n'
      with open(fname_hs,'a') as f:                  # append to file
         f.write(s)
      par_ma = ma.array(par,mask=np.isnan(par),fill_value=excp_hs)
      array2cols(np.flipud(par_ma),fname_hs,nlon)

      # DIR
      s = str(ipart+1).rjust(6)+'                                                                     System number\n'
      with open(fname_dr,'a') as f:                  # append to file
         f.write(s)
      s = str(np.count_nonzero(~np.isnan(par3))).rjust(6)+\
         '                                                                     Number of points in system\n'
      with open(fname_dr,'a') as f:                  # append to file
         f.write(s)
      par3ma = ma.array(par3,mask=np.isnan(par3),fill_value=excp_dr)
      array2cols(np.flipud(par3ma),fname_dr,nlon)

      # TP
      s = str(ipart+1).rjust(6)+'                                                                     System number\n'
      with open(fname_tp,'a') as f:                  # append to file
         f.write(s)
      s = str(np.count_nonzero(~np.isnan(par2))).rjust(6)+\
         '                                                                     Number of points in system\n'
      with open(fname_tp,'a') as f:                  # append to file
         f.write(s)
      par2ma = ma.array(par2,mask=np.isnan(par2),fill_value=excp_tp)
      array2cols(np.flipud(par2ma),fname_tp,nlon)

      # PNT
      for iloc in range(0, nloc):
         ma_filled = par_ma.filled()
         hs_pnt[iloc,ipart] = ma_filled[pntlat_ind1[iloc],pntlon_ind1[iloc]]
         ma_filled = par2ma.filled()
         tp_pnt[iloc,ipart] = ma_filled[pntlat_ind1[iloc],pntlon_ind1[iloc]]
         ma_filled = par3ma.filled()
         dr_pnt[iloc,ipart] = ma_filled[pntlat_ind1[iloc],pntlon_ind1[iloc]]

      # ------------------------------------------------------------------------

   # Write all partitions to PNT (point output file)
   for iloc in range(0, nloc):
        data = []
        data = np.append(data,pntlon[iloc])
        data = np.append(data,pntlat[iloc])
        data = np.append(data,hs_pnt[iloc,:])
        data = np.append(data,tp_pnt[iloc,:])
        data = np.append(data,dr_pnt[iloc,:])
        data = np.resize(data,(1,32))                  # expand to new size
        s = StringIO()                                 # create internal file
        np.savetxt(s,data,fmt='%14.4f',delimiter='')   # save to internal file
        s2=s.getvalue()
        with open(fname_pnt,'a') as f:                  # append to file
           f.write(s2)

   if (plot_output) & (fhour % 3 == 0):   
      date = datetime.datetime.fromtimestamp(itime) 
      figtitle = 'NWPS Wave Systems: Top: Hs (ft) and Dir; Bottom: Tp (s) and Dir \n'\
                  +'Hour '+str(fhour)+' ('+str(date.hour).zfill(2)+'Z'+str(date.day).zfill(2)\
                  +monthstr[int(date.month)-1]+str(date.year)+')'+', SC = '+("%4.2f" % silhouette_best)\
                  +' ('+("%4.2f" % silhouette_spl)+'/'+str(ngrpspl)+')\n'\
                  +'*** EXPERIMENTAL - NOT FOR OPERATIONAL USE ***' 
      plt.suptitle(figtitle,fontsize=18)

      filenm = 'swan_systrk1_hr'+str(fhour).zfill(3)+'.png'
      plt.savefig(filenm,dpi=150,bbox_inches='tight',pad_inches=0.1)
      plt.clf()

# Write output file with wave system stats
ofilenm = wfo+'_'+datetime.datetime.fromtimestamp(startdate).strftime('%Y%m%d.%H%M%S')+'.sys'
text_file = open(ofilenm, "w")
outstring = str(startdate)+' '+str(nclust_best)+' '+("%6.3f" % silhouette_best)\
                          +' '+str(ngrpspl)+' '+("%6.3f" % silhouette_spl)+("%6.3f" % placemnt_coef)+'\n'
text_file.write("%s" % outstring)
text_file.close()


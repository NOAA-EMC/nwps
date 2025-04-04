#!/usr/bin/env python
import cartopy
import cartopy.crs as ccrs
import cartopy.feature as cfeature
import sys
import os
import matplotlib
#matplotlib.use('Agg',warn=False)
import time
import datetime
import numpy as np
import numpy.ma as ma
import matplotlib.pyplot as plt
from matplotlib.colors import BoundaryNorm
import math
#from mpl_toolkits.basemap import Basemap
from io import StringIO

from sklearn import cluster
from sklearn.neighbors import kneighbors_graph
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import silhouette_score
from scipy.interpolate import interp1d

print
print('                   *** WAVEWATCH III Wave system tracking ***  ')
print('               ===============================================')
print

NWPSdir = os.environ['NWPSdir']
cartopy.config['pre_existing_data_dir'] = NWPSdir+'/lib/cartopy'
print('Reading cartopy shapefiles from:')
print(cartopy.config['pre_existing_data_dir'])
# Parameters
monthstr = ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC']
wfo = sys.argv[1]
core = int(sys.argv[2])
plot_output = True

# Define buoy and fracwet based on wfo
wfo_dict = {
    'bro': ('42020', 0.7368),
    'crp': ('42019', 0.5043),
    'hgx': ('42019', 0.5751),
    'lch': ('42035', 0.8328),
    'lix': ('42040', 0.8447),
    'mob': ('42040', 0.7528),
    'tae': ('42039', 0.7052),
    'tbw': ('42036', 0.7159),
    'mfl': ('41114', 0.7703),
    'key': ('GSTRM', 0.9120),
    'mlb': ('41009', 0.7416),
    'jax': ('41112', 0.8252),
    'sju': ('41053', 0.9255),
    'chs': ('41004', 0.7009),
    'ilm': ('41013', 0.5599),
    'mhx': ('41025', 0.5868),
    'akq': ('44093', 0.5187),
    'lwx': ('44062', 0.2647),
    'phi': ('44091', 0.5663),
    'okx': ('44025', 0.7183),
    'box': ('44018', 0.6663),
    'gyx': ('44032', 0.5136),
    'car': ('44034', 0.7279),
    'sew': ('46041', 0.5482),
    'pqr': ('46248', 0.7504),
    'mfr': ('46015', 0.8301),
    'eka': ('46213', 0.7865),
    'mtr': ('46012', 0.7008),
    'lox': ('46069', 0.6416),
    'sgx': ('46086', 0.6348),
    'hfo': ('51003', 0.9614),
    'gum': ('52202', 1.00),
    'gua': ('52202', 0.9874),
    'ajk': ('46085', 0.6384),
    'aer': ('46080', 0.6473),
    'alu': ('46073', 0.7692),
    'afg': ('48114', 0.1568),
}

if wfo in wfo_dict:
    buoy, fracwet = wfo_dict[wfo]
else:
    print(f"Invalid wfo: {wfo}")
    sys.exit(1)

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

def hs_agg(hs_gr):
        return 4.*np.sqrt( np.sum( np.square(hs_gr/4.) ) )

def tp_agg(hs_gr,tp_gr):
        return np.dot(tp_gr, np.square(hs_gr/4.))/np.sum( np.square(hs_gr/4.) )

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
   startdate = int(time.mktime(time.strptime(date_time, pattern))) + core*dt*24
   #enddate = startdate + dt*(nt-1)
   if core < 5:
      enddate = startdate + dt*23
   else:
      enddate = startdate + dt*24
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
          #vardens[fhour,ifreq,0:(ndir-1)] = line.split()
          vardens[fhour, ifreq, 0:(ndir - 1)] = [float(x.strip().replace('****', 'nan')) if wfo == 'bro' else float(x.strip()) for x in line.split()]
      vardens[fhour,:,:] = float(factor)*np.asarray(vardens[fhour,:,:])
      vardens[fhour,:,(ndir-1)] = vardens[fhour,:,0]
      vardens[fhour,0,:] = np.zeros(ndir)
      #print('variance density:')
      #print(vardens[fhour,:,:])
      #vardens[vardens < 100.*float(factor)] = np.nan
      if wfo == 'bro':
      # Interpolation
          for ifreq in range(1, nfreq):
              for idir in range(ndir - 1):
                  if np.isnan(vardens[fhour, ifreq, idir]):
                      non_nan_indices = np.where(~np.isnan(vardens[fhour, ifreq, :ndir - 1]))[0]
                      if len(non_nan_indices) > 1:
                          interp_func = interp1d(non_nan_indices, vardens[fhour, ifreq, non_nan_indices], kind='linear', fill_value="extrapolate")
                          vardens[fhour, ifreq, idir] = interp_func(idir)


# Format zeniths/azimuths
r, theta = np.meshgrid(zeniths, azimuths)
#print(r)
#print(theta)

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
# Test optimal number of clusters (between 2-5)

for nclust in range(2, 6):
   try:
      silhouette_avg=np.loadtxt('silhouette_coeff_k'+str(nclust)+'.txt')
   except:            
      silhouette_avg=0.
      print('*** Warning: No valid silhouette coefficient found for k='+str(nclust))
   print('k='+str(nclust)+': silhouette coeff = '+str(silhouette_avg))
   if silhouette_avg > silhouette_best:
      silhouette_best = silhouette_avg
      nclust_best = nclust

print('nclust_best = ',nclust_best)
print('silhouette_best = ',silhouette_best)

k_means = cluster.KMeans(n_clusters=nclust_best, random_state=1)
k_means.fit(wavedat)
label_best=k_means.labels_.astype(np.float)
#--------------------------------

lons=np.linspace(x0,x0+float(nlon-1)*dx,num=nlon)
lats=np.linspace(y0,y0+float(nlat-1)*dy,num=nlat)
reflon,reflat=np.meshgrid(lons,lats)
#print(lons)
#print(lats)

# Write coordinate output file
if core==0:
   #Clean old output file before writing new one
   fname_coords = "SYS_COORD.OUT"
   if os.path.isfile(fname_coords):
      os.remove(fname_coords)
   # Header info
   s = str(nlat).rjust(6)+'                                                                     Number of rows\n'
   with open(fname_coords,'a') as f:                  # append to file
       f.write(s)
   s = str(nlon).rjust(6)+'                                                                     Number of cols\n'
   with open(fname_coords,'a') as f:                  # append to file
       f.write(s)

   s = np.array2string(lons, max_line_width=1400, formatter={'float_kind':lambda x: '%6.2f' % x})
   with open(fname_coords,'a') as f:                  # append to file
       f.write(' Longitude =\n')
       for row in range(nlat):
          f.write(' '+s[1:-1]+'\n')

   with open(fname_coords,'a') as f:                  # append to file
       f.write(' Latitude =\n')
       for row in reversed(range(nlat)):
          s = np.array2string(np.repeat(lats[row], nlon), max_line_width=1400, formatter={'float_kind':lambda x: '%6.2f' % x})
          f.write(' '+s[1:-1]+'\n')

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

fname_hs = 'SYS_HSIGN.OUT-'+str(core).zfill(3)
excp_hs = 9999.00
fname_dr = 'SYS_DIR.OUT-'+str(core).zfill(3)
excp_dr = 9999.00
fname_tp = 'SYS_TP.OUT-'+str(core).zfill(3)
excp_tp = 9999.00
fname_pnt = 'SYS_PNT.OUT-'+str(core).zfill(3)
excp_pnt = 9999.00

#HS
#Clean old output file before writing new one
if os.path.isfile(fname_hs):
   os.remove(fname_hs)
# Header info
if core==0:
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
if core==0:
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
if core==0:
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
if core==0:
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

bulfilenm = wfo+'_nwps_CG0_Trkng_'+datetime.datetime.fromtimestamp(startdate).strftime('%Y%m%d')+'_'\
            +datetime.datetime.fromtimestamp(startdate).strftime('%H%M')+'.bull-'+str(core).zfill(3)
bul_file = open(bulfilenm, "w")
if core==0:
   bul_file.write("%s" % '  Location : '+wfo.upper()+' domain spatial average\n')
   bul_file.write("%s" % '  Model    : Cluster-based wave system tracking\n')
   bul_file.write("%s" % '  Cycle    : '+datetime.datetime.fromtimestamp(startdate).strftime('%Y%m%d')\
                      +' '+datetime.datetime.fromtimestamp(startdate).strftime('%H')+' UTC\n')
   bul_file.write("%s" % ' +-------+-----------+--------------------+--------------------+--------------------+--------------------+--------------------+\n')
   bul_file.write("%s" % ' | day & |  Hst  n x |   Hs   Tp  dir Cov |   Hs   Tp  dir Cov |   Hs   Tp  dir Cov |   Hs   Tp  dir Cov |   Hs   Tp  dir Cov |\n')
   bul_file.write("%s" % ' |  hour |  (m)  - - |   (m)  (s) (d) (pc)|   (m)  (s) (d) (pc)|   (m)  (s) (d) (pc)|   (m)  (s) (d) (pc)|   (m)  (s) (d) (pc)|\n')
   bul_file.write("%s" % ' +-------+-----------+--------------------+--------------------+--------------------+--------------------+--------------------+\n')

#AWfhour = -3*dt/3600
#fhour = -1*dt/3600
fhour = (core*24-1)*dt/3600
#AWfor itime in range(startdate, (enddate+3*dt), 3*dt):

hsmax_all = convfac*np.max(wavedat2[:,3])
print('Hs_max overall:',("%5.2f" % hsmax_all))

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

   hs_part = excp_pnt*np.ones(5)
   tp_part = excp_pnt*np.ones(5)
   dir_part = excp_pnt*np.ones(5)
   cover_part = excp_pnt*np.ones(5)

   if (plot_output) & (fhour % 3 == 0):
      fig, axarr = plt.subplots(nrows=4, ncols=3, figsize=(16,13), constrained_layout=False,
                          subplot_kw={'projection': ccrs.PlateCarree()})
      #fig.tight_layout()
      axlist = axarr.flatten()

   for ipart in range(0, nclust_best):
      #print('Wave system:',(ipart+1))
      labelindex = np.where(label_best == ipart)[0]
      partfield = wavedat2[ labelindex, ]

      #hsmax = convfac*np.max(partfield[:,3])
      hsmax = hsmax_all

      dateindex = np.where(partfield[:,0] == float(timestr))[0]
      partfield2 = partfield[ dateindex, ]

      # Create a matrices of nlat x nlon initialized to 0
      #tic = time.time()
      par = np.zeros((nlat, nlon))
      par.fill(np.nan)
      par2 = np.zeros((nlat, nlon))
      par2.fill(np.nan)
      par3 = np.zeros((nlat, nlon))
      par3.fill(np.nan)
      #toc = time.time()
      #print('Time to create matrices:')
      #print(toc-tic)

      #tic = time.time()
      # Set up parameter field
      for ilat in range(0, nlat):
         llind_lat = np.where(partfield2[:,6]==ilat)[0]
         for ilon in range(0, nlon):
            llind = llind_lat[ np.where(partfield2[llind_lat,7]==ilon)[0] ]
            if llind.size > 1:
               par[ilat,ilon] = hs_agg(partfield2[llind,3])
               par2[ilat,ilon] = tp_agg(partfield2[llind,3],partfield2[llind,4])
               par3[ilat,ilon] = partfield2[min(llind),5]
            elif llind.size:
               par[ilat,ilon] = partfield2[llind,3]
               par2[ilat,ilon] = partfield2[llind,4]
               par3[ilat,ilon] = partfield2[llind,5]
      print('Sys, Hs, Tp, Dir:',(ipart+1),("%5.2f" % np.nanmean(par)),("%5.2f" % np.nanmean(par2)),("%6.2f" % np.nanmean(par3)))
      #toc = time.time()
      #print('Time to interpolate parameter field (5):')
      #print(toc-tic)

      par3ma = ma.masked_where(par3==-9999, par3)
      u=ma.cos(3.1416/180*(270-par3ma))
      v=ma.sin(3.1416/180*(270-par3ma))

      # --- Plot output in separate panels per cluster (every 3 hours) ---------
      #tic = time.time()
      if (plot_output) & (fhour % 3 == 0):      
         x=reflon-360.
         y=reflat
         xspc=spclon-360.
         yspc=spclat

         if ipart < 3:
            plotloc = ipart
         else:
            plotloc = ipart+3         

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

         if len(clevs) > 256:
             clevs = np.linspace(clevs.min(), clevs.max(), 256)
         norm = BoundaryNorm(clevs, ncolors=plt.cm.jet.N, clip=True)
         cf = axlist[plotloc].pcolormesh(x,y,convfac*np.asarray(par),cmap=plt.cm.jet, norm=norm, transform=ccrs.PlateCarree())
         cb = fig.colorbar(cf, ax=axlist[plotloc])
         cb.set_label('System '+str(ipart+1)+': Hs (ft)', size=9)
         axlist[plotloc].plot(xspc,yspc,'k+',markersize=10,markeredgewidth=2,transform=ccrs.PlateCarree())
         rowskip=int(np.floor(par3.shape[0]/20))
         colskip=int(np.floor(par3.shape[1]/20))
         print(rowskip)
         print(colskip)
         axlist[plotloc].quiver(x[0::rowskip,0::colskip],y[0::rowskip,0::colskip],\
             u[0::rowskip,0::colskip],v[0::rowskip,0::colskip], \
             color='black',pivot='middle',scale=6.,width=0.015,units='inches',transform=ccrs.PlateCarree())
         #axlist[plotloc].coastlines(resolution='10m', color='black', linewidth=1)
         coast = cfeature.GSHHSFeature(scale='high',edgecolor='black',facecolor=cfeature.COLORS['land'])
         axlist[plotloc].add_feature(coast)
         axlist[plotloc].set_extent([lons.min()-360.,lons.max()-360., lats.min(), lats.max()])
         gl = axlist[plotloc].gridlines(crs=ccrs.PlateCarree(), draw_labels=True,
                  linewidth=0.5, color='gray', alpha=0.5, linestyle='--')
         gl.xlabels_top = False
         gl.ylabels_right = False
         gl.xlabel_style = {'size': 7}
         gl.ylabel_style = {'size': 7}

         clevs2 = np.arange(0, 30+1)
         norm = BoundaryNorm(clevs2, ncolors=plt.cm.jet.N, clip=True)
         cf = axlist[plotloc+3].pcolormesh(x,y,par2,cmap=plt.cm.jet, norm=norm, transform=ccrs.PlateCarree())
         cb = fig.colorbar(cf, ax=axlist[plotloc+3])
         cb.set_label('System '+str(ipart+1)+': Tp (s)', size=9)
         axlist[plotloc+3].plot(xspc,yspc,'k+',markersize=10,markeredgewidth=2)
         rowskip=int(np.floor(par3.shape[0]/20))
         colskip=int(np.floor(par3.shape[1]/20))
         print(rowskip)
         print(colskip)
         axlist[plotloc+3].quiver(x[0::rowskip,0::colskip],y[0::rowskip,0::colskip],\
             u[0::rowskip,0::colskip],v[0::rowskip,0::colskip], \
             color='black',pivot='middle',scale=6.,width=0.015,units='inches',transform=ccrs.PlateCarree())
         #axlist[plotloc+3].coastlines(resolution='10m', color='black', linewidth=1)
         coast = cfeature.GSHHSFeature(scale='high',edgecolor='black',facecolor=cfeature.COLORS['land'])
         axlist[plotloc+3].add_feature(coast)
         axlist[plotloc+3].set_extent([lons.min()-360.,lons.max()-360., lats.min(), lats.max()])
         gl = axlist[plotloc+3].gridlines(crs=ccrs.PlateCarree(), draw_labels=True,
                  linewidth=0.5, color='gray', alpha=0.5, linestyle='--')
         gl.xlabels_top = False
         gl.ylabels_right = False
         gl.xlabel_style = {'size': 7}
         gl.ylabel_style = {'size': 7}

         # Plot 2d wave spectrum
         vardens_plt = vardens[fhour,:,:]  
         vardens_plt = np.transpose(vardens_plt)
         vardens_plt = np.log10(np.maximum(vardens_plt,1e-09))
         vardens_plt[vardens_plt==np.log10(1e-09)] = np.NaN
         cmap=plt.cm.jet
         cmap.set_bad("white")
         ax2 = fig.add_subplot(4, 3, 9, projection='polar')
         ax2.contourf(theta[:,0:21],r[:,0:21],vardens_plt[:,0:21],cmap=cmap)
         ax2.set_theta_zero_location("N")
         ax2.set_theta_direction("clockwise")
      #toc = time.time()
      #print('Time to plot fields:')
      #print(toc-tic)

      # --- Write output to file -----------------------------------------------
      #tic = time.time()
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

      hs_part[ipart] = np.nanmean(par)
      tp_part[ipart] = np.nanmean(par2)
      dir_part[ipart] = np.nanmean(par3)
      cover_part[ipart] = 100.*( np.count_nonzero(~np.isnan(par)) / (fracwet*nlat*nlon) )
      #toc = time.time()
      #print('Time to plot wave systems:')
      #print(toc-tic)

   # Write all partitions to PNT (point output file)
   #tic = time.time()
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
   #toc = time.time()
   #print('Time to write to PNT output file:')
   #print(toc-tic)

   # Remove panels for unused wave systems
   if (plot_output) & (fhour % 3 == 0): 
      for plotloc in range(nclust_best, 6):
         if plotloc < 3: 
            axlist[plotloc].outline_patch.set_visible(False)
            axlist[plotloc+3].outline_patch.set_visible(False)
         else:
            axlist[plotloc+3].outline_patch.set_visible(False)
            axlist[plotloc+6].outline_patch.set_visible(False)

   if (plot_output) & (fhour % 3 == 0):   
      date = datetime.datetime.fromtimestamp(itime) 
      figtitle = 'NWPS Wave Systems: Top: Hs (ft) and Dir; Bottom: Tp (s) and Dir \n'\
                  +'Hour '+str(fhour)+' ('+str(date.hour).zfill(2)+'Z'+str(date.day).zfill(2)\
                  +monthstr[int(date.month)-1]+str(date.year)+')'+', SC = '+("%4.2f" % silhouette_best)
      fig.suptitle(figtitle,fontsize=18)

      filenm = 'swan_systrk1_hr'+str(fhour).zfill(3)+'.png'
      fig.savefig(filenm,dpi=150,bbox_inches='tight',pad_inches=0.1)
      #fig.clf()

# Write bulletin output, format:
#
#  Location : SGX domain spatial average
#  Model    : Cluster-based wave system tracking
#  Cycle    : 20190509 12 UTC
# +-------+-----------+-----------------+-----------------+-----------------+-----------------+-----------------+-----------------+
# | day & |  Hst  n x |    Hs   Tp  dir |    Hs   Tp  dir |    Hs   Tp  dir |    Hs   Tp  dir |    Hs   Tp  dir |    Hs   Tp  dir |
# |  hour |  (m)  - - |    (m)  (s) (d) |    (m)  (s) (d) |    (m)  (s) (d) |    (m)  (s) (d) |    (m)  (s) (d) |    (m)  (s) (d) |
# +-------+-----------+-----------------+-----------------+-----------------+-----------------+-----------------+-----------------+
# |  1 15 | 1.86  3   |   1.81 10.5   8 |   0.35 15.3   6 |   0.22 17.8   3 |                 |                 |                 |
# |  1 16 | 1.84  3   |   1.79 10.4   8 |   0.36 15.3   7 |   0.22 17.8   3 |                 |                 |                 |
# |  1 17 | 1.82  3   |   1.77 10.4   8 |   0.36 15.2   6 |   0.22 17.8   3 |                 |                 |                 |
# |  1 18 | 1.80  3   |   1.75 10.3   7 |   0.35 15.1   7 |   0.25 17.8   2 |                 |                 |                 |

   hs_part_str = ['      ','      ','      ','      ','      ']
   tp_part_str = ['     ','     ','     ','     ','     ']
   dir_part_str = ['    ','    ','    ','    ','    ']
   cover_part_str = ['    ','    ','    ','    ','    ']

   hst_sqr = 0.
   nsystems = 0
   for ipart in range(0, nclust_best):
       #if not np.isnan(hs_part[ipart]):
       if cover_part[ipart] > 5.0:
           hs_part_str[ipart] = ("%6.2f" % hs_part[ipart])
           tp_part_str[ipart] = ("%5.1f" % tp_part[ipart])
           dir_part_str[ipart] = ("%4.0f" % dir_part[ipart])
           cover_part_str[ipart] = ("%4.0f" % cover_part[ipart])
           hst_sqr += hs_part[ipart]**2
           nsystems += 1
   hst_str = ("%5.2f" % np.sqrt(hst_sqr))

   hrly_date = datetime.datetime.fromtimestamp(itime)
   outstring = ' | '+str(hrly_date.day).zfill(2)+' '+str(hrly_date.hour).zfill(2)+' |'+hst_str+'  '+str(nsystems)+'   |'\
               +hs_part_str[0]+tp_part_str[0]+dir_part_str[0]+cover_part_str[0]+' |'\
               +hs_part_str[1]+tp_part_str[1]+dir_part_str[1]+cover_part_str[1]+' |'\
               +hs_part_str[2]+tp_part_str[2]+dir_part_str[2]+cover_part_str[2]+' |'\
               +hs_part_str[3]+tp_part_str[3]+dir_part_str[3]+cover_part_str[3]+' |'\
               +hs_part_str[4]+tp_part_str[4]+dir_part_str[4]+cover_part_str[4]+' |\n'
   bul_file.write("%s" % outstring)

if core==5:
   bul_file.write("%s" % ' +-------+-----------+--------------------+--------------------+--------------------+--------------------+--------------------+\n')
bul_file.close()

# Write output file with wave system stats
#AW20200206 ofilenm = wfo+'_'+datetime.datetime.fromtimestamp(startdate).strftime('%Y%m%d.%H%M%S')+'.sys'
#AW20200206 text_file = open(ofilenm, "w")
#AW20200206 outstring = str(startdate)+' '+str(nclust_best)+' '+("%6.3f" % silhouette_best)\
#AW20200206                           +' '+str(ngrpspl)+' '+("%6.3f" % silhouette_spl)+("%6.3f" % placemnt_coef)+'\n'
#AW20200206 text_file.write("%s" % outstring)
#AW20200206 text_file.close()


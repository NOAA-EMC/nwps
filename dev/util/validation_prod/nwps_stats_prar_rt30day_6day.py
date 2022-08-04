import matplotlib
matplotlib.use('Agg',warn=False)  # Use this to run Matplotlib in the background and avoid issues with the X-Server

import sys
import os
import os.path
import re
import numpy as np
from scipy.linalg import norm
#from datetime import datetime
import datetime
from datetime import timedelta, date
from netCDF4 import Dataset, num2date
import matplotlib.pyplot as plt
import matplotlib.dates as mdate
from scipy.interpolate import interp1d

# global vars
COMOUT = os.environ.get('COMOUT')
workdir = os.environ.get('workdir')

TDEF = 35
TDEF = 145

wfos=['hfo','hfo','hfo','hfo','hfo','gum','gum',
      'aer','aer','aer','aer','aer','alu','alu','ajk','ajk']
wfobuoys=['51206',
          '51205',
          '51203',
          '51201',
          '51003',
          '52200',
          '52211',
          '46001',
          '46080',
          '46076',
          '46061',
          '46108',
          '46073',
          '46075',
          '46085',
          '46083']

# Comprehensions
obstim = [[0 for x in range(30000)] for x in range(len(wfobuoys))]
obspar = [[0 for x in range(30000)] for x in range(len(wfobuoys))]
obswnd = [[0 for x in range(30000)] for x in range(len(wfobuoys))]

varname = []
bcycle = [0 for x in range(len(wfobuoys))]

def read_ndbc(buoy,vname,startDate,stopDate):

     print 'processing',buoy
     url='http://dods.ndbc.noaa.gov/thredds/dodsC/data/stdmet/'+str(buoy)+'/'+str(buoy)+'h9999.nc'
     #url='http://dods.ndbc.noaa.gov/thredds/dodsC/data/stdmet/'+str(buoy)+'/'+str(buoy)+'h2015.nc'  # Monthly QAed values

     try:
          nco = Dataset(url)
          times = nco.variables['time'][:]
          h = nco.variables['wave_height'][:]
     except:
          print 'skipping', buoy
          times = []
          h = []

     #jd = num2date(times,times.units)
     return (times, h)

def daterange(start_date, end_date):
     for n in range(int((end_date - start_date).days)+1):
        yield start_date + timedelta(n)

# ----------- Main routine starts here -------------
#if __name__ == '__main__':

print 'Made it to here'

command = 'cd '+workdir
os.system(command)
command = 'date'
os.system(command)
command = 'pwd'
os.system(command)

#Get analysis dates from shell
tmp1 = os.environ.get('STARTDATE')
tmp2 = os.environ.get('ENDDATE')

startDate=datetime.datetime(int(tmp1[0:4]),int(tmp1[4:6]),int(tmp1[6:8]))
stopDate=datetime.datetime(int(tmp2[0:4]),int(tmp2[4:6]),int(tmp2[6:8]))

print '-------- In nwps_stat_prar_rt30day.py ---------'
print 'Computing NWPS statistics:'
print 'startDate = '+startDate.strftime("%Y/%m/%d")
print 'stopDate = '+stopDate.strftime("%Y/%m/%d")
print ''

vname = 'wave_height'
ibuoy = 0

# Fetch and read NDBC buoy observations
print 'Fetching realtime NDBC buoy obs...'
for buoy in wfobuoys:
     times, h = read_ndbc(buoy,vname,startDate,stopDate)
     if (len(h) != 0):
        #Read obs (incl. any NaNs) as a masked array
        obstim_withnans = times[:]
        obspar_withnans = h[:,0,0]
        #Filter out any small (erroneous) obs and replace with NaNs
        for tstep in range(len(obspar_withnans)):
           if obspar_withnans[tstep]<0.05:
              obspar_withnans[tstep]=np.nan
        #Filter out the NaNs (masked values in ma) using the mask in opspar_withnans
        obspar[ibuoy][:] = obspar_withnans[np.ma.nonzero(obspar_withnans)]
        obstim[ibuoy][:] = obstim_withnans[np.ma.nonzero(obspar_withnans)]
     else:
        obspar[ibuoy][:] = []
        obstim[ibuoy][:] = [] 
     #print obspar[ibuoy][:]
     #print obstim[ibuoy][:]
     #print len(obspar[ibuoy][:])
     ibuoy = ibuoy+1

##plt.figure()
## See: http://stackoverflow.com/questions/23294197/plotting-chart-with-epoch-time-x-axis-using-matplotlib
#fig, ax = plt.subplots()
#
## Plot the date using plot_date rather than plot.
## mdate.epoch2num converts epoch timestamps to the right format for matplotlib
#ax.plot_date(mdate.epoch2num(obstim[0][:]), obspar[0][:], 'b-o', markeredgecolor='b',markersize=1)
#ax.plot_date(mdate.epoch2num(obstim[1][:]), obspar[1][:], 'r-o', markeredgecolor='r',markersize=1)
##date_fmt = '%d-%m-%y %H:%M'  # Choose your xtick format string
#date_formatter = mdate.DateFormatter('%m/%d')  # Use a DateFormatter to set the data to the correct format.
#ax.xaxis.set_major_formatter(date_formatter)  # Use a DateFormatter to set the data to the correct format.
#fig.autofmt_xdate()
#ax.set_xlim([startDate, stopDate])
##ax.set_ylim([0, 10])
#
#fig.suptitle('NDBC Observations')
#plt.xlabel('Time (UTC)')
#plt.ylabel('Hs (m)')
#
#filenm = 'ndbc.png'
#plt.savefig(filenm,dpi=150,bbox_inches='tight',pad_inches=0.1)
#plt.clf()

# ------- Extract NWPS data at NDBC locations ----------

#timestamp=$(date -d "yesterday" +%Y%m%d)
#timestamp='20151006'
#timestamp='20150927'

wfos=['hfo','hfo','hfo','hfo','hfo','gum','gum',
      'aer','aer','aer','aer','aer','alu','alu','ajk','ajk']
regions=['pr','pr','pr','pr','pr','pr','pr',
         'ar','ar','ar','ar','ar','ar','ar','ar','ar']
wfobuoys=['51206',
          '51205',
          '51203',
          '51201',
          '51003',
          '52200',
          '52211',
          '46001',
          '46080',
          '46076',
          '46061',
          '46108',
          '46073',
          '46075',
          '46085',
          '46083']
wfobuoycoors=['205.032 19.781',
              '203.575 21.018',
              '202.990 20.788',
              '201.880 21.669',
              '199.431 19.289',
              '144.788 13.354',
              '145.662 15.267',
              '212.080 56.304',
              '210.040 57.939',
              '212.010 59.502',
              '213.166 60.227',
              '208.183 59.590',
              '187.999 55.031',
              '199.194 53.911',
              '217.506 55.868',
              '222.003 58.300']

cycles=['00','03','06','09','12','15','18','21']
varname=['HTSGW','PERPW','DIRPW','WIND']

obs_fcast_array_24hr = []
obs_fcast_array_48hr = []
obs_fcast_array_72hr = []
obs_fcast_array_96hr = []
obs_fcast_array_120hr = []
obs_fcast_array_144hr = []

mod_fcast_array_24hr = []
mod_fcast_array_48hr = []
mod_fcast_array_72hr = []
mod_fcast_array_96hr = []
mod_fcast_array_120hr = []
mod_fcast_array_144hr = []

for single_date in daterange(startDate,stopDate):

   # Comprehensions
   modpar = [[0 for x in range(TDEF)] for x in range(len(wfos))]
   modtim = [[0 for x in range(TDEF)] for x in range(len(wfos))]

   timestamp = single_date.strftime("%Y%m%d")
   print ''
   print 'Analysing '+timestamp+'...'

   for iwfo in range(len(wfos)):
      print ''
      wfo=wfos[iwfo]
      iwfobuoy=iwfo
      wfobuoy=wfobuoys[iwfobuoy]
      region=regions[iwfobuoy]
      CGextract='CG1'
      print 'Extracting '+region+'.'+timestamp+'/'+wfo+', buoy '+wfobuoy+', on '+CGextract+':'

      for cycle in cycles:
         print 'Checking cycle '+cycle
         extdir=COMOUT+region+'.'+timestamp+'/'+wfo+'/'+cycle+'/'+CGextract+'/'
         infile=wfo+'_nwps_'+CGextract+'_'+timestamp+'_'+cycle+'00.grib2'

         if os.path.isfile(extdir+infile):
            if (os.stat(extdir+infile).st_size !=0):
               print 'Data found. Extracting at buoy locations...'
               command = 'cp '+extdir+infile+' '+workdir
               os.system(command)

               command = '$WGRIB2 '+workdir+infile+'  -match "'+varname[0]+'" -lon '+wfobuoycoors[iwfobuoy]+'  > '+wfo+'_'+wfobuoy+'_'+varname[0]+'_'+timestamp+'_'+cycle+'00.pnt'
               os.system(command)
               #command = '$WGRIB2 '+workdir+infile+'  -match "'+varname[3]+'" -lon '+wfobuoycoors[iwfobuoy]+'  > '+wfo+'_'+wfobuoy+'_'+varname[3]+'_'+timestamp+'_'+cycle+'00.pnt'
               #os.system(command)
               command = 'rm '+workdir+infile
               os.system(command)

               break

# ---------- Read NWPS model data into buoy-centered arrays ----------

   for iwfo in range(len(wfos)):
   #for ibuoy in range(len(allBuoys)):
      print ''
      wfo=wfos[iwfo]
      print 'Reading pnt data from '+region+'.'+timestamp+'/'+wfo+':'

      #for iwfobuoy in range(len(wfobuoys[iwfo][:])):
      iwfobuoy=iwfo
      wfobuoy=wfobuoys[iwfobuoy]
      #wfobuoy=allBuoys[ibuoy]
      datafound = 'false'

      for cycle in cycles:
         if datafound == 'true':
            continue
         print 'Search for '+wfobuoy+' cycle '+cycle 
         infile = wfo+'_'+wfobuoy+'_'+varname[0]+'_'+timestamp+'_'+cycle+'00.pnt'
         if os.path.isfile(infile):
            if (os.stat(infile).st_size !=0):
               print 'Reading file '+infile
               datafound = 'true'
               fo = open(workdir+infile, "r")
               for tstep in range(TDEF):
                  #print tstep*3
                  line = fo.readline()
                  linesplit = [s for s in re.split(r',val=', line) if s]
                  modpar[iwfobuoy][tstep] = float(linesplit[1])
                  date = datetime.datetime(int(timestamp[0:4]),int(timestamp[4:6]),int(timestamp[6:8]),int(cycle))
                  # Add the forecast hour to the start of the cycle timestamp
                  #date = date + datetime.timedelta(hours=(tstep*3))
                  date = date + datetime.timedelta(hours=(tstep))
                  modtim[iwfobuoy][tstep] = (date-datetime.datetime(1970,1,1)).total_seconds()
                  bcycle[iwfobuoy] = cycle
                  # Remove SWAN exception values
                  if (modpar[iwfobuoy][tstep]<0.05) or (modpar[iwfobuoy][tstep] == 9.999e+20):
                     modpar[iwfobuoy][tstep]=np.nan
               fo.close()
               command = 'rm '+workdir+infile
               os.system(command)
         else:
            continue
      if (datafound == 'false'):
         print ' *** Warning: no model data found'
         for tstep in range(TDEF):
            modpar[iwfobuoy][tstep] = np.nan
            modtim[iwfobuoy][tstep] = np.nan
         bcycle[iwfobuoy] = '00'   # Reset the cycle if no data is found
      #modpar(find(modpar==0.)) = NaN;

      # ---------- Interpolate obeservational and model time series to daily values, for comparison ----------
      refdate = datetime.datetime(int(timestamp[0:4]),int(timestamp[4:6]),int(timestamp[6:8])).strftime('%s')
      synpdate = datetime.datetime(int(timestamp[0:4]),int(timestamp[4:6]),int(timestamp[6:8]),int(bcycle[iwfobuoy])).strftime('%s')

      int_time = np.arange((int(synpdate)+86400),(int(synpdate)+7*86400),86400)
      obs_int_time = []
      mod_int_time = []
      obs_interp = []
      mod_interp = []

      if (len(obspar[iwfobuoy][:]) != 0) & (len(modpar[iwfobuoy][:]) != 0):
         obs_int_time = np.arange((int(synpdate)+86400),(int(synpdate)+7*86400),86400)
         obs_interp = np.interp(obs_int_time, obstim[iwfobuoy][:], obspar[iwfobuoy][:])
         obs_fcast_array_24hr.append( obs_interp[0] )
         obs_fcast_array_48hr.append( obs_interp[1] )
         obs_fcast_array_72hr.append( obs_interp[2] )
         obs_fcast_array_96hr.append( obs_interp[3] )
         obs_fcast_array_120hr.append( obs_interp[4] )
         obs_fcast_array_144hr.append( obs_interp[5] )

         mod_int_time = np.arange((int(synpdate)+86400),(int(synpdate)+7*86400),86400)
         mod_interp = np.interp(mod_int_time, modtim[iwfobuoy][:], modpar[iwfobuoy][:])
         mod_fcast_array_24hr.append( mod_interp[0] )
         mod_fcast_array_48hr.append( mod_interp[1] )
         mod_fcast_array_72hr.append( mod_interp[2] )
         mod_fcast_array_96hr.append( mod_interp[3] )
         mod_fcast_array_120hr.append( mod_interp[4] )
         mod_fcast_array_144hr.append( mod_interp[5] )

      pltflag = False
      if (pltflag):
         print 'Plotting time series for '+wfo+'...'
         fig, ax = plt.subplots()
         ax.plot_date(mdate.epoch2num(modtim[iwfobuoy][:]), modpar[iwfobuoy][:], 'b-o', markeredgecolor='b',markersize=2)
         ax.plot_date(mdate.epoch2num(obstim[iwfobuoy][:]), obspar[iwfobuoy][:], 'r-o', markeredgecolor='r',markersize=2)
         ax.plot_date(mdate.epoch2num(int_time), mod_interp, 'bo', markeredgecolor='b',markersize=5)
         ax.plot_date(mdate.epoch2num(int_time), obs_interp, 'ro', markeredgecolor='b',markersize=5)
         date_formatter = mdate.DateFormatter('%m/%d')  # Use a DateFormatter to set the data to the correct format.
         ax.xaxis.set_major_formatter(date_formatter)  # Use a DateFormatter to set the data to the correct format.
         fig.autofmt_xdate()
         ax.set_xlim([startDate, stopDate])
         #ax.set_ylim([0, 10])
      
         fig.suptitle('NWPS: '+wfo+' '+timestamp+'_'+bcycle[iwfobuoy]+'Z')
         plt.xlabel('Time (UTC)')
         plt.ylabel('Hs (m)')
      
         filenm = wfo+'_'+wfobuoy+'_'+timestamp+'_'+bcycle[iwfobuoy]+'_ts.png'
         plt.savefig(filenm,dpi=150,bbox_inches='tight',pad_inches=0.1)
         plt.clf()

      print mod_interp
      print obs_interp

# ---- Compute overall stats and make scatter plot

bs_array = [0 for x in np.arange(1,8)]
si_array = [0 for x in np.arange(1,8)]
n_array = [0 for x in np.arange(1,8)]

plt.figure(figsize=(11,7))
for ipanel in np.arange(1,7):
   ax = plt.subplot(2, 3, ipanel, aspect='equal')
   if ipanel == 1:
      model = mod_fcast_array_24hr;
      observ = obs_fcast_array_24hr;
      figtitle = '24h fcst';
   elif ipanel == 2:
      model = mod_fcast_array_48hr;
      observ = obs_fcast_array_48hr;
      figtitle = '48h fcst';
   elif ipanel == 3:
      model = mod_fcast_array_72hr;
      observ = obs_fcast_array_72hr;
      figtitle = '72h fcst';
   elif ipanel == 4:
      model = mod_fcast_array_96hr;
      observ = obs_fcast_array_96hr;
      figtitle = '96h fcst';
   elif ipanel == 5:
      model = mod_fcast_array_120hr;
      observ = obs_fcast_array_120hr;
      figtitle = '120h fcst';
   elif ipanel == 6:
      model = mod_fcast_array_144hr;
      observ = obs_fcast_array_144hr;
      figtitle = '144h fcst';

   # Compute stats
   temp = np.subtract(model,observ)
   temp = temp[~np.isnan(temp)]
   observ = np.subtract(observ,0)   # Do this in order to correctly remove the nans:
   model = np.subtract(model,0)   # Do this in order to correctly remove the nans:
   observ_nonan = observ[~np.isnan(observ)]
   model_nonan = model[~np.isnan(model)]
   mn = np.mean(observ_nonan)
   relbias = np.mean(temp)/mn
   rms = np.linalg.norm(temp,2)/np.sqrt(len(temp))
   si = rms/mn;

   biasstr = "Rel. bias = %6.3f"% (relbias)
   sistr = "SI = %6.3f"% (si)
   nstr = 'N = '+str(len(temp))

   print ''
   print '--- Final stats for '+figtitle+' ('+startDate.strftime("%Y/%m/%d")+'-'+stopDate.strftime("%Y/%m/%d")+'):'
   print biasstr
   print sistr
   print nstr

   bs_array[ipanel] = "%6.3f"% (relbias)
   si_array[ipanel] = "%6.3f"% (si)
   n_array[ipanel] = str(len(temp))

   ascale = np.ceil( np.amax( [np.amax(observ_nonan),np.amax(model_nonan)] ) )

   plt.plot(observ,model,'ko', markeredgecolor='k',markersize=1)
   plt.plot(range(int(ascale)+1),range(int(ascale)+1),'k:')
   plt.text(0.07, 0.90, biasstr, fontsize=10, transform = ax.transAxes)
   plt.text(0.07, 0.80, sistr, fontsize=10, transform = ax.transAxes)
   plt.text(0.07, 0.70, nstr, fontsize=10, transform = ax.transAxes)  
   plt.tick_params(axis='both', which='major', labelsize=8)
   #plt.title(figtitle)
   plt.text(0.6, 0.1, figtitle, transform = ax.transAxes)
   if (ipanel == 4) |(ipanel == 5) | (ipanel == 6):
      plt.xlabel('Hs,obs (m)', fontsize=10)
   if (ipanel == 1) | (ipanel == 4):
      plt.ylabel('Hs,mod (m)', fontsize=10)

plt.suptitle('NWPS PR/AR: NDBC buoy validation for '+startDate.strftime("%Y/%m/%d")+'-'+stopDate.strftime("%Y/%m/%d"))
filenm = 'nwps_'+timestamp+'_prar_scatter_retro.png'
plt.savefig(workdir+filenm,dpi=150,bbox_inches='tight',pad_inches=0.1)
plt.clf()

# Write output stats file
ofilenm = 'nwps_val_stats_prar_'+timestamp+'.dat'
outstring = timestamp+' '+bs_array[1]+' '+bs_array[2]+' '+bs_array[3]+' '+bs_array[4]+' '+si_array[1]+' '+si_array[2]+' '+si_array[3]+' '+si_array[4]+' '+n_array[1]+' '+n_array[2]+' '+n_array[3]+' '+n_array[4]+' '+bs_array[5]+' '+bs_array[6]+' '+si_array[5]+' '+si_array[6]+' '+n_array[5]+' '+n_array[6]+'\n'
text_file = open(ofilenm, "w")
text_file.write("%s" % outstring)
text_file.close()

print '-------- Exiting nwps_stat_prar_rt30day.py ---------'
print ''

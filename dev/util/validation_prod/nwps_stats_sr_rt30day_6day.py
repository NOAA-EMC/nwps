import matplotlib
#matplotlib.use('Agg',warn=False)  # Use this to run Matplotlib in the background and avoid issues with the X-Server

import sys
import os
import os.path
import re
import numpy as np
from scipy.linalg import norm
import datetime
from datetime import timedelta, date
from netCDF4 import Dataset, num2date
import matplotlib.pyplot as plt
import matplotlib.dates as mdate
from scipy.interpolate import interp1d

# global vars
COMOUT = os.environ.get('COMOUT')
workdir = os.environ.get('workdir')

#TDEF = 35
TDEF = 145

wfos=['bro','crp','hgx','hgx','lch','lix','mob','mob','mob','tae','tae','tbw','mfl','mlb','mlb','mlb','jax','jax',
      'sju','sju','sju','sju']
wfobuoys=['42020',
          '42020',
          '42019',
          '42035',
          '42035',
          '42040',
          '42040',
          '42012',
          '42039',
          '42039',
          '42036',
          '42036',
          '41114',
          '41114',
          '41009',
          '41113',
          '41112',
          '41008',
          '41053',
          '41115',
          '42085',
          '41056',]

wfos=['bro','crp','hgx','hgx','lch','lix','mob','mob','mob','tae','tae','tbw','mlb','jax','jax',
      'sju','sju','sju','sju']
wfobuoys=['42020',
          '42020',
          '42019',
          '42035',
          '42035',
          '42040',
          '42040',
          '42012',
          '42039',
          '42039',
          '42036',
          '42036',
          '41113',
          '41112',
          '41008',
          '41053',
          '41115',
          '42085',
          '41056',]

wfos=['bro','crp','hgx','hgx','lch','lix','mob','mob','mob','tae','tae','tbw','mlb','jax','jax']
wfobuoys=['42020',
          '42020',
          '42019',
          '42035',
          '42035',
          '42040',
          '42040',
          '42012',
          '42039',
          '42039',
          '42036',
          '42036',
          '41113',
          '41112',
          '41008']

# Comprehensions
obstim = [[0 for x in range(30000)] for x in range(len(wfobuoys))]
obspar = [[0 for x in range(30000)] for x in range(len(wfobuoys))]
obswnd = [[0 for x in range(30000)] for x in range(len(wfobuoys))]

varname = []
bcycle = [0 for x in range(len(wfobuoys))]


def process_archived_buoy_data(date_to_process, base_path='/lfs/h2/emc/vpppg/noscrub/emc.vpppg/verification/global/archive/obs_data/ndbc_buoy'):
    """
    Grabs the daily tar file, creates a dated subdirectory, extracts files there,
    and cleans up the subdirectory.

    Args:
        date_to_process (datetime): The date for which to process the data.
        base_path (str): The base directory for the archive.

    Returns:
        bool: True if extraction was successful, False otherwise.
    """

    # 1. Construct file paths and local directory name
    date_str = date_to_process.strftime('%Y%m%d')
    tar_filename = f'buoy_{date_str}.tar'
    full_tar_path = os.path.join(base_path, tar_filename)

    # Create a dated directory for extraction
    extract_dir = f'ndbc_buoy_data_{date_str}'
    os.makedirs(extract_dir, exist_ok=True)

    print(f"Attempting to process data for date: {date_str}")
    print(f"Extraction target directory: {extract_dir}")

    success = False

    # 2. Extract the archive
    try:
        if not os.path.exists(full_tar_path):
             print(f"❌ ERROR: Archive file not found at {full_tar_path}")
             return False

        # Extract the tar file into the newly created directory
        with tarfile.open(full_tar_path) as tar:
            tar.extractall(path=extract_dir)
            print(f"✅ Successfully extracted {tar_filename} into {extract_dir}")

        success = True # Set success flag if extraction completes without error

    except tarfile.TarError as e:
        print(f"❌ ERROR: Failed to extract tar file {tar_filename}: {e}")
    except Exception as e:
        print(f"❌ An unexpected error occurred: {e}")

    # 3. Cleanup (Remove the entire dated directory)
    try:
        # Use shutil.rmtree to recursively remove the directory and its contents
        shutil.rmtree(extract_dir)
        print(f"🧹 Cleaned up extracted directory: {extract_dir}")
    except Exception as e:
        # Note: If extraction failed, the directory might be empty, but we ensure it's removed.
        print(f"Warning: Failed to remove directory {extract_dir}: {e}")

    # 4. Return simplified result
    return success

def read_ndbc(filename, start_date=None, end_date=None):
    """
    Reads time and wave height data from a single local NDBC-style file (e.g., buoy.txt),
    filtering data points to be within the specified date range.

    Args:
        filename (str): The path to the local data file.
        start_date (datetime, optional): The beginning of the desired time window (inclusive).
        end_date (datetime, optional): The end of the desired time window (inclusive).

    Returns:
        tuple: A tuple (times, wave_heights) containing filtered datetime objects
               and corresponding NumPy array of wave heights.
    """
    print(f'Processing file: {filename}')

    if not os.path.exists(filename):
        print(f'Skipping - File not found: {filename}')
        return ([], [])

    filtered_times = []
    filtered_wave_heights = []

    try:
        with open(filename, 'r') as f:
            # Skip the header lines (start with '#')
            data_lines = [line for line in f if not line.startswith('#')]

            for line in data_lines:
                parts = line.split()
                if len(parts) < 9:
                    continue

                # 1. Parse Date/Time components and create datetime object (dt)
                try:
                    year = int(parts[0])
                    month = int(parts[1])
                    day = int(parts[2])
                    hour = int(parts[3])
                    minute = int(parts[4])

                    #dt = datetime(year, month, day, hour, minute)
                    dt = datetime.datetime(year, month, day, hour, minute)
                except ValueError:
                    # Skip line if date format is invalid
                    continue

                # 🌟 2. Apply Date Filtering 🌟
                # Only proceed if dt falls within the specified range (inclusive).
                # If start_date/end_date are None, the conditions are ignored.
                date_check = True
                if start_date and dt < start_date:
                    date_check = False
                if end_date and dt > end_date:
                    date_check = False

                if date_check:
                    # 3. Parse Wave Height (WVHT)
                    wvht_str = parts[8]
                    if wvht_str == 'MM':
                        wave_val = np.nan
                    else:
                        try:
                            wave_val = float(wvht_str)
                        except ValueError:
                            wave_val = np.nan

                    # 4. Add filtered data to results
                    filtered_times.append(dt)
                    filtered_wave_heights.append(wave_val)

    except Exception as e:
        print(f'Error reading data from {filename}: {e}')
        return ([], [])

    if filtered_times:
        # Use a list comprehension to call the .timestamp() method on each datetime object
        # This converts the times to floating-point seconds since 1970-01-01 00:00:00 UTC.
        unix_times = [dt.timestamp() for dt in filtered_times]
    else:
        unix_times = []

    # 5. Return UNIX timestamps and NumPy array of wave heights
    return (unix_times, np.array(filtered_wave_heights))

def daterange(start_date, end_date):
     for n in range(int((end_date - start_date).days)+1):
        yield start_date + timedelta(n)

# ----------- Main routine starts here -------------
#if __name__ == '__main__':

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

print ('-------- In nwps_stat_sr_rt30day.py ---------')
print ('Computing NWPS statistics:')
print ('startDate = '+startDate.strftime("%Y/%m/%d"))
print ('stopDate = '+stopDate.strftime("%Y/%m/%d"))
print ('')

vname = 'wave_height'
ibuoy = 0

# Fetch and read NDBC buoy observations
print('Fetching realtime NDBC buoy obs...')
for buoy in wfobuoys:
     buoy_filename = f'{buoy}.txt'

    #  Create the full path to the file
    # Example: 'ndbc_buoy_data_20251116/46025.txt'
     date_str = stopDate.strftime('%Y%m%d')
     extract_dir = f'/lfs/h2/emc/vpppg/noscrub/emc.vpppg/verification/global/archive/obs_data/ndbc_buoy/{date_str}'
     full_file_path = os.path.join(extract_dir, buoy_filename)

    # 3. Read the data using the full path and date filters
    # Note: We assume your read_ndbc signature is now: read_ndbc(filename, start_date, end_date)
     print(f"Reading data for Buoy {buoy} from {full_file_path}")
     times, h = read_ndbc(full_file_path, startDate, stopDate)
     if (len(h) != 0):
        #Read obs (incl. any NaNs) as a masked array
        obstim_withnans = np.array(times)
        #obstim_withnans = times[:]
        obspar_withnans = h[:]
        #Filter out any small (erroneous) obs and replace with NaNs
        obspar_withnans[obspar_withnans < 0.05] = np.nan
        valid_mask = ~np.isnan(obspar_withnans)

        obspar_valid = obspar_withnans[valid_mask]
        obstim_valid = obstim_withnans[valid_mask]
        #Filter out the NaNs (masked values in ma) using the mask in opspar_withnans

        obspar[ibuoy] = obspar_valid
        obstim[ibuoy] = obstim_valid
     else:
        # Use NumPy arrays for empty data consistency
        obspar[ibuoy] = np.array([])
        obstim[ibuoy] = np.array([])
     #print(obspar[ibuoy]) # Note: Removed [:] slice here
     #print(obstim[ibuoy]) # Note: Removed [:] slice here
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

wfos=['bro','crp','hgx','hgx','lch','lix','mob','mob','mob','tae','tae','tbw','mfl','mlb','mlb','mlb','jax','jax',
      'sju','sju','sju','sju']
regions=['sr','sr','sr','sr','sr','sr','sr','sr','sr','sr','sr','sr','sr','sr','sr','sr','sr','sr',
         'sr','sr','sr','sr']
wfobuoys=['42020',
          '42020',
          '42019',
          '42035',
          '42035',
          '42040',
          '42040',
          '42012',
          '42039',
          '42039',
          '42036',
          '42036',
          '41114',
          '41114',
          '41009',
          '41113',
          '41112',
          '41008',
          '41053',
          '41115',
          '42085',
          '41056',]
wfobuoycoors=['263.306 26.968',
              '263.306 26.968',
              '264.647 27.907',
              '265.587 29.232',
              '265.587 29.232',
              '271.793 29.212',
              '271.793 29.212',
              '272.445 30.065',
              '273.994 28.739',
              '273.994 28.739',
              '275.483 28.500',
              '275.483 28.500',
              '279.780 27.551',
              '279.780 27.551',
              '279.812 28.522',
              '279.467 28.400',
              '278.708 30.709',
              '279.132 31.400',
              '293.901 18.474',
              '292.720 18.376',
              '293.476 17.860',
              '294.543 18.259'];

wfos=['bro','crp','hgx','hgx','lch','lix','mob','mob','mob','tae','tae','tbw','mlb','jax','jax',
      'sju','sju','sju','sju']
regions=['sr','sr','sr','sr','sr','sr','sr','sr','sr','sr','sr','sr','sr','sr','sr',
         'sr','sr','sr','sr']
wfobuoys=['42020',
          '42020',
          '42019',
          '42035',
          '42035',
          '42040',
          '42040',
          '42012',
          '42039',
          '42039',
          '42036',
          '42036',
          '41113',
          '41112',
          '41008',
          '41053',
          '41115',
          '42085',
          '41056',]
wfobuoycoors=['263.306 26.968',
              '263.306 26.968',
              '264.647 27.907',
              '265.587 29.232',
              '265.587 29.232',
              '271.793 29.212',
              '271.793 29.212',
              '272.445 30.065',
              '273.994 28.739',
              '273.994 28.739',
              '275.483 28.500',
              '275.483 28.500',
              '279.467 28.400',
              '278.708 30.709',
              '279.132 31.400',
              '293.901 18.474',
              '292.720 18.376',
              '293.476 17.860',
              '294.543 18.259'];

wfos=['bro','crp','hgx','hgx','lch','lix','mob','mob','mob','tae','tae','tbw','mlb','jax','jax']
regions=['sr','sr','sr','sr','sr','sr','sr','sr','sr','sr','sr','sr','sr','sr','sr']
wfobuoys=['42020',
          '42020',
          '42019',
          '42035',
          '42035',
          '42040',
          '42040',
          '42012',
          '42039',
          '42039',
          '42036',
          '42036',
          '41113',
          '41112',
          '41008']
wfobuoycoors=['263.306 26.968',
              '263.306 26.968',
              '264.647 27.907',
              '265.587 29.232',
              '265.587 29.232',
              '271.793 29.212',
              '271.793 29.212',
              '272.445 30.065',
              '273.994 28.739',
              '273.994 28.739',
              '275.483 28.500',
              '275.483 28.500',
              '279.467 28.400',
              '278.708 30.709',
              '279.132 31.400']

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
   print ('')
   print ('Analysing '+timestamp+'...')

   for iwfo in range(len(wfos)):
      print ('')
      wfo=wfos[iwfo]
      iwfobuoy=iwfo
      wfobuoy=wfobuoys[iwfobuoy]
      region=regions[iwfobuoy]
      CGextract='CG1'
      print ('Extracting '+region+'.'+timestamp+'/'+wfo+', buoy '+wfobuoy+', on '+CGextract+':')

      for cycle in cycles:
         print ('Checking cycle '+cycle)
         extdir=COMOUT+region+'.'+timestamp+'/'+wfo+'/'+cycle+'/'+CGextract+'/'
         infile=wfo+'_nwps_'+CGextract+'_'+timestamp+'_'+cycle+'00.grib2'

         if os.path.isfile(extdir+infile):
            if (os.stat(extdir+infile).st_size !=0):
               print ('Data found. Extracting at buoy locations...')
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
      print ('')
      wfo=wfos[iwfo]
      print ('Reading pnt data from '+region+'.'+timestamp+'/'+wfo+':')

      #for iwfobuoy in range(len(wfobuoys[iwfo][:])):
      iwfobuoy=iwfo
      wfobuoy=wfobuoys[iwfobuoy]
      #wfobuoy=allBuoys[ibuoy]
      datafound = 'false'

      for cycle in cycles:
         if datafound == 'true':
            continue
         print ('Search for '+wfobuoy+' cycle '+cycle)
         infile = wfo+'_'+wfobuoy+'_'+varname[0]+'_'+timestamp+'_'+cycle+'00.pnt'
         if (os.path.isfile(infile)):
            if (os.stat(infile).st_size > 0):
               print ('Reading file '+infile)
               datafound = 'true'
               fo = open(workdir+infile, "r")
               for tstep in range(TDEF):
               #print(tstep*3)
                  line = fo.readline()
                  linesplit = [s for s in re.split(r',val=', line) if s]
                  modpar[iwfobuoy][tstep] = float(linesplit[1])
                  date = datetime.datetime(int(timestamp[0:4]),int(timestamp[4:6]),int(timestamp[6:8]),int(cycle))
                  # Add the forecast hour to the start of the cycle timestamp
                  #date = date + datetime.timedelta(hours=(tstep*3))
                  date = date + datetime.timedelta(hours=(tstep))
                  mod_unix_time = (date - datetime.datetime(1970,1,1)).total_seconds()
                  #modtim[iwfobuoy][tstep] = (date-datetime.datetime(1970,1,1)).total_seconds()
                  bcycle[iwfobuoy] = cycle
                  modtim[iwfobuoy][tstep] = mod_unix_time
                  readable_date = datetime.datetime.fromtimestamp(mod_unix_time).strftime('%Y-%m-%d %H:%M:%S UTC')

                  # Print the model time for the current forecast step
                  #print(f"  [Time Check] Fstep {tstep}:")
                  #print(f"    - Datetime: {readable_date}")
                  #print(f"    - Unix (seconds): {mod_unix_time:.0f}") # Print as integer for cleaner look
                  # Remove SWAN exception values
                  if (modpar[iwfobuoy][tstep]<0.05) or (modpar[iwfobuoy][tstep] == 9.999e+20):
                      modpar[iwfobuoy][tstep]=np.nan
               fo.close()
               command = 'rm '+workdir+infile
               os.system(command)
         else:
            continue
      if (datafound == 'false'):
         print (' *** Warning: no model data found')
         for tstep in range(TDEF):
            modpar[iwfobuoy][tstep] = np.nan
            modtim[iwfobuoy][tstep] = np.nan
         bcycle[iwfobuoy] = '00'   # Reset the cycle if no data is found
      #modpar(find(modpar==0.)) = NaN;

      # ---------- Interpolate obeservational and model time series to daily values, for comparison ----------
      refdate = datetime.datetime(int(timestamp[0:4]),int(timestamp[4:6]),int(timestamp[6:8])).strftime('%s')
      synpdate = datetime.datetime(int(timestamp[0:4]),int(timestamp[4:6]),int(timestamp[6:8]),int(bcycle[iwfobuoy])).strftime('%s')

      #int_time = np.arange((int(synpdate)+86400),(int(synpdate)+5*86400),86400)
      obs_int_time = []
      mod_int_time = []
      obs_interp = []
      mod_interp = []

      if (len(obspar[iwfobuoy][:]) != 0) & (len(modpar[iwfobuoy][:]) != 0):
         obs_int_time = np.arange((int(synpdate)+86400),(int(synpdate)+7*86400),86400)
         obs_interp = np.interp(
                 obs_int_time,
                 obstim[iwfobuoy][:], # x-coordinates (Observed Times)
                 obspar[iwfobuoy][:], # f(x) values (Observed Wave Heights)
                 left=np.nan,         # Use NaN for target times before the first observation
                 right=np.nan         # Use NaN for target times after the last observation
                 )         
         obs_fcast_array_24hr.append( obs_interp[0] )
         obs_fcast_array_48hr.append( obs_interp[1] )
         obs_fcast_array_72hr.append( obs_interp[2] )
         obs_fcast_array_96hr.append( obs_interp[3] )
         obs_fcast_array_120hr.append( obs_interp[4] )
         obs_fcast_array_144hr.append( obs_interp[5] )

         mod_int_time = np.arange((int(synpdate)+86400),(int(synpdate)+7*86400),86400)
         mod_interp = np.interp(mod_int_time, modtim[iwfobuoy][:], modpar[iwfobuoy][:])
         if (mod_interp[0] > 3.):
            mod_interp[0] = np.nan
         if (mod_interp[1] > 3.):
            mod_interp[1] = np.nan
         if (mod_interp[2] > 3.):
            mod_interp[2] = np.nan
         if (mod_interp[3] > 3.):
            mod_interp[3] = np.nan
         mod_fcast_array_24hr.append( mod_interp[0] )
         mod_fcast_array_48hr.append( mod_interp[1] )
         mod_fcast_array_72hr.append( mod_interp[2] )
         mod_fcast_array_96hr.append( mod_interp[3] )
         mod_fcast_array_120hr.append( mod_interp[4] )
         mod_fcast_array_144hr.append( mod_interp[5] )

      pltflag = False
      if (pltflag):
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

   print ('')
   print ('--- Final stats for '+figtitle+' ('+startDate.strftime("%Y/%m/%d")+'-'+stopDate.strftime("%Y/%m/%d")+'):')
   print (biasstr)
   print (sistr)
   print (nstr)

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

plt.suptitle('NWPS SR: NDBC buoy validation for '+startDate.strftime("%Y/%m/%d")+'-'+stopDate.strftime("%Y/%m/%d"))
filenm = 'nwps_'+timestamp+'_sr_scatter.png'
plt.savefig(workdir+filenm,dpi=150,bbox_inches='tight',pad_inches=0.1)
plt.clf()

# Write output stats file
ofilenm = 'nwps_val_stats_sr_'+timestamp+'.dat'
outstring = timestamp+' '+bs_array[1]+' '+bs_array[2]+' '+bs_array[3]+' '+bs_array[4]+' '+si_array[1]+' '+si_array[2]+' '+si_array[3]+' '+si_array[4]+' '+n_array[1]+' '+n_array[2]+' '+n_array[3]+' '+n_array[4]+' '+bs_array[5]+' '+bs_array[6]+' '+si_array[5]+' '+si_array[6]+' '+n_array[5]+' '+n_array[6]+'\n'
text_file = open(ofilenm, "w")
text_file.write("%s" % outstring)
text_file.close()

print ('-------- Exiting nwps_stat_sr_rt30day.py ---------')
print ('')


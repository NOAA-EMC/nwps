import matplotlib
#matplotlib.use('Agg',warn=False)  # Use this to run Matplotlib in the background and avoid issues with the X-Server

import sys
import os
import os.path
import re
import numpy as np
from scipy.linalg import norm
#from datetime import datetime
import time
import datetime
from datetime import timedelta, date
from netCDF4 import Dataset, num2date
import matplotlib.pyplot as plt
import matplotlib.dates as mdate
from scipy.interpolate import interp1d
#from sklearn import linear_model

# global vars
COMOUT = os.environ.get('COMOUT')
workdir = os.environ.get('workdir')

#TDEF = 35
TDEF = 145
NDBCextract = sys.argv[1]
CGextract = sys.argv[2]

if NDBCextract == '42020':
   wfos=['bro']
   wfobuoys=['42020']
   wfobuoycoors=['263.306 26.968']
#if NDBCextract == 'crp':
#   wfos=['crp'] 
#   wfobuoys=['42020']
#   wfobuoycoors=['263.306 26.968']
if NDBCextract == '42019':
   wfos=['hgx']
   wfobuoys=['42019']
   wfobuoycoors=['264.647 27.907']
if NDBCextract == '42035':
   wfos=['lch']
   wfobuoys=['42035']
   wfobuoycoors=['265.587 29.232']
if NDBCextract == '42040':
   wfos=['lix']
   wfobuoys=['42040']
   wfobuoycoors=['271.793 29.212']
if NDBCextract == '42012':
   wfos=['mob']
   wfobuoys=['42012']
   wfobuoycoors=['272.445 30.065']
if NDBCextract == '42039':
   wfos=['tae']
   wfobuoys=['42039']
   wfobuoycoors=['273.994 28.739']
if NDBCextract == '42036':
   wfos=['tae']
   wfobuoys=['42036']
   wfobuoycoors=['275.483 28.500']
if NDBCextract == '42023':
   wfos=['mfl']
   wfobuoys=['42023']
   wfobuoycoors=['276.926 26.064']
if NDBCextract == '41114':
   wfos=['mfl']
   wfobuoys=['41114']
   wfobuoycoors=['279.780 27.551']
if NDBCextract == '41009':
   wfos=['mlb']
   wfobuoys=['41009']
   wfobuoycoors=['279.812 28.522']
if NDBCextract == '41113':
   wfos=['mlb']
   wfobuoys=['41113']
   wfobuoycoors=['279.467 28.400']
if NDBCextract == '41112':
   wfos=['jax']
   wfobuoys=['41112']
   wfobuoycoors=['278.708 30.709']
if NDBCextract == '41008':
   wfos=['jax']
   wfobuoys=['41008']
   wfobuoycoors=['279.132 31.400']
if NDBCextract == '41012':
   wfos=['jax']
   wfobuoys=['41012']
   wfobuoycoors=['279.466 30.042']
if NDBCextract == '41053':
   wfos=['sju']
   wfobuoys=['41053']
   wfobuoycoors=['293.901 18.474']
if NDBCextract == '41115':
   wfos=['sju']
   wfobuoys=['41115']
   wfobuoycoors=['292.720 18.376']
if NDBCextract == '42085':
   wfos=['sju']
   wfobuoys=['42085']
   wfobuoycoors=['293.476 17.860']
if NDBCextract == '41056':
   wfos=['sju']
   wfobuoys=['41056']
   wfobuoycoors=['294.543 18.259']

if NDBCextract == '41008':
   wfos=['chs']
   wfobuoys=['41008']
   wfobuoycoors=['279.132 31.400']
if NDBCextract == '41029':
   wfos=['chs']
   wfobuoys=['41029']
   wfobuoycoors=['280.380 32.800']
if NDBCextract == '41033':
   wfos=['chs']
   wfobuoys=['41033']
   wfobuoycoors=['279.600 32.270']
if NDBCextract == '41004':
   wfos=['chs']
   wfobuoys=['41004']
   wfobuoycoors=['280.901 32.501']
if NDBCextract == '41065':
   wfos=['chs']
   wfobuoys=['41065']
   wfobuoycoors=['280.381 32.802']
if NDBCextract == '41076':
   wfos=['chs']
   wfobuoys=['41076']
   wfobuoycoors=['280.341 32.536']
if NDBCextract == '41013':
   wfos=['ilm']
   wfobuoys=['41013']
   wfobuoycoors=['282.257 33.436']
if NDBCextract == '44095':
   wfos=['mhx']
   wfobuoys=['44095']
   wfobuoycoors=['284.670 35.750']
#if NDBCextract == '41036':
#   wfos=['mhx']
#   wfobuoys=['41036']
#   wfobuoycoors=['283.051 34.207']
if NDBCextract == '41159':
   wfos=['mhx']
   wfobuoys=['41159']
   wfobuoycoors=['283.052 34.210']
if NDBCextract == '41025':
   wfos=['mhx']
   wfobuoys=['41025']
   wfobuoycoors=['284.598 35.006']
if NDBCextract == '44056':
   wfos=['mhx']
   wfobuoys=['44056']
   wfobuoycoors=['284.286 36.200']
if NDBCextract == '44100':
   wfos=['mhx']
   wfobuoys=['44100']
   wfobuoycoors=['284.409 36.255']
if NDBCextract == '44014':
   wfos=['akq']
   wfobuoys=['44014']
   wfobuoycoors=['285.158 36.611']
if NDBCextract == '44093':
   wfos=['akq']
   wfobuoys=['44093']
   wfobuoycoors=['284.508 36.872']
if NDBCextract == '44096':
   wfos=['akq']
   wfobuoys=['44096']
   wfobuoycoors=['284.190 37.023']
if NDBCextract == '44043':
   wfos=['lwx']
   wfobuoys=['44043']
   wfobuoycoors=['283.609 39.152']
if NDBCextract == 'TPLM2':
   wfos=['lwx']
   wfobuoys=['TPLM2']
   wfobuoycoors=['283.564 38.899']
if NDBCextract == '44062':
   wfos=['lwx']
   wfobuoys=['44062']
   wfobuoycoors=['283.585 38.556']
if NDBCextract == '44042':
   wfos=['lwx']
   wfobuoys=['44042']
   wfobuoycoors=['283.664 38.033']
if NDBCextract == '44058':
   wfos=['lwx']
   wfobuoys=['44058']
   wfobuoycoors=['283.743 37.551']
if NDBCextract == '44009':
   wfos=['phi']
   wfobuoys=['44009']
   wfobuoycoors=['285.297 38.461']
if NDBCextract == '44091':
   wfos=['phi']
   wfobuoys=['44091']
   wfobuoycoors=['286.231 39.778']
if NDBCextract == '44065':
   wfos=['okx']
   wfobuoys=['44065']
   wfobuoycoors=['286.297 40.369']
if NDBCextract == '44094':
   wfos=['okx']
   wfobuoys=['44094']
   wfobuoycoors=['286.894 40.585']
if NDBCextract == '44025':
   wfos=['okx']
   wfobuoys=['44025']
   wfobuoycoors=['286.836 40.251']
if NDBCextract == '44040':
   wfos=['okx']
   wfobuoys=['44040']
   wfobuoycoors=['286.420 40.956']
if NDBCextract == '44039':
   wfos=['okx']
   wfobuoys=['44039']
   wfobuoycoors=['287.345 41.138']
if NDBCextract == '44060':
   wfos=['okx']
   wfobuoys=['44060']
   wfobuoycoors=['287.933 41.263']
if NDBCextract == '44069':
   wfos=['okx']
   wfobuoys=['44069']
   wfobuoycoors=['286.914 40.693']
if NDBCextract == '44017':
   wfos=['box']
   wfobuoys=['44017']
   wfobuoycoors=['287.952 40.694']
if NDBCextract == '44020':
   wfos=['box']
   wfobuoys=['44020']
   wfobuoycoors=['289.813 41.443']
if NDBCextract == '44013':
   wfos=['box']
   wfobuoys=['44013']
   wfobuoycoors=['289.349 42.346']
if NDBCextract == '44018':
   wfos=['box']
   wfobuoys=['44018']
   wfobuoycoors=['290.299 42.121']
if NDBCextract == '44029':
   wfos=['box']
   wfobuoys=['44029']
   wfobuoycoors=['289.434 42.523']
if NDBCextract == '44090':
   wfos=['box']
   wfobuoys=['44090']
   wfobuoycoors=['289.671 41.840']
if NDBCextract == '44098':
   wfos=['box']
   wfobuoys=['44098']
   wfobuoycoors=['289.832 42.798']
if NDBCextract == '44033':
   wfos=['gyx']
   wfobuoys=['44033']
   wfobuoycoors=['291.003 44.056']
if NDBCextract == '44007':
   wfos=['gyx']
   wfobuoys=['44007']
   wfobuoycoors=['289.859 43.525']
if NDBCextract == '44032':
   wfos=['gyx']
   wfobuoys=['44032']
   wfobuoycoors=['290.645 43.716']
if NDBCextract == '44034':
   wfos=['car']
   wfobuoys=['44034']
   wfobuoycoors=['291.891 44.106']
if NDBCextract == '44027':
   wfos=['car']
   wfobuoys=['44027']
   wfobuoycoors=['292.693 44.287']

if NDBCextract == '46206':
   wfos=['sew']
   wfobuoys=['46206']
   wfobuoycoors=['234.002 48.835']
if NDBCextract == '46041':
   wfos=['sew']
   wfobuoys=['46041']
   wfobuoycoors=['235.269 47.353']
if NDBCextract == '46087':
   wfos=['sew']
   wfobuoys=['46087']
   wfobuoycoors=['235.272 48.494']
if NDBCextract == '46088':
   wfos=['sew']
   wfobuoys=['46088']
   wfobuoycoors=['236.835 48.334']
if NDBCextract == '46211':
   wfos=['pqr']
   wfobuoys=['46211']
   wfobuoycoors=['235.756 46.858']
if NDBCextract == '46243':
   wfos=['pqr']
   wfobuoys=['46243']
   wfobuoycoors=['235.871 46.215']
if NDBCextract == '46248':
   wfos=['pqr']
   wfobuoys=['46248']
   wfobuoycoors=['235.355 46.133']
if NDBCextract == '46029':
   wfos=['pqr']
   wfobuoys=['46029']
   wfobuoycoors=['235.486 46.159']
if NDBCextract == '46050':
   wfos=['pqr']
   wfobuoys=['46050']
   wfobuoycoors=['235.474 44.656']
if NDBCextract == '46015':
   wfos=['mfr']
   wfobuoys=['46015']
   wfobuoycoors=['235.168 42.764']
if NDBCextract == '46027':
   wfos=['mfr']
   wfobuoys=['46027']
   wfobuoycoors=['235.619 41.850']
if NDBCextract == '46229':
   wfos=['mfr']
   wfobuoys=['46229']
   wfobuoycoors=['235.451 43.767']
if NDBCextract == '46213':
   wfos=['eka']
   wfobuoys=['46213']
   wfobuoycoors=['235.260 40.300']
if NDBCextract == '46212':
   wfos=['eka']
   wfobuoys=['46212']
   wfobuoycoors=['235.690 40.750']
#if NDBCextract == '46027':
#   wfos=['eka']
#   wfobuoys=['46027']
#   wfobuoycoors=['235.620 41.760']
if NDBCextract == '46014':
   wfos=['eka']
   wfobuoys=['46014']
   wfobuoycoors=['236.030 39.220']
if NDBCextract == '46042':
   wfos=['mtr']
   wfobuoys=['46042']
   wfobuoycoors=['237.531 36.785']
if NDBCextract == '46028':
   wfos=['mtr']
   wfobuoys=['46028']
   wfobuoycoors=['238.116 35.741']
if NDBCextract == '46239':
   wfos=['mtr']
   wfobuoys=['46239']
   wfobuoycoors=['237.898 36.342']
if NDBCextract == '46236':
   wfos=['mtr']
   wfobuoys=['46236']
   wfobuoycoors=['238.053 36.761']
if NDBCextract == '46240':
   wfos=['mtr']
   wfobuoys=['46240']
   wfobuoycoors=['238.093 36.626']
if NDBCextract == '46214':
   wfos=['mtr']
   wfobuoys=['46214']
   wfobuoycoors=['236.531 37.946']
if NDBCextract == '46013':
   wfos=['mtr']
   wfobuoys=['46013']
   wfobuoycoors=['236.699 38.242']
if NDBCextract == '46012':
   wfos=['mtr']
   wfobuoys=['46012']
   wfobuoycoors=['237.119 37.363']
if NDBCextract == '46026':
   wfos=['mtr']
   wfobuoys=['46026']
   wfobuoycoors=['237.161 37.755']
if NDBCextract == '46237':
   wfos=['mtr']
   wfobuoys=['46237']
   wfobuoycoors=['237.366 37.786']
if NDBCextract == '46028':
   wfos=['lox']
   wfobuoys=['46028']
   wfobuoycoors=['238.120 35.740']
if NDBCextract == '46219':
   wfos=['lox']
   wfobuoys=['46219']
   wfobuoycoors=['240.120 33.220']
if NDBCextract == '46069':
   wfos=['lox']
   wfobuoys=['46069']
   wfobuoycoors=['239.790 33.670']
if NDBCextract == '46221':
   wfos=['lox']
   wfobuoys=['46221']
   wfobuoycoors=['241.370 33.860']
if NDBCextract == '46222':
   wfos=['lox']
   wfobuoys=['46222']
   wfobuoycoors=['241.683 33.618']
if NDBCextract == '46253':
   wfos=['lox']
   wfobuoys=['46253']
   wfobuoycoors=['241.816 33.578']
if NDBCextract == '46256':
   wfos=['lox']
   wfobuoys=['46256']
   wfobuoycoors=['241.7993 33.7003']
if NDBCextract == '46011':
   wfos=['lox']
   wfobuoys=['46011']
   wfobuoycoors=['238.981 34.956']
if NDBCextract == '46053':
   wfos=['lox']
   wfobuoys=['46053']
   wfobuoycoors=['240.147 34.252']
if NDBCextract == '46054':
   wfos=['lox']
   wfobuoys=['46054']
   wfobuoycoors=['239.523 34.265']
if NDBCextract == '46025':
   wfos=['lox']
   wfobuoys=['46025']
   wfobuoycoors=['240.947 33.749']
if NDBCextract == '46218':
   wfos=['lox']
   wfobuoys=['46218']
   wfobuoycoors=['239.218 34.454']
if NDBCextract == '46086':
   wfos=['sgx']
   wfobuoys=['46086']
   wfobuoycoors=['241.965 32.491']
if NDBCextract == '46224':
   wfos=['sgx']
   wfobuoys=['46224']
   wfobuoycoors=['242.529 33.179']
if NDBCextract == '46232':
   wfos=['sgx']
   wfobuoys=['46232']
   wfobuoycoors=['242.569 32.530']
if NDBCextract == '46231':
   wfos=['sgx']
   wfobuoys=['46231']
   wfobuoycoors=['242.630 32.747']
if NDBCextract == '46258':
   wfos=['sgx']
   wfobuoys=['46258']
   wfobuoycoors=['242.500 32.750']
if NDBCextract == '46225':
   wfos=['sgx']
   wfobuoys=['46225']
   wfobuoycoors=['242.608 32.930']
if NDBCextract == '46242':
   wfos=['sgx']
   wfobuoys=['46242']
   wfobuoycoors=['242.561 33.220']
if NDBCextract == '46254':
   wfos=['sgx']
   wfobuoys=['46254']
   wfobuoycoors=['242.733 32.868']
if NDBCextract == 'LJPC1':
   wfos=['sgx']
   wfobuoys=['LJPC1']
   wfobuoycoors=['242.743 32.867']

if NDBCextract == '51208':
   wfos=['hfo']
   wfobuoys=['51208']
   wfobuoycoors=['200.430 22.300']
if NDBCextract == '51207':
   wfos=['hfo']
   wfobuoys=['51207']
   wfobuoycoors=['202.248 21.477']
if NDBCextract == '51206':
   wfos=['hfo']
   wfobuoys=['51206']
   wfobuoycoors=['205.032 19.781']
if NDBCextract == '51205':
   wfos=['hfo']
   wfobuoys=['51205']
   wfobuoycoors=['203.575 21.018']
if NDBCextract == '51204':
   wfos=['hfo']
   wfobuoys=['51204']
   wfobuoycoors=['201.876 21.281']
if NDBCextract == '51203':
   wfos=['hfo']
   wfobuoys=['51203']
   wfobuoycoors=['202.990 20.788']
if NDBCextract == '51202':
   wfos=['hfo']
   wfobuoys=['51202']
   wfobuoycoors=['202.321 21.414']
if NDBCextract == '51201':
   wfos=['hfo']
   wfobuoys=['51201']
   wfobuoycoors=['201.880 21.669']
if NDBCextract == '51003':
   wfos=['hfo']
   wfobuoys=['51003']
   wfobuoycoors=['199.431 19.289']
if NDBCextract == 'Kona':
   wfos=['hfo']
   wfobuoys=['Kona']
   wfobuoycoors=['203.820 19.650']
if NDBCextract == 'Isaac':
   wfos=['hfo']
   wfobuoys=['Isaac']
   wfobuoycoors=['205.270 19.410']
if NDBCextract == '52200':
   wfos=['gum']
   wfobuoys=['52200']
   wfobuoycoors=['144.788 13.354']
if NDBCextract == '52211':
   wfos=['gum']
   wfobuoys=['52211']
   wfobuoycoors=['145.662 15.267']
if NDBCextract == 'APRP7':
   wfos=['gum']
   wfobuoys=['APRP7']
   wfobuoycoors=['144.657 13.444']

if NDBCextract == '46001':
   wfos=['aer']
   wfobuoys=['46001']
   wfobuoycoors=['212.080 56.304']
if NDBCextract == '46080':
   wfos=['aer']
   wfobuoys=['46080']
   wfobuoycoors=['210.040 57.939']
if NDBCextract == '46076':
   wfos=['aer']
   wfobuoys=['46076']
   wfobuoycoors=['212.010 59.502']
if NDBCextract == '46082':
   wfos=['aer']
   wfobuoys=['46082']
   wfobuoycoors=['216.608 59.668']
if NDBCextract == '46061':
   wfos=['aer']
   wfobuoys=['46061']
   wfobuoycoors=['213.166 60.227']
if NDBCextract == '46060':
   wfos=['aer']
   wfobuoys=['46060']
   wfobuoycoors=['213.216 60.584']
if NDBCextract == '46108':
   wfos=['aer']
   wfobuoys=['46108']
   wfobuoycoors=['208.183 59.590']
if NDBCextract == '46081':
   wfos=['aer']
   wfobuoys=['46081']
   wfobuoycoors=['211.737 60.799']
if NDBCextract == '46077':
   wfos=['aer']
   wfobuoys=['46077']
   wfobuoycoors=['205.709 57.892']
if NDBCextract == '46066':
   wfos=['alu']
   wfobuoys=['46066']
   wfobuoycoors=['204.953 52.785']
if NDBCextract == '46073':
   wfos=['alu']
   wfobuoys=['46073']
   wfobuoycoors=['187.999 55.031']
if NDBCextract == '46075':
   wfos=['alu']
   wfobuoys=['46075']
   wfobuoycoors=['199.194 53.911']
if NDBCextract == '46085':
   wfos=['ajk']
   wfobuoys=['46085']
   wfobuoycoors=['217.506 55.868']
if NDBCextract == '46083':
   wfos=['ajk']
   wfobuoys=['46083']
   wfobuoycoors=['222.003 58.300']
if NDBCextract == 'FFIA2':
   wfos=['ajk']
   wfobuoys=['FFIA2']
   wfobuoycoors=['226.370 57.272']
if NDBCextract == '48114':
   wfos=['afg']
   wfobuoys=['48114']
   wfobuoycoors=['190.546 65.011']
if NDBCextract == '48012':
   wfos=['afg']
   wfobuoys=['48012']
   wfobuoycoors=['193.929 70.025']
if NDBCextract == '48212':
   wfos=['afg']
   wfobuoys=['48212']
   wfobuoycoors=['209.721 70.874']

# Comprehensions
obstim = [[0 for x in range(30000)] for x in range(len(wfobuoys))]
obspar = [[0 for x in range(30000)] for x in range(len(wfobuoys))]
obswnd = [[0 for x in range(30000)] for x in range(len(wfobuoys))]

varname = []
bcycle = [0 for x in range(len(wfobuoys))]

def read_ndbc(buoy,vname,startDate,stopDateObs):

     print('processing',buoy)
     url='http://dods.ndbc.noaa.gov/thredds/dodsC/data/stdmet/'+str(buoy)+'/'+str(buoy)+'h9999.nc'
     print(url)
     #url='http://dods.ndbc.noaa.gov/thredds/dodsC/data/stdmet/'+str(buoy)+'/'+str(buoy)+'h2015.nc'  # Monthly QAed values

     startindx = -999
     stopindx = -999
     try:
          nco = Dataset(url)

          print('Data range:')
          print(time.strftime('%Y/%m/%d %H:%M:%S', time.localtime(nco.variables['time'][0]))+' (index 0) to')
          print(time.strftime('%Y/%m/%d %H:%M:%S', time.localtime(nco.variables['time'][-1]))+' (index '+str(len(nco.variables['time'][:]))+')')
          for index, item in enumerate(nco.variables['time'][:]):
             if int(item) > int(startDate.strftime('%s')):
                startindx = index
                break
          for index, item in enumerate(nco.variables['time'][:]):
             if int(item) > int(stopDateObs.strftime('%s')):
                stopindx = index
                break
          if (startindx != -999) & (stopindx != -999):
             print('Found startDate '+startDate.strftime("%Y/%m/%d")+' at index '+str(startindx))
             print('Found stopDateObs '+stopDateObs.strftime("%Y/%m/%d")+' at index '+str(stopindx))
             times = nco.variables['time'][startindx:stopindx]
             h = nco.variables['wave_height'][startindx:stopindx]
          else:
             times = []
             h = []
             print('*** Warning: no observation data found in analysis range')
     except:
          print('*** Warning: no observation data found. Skipping', buoy)
          times = []
          h = []

     #jd = num2date(times,times.units)
     return (times, h)

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

startDate = datetime.datetime(int(tmp1[0:4]),int(tmp1[4:6]),int(tmp1[6:8]))
stopDate = datetime.datetime(int(tmp2[0:4]),int(tmp2[4:6]),int(tmp2[6:8]))
stopDateObs = stopDate + datetime.timedelta(days=4)

print('-------- In nwps_stat_ndbc_rt30day.py ---------')
print('Computing NWPS statistics for NDBC '+NDBCextract.upper()+':')
print('startDate = '+startDate.strftime("%Y/%m/%d"))
print('stopDate = '+stopDate.strftime("%Y/%m/%d"))
print('stopDateObs = '+stopDateObs.strftime("%Y/%m/%d"))
print('')

vname = 'wave_height'
ibuoy = 0

# Fetch and read NDBC buoy observations
print('Fetching realtime NDBC buoy obs...')
for buoy in wfobuoys:
     times, h = read_ndbc(buoy,vname,startDate,stopDateObs)
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
     #print(obspar[ibuoy][:])
     #print(obstim[ibuoy][:])
     #print(len(obspar[ibuoy][:]))
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

if NDBCextract == '42020':
   wfos=['bro']
   region='sr'
   wfobuoys=['42020']
   wfobuoycoors=['263.306 26.968']
#if NDBCextract == 'crp':
#   wfos=['crp'] 
#   wfobuoys=['42020']
#   wfobuoycoors=['263.306 26.968']
if NDBCextract == '42019':
   wfos=['hgx']
   region='sr'
   wfobuoys=['42019']
   wfobuoycoors=['264.647 27.907']
if NDBCextract == '42035':
   wfos=['lch']
   region='sr'
   wfobuoys=['42035']
   wfobuoycoors=['265.587 29.232']
if NDBCextract == '42040':
   wfos=['lix']
   region='sr'
   wfobuoys=['42040']
   wfobuoycoors=['271.793 29.212']
if NDBCextract == '42012':
   wfos=['mob']
   region='sr'
   wfobuoys=['42012']
   wfobuoycoors=['272.445 30.065']
if NDBCextract == '42039':
   wfos=['tae']
   region='sr'
   wfobuoys=['42039']
   wfobuoycoors=['273.994 28.739']
if NDBCextract == '42036':
   wfos=['tae']
   region='sr'
   wfobuoys=['42036']
   wfobuoycoors=['275.483 28.500']
if NDBCextract == '42023':
   wfos=['mfl']
   region='sr'
   wfobuoys=['42023']
   wfobuoycoors=['276.926 26.064']
if NDBCextract == '41114':
   wfos=['mfl']
   region='sr'
   wfobuoys=['41114']
   wfobuoycoors=['279.780 27.551']
if NDBCextract == '41009':
   wfos=['mlb']
   region='sr'
   wfobuoys=['41009']
   wfobuoycoors=['279.812 28.522']
if NDBCextract == '41113':
   wfos=['mlb']
   region='sr'
   wfobuoys=['41113']
   wfobuoycoors=['279.467 28.400']
if NDBCextract == '41112':
   wfos=['jax']
   region='sr'
   wfobuoys=['41112']
   wfobuoycoors=['278.708 30.709']
if NDBCextract == '41008':
   wfos=['jax']
   region='sr'
   wfobuoys=['41008']
   wfobuoycoors=['279.132 31.400']
if NDBCextract == '41012':
   wfos=['jax']
   region='sr'
   wfobuoys=['41012']
   wfobuoycoors=['279.466 30.042']
if NDBCextract == '41053':
   wfos=['sju']
   region='sr'
   wfobuoys=['41053']
   wfobuoycoors=['293.901 18.474']
if NDBCextract == '41115':
   wfos=['sju']
   region='sr'
   wfobuoys=['41115']
   wfobuoycoors=['292.720 18.376']
if NDBCextract == '42085':
   wfos=['sju']
   region='sr'
   wfobuoys=['42085']
   wfobuoycoors=['293.476 17.860']
if NDBCextract == '41056':
   wfos=['sju']
   region='sr'
   wfobuoys=['41056']
   wfobuoycoors=['294.543 18.259']

if NDBCextract == '41008':
   wfos=['chs']
   region='er'
   wfobuoys=['41008']
   wfobuoycoors=['279.132 31.400']
if NDBCextract == '41029':
   wfos=['chs']
   region='er'
   wfobuoys=['41029']
   wfobuoycoors=['280.380 32.800']
if NDBCextract == '41033':
   wfos=['chs']
   region='er'
   wfobuoys=['41033']
   wfobuoycoors=['279.600 32.270']
if NDBCextract == '41004':
   wfos=['chs']
   region='er'
   wfobuoys=['41004']
   wfobuoycoors=['280.901 32.501']
if NDBCextract == '41065':
   wfos=['chs']
   region='er'
   wfobuoys=['41065']
   wfobuoycoors=['280.381 32.801']
if NDBCextract == '41076':
   wfos=['chs']
   region='er'
   wfobuoys=['41076']
   wfobuoycoors=['280.341 32.536']
if NDBCextract == '41013':
   wfos=['ilm']
   region='er'
   wfobuoys=['41013']
   wfobuoycoors=['282.257 33.436']
if NDBCextract == '44095':
   wfos=['mhx']
   region='er'
   wfobuoys=['44095']
   wfobuoycoors=['284.670 35.750']
#if NDBCextract == '41036':
#   wfos=['mhx']
#   wfobuoys=['41036']
#   wfobuoycoors=['283.051 34.207']
if NDBCextract == '41159':
   wfos=['mhx']
   region='er'
   wfobuoys=['41159']
   wfobuoycoors=['283.052 34.210']
if NDBCextract == '41025':
   wfos=['mhx']
   region='er'
   wfobuoys=['41025']
   wfobuoycoors=['284.598 35.006']
if NDBCextract == '44056':
   wfos=['mhx']
   region='er'
   wfobuoys=['44056']
   wfobuoycoors=['284.286 36.200']
if NDBCextract == '44100':
   wfos=['mhx']
   region='er'
   wfobuoys=['44100']
   wfobuoycoors=['284.409 36.255']
if NDBCextract == '44014':
   wfos=['akq']
   region='er'
   wfobuoys=['44014']
   wfobuoycoors=['285.158 36.611']
if NDBCextract == '44093':
   wfos=['akq']
   region='er'
   wfobuoys=['44093']
   wfobuoycoors=['284.508 36.872']
if NDBCextract == '44096':
   wfos=['akq']
   region='er'
   wfobuoys=['44096']
   wfobuoycoors=['284.190 37.023']
if NDBCextract == '44043':
   wfos=['lwx']
   region='er'
   wfobuoys=['44043']
   wfobuoycoors=['283.609 39.152']
if NDBCextract == 'TPLM2':
   wfos=['lwx']
   region='er'
   wfobuoys=['TPLM2']
   wfobuoycoors=['283.564 38.899']
if NDBCextract == '44062':
   wfos=['lwx']
   region='er'
   wfobuoys=['44062']
   wfobuoycoors=['283.585 38.556']
if NDBCextract == '44042':
   wfos=['lwx']
   region='er'
   wfobuoys=['44042']
   wfobuoycoors=['283.664 38.033']
if NDBCextract == '44058':
   wfos=['lwx']
   region='er'
   wfobuoys=['44058']
   wfobuoycoors=['283.743 37.551']
if NDBCextract == '44009':
   wfos=['phi']
   region='er'
   wfobuoys=['44009']
   wfobuoycoors=['285.297 38.461']
if NDBCextract == '44091':
   wfos=['phi']
   region='er'
   wfobuoys=['44091']
   wfobuoycoors=['286.231 39.778']
if NDBCextract == '44065':
   wfos=['okx']
   region='er'
   wfobuoys=['44065']
   wfobuoycoors=['286.297 40.369']
if NDBCextract == '44094':
   wfos=['okx']
   region='er'
   wfobuoys=['44094']
   wfobuoycoors=['286.894 40.585']
if NDBCextract == '44025':
   wfos=['okx']
   region='er'
   wfobuoys=['44025']
   wfobuoycoors=['286.836 40.251']
if NDBCextract == '44040':
   wfos=['okx']
   region='er'
   wfobuoys=['44040']
   wfobuoycoors=['286.420 40.956']
if NDBCextract == '44039':
   wfos=['okx']
   region='er'
   wfobuoys=['44039']
   wfobuoycoors=['287.345 41.138']
if NDBCextract == '44060':
   wfos=['okx']
   region='er'
   wfobuoys=['44060']
   wfobuoycoors=['287.933 41.263']
if NDBCextract == '44069':
   wfos=['okx']
   region='er'
   wfobuoys=['44069']
   wfobuoycoors=['286.914 40.693']
if NDBCextract == '44017':
   wfos=['box']
   region='er'
   wfobuoys=['44017']
   wfobuoycoors=['287.952 40.694']
if NDBCextract == '44020':
   wfos=['box']
   region='er'
   wfobuoys=['44020']
   wfobuoycoors=['289.813 41.443']
if NDBCextract == '44013':
   wfos=['box']
   region='er'
   wfobuoys=['44013']
   wfobuoycoors=['289.349 42.346']
if NDBCextract == '44018':
   wfos=['box']
   region='er'
   wfobuoys=['44018']
   wfobuoycoors=['290.299 42.121']
if NDBCextract == '44029':
   wfos=['box']
   region='er'
   wfobuoys=['44029']
   wfobuoycoors=['289.434 42.523']
if NDBCextract == '44090':
   wfos=['box']
   region='er'
   wfobuoys=['44090']
   wfobuoycoors=['289.671 41.840']
if NDBCextract == '44098':
   wfos=['box']
   region='er'
   wfobuoys=['44098']
   wfobuoycoors=['289.832 42.798']
if NDBCextract == '44033':
   wfos=['gyx']
   region='er'
   wfobuoys=['44033']
   wfobuoycoors=['291.003 44.056']
if NDBCextract == '44007':
   wfos=['gyx']
   region='er'
   wfobuoys=['44007']
   wfobuoycoors=['289.859 43.525']
if NDBCextract == '44032':
   wfos=['gyx']
   region='er'
   wfobuoys=['44032']
   wfobuoycoors=['290.645 43.716']
if NDBCextract == '44034':
   wfos=['car']
   region='er'
   wfobuoys=['44034']
   wfobuoycoors=['291.891 44.106']
if NDBCextract == '44027':
   wfos=['car']
   region='er'
   wfobuoys=['44027']
   wfobuoycoors=['292.693 44.287']

if NDBCextract == '46206':
   wfos=['sew']
   region='wr'
   wfobuoys=['46206']
   wfobuoycoors=['234.002 48.835']
if NDBCextract == '46041':
   wfos=['sew']
   region='wr'
   wfobuoys=['46041']
   wfobuoycoors=['235.269 47.353']
if NDBCextract == '46087':
   wfos=['sew']
   region='wr'
   wfobuoys=['46087']
   wfobuoycoors=['235.272 48.494']
if NDBCextract == '46088':
   wfos=['sew']
   region='wr'
   wfobuoys=['46088']
   wfobuoycoors=['236.835 48.334']
if NDBCextract == '46211':
   wfos=['pqr']
   region='wr'
   wfobuoys=['46211']
   wfobuoycoors=['235.756 46.858']
if NDBCextract == '46243':
   wfos=['pqr']
   region='wr'
   wfobuoys=['46243']
   wfobuoycoors=['235.871 46.215']
if NDBCextract == '46248':
   wfos=['pqr']
   region='wr'
   wfobuoys=['46248']
   wfobuoycoors=['235.355 46.133']
if NDBCextract == '46029':
   wfos=['pqr']
   region='wr'
   wfobuoys=['46029']
   wfobuoycoors=['235.486 46.159']
if NDBCextract == '46050':
   wfos=['pqr']
   region='wr'
   wfobuoys=['46050']
   wfobuoycoors=['235.474 44.656']
if NDBCextract == '46015':
   wfos=['mfr']
   region='wr'
   wfobuoys=['46015']
   wfobuoycoors=['235.168 42.764']
if NDBCextract == '46027':
   wfos=['mfr']
   region='wr'
   wfobuoys=['46027']
   wfobuoycoors=['235.619 41.850']
if NDBCextract == '46229':
   wfos=['mfr']
   region='wr'
   wfobuoys=['46229']
   wfobuoycoors=['235.451 43.767']
if NDBCextract == '46213':
   wfos=['eka']
   region='wr'
   wfobuoys=['46213']
   wfobuoycoors=['235.260 40.300']
if NDBCextract == '46212':
   wfos=['eka']
   region='wr'
   wfobuoys=['46212']
   wfobuoycoors=['235.690 40.750']
#if NDBCextract == '46027':
#   wfos=['eka']
#   wfobuoys=['46027']
#   wfobuoycoors=['235.620 41.760']
if NDBCextract == '46014':
   wfos=['eka']
   region='wr'
   wfobuoys=['46014']
   wfobuoycoors=['236.030 39.220']
if NDBCextract == '46042':
   wfos=['mtr']
   region='wr'
   wfobuoys=['46042']
   wfobuoycoors=['237.531 36.785']
if NDBCextract == '46028':
   wfos=['mtr']
   region='wr'
   wfobuoys=['46028']
   wfobuoycoors=['238.116 35.741']
if NDBCextract == '46239':
   wfos=['mtr']
   region='wr'
   wfobuoys=['46239']
   wfobuoycoors=['237.898 36.342']
if NDBCextract == '46236':
   wfos=['mtr']
   region='wr'
   wfobuoys=['46236']
   wfobuoycoors=['238.053 36.761']
if NDBCextract == '46240':
   wfos=['mtr']
   region='wr'
   wfobuoys=['46240']
   wfobuoycoors=['238.093 36.626']
if NDBCextract == '46214':
   wfos=['mtr']
   region='wr'
   wfobuoys=['46214']
   wfobuoycoors=['236.531 37.946']
if NDBCextract == '46013':
   wfos=['mtr']
   region='wr'
   wfobuoys=['46013']
   wfobuoycoors=['236.699 38.242']
if NDBCextract == '46012':
   wfos=['mtr']
   region='wr'
   wfobuoys=['46012']
   wfobuoycoors=['237.119 37.363']
if NDBCextract == '46026':
   wfos=['mtr']
   region='wr'
   wfobuoys=['46026']
   wfobuoycoors=['237.161 37.755']
if NDBCextract == '46237':
   wfos=['mtr']
   region='wr'
   wfobuoys=['46237']
   wfobuoycoors=['237.366 37.786']
if NDBCextract == '46028':
   wfos=['lox']
   region='wr'
   wfobuoys=['46028']
   wfobuoycoors=['238.120 35.740']
if NDBCextract == '46219':
   wfos=['lox']
   region='wr'
   wfobuoys=['46219']
   wfobuoycoors=['240.120 33.220']
if NDBCextract == '46069':
   wfos=['lox']
   region='wr'
   wfobuoys=['46069']
   wfobuoycoors=['239.790 33.670']
if NDBCextract == '46221':
   wfos=['lox']
   region='wr'
   wfobuoys=['46221']
   wfobuoycoors=['241.370 33.860']
if NDBCextract == '46222':
   wfos=['lox']
   region='wr'
   wfobuoys=['46222']
   wfobuoycoors=['241.683 33.618']
if NDBCextract == '46253':
   wfos=['lox']
   region='wr'
   wfobuoys=['46253']
   wfobuoycoors=['241.816 33.578']
if NDBCextract == '46256':
   wfos=['lox']
   region='wr'
   wfobuoys=['46256']
   wfobuoycoors=['241.7993 33.7003']
if NDBCextract == '46011':
   wfos=['lox']
   region='wr'
   wfobuoys=['46011']
   wfobuoycoors=['238.981 34.956']
if NDBCextract == '46053':
   wfos=['lox']
   region='wr'
   wfobuoys=['46053']
   wfobuoycoors=['240.147 34.252']
if NDBCextract == '46054':
   wfos=['lox']
   region='wr'
   wfobuoys=['46054']
   wfobuoycoors=['239.523 34.265']
if NDBCextract == '46025':
   wfos=['lox']
   region='wr'
   wfobuoys=['46025']
   wfobuoycoors=['240.947 33.749']
if NDBCextract == '46218':
   wfos=['lox']
   region='wr'
   wfobuoys=['46218']
   wfobuoycoors=['239.218 34.454']
if NDBCextract == '46086':
   wfos=['sgx']
   region='wr'
   wfobuoys=['46086']
   wfobuoycoors=['241.965 32.491']
if NDBCextract == '46224':
   wfos=['sgx']
   region='wr'
   wfobuoys=['46224']
   wfobuoycoors=['242.529 33.179']
if NDBCextract == '46232':
   wfos=['sgx']
   region='wr'
   wfobuoys=['46232']
   wfobuoycoors=['242.569 32.530']
if NDBCextract == '46231':
   wfos=['sgx']
   region='wr'
   wfobuoys=['46231']
   wfobuoycoors=['242.630 32.747']
if NDBCextract == '46258':
   wfos=['sgx']
   region='wr'
   wfobuoys=['46258']
   wfobuoycoors=['242.500 32.750']
if NDBCextract == '46225':
   wfos=['sgx']
   region='wr'
   wfobuoys=['46225']
   wfobuoycoors=['242.608 32.930']
if NDBCextract == '46242':
   wfos=['sgx']
   region='wr'
   wfobuoys=['46242']
   wfobuoycoors=['242.561 33.220']
if NDBCextract == '46254':
   wfos=['sgx']
   region='wr'
   wfobuoys=['46254']
   wfobuoycoors=['242.733 32.868']
if NDBCextract == 'LJPC1':
   wfos=['sgx']
   region='wr'
   wfobuoys=['LJPC1']
   wfobuoycoors=['242.743 32.867']

if NDBCextract == '51208':
   wfos=['hfo']
   region='pr'
   wfobuoys=['51208']
   wfobuoycoors=['200.430 22.300']
if NDBCextract == '51207':
   wfos=['hfo']
   region='pr'
   wfobuoys=['51207']
   wfobuoycoors=['202.248 21.477']
if NDBCextract == '51206':
   wfos=['hfo']
   region='pr'
   wfobuoys=['51206']
   wfobuoycoors=['205.032 19.781']
if NDBCextract == '51205':
   wfos=['hfo']
   region='pr'
   wfobuoys=['51205']
   wfobuoycoors=['203.575 21.018']
if NDBCextract == '51204':
   wfos=['hfo']
   region='pr'
   wfobuoys=['51204']
   wfobuoycoors=['201.876 21.281']
if NDBCextract == '51203':
   wfos=['hfo']
   region='pr'
   wfobuoys=['51203']
   wfobuoycoors=['202.990 20.788']
if NDBCextract == '51202':
   wfos=['hfo']
   region='pr'
   wfobuoys=['51202']
   wfobuoycoors=['202.321 21.414']
if NDBCextract == '51201':
   wfos=['hfo']
   region='pr'
   wfobuoys=['51201']
   wfobuoycoors=['201.880 21.669']
if NDBCextract == '51003':
   wfos=['hfo']
   region='pr'
   wfobuoys=['51003']
   wfobuoycoors=['199.431 19.289']
if NDBCextract == 'Kona':
   wfos=['hfo']
   region='pr'
   wfobuoys=['Kona']
   wfobuoycoors=['203.820 19.650']
if NDBCextract == 'Isaac':
   wfos=['hfo']
   region='pr'
   wfobuoys=['Isaac']
   wfobuoycoors=['205.270 19.410']
if NDBCextract == '52200':
   wfos=['gum']
   region='pr'
   wfobuoys=['52200']
   wfobuoycoors=['144.788 13.354']
if NDBCextract == '52211':
   wfos=['gum']
   region='pr'
   wfobuoys=['52211']
   wfobuoycoors=['145.662 15.267']
if NDBCextract == 'APRP7':
   wfos=['gum']
   region='pr'
   wfobuoys=['APRP7']
   wfobuoycoors=['144.657 13.444']

if NDBCextract == '46001':
   wfos=['aer']
   region='ar'
   wfobuoys=['46001']
   wfobuoycoors=['212.080 56.304']
if NDBCextract == '46080':
   wfos=['aer']
   region='ar'
   wfobuoys=['46080']
   wfobuoycoors=['210.040 57.939']
if NDBCextract == '46076':
   wfos=['aer']
   region='ar'
   wfobuoys=['46076']
   wfobuoycoors=['212.010 59.502']
if NDBCextract == '46082':
   wfos=['aer']
   region='ar'
   wfobuoys=['46082']
   wfobuoycoors=['216.608 59.668']
if NDBCextract == '46061':
   wfos=['aer']
   region='ar'
   wfobuoys=['46061']
   wfobuoycoors=['213.166 60.227']
if NDBCextract == '46060':
   wfos=['aer']
   region='ar'
   wfobuoys=['46060']
   wfobuoycoors=['213.216 60.584']
if NDBCextract == '46108':
   wfos=['aer']
   region='ar'
   wfobuoys=['46108']
   wfobuoycoors=['208.183 59.590']
if NDBCextract == '46081':
   wfos=['aer']
   region='ar'
   wfobuoys=['46081']
   wfobuoycoors=['211.737 60.799']
if NDBCextract == '46077':
   wfos=['aer']
   region='ar'
   wfobuoys=['46077']
   wfobuoycoors=['205.709 57.892']
if NDBCextract == '46066':
   wfos=['alu']
   region='ar'
   wfobuoys=['46066']
   wfobuoycoors=['204.953 52.785']
if NDBCextract == '46073':
   wfos=['alu']
   region='ar'
   wfobuoys=['46073']
   wfobuoycoors=['187.999 55.031']
if NDBCextract == '46075':
   wfos=['alu']
   region='ar'
   wfobuoys=['46075']
   wfobuoycoors=['199.194 53.911']
if NDBCextract == '46085':
   wfos=['ajk']
   region='ar'
   wfobuoys=['46085']
   wfobuoycoors=['217.506 55.868']
if NDBCextract == '46083':
   wfos=['ajk']
   region='ar'
   wfobuoys=['46083']
   wfobuoycoors=['222.003 58.300']
if NDBCextract == 'FFIA2':
   wfos=['ajk']
   region='ar'
   wfobuoys=['FFIA2']
   wfobuoycoors=['226.370 57.272']
if NDBCextract == '48114':
   wfos=['afg']
   region='ar'
   wfobuoys=['48114']
   wfobuoycoors=['190.546 65.011']
if NDBCextract == '48012':
   wfos=['afg']
   region='ar'
   wfobuoys=['48012']
   wfobuoycoors=['193.929 70.025']
if NDBCextract == '48212':
   wfos=['afg']
   region='ar'
   wfobuoys=['48212']
   wfobuoycoors=['209.721 70.874']

cycles=['00','01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23']
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
   print('')
   print('Analysing '+timestamp+'...')

   for iwfo in range(len(wfos)):
      print('')
      wfo=wfos[iwfo]
      iwfobuoy=iwfo
      wfobuoy=wfobuoys[iwfobuoy]
      print('Extracting '+region+'.'+timestamp+'/'+wfo+', buoy '+wfobuoy+', on '+CGextract+':')

      for cycle in cycles:
         print('Checking cycle '+cycle)
         extdir=COMOUT+region+'.'+timestamp+'/'+wfo+'/'+cycle+'/'+CGextract+'/'
         infile=wfo+'_nwps_'+CGextract+'_'+timestamp+'_'+cycle+'00.grib2'
         print('Checking '+extdir+infile)

         if os.path.isfile(extdir+infile):
            print('Data found. Extracting at buoy locations...')
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
      print('')
      wfo=wfos[iwfo]
      print('Reading pnt data from '+region+'.'+timestamp+'/'+wfo+':')

      #for iwfobuoy in range(len(wfobuoys[iwfo][:])):
      iwfobuoy=iwfo
      wfobuoy=wfobuoys[iwfobuoy]
      #wfobuoy=allBuoys[ibuoy]
      datafound = 'false'

      for cycle in cycles:
         if datafound == 'true':
            continue
         print('Search for '+wfobuoy+' cycle '+cycle)
         infile = wfo+'_'+wfobuoy+'_'+varname[0]+'_'+timestamp+'_'+cycle+'00.pnt'
         if os.path.isfile(infile):
            print('Reading file '+infile)
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
         print(' *** Warning: no model data found')
         for tstep in range(TDEF):
            modpar[iwfobuoy][tstep] = np.nan
            modtim[iwfobuoy][tstep] = np.nan
         bcycle[iwfobuoy] = '00'   # Reset the cycle if no data is found
      #modpar(find(modpar==0.)) = NaN;

      # ---------- Interpolate obeservational and model time series to daily values, for comparison ----------
      refdate = datetime.datetime(int(timestamp[0:4]),int(timestamp[4:6]),int(timestamp[6:8])).strftime('%s')
      synpdate = datetime.datetime(int(timestamp[0:4]),int(timestamp[4:6]),int(timestamp[6:8]),int(bcycle[iwfobuoy])).strftime('%s')

      #temp = interp1(flipud(obstim(1:360,ibuoy)),flipud(obspar(1:360,ibuoy)),int_time);
      obs_int_time = []
      mod_int_time = []
      obs_interp = []
      mod_interp = []
      if (len(obspar[iwfobuoy][:]) != 0):
         obs_int_time = np.arange((int(synpdate)+86400),(int(synpdate)+7*86400),86400)
         obs_interp = np.interp(obs_int_time, obstim[iwfobuoy][:], obspar[iwfobuoy][:])
         obs_fcast_array_24hr.append( obs_interp[0] )
         obs_fcast_array_48hr.append( obs_interp[1] )
         obs_fcast_array_72hr.append( obs_interp[2] )
         obs_fcast_array_96hr.append( obs_interp[3] )
         obs_fcast_array_120hr.append( obs_interp[4] )
         obs_fcast_array_144hr.append( obs_interp[5] )

      if (len(modpar[iwfobuoy][:]) != 0):
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
         fig, ax = plt.subplots()
         ax.plot_date(mdate.epoch2num(modtim[iwfobuoy][:]), modpar[iwfobuoy][:], 'b-o', markeredgecolor='b',markersize=2)
         ax.plot_date(mdate.epoch2num(obstim[iwfobuoy][:]), obspar[iwfobuoy][:], 'r-o', markeredgecolor='r',markersize=2)
         ax.plot_date(mdate.epoch2num(mod_int_time), mod_interp, 'bo', markeredgecolor='b',markersize=5)
         ax.plot_date(mdate.epoch2num(obs_int_time), obs_interp, 'ro', markeredgecolor='b',markersize=5)
         date_formatter = mdate.DateFormatter('%m/%d')  # Use a DateFormatter to set the data to the correct format.
         ax.xaxis.set_major_formatter(date_formatter)  # Use a DateFormatter to set the data to the correct format.
         fig.autofmt_xdate()
         ax.set_xlim([startDate, stopDateObs])
         #ax.set_ylim([0, 10])
      
         fig.suptitle('NWPS: '+wfo+' '+timestamp+'_'+bcycle[iwfobuoy]+'Z')
         plt.xlabel('Time (UTC)')
         plt.ylabel('Hs (m)')
      
         filenm = wfo+'_'+wfobuoy+'_'+timestamp+'_'+bcycle[iwfobuoy]+'_ts.png'
         plt.savefig(filenm,dpi=150,bbox_inches='tight',pad_inches=0.1)
         plt.clf()

      print(mod_interp)
      print(obs_interp)

# ---- Compute overall stats and make scatter plot

plt.figure(figsize=(11,7))

#print(len(obspar[iwfobuoy][:]))
#print(len(modpar[iwfobuoy][:]))

#print(mod_fcast_array_24hr)
#print(obs_fcast_array_24hr)

if ( (len(obspar[iwfobuoy][:]) != 0) & (len(modpar[iwfobuoy][:]) != 0) ):
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

      # Create linear regression object
      #regr = linear_model.LinearRegression()
      # Train the model using the training sets
      #regr.fit(observ, model)

      biasstr = "Rel. bias = %6.3f"% (relbias)
      sistr = "SI = %6.3f"% (si)
      nstr = 'N = '+str(len(temp))
      #rstr = 'r^2: %.2f' % regr.score(observ, model)

      print('')
      print('--- Final stats for '+figtitle+' ('+startDate.strftime("%Y/%m/%d")+'-'+stopDate.strftime("%Y/%m/%d")+'):')
      print(biasstr)
      print(sistr)
      print(nstr)
      # Explained variance score: 1 is perfect prediction
      #print(rstr)

      ascale = np.ceil( np.amax( [np.amax(observ_nonan),np.amax(model_nonan)] ) )

      plt.plot(observ,model,'ko', markeredgecolor='k',markersize=2)
      #plt.plot(observ,regr.predict(observ), color='black',linewidth=3)
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

else:
   for ipanel in np.arange(1,7):
      ax = plt.subplot(2, 3, ipanel, aspect='equal')
      if ipanel == 1:
         figtitle = '24h fcst';
      elif ipanel == 2:
         figtitle = '48h fcst';
      elif ipanel == 3:
         figtitle = '72h fcst';
      elif ipanel == 4:
         figtitle = '96h fcst';
      elif ipanel == 5:
         figtitle = '120h fcst';
      elif ipanel == 6:
         figtitle = '144h fcst';

      print('')
      print('--- Final stats for '+figtitle+' ('+startDate.strftime("%Y/%m/%d")+'-'+stopDate.strftime("%Y/%m/%d")+'):')
      print('Rel. bias = NO DATA')
      print('SI = NO DATA')
      print('N = NO DATA')

      plt.plot(range(2),range(2),'k:')
      plt.text(0.35, 0.48, 'NO DATA', fontsize=10, transform = ax.transAxes)  
      plt.tick_params(axis='both', which='major', labelsize=8)
      #plt.title(figtitle)
      plt.text(0.6, 0.1, figtitle, transform = ax.transAxes)

      if (ipanel == 4) |(ipanel == 5) | (ipanel == 6):
         plt.xlabel('Hs,obs (m)', fontsize=10)
      if (ipanel == 1) | (ipanel == 4):
         plt.ylabel('Hs,mod (m)', fontsize=10)     

plt.suptitle('NWPS WFO-'+wfo.upper()+': NDBC '+NDBCextract+' validation '+startDate.strftime("%Y/%m/%d")+'-'+stopDate.strftime("%Y/%m/%d"))
filenm = 'nwps_'+timestamp+'_'+wfo+'_'+NDBCextract+'_scatter.png'
plt.savefig(workdir+filenm,dpi=150,bbox_inches='tight',pad_inches=0.1)
plt.clf()

print('-------- Exiting nwps_stat_ndbc_rt30day.py ---------')
print('')


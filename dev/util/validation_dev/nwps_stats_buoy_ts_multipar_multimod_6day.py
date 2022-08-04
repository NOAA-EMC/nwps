import matplotlib
#matplotlib.use('Agg',warn=False)  # Use this to run Matplotlib in the background and avoid issues with the X-Server

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
from matplotlib.ticker import MultipleLocator

# global vars
COMOUT = os.environ.get('COMOUT')
COMOUTm1 = os.environ.get('COMOUTm1')
COMOUTm2 = os.environ.get('COMOUTm2')
COMOUTww1 = os.environ.get('COMOUTww1')
COMOUTww1_m1 = os.environ.get('COMOUTww1_m1')
COMOUTww1_m2 = os.environ.get('COMOUTww1_m2')
workdir = os.environ.get('workdir')

TDEF = 145
TDEF2 = 35
tdelta = 1
tdelta2 = 3
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
if NDBCextract == 'GSTRM':
   wfos=['key']
   wfobuoys=['GSTRM']
   wfobuoycoors=['280.000 25.000']
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
#if NDBCextract == '41008':
#   wfos=['jax']
#   wfobuoys=['41008']
#   wfobuoycoors=['279.132 31.400']
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
if NDBCextract == '44064':
   wfos=['akq']
   wfobuoys=['44064']
   wfobuoycoors=['283.913 36.998']
if NDBCextract == '44072':
   wfos=['akq']
   wfobuoys=['44072']
   wfobuoycoors=['283.734 37.201']
if NDBCextract == '44099':
   wfos=['akq']
   wfobuoys=['44099']
   wfobuoycoors=['284.280 36.915']
if NDBCextract == '44089':
   wfos=['akq']
   wfobuoys=['44089']
   wfobuoycoors=['284.666 37.756']
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
   wfos=['akq']
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
if NDBCextract == '51211':
   wfos=['hfo']
   wfobuoys=['51211']
   wfobuoycoors=['202.041 21.297']
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
if NDBCextract == '52202':
   wfos=['gum']
   wfobuoys=['52202']
   wfobuoycoors=['144.811 13.682']

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
if NDBCextract == '46075':
   wfos=['alu']
   wfobuoys=['46075']
   wfobuoycoors=['199.194 53.911']
if NDBCextract == '46073':
   wfos=['alu']
   wfobuoys=['46073']
   wfobuoycoors=['187.999 55.031']
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
obspertim = [[0 for x in range(30000)] for x in range(len(wfobuoys))]
obsdirtim = [[0 for x in range(30000)] for x in range(len(wfobuoys))]
obswspdtim = [[0 for x in range(30000)] for x in range(len(wfobuoys))]
obswdirtim = [[0 for x in range(30000)] for x in range(len(wfobuoys))]
obspar = [[0 for x in range(30000)] for x in range(len(wfobuoys))]
obsper = [[0 for x in range(30000)] for x in range(len(wfobuoys))]
obsdir = [[0 for x in range(30000)] for x in range(len(wfobuoys))]
obswnd = [[0 for x in range(30000)] for x in range(len(wfobuoys))]
obswspd = [[0 for x in range(30000)] for x in range(len(wfobuoys))]
obswdir = [[0 for x in range(30000)] for x in range(len(wfobuoys))]

varname = []
bcycle = [0 for x in range(len(wfobuoys))]
bcyclem1 = [0 for x in range(len(wfobuoys))]
bcyclem2 = [0 for x in range(len(wfobuoys))]
ww1cycle = [0 for x in range(len(wfobuoys))]
ww1cyclem1 = [0 for x in range(len(wfobuoys))]
ww1cyclem2 = [0 for x in range(len(wfobuoys))]

def read_ndbc(buoy,vname,startDate,stopDate):

     print('processing',buoy)
     url='https://dods.ndbc.noaa.gov/thredds/dodsC/data/stdmet/'+str(buoy)+'/'+str(buoy)+'h9999.nc'
     #url='https://dods.ndbc.noaa.gov/thredds/fileServer/data/stdmet/'+str(buoy)+'/'+str(buoy)+'h9999.nc'
     #url='http://dods.ndbc.noaa.gov/thredds/dodsC/data/stdmet/'+str(buoy)+'/'+str(buoy)+'h2015.nc'  # Monthly QAed values

     try:
          nco = Dataset(url)
          #print(nco.variables)

          times = nco.variables['time'][:]
          h = nco.variables['wave_height'][:]
          t = nco.variables['dominant_wpd'][:]
          d = nco.variables['mean_wave_dir'][:]
     except:
          print('*** Warning: no observation data found. Skipping', buoy)
          times = []
          h = []
          t = []
          d = []

     #jd = num2date(times,times.units)
     return (times, h, t, d)

def daterange(start_date, end_date):
     for n in range(int((end_date - start_date).days)+1):
        yield start_date + timedelta(n)

def timedelta_total_seconds(timedelta):
    return (
        timedelta.microseconds + 0.0 +
        (timedelta.seconds + timedelta.days * 24 * 3600) * 10 ** 6) / 10 ** 6

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
tmp2 = os.environ.get('STARTDATEm1')
tmp3 = os.environ.get('STARTDATEm2')
tmp4 = os.environ.get('ENDDATE')

startDate=datetime.datetime(int(tmp1[0:4]),int(tmp1[4:6]),int(tmp1[6:8]))
startDatem1=datetime.datetime(int(tmp2[0:4]),int(tmp2[4:6]),int(tmp2[6:8]))
startDatem2=datetime.datetime(int(tmp3[0:4]),int(tmp3[4:6]),int(tmp3[6:8]))
stopDate=datetime.datetime(int(tmp4[0:4]),int(tmp4[4:6]),int(tmp4[6:8]))

print('-------- In nwps_stats_buoy_ts.py ---------')
print('Computing NWPS statistics for NDBC '+NDBCextract.upper()+':')
print('startDate = '+startDate.strftime("%Y/%m/%d"))
print('startDatem1 = '+startDatem1.strftime("%Y/%m/%d"))
print('startDatem2 = '+startDatem2.strftime("%Y/%m/%d"))
print('stopDate = '+stopDate.strftime("%Y/%m/%d"))
print('')

vname = 'wave_height'
ibuoy = 0

# Fetch and read NDBC buoy observations
print('Fetching realtime NDBC buoy obs...')
for buoy in wfobuoys:
     times, h, t, d = read_ndbc(buoy,vname,startDate,stopDate)
     if (len(h) != 0):
        #Read obs (incl. any NaNs) as a masked array
        obstim_withnans = times[:]
        obspertim_withnans = times[:]
        #obsdirtim_withnans = times[:]
        obspar_withnans = h[:,0,0]
        obsper_withnans = t[:,0,0]
        #obsdir_withnans = d[:,0,0]
        #obswspd_withnans = wspd[:,0,0]
        #obswdir_withnans = wdir[:,0,0]
        #Filter out any small (erroneous) obs and replace with NaNs
        for tstep in range(len(obspar_withnans)):
           if obspar_withnans[tstep]<0.05:
              obspar_withnans[tstep]=np.nan
              obsper_withnans[tstep]=np.nan
              #obsdir_withnans[tstep]=np.nan
              #obswspd_withnans[tstep]=np.nan
              #obswdir_withnans[tstep]=np.nan
        #Filter out the NaNs (masked values in ma) using the mask in opspar_withnans
        obstim[ibuoy][:] = obstim_withnans[np.ma.nonzero(obspar_withnans)]
        obspertim[ibuoy][:] = obstim_withnans[np.ma.nonzero(obsper_withnans)]
        #obsdirtim[ibuoy][:] = obstim_withnans[np.ma.nonzero(obsdir_withnans)]
        #obswspdtim[ibuoy][:] = obstim_withnans[np.ma.nonzero(obswspd_withnans)]
        #obswdirtim[ibuoy][:] = obstim_withnans[np.ma.nonzero(obswdir_withnans)]
        obspar[ibuoy][:] = obspar_withnans[np.ma.nonzero(obspar_withnans)]
        obsper[ibuoy][:] = obsper_withnans[np.ma.nonzero(obsper_withnans)]
        #obsdir[ibuoy][:] = obsdir_withnans[np.ma.nonzero(obsdir_withnans)]
        #obswspd[ibuoy][:] = obswspd_withnans[np.ma.nonzero(obswspd_withnans)]
        #obswdir[ibuoy][:] = obswdir_withnans[np.ma.nonzero(obswdir_withnans)]
        #print(np.shape(obsdir[ibuoy][:]))
        #print(obsdir_withnans)
     else:
        obstim[ibuoy][:] = []
        obspertim[ibuoy][:] = []
        #obsdirtim[ibuoy][:] = []
        #obswspdtim[ibuoy][:] = []
        #obswdirtim[ibuoy][:] = []
        obspar[ibuoy][:] = []
        obsper[ibuoy][:] = []
        #obsdir[ibuoy][:] = [] 
        #obswspd[ibuoy][:] = []
        #obswdir[ibuoy][:] = []
     #print(obspar[ibuoy][:])
     #print(obstim[ibuoy][:])
     #print(len(obspar[ibuoy][:]))

     # Truncate all Hs obs earlier than startDatem2
     print(len(np.array(obstim[ibuoy][:])))
     print(np.any( np.array(obstim[ibuoy][:]) > int(startDatem2.strftime('%s')) ))
     timind = 0
     if np.any( np.array(obstim[ibuoy][:]) > int(startDatem2.strftime('%s')) ):
        timind = min(min( np.where(np.array(obstim[ibuoy][:]) > int(startDatem2.strftime('%s'))) ))
        obstim[ibuoy][:] = obstim[ibuoy][timind:]
        obspar[ibuoy][:] = obspar[ibuoy][timind:]
     else:
        obstim[ibuoy][:] = []
        obspar[ibuoy][:] = []
     print(timind)
     print(len(np.array(obstim[ibuoy][:])))
     print(len(np.array(obspar[ibuoy][:])))
     if len(np.array(obspar[ibuoy][:]))==0:
        read_hs_obs_from_5day = True
        print('Reading Hs and Tp from NDBC 5day data file...')
        obstim = [[0 for x in range(30000)] for x in range(len(wfobuoys))]
        obspertim = [[0 for x in range(30000)] for x in range(len(wfobuoys))]
        obspar = [[0 for x in range(30000)] for x in range(len(wfobuoys))]
        obsper = [[0 for x in range(30000)] for x in range(len(wfobuoys))]
     else:
        read_hs_obs_from_5day = False

#-----------------------------------------------------------
     print('')
     url='https://www.ndbc.noaa.gov/data/5day2/'+str(buoy)+'_5day.txt'
     url2='https://www.ndbc.noaa.gov/data/derived2/'+str(buoy)+'.dmv'

     try:
          command = 'wget '+url
          os.system(command)

          infile = str(buoy)+'_5day.txt'
          f = open(workdir+infile, "r")
          tstep = 0
          for line in f:
             data = line.split()
             if data[0] == '#YY':
                obsdir[ibuoy][tstep] = [] #Skipping header line'
             elif data[0] == '#yr':
                obsdir[ibuoy][tstep] = [] #Skipping header line'
             else:
                obsdirtim[ibuoy][tstep] = int(datetime.datetime(int(data[0]),int(data[1]),int(data[2]),int(data[3]),int(data[4])).strftime('%s'))
                obswspdtim[ibuoy][tstep] = obsdirtim[ibuoy][tstep]
                obswdirtim[ibuoy][tstep] = obsdirtim[ibuoy][tstep]
                if data[11] != 'MM':
                   obsdir[ibuoy][tstep] = float(data[11])
                else:
                   obsdir[ibuoy][tstep] = np.nan
                if data[6] != 'MM':
                   obswspd[ibuoy][tstep] = float(data[6])
                else:
                   obswspd[ibuoy][tstep] = np.nan
                if data[5] != 'MM':
                   obswdir[ibuoy][tstep] = float(data[5])
                else:
                   obswdir[ibuoy][tstep] = np.nan
                if read_hs_obs_from_5day:
                   obstim[ibuoy][tstep] = int(datetime.datetime(int(data[0]),int(data[1]),int(data[2]),int(data[3]),int(data[4])).strftime('%s'))
                   obspertim[ibuoy][tstep] = int(datetime.datetime(int(data[0]),int(data[1]),int(data[2]),int(data[3]),int(data[4])).strftime('%s'))
                   if data[8] != 'MM':
                      obspar[ibuoy][tstep] = float(data[8])
                   else:
                      obspar[ibuoy][tstep] = np.nan
                   if data[9] != 'MM':
                      obsper[ibuoy][tstep] = float(data[9])
                   else:
                      obsper[ibuoy][tstep] = np.nan
                   #print(obstim[ibuoy][tstep])
                   #print(obspertim[ibuoy][tstep])
                   #print(obspar[ibuoy][tstep])
                   #print(obsper[ibuoy][tstep])
                #print(d[tstep])
                tstep = tstep+1

          command = 'rm '+infile
          os.system(command)
          command = 'rm '+infile+'.?'
          os.system(command)      
          command = 'rm '+infile+'.??'
          os.system(command) 
          command = 'rm '+infile+'.???'
          os.system(command)    
     except:
          print('*** Warning: No wave direction observational data found for ',buoy)
          obsdirtim[ibuoy] = []
          obswspdtim[ibuoy] = []
          obswdirtim[ibuoy] = []
          obsdir[ibuoy] = []
          obswspd[ibuoy] = []
          obswdir[ibuoy] = []

          command = 'rm '+infile
          os.system(command)
          command = 'rm '+infile+'.?'
          os.system(command)      
          command = 'rm '+infile+'.??'
          os.system(command) 
          command = 'rm '+infile+'.???'
          os.system(command)
#---------------------------------------------------------

     ibuoy = ibuoy+1

#print(obstim[0][:])
#print(obspar[0][:])

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
if NDBCextract == 'GSTRM':
   wfos=['key']
   region='sr'
   wfobuoys=['GSTRM']
   wfobuoycoors=['280.000 25.000']
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
#   region='er'
   wfobuoys=['41036']
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
if NDBCextract == '44064':
   wfos=['akq']
   region='er'
   wfobuoys=['44064']
   wfobuoycoors=['283.913 36.998']
if NDBCextract == '44072':
   wfos=['akq']
   region='er'
   wfobuoys=['44072']
   wfobuoycoors=['283.734 37.201']
if NDBCextract == '44099':
   wfos=['akq']
   region='er'
   wfobuoys=['44099']
   wfobuoycoors=['284.280 36.915']
if NDBCextract == '44089':
   wfos=['akq']
   region='er'
   wfobuoys=['44089']
   wfobuoycoors=['284.666 37.756']
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
   wfos=['akq']
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
#   region='wr'
   wfobuoys=['46027']
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
if NDBCextract == '51211':
   wfos=['hfo']
   region='pr'
   wfobuoys=['51211']
   wfobuoycoors=['202.041 21.297']
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
if NDBCextract == '52202':
   wfos=['gum']
   region='pr'
   wfobuoys=['52202']
   wfobuoycoors=['144.811 13.682']

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
revcycles=['23','22','21','20','19','18','17','16','15','14','13','12','11','10','09','08','07','06','05','04','03','02','01','00']
fhours=['000','003','006','009','012','015','018','021','024','027','030','033','036','039','042','045','048','051','054','057','060',
        '063','066','069','072','075','078','081','084','087','090','093','096','099','102']
varname=['HTSGW','PERPW','DIRPW','WIND','WDIR']

for single_date in daterange(startDate,startDate):

   # Comprehensions
   modtim = [[0 for x in range(TDEF)] for x in range(len(wfos))]
   modpar = [[0 for x in range(TDEF)] for x in range(len(wfos))]
   modper = [[0 for x in range(TDEF)] for x in range(len(wfos))]
   moddir = [[0 for x in range(TDEF)] for x in range(len(wfos))]
   modwnd = [[0 for x in range(TDEF)] for x in range(len(wfos))]
   modwdr = [[0 for x in range(TDEF)] for x in range(len(wfos))]

   timestamp = single_date.strftime("%Y%m%d")
   print('')
   print('Analysing '+timestamp+'...')

   for iwfo in range(len(wfos)):
      print('')
      wfo=wfos[iwfo]
      iwfobuoy=iwfo
      wfobuoy=wfobuoys[iwfobuoy]
      print('Extracting '+region+'.'+timestamp+'/'+wfo+', buoy '+wfobuoy+', on '+CGextract+':')

      for cycle in revcycles:
         print('Checking cycle '+cycle)
         extdir=COMOUT+region+'.'+timestamp+'/'+wfo+'/'+cycle+'/'+CGextract+'/'
         infile=wfo+'_nwps_'+CGextract+'_'+timestamp+'_'+cycle+'00.grib2'

         if os.path.isfile(extdir+infile):
            print('Data found. Extracting at buoy locations...')
            command = 'cp '+extdir+infile+' '+workdir
            os.system(command)

            command = '$WGRIB2 '+workdir+infile+'  -match "'+varname[0]+'" -lon '+wfobuoycoors[iwfobuoy]+'  > '+wfo+'_'+wfobuoy+'_'+varname[0]+'_'+timestamp+'_'+cycle+'00.pnt'
            os.system(command)
            command = '$WGRIB2 '+workdir+infile+'  -match "'+varname[1]+'" -lon '+wfobuoycoors[iwfobuoy]+'  > '+wfo+'_'+wfobuoy+'_'+varname[1]+'_'+timestamp+'_'+cycle+'00.pnt'
            os.system(command)
            command = '$WGRIB2 '+workdir+infile+'  -match "'+varname[2]+'" -lon '+wfobuoycoors[iwfobuoy]+'  > '+wfo+'_'+wfobuoy+'_'+varname[2]+'_'+timestamp+'_'+cycle+'00.pnt'
            os.system(command)
            command = '$WGRIB2 '+workdir+infile+'  -match "'+varname[3]+'" -lon '+wfobuoycoors[iwfobuoy]+'  > '+wfo+'_'+wfobuoy+'_'+varname[3]+'_'+timestamp+'_'+cycle+'00.pnt'
            os.system(command)
            command = '$WGRIB2 '+workdir+infile+'  -match "'+varname[4]+'" -lon '+wfobuoycoors[iwfobuoy]+'  > '+wfo+'_'+wfobuoy+'_'+varname[4]+'_'+timestamp+'_'+cycle+'00.pnt'
            os.system(command)
            command = 'rm '+workdir+infile
            os.system(command)

            command = 'ls -lrt *.pnt'
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

      for cycle in revcycles:
         if datafound == 'true':
            continue
         print('Search for '+wfobuoy+' cycle '+cycle)
         infile  = wfo+'_'+wfobuoy+'_'+varname[0]+'_'+timestamp+'_'+cycle+'00.pnt'
         infile1 = wfo+'_'+wfobuoy+'_'+varname[1]+'_'+timestamp+'_'+cycle+'00.pnt'
         infile2 = wfo+'_'+wfobuoy+'_'+varname[2]+'_'+timestamp+'_'+cycle+'00.pnt'
         infile3 = wfo+'_'+wfobuoy+'_'+varname[3]+'_'+timestamp+'_'+cycle+'00.pnt'
         infile4 = wfo+'_'+wfobuoy+'_'+varname[4]+'_'+timestamp+'_'+cycle+'00.pnt'
         if os.path.isfile(infile):
            print('Reading file '+infile)
            print('Reading file '+infile1)
            print('Reading file '+infile2)
            print('Reading file '+infile3)
            print('Reading file '+infile4)
            datafound = 'true'
            fo  = open(workdir+infile, "r")
            fo1 = open(workdir+infile1, "r")
            fo2 = open(workdir+infile2, "r")
            fo3 = open(workdir+infile3, "r")
            fo4 = open(workdir+infile4, "r")
            for tstep in range(TDEF):
               # Hs
               line = fo.readline()
               linesplit = [s for s in re.split(r',val=', line) if s]
               modpar[iwfobuoy][tstep] = float(linesplit[1])
               # Tp
               line = fo1.readline()
               linesplit = [s for s in re.split(r',val=', line) if s]
               modper[iwfobuoy][tstep] = float(linesplit[1])
               # Dir
               line = fo2.readline()
               linesplit = [s for s in re.split(r',val=', line) if s]
               moddir[iwfobuoy][tstep] = float(linesplit[1])
               # Wind
               line = fo3.readline()
               linesplit = [s for s in re.split(r',val=', line) if s]
               modwnd[iwfobuoy][tstep] = float(linesplit[1])
               # WDir
               line = fo4.readline()
               linesplit = [s for s in re.split(r',val=', line) if s]
               modwdr[iwfobuoy][tstep] = float(linesplit[1])
               # Date (Add the forecast hour to the start of the cycle timestamp)
               date = datetime.datetime(int(timestamp[0:4]),int(timestamp[4:6]),int(timestamp[6:8]),int(cycle))
               date = date + datetime.timedelta(hours=(tstep*tdelta))
               #modtim[iwfobuoy][tstep] = (date-datetime.datetime(1970,1,1)).total_seconds()
               modtim[iwfobuoy][tstep] = timedelta_total_seconds(date-datetime.datetime(1970,1,1))
               bcycle[iwfobuoy] = cycle
               # Remove SWAN exception values
               if modpar[iwfobuoy][tstep]<0.05:
                  modpar[iwfobuoy][tstep]=np.nan
                  modper[iwfobuoy][tstep]=np.nan
                  moddir[iwfobuoy][tstep]=np.nan
                  modwnd[iwfobuoy][tstep]=np.nan
                  modwdr[iwfobuoy][tstep]=np.nan
                  modtim[iwfobuoy][tstep] = np.nan
            fo.close()
            command = 'rm '+workdir+infile
            os.system(command)
            command = 'rm '+workdir+infile1
            os.system(command)
            command = 'rm '+workdir+infile2
            os.system(command)
            command = 'rm '+workdir+infile3
            os.system(command)
            command = 'rm '+workdir+infile4
            os.system(command)

            command = 'ls -lrt *.pnt'
            os.system(command)
         else:
            continue
      if (datafound == 'false'):
         print(' *** Warning: no model data found')
         for tstep in range(TDEF):
            modpar[iwfobuoy][tstep] = np.nan
            modper[iwfobuoy][tstep] = np.nan
            moddir[iwfobuoy][tstep] = np.nan
            modwnd[iwfobuoy][tstep] = np.nan
            modwdr[iwfobuoy][tstep] = np.nan
            modtim[iwfobuoy][tstep] = np.nan
         bcycle[iwfobuoy] = '00'   # Reset the cycle if no data is found
      #modpar(find(modpar==0.)) = NaN;

for single_date in daterange(startDatem1,startDatem1):

   # Comprehensions
   modtimm1 = [[0 for x in range(TDEF)] for x in range(len(wfos))]
   modparm1 = [[0 for x in range(TDEF)] for x in range(len(wfos))]
   modperm1 = [[0 for x in range(TDEF)] for x in range(len(wfos))]
   moddirm1 = [[0 for x in range(TDEF)] for x in range(len(wfos))]
   modwndm1 = [[0 for x in range(TDEF)] for x in range(len(wfos))]
   modwdrm1 = [[0 for x in range(TDEF)] for x in range(len(wfos))]

   timestampm1 = single_date.strftime("%Y%m%d")
   print('')
   print('Analysing '+timestampm1+'...')

   for iwfo in range(len(wfos)):
      print('')
      wfo=wfos[iwfo]
      iwfobuoy=iwfo
      wfobuoy=wfobuoys[iwfobuoy]
      print('Extracting '+region+'.'+timestampm1+', buoy '+wfobuoy+', on '+CGextract+':')

      for cycle in cycles:
         print('Checking cycle '+cycle)
         extdir=COMOUTm1+region+'.'+timestampm1+'/'+wfo+'/'+cycle+'/'+CGextract+'/'
         infile=wfo+'_nwps_'+CGextract+'_'+timestampm1+'_'+cycle+'00.grib2'

         if os.path.isfile(extdir+infile):
            print('Data found. Extracting at buoy locations...')
            command = 'cp '+extdir+infile+' '+workdir
            os.system(command)

            command = '$WGRIB2 '+workdir+infile+'  -match "'+varname[0]+'" -lon '+wfobuoycoors[iwfobuoy]+'  > '+wfo+'_'+wfobuoy+'_'+varname[0]+'_'+timestampm1+'_'+cycle+'00.pnt'
            os.system(command)
            command = '$WGRIB2 '+workdir+infile+'  -match "'+varname[1]+'" -lon '+wfobuoycoors[iwfobuoy]+'  > '+wfo+'_'+wfobuoy+'_'+varname[1]+'_'+timestampm1+'_'+cycle+'00.pnt'
            os.system(command)
            command = '$WGRIB2 '+workdir+infile+'  -match "'+varname[2]+'" -lon '+wfobuoycoors[iwfobuoy]+'  > '+wfo+'_'+wfobuoy+'_'+varname[2]+'_'+timestampm1+'_'+cycle+'00.pnt'
            os.system(command)
            command = '$WGRIB2 '+workdir+infile+'  -match "'+varname[3]+'" -lon '+wfobuoycoors[iwfobuoy]+'  > '+wfo+'_'+wfobuoy+'_'+varname[3]+'_'+timestampm1+'_'+cycle+'00.pnt'
            os.system(command)
            command = '$WGRIB2 '+workdir+infile+'  -match "'+varname[4]+'" -lon '+wfobuoycoors[iwfobuoy]+'  > '+wfo+'_'+wfobuoy+'_'+varname[4]+'_'+timestampm1+'_'+cycle+'00.pnt'
            os.system(command)
            command = 'rm '+workdir+infile
            os.system(command)

            command = 'ls -lrt *.pnt'
            os.system(command)
            break

# ---------- Read NWPS model data into buoy-centered arrays ----------

   for iwfo in range(len(wfos)):
   #for ibuoy in range(len(allBuoys)):
      print('')
      wfo=wfos[iwfo]
      print('Reading pnt data from '+wfo+'.'+timestampm1+':')

      #for iwfobuoy in range(len(wfobuoys[iwfo][:])):
      iwfobuoy=iwfo
      wfobuoy=wfobuoys[iwfobuoy]
      #wfobuoy=allBuoys[ibuoy]
      datafound = 'false'

      for cycle in cycles:
         if datafound == 'true':
            continue
         print('Search for '+wfobuoy+' cycle '+cycle) 
         infile  = wfo+'_'+wfobuoy+'_'+varname[0]+'_'+timestampm1+'_'+cycle+'00.pnt'
         infile1 = wfo+'_'+wfobuoy+'_'+varname[1]+'_'+timestampm1+'_'+cycle+'00.pnt'
         infile2 = wfo+'_'+wfobuoy+'_'+varname[2]+'_'+timestampm1+'_'+cycle+'00.pnt'
         infile3 = wfo+'_'+wfobuoy+'_'+varname[3]+'_'+timestampm1+'_'+cycle+'00.pnt'
         infile4 = wfo+'_'+wfobuoy+'_'+varname[4]+'_'+timestampm1+'_'+cycle+'00.pnt'
         if os.path.isfile(infile):
            print('Reading file '+infile)
            print('Reading file '+infile1)
            print('Reading file '+infile2)
            print('Reading file '+infile3)
            print('Reading file '+infile4)
            datafound = 'true'
            fo  = open(workdir+infile, "r")
            fo1 = open(workdir+infile1, "r")
            fo2 = open(workdir+infile2, "r")
            fo3 = open(workdir+infile3, "r")
            fo4 = open(workdir+infile4, "r")
            for tstep in range(TDEF):
               # Hs
               line = fo.readline()
               linesplit = [s for s in re.split(r',val=', line) if s]
               modparm1[iwfobuoy][tstep] = float(linesplit[1])
               # Tp
               line = fo1.readline()
               linesplit = [s for s in re.split(r',val=', line) if s]
               modperm1[iwfobuoy][tstep] = float(linesplit[1])
               # Dir
               line = fo2.readline()
               linesplit = [s for s in re.split(r',val=', line) if s]
               moddirm1[iwfobuoy][tstep] = float(linesplit[1])
               # Wind
               line = fo3.readline()
               linesplit = [s for s in re.split(r',val=', line) if s]
               modwndm1[iwfobuoy][tstep] = float(linesplit[1])
               # WDir
               line = fo4.readline()
               linesplit = [s for s in re.split(r',val=', line) if s]
               modwdrm1[iwfobuoy][tstep] = float(linesplit[1])
               # Date (Add the forecast hour to the start of the cycle timestamp)
               date = datetime.datetime(int(timestampm1[0:4]),int(timestampm1[4:6]),int(timestampm1[6:8]),int(cycle))
               date = date + datetime.timedelta(hours=(tstep*tdelta))
               #modtimm1[iwfobuoy][tstep] = (date-datetime.datetime(1970,1,1)).total_seconds()
               modtimm1[iwfobuoy][tstep] = timedelta_total_seconds(date-datetime.datetime(1970,1,1))
               bcyclem1[iwfobuoy] = cycle
               # Remove SWAN exception values
               if (modparm1[iwfobuoy][tstep]<0.05) or (modparm1[iwfobuoy][tstep] == 9.999e+20):
                  modparm1[iwfobuoy][tstep]=np.nan
                  modperm1[iwfobuoy][tstep]=np.nan
                  moddirm1[iwfobuoy][tstep]=np.nan
                  modwndm1[iwfobuoy][tstep]=np.nan
                  modwdrm1[iwfobuoy][tstep]=np.nan
                  modtimm1[iwfobuoy][tstep] = np.nan
            fo.close()
            command = 'rm '+workdir+infile
            os.system(command)
            command = 'rm '+workdir+infile1
            os.system(command)
            command = 'rm '+workdir+infile2
            os.system(command)
            command = 'rm '+workdir+infile3
            os.system(command)
            command = 'rm '+workdir+infile4
            os.system(command)
         else:
            continue
      if (datafound == 'false'):
         print(' *** Warning: no model data found')
         for tstep in range(TDEF):
            modparm1[iwfobuoy][tstep] = np.nan
            modperm1[iwfobuoy][tstep] = np.nan
            moddirm1[iwfobuoy][tstep] = np.nan
            modwndm1[iwfobuoy][tstep] = np.nan
            modwdrm1[iwfobuoy][tstep] = np.nan
            modtimm1[iwfobuoy][tstep] = np.nan
         bcyclem1[iwfobuoy] = '00'   # Reset the cycle if no data is found
      #modpar(find(modpar==0.)) = NaN;

for single_date in daterange(startDatem2,startDatem2):

   # Comprehensions
   modtimm2 = [[0 for x in range(TDEF)] for x in range(len(wfos))]
   modparm2 = [[0 for x in range(TDEF)] for x in range(len(wfos))]
   modperm2 = [[0 for x in range(TDEF)] for x in range(len(wfos))]
   moddirm2 = [[0 for x in range(TDEF)] for x in range(len(wfos))]
   modwndm2 = [[0 for x in range(TDEF)] for x in range(len(wfos))]
   modwdrm2 = [[0 for x in range(TDEF)] for x in range(len(wfos))]

   timestampm2 = single_date.strftime("%Y%m%d")
   print('')
   print('Analysing '+timestampm2+'...')

   for iwfo in range(len(wfos)):
      print('')
      wfo=wfos[iwfo]
      iwfobuoy=iwfo
      wfobuoy=wfobuoys[iwfobuoy]
      print('Extracting '+region+'.'+timestampm2+', buoy '+wfobuoy+', on '+CGextract+':')

      for cycle in cycles:
         print('Checking cycle '+cycle)
         extdir=COMOUTm2+region+'.'+timestampm2+'/'+wfo+'/'+cycle+'/'+CGextract+'/'
         infile=wfo+'_nwps_'+CGextract+'_'+timestampm2+'_'+cycle+'00.grib2'

         if os.path.isfile(extdir+infile):
            #print('Data found. Extracting at buoy locations...')
            command = 'cp '+extdir+infile+' '+workdir
            os.system(command)

            command = '$WGRIB2 '+workdir+infile+'  -match "'+varname[0]+'" -lon '+wfobuoycoors[iwfobuoy]+'  > '+wfo+'_'+wfobuoy+'_'+varname[0]+'_'+timestampm2+'_'+cycle+'00.pnt'
            os.system(command)
            command = '$WGRIB2 '+workdir+infile+'  -match "'+varname[1]+'" -lon '+wfobuoycoors[iwfobuoy]+'  > '+wfo+'_'+wfobuoy+'_'+varname[1]+'_'+timestampm2+'_'+cycle+'00.pnt'
            os.system(command)
            command = '$WGRIB2 '+workdir+infile+'  -match "'+varname[2]+'" -lon '+wfobuoycoors[iwfobuoy]+'  > '+wfo+'_'+wfobuoy+'_'+varname[2]+'_'+timestampm2+'_'+cycle+'00.pnt'
            os.system(command)
            command = '$WGRIB2 '+workdir+infile+'  -match "'+varname[3]+'" -lon '+wfobuoycoors[iwfobuoy]+'  > '+wfo+'_'+wfobuoy+'_'+varname[3]+'_'+timestampm2+'_'+cycle+'00.pnt'
            os.system(command)
            command = '$WGRIB2 '+workdir+infile+'  -match "'+varname[4]+'" -lon '+wfobuoycoors[iwfobuoy]+'  > '+wfo+'_'+wfobuoy+'_'+varname[4]+'_'+timestampm2+'_'+cycle+'00.pnt'
            os.system(command)
            command = 'rm '+workdir+infile
            os.system(command)

            command = 'ls -lrt *.pnt'
            os.system(command)
            break

# ---------- Read NWPS model data into buoy-centered arrays ----------

   for iwfo in range(len(wfos)):
   #for ibuoy in range(len(allBuoys)):
      print('')
      wfo=wfos[iwfo]
      print('Reading pnt data from '+wfo+'.'+timestampm2+':')

      #for iwfobuoy in range(len(wfobuoys[iwfo][:])):
      iwfobuoy=iwfo
      wfobuoy=wfobuoys[iwfobuoy]
      #wfobuoy=allBuoys[ibuoy]
      datafound = 'false'

      for cycle in cycles:
         if datafound == 'true':
            continue
         print('Search for '+wfobuoy+' cycle '+cycle)
         infile  = wfo+'_'+wfobuoy+'_'+varname[0]+'_'+timestampm2+'_'+cycle+'00.pnt'
         infile1 = wfo+'_'+wfobuoy+'_'+varname[1]+'_'+timestampm2+'_'+cycle+'00.pnt'
         infile2 = wfo+'_'+wfobuoy+'_'+varname[2]+'_'+timestampm2+'_'+cycle+'00.pnt'
         infile3 = wfo+'_'+wfobuoy+'_'+varname[3]+'_'+timestampm2+'_'+cycle+'00.pnt'
         infile4 = wfo+'_'+wfobuoy+'_'+varname[4]+'_'+timestampm2+'_'+cycle+'00.pnt'
         if os.path.isfile(infile):
            print('Reading file '+infile)
            print('Reading file '+infile1)
            print('Reading file '+infile2)
            print('Reading file '+infile3)
            print('Reading file '+infile4)
            datafound = 'true'
            fo  = open(workdir+infile, "r")
            fo1 = open(workdir+infile1, "r")
            fo2 = open(workdir+infile2, "r")
            fo3 = open(workdir+infile3, "r")
            fo4 = open(workdir+infile4, "r")
            for tstep in range(TDEF):
               # Hs
               line = fo.readline()
               linesplit = [s for s in re.split(r',val=', line) if s]
               modparm2[iwfobuoy][tstep] = float(linesplit[1])
               # Tp
               line = fo1.readline()
               linesplit = [s for s in re.split(r',val=', line) if s]
               modperm2[iwfobuoy][tstep] = float(linesplit[1])
               # Dir
               line = fo2.readline()
               linesplit = [s for s in re.split(r',val=', line) if s]
               moddirm2[iwfobuoy][tstep] = float(linesplit[1])
               # Wind
               line = fo3.readline()
               linesplit = [s for s in re.split(r',val=', line) if s]
               modwndm2[iwfobuoy][tstep] = float(linesplit[1])
               # WDir
               line = fo4.readline()
               linesplit = [s for s in re.split(r',val=', line) if s]
               modwdrm2[iwfobuoy][tstep] = float(linesplit[1])
               # Date (Add the forecast hour to the start of the cycle timestamp)
               date = datetime.datetime(int(timestampm2[0:4]),int(timestampm2[4:6]),int(timestampm2[6:8]),int(cycle))
               date = date + datetime.timedelta(hours=(tstep*tdelta))
               #modtimm2[iwfobuoy][tstep] = (date-datetime.datetime(1970,1,1)).total_seconds()
               modtimm2[iwfobuoy][tstep] = timedelta_total_seconds(date-datetime.datetime(1970,1,1))
               bcyclem2[iwfobuoy] = cycle
               # Remove SWAN exception values
               if modparm2[iwfobuoy][tstep]<0.05:
                  modparm2[iwfobuoy][tstep]=np.nan
                  modperm2[iwfobuoy][tstep]=np.nan
                  moddirm2[iwfobuoy][tstep]=np.nan
                  modwndm2[iwfobuoy][tstep]=np.nan
                  modwdrm2[iwfobuoy][tstep]=np.nan
                  modtimm2[iwfobuoy][tstep]=np.nan
            fo.close()
            command = 'rm '+workdir+infile
            os.system(command)
            command = 'rm '+workdir+infile1
            os.system(command)
            command = 'rm '+workdir+infile2
            os.system(command)
            command = 'rm '+workdir+infile3
            os.system(command)
            command = 'rm '+workdir+infile4
            os.system(command)

            command = 'ls -lrt *.pnt'
            os.system(command)
         else:
            continue
      if (datafound == 'false'):
         print(' *** Warning: no model data found')
         for tstep in range(TDEF):
            modparm2[iwfobuoy][tstep] = np.nan
            modperm2[iwfobuoy][tstep] = np.nan
            moddirm2[iwfobuoy][tstep] = np.nan
            modwndm2[iwfobuoy][tstep] = np.nan
            modwdrm2[iwfobuoy][tstep] = np.nan
            modtimm2[iwfobuoy][tstep] = np.nan
         bcyclem2[iwfobuoy] = '00'   # Reset the cycle if no data is found
      #modpar(find(modpar==0.)) = NaN;

# -------- Extract WW3 Multi_1 data ---------------
for single_date in daterange(startDate,startDate):

   # Comprehensions
   ww1tim = [[0 for x in range(TDEF2)] for x in range(len(wfos))]
   ww1par = [[0 for x in range(TDEF2)] for x in range(len(wfos))]
   ww1per = [[0 for x in range(TDEF2)] for x in range(len(wfos))]
   ww1dir = [[0 for x in range(TDEF2)] for x in range(len(wfos))]
   ww1wnd = [[0 for x in range(TDEF2)] for x in range(len(wfos))]
   ww1wdr = [[0 for x in range(TDEF2)] for x in range(len(wfos))]

   timestamp = single_date.strftime("%Y%m%d")
   print('')
   print('Analysing '+timestamp+'...')

   for iwfo in range(len(wfos)):
      print('')
      wfo=wfos[iwfo]
      iwfobuoy=iwfo
      wfobuoy=wfobuoys[iwfobuoy]
      if region == 'sr':
         wwgrid = 'atlocn.0p16'
      elif region == 'er':
         wwgrid = 'atlocn.0p16'
      elif region == 'ar':
         wwgrid = 'global.0p25'
      elif region == 'wr':
         wwgrid = 'wcoast.0p16'
      elif (region == 'pr') and (wfo == 'hfo'):
         wwgrid = 'epacif.0p16'
      elif (region == 'pr') and (wfo == 'gum'):
         wwgrid = 'global.0p16'
      cycle = '00'
      print('Extracting gfswave.t'+cycle+'z.'+wwgrid+'.f???.grib2'+', for WFO '+wfo+', buoy '+wfobuoy+':')

      for tstep in range(TDEF2):
         #print('Hour: '+fhours[tstep])
         extdir=workdir
         infile=timestamp+'.gfswave.t'+cycle+'z.'+wwgrid+'.f'+fhours[tstep]+'.grib2'
         print('Searching for '+infile)

         if os.path.isfile(extdir+infile):
            #print('Data found. Extracting at buoy locations...')
            #command = 'cp '+extdir+infile+' '+workdir
            #os.system(command)

            #+'00_f'+fhours[tstep-1]+'.pnt'

            if tstep == 0:
               command = '$WGRIB2 '+workdir+infile+'  -match "'+varname[0]+'" -lon '+wfobuoycoors[iwfobuoy]+'  > wwm1_'+wfo+'_'+wfobuoy+'_'+varname[0]+'_'+timestamp+'_'+cycle+'00'+'.pnt'
               os.system(command)
               command = '$WGRIB2 '+workdir+infile+'  -match "'+varname[1]+'" -lon '+wfobuoycoors[iwfobuoy]+'  > wwm1_'+wfo+'_'+wfobuoy+'_'+varname[1]+'_'+timestamp+'_'+cycle+'00'+'.pnt'
               os.system(command)
               command = '$WGRIB2 '+workdir+infile+'  -match "'+varname[2]+'" -lon '+wfobuoycoors[iwfobuoy]+'  > wwm1_'+wfo+'_'+wfobuoy+'_'+varname[2]+'_'+timestamp+'_'+cycle+'00'+'.pnt'
               os.system(command)
               command = '$WGRIB2 '+workdir+infile+'  -match "'+varname[3]+'" -lon '+wfobuoycoors[iwfobuoy]+'  > wwm1_'+wfo+'_'+wfobuoy+'_'+varname[3]+'_'+timestamp+'_'+cycle+'00'+'.pnt'
               os.system(command)
               command = '$WGRIB2 '+workdir+infile+'  -match "'+varname[4]+'" -lon '+wfobuoycoors[iwfobuoy]+'  > wwm1_'+wfo+'_'+wfobuoy+'_'+varname[4]+'_'+timestamp+'_'+cycle+'00'+'.pnt'
               os.system(command)

            else:
               command = '$WGRIB2 '+workdir+infile+'  -match "'+varname[0]+'" -lon '+wfobuoycoors[iwfobuoy]+'  >> wwm1_'+wfo+'_'+wfobuoy+'_'+varname[0]+'_'+timestamp+'_'+cycle+'00'+'.pnt'
               os.system(command)
               command = '$WGRIB2 '+workdir+infile+'  -match "'+varname[1]+'" -lon '+wfobuoycoors[iwfobuoy]+'  >> wwm1_'+wfo+'_'+wfobuoy+'_'+varname[1]+'_'+timestamp+'_'+cycle+'00'+'.pnt'
               os.system(command)
               command = '$WGRIB2 '+workdir+infile+'  -match "'+varname[2]+'" -lon '+wfobuoycoors[iwfobuoy]+'  >> wwm1_'+wfo+'_'+wfobuoy+'_'+varname[2]+'_'+timestamp+'_'+cycle+'00'+'.pnt'
               os.system(command)
               command = '$WGRIB2 '+workdir+infile+'  -match "'+varname[3]+'" -lon '+wfobuoycoors[iwfobuoy]+'  >> wwm1_'+wfo+'_'+wfobuoy+'_'+varname[3]+'_'+timestamp+'_'+cycle+'00'+'.pnt'
               os.system(command)
               command = '$WGRIB2 '+workdir+infile+'  -match "'+varname[4]+'" -lon '+wfobuoycoors[iwfobuoy]+'  >> wwm1_'+wfo+'_'+wfobuoy+'_'+varname[4]+'_'+timestamp+'_'+cycle+'00'+'.pnt'
               os.system(command)

            #command = 'rm '+workdir+infile
            #os.system(command)

            #command = 'ls -lrt *.pnt'
            #os.system(command)

# ---------- Read WW3 Multi_1 data into buoy-centered arrays ----------

   for iwfo in range(len(wfos)):
   #for ibuoy in range(len(allBuoys)):
      print('')
      wfo=wfos[iwfo]
      print('Reading pnt data from gfswave.t'+cycle+'z.'+wwgrid+'.f???.grib2'+', for WFO '+wfo+', buoy '+wfobuoy+':')

      #for iwfobuoy in range(len(wfobuoys[iwfo][:])):
      iwfobuoy=iwfo
      wfobuoy=wfobuoys[iwfobuoy]
      #wfobuoy=allBuoys[ibuoy]
      cycle = '00'
      datafound = 'false'

      print('Search for '+wfobuoy+' cycle '+cycle)
      infile  = 'wwm1_'+wfo+'_'+wfobuoy+'_'+varname[0]+'_'+timestamp+'_'+cycle+'00'+'.pnt'
      infile1 = 'wwm1_'+wfo+'_'+wfobuoy+'_'+varname[1]+'_'+timestamp+'_'+cycle+'00'+'.pnt'
      infile2 = 'wwm1_'+wfo+'_'+wfobuoy+'_'+varname[2]+'_'+timestamp+'_'+cycle+'00'+'.pnt'
      infile3 = 'wwm1_'+wfo+'_'+wfobuoy+'_'+varname[3]+'_'+timestamp+'_'+cycle+'00'+'.pnt'
      infile4 = 'wwm1_'+wfo+'_'+wfobuoy+'_'+varname[4]+'_'+timestamp+'_'+cycle+'00'+'.pnt'
      if os.path.isfile(infile):
         print('Reading file '+infile)
         print('Reading file '+infile1)
         print('Reading file '+infile2)
         print('Reading file '+infile3)
         print('Reading file '+infile4)
         datafound = 'true'
         fo  = open(workdir+infile, "r")
         fo1 = open(workdir+infile1, "r")
         fo2 = open(workdir+infile2, "r")
         fo3 = open(workdir+infile3, "r")
         fo4 = open(workdir+infile4, "r")
         for tstep in range(TDEF2):
            # Hs
            line = fo.readline()
            linesplit = [s for s in re.split(r',val=', line) if s]
            ww1par[iwfobuoy][tstep] = float(linesplit[1])
            # Tp
            line = fo1.readline()
            linesplit = [s for s in re.split(r',val=', line) if s]
            ww1per[iwfobuoy][tstep] = float(linesplit[1])
            # Dir
            line = fo2.readline()
            linesplit = [s for s in re.split(r',val=', line) if s]
            ww1dir[iwfobuoy][tstep] = float(linesplit[1])
            # Wind
            line = fo3.readline()
            linesplit = [s for s in re.split(r',val=', line) if s]
            ww1wnd[iwfobuoy][tstep] = float(linesplit[1])
            # WDir
            line = fo4.readline()
            linesplit = [s for s in re.split(r',val=', line) if s]
            ww1wdr[iwfobuoy][tstep] = float(linesplit[1])
            # Date (Add the forecast hour to the start of the cycle timestamp)
            date = datetime.datetime(int(timestamp[0:4]),int(timestamp[4:6]),int(timestamp[6:8]),int(cycle))
            date = date + datetime.timedelta(hours=(tstep*tdelta2))
            #ww1tim[iwfobuoy][tstep] = (date-datetime.datetime(1970,1,1)).total_seconds()
            ww1tim[iwfobuoy][tstep] = timedelta_total_seconds(date-datetime.datetime(1970,1,1))
            ww1cycle[iwfobuoy] = cycle
            # Remove WW3 exception values
            if (ww1par[iwfobuoy][tstep]<0.05) or (ww1par[iwfobuoy][tstep]==9.999e+20):
               ww1par[iwfobuoy][tstep]=np.nan
               ww1per[iwfobuoy][tstep]=np.nan
               ww1dir[iwfobuoy][tstep]=np.nan
               ww1wnd[iwfobuoy][tstep]=np.nan
               ww1wdr[iwfobuoy][tstep]=np.nan
               ww1tim[iwfobuoy][tstep] = np.nan
         fo.close()
         command = 'rm '+workdir+infile
         os.system(command)
         command = 'rm '+workdir+infile1
         os.system(command)
         command = 'rm '+workdir+infile2
         os.system(command)
         command = 'rm '+workdir+infile3
         os.system(command)
         command = 'rm '+workdir+infile4
         os.system(command)

         command = 'ls -lrt *.pnt'
         os.system(command)
      else:
         continue
   if (datafound == 'false'):
      print(' *** Warning: no model data found')
      for tstep in range(TDEF2):
         ww1par[iwfobuoy][tstep] = np.nan
         ww1per[iwfobuoy][tstep] = np.nan
         ww1dir[iwfobuoy][tstep] = np.nan
         ww1wnd[iwfobuoy][tstep] = np.nan
         ww1wdr[iwfobuoy][tstep] = np.nan
         ww1tim[iwfobuoy][tstep] = np.nan
      ww1cycle[iwfobuoy] = '00'   # Reset the cycle if no data is found
   #ww1par(find(ww1par==0.)) = NaN;

# -------- Extract WW3 Multi_1 data ---------------
for single_date in daterange(startDatem1,startDatem1):

   # Comprehensions
   ww1timm1 = [[0 for x in range(TDEF2)] for x in range(len(wfos))]
   ww1parm1 = [[0 for x in range(TDEF2)] for x in range(len(wfos))]
   ww1perm1 = [[0 for x in range(TDEF2)] for x in range(len(wfos))]
   ww1dirm1 = [[0 for x in range(TDEF2)] for x in range(len(wfos))]
   ww1wndm1 = [[0 for x in range(TDEF2)] for x in range(len(wfos))]
   ww1wdrm1 = [[0 for x in range(TDEF2)] for x in range(len(wfos))]

   timestampm1 = single_date.strftime("%Y%m%d")
   print('')
   print('Analysing '+timestampm1+'...')

   for iwfo in range(len(wfos)):
      print('')
      wfo=wfos[iwfo]
      iwfobuoy=iwfo
      wfobuoy=wfobuoys[iwfobuoy]
      if region == 'sr':
         wwgrid = 'atlocn.0p16'
      elif region == 'er':
         wwgrid = 'atlocn.0p16'
      elif region == 'ar':
         wwgrid = 'global.0p25'
      elif region == 'wr':
         wwgrid = 'wcoast.0p16'
      elif (region == 'pr') and (wfo == 'hfo'):
         wwgrid = 'epacif.0p16'
      elif (region == 'pr') and (wfo == 'gum'):
         wwgrid = 'global.0p16'
      cycle = '00'
      print('Extracting gfswave.t'+cycle+'z.'+wwgrid+'.f???.grib2'+', for WFO '+wfo+', buoy '+wfobuoy+':')

      for tstep in range(TDEF2):
         #print('Hour: '+fhours[tstep])
         extdir=workdir
         infile=timestampm1+'.gfswave.t'+cycle+'z.'+wwgrid+'.f'+fhours[tstep]+'.grib2'
         print('Searching for '+infile)

         if os.path.isfile(extdir+infile):
            #print('Data found. Extracting at buoy locations...')
            #command = 'cp '+extdir+infile+' '+workdir
            #os.system(command)

            #+'00_f'+fhours[tstep-1]+'.pnt'

            if tstep == 0:
               command = '$WGRIB2 '+workdir+infile+'  -match "'+varname[0]+'" -lon '+wfobuoycoors[iwfobuoy]+'  > wwm1_'+wfo+'_'+wfobuoy+'_'+varname[0]+'_'+timestampm1+'_'+cycle+'00'+'.pnt'
               os.system(command)
               command = '$WGRIB2 '+workdir+infile+'  -match "'+varname[1]+'" -lon '+wfobuoycoors[iwfobuoy]+'  > wwm1_'+wfo+'_'+wfobuoy+'_'+varname[1]+'_'+timestampm1+'_'+cycle+'00'+'.pnt'
               os.system(command)
               command = '$WGRIB2 '+workdir+infile+'  -match "'+varname[2]+'" -lon '+wfobuoycoors[iwfobuoy]+'  > wwm1_'+wfo+'_'+wfobuoy+'_'+varname[2]+'_'+timestampm1+'_'+cycle+'00'+'.pnt'
               os.system(command)
               command = '$WGRIB2 '+workdir+infile+'  -match "'+varname[3]+'" -lon '+wfobuoycoors[iwfobuoy]+'  > wwm1_'+wfo+'_'+wfobuoy+'_'+varname[3]+'_'+timestampm1+'_'+cycle+'00'+'.pnt'
               os.system(command)
               command = '$WGRIB2 '+workdir+infile+'  -match "'+varname[4]+'" -lon '+wfobuoycoors[iwfobuoy]+'  > wwm1_'+wfo+'_'+wfobuoy+'_'+varname[4]+'_'+timestampm1+'_'+cycle+'00'+'.pnt'
               os.system(command)

            else:
               command = '$WGRIB2 '+workdir+infile+'  -match "'+varname[0]+'" -lon '+wfobuoycoors[iwfobuoy]+'  >> wwm1_'+wfo+'_'+wfobuoy+'_'+varname[0]+'_'+timestampm1+'_'+cycle+'00'+'.pnt'
               os.system(command)
               command = '$WGRIB2 '+workdir+infile+'  -match "'+varname[1]+'" -lon '+wfobuoycoors[iwfobuoy]+'  >> wwm1_'+wfo+'_'+wfobuoy+'_'+varname[1]+'_'+timestampm1+'_'+cycle+'00'+'.pnt'
               os.system(command)
               command = '$WGRIB2 '+workdir+infile+'  -match "'+varname[2]+'" -lon '+wfobuoycoors[iwfobuoy]+'  >> wwm1_'+wfo+'_'+wfobuoy+'_'+varname[2]+'_'+timestampm1+'_'+cycle+'00'+'.pnt'
               os.system(command)
               command = '$WGRIB2 '+workdir+infile+'  -match "'+varname[3]+'" -lon '+wfobuoycoors[iwfobuoy]+'  >> wwm1_'+wfo+'_'+wfobuoy+'_'+varname[3]+'_'+timestampm1+'_'+cycle+'00'+'.pnt'
               os.system(command)
               command = '$WGRIB2 '+workdir+infile+'  -match "'+varname[4]+'" -lon '+wfobuoycoors[iwfobuoy]+'  >> wwm1_'+wfo+'_'+wfobuoy+'_'+varname[4]+'_'+timestampm1+'_'+cycle+'00'+'.pnt'
               os.system(command)

            #command = 'rm '+workdir+infile
            #os.system(command)

            #command = 'ls -lrt *.pnt'
            #os.system(command)

# ---------- Read WW3 Multi_1 data into buoy-centered arrays ----------

   for iwfo in range(len(wfos)):
   #for ibuoy in range(len(allBuoys)):
      print('')
      wfo=wfos[iwfo]
      print('Reading pnt data from gfswave.t'+cycle+'z.'+wwgrid+'.f???.grib2'+', for WFO '+wfo+', buoy '+wfobuoy+':')

      #for iwfobuoy in range(len(wfobuoys[iwfo][:])):
      iwfobuoy=iwfo
      wfobuoy=wfobuoys[iwfobuoy]
      #wfobuoy=allBuoys[ibuoy]
      cycle = '00'
      datafound = 'false'

      print('Search for '+wfobuoy+' cycle '+cycle)
      infile  = 'wwm1_'+wfo+'_'+wfobuoy+'_'+varname[0]+'_'+timestampm1+'_'+cycle+'00'+'.pnt'
      infile1 = 'wwm1_'+wfo+'_'+wfobuoy+'_'+varname[1]+'_'+timestampm1+'_'+cycle+'00'+'.pnt'
      infile2 = 'wwm1_'+wfo+'_'+wfobuoy+'_'+varname[2]+'_'+timestampm1+'_'+cycle+'00'+'.pnt'
      infile3 = 'wwm1_'+wfo+'_'+wfobuoy+'_'+varname[3]+'_'+timestampm1+'_'+cycle+'00'+'.pnt'
      infile4 = 'wwm1_'+wfo+'_'+wfobuoy+'_'+varname[4]+'_'+timestampm1+'_'+cycle+'00'+'.pnt'
      if os.path.isfile(infile):
         print('Reading file '+infile)
         print('Reading file '+infile1)
         print('Reading file '+infile2)
         print('Reading file '+infile3)
         print('Reading file '+infile4)
         datafound = 'true'
         fo  = open(workdir+infile, "r")
         fo1 = open(workdir+infile1, "r")
         fo2 = open(workdir+infile2, "r")
         fo3 = open(workdir+infile3, "r")
         fo4 = open(workdir+infile4, "r")
         for tstep in range(TDEF2):
            # Hs
            line = fo.readline()
            linesplit = [s for s in re.split(r',val=', line) if s]
            ww1parm1[iwfobuoy][tstep] = float(linesplit[1])
            # Tp
            line = fo1.readline()
            linesplit = [s for s in re.split(r',val=', line) if s]
            ww1perm1[iwfobuoy][tstep] = float(linesplit[1])
            # Dir
            line = fo2.readline()
            linesplit = [s for s in re.split(r',val=', line) if s]
            ww1dirm1[iwfobuoy][tstep] = float(linesplit[1])
            # Wind
            line = fo3.readline()
            linesplit = [s for s in re.split(r',val=', line) if s]
            ww1wndm1[iwfobuoy][tstep] = float(linesplit[1])
            # WDir
            line = fo4.readline()
            linesplit = [s for s in re.split(r',val=', line) if s]
            ww1wdrm1[iwfobuoy][tstep] = float(linesplit[1])
            # Date (Add the forecast hour to the start of the cycle timestampm1)
            date = datetime.datetime(int(timestampm1[0:4]),int(timestampm1[4:6]),int(timestampm1[6:8]),int(cycle))
            date = date + datetime.timedelta(hours=(tstep*tdelta2))
            #ww1tim[iwfobuoy][tstep] = (date-datetime.datetime(1970,1,1)).total_seconds()
            ww1timm1[iwfobuoy][tstep] = timedelta_total_seconds(date-datetime.datetime(1970,1,1))
            ww1cyclem1[iwfobuoy] = cycle
            # Remove SWAN exception values
            if (ww1parm1[iwfobuoy][tstep]<0.05) or (ww1parm1[iwfobuoy][tstep]==9.999e+20):
               ww1parm1[iwfobuoy][tstep]=np.nan
               ww1perm1[iwfobuoy][tstep]=np.nan
               ww1dirm1[iwfobuoy][tstep]=np.nan
               ww1wndm1[iwfobuoy][tstep]=np.nan
               ww1wdrm1[iwfobuoy][tstep]=np.nan
               ww1timm1[iwfobuoy][tstep] = np.nan
         fo.close()
         command = 'rm '+workdir+infile
         os.system(command)
         command = 'rm '+workdir+infile1
         os.system(command)
         command = 'rm '+workdir+infile2
         os.system(command)
         command = 'rm '+workdir+infile3
         os.system(command)
         command = 'rm '+workdir+infile4
         os.system(command)

         command = 'ls -lrt *.pnt'
         os.system(command)
      else:
         continue
   if (datafound == 'false'):
      print(' *** Warning: no model data found')
      for tstep in range(TDEF2):
         ww1parm1[iwfobuoy][tstep] = np.nan
         ww1perm1[iwfobuoy][tstep] = np.nan
         ww1dirm1[iwfobuoy][tstep] = np.nan
         ww1wndm1[iwfobuoy][tstep] = np.nan
         ww1wdrm1[iwfobuoy][tstep] = np.nan
         ww1timm1[iwfobuoy][tstep] = np.nan
      ww1cyclem1[iwfobuoy] = '00'   # Reset the cycle if no data is found
   #ww1par(find(ww1par==0.)) = NaN;

# -------- Extract WW3 Multi_1 data ---------------
for single_date in daterange(startDatem2,startDatem2):

   # Comprehensions
   ww1timm2 = [[0 for x in range(TDEF2)] for x in range(len(wfos))]
   ww1parm2 = [[0 for x in range(TDEF2)] for x in range(len(wfos))]
   ww1perm2 = [[0 for x in range(TDEF2)] for x in range(len(wfos))]
   ww1dirm2 = [[0 for x in range(TDEF2)] for x in range(len(wfos))]
   ww1wndm2 = [[0 for x in range(TDEF2)] for x in range(len(wfos))]
   ww1wdrm2 = [[0 for x in range(TDEF2)] for x in range(len(wfos))]

   timestampm2 = single_date.strftime("%Y%m%d")
   print('')
   print('Analysing '+timestampm2+'...')

   for iwfo in range(len(wfos)):
      print('')
      wfo=wfos[iwfo]
      iwfobuoy=iwfo
      wfobuoy=wfobuoys[iwfobuoy]
      if region == 'sr':
         wwgrid = 'atlocn.0p16'
      elif region == 'er':
         wwgrid = 'atlocn.0p16'
      elif region == 'ar':
         wwgrid = 'global.0p25'
      elif region == 'wr':
         wwgrid = 'wcoast.0p16'
      elif (region == 'pr') and (wfo == 'hfo'):
         wwgrid = 'epacif.0p16'
      elif (region == 'pr') and (wfo == 'gum'):
         wwgrid = 'global.0p16'
      cycle = '00'
      print('Extracting gfswave.t'+cycle+'z.'+wwgrid+'.f???.grib2'+', for WFO '+wfo+', buoy '+wfobuoy+':')

      for tstep in range(TDEF2):
         #print('Hour: '+fhours[tstep])
         extdir=workdir
         infile=timestampm2+'.gfswave.t'+cycle+'z.'+wwgrid+'.f'+fhours[tstep]+'.grib2'
         print('Searching for '+infile)

         if os.path.isfile(extdir+infile):
            #print('Data found. Extracting at buoy locations...')
            #command = 'cp '+extdir+infile+' '+workdir
            #os.system(command)

            #+'00_f'+fhours[tstep-1]+'.pnt'

            if tstep == 0:
               command = '$WGRIB2 '+workdir+infile+'  -match "'+varname[0]+'" -lon '+wfobuoycoors[iwfobuoy]+'  > wwm2_'+wfo+'_'+wfobuoy+'_'+varname[0]+'_'+timestampm2+'_'+cycle+'00'+'.pnt'
               os.system(command)
               command = '$WGRIB2 '+workdir+infile+'  -match "'+varname[1]+'" -lon '+wfobuoycoors[iwfobuoy]+'  > wwm2_'+wfo+'_'+wfobuoy+'_'+varname[1]+'_'+timestampm2+'_'+cycle+'00'+'.pnt'
               os.system(command)
               command = '$WGRIB2 '+workdir+infile+'  -match "'+varname[2]+'" -lon '+wfobuoycoors[iwfobuoy]+'  > wwm2_'+wfo+'_'+wfobuoy+'_'+varname[2]+'_'+timestampm2+'_'+cycle+'00'+'.pnt'
               os.system(command)
               command = '$WGRIB2 '+workdir+infile+'  -match "'+varname[3]+'" -lon '+wfobuoycoors[iwfobuoy]+'  > wwm2_'+wfo+'_'+wfobuoy+'_'+varname[3]+'_'+timestampm2+'_'+cycle+'00'+'.pnt'
               os.system(command)
               command = '$WGRIB2 '+workdir+infile+'  -match "'+varname[4]+'" -lon '+wfobuoycoors[iwfobuoy]+'  > wwm2_'+wfo+'_'+wfobuoy+'_'+varname[4]+'_'+timestampm2+'_'+cycle+'00'+'.pnt'
               os.system(command)

            else:
               command = '$WGRIB2 '+workdir+infile+'  -match "'+varname[0]+'" -lon '+wfobuoycoors[iwfobuoy]+'  >> wwm2_'+wfo+'_'+wfobuoy+'_'+varname[0]+'_'+timestampm2+'_'+cycle+'00'+'.pnt'
               os.system(command)
               command = '$WGRIB2 '+workdir+infile+'  -match "'+varname[1]+'" -lon '+wfobuoycoors[iwfobuoy]+'  >> wwm2_'+wfo+'_'+wfobuoy+'_'+varname[1]+'_'+timestampm2+'_'+cycle+'00'+'.pnt'
               os.system(command)
               command = '$WGRIB2 '+workdir+infile+'  -match "'+varname[2]+'" -lon '+wfobuoycoors[iwfobuoy]+'  >> wwm2_'+wfo+'_'+wfobuoy+'_'+varname[2]+'_'+timestampm2+'_'+cycle+'00'+'.pnt'
               os.system(command)
               command = '$WGRIB2 '+workdir+infile+'  -match "'+varname[3]+'" -lon '+wfobuoycoors[iwfobuoy]+'  >> wwm2_'+wfo+'_'+wfobuoy+'_'+varname[3]+'_'+timestampm2+'_'+cycle+'00'+'.pnt'
               os.system(command)
               command = '$WGRIB2 '+workdir+infile+'  -match "'+varname[4]+'" -lon '+wfobuoycoors[iwfobuoy]+'  >> wwm2_'+wfo+'_'+wfobuoy+'_'+varname[4]+'_'+timestampm2+'_'+cycle+'00'+'.pnt'
               os.system(command)

            command = 'rm '+workdir+infile
            os.system(command)

            #command = 'ls -lrt *.pnt'
            #os.system(command)

# ---------- Read WW3 Multi_1 data into buoy-centered arrays ----------

   for iwfo in range(len(wfos)):
   #for ibuoy in range(len(allBuoys)):
      print('')
      wfo=wfos[iwfo]
      print('Reading pnt data from gfswave.t'+cycle+'z.'+wwgrid+'.f???.grib2'+', for WFO '+wfo+', buoy '+wfobuoy+':')

      #for iwfobuoy in range(len(wfobuoys[iwfo][:])):
      iwfobuoy=iwfo
      wfobuoy=wfobuoys[iwfobuoy]
      #wfobuoy=allBuoys[ibuoy]
      cycle = '00'
      datafound = 'false'

      print('Search for '+wfobuoy+' cycle '+cycle)
      infile  = 'wwm2_'+wfo+'_'+wfobuoy+'_'+varname[0]+'_'+timestampm2+'_'+cycle+'00'+'.pnt'
      infile1 = 'wwm2_'+wfo+'_'+wfobuoy+'_'+varname[1]+'_'+timestampm2+'_'+cycle+'00'+'.pnt'
      infile2 = 'wwm2_'+wfo+'_'+wfobuoy+'_'+varname[2]+'_'+timestampm2+'_'+cycle+'00'+'.pnt'
      infile3 = 'wwm2_'+wfo+'_'+wfobuoy+'_'+varname[3]+'_'+timestampm2+'_'+cycle+'00'+'.pnt'
      infile4 = 'wwm2_'+wfo+'_'+wfobuoy+'_'+varname[4]+'_'+timestampm2+'_'+cycle+'00'+'.pnt'
      if os.path.isfile(infile):
         print('Reading file '+infile)
         print('Reading file '+infile1)
         print('Reading file '+infile2)
         print('Reading file '+infile3)
         print('Reading file '+infile4)
         datafound = 'true'
         fo  = open(workdir+infile, "r")
         fo1 = open(workdir+infile1, "r")
         fo2 = open(workdir+infile2, "r")
         fo3 = open(workdir+infile3, "r")
         fo4 = open(workdir+infile4, "r")
         for tstep in range(TDEF2):
            # Hs
            line = fo.readline()
            linesplit = [s for s in re.split(r',val=', line) if s]
            ww1parm2[iwfobuoy][tstep] = float(linesplit[1])
            # Tp
            line = fo1.readline()
            linesplit = [s for s in re.split(r',val=', line) if s]
            ww1perm2[iwfobuoy][tstep] = float(linesplit[1])
            # Dir
            line = fo2.readline()
            linesplit = [s for s in re.split(r',val=', line) if s]
            ww1dirm2[iwfobuoy][tstep] = float(linesplit[1])
            # Wind
            line = fo3.readline()
            linesplit = [s for s in re.split(r',val=', line) if s]
            ww1wndm2[iwfobuoy][tstep] = float(linesplit[1])
            # WDir
            line = fo4.readline()
            linesplit = [s for s in re.split(r',val=', line) if s]
            ww1wdrm2[iwfobuoy][tstep] = float(linesplit[1])
            # Date (Add the forecast hour to the start of the cycle timestampm2)
            date = datetime.datetime(int(timestampm2[0:4]),int(timestampm2[4:6]),int(timestampm2[6:8]),int(cycle))
            date = date + datetime.timedelta(hours=(tstep*tdelta2))
            #ww1tim[iwfobuoy][tstep] = (date-datetime.datetime(1970,1,1)).total_seconds()
            ww1timm2[iwfobuoy][tstep] = timedelta_total_seconds(date-datetime.datetime(1970,1,1))
            ww1cyclem2[iwfobuoy] = cycle
            # Remove SWAN exception values
            if (ww1parm2[iwfobuoy][tstep]<0.05) or (ww1parm2[iwfobuoy][tstep]==9.999e+20):
               ww1parm2[iwfobuoy][tstep]=np.nan
               ww1perm2[iwfobuoy][tstep]=np.nan
               ww1dirm2[iwfobuoy][tstep]=np.nan
               ww1wndm2[iwfobuoy][tstep]=np.nan
               ww1wdrm2[iwfobuoy][tstep]=np.nan
               ww1timm2[iwfobuoy][tstep] = np.nan
         fo.close()
         command = 'rm '+workdir+infile
         os.system(command)
         command = 'rm '+workdir+infile1
         os.system(command)
         command = 'rm '+workdir+infile2
         os.system(command)
         command = 'rm '+workdir+infile3
         os.system(command)
         command = 'rm '+workdir+infile4
         os.system(command)

         command = 'ls -lrt *.pnt'
         os.system(command)
      else:
         continue
   if (datafound == 'false'):
      print(' *** Warning: no model data found')
      for tstep in range(TDEF2):
         ww1parm2[iwfobuoy][tstep] = np.nan
         ww1perm2[iwfobuoy][tstep] = np.nan
         ww1dirm2[iwfobuoy][tstep] = np.nan
         ww1wndm2[iwfobuoy][tstep] = np.nan
         ww1wdrm2[iwfobuoy][tstep] = np.nan
         ww1timm2[iwfobuoy][tstep] = np.nan
      ww1cyclem2[iwfobuoy] = '00'   # Reset the cycle if no data is found
   #ww1par(find(ww1par==0.)) = NaN;


# ---------- Plot time series at buoy ----------
print('Plotting data...')

convfac = 1/0.3048   #meters to feet
convfac2 = 1.9438     #m/s to knots
if (not np.isnan(modparm2[iwfobuoy][0])):
   pltrange = 0
   pltrangem1 = 0
   pltrangem2 = TDEF
if (not np.isnan(modparm1[iwfobuoy][0])):
   pltrange = 0
   pltrangem1 = TDEF
   pltrangem2 = 49
if (not np.isnan(modpar[iwfobuoy][0])):
   pltrange = TDEF
   pltrangem1 = 49
   pltrangem2 = 49

ww1pltrange = 0
ww1pltrangem1 = 0
ww1pltrangem2 = 0
if (not np.isnan(ww1parm1[iwfobuoy][0])):
   ww1pltrange = 0
   ww1pltrangem1 = TDEF2
   ww1pltrangem2 = 9
if (not np.isnan(ww1par[iwfobuoy][0])):
   ww1pltrange = TDEF2
   ww1pltrangem1 = 9
   ww1pltrangem2 = 9

modparft = [x*convfac for x in modpar[iwfobuoy][0:pltrange]]
modperft = [x for x in modper[iwfobuoy][0:pltrange]]
moddirft = [x for x in moddir[iwfobuoy][0:pltrange]]
modwndft = [x*convfac2 for x in modwnd[iwfobuoy][0:pltrange]]
modwdrft = [(270.-x)*(np.pi/180.) for x in modwdr[iwfobuoy][0:pltrange]]

modparftm1 = [x*convfac for x in modparm1[iwfobuoy][0:pltrangem1]]
modperftm1 = [x for x in modperm1[iwfobuoy][0:pltrangem1]]
moddirftm1 = [x for x in moddirm1[iwfobuoy][0:pltrangem1]]
modwndftm1 = [x*convfac2 for x in modwndm1[iwfobuoy][0:pltrangem1]]
modwdrftm1 = [(270.-x)*(np.pi/180.) for x in modwdrm1[iwfobuoy][0:pltrangem1]]

modparftm2 = [x*convfac for x in modparm2[iwfobuoy][0:pltrangem2]]
modperftm2 = [x for x in modperm2[iwfobuoy][0:pltrangem2]]
moddirftm2 = [x for x in moddirm2[iwfobuoy][0:pltrangem2]]
modwndftm2 = [x*convfac2 for x in modwndm2[iwfobuoy][0:pltrangem2]]
modwdrftm2 = [(270.-x)*(np.pi/180.) for x in modwdrm2[iwfobuoy][0:pltrangem2]]

ww1parft = [x*convfac for x in ww1par[iwfobuoy][0:ww1pltrange]]
ww1perft = [x for x in ww1per[iwfobuoy][0:ww1pltrange]]
ww1dirft = [x for x in ww1dir[iwfobuoy][0:ww1pltrange]]
ww1wndft = [x*convfac2 for x in ww1wnd[iwfobuoy][0:ww1pltrange]]
ww1wdrft = [(270.-x)*(np.pi/180.) for x in ww1wdr[iwfobuoy][0:ww1pltrange]]

ww1parftm1 = [x*convfac for x in ww1parm1[iwfobuoy][0:ww1pltrangem1]]
ww1perftm1 = [x for x in ww1perm1[iwfobuoy][0:ww1pltrangem1]]
ww1dirftm1 = [x for x in ww1dirm1[iwfobuoy][0:ww1pltrangem1]]
ww1wndftm1 = [x*convfac2 for x in ww1wndm1[iwfobuoy][0:ww1pltrangem1]]
ww1wdrftm1 = [(270.-x)*(np.pi/180.) for x in ww1wdrm1[iwfobuoy][0:ww1pltrangem1]]

ww1parftm2 = [x*convfac for x in ww1parm2[iwfobuoy][0:ww1pltrangem2]]
ww1perftm2 = [x for x in ww1perm2[iwfobuoy][0:ww1pltrangem2]]
ww1dirftm2 = [x for x in ww1dirm2[iwfobuoy][0:ww1pltrangem2]]
ww1wndftm2 = [x*convfac2 for x in ww1wndm2[iwfobuoy][0:ww1pltrangem2]]
ww1wdrftm2 = [(270.-x)*(np.pi/180.) for x in ww1wdrm2[iwfobuoy][0:ww1pltrangem2]]

obsparft = [x*convfac for x in obspar[iwfobuoy][:]]
obsperft = [x for x in obsper[iwfobuoy][:]]
obsdirft = [x for x in obsdir[iwfobuoy][:]]
obswspdft = [x*convfac2 for x in obswspd[iwfobuoy][:]]
obswdirft = [(270.-x)*(np.pi/180.) for x in obswdir[iwfobuoy][:]]

plt.figure(figsize=(8,7))
# Hs
print(np.shape(obstim[iwfobuoy][:]))
print(np.shape(obsparft))

#fig, ax = plt.subplots()
ax = plt.subplot(4, 1, 1)
#ax.plot_date(mdate.epoch2num(modtim[iwfobuoy][:]), modpar[iwfobuoy][:], 'b-o', markeredgecolor='b',markersize=2)
#ax.plot_date(mdate.epoch2num(obstim[iwfobuoy][:]), obspar[iwfobuoy][:], 'r-o', markeredgecolor='r',markersize=2)
ax.plot_date(mdate.epoch2num(obstim[iwfobuoy][:]), obsparft, 'r-o', markeredgecolor='r',markersize=2)
ax.plot_date(mdate.epoch2num(ww1timm2[iwfobuoy][0:ww1pltrangem2]), ww1parftm2, 'g-x', markeredgecolor='g',markersize=3)
ax.plot_date(mdate.epoch2num(ww1timm1[iwfobuoy][0:ww1pltrangem1]), ww1parftm1, 'g-x', markeredgecolor='g',markersize=3)
ax.plot_date(mdate.epoch2num(ww1tim[iwfobuoy][0:ww1pltrange]), ww1parft, 'g-x', markeredgecolor='g',markersize=3)
ax.plot_date(mdate.epoch2num(modtimm2[iwfobuoy][0:pltrangem2]), modparftm2, 'k-o', markeredgecolor='k',markersize=2)
ax.plot_date(mdate.epoch2num(modtimm1[iwfobuoy][0:pltrangem1]), modparftm1, 'c-o', markeredgecolor='c',markersize=2)
ax.plot_date(mdate.epoch2num(modtim[iwfobuoy][0:pltrange]), modparft, 'b-o', markeredgecolor='b',markersize=2)
date_formatter = mdate.DateFormatter('%m/%d')  # Use a DateFormatter to set the data to the correct format.
ax.xaxis.set_major_formatter(date_formatter)  # Use a DateFormatter to set the data to the correct format.
ax.tick_params(direction='in', pad=4, labelsize=8)
#fig.autofmt_xdate()
ax.set_xlim([startDatem2, stopDate])
ax.set_ylim(bottom=0)
ax.xaxis.grid(b=True, which='major', color='#C0C0C0', linestyle=':')
ax.yaxis.grid(b=True, which='major', color='#C0C0C0', linestyle=':')
plt.ylabel('Sign. Wave Height [ft]', fontsize=10)
      
dstring = timestamp[0:4]+'/'+timestamp[4:6]+'/'+timestamp[6:8]+' '+bcycle[iwfobuoy]+'Z'
dstringm1 = timestampm1[0:4]+'/'+timestampm1[4:6]+'/'+timestampm1[6:8]+' '+bcyclem1[iwfobuoy]+'Z'
dstringm2 = timestampm2[0:4]+'/'+timestampm2[4:6]+'/'+timestampm2[6:8]+' '+bcyclem2[iwfobuoy]+'Z'

if (not np.isnan(modparm2[iwfobuoy][0])):
   plt.text(0.02, 1.05, 'NWPS '+dstringm2, color='k', transform = ax.transAxes, fontsize=8)
   dstringtitle = dstringm2
if (not np.isnan(modparm1[iwfobuoy][0])):
   plt.text(0.25, 1.05, 'NWPS '+dstringm1, color='c', transform = ax.transAxes, fontsize=8)
   dstringtitle = dstringm1
if (not np.isnan(modpar[iwfobuoy][0])):
   plt.text(0.48, 1.05, 'NWPS '+dstring, color='b', transform = ax.transAxes, fontsize=8)
   dstringtitle = dstring
if ( (not np.isnan(ww1par[iwfobuoy][0])) or (not np.isnan(ww1parm1[iwfobuoy][0])) or (not np.isnan(ww1parm2[iwfobuoy][0])) ):
   if wwgrid[-4:] == '0p16':
      plt.text(0.77, 1.05, 'GFS-Wave 10 arc-min', color='g', transform = ax.transAxes, fontsize=8)
      dstringtitle = dstring
   if wwgrid[-4:] == '0p25':
      plt.text(0.77, 1.05, 'GFS-Wave 15 arc-min', color='g', transform = ax.transAxes, fontsize=8)
      dstringtitle = dstring
plt.text(0.02, 1.16, 'NDBC '+NDBCextract, color='r', transform = ax.transAxes, fontsize=8)

# Per
print(np.shape(obspertim[iwfobuoy][:]))
print(np.shape(obsperft))
ax = plt.subplot(4, 1, 2)
#ax.plot_date(mdate.epoch2num(modtim[iwfobuoy][:]), modpar[iwfobuoy][:], 'b-o', markeredgecolor='b',markersize=2)
#ax.plot_date(mdate.epoch2num(obstim[iwfobuoy][:]), obspar[iwfobuoy][:], 'r-o', markeredgecolor='r',markersize=2)
ax.plot_date(mdate.epoch2num(obspertim[iwfobuoy][:]), obsperft, 'r-o', markeredgecolor='r',markersize=2)
ax.plot_date(mdate.epoch2num(ww1timm2[iwfobuoy][0:ww1pltrangem2]), ww1perftm2, 'g-x', markeredgecolor='g',markersize=3)
ax.plot_date(mdate.epoch2num(ww1timm1[iwfobuoy][0:ww1pltrangem1]), ww1perftm1, 'g-x', markeredgecolor='g',markersize=3)
ax.plot_date(mdate.epoch2num(ww1tim[iwfobuoy][0:ww1pltrange]), ww1perft, 'g-x', markeredgecolor='g',markersize=3)
ax.plot_date(mdate.epoch2num(modtimm2[iwfobuoy][0:pltrangem2]), modperftm2, 'k-o', markeredgecolor='k',markersize=2)
ax.plot_date(mdate.epoch2num(modtimm1[iwfobuoy][0:pltrangem1]), modperftm1, 'c-o', markeredgecolor='c',markersize=2)
ax.plot_date(mdate.epoch2num(modtim[iwfobuoy][0:pltrange]), modperft, 'b-o', markeredgecolor='b',markersize=2)
date_formatter = mdate.DateFormatter('%m/%d')  # Use a DateFormatter to set the data to the correct format.
ax.xaxis.set_major_formatter(date_formatter)  # Use a DateFormatter to set the data to the correct format.
ax.tick_params(direction='in', pad=4, labelsize=8)
#fig.autofmt_xdate()
ax.set_xlim([startDatem2, stopDate])
ax.set_ylim([0, 25])
ax.xaxis.grid(b=True, which='major', color='#C0C0C0', linestyle=':')
ax.yaxis.grid(b=True, which='major', color='#C0C0C0', linestyle=':')
plt.ylabel('Peak Period [s]', fontsize=10)

# Dir
print(np.shape(obsdirtim[iwfobuoy][:]))
print(np.shape(obsdirft))
ax = plt.subplot(4, 1, 3)
ax.plot_date(mdate.epoch2num(obsdirtim[iwfobuoy][:]), obsdirft, 'r-o', markeredgecolor='r',markersize=2)
ax.plot_date(mdate.epoch2num(ww1timm2[iwfobuoy][0:ww1pltrangem2]), ww1dirftm2, 'g-x', markeredgecolor='g',markersize=3)
ax.plot_date(mdate.epoch2num(ww1timm1[iwfobuoy][0:ww1pltrangem1]), ww1dirftm1, 'g-x', markeredgecolor='g',markersize=3)
ax.plot_date(mdate.epoch2num(ww1tim[iwfobuoy][0:ww1pltrange]), ww1dirft, 'g-x', markeredgecolor='g',markersize=3)
ax.plot_date(mdate.epoch2num(modtimm2[iwfobuoy][0:pltrangem2]), moddirftm2, 'k-o', markeredgecolor='k',markersize=2)
ax.plot_date(mdate.epoch2num(modtimm1[iwfobuoy][0:pltrangem1]), moddirftm1, 'c-o', markeredgecolor='c',markersize=2)
ax.plot_date(mdate.epoch2num(modtim[iwfobuoy][0:pltrange]), moddirft, 'b-o', markeredgecolor='b',markersize=2)
date_formatter = mdate.DateFormatter('%m/%d')  # Use a DateFormatter to set the data to the correct format.
ax.xaxis.set_major_formatter(date_formatter)  # Use a DateFormatter to set the data to the correct format.
ax.tick_params(direction='in', pad=4, labelsize=8)
#fig.autofmt_xdate()
ax.set_xlim([startDatem2, stopDate])
ax.set_ylim([0, 360])
ax.xaxis.grid(b=True, which='major', color='#C0C0C0', linestyle=':')
ax.yaxis.grid(b=True, which='major', color='#C0C0C0', linestyle=':')
plt.ylabel('Wave Dir [Deg. N]', fontsize=10)

# Wind
print(np.shape(obswspdtim[iwfobuoy][:]))
print(np.shape(obswspdft))
print(np.shape(obswdirtim[iwfobuoy][:]))
print(np.shape(obswdirft))
ax = plt.subplot(4, 1, 4)

modwndU = [a * b for a, b in zip(modwndft, np.cos(modwdrft))]
modwndV = [a * b for a, b in zip(modwndft, np.sin(modwdrft))]
modwndUm1 = [a * b for a, b in zip(modwndftm1, np.cos(modwdrftm1))]
modwndVm1 = [a * b for a, b in zip(modwndftm1, np.sin(modwdrftm1))]
modwndUm2 = [a * b for a, b in zip(modwndftm2, np.cos(modwdrftm2))]
modwndVm2 = [a * b for a, b in zip(modwndftm2, np.sin(modwdrftm2))]
obswndU = [a * b for a, b in zip(obswspdft, np.cos(obswdirft))]
obswndV = [a * b for a, b in zip(obswspdft, np.sin(obswdirft))]
mxUVwind = max(abs(np.concatenate([modwndU,modwndV,modwndUm1,modwndVm1,modwndUm2,modwndVm2,obswndU,obswndV])))
print(mxUVwind)

# Obs
size = len(obswspdtim[iwfobuoy][0::3])
ax.quiver(mdate.epoch2num(obswspdtim[iwfobuoy][0::3]), np.zeros(size), obswndU[0::3], obswndV[0::3], scale=np.round(mxUVwind,1)*10,width=0.0035, color='r')

# Current cycle
size = len(modtim[iwfobuoy][0:pltrange])
ax.quiver(mdate.epoch2num(modtim[iwfobuoy][0:pltrange]), np.zeros(size), modwndU, modwndV, scale=np.round(mxUVwind,1)*10,width=0.0025, color='b')
ax.plot_date([startDatem2, stopDate], np.zeros(2), 'k:')

# Current minus 1 day
size = len(modtimm1[iwfobuoy][0:pltrangem1])
ax.quiver(mdate.epoch2num(modtimm1[iwfobuoy][0:pltrangem1]), np.zeros(size), modwndUm1, modwndVm1, scale=np.round(mxUVwind,1)*10,width=0.0025, color='c')

# Current minus 2 days
size = len(modtimm2[iwfobuoy][0:pltrangem2])
ax.quiver(mdate.epoch2num(modtimm2[iwfobuoy][0:pltrangem2]), np.zeros(size), modwndUm2, modwndVm2, scale=np.round(mxUVwind,1)*10,width=0.0025, color='k')

date_formatter = mdate.DateFormatter('%m/%d')  # Use a DateFormatter to set the data to the correct format.
ax.xaxis.set_major_formatter(date_formatter)  # Use a DateFormatter to set the data to the correct format.
ax.tick_params(direction='in', pad=4, labelsize=8)
#fig.autofmt_xdate()
ax.set_xlim([startDatem2, stopDate])
ax.yaxis.set_major_locator(MultipleLocator(int(np.round(mxUVwind,0))/2))
ax.set_ylim(int(np.round(mxUVwind,0))*-1,int(np.round(mxUVwind,0)))
ax.xaxis.grid(b=True, which='major', color='#C0C0C0', linestyle=':')
ax.yaxis.grid(b=True, which='major', color='#C0C0C0', linestyle=':')
plt.xlabel('Time [UTC]', fontsize=10)
plt.ylabel('Wind Speed [kts]', fontsize=10)

#windXvals = arange(0,waveCols,1)
#mxUVwind = 20
#
#quiverkey(Qwind,windXvals[-1]*1.1,int(np.round(mxUVwind*1.94,0))*-0.5,mxUVwind,'WindSource\n'+windSource+'\n\nMax\nWind Speed\n'+str(np.round#(mxUVwind*1.94,1))+" [knots]",coordinates='data',color='r',fontproperties={'size': 'small'})
#annotate(''+str(np.round((mxUVwind),1))+' [m/s]', xy=(1.1, 0.06), xycoords='axes fraction', color='k', horizontalalignment='center', fontsize='small')

plt.suptitle('NWPS WFO-'+wfo.upper()+': NDBC '+NDBCextract+' real-time validation '+dstringtitle)
      
#filenm = wfo+'_'+wfobuoy+'_'+timestamp+'_'+bcycle[iwfobuoy]+'_ts.png'
filenm = 'nwps_'+timestamp+'_'+wfo+'_'+NDBCextract+'_ts.png'
plt.savefig(filenm,dpi=150,bbox_inches='tight',pad_inches=0.1)
plt.clf()

print('-------- Exiting nwps_stat_buoy_ts.py ---------')
print('')

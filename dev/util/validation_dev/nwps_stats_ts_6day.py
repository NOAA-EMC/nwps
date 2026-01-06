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
COMOUTm5_dev = os.environ.get('COMOUTm5_dev')
COMOUTm5 =  os.environ.get('COMOUTm5')
COMOUTww1 = os.environ.get('COMOUTww1')
workdir = os.environ.get('workdir')

TDEF = 145
TDEF2 = 49
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

def read_ndbc(filename, start_date=None, end_date=None):
    """
    Reads time, wave height (WVHT), dominant period (DPD), and mean direction (MWD) 
    from a local NDBC-style file, filtering data points to be within the specified 
    date range and converting time to UNIX timestamps.

    Args:
        filename (str): The path to the local data file.
        start_date (datetime.datetime, optional): The beginning of the desired time window (inclusive).
        end_date (datetime.datetime, optional): The end of the desired time window (inclusive).

    Returns:
        tuple: (times_unix, h_wvht, t_dpd, d_mwd) containing filtered UNIX timestamps 
               and corresponding NumPy arrays for the three variables.
    """
    print(f'Processing file: {filename}')

    if not os.path.exists(filename):
        print(f'Skipping - File not found: {filename}')
        # Return four empty lists/arrays to match the expected output structure
        return ([], np.array([]), np.array([]), np.array([]))

    filtered_times = []
    filtered_h = []  # Wave Height (WVHT) - Index 8
    filtered_t = []  # Dominant Period (DPD) - Index 9
    filtered_d = []  # Mean Wave Direction (MWD) - Index 11

    try:
        with open(filename, 'r') as f:
            # Skip the header lines
            data_lines = [line for line in f if not line.startswith('#')]

            for line in data_lines:
                parts = line.split()
                # We need at least index 11 (MWD), so check for length >= 12
                if len(parts) < 12:
                    continue
                
                # --- 1. Parse Date/Time and Create datetime object (dt) ---
                try:
                    year = int(parts[0])
                    month = int(parts[1])
                    day = int(parts[2])
                    hour = int(parts[3])
                    minute = int(parts[4])
                    dt = datetime.datetime(year, month, day, hour, minute)
                except ValueError:
                    continue

                # --- 2. Apply Date Filtering ---
                date_check = True
                if start_date and dt < start_date:
                    date_check = False
                if end_date and dt > end_date:
                    date_check = False

                if date_check:
                    # --- 3. Parse Data Variables (Helper function for cleaning) ---
                    def safe_float(s):
                        return float(s) if s != 'MM' else np.nan
                    
                    try:
                        h_val = safe_float(parts[8])   # WVHT
                        t_val = safe_float(parts[9])   # DPD
                        d_val = safe_float(parts[11])  # MWD (Index 11)
                    except (ValueError, IndexError):
                        # If a data point is corrupted but time is fine, use NaN
                        h_val, t_val, d_val = np.nan, np.nan, np.nan

                    # --- 4. Add filtered data to results ---
                    filtered_times.append(dt)
                    filtered_h.append(h_val)
                    filtered_t.append(t_val)
                    filtered_d.append(d_val)

    except Exception as e:
        print(f'Error reading data from {filename}: {e}')
        return ([], np.array([]), np.array([]), np.array([]))

    # --- 5. Final Conversion and Return ---
    if filtered_times:
        # Convert list of datetime objects to floating-point Unix timestamps
        unix_times = [dt.timestamp() for dt in filtered_times]
    else:
        unix_times = []

    # Return the Unix times and NumPy arrays for all three variables
    return (unix_times, np.array(filtered_h), np.array(filtered_t), np.array(filtered_d))

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
tmp3 = os.environ.get('STARTDATEm5')
tmp4 = os.environ.get('ENDDATE')

startDate=datetime.datetime(int(tmp1[0:4]),int(tmp1[4:6]),int(tmp1[6:8]))
startDatem1=datetime.datetime(int(tmp2[0:4]),int(tmp2[4:6]),int(tmp2[6:8]))
startDatem5=datetime.datetime(int(tmp3[0:4]),int(tmp3[4:6]),int(tmp3[6:8]))
stopDate=datetime.datetime(int(tmp4[0:4]),int(tmp4[4:6]),int(tmp4[6:8]))

print('-------- In nwps_stats_buoy_ts.py ---------')
print('Computing NWPS statistics for NDBC '+NDBCextract.upper()+':')
print('startDate = '+startDate.strftime("%Y/%m/%d"))
print('startDatem1 = '+startDatem1.strftime("%Y/%m/%d"))
print('startDatem5 = '+startDatem5.strftime("%Y/%m/%d"))
print('startDatem5 = '+startDatem5.strftime("%Y/%m/%d"))
print('stopDate = '+stopDate.strftime("%Y/%m/%d"))
print('')

vname = 'wave_height'
ibuoy = 0

# Fetch and read NDBC buoy observations
print('Fetching realtime NDBC buoy obs...')
for buoy in wfobuoys:
     buoy_filename = f'{buoy}.txt'
    # Example: 'ndbc_buoy_data_20251116/46025.txt'
     date_str = startDatem1.strftime('%Y%m%d')
     extract_dir = f'/lfs/h2/emc/vpppg/noscrub/emc.vpppg/verification/global/archive/obs_data/ndbc_buoy/{date_str}'
     full_file_path = os.path.join(extract_dir, buoy_filename)
     times, h, t, d = read_ndbc(full_file_path,startDatem5,startDate)
     if len(h) != 0:
        # Convert times list to NumPy array for synchronized indexing
        obstim_withnans = np.array(times)

        # Keep data arrays as simple copies (they are already 1D arrays from read_ndbc)
        obspar_withnans = h.copy()  # Wave Height (Hs)
        obsper_withnans = t.copy()  # Dominant Period (Tp)
        obsdir_withnans = d.copy()  # Mean Wave Direction (MWD)

        # --- 3. Filter and Synchronize (Hs and Tp) ---

        # Vectorized filtering for Hs: Replace small values with NaN
        obspar_withnans[obspar_withnans < 0.05] = np.nan

        # CRITICAL: Create ONE mask based on *Hs* validity for the main time series.
        # Data is typically driven by the primary variable (Hs).
        hs_valid_mask = ~np.isnan(obspar_withnans)

        # Filter all arrays using the primary mask:
        obspar_valid = obspar_withnans[hs_valid_mask]
        obstim_valid = obstim_withnans[hs_valid_mask]

        # Filter Period using the same primary mask
        obsper_valid = obsper_withnans[hs_valid_mask]
        obsdir_valid = obsdir_withnans[hs_valid_mask]

        # If period needs a secondary filter (e.g., period must be > 1.0s):
        # period_filter = ~np.isnan(obsper_valid) & (obsper_valid > 1.0)
        # obspar_valid = obspar_valid[period_filter]
        # obstim_valid = obstim_valid[period_filter]
        # obsper_valid = obsper_valid[period_filter]

        # --- 4. Assign Filtered/Compact Arrays to Final Structure ---

        # 🟢 FIX: Directly replace the object at the list/array index.
        # This solves the size mismatch error caused by [:] assignment.
        obstim[ibuoy] = obstim_valid    # Final time series (driven by valid Hs)
        obspar[ibuoy] = obspar_valid    # Final Hs data
        obsdir[ibuoy] = obsdir_valid

        # For the period data, use the Hs-driven time, but the filtered period values
        obsper[ibuoy] = obsper_valid    # Final Tp data
        # Note: If obstim and obspertim are meant to be DIFFERENT, you'd need a separate filter.
        # Here, we assume Tp quality is tied to Hs quality, or at least synchronized to its valid times.
        obspertim[ibuoy] = obstim_valid # Time for the period data
        obsdirtim[ibuoy] = obstim_valid

        # Use np.array([]) for empty consistency
     else:
        obspar[ibuoy] = np.array([])
        obstim[ibuoy] = np.array([])
        obsper[ibuoy] = np.array([])
        obspertim[ibuoy] = np.array([])
        obsdir[ibuoy] = np.array([])
        obsdirtim[ibuoy] = np.array([])
     #print(len(obspar[ibuoy][:]))

     # Truncate all Hs obs earlier than startDatem5
     print(len(np.array(obstim[ibuoy][:])))
     print(np.any( np.array(obstim[ibuoy][:]) > int(startDatem5.strftime('%s')) ))
     timind = 0
     if np.any( np.array(obstim[ibuoy][:]) > int(startDatem5.strftime('%s')) ):
        timind = min(min( np.where(np.array(obstim[ibuoy][:]) > int(startDatem5.strftime('%s'))) ))
        obstim[ibuoy][:] = obstim[ibuoy][timind:]
        obspar[ibuoy][:] = obspar[ibuoy][timind:]
     else:
        obstim[ibuoy][:] = []
        obspar[ibuoy][:] = []
     print(timind)
     print(len(np.array(obstim[ibuoy][:])))
     print(len(np.array(obspar[ibuoy][:])))
     if len(np.array(obspar[ibuoy][:]))==0:
        read_hs_obs_from_5day = False
        print('Reading Hs and Tp from NDBC 5day data file...')
        obstim = [[0 for x in range(30000)] for x in range(len(wfobuoys))]
        obspertim = [[0 for x in range(30000)] for x in range(len(wfobuoys))]
        obspar = [[0 for x in range(30000)] for x in range(len(wfobuoys))]
        obsper = [[0 for x in range(30000)] for x in range(len(wfobuoys))]
        obsdir = [[0 for x in range(30000)] for x in range(len(wfobuoys))]

     else:
        read_hs_obs_from_5day = False


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
        '063','066','069','072','075','078','081','084','087','090','093','096','099','102','105','108','111','114','117','120','123','126','129','132','135','138','141','144']
varname=['HTSGW','PERPW','DIRPW','WIND','WDIR']


for single_date in daterange(startDatem5,startDatem5):

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
         extdir=COMOUTm5_dev+region+'.'+timestampm1+'/'+wfo+'/'+cycle+'/'+CGextract+'/'
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

for single_date in daterange(startDatem5,startDatem5):

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
         extdir=COMOUTm5+region+'.'+timestampm2+'/'+wfo+'/'+cycle+'/'+CGextract+'/'
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
for single_date in daterange(startDatem5,startDatem5):

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
for single_date in daterange(startDatem5,startDatem5):

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
   pltrangem2 = 145

ww1pltrange = 0
ww1pltrangem1 = 0
ww1pltrangem2 = 0
if (not np.isnan(ww1parm2[iwfobuoy][0])):
   ww1pltrange = 0
   ww1pltrangem1 = TDEF2
   ww1pltrangem2 = 49


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


start_epoch_time = mdate.num2epoch(mdate.epoch2num(modtimm2[iwfobuoy][0]))
SECONDS_TO_HOURS = 3600

# --- 2. & 3. Calculate Time Differences and Convert to Hours for ALL time arrays ---

# The x-axis data (forecast hours) for observations
obstim_hours = (mdate.num2epoch(mdate.epoch2num(obstim[iwfobuoy][:])) - start_epoch_time) / SECONDS_TO_HOURS

# The x-axis data for the ww1 model runs
ww1timm2_hours = (mdate.num2epoch(mdate.epoch2num(ww1timm2[iwfobuoy][0:ww1pltrangem2])) - start_epoch_time) / SECONDS_TO_HOURS
#ww1timm1_hours = (mdate.num2epoch(mdate.epoch2num(ww1timm1[iwfobuoy][0:ww1pltrangem1])) - start_epoch_time) / SECONDS_TO_HOURS
#ww1tim_hours = (mdate.num2epoch(mdate.epoch2num(ww1tim[iwfobuoy][0:ww1pltrange])) - start_epoch_time) / SECONDS_TO_HOURS

# The x-axis data for the mod model runs (your forecasts)
modtimm2_hours = (mdate.num2epoch(mdate.epoch2num(modtimm2[iwfobuoy][0:pltrangem2])) - start_epoch_time) / SECONDS_TO_HOURS
modtimm1_hours = (mdate.num2epoch(mdate.epoch2num(modtimm1[iwfobuoy][0:pltrangem1])) - start_epoch_time) / SECONDS_TO_HOURS

# --- 4. Plot using standard ax.plot (since x-axis is now a numerical array of hours) ---

print(np.shape(obstim[iwfobuoy][:]))
print(np.shape(obsparft))

#fig, ax = plt.subplots()
ax = plt.subplot(4, 1, 1)

# *** IMPORTANT CHANGE: Use ax.plot() instead of ax.plot_date() and use the new '_hours' arrays ***
# The lines below are your modified plotting calls:
ax.plot(obstim_hours, obsparft, 'ro', markeredgecolor='r',markersize=2)
ax.plot(ww1timm2_hours, ww1parftm2, 'g-x', markeredgecolor='g',markersize=3)
#ax.plot(ww1timm1_hours, ww1parftm1, 'g-x', markeredgecolor='g',markersize=3)
#ax.plot(ww1tim_hours, ww1parft, 'g-x', markeredgecolor='g',markersize=3)
ax.plot(modtimm2_hours, modparftm2, 'k-o', markeredgecolor='k',markersize=2)
ax.plot(modtimm1_hours, modparftm1, 'c-o', markeredgecolor='c',markersize=2)

# --- 5. Adjust X-Axis Ticks/Labels ---

# You no longer need the DateFormatter
# date_formatter = mdate.DateFormatter('%m/%d')
# ax.xaxis.set_major_formatter(date_formatter) # <--- REMOVE THIS LINE

# Set your desired x-axis limits and ticks
max_forecast_hour = 144 # e.g., the max hour you want to show
x_ticks = np.arange(0, max_forecast_hour + 1, 24) # Creates [0, 24, 48, 72, 96, 120, 144]

ax.set_xlim([0, max_forecast_hour]) # Set limits from 0 to your max hour
ax.set_xticks(x_ticks) # Set the major ticks to your desired hours

# fig.autofmt_xdate() # <--- REMOVE THIS LINE
ax.tick_params(direction='in', pad=4, labelsize=8)
ax.set_ylim(bottom=0)
ax.xaxis.grid(b=True, which='major', color='#C0C0C0', linestyle=':')
ax.yaxis.grid(b=True, which='major', color='#C0C0C0', linestyle=':')
plt.xlabel('Forecast Hour', fontsize=10) # Change to Forecast Hour
plt.ylabel('Sign. Wave Height [ft]', fontsize=10)

# The text placement code remains the same, but you might want to adjust the dstringtitle text to reflect the new X-axis (e.g., "Initialization: YYYY/MM/DD HHZ")
# ... (your original text placement code here)

      
dstringm1 = timestampm1[0:4]+'/'+timestampm1[4:6]+'/'+timestampm1[6:8]+' '+bcyclem1[iwfobuoy]+'Z'
dstringm2 = timestampm2[0:4]+'/'+timestampm2[4:6]+'/'+timestampm2[6:8]+' '+bcyclem2[iwfobuoy]+'Z'

if (not np.isnan(modparm2[iwfobuoy][0])):
   plt.text(0.02, 1.05, 'NWPS prod', color='k', transform = ax.transAxes, fontsize=8)
   dstringtitle = dstringm2
if (not np.isnan(modparm1[iwfobuoy][0])):
   plt.text(0.33, 1.05, 'NWPS dev', color='c', transform = ax.transAxes, fontsize=8)
   dstringtitle = dstringm1
if ( (not np.isnan(ww1parm1[iwfobuoy][0])) or (not np.isnan(ww1parm2[iwfobuoy][0])) ):
   if wwgrid[-4:] == '0p16':
      plt.text(0.66, 1.05, 'GFS-Wave 10 arc-min', color='g', transform = ax.transAxes, fontsize=8)
      dstringtitle = dstringm1
   if wwgrid[-4:] == '0p25':
      plt.text(0.66, 1.05, 'GFS-Wave 15 arc-min', color='g', transform = ax.transAxes, fontsize=8)
      dstringtitle = dstringm1
plt.text(0.02, 1.16, 'NDBC '+NDBCextract, color='r', transform = ax.transAxes, fontsize=8)

# Per
print(np.shape(obspertim[iwfobuoy][:]))
print(np.shape(obsperft))
ax = plt.subplot(4, 1, 2)

ax.plot(obstim_hours, obsperft, 'r-o', markeredgecolor='r',markersize=2)
ax.plot(ww1timm2_hours, ww1perftm2, 'g-x', markeredgecolor='g',markersize=3)
#ax.plot(ww1timm1_hours, ww1perftm1, 'g-x', markeredgecolor='g',markersize=3)
#ax.plot(ww1tim_hours, ww1perft, 'g-x', markeredgecolor='g',markersize=3)
ax.plot(modtimm2_hours, modperftm2, 'k-o', markeredgecolor='k',markersize=2)
ax.plot(modtimm1_hours, modperftm1, 'c-o', markeredgecolor='c',markersize=2)

# --- X-Axis Customization for Forecast Hours ---

# Remove DateFormatter settings
# date_formatter = mdate.DateFormatter('%m/%d')
# ax.xaxis.set_major_formatter(date_formatter) 

# Define the same X-axis settings as the first plot for consistency
max_forecast_hour = 144
x_ticks = np.arange(0, max_forecast_hour + 1, 24)

ax.set_xlim([0, max_forecast_hour]) # Set limits from 0 to your max hour
ax.set_xticks(x_ticks) # Set the major ticks

ax.tick_params(direction='in', pad=4, labelsize=8)
# fig.autofmt_xdate() # Remove this line
ax.set_ylim([0, 25])
ax.xaxis.grid(b=True, which='major', color='#C0C0C0', linestyle=':')
ax.yaxis.grid(b=True, which='major', color='#C0C0C0', linestyle=':')
plt.ylabel('Peak Period [s]', fontsize=10)
plt.xlabel('Forecast hour', fontsize=10)

#
#quiverkey(Qwind,windXvals[-1]*1.1,int(np.round(mxUVwind*1.94,0))*-0.5,mxUVwind,'WindSource\n'+windSource+'\n\nMax\nWind Speed\n'+str(np.round#(mxUVwind*1.94,1))+" [knots]",coordinates='data',color='r',fontproperties={'size': 'small'})
#annotate(''+str(np.round((mxUVwind),1))+' [m/s]', xy=(1.1, 0.06), xycoords='axes fraction', color='k', horizontalalignment='center', fontsize='small')

plt.suptitle('NWPS WFO-'+wfo.upper()+': NDBC '+NDBCextract+' real-time validation '+dstringtitle)
      
#filenm = wfo+'_'+wfobuoy+'_'+timestamp+'_'+bcycle[iwfobuoy]+'_ts.png'
filenm = 'nwps_'+timestampm2+'_'+wfo+'_'+NDBCextract+'_ts_6day.png'
plt.savefig(filenm,dpi=150,bbox_inches='tight',pad_inches=0.1)
plt.clf()

print('-------- Exiting nwps_stat_buoy_ts.py ---------')
print('')

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
from matplotlib.ticker import MultipleLocator

# global vars
COMOUT = os.environ.get('COMOUT')
#COMOUTm1 = os.environ.get('COMOUTm1')
#COMOUTm2 = os.environ.get('COMOUTm2')
workdir = os.environ.get('workdir')

#TDEF = 35
REGION = sys.argv[1]
WFO = sys.argv[2]
CGextract = sys.argv[3]

#Get analysis dates from shell
tmp1 = os.environ.get('STARTDATE')
tmp2 = os.environ.get('STARTDATEm1')
tmp3 = os.environ.get('STARTDATEm2')
tmp4 = os.environ.get('ENDDATE')

startDate=datetime.datetime(int(tmp1[0:4]),int(tmp1[4:6]),int(tmp1[6:8]))
startDatem1=datetime.datetime(int(tmp2[0:4]),int(tmp2[4:6]),int(tmp2[6:8]))
startDatem2=datetime.datetime(int(tmp3[0:4]),int(tmp3[4:6]),int(tmp3[6:8]))
stopDate=datetime.datetime(int(tmp4[0:4]),int(tmp4[4:6]),int(tmp4[6:8]))

timestamp = startDate.strftime("%Y%m%d")

# Read NOAA and NWS logos
noaa_logo = plt.imread('NOAA-Transparent-Logo.png')
nws_logo = plt.imread('NWS_Logo.png')
usgs_logo = plt.imread('USGS_Logo.png')

modtim = [[0 for x in range(145)] for x in range(5000)]
modlon = [[0 for x in range(145)] for x in range(5000)]
modlat = [[0 for x in range(145)] for x in range(5000)]
modprb = [[0 for x in range(145)] for x in range(5000)]
modhs = [[0 for x in range(145)] for x in range(5000)]
modcrt = [[0 for x in range(145)] for x in range(5000)]
modtoe = [[0 for x in range(145)] for x in range(5000)]
modper = [[0 for x in range(145)] for x in range(5000)]
modlev = [[0 for x in range(145)] for x in range(5000)]
modrun = [[0 for x in range(145)] for x in range(5000)]
modtyp = [[0 for x in range(145)] for x in range(5000)]
istat = 1

#Find rip current data
revcycles=['23','22','21','20','19','18','17','16','15','14','13','12','11','10','09','08','07','06','05','04','03','02','01','00']
datafound = 'false'
for cycle in revcycles:
   print('Search for '+WFO+' cycle '+cycle) 
   extdir=COMOUT+REGION+'.'+timestamp+'/'+WFO+'/'+cycle+'/'+CGextract+'/'
   infile = WFO+'_nwps_20m_'+CGextract+'_runup.'+timestamp+'_'+cycle+'00'
   print('Search for '+extdir+infile)
   if os.path.isfile(extdir+infile):
      print('Reading file '+infile)
      datafound = 'true'
      f = open(extdir+infile, "r")

      tstep = 0
      istat = 0
      print('Reading runup data...')
      for line in f:
          if tstep == 145:
             tstep = 0
             istat = istat+1
          #print(istat, tstep)
          data = line.split()
          if data[0] == '%':
             continue
          elif data[0] == '%DATE':
             continue
          else:
             timestr = data[0]
             modtim[istat][tstep] = int(datetime.datetime(int(timestr[0:4]),int(timestr[4:6]),int(timestr[6:8]),int(timestr[9:11]),int(timestr[11:13])).strftime('%s'))
             if data[1] != 'MM':
                modlon[istat][tstep] = float(data[1])
             else:
                modlon[istat][tstep] = np.nan
             if data[2] != 'MM':
                modlat[istat][tstep] = float(data[2])
             else:
                modlat[istat][tstep] = np.nan
             if data[6] != '999.00':
                modprb[istat][tstep] = float(data[6])
             else:
                modprb[istat][tstep] = np.nan
             if data[3] != 'MM':
                modhs[istat][tstep] = float(data[3])
             else:
                modper[istat][tstep] = np.nan
             if data[4] != 'MM':
                modper[istat][tstep] = float(data[4])
             else:
                modper[istat][tstep] = np.nan
             if data[16] != 'MM':
                modcrt[istat][tstep] = float(data[16])
             else:
                modcrt[istat][tstep] = np.nan
             if data[17] != 'MM':
                modtoe[istat][tstep] = float(data[17])
             else:
                modtoe[istat][tstep] = np.nan
             if (data[6] != '999.00') and (data[9] != '999.00'):
                modlev[istat][tstep] = float(data[6])-float(data[9])
             else:
                modlev[istat][tstep] = np.nan
             if data[9] != '999.00':
                modrun[istat][tstep] = float(data[9])
             else:
                modrun[istat][tstep] = np.nan
             if data[22] != 'MM':
                modtyp[istat][tstep] = float(data[22])
             else:
                modtyp[istat][tstep] = np.nan
             tstep = tstep+1
   if datafound == 'true':
      break
nstat = istat+1

if datafound == 'true':
   for istat in range(nstat):
      print('Plotting '+WFO+' station '+str(istat+1))
      convfac = 1/0.3048   #meters to feet

      plt.figure(figsize=(8,7))

      # Total water level
      hoffset = 0.05
      voffset = 1.0
      ax = plt.subplot(4, 1, 1)
      ax.axhline(0., linestyle='--', linewidth=1.0, color='k') # horizontal lines
      ax.axhline(convfac*modtoe[istat][0], linestyle='-', color='y') # horizontal lines
      ax.axhline(convfac*modcrt[istat][0], linestyle='-', color='r') # horizontal lines
      if modtyp[istat][0]==0:
         ax.text(int(mdate.epoch2num(modtim[istat][0]))+hoffset, convfac*modtoe[istat][0]+voffset, 'Dune toe', style='italic',fontsize=8)
         ax.text(int(mdate.epoch2num(modtim[istat][0]))+hoffset, convfac*modcrt[istat][0]+voffset, 'Dune crest', style='italic',fontsize=8)
      if modtyp[istat][0]==1:
         ax.text(int(mdate.epoch2num(modtim[istat][0]))+hoffset, convfac*modtoe[istat][0]+voffset, 'Seawall base', style='italic',fontsize=8)
         ax.text(int(mdate.epoch2num(modtim[istat][0]))+hoffset, convfac*modcrt[istat][0]+voffset, 'Seawall crest', style='italic',fontsize=8)
      if modtyp[istat][0]==2:
         ax.text(int(mdate.epoch2num(modtim[istat][0]))+hoffset, convfac*modtoe[istat][0]+voffset, 'Cliff bottom', style='italic',fontsize=8)
         ax.text(int(mdate.epoch2num(modtim[istat][0]))+hoffset, convfac*modcrt[istat][0]+voffset, 'Cliff top', style='italic',fontsize=8)
      ax.plot_date(mdate.epoch2num(modtim[istat][0:(tstep)]), convfac*np.asarray(modprb[istat][0:(tstep)]), 'b-o', linewidth=1.0, markeredgecolor='b',markersize=2, label='TWL')
      ax.plot_date(mdate.epoch2num(modtim[istat][0:(tstep)]), convfac*np.asarray(modlev[istat][0:(tstep)]), 'g-o', linewidth=1.0, markeredgecolor='g',markersize=2, label='ESTOFS Tide+Surge')
      ax.legend(loc='upper right')
      date_formatter = mdate.DateFormatter('%m/%d')  # Use a DateFormatter to set the data to the correct format.
      ax.xaxis.set_major_formatter(date_formatter)  # Use a DateFormatter to set the data to the correct format.
      ax.tick_params(direction='in', pad=3, labelsize=8)
      ax.set_xlim([startDate, stopDate])
      if not any(np.isnan(modprb[istat][:])):
         print(np.min(modlev[istat][:]))
         print(np.max(modcrt[istat][:]))
         print(np.max(modprb[istat][:]))
         print(2.+max( np.max(modcrt[istat][:]),np.max(modprb[istat][:]) ))
         ax.set_ylim([convfac*np.min(modlev[istat][:]), 8.+convfac*max( np.max(modcrt[istat][:]),np.max(modprb[istat][:]) )])
      #ax.set_yticks(np.arange(0, 125, 25))
      ax.xaxis.grid(b=True, which='major', color='#C0C0C0', linestyle=':')
      ax.yaxis.grid(b=True, which='major', color='#C0C0C0', linestyle=':')
      plt.ylabel('TWL [ft, MSL]', fontsize=10) 

      # Hs
      ax = plt.subplot(4, 1, 2)
      ax.plot_date(mdate.epoch2num(modtim[istat][0:(tstep)]), convfac*np.asarray(modhs[istat][0:(tstep)]), 'b-o', linewidth=1.0, markeredgecolor='b',markersize=2)
      date_formatter = mdate.DateFormatter('%m/%d')  # Use a DateFormatter to set the data to the correct format.  
      ax.xaxis.set_major_formatter(date_formatter)  # Use a DateFormatter to set the data to the correct format.
      ax.tick_params(direction='in', pad=3, labelsize=8)
      ax.set_xlim([startDate, stopDate])
      ax.set_ylim([0., int(max(convfac*np.asarray(modhs[istat][0:(tstep)])))+1.])
      ax.xaxis.grid(b=True, which='major', color='#C0C0C0', linestyle=':')
      ax.yaxis.grid(b=True, which='major', color='#C0C0C0', linestyle=':')
      plt.ylabel('Hsig [ft]', fontsize=10)

      # Peak per
      ax = plt.subplot(4, 1, 3)
      ax.plot_date(mdate.epoch2num(modtim[istat][0:(tstep)]), modper[istat][0:(tstep)], 'b-o', linewidth=1.0, markeredgecolor='b',markersize=2)
      date_formatter = mdate.DateFormatter('%m/%d')  # Use a DateFormatter to set the data to the correct format.
      ax.xaxis.set_major_formatter(date_formatter)  # Use a DateFormatter to set the data to the correct format.
      ax.tick_params(direction='in', pad=3, labelsize=8)
      ax.set_xlim([startDate, stopDate])
      ax.set_ylim([0., 20.])  
      ax.xaxis.grid(b=True, which='major', color='#C0C0C0', linestyle=':')
      ax.yaxis.grid(b=True, which='major', color='#C0C0C0', linestyle=':')
      plt.ylabel('Peak period [s]', fontsize=10)      

      # Runup
      ax = plt.subplot(4, 1, 4)
      ax.plot_date(mdate.epoch2num(modtim[istat][0:(tstep)]), convfac*np.asarray(modrun[istat][0:(tstep)]), 'b-o', linewidth=1.0, markeredgecolor='b',markersize=2)
      date_formatter = mdate.DateFormatter('%m/%d')  # Use a DateFormatter to set the data to the correct format.
      ax.xaxis.set_major_formatter(date_formatter)  # Use a DateFormatter to set the data to the correct format.    
      ax.tick_params(direction='in', pad=3, labelsize=8)   
      ax.set_xlim([startDate, stopDate])
      ax.xaxis.grid(b=True, which='major', color='#C0C0C0', linestyle=':')
      ax.yaxis.grid(b=True, which='major', color='#C0C0C0', linestyle=':')
      plt.ylabel('Wave runup [ft]', fontsize=10)

      dstring = timestamp[0:4]+'/'+timestamp[4:6]+'/'+timestamp[6:8]+' '+cycle+'Z'
      plt.suptitle('NWPS WFO-'+WFO.upper()+': Total Water Level '+dstring+'\n'+\
           'Station '+str(istat+1)+' ('+"{:.3f}".format(modlat[istat][0])+','+"{:.3f}".format(modlon[istat][0]-360)+')')
           #'Station '+str(istat+1)+' ('+str(modlat[istat][0])+','+str(modlon[istat][0]-360)+')')
   
      # Set up subaxes and plot the logos in them
      #plt.axes([0.09,.93,.08,.08])
      plt.axes([0.09,.90,.08,.08])
      plt.axis('off')
      plt.imshow(noaa_logo,interpolation='gaussian')
      #plt.axes([.83,.93,.08,.08])
      plt.axes([.82,.88,.12,.12])
      plt.axis('off')
      plt.imshow(usgs_logo,interpolation='gaussian')
   
      #filenmdate = 'nwps_'+timestamp+'_'+WFO+'_ripprob_stat'+str(istat+1)+'.png'
      #plt.savefig(filenmdate,dpi=150,bbox_inches='tight',pad_inches=0.1)
      filenm = 'nwps_'+WFO+'_runup_stat'+str(istat+1)+'.png'
      plt.savefig(filenm,dpi=150,bbox_inches='tight',pad_inches=0.1)
      plt.close()

   """
   # Write output file with max rip prob values for forcast period
   ofilenm = WFO.upper()+'1.rip'
   text_file = open(ofilenm, "w")
   for istat in range(nstat):
      #if max(modprb[istat][0:(tstep)]) < 25.0:
      if max(modprb[istat][0:25]) < 25.0:        #Integrate risk over first day only
         ripwarncol = 'gray'
         ripwarnlev = 'LOW'
      #elif max(modprb[istat][0:(tstep)]) > 50.0:
      elif max(modprb[istat][0:25]) > 50.0:        #Integrate risk over first day only
         ripwarncol = 'red'
         ripwarnlev = 'HIGH'
      else:
         ripwarncol = 'yellow' 
         ripwarnlev = 'MODERATE'      
      outstring = '"'+WFO+'_ripprob_stat'+str(istat+1)+'|'+\
                  "{:.3f}".format(modlat[istat][0])+'|'+"{:.3f}".format(modlon[istat][0]-360)+\
                  '|Rip Current Station '+str(istat+1)+'|'+WFO.upper()+'|'+ripwarncol+'|'+ripwarnlev+'",\n'
      text_file.write("%s" % outstring)
   text_file.close()
   """

else:
   print(' *** Warning: no model data found')

print('-------- Exiting nwps_plot_runup.py ---------')
print('')


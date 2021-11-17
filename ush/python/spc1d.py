#--------------------------------------------------------
# spc1d.py script
# Author: Ernesto Rodriguez, 05/03/2015
# Purpose: Plots SWAN 1D Spectrum from binary file.
#--------------------------------------------------------

import matplotlib
#matplotlib.use('Agg',warn=False)
import numpy as np
from pylab import *
from time import gmtime, strftime
from datetime import date, timedelta

#=====================================
#----------- MAIN SCRIPT -------------
#=====================================

#-----------------------------------------
#--- Command line Parameters
#-----------------------------------------
LocName=sys.argv[1]
lon=sys.argv[2]
lat=sys.argv[3]

if float(lon) > 180:
	lon = str(np.round(float(lon)-360,1))

#-----------------------------------------
#--- Read NOAA and NWS logos
#-----------------------------------------
noaa_logo = imread('noaa_logo.png')
nws_logo = imread('nws_logo.png')

#-----------------------------------------
#--- Read files
#-----------------------------------------
cfile = open('swanspc1d.ctl','r')   # Control file
bfile = open('spec.bin','r')        # Binary 1D Spectrum file

#----------------------------------------------
#--- Read variables inside of the control file
#----------------------------------------------
for line in cfile:
    words = line.split()
    if words[0] == 'XDEF':
        cols = int(words[1])
        xval = words[3::]
    elif words[0] == 'TDEF':
        rows = int(words[1])
        run  = words[3]
        fhr  = run[0:2]
        step = int(words[4][0])
    #elif len(words) == 4 and words[3] == 'spec1d':
    #    LocName = words[0].split("=")[0].strip()
    else:
        continue

print(cols,rows,run,fhr,step)
#-----------------------------------------
#--- Convert the xval(string) to float
#-----------------------------------------
xvals = np.linspace(0, 0.5, num=cols)
#xvals = []
#for x in range(len(xval)):
#    xvals.append(float(xval[x]))
    
data = np.fromfile(bfile, dtype=np.float32) # read the binary data
data = data.reshape((rows,cols)) # reshape the data file

cfile.close()
bfile.close()

#-----------------------------------------
# Create time stamp
#-----------------------------------------
month = ['jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dic']

day = int(run[3:5])
mth = run[5:8]
yrs = int(run[8:12])

num_mth = month.index(mth)+1

#-----------------------------------------
#--- Plot the data
#-----------------------------------------
timeSteps = len(data)

for i in range(timeSteps):
    ts=((i+1)*step)-step
    
    runTime = datetime.datetime(yrs, num_mth, day, int(fhr)) + timedelta(hours=ts)
    title_time = runTime.strftime('%HZ %b %d,%Y')
    
    clf()
    energy = data[i]
    energy[energy == -99] = nan     # Replacing missing values with NaN
    
    plot(xvals,energy, color='r')
    
    # Calculate the y-tick spacing and maximum
    mx_energy = max(energy[~np.isnan(energy)])

    if mx_energy < 0.01:
        ySpace = 0.001
    elif mx_energy < 0.2:
        ySpace = 0.01
    elif mx_energy < 0.5:
        ySpace = 0.05
    elif mx_energy < 1:
        ySpace = 0.1
    elif mx_energy < 1.5:
        ySpace = 0.15
    else:
        ySpace = 0.25
    
    mx_energy = mx_energy+ySpace

    # Customize the axis of the plot
    ax=gca()
    ax.xaxis.set_major_locator(MultipleLocator(0.05))
    ax.xaxis.grid(b=True, which='major', color='#C0C0C0', linestyle=':')
    ax.yaxis.set_major_locator(MultipleLocator(ySpace))
    ax.yaxis.grid(b=True, which='major', color='#C0C0C0', linestyle=':')
    ax.tick_params( labelsize='x-small')
    ax.set_xlabel('Frequency [Hz]')
    ax.set_ylabel('Energy [m2/Hz]')
    annotate('Location: '+LocName+"\n("+lon+","+lat+")", xy=(0.875, 0.925), xycoords='axes fraction', color='b', horizontalalignment='center')
    ax.set_xlim(0,0.5)
    ax.set_ylim((ySpace*-0.5),mx_energy)

    ax2 = ax.twiny()
    ax2.set_xlabel("Period [s]")
    ax2.set_xlim(0, 0.5)
    ax2.set_xticks([0.05, 0.07, 0.1,0.125,0.143,0.16667,0.2,0.25,0.33])
    ax2.set_xticklabels(['20','13','10','8','7','6','5','4','3'])
    ax2.tick_params(labelright=True, labelsize='x-small')
    
    title('NWPS Spectral Density at Hr '+str(ts)+' from '+title_time, y=1.125)
    
    # Set up subaxes and plot the logos in them
    axes([0.07,.95,.08,.08])
    axis('off')
    imshow(noaa_logo,interpolation='gaussian')
    axes([.87,.95,.08,.08])
    axis('off')
    imshow(nws_logo,interpolation='gaussian')
    
    #------ Plot name depending of the forecast hour ------
    if ts < 10:
        plotname = 'swan_'+LocName+'_hr00'+str(ts)+'.png'
    elif ts < 100:
        plotname = 'swan_'+LocName+'_hr0'+str(ts)+'.png'
    else:
        plotname = 'swan_'+LocName+'_hr'+str(ts)+'.png'    
    
    print(plotname,mx_energy)
    savefig(plotname, bbox_inches='tight', dpi = 150)






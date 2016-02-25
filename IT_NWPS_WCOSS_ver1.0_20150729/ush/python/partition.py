#--------------------------------------------------------
# partition.py script
# Author: Ernesto Rodriguez, NWS WFO San Juan
# Created on 05/18/2015
# Purpose: Plots SWAN 1D Spectrum from binary file.
#--------------------------------------------------------

import numpy as np
from pylab import *
from time import gmtime, strftime
from datetime import date, timedelta

#===========================================
# Methods/Functions to optimize the script
#===========================================
def read_controlFile(cfile):
    for line in cfile:
        words = line.split()
        if words[0] == 'DSET':
            file = words[1]
	elif words[0] == 'UNDEF':
            undef = float(words[1])
        elif words[0] == 'XDEF':
            xcol = int(words[1])
        elif words[0] == 'YDEF':
            rows = int(words[1]) # Frequencies/Periods
            yval = float(words[4])
        elif words[0] == 'ZDEF':
            prts = int(words[1]) # Partitions
        elif words[0] == 'TDEF':
            cols = int(words[1]) # Forecast hours
            run  = words[3]
            fhr  = run[0:2]
            step = int(words[4][0])
        else:
            continue
    return file,xcol,rows,yval,prts,cols,run,fhr,step,undef

#===========================================
#---- MAIN SCRIPT --------- MAIN SCRIPT ----
#===========================================

#-----------------------------------------
#--- Command line Parameters
#-----------------------------------------
LocName=sys.argv[1]
lon=sys.argv[2]
lat=sys.argv[3]
windSource=sys.argv[4]

#-----------------------------------------
#--- Read NOAA and NWS logos
#-----------------------------------------
noaa_logo = imread('noaa_logo.png')
nws_logo = imread('nws_logo.png')

#-----------------------------------------
#--- Read Control files
#-----------------------------------------
cWave = open('swanpartition.ctl','r')    	# Control file
cWind = open('windforhansonplots.ctl','r')    	# Control file

#----------------------------------------------
#--- Read Wave Partition binary & control file
#----------------------------------------------
fwave,waveXcol,waveRows,waveYval,wavePrts,waveCols,waveRun,waveFhr,waveStep,missing_val = read_controlFile(cWave)
bWave = open(fwave,'r')        	# Binary 1D Spectrum file

print(fwave,waveXcol,waveRows,waveYval,wavePrts,waveCols,waveRun,waveFhr,waveStep)

waveRun = waveRun.upper()

waveXvals = arange(0,waveCols,1)
waveYvals = np.linspace(0, 25, num=waveRows)	# Frequency [Hz]

waveXticks = []
for xt in waveXvals:
    waveXticks.append(str(xt*3))
    
data = np.fromfile(bWave, dtype=np.float32) # read the binary data
data = data.reshape((wavePrts*2,waveCols,waveRows)) # reshape the data file (2*components u,v)

(x,y) = np.meshgrid(waveXvals,waveYvals)

bWave.close()

#----------------------------------------------
#--- Read Wind Partition binary & control file
#----------------------------------------------
fwind,windXcol,windRows,windYval,windPrts,windCols,windRun,windFhr,windStep,missing_val = read_controlFile(cWind)
bWind = open(fwind,'r')        	# Binary 1D Spectrum file

windData = np.fromfile(bWind, dtype=np.float32) # read the binary data
windData = windData.reshape((windPrts*2,windCols,windRows)) # reshape the data file (2*components u,v)

windXvals = arange(0,windCols,1)
windYvals = np.linspace(-30,30, num=windRows)	# Frequency [Hz]

(Xwnd,Ywnd) = np.meshgrid(windXvals,windYvals)

UWind = windData[0,:,:]
VWind = windData[1,:,:]

UWind[UWind == missing_val] = nan     # Replacing missing values with NaN
VWind[VWind == missing_val] = nan     # Replacing missing values with NaN
 
mxUVwind = max(abs(np.concatenate([UWind[~np.isnan(UWind)],VWind[~np.isnan(VWind)]])))

print(fwind,windXcol,windRows,windYval,windPrts,windCols,windRun,windFhr,windStep,shape(windData),mxUVwind)

bWind.close()
      
#-----------------------------------------
#--- Prepare the Wave data for plotting
#-----------------------------------------
timeSteps = wavePrts	# (2*components u,v)

if timeSteps > 20:
    XtickSpacing = 2
elif timeSteps >= 36:
    XtickSpacing = 4
else:
    XtickSpacing = 1

VectorColors = ['#000099','#0033FF','#00CCFF','#00FF00','#FFFF00','#FF6600','#FF3300','#990000','#660099','#CC0099']

waveComp = []
mxUVwave = 0
UWave 	 = np.zeros((timeSteps,waveCols,waveRows))
VWave 	 = np.zeros((timeSteps,waveCols,waveRows))

for i in range(0,timeSteps,1): #different lines
    #print(i)
    uwave = data[i,:,:]
    uwave[uwave == missing_val] = nan     # Replacing missing values with NaN
    UWave[i,:,:] = uwave

    
    vwave = data[i+timeSteps,:,:]
    vwave[vwave == missing_val] = nan     # Replacing missing values with NaN
    VWave[i,:,:] = vwave

    vec   = np.concatenate([uwave[~np.isnan(uwave)],vwave[~np.isnan(vwave)]])
    
    if len(vec) != 0:
	waveComp.append(str(i+1))
	mxUVwave = max(max(abs(vec)),mxUVwave)
    else:
	waveComp.append('')

#-----------------------------------------
#--- Plot the data
#-----------------------------------------
for i in range(0,timeSteps,1):
    
    subplot(6,1,(1,4))
    Qwave = quiver(x,y,UWave[i,:,:],VWave[i,:,:],scale=int(np.round(mxUVwave,1)*15),color=VectorColors[i])
    
    ax=gca()
    ax.xaxis.set_major_locator(MultipleLocator(XtickSpacing))
    ax.xaxis.grid(b=True, which='major', color='#C0C0C0', linestyle=':')
    ax.yaxis.set_major_locator(MultipleLocator(2))
    ax.yaxis.grid(b=True, which='major', color='#C0C0C0', linestyle=':')
    ax.tick_params( labelsize='x-small')
    ax.set_ylabel('Peak Period [s]',labelpad = 12)

    xticks(waveXvals,waveXticks)
    xlim(0,waveXvals[-1])
    title('Gerling-Hanson Plot for '+LocName+' ('+lon+'$^\circ$,'+lat+'$^\circ$) '+'\nNWPS RUN: '+waveRun)
    xlabel('Z-Time [hours from '+waveRun+']')
    
    if i == (timeSteps-1):
	annotate(' NWPSystem\n\nWave\nPartition', xy=(1.1, 0.925), xycoords='axes fraction', color='k', horizontalalignment='center')
	for j in range(len(waveComp)):
	    annotate(waveComp[j]+'\n', xy=(1.1, 0.8-(j*0.075)), xycoords='axes fraction', color=VectorColors[j], horizontalalignment='center')

    
subplot(6,1,(5,6))
Qwind = quiver(Xwnd,Ywnd,UWind,VWind,scale=np.round(mxUVwind,1)*10,width=0.0025, color=VectorColors[0])

ax1=gca()
ax1.xaxis.set_major_locator(MultipleLocator(XtickSpacing))
ax1.xaxis.grid(b=True, which='major', color='#C0C0C0', linestyle=':')
ax1.yaxis.set_major_locator(MultipleLocator(int(np.round(mxUVwind*1.94,0))/2))
ax1.yaxis.grid(b=True, which='major', color='#C0C0C0', linestyle=':')
ax1.tick_params( labelsize='x-small')

xticks(waveXvals,waveXticks)
ylabel('Wind Speed [kts]')
ylim(int(np.round(mxUVwind*1.94,0))*-1,int(np.round(mxUVwind*1.94,0)))

subplots_adjust(hspace=1.5)    

quiverkey(Qwave,waveXvals[-1]*1.1,3,mxUVwave,'Max\nWave Height\n'+str(np.round(mxUVwave*3.28,1))+" [ft]",coordinates='data',color='r',fontproperties={'size': 'small'})
annotate(''+str(np.round((mxUVwave),1))+' [m]', xy=(1.1, 1.54), xycoords='axes fraction', color='k', horizontalalignment='center', fontsize='small')

quiverkey(Qwind,waveXvals[-1]*1.1,int(np.round(mxUVwind*1.94,0))*-0.5,mxUVwind,'WindSource\n'+windSource+'\n\nMax\nWind Speed\n'+str(np.round(mxUVwind*1.94,1))+" [knots]",coordinates='data',color='r',fontproperties={'size': 'small'})
annotate(''+str(np.round((mxUVwind),1))+' [m/s]', xy=(1.1, 0.06), xycoords='axes fraction', color='k', horizontalalignment='center', fontsize='small')


# Set up the logos in them
axes([0.1,.91,.08,.08])
axis('off')
imshow(noaa_logo,interpolation='gaussian')
axes([.84,.91,.08,.08])
axis('off')
imshow(nws_logo,interpolation='gaussian')

savefig('Hansonplot_'+LocName+'.png', dpi = 150, bbox_inches = 'tight')

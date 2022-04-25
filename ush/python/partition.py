#!/usr/bin/env python
#--------------------------------------------------------
# partition.py script
# Author: Ernesto Rodriguez, NWS WFO San Juan
# Created on 05/18/2015
# Purpose: Plots SWAN 1D Spectrum from binary file.
#--------------------------------------------------------

import matplotlib
#matplotlib.use('Agg',warn=False)
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
            yyyy = int(words[5])
            mm = int(words[6])
            dd = int(words[7])
            hh = int(words[8])
        else:
            continue
    return file,xcol,rows,yval,prts,cols,run,fhr,step,undef,yyyy,mm,dd,hh

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
region=sys.argv[5]

#-----------------------------------------
#--- Read NOAA and NWS logos
#-----------------------------------------
noaa_logo = imread('noaa_logo.png')
nws_logo = imread('nws_logo.png')

#-----------------------------------------
#--- Read Control files
#-----------------------------------------
cWave = open('swanpartition.ctl','r')           # Control file
cWind = open('windforhansonplots.ctl','r')      # Control file

#----------------------------------------------
#--- Read Wave Partition binary & control file
#----------------------------------------------
fwave,waveXcol,waveRows,waveYval,wavePrts,waveCols,waveRun,waveFhr,waveStep,missing_val,YYYY,MM,DD,HH = read_controlFile(cWave)
bWave = open(fwave,'r')         # Binary 1D Spectrum file

print(fwave,waveXcol,waveRows,waveYval,wavePrts,waveCols,waveRun,waveFhr,waveStep,YYYY,MM,DD,HH)

waveRun = waveRun.upper()

waveXvals = arange(0,waveCols,1)
waveXdates = [datetime.datetime(YYYY, MM, DD, HH, 00) + datetime.timedelta(hours=x) for x in range(0, waveCols)]
waveYvals = np.linspace(0, 25, num=waveRows)	# Frequency [Hz]

#waveXticks = []
#for xt in waveXvals:
#    waveXticks.append(str(xt*1))
waveXticks = []
for d in waveXdates:
    waveXticks.append(d.strftime("%m/%d\n%HZ"))
    
data = np.fromfile(bWave, dtype=np.float32) # read the binary data
#print(data.shape)
data = data.reshape((wavePrts*2,waveCols,waveRows)) # reshape the data file (2*components u,v)
#print(data.shape)
data2 = data.reshape((wavePrts*2,waveRows,waveCols)) # reshape the data file (2*components u,v)
#print(data2.shape)

(x,y) = np.meshgrid(waveXvals,waveYvals)

bWave.close()

#----------------------------------------------
#--- Read Wind Partition binary & control file
#----------------------------------------------
fwind,windXcol,windRows,windYval,windPrts,windCols,windRun,windFhr,windStep,missing_val,YYYY,MM,DD,HH = read_controlFile(cWind)
bWind = open(fwind,'r')         # Binary 1D Spectrum file

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

XtickSpacing = 1

#VectorColors = ['#000099','#0033FF','#00CCFF','#00FF00','#FFFF00','#FF6600','#FF3300','#990000','#660099','#CC0099']
VectorColors = ['#0033FF','#FF0000','#00CCFF','#00FF00','#8B008B','#FF6600','#FF3300','#990000','#660099','#CC0099']

waveComp = []
mxUVwave = 0
mxUVwave2 = 0
UWave    = np.zeros((wavePrts,waveCols,waveRows))
VWave    = np.zeros((wavePrts,waveCols,waveRows))
UWave2    = np.zeros((wavePrts,waveCols,waveRows))
VWave2    = np.zeros((wavePrts,waveCols,waveRows))

for i in range(0,wavePrts,1): #different lines
    uwave = data[i,:,:]
    uwave[uwave == missing_val] = nan     # Replacing missing values with NaN
    UWave[i,:,:] = uwave
    uwave2 = np.transpose(data2[i,:,:])
    uwave2[uwave2 == missing_val] = nan     # Replacing missing values with NaN
    UWave2[i,:,:] = uwave2

    vwave = data[i+wavePrts,:,:]
    vwave[vwave == missing_val] = nan     # Replacing missing values with NaN
    VWave[i,:,:] = vwave
    vwave2 = np.transpose(data2[i+wavePrts,:,:])
    vwave2[vwave2 == missing_val] = nan     # Replacing missing values with NaN
    VWave2[i,:,:] = vwave2

    vec   = np.concatenate([uwave[~np.isnan(uwave)],vwave[~np.isnan(vwave)]])
    vec2   = np.column_stack(( np.nansum(uwave2[:,:], axis=1), np.nansum(vwave2[:,:], axis=1) ))
    
    if len(vec) != 0:
        waveComp.append(str(i+1))
        mxUVwave = max(max(abs(vec)),mxUVwave)
    else:
        waveComp.append('')

    if len(vec2) != 0:
        mxUVwave2 = max(max(np.linalg.norm(vec2, axis=1)),mxUVwave2)

# Set the tick interval for the Hs panel
WaveScaleFeet = np.ceil(3.28*mxUVwave2)
print(WaveScaleFeet)
if WaveScaleFeet > 20:
    YtickSpacing = 5
elif WaveScaleFeet >= 8:
    YtickSpacing = 2
else:
    YtickSpacing = 1

#Set regional override for fixed vector scaling
#if region == 'wr':
#    mxUVwave = 10./3.28    #in ft/3.28
#    mxUVwind = 40./1.94   #in knt/1.94

#-----------------------------------------
#--- Plot the data
#-----------------------------------------
wavePrts = min(9,wavePrts)          ## Limit plot to 9 wave systems
for i in range(0,wavePrts,1):
    hscomp = np.zeros((wavePrts, 145))
    
    subplot(8,1,(1,4))
    ## 12/23/16 AW: With model output now hourly, thin out quiver plot to 3-hourly again
    #Qwave = quiver(x[:,0::3],y[:,0::3],UWave[i,:,0::3],VWave[i,:,0::3],scale=int(np.round(mxUVwave,1)*15),color=VectorColors[i])
    Qwave = quiver(x,y,UWave[i,:,:],VWave[i,:,:],scale=int(np.round(mxUVwave,1)*15),color=VectorColors[i])
    
    ax=gca()
    ax.xaxis.set_major_locator(MultipleLocator(XtickSpacing))
    ax.xaxis.grid(b=True, which='major', color='#C0C0C0', linestyle=':')
    ax.yaxis.set_major_locator(MultipleLocator(2))
    ax.yaxis.grid(b=True, which='major', color='#C0C0C0', linestyle=':')
    ax.tick_params( labelsize='x-small')
    ax.set_ylabel('Peak Wave Period [s]',labelpad = 12)

    xticks(waveXvals[0::12],waveXticks[0::12])
    xlim(0,waveXvals[-1])
    title('Gerling-Hanson Plot for '+LocName+' ('+lon+'$^\circ$,'+lat+'$^\circ$) '+'\nNWPS RUN: '+waveRun)
    #xlabel('Time [UTC]',labelpad=2)
    
    if i == (wavePrts-1):
        annotate('\n\n\nWave\nSystem', xy=(1.1, 0.925), xycoords='axes fraction', color='k', horizontalalignment='center')
        for j in range(min(9,len(waveComp))):          ## Limit plot to 9 wave systems
            annotate(waveComp[j]+'\n', xy=(1.1, 0.74-(j*0.080)), xycoords='axes fraction', color=VectorColors[j], horizontalalignment='center')

    subplot(8,1,(5,6))
    hscomp[i,:] = np.sqrt(np.nansum(UWave2[i,:,:], axis=1)**2 + np.nansum(VWave2[i,:,:], axis=1)**2)
    hscomp[hscomp == 0.] = nan     # Replace missing values with NaN
    hscomp = 3.28*hscomp     # Convert to feet
    Hwave = plot(waveXvals, hscomp[i,:], color=VectorColors[i])   

    ax1=gca()
    ax1.xaxis.set_major_locator(MultipleLocator(XtickSpacing))
    ax1.xaxis.grid(b=True, which='major', color='#C0C0C0', linestyle=':')
    ax1.yaxis.set_major_locator(MultipleLocator(2))
    ax1.yaxis.grid(b=True, which='major', color='#C0C0C0', linestyle=':')
    ax1.tick_params( labelsize='x-small')
    ax1.set_ylabel('Hs [ft]',labelpad = 18)
    #pos1 = ax1.get_position() # get the original position 
    #pos2 = [pos1.x0, pos1.y0-0.3, pos1.width, pos1.height]
    #ax1.set_position(pos2)

    xticks(waveXvals[0::12],waveXticks[0::12])
    xlim(0,waveXvals[-1])
    yticks(np.arange(0, WaveScaleFeet+1, YtickSpacing))
    ylim(0, WaveScaleFeet)
    
subplot(8,1,(7,8))
## 12/23/16 AW: With model output now hourly, thin out quiver plot to 3-hourly again 
#Qwind = quiver(Xwnd[:,0::3],Ywnd[:,0::3],UWind[:,0::3],VWind[:,0::3],scale=np.round(mxUVwind,1)*10,width=0.0025, color=VectorColors[0])
#Qwind = quiver(Xwnd,Ywnd,UWind,VWind,scale=np.round(mxUVwind,1)*10,width=0.0025, color=VectorColors[0])
Qwind = quiver(Xwnd,Ywnd,UWind,VWind,scale=np.round(mxUVwind,1)*14.5,width=0.0025, color=VectorColors[0])

ax2=gca()
ax2.xaxis.set_major_locator(MultipleLocator(XtickSpacing))
ax2.xaxis.grid(b=True, which='major', color='#C0C0C0', linestyle=':')
ax2.yaxis.set_major_locator(MultipleLocator(int(np.round(mxUVwind*1.94,0))/2))
ax2.yaxis.grid(b=True, which='major', color='#C0C0C0', linestyle=':')
ax2.tick_params( labelsize='x-small')

xticks(waveXvals[0::12],waveXticks[0::12])
xlim(0,waveXvals[-1])
ylabel('Wind Speed [kts]')
#ylim(int(np.round(mxUVwind*1.94,0))*-1,int(np.round(mxUVwind*1.94,0)))
ylim(int(np.ceil(mxUVwind*1.94))*-1,int(np.ceil(mxUVwind*1.94)))
#print(mxUVwind*1.94)

subplots_adjust(hspace=1.5)    

quiverkey(Qwave,waveXvals[-1]*1.1,3,mxUVwave,'Wave Height\nScale\n'+str(np.round(mxUVwave*3.28,1))+" [ft]",coordinates='data',color='#0033FF',fontproperties={'size': 'small'})
annotate(''+str(np.round((mxUVwave),1))+' [m]', xy=(1.1, 2.94), xycoords='axes fraction', color='k', horizontalalignment='center', fontsize='small')

quiverkey(Qwind,waveXvals[-1]*1.1,int(np.round(mxUVwind*1.94,0))*-0.5,mxUVwind,'Wind Source:\n'+windSource[:8]+'\n\nWind Speed\nScale\n'+str(np.round(mxUVwind*1.94,1))+" [kts]",coordinates='data',color='#0033FF',fontproperties={'size': 'small'})
annotate(''+str(np.round((mxUVwind),1))+' [m/s]', xy=(1.1, 0.06), xycoords='axes fraction', color='k', horizontalalignment='center', fontsize='small')


# Set up the logos in them
axes([0.1,.91,.08,.08])
axis('off')
imshow(noaa_logo,interpolation='gaussian')
axes([.84,.91,.08,.08])
axis('off')
imshow(nws_logo,interpolation='gaussian')

savefig('Hansonplot_'+LocName+'.png', dpi = 150, bbox_inches = 'tight')

#!/usr/bin/env python

print('Entering get_estofs_currents.py...')
import os, sys
lonmin = float(sys.argv[1])
lonmax = float(sys.argv[2])
latmin = float(sys.argv[3])
latmax = float(sys.argv[4])
estofshours = int(sys.argv[5])
datafile = sys.argv[6]
outputdir = sys.argv[7]
outputtime = sys.argv[8]
mode = sys.argv[9]
print(lonmin)
print(lonmax)
print(latmin)
print(latmax)
print(estofshours)
print(datafile)
print(outputdir)
print(outputtime)
print(mode)
print('Plotting unstructured file '+str(datafile))

# Script for plotting unstructured WW3 output files in netCDF format, created by ww3_ounf
# Andre van der Westhuysen, 09/08/20
#
import matplotlib
#> print(matplotlib.__version__)
#matplotlib.use('Agg',warn=False)

import os, sys
import datetime
from matplotlib.tri import Triangulation, TriAnalyzer, LinearTriInterpolator
import matplotlib.pyplot as plt
import netCDF4
import numpy as np
"""
import cartopy	
import cartopy.crs as ccrs	
import cartopy.feature as cfeature
from cartopy.mpl.gridliner import LONGITUDE_FORMATTER, LATITUDE_FORMATTER
"""

NWPSdir = os.environ['NWPSdir']
"""
cartopy.config['pre_existing_data_dir'] = NWPSdir+'/lib/cartopy'
print('Reading cartopy shapefiles from:')
print(cartopy.config['pre_existing_data_dir'])
"""

lonmin = float(sys.argv[1])
lonmax = float(sys.argv[2])
latmin = float(sys.argv[3])
latmax = float(sys.argv[4])
estofshours = int(sys.argv[5])
datafile = sys.argv[6]
outputdir = sys.argv[7]
outputtime = sys.argv[8]
mode = sys.argv[9]
print('Plotting unstructured file '+str(datafile))

def plot_cur(storm, datafile, lonmin, lonmax, latmin, latmax):

   print('Extracting ESTOFS '+mode+' currents for: WFO '+outputdir[-10:-7].upper()+' '+str(lonmin)+' '+str(lonmax)+' '+str(latmin)+' '+str(latmax))

   #Single file netCDF reading
   ncf=datafile
   nco=netCDF4.Dataset(ncf)

   #print(nco.variables)

   #Get fields to plot
   lon=nco.variables['x'][:]
   lat=nco.variables['y'][:]
   base_date=nco['time'].base_date
   timeinseconds=nco.variables['time'][:]
   #AW ucur=nco.variables['u-vel'][:]
   #AW vcur=nco.variables['v-vel'][:]
   #AW triangles=nco.variables['element'][:,:]

   datetime_basedate = datetime.datetime.strptime(base_date[:19], '%Y-%m-%d %H:%M:%S')
   print('ESTOFS base date is',datetime_basedate)

   #AW ucur[ucur<-9.] = 0.
   #AW vcur[vcur<-9.] = 0.

   #AW print(triangles[0:20])

   #reflon=np.linspace(lon.min(),lon.max(),1000)
   #reflat=np.linspace(lat.min(),lat.max(),1000)
   reflon=np.linspace(lonmin, lonmax, 1000)
   reflat=np.linspace(latmin, latmax, 1000)
   reflon,reflat=np.meshgrid(reflon,reflat)

   """
   plt.figure(figsize = [6.4, 3.8])
   """

   flatness=0.10  # flatness is from 0-.5 .5 is equilateral triangle
   #AW triangles=triangles-1  # Correct indices for Python's zero-base
   #AW tri=Triangulation(lon,lat,triangles=triangles)
   
   #zoom_ind = np.where((lon>-126.28 & lon<-123.30) & (lat>43.50 & lat<47.15))
   zoom_ind = ((lon>(lonmin-1.0)) & (lon<(lonmax+1.0))) & ((lat>(latmin-1.0)) & (lat<(latmax+1.0)))
   tri=Triangulation(lon[zoom_ind],lat[zoom_ind])

   mask = TriAnalyzer(tri).get_flat_tri_mask(flatness)
   tri.set_mask(mask)

   # Loop through each time step and plot results
   for hour in range(0, estofshours):
      ucur=nco.variables['u-vel'][hour,:]
      vcur=nco.variables['v-vel'][hour,:]
      ucur[ucur<-9.] = 0.
      vcur[vcur<-9.] = 0.

      """
      plt.clf()
      ax = plt.axes(projection=ccrs.Mercator())
      ax.set_extent([lonmin, lonmax, latmin, latmax], crs=ccrs.PlateCarree())
      """

      dt = datetime_basedate + datetime.timedelta(seconds=timeinseconds[hour])
      if mode == 'nowcast':
         dt_init = datetime_basedate + datetime.timedelta(seconds=(timeinseconds[0]+(estofshours-1)*3600)) # Add 5 hours to get nowcast time at f000
      else:
         #AW dt_init = datetime_basedate + datetime.timedelta(seconds=(timeinseconds[0]-3600)) # Count back 1 hour since forecast file starts at f001
         dt_init = datetime_basedate + datetime.timedelta(seconds=(timeinseconds[0]+5*3600)) # Add 5 hours to get nowcast time at f000
      dstr = datetime.date.strftime(dt,'%Y%m%d%H:%M:%S')
      dstr_init = datetime.date.strftime(dt_init,'%Y%m%d_%H')[0:12]
      epoch_init = int(dt_init.timestamp())
      dstr = dstr[0:8]+' '+dstr[8:17]
      print('Extracting WFO '+outputdir[-10:-7].upper()+' '+dstr)

      par=np.sqrt( np.square(np.double(ucur[zoom_ind])) + np.square(np.double(vcur[zoom_ind])) )
      #par2=np.double(dir[hour,:])

      tli=LinearTriInterpolator(tri,par)
      par_interp=tli(reflon,reflat)

      tli2=LinearTriInterpolator(tri,np.double(ucur[zoom_ind]))
      u_interp=tli2(reflon,reflat)

      tli3=LinearTriInterpolator(tri,np.double(vcur[zoom_ind]))
      v_interp=tli3(reflon,reflat)

      """
      plt.pcolormesh(reflon,reflat,par_interp,vmin=0.0,vmax=1.0,shading='flat',cmap=plt.cm.jet, transform=ccrs.PlateCarree())
      #plt.scatter(lon[zoom_ind], lat[zoom_ind], s=0.5, c=par,cmap=plt.cm.jet, transform=ccrs.PlateCarree())
      #plt.contourf(reflon, reflat, par_interp, vmax=60.0, cmap=plt.cm.jet, transform=ccrs.PlateCarree())
      cb = plt.colorbar()
      cb.ax.tick_params(labelsize=8)
      #rowskip=np.floor(par_interp.shape[0]/25)
      #colskip=np.floor(par_interp.shape[1]/25)
      rowskip = 25
      colskip = 25
      plt.quiver(reflon[0::rowskip,0::colskip],reflat[0::rowskip,0::colskip],\
            u_interp[0::rowskip,0::colskip],v_interp[0::rowskip,0::colskip], \
            scale=6.,color='black',pivot='middle',units='inches',alpha=0.7,transform=ccrs.PlateCarree())

      #coast = cfeature.GSHHSFeature(scale='full',edgecolor='black',facecolor=cfeature.COLORS['land'],linewidth=0.25)
      coast = cfeature.GSHHSFeature(scale='full',edgecolor='black',facecolor='none',linewidth=0.25)	
      ax.add_feature(coast)
      
      gl = ax.gridlines(crs=ccrs.PlateCarree(), draw_labels=True,
                  linewidth=2, color='gray', alpha=0.5, linestyle='--')
      gl.xlabels_top = False
      gl.ylabels_right = False
      gl.xlines = False
      gl.ylines = False
      gl.xformatter = LONGITUDE_FORMATTER
      gl.yformatter = LATITUDE_FORMATTER
      gl.xlabel_style = {'size': 6, 'color': 'black'}
      gl.ylabel_style = {'size': 6, 'color': 'black'}
      figtitle = storm+': Cur (m/s): '+dstr
      plt.title(figtitle)

      dtlabel = datetime.date.strftime(dt,'%Y%m%d%H%M%S')
      dtlabel = dtlabel[0:8]+'_'+dtlabel[8:14]
      filenm = 'estofs_'+storm+'_cur_'+dtlabel+'.png'
      plt.savefig(outputdir+"/"+filenm,dpi=150,bbox_inches='tight',pad_inches=0.1)
      """

      u_interp = np.nan_to_num(u_interp) # Replace nans with default zero
      v_interp = np.nan_to_num(v_interp) # Replace nans with default zero

      #print(reflon.shape)
      #print(reflat.shape)
      #print(u_interp.shape)
      #print(v_interp.shape)

      u_interp_1d = u_interp.reshape(1000*1000)
      #print(u_interp_1d.shape)
      v_interp_1d = v_interp.reshape(1000*1000)
      #print(v_interp_1d.shape)

      if mode == 'nowcast':
         if hour < (estofshours-1):
            with open(outputdir+"/"+"wave_estofs_uv_"+str(epoch_init)+"_"+dstr_init+"_h"+str(estofshours-1-hour).zfill(3)+".dat", "w") as f:
               np.savetxt(f, u_interp_1d, fmt='%1.2f')
               np.savetxt(f, v_interp_1d, fmt='%1.2f')
         else:
            with open(outputdir+"/"+"wave_estofs_uv_"+str(epoch_init)+"_"+dstr_init+"_f"+str(estofshours-1-hour).zfill(3)+".dat", "w") as f:
               np.savetxt(f, u_interp_1d, fmt='%1.2f')
               np.savetxt(f, v_interp_1d, fmt='%1.2f')
      else:
         with open(outputdir+"/"+"wave_estofs_uv_"+str(epoch_init)+"_"+dstr_init+"_f"+str(hour).zfill(3)+".dat", "w") as f:
            np.savetxt(f, u_interp_1d, fmt='%1.2f')
            np.savetxt(f, v_interp_1d, fmt='%1.2f')
    
      del(par)
      del(par_interp)
      del(u_interp)
      del(v_interp)
      del(u_interp_1d)
      del(v_interp_1d)

   f2 = open(outputtime, "w")
   f2.write(str(epoch_init))
   f2.close()

if __name__ == "__main__":
   #plot_cur(storm='Global_ESTOFS', datafile1='estofs.t18z.fields.cwl.vel.nowcast.nc')
   #plot_cur(storm='Global_ESTOFS', datafile1='estofs.t18z.fields.cwl.vel.forecast.nc')
   plot_cur(storm='Global_ESTOFS', datafile=datafile, lonmin=lonmin, lonmax=lonmax, latmin=latmin, latmax=latmax)


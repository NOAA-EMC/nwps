# swn_reginterp.py script
# Purpose: Interpolates SWAN results from an unstructured mesh onto a regular grid
# Andre van der Westhuysen, 10/30/13

from __future__ import division
import sys
import os
import numpy as np
import numpy.ma as ma
import netCDF4
from matplotlib.tri import Triangulation, LinearTriInterpolator
from StringIO import StringIO

#import ipdb; ipdb.set_trace()

#-----------------------------------------
#--- Command line Parameters
#-----------------------------------------
direc=sys.argv[1]
ncfile=sys.argv[2]
grid=sys.argv[3]
par=sys.argv[4]
siteid=direc[-17:-14]

#-----------------------------------------
#--- Output mesh configuration
#-----------------------------------------
Xpmin = #SWLONCIRCN3#-360.
Xpmax = (#SWLONCIRCN3#+#XLENCN3#)-360.
mxc = #MESHLONN3#
Ypmin = #SWLATN3#  
Ypmax = #SWLATN3#+#YLENCN3#
myc = #MESHLATN3#

def array2cols(data,filename,cols):
	rows=data.shape[0]
	s=''
	for row in range(rows):
		s+=array_one_row(data[row,],filename,cols)
	with open(filename,'a') as f:                  # append to file
		f.write(s)
	return

def array_one_row(data,filename,cols):
	"""
	Convert numpy masked array to ascii fixed width file
	"""
	rows=int(data.size/cols)                       # calc number of rows needed
	if data.size%cols != 0:                        # add one more for spillover
		rows+=1
	data2=data.filled().copy()                     # convert to filled numpy array
	data2=np.resize(data2,(rows,cols))             # expand to new size and pad with zeros
	spares=cols-data.size%cols                     # compute number of values to blank at end
	if (spares > 0) & (spares < 6):
		data2[-1,-spares:]=-888.               # convert any end zeros to dummy values
	s = StringIO()                                 # create internal file
	np.savetxt(s,data2,fmt='%11.4e',delimiter=' ') # save to internal file
	s2=s.getvalue().replace('-8.8800e+02',' '*11)  # replace dummy values
        #del s                                          # Cleans internal file
	return s2

#--- Added read triangulation from fort.14 to avoid interpolation over land mass ---
if (siteid == 'hfo'):
   def get_grid_tri(fname_grid):
	# get triangulation from fort.14
	grid = open(fname_grid)
	tmp = grid.readlines()
	n_points = int(tmp[1].split()[1])
	n_elements = int(tmp[1].split()[0])
	points_array = tmp[2:n_points+2]
	element_array = tmp[n_points+2: n_points+n_elements+2]
	arraywidth = len(np.array(element_array[0].split(),dtype=int))
	elements = np.zeros((n_elements,arraywidth),dtype=int,order='C')
	for i in range(0, n_elements):
		elements[i] = np.array(element_array[i].split(),dtype=int)-1
	tri_grid = elements[:,arraywidth-3:arraywidth]		# indices of grid point for each element
	return tri_grid
#--- Added read triangulation from fort.14 to avoid interpolation over land mass ---

# Load unstructured grid (Matlab binary)
infile = direc+ncfile
print 'Loading: '+infile

ncf=infile
nco=netCDF4.Dataset(ncf)

print 'Interpolating: '+grid+', '+par
parkey = ''
parkey2 = ''

#Look up matching key
if par == 'HSIG':
   parkey = 'hs'
   excp = -0.9000E+01
if par == 'WIND':
   parkey = 'xwnd'
   parkey2 = 'ywnd'
   excp = 00.00
if par == 'TPS':
   parkey = 'tps'
   excp = -0.9000E+01
if par == 'DIR':
   parkey = 'theta0'
   excp = -0.9990E+03
if par == 'PDIR':
   parkey = 'thetap'
   excp = -0.9990E+03
if par == 'VEL':
   parkey = 'xcur'
   parkey2 = 'ycur'
   excp = 00.00
if par == 'WATL':
   parkey = 'ssh'
   excp = -0.9900E+02         #NOTE: This is adapted from standard SWAN to deal with ice fields
if par == 'HSWE':
   parkey = 'hswe'
   excp = -0.9000E+01
if par == 'WLEN':
   parkey = 'L'
   excp = -0.9000E+01
if par == 'DEPTH':
   parkey = 'depth'
   excp = -99

epochtime=nco.variables['time'][:]
fields=nco.variables[parkey][:]
if (parkey2 == 'ywnd') | (parkey2 == 'ycur'):
   fields2=nco.variables[parkey2][:]

Xp=nco.variables['longitude'][:]-360
Yp=nco.variables['latitude'][:]
reflon=np.linspace(Xpmin,Xpmax,mxc+1)
reflat=np.linspace(Ypmin,Ypmax,myc+1)
reflon,reflat=np.meshgrid(reflon,reflat)

#--- Added read triangulation from fort.14 to avoid interpolation over land mass ---
if (siteid == 'hfo'):
   tri_grid = get_grid_tri(direc+'fort.14')
   tri=Triangulation(Xp,Yp,triangles = tri_grid)
else:
   tri=Triangulation(Xp,Yp)
#--- Added read triangulation from fort.14 to avoid interpolation over land mass ---

#fout = open(direc+par+'.'+grid+'.CGRID',"w")
fname = direc+par+'.'+grid+'.CGRID'
#Clean old output file before writing new one
if os.path.isfile(fname):
   os.remove(fname)

for rec in range(0, len(epochtime)):
   print 'Hour ',rec
   #Read and interpolate data
   var=ma.array(fields[rec,:],dtype='double')
   var.fill_value=np.nan
   var=var.filled()
   #var2=ma.array(var,mask=np.isnan(var),fill_value=-999)
      
   tli=LinearTriInterpolator(tri,var)
   var_interp=tli(reflon,reflat)

   #Replace NaNs with exception values
   #var_interp[np.isnan(var_interp)]=excp
   var_interp.fill_value=excp

   #for irow in range(0,var_interp.shape[0]):
   #   #for icol in range(0,var_interp.shape[1]):
   #   for ind in range(0,var_interp.shape[1],6):
   #      for item in var_interp[irow,ind:(ind+6)]:
   #         fout.write('  %.4e' % item)
   #      fout.write('\n')
   array2cols(var_interp,fname,6)

   #In case of a vector field, write the second vector component
   if (parkey2 == 'ywnd') | (parkey2 == 'ycur'):
      var=ma.array(fields2[rec,:],dtype='double')
      var.fill_value=np.nan
      var=var.filled()
      #var2=ma.array(var,mask=np.isnan(var))

      tli=LinearTriInterpolator(tri,var)
      var_interp=tli(reflon,reflat)

      #Replace NaNs with exception values
      #var_interp[np.isnan(var_interp)]=excp
      var_interp.fill_value=excp

      #for irow in range(0,var_interp.shape[0]):
      #   #for icol in range(0,var_interp.shape[1]):
      #   for ind in range(0,var_interp.shape[1],6):
      #      for item in var_interp[irow,ind:(ind+6)]:
      #         fout.write('  %.4e' % item)
      #      fout.write('\n')
      array2cols(var_interp,fname,6)

#fout.close()


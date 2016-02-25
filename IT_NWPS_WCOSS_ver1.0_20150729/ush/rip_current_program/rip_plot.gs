# -----------------------------------------------------------
# GrADS Script
# Program: Rip Current Model Probabilities
# Tested Operating System(s): RHEL 5/6
# Shell Used: BASH shell
# Original Author(s): alex.gibbs@noaa.gov
# File Creation Date: 12/10/2013
# Date Last Modified: 12/10/2013
#
# Version control: 1.00
#
# Support Team:
#
# Contributors:
#
# -----------------------------------------------------------
# ------------- Program Description and Details -------------
# -----------------------------------------------------------
#
# This program is executed from the run_nos.sh script. To
# execute this program, a GrADS ctl and data file are needed 
# in a working GrADS directory configured within the NWPS
# package. To view an example graphic or plot from this script,
# view the online documentation at:
#
# innovation.srh.noaa.gov/nwps/nwpsmanual.php/rip_current_program
#
# To configure this script for your site, begin on line 104 and 
# replace the Miami Beach wording on line 112 and 115. Also, 
# ensure the correct PNG is setup toward the bottom of this script.
# This image will be the image displaying the 2D spatial plot of your
# bathymetry and a point where the probabilities will be forecast for 
# in your time series.
#
# View an example plot provided with this package: ripprob.png 
#
# To execute: 1st ensure you have: ripprob.ctl, rip.nc and swan.ctl
# in your dir.
#                            
# $NWPSdir/lib64/grads/bin/grads -blc rip_plot.gs 
# 
# -----------------------------------------------------------

'reinit'
'open swan.ctl'

# time series 
'set vpage 4 11 1.3 3.3'
'set lat 25.895'
'set lon -80.10'
'set grads off'
'set grid off'
'set t 1 12'
'set vrange -1 1'
'set ylint .5'
'set cmark 0'
'set ccolor 1'
'set cint 0'
'set digsiz 20'
'set arrlab on'
'set arrscl .75'
'set xlopts 1 5 0.15'
'set gxout linefill'
'define wlev= wlevel*3.28'
'set lfcols  1 11' ; 'd ('wlev'*0);('wlev')'

'close 1'

'open ripprob.ctl'

'set vpage 4 11 4.75 6.75'
'set t 1 12'
'set grads off'
'set ylab on'
'set ylopts 1 3 .2'
'set xlab off'
'set ylint 5'
'set cmark 1'
#draw y on left
'set ylpos 0 l'
'set vrange 0 10'
'set ylint 2'
'set ccolor 2'
'set gxout linefill'
'define hgt= hsig*3.28'
'set lfcols  1 11' ; 'd ('hgt'*0);('hgt')'
# draw y on right
'set ylpos 0 r'
'set vrange 0 20'
'set ylint 5'
'set cthick 4'
'set ccolor 7'
'set gxout bar'
'set bargap 80'
'set baropts fill'
'd period'


'set vpage 4 11 2.8 5.3'
'set grads off'
'set ylint 1'
'set cmark 0'
'set ccolor 3'
'set vrange 0 100'
'set ylint 20'
'set ylab on'
'set gxout bar'
'set bargap 70'
'set baropts fill'
'd prob*100'

#### Draw title and labels #####

'set vpage off'
# 'draw title Rip Current Probability\North Miami Beach - Haulover Inlet'
'set strsiz 0.2'
'set string 1 tc 5 0'
'draw string 5.75 8.25 Rip Current Probability'
'draw string 5.75 7.8 North Miami Beach - Haulover Inlet'
'draw string 5.75 7.4 33 hr Forecast'
'set strsiz .15'
'draw string 2.6 6.4 North Miami Beach (Depth-ft)'
'set strsiz .1'
'set string 4 tl 2 0'
'draw string 5 6.5 (ft) Significant Wave Height (5m)'
'set string 12 tl 2 0'
'draw string 8.8 6.5 Peak Wave Period  (sec)'
'set string 1 tc 5 0'
'draw string 7.9 5.05 Rip Current Probability (%)'
'draw string 8 3.05 Tide (ft) (Relative to MSL)'

'set strsiz .09'
'set string 1 tl 2 0'

# 'set line 2 1 6'
# 'draw string 6.95 4.2 Hazardous Rips Likely'
# 'draw line 5.27 4.05 10.68 4.05'

'set strsiz .125'
'draw string .35 .8 **Experimental**: The accuracy or reliability of these forecasts are not guaranteed nor'
'draw string .75 .6 warranted in any way. These forecasts should not be used as the sole resource for decision'
'draw string .75 .4 making. These graphics may not be available at all times.'

  'printim ripprob.png x1024 y768 white'
  '!/usr/bin/convert ripprob.png -draw "image over 2,2 0,0 noaa_logo.gif" ripprob.png'
  '!/usr/bin/convert ripprob.png -draw "image over 950,3 0,0 nws_logo.gif" ripprob.png'
#  '!/usr/bin/convert ripprob.png -draw "image over 0,175 100,0 ripmodel.PNG" ripprob.png'
  '!/usr/bin/convert ripprob.png -draw "image over 15,220 100,0 cg2bathy.PNG" ripprob.png'
  
'quit'


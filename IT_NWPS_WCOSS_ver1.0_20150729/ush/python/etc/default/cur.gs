'reinit'
t1=1
'open swan.ctl'
'q file'
rec=sublin(result,5)
tt=subwrd(rec,12)

while(t1<=tt)
 'set grads off'
 'set mpdset hires'
 'set t 't1
 'q dims'
 line=sublin(result,5)
 time=subwrd(line,6)
 <!-- SET TIMESTEP HERE -->
 'define rad = 4*atan2(1.0,1.0)/180'
 'define u = -curspd*sin(rad*curdir)'
 'define v = -curspd*cos(rad*curdir)'
 'color 0 7 .5 -kind darkblue->dodgerblue->yellow->orange->red->darkred'
 'set gxout stream'
 'set ccolor 1'
 'd u ; v ; mag(u,v)'
 'run cbarn.gs'
 'set line 1 1 1'
 'draw shp marine_zones'
 'draw shp river_basins'
 'draw shp lakes'
 'set shpopts 15'
 'draw shp rivers'
 'draw shp zones'
 'draw string 4.8 .2 **EXPERIMENTAL**'
 'draw title NWPS Surface Horizontal Current (knots)\Hour 't2' ('time')'
 if (t2 < 10)
  'printim swan_cur_hr00't2'.png x1024 y768 white'
  '!/usr/bin/convert swan_cur_hr00't2'.png -draw "image over 2,2 0,0 noaa_logo.gif" swan_cur_hr00't2'.png'
  '!/usr/bin/convert swan_cur_hr00't2'.png -draw "image over 950,3 0,0 nws_logo.gif" swan_cur_hr00't2'.png'
 else
   if (t2 < 100)
    'printim swan_cur_hr0't2'.png x1024 y768 white'
    '!/usr/bin/convert swan_cur_hr0't2'.png -draw "image over 2,2 0,0 noaa_logo.gif" swan_cur_hr0't2'.png'
    '!/usr/bin/convert swan_cur_hr0't2'.png -draw "image over 950,3 0,0 nws_logo.gif" swan_cur_hr0't2'.png'
   else
    'printim swan_cur_hr't2'.png x1024 y768 white'
    '!/usr/bin/convert swan_cur_hr't2'.png -draw "image over 2,2 0,0 noaa_logo.gif" swan_cur_hr't2'.png'
    '!/usr/bin/convert swan_cur_hr't2'.png -draw "image over 950,3 0,0 nws_logo.gif" swan_cur_hr't2'.png'
   endif
 endif
 'c'
 t1=t1+1
endwhile

'quit' 



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
 'set gxout shaded'
 'color 0 24 2 -kind darkblue->cyan->lime->yellow->orange->red->darkred->maroon'
 'd const(waveper,0,-u)'
 'run cbarn.gs'
 'set gxout vector'
 'set arrlab off'
 'set arrscl 0.2'
 'define rad = 4*atan2(1.0,1.0)/180'
 'define uwave = -1*sin(rad*wavedir)'
 'define vwave = -1*cos(rad*wavedir)'
 'set ccolor 1'
 'd skip(uwave,10,10);skip(vwave,10,10)'
 'set line 1 1 1'
 'draw shp marine_zones'
 'draw shp river_basins'
 'draw shp lakes'
 'set shpopts 15'
 'draw shp rivers'
 'draw shp zones' 
 'draw title NWPS Peak Wave Period (s) and Direction\Hour 't2' ('time')'
 'draw string 4.8 .2 **EXPERIMENTAL**'
 if (t2 < 10)
  'printim swan_waveperiod_hr00't2'.png x1024 y768 white'
  '!/usr/bin/convert swan_waveperiod_hr00't2'.png -draw "image over 2,2 0,0 noaa_logo.gif" swan_waveperiod_hr00't2'.png'
  '!/usr/bin/convert swan_waveperiod_hr00't2'.png -draw "image over 950,3 0,0 nws_logo.gif" swan_waveperiod_hr00't2'.png'
 else
   if (t2 < 100)
    'printim swan_waveperiod_hr0't2'.png x1024 y768 white'
    '!/usr/bin/convert swan_waveperiod_hr0't2'.png -draw "image over 2,2 0,0 noaa_logo.gif" swan_waveperiod_hr0't2'.png'
    '!/usr/bin/convert swan_waveperiod_hr0't2'.png -draw "image over 950,3 0,0 nws_logo.gif" swan_waveperiod_hr0't2'.png'
   else
    'printim swan_waveperiod_hr't2'.png x1024 y768 white'
    '!/usr/bin/convert swan_waveperiod_hr't2'.png -draw "image over 2,2 0,0 noaa_logo.gif" swan_waveperiod_hr't2'.png'
    '!/usr/bin/convert swan_waveperiod_hr't2'.png -draw "image over 950,3 0,0 nws_logo.gif" swan_waveperiod_hr't2'.png'
   endif
 endif
 'c'
 t1=t1+1
endwhile

'quit' 



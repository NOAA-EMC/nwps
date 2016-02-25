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
 'color 0 36 2 -kind darkblue->dodgerblue->lime->yellow->orange->red->magenta->maroon->lavenderblush'
 'd swell*3.28'
 'run cbarn.gs'
 'set line 1 1 1'
 'draw shp marine_zones'
 'draw shp river_basins'
 'draw shp lakes'
 'set shpopts 15'
 'draw shp rivers'
 'draw shp zones'
 'draw title NWPS Swell (ft)\Hour 't2' ('time')'
 'draw string 4.8 .2 **EXPERIMENTAL**'
 if (t2 < 10)
  'printim swan_swell_hr00't2'.png x1024 y768 white'
  '!/usr/bin/convert swan_swell_hr00't2'.png -draw "image over 2,2 0,0 noaa_logo.gif" swan_swell_hr00't2'.png'
  '!/usr/bin/convert swan_swell_hr00't2'.png -draw "image over 950,3 0,0 nws_logo.gif" swan_swell_hr00't2'.png'
 else
   if (t2 < 100)
    'printim swan_swell_hr0't2'.png x1024 y768 white'
    '!/usr/bin/convert swan_swell_hr0't2'.png -draw "image over 2,2 0,0 noaa_logo.gif" swan_swell_hr0't2'.png'
    '!/usr/bin/convert swan_swell_hr0't2'.png -draw "image over 950,3 0,0 nws_logo.gif" swan_swell_hr0't2'.png'
   else
    'printim swan_swell_hr't2'.png x1024 y768 white'
    '!/usr/bin/convert swan_swell_hr't2'.png -draw "image over 2,2 0,0 noaa_logo.gif" swan_swell_hr't2'.png'
    '!/usr/bin/convert swan_swell_hr't2'.png -draw "image over 950,3 0,0 nws_logo.gif" swan_swell_hr't2'.png'
   endif
 endif
 'c'
 t1=t1+1
endwhile

'quit' 



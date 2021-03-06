'reinit'
t1=1
'open swan.ctl'
'q file'
rec=sublin(result,5)
tt=subwrd(rec,12)

while(t1<=tt)
 'set vpage 0.25 3.75 4.5 7.5'
 'set grads off'
 'set mpdset hires'
 'set t 't1
 'q dims'
 line=sublin(result,5)
 time=subwrd(line,6)
 <!-- SET TIMESTEP HERE -->
 'set gxout shaded'
 'color 0 ##MAX_HTSGW_FT## ##HTSGW_INCR## -kind darkblue->cyan->lime->yellow->orange->red->darkred->maroon'
 'd const(htsgw*3.2808399,0,-u)'
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
 'draw title NWPS Significant Wave Height (ft) and Peak Wave Direction\Hour 't2' ('time')'
 
 'set vpage 0.25 3.75 1.25 4.25'
 'set grads off'
 'set gxout shaded'
 'set mpdset hires'
 'color 0 ##MAX_WNDSPD_KTS## ##WNDSPD_INCR## -kind darkblue->cyan->lime->yellow->orange->red->darkred->maroon'
 'define wndspd = wndspdms*1.94384449'
 'd const(wndspd,0,-u)'
 'run cbarn.gs'
 'set gxout barb'
 'set arrlab off'
 'set arrscl 0.2'
 'define rad = 4*atan2(1.0,1.0)/180'
 'define uwnd = -wndspd*sin(rad*wnddir)'
 'define vwnd = -wndspd*cos(rad*wnddir)'
 'set ccolor 1'
 'd skip(uwnd,10,10);skip(vwnd,10,10)'
 'set line 1 1 1'
 'draw shp marine_zones'
 'draw shp river_basins'
 'draw shp lakes'
 'set shpopts 15'
 'draw shp rivers'
 'draw shp zones'
 'draw title NWPS Wind (kts)\Hour 't2' ('time')'

 'set vpage 3.75 7.25 4.5 7.5'
 'set grads off'
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

 'set vpage 3.75 7.25 1.25 4.25'
 'set grads off'
 'set gxout shaded'
 'color 0 ##MAX_SWELL_FT## ##SWELL_INCR## -kind darkblue->cyan->lime->yellow->orange->red->darkred->maroon'
 'd const(swell*3.2808399,0,-u)'
 'run cbarn.gs'
 'set gxout vector'
 'set arrlab off'
 'set arrscl 0.2'
 'run choosecolorbar.gs'
 'set line 1 1 1'
 'draw shp marine_zones'
 'draw shp river_basins'
 'draw shp lakes'
 'set shpopts 15'
 'draw shp rivers'
 'draw shp zones'
 'draw title NWPS Significant Swell Height (ft)\Hour 't2' ('time')'

 'set vpage 7.25 10.75 4.5 7.5'
 'set grads off'
 'define rad = 4*atan2(1.0,1.0)/180'
 'define curspd = curspdms*1.94384449'
 'define u = -curspd*sin(rad*curdir)'
 'define v = -curspd*cos(rad*curdir)'
 'color 0 ##MAX_CUR_KTS## .25 -kind darkblue->cyan->lime->yellow->orange->red->darkred->maroon'
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
 'draw title NWPS Horizontal Current (kts)\Hour 't2' ('time')'

 'set vpage 7.25 10.75 1.25 4.25'
 'set grads off'
 'set gxout shaded'
 'set mpdset hires'
 'color -3 ##MAX_WLEV_FT## .5 -kind darkblue->cyan->lime->yellow->orange->red->darkred->maroon'
 'd wlevel*3.28083989501'
 'run cbarn.gs'
 'set arrlab off'
 'set arrscl 0.2'
 'set line 1 1 1'
 'draw shp marine_zones'
 'draw shp river_basins'
 'draw shp lakes'
 'set shpopts 15'
 'draw shp rivers'
 'draw shp zones'
 'draw title NWPS Sea Surface Height relative to MSL (ft)\Hour 't2' ('time')'

 'set vpage off'
 'draw string 5.5 7.8 **EXPERIMENTAL**'

 if (t2 < 10)
  'printim swan_6panel_hr00't2'.png x1792 y1344 white'
  '!/usr/bin/convert swan_6panel_hr00't2'.png -draw "image over 35,75 0,0 noaa_logo.gif" swan_6panel_hr00't2'.png'
  '!/usr/bin/convert swan_6panel_hr00't2'.png -draw "image over 1675,75 0,0 nws_logo.gif" swan_6panel_hr00't2'.png'
 else
   if (t2 < 100)
    'printim swan_6panel_hr0't2'.png x1792 y1344 white'
    '!/usr/bin/convert swan_6panel_hr0't2'.png -draw "image over 35,75 0,0 noaa_logo.gif" swan_6panel_hr0't2'.png'
    '!/usr/bin/convert swan_6panel_hr0't2'.png -draw "image over 1675,75 0,0 nws_logo.gif" swan_6panel_hr0't2'.png'
   else
    'printim swan_6panel_hr't2'.png x1792 y1344 white'
    '!/usr/bin/convert swan_6panel_hr't2'.png -draw "image over 35,75 0,0 noaa_logo.gif" swan_6panel_hr't2'.png'
    '!/usr/bin/convert swan_6panel_hr't2'.png -draw "image over 1675,75 0,0 nws_logo.gif" swan_6panel_hr't2'.png'
   endif
 endif
 'c'
 t1=t1+1
endwhile

'quit' 

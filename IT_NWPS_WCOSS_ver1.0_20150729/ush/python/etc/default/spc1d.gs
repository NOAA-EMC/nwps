'reinit'
t1=1
'open swanspc1d.ctl'
'q file'

rec=sublin(result,5)
tt=subwrd(rec,12)

while(t1<=tt)

 'set t 't1
 'q dims'
 line=sublin(result,5)
 time=subwrd(line,6)
 <!-- SET TIMESTEP HERE -->
 <!-- SET TIMESTEP HERE -->
 <!-- SET LOCATION NAME HERE -->
 <!-- SET LOCATION LON HERE -->
 <!-- SET LOCATION LAT HERE -->
#set printarea (parea)
#Page Size = 11 by 8.5
#X Limits = 0.5 to 10.5
#Y Limits = 0.75 to 7.75
'set grads off'
'set parea 1.2 8.8 1 7.25'
 'set xaxis 0.0 .5'
 'set gxout line'
 'set cmark 0'
 'set ccolor 2'
 'd location'
# 'draw xlab Frequency [Hz]'
 'set string 1 bc 6 0'
 'set strsiz 0.16 0.16'
 'draw string 4.9 .35 Frequency [Hz]'
 'draw ylab Energy [m`a2`n/Hz]'
 'set string 1 bc 6 0'
 'set strsiz 0.16 0.16'
  ytext=7.3
 'draw string 4.9 7.55 Period [s]'
 'set string 1 bl 4 0'
 'set strsiz 0.10 0.10'
 'draw string 1.85 'ytext' 20'
 'draw string 2.25 'ytext' 13'
 'draw string 2.65 'ytext' 10'
 'draw string 3.25 'ytext' 7'
 'draw string 4.2 'ytext' 5'
 'draw string 4.95 'ytext' 4'
 'draw string 6.5 'ytext's 3'
 'draw string 8.75 'ytext' 2'
'set string 1 bl 6 0'
'set strsiz 0.16 0.16'
LOCLON=360-LOCLON
'draw string 2 8.1 NWPS Spectral Density at Hr 't2' from 'time''

'set string 1 bc 6 0'
'set strsiz 0.15 0.15'
'draw string 9.85 7.1  'NWPSystem' '
'set string 1 bc 5 0'
'set strsiz 0.14 0.14'
'draw string 9.85 6.8 Loc: 'LOCNAME' '

'set string 1 bc 5 0'
'set strsiz 0.14 0.14'
'draw string 9.85 6.5 (-'LOCLON'`ao`n,'LOCLAT'`ao`n)'
'draw string 9.8 .2 **EXPERIMENTAL**'

 if (t2 < 10)
 'printim swan_'LOCNAME'_hr00't2'.png x1024 y768 white'
 '!/usr/bin/convert swan_'LOCNAME'_hr00't2'.png -draw "image over 2,2 0,0 noaa_logo.gif" swan_'LOCNAME'_hr00't2'.png'
 '!/usr/bin/convert swan_'LOCNAME'_hr00't2'.png -draw "image over 950,3 0,0 nws_logo.gif" swan_'LOCNAME'_hr00't2'.png'
 else
   if (t2 < 100)
    'printim swan_'LOCNAME'_hr0't2'.png x1024 y768 white'
    '!/usr/bin/convert swan_'LOCNAME'_hr0't2'.png -draw "image over 2,2 0,0 noaa_logo.gif" swan_'LOCNAME'_hr0't2'.png'
    '!/usr/bin/convert swan_'LOCNAME'_hr0't2'.png -draw "image over 950,3 0,0 nws_logo.gif" swan_'LOCNAME'_hr0't2'.png'
   else
    'printim swan_'LOCNAME'_hr't2'.png x1024 y768 white'
    '!/usr/bin/convert swan_'LOCNAME'_hr't2'.png -draw "image over 2,2 0,0 noaa_logo.gif" swan_'LOCNAME'_hr't2'.png'
    '!/usr/bin/convert swan_'LOCNAME'_hr't2'.png -draw "image over 950,3 0,0 nws_logo.gif" swan_'LOCNAME'_hr't2'.png'
   endif
 endif

 'c'
 t1=t1+1
endwhile
'quit'

latarray="26.96 26.47 26.31 25.81 25.88"

lonarray="-80.04 -80.04 -80.06 -80.09 -82.90"

locarray="~2NM_E_Jupiter ~1NM_E_Delray_Beach ~1NM_E_Deerfield_Beach ~1NM_E_Miami_Beach ~63NM_W_Marco_Island"  

points=1
while(points<=5)
 'reinit'
 'open swan.ctl'
 'set grads off'

 latit=subwrd(latarray,points)
 lonit=subwrd(lonarray,points)
 locit=subwrd(locarray,points)
 
 'q file'
 rec=sublin(result,5)
 tt=subwrd(rec,12)
 
 'set lat 'latit
 'set lon 'lonit
 'set t 5 'tt
 
 'd max(htsgw*3.2808399,t=5,t='tt')'
 rr=sublin(result,2)
 maxwh=subwrd(rr,4)
 'd max(waveper,t=5,t='tt')'
 rr=sublin(result,2)
 maxwp=subwrd(rr,4)
 if(maxwh>maxwp)
  'set vrange 0 'maxwh+1
 else
  'set vrange 0 'maxwp+1
 endif

 'set ccolor 2'
 'd htsgw*3.2808399'

 'set ccolor 3'
 'd waveper'

 'set ccolor 5'
 'd swell*3.2808399'

 'draw string 2.3 7.5 Hs (Feet-Red)'
 'draw string 2.3 7.2 Swell (Feet-Light Blue)'
 'draw string 2.3 6.9 Dominant Wave Period (Seconds-Green)'

 'draw ylab Hs--Swell--Period'
 'draw title (NWPS) Simulating WAves Nearshore Model\Location: 'latit'N 'lonit'W ('locit')' 
 'printim swan_graph_'locit'.png png x1024 y768'

 points=points+1
endwhile 

'quit'


'reinit'
'open swanpartition.ctl'
'q file'
'q dims'
 line=sublin(result,5)
 time=subwrd(line,6)
 line=sublin(result,2)
 Lonmax=subwrd(line,8)
 line=sublin(result,2)
 Xmax=subwrd(line,13)
 'set mproj off'
 'set gxout vector'
# Give the panel position 
position(top)
<!-- SET OUTTIMESTEP -->
<!-- SET INIT HH -->
<!-- SET INIT DD -->
<!-- SET INIT MM -->
<!-- SET INIT YY -->
<!-- SET INIT CC -->
<!-- SET LOCATION NAME HERE -->
<!-- SET LOCATION LON HERE -->
<!-- SET LOCATION LAT HERE -->
#set printarea (parea)
#Page Size = 11 by 8.5
#X Limits = 0.5 to 10.5
#Y Limits = 0.75 to 7.75
#'set parea 1.0 9 1 7.75'
maxvec=0
if (MMINI > 2)
  MM = MMINI-3
  YY=YYINI
else
  MM = MMINI+9
  YY=YYINI-1
endif	 
ya = YY-100*CC
ji=math_int((146097*CC)/4+(1461*ya)/4+(153*MM+2)/5+DDINI+1721119)
#y = year (eg. 1999);  m = month;  d = day;  ji = Julian Day Number
#As ji is the number of days (not day+hours) the first day on the x-label must be
# the next day.
if (HHINI>0)
    ji=ji+1
endif

numofprt=10
in=1
while(in<=numofprt)
  label.in='in'
  in=in+1
endwhile

TOTALDAYS=Xmax/(24/OUTPUTDT)+1
ii=1
while (ii < TOTALDAYS)
   j = ji-1721119
   y = math_int((4*j-1)/146097)
   j = math_int(4*j-1-146097*y)
   d = math_int(j/4)
   j = math_int((4*d+3)/1461)
   d = math_int(4*d+3-1461*j)
   d = math_int((d+4)/4) 
   m = math_int((5*d-3)/153)
   d = math_int(5*d-3-153*m) 
   d = math_int((d+5)/5) 
   y = math_int(100*y+j) 
   if (m < 10)
      m = m+3
   else
      m = m-9
      y = y+1
   endif
   label.ii=''m'/'d''
   ii=ii+1
   ji=ji+1

endwhile
#Define xlabs before to display the data
xini=HHINI
xend=Lonmax+xini
if (Xmax>24) 
 deltatext=24
 'set xaxis 'xini' 'xend' 'deltatext''
 'set xlabs  'label.1'| 'label.2' | 'label.3' | 'label.4' | 'label.5' | 'label.6' | 'label.7' | 'label.8'| 'label.9' | 'label.10' |'
endif
fmt = '%4.1f'
in=1
numplots=0
while(in<=numofprt)
plotyn.in=0
    'res1=mag(u(z='in'),v(z='in'))'
     'res=max(max(res1,lon=1,lon='Lonmax'),lat=1,lat=25)'
     'd res' 
     line=sublin(result,1)
     resu01=subwrd(line,4)
     if (resu01>maxvec)
       maxvec=resu01
     endif
#finding which partitions are going to be plotted
#if not  very small wave energy then  plot
#if larger wave energy found then re-define vector scale 
#   if (maxu> 0.025 | maxv>0.025)
   if (resu01 > 0.025)
    plotyn.in=in
    numplots=1
   endif
   in=in+1
endwhile
if (maxvec <= 0)
  maxvec=1.0
endif
'set arrlab off'

'draw string 0.005 6.1 **EXPERIMENTAL**'

'set string 1 bc 6 0'
'set strsiz 0.16 0.16'
'draw string 10.2 6.55 NWPSystem'

xtext=10.4 
ytext=5.55
'set string 1 bc 6 0'
'set strsiz 0.16 0.16'
'draw string 'xtext-0.2' 'ytext+0.3' WAVE'

'set string 1 bc 6 0'
'set strsiz 0.16 0.16'
'draw string 'xtext-0.2' 'ytext' PARTITION'


#Someone ask to add the date of the bound cond..
#We decided to cancel this for the moment
#'set string 1 bc 4 0'
#'set strsiz 0.12 0.12'
#'draw string 10.25 1.5 WWIII BC'
#
#'set string 1 bc 4 0'
#'set strsiz 0.12 0.12'
#'draw string 10.25 1.32 *DATE*'



'set arrowhead -0.1'
#Vectors Color definition 
color.1=1
color.2=2
color.3=4
color.4=3
color.5=9
color.6=12
color.7=8
color.8=13
color.9=11
color.10=6

dtext=0.34
#Plot only the non zero wave fields
#and their associated text (Partition Number)
'set vrange 0 25'
xrit = 10.25
t1=1
while(t1<=numofprt)
  ytext=ytext-dtext

  'set ccolor 'color.t1' '

  if (plotyn.t1 !=0 )

#---Defining the scale vector
    len = 0.68
    scale =maxvec
    ybot = 0.7
#---draw the scale vector
    'set arrscl 'len' 'scale
    rc = arrow(xrit,ybot,len,scale)

#------------------------------------------
#-----Add labels to the scale vector-------
  'set string 1 bc 4'
  'set strsiz 0.1'
   rc1 = math_format(fmt,scale)
  'draw string 'xrit' 'ybot-0.17' 'rc1 '[m]'

#--=The scale in feet 
  'set string 1 bc 4'
  'set strsiz 0.1'
   fscale=scale*3.280839895 
   rc1 = math_format(fmt,fscale)
  'draw string 'xrit' 'ybot+0.10' 'rc1'[ft]'

#----For the Wave Height text
    'set string 1 bc 4'
    'set strsiz 0.11 0.11'
     xarrow=xrit
     yarrow=ybot+0.3
    'draw string 'xarrow' 'yarrow' Max.Wave Height'
#----------End scale vector----------------

#-------Ploting the vector field---------
    'd u(z='t1');v(z='t1')'

#---- Adding the Partition Number------
    'set string 'color.t1' br 16 0'
    'set strsiz 0.23 0.26'
    'draw string 'xtext' 'ytext' 't1'' 

  endif
  t1=t1+1
endwhile

#If simulation time is smaller than 24 hours,then xlabels 
#fails using month/day, then hours from starting date are used
if (Xmax>24) 
'draw xlab Z-Time[Month/Day]'
endif
if (Xmax<=24) 
'draw xlab Z-Time[hours from 'time']'
endif

'draw ylab Peak Period[s]'
#TODO
#Following line whould be changed once the setup domain is changed
#To acept negative longitudes
LOCLON=360-LOCLON
'draw title Gerling-Hanson Plot for 'LOCNAME' (-'LOCLON'`ao`n,'LOCLAT'`ao`n) \NWPS RUN: 'time''

if (numplots = 0)
  'set string 1 bl 3'
  'set strsiz 0.25 0.25'
  'draw string 1.5 2.5 VERY LOW WAVE HEIGHT (<0.25 m)'
endif
'close 1'

#############  THE WIND PLOT ###########################
'open windforhansonplots.ctl'
'q dims'
 line=sublin(result,5)
 time=subwrd(line,6)
 line=sublin(result,2)
 Lonmin=subwrd(line,6)
 Lonmax=subwrd(line,8)
 line=sublin(result,3)
 Latmin=subwrd(line,6)
 Latmax=subwrd(line,8)
# Give the panel position 
position(bottom)
 'set mproj off'
'set gxout vector'
#'set grid off'
'set arrlab off'

'resw=mag(wu(z=1),wv(z=1))'
'reswm=max(max(resw,lon='Lonmin',lon='Lonmax'),lat='Latmin',lat='Latmax')'
'd reswm'
line=sublin(result,1)
resmax=subwrd(line,4)
# Defining the scale vector
len = 0.68
scale =resmax
ybot = 0.6
#   draw the vector scale
'set arrscl 'len' 'scale
rc = arrow(xrit,ybot,len,scale)

'set string 1 bc 4'
'set strsiz 0.11 0.11'
yarrow=ybot+0.3
'draw string 'xarrow' 'yarrow' Max.Wind Speed'

kntscale=scale* 1.943844492 5 
rc1 = math_format(fmt,kntscale)

# wter level
wlmax=10
#wlmaxn=-10
#'set ylabs 'wlmaxn' | 0 | 'wlmax'
'set ylabs 'rc1' | 0 | 'rc1' '

'set string 1 bc 4 0'
'set strsiz 0.12 0.12'
'draw string 'xrit' 'ybot+0.85' WindSource'


'set string 1 bc 4 0'
'set strsiz 0.12 0.12'
'draw string 'xrit' 'ybot+0.65' <!-- SET WIND SOURCE HERE -->'



#The feet scale
'set string 1 bc 4'
'set strsiz 0.1'
'draw string 'xrit' 'ybot+0.10' 'rc1 '[Kn]'


'set string 1 bc 4'
'set strsiz 0.1'
rc2 = math_format(fmt,scale)
'draw string 'xrit' 'ybot-0.17' 'rc2 '[m/s]'

xini=HHINI
xend=Lonmax+xini
if (Xmax>24) 
 deltatext=24
 'set xaxis 'xini' 'xend' 'deltatext''
 'set xlabs  'label.1'| 'label.2' | 'label.3' | 'label.4' | 'label.5' | 'label.6' | 'label.7' | 'label.8'| 'label.9' | 'label.10' |'
endif


'set ccolor 1 '
'd wu;wv'


'set string 1 bl 1.5 90'
'set strsiz 0.10 0.10'
#---TODO'draw string 0.5 .35  Water Level [Feet]'
'draw string 0.48 .36  Wind Speed [Kn]'

'draw string 0.2 5.55 **EXPERIMENTAL**'

########################################################

'printim Hansonplot_'LOCNAME'.png x1536 y1152 white'
'!/usr/bin/convert Hansonplot_'LOCNAME'.png -draw "image over 27,2 0,0 noaa_logo.gif" Hansonplot_'LOCNAME'.png'
'!/usr/bin/convert Hansonplot_'LOCNAME'.png -draw "image over 100,2 0,0 nws_logo.gif" Hansonplot_'LOCNAME'.png'
'quit'

function arrow(x,y,len,scale)
  'set line 1 1 5'
  'draw line 'x-len/2.' 'y' 'x+len/2.' 'y
  'draw line 'x+len/2.-0.05' 'y+0.025' 'x+len/2.' 'y
  'draw line 'x+len/2.-0.05' 'y-0.025' 'x+len/2.' 'y

return


function position(arg)

# position = top bottom 
 
'set vpage off'
'query gxinfo'
rec2 = sublin(result,2)
xlo = 0
xhi = subwrd(rec2,4)
ylo = 0
yhi = subwrd(rec2,6)


if ( arg = 'top' )
#set parea left rigth bottom top
'set parea 1.0 9.5 0.7 6.'
xmid = 0.5 * (xlo + xhi)
ymid = 0.2 * (ylo + yhi)
  'set vpage ' xlo ' ' xhi ' ' ymid ' ' yhi
endif
if ( arg = 'bottom' )
#set parea left rigth bottom top
'set parea 1.0  9.5   0.4    1.75'
xmid = 0.5 * (xlo + xhi)
ymid = 0.5 * (ylo + yhi)
  'set vpage ' xlo ' ' xhi ' ' ylo ' ' ymid
endif

'set grads off'
return

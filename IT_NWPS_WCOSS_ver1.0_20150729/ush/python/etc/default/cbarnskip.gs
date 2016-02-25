*
*  Script to plot a colorbar
*
*  The script will assume a colorbar is wanted even if there is
*  not room -- it will plot on the side or the bottom if there is
*  room in either place, otherwise it will plot along the bottom and
*  overlay labels there if any.  This can be dealt with via
*  the 'set parea' command.  In version 2 the default parea will
*  be changed, but we want to guarantee upward compatibility in
*  sub-releases.
*
*       modifications by mike fiorino 940614
*       rvp added by diane stokes 20040729
*       cinc added by diane stokes 20050130
*
*       - the extreme colors are plotted as triangles
*       - the colors are boxed in white
*       - input arguments in during a run execution:
*
*       run cbarn cinc sf vert xmid ymid rvp
*
*       cinc - increment for labels
*       sf   - scale the whole bar 1.0 = original 0.5 half the size, etc.
*       vert - 0 FORCES a horizontal bar = 1 a vertical bar
*       xmid - the x position on the virtual page the center the bar
*       ymid - the x position on the virtual page the center the bar
*       rvp  - 1 resets virtual page (one colorbar for several plots)
*
*       if cinc is not specified, every color interval is labeled
*       if vert,xmid,ymid are not specified, they are selected
*       as in the original algorithm
*
*       if rvp is not specified, it is 0 (do not reset virtual page)
 
function colorbar (args)
 
*  Parse command line arguments
*  ----------------------------
   cinc=subwrd(args,1)
   sf=subwrd(args,2)
   vert=subwrd(args,3)
   xmid=subwrd(args,4)
   ymid=subwrd(args,5)
   rvp=subwrd(args,6)
   if(cinc=''|cinc=0);cinc=1;endif
   if(sf='');sf=1.0;endif
 
*  Check shading information
*  -------------------------
   'query shades'
   shdinfo = result
   if (subwrd(shdinfo,1)='None')
      say 'Cannot plot color bar: No shading information'
      return
   endif
 
* Check if reset of virtual page is desired
* -----------------------------------------
  if(rvp = 1)
     say 'Colorbar based on colors from last plot drawn'
     'set vpage off'
  endif
 
* Get plot size info
* ------------------
  'query gxinfo'
  rec2 = sublin(result,2)
  rec3 = sublin(result,3)
  rec4 = sublin(result,4)
  xsiz = subwrd(rec2,4)
  ysiz = subwrd(rec2,6)
  ylo = subwrd(rec4,4)
  xhi = subwrd(rec3,6)
  xd = xsiz - xhi
 
  ylolim=0.6*sf
  xdlim1=1.0*sf
  xdlim2=1.5*sf
  barsf=0.8*sf
  yoffset=0.2*sf
  stroff=0.05*sf
  strxsiz=0.12*sf
  strysiz=0.13*sf
 
*  Decide if horizontal or vertical color bar
*  and set up constants.
*  ------------------------------------------
   if (ylo<ylolim & xd<xdlim1)
      say "Not enough room in plot for a colorbar"
      return
   endif
   cnum = subwrd(shdinfo,5)
 
*  Logic for setting the bar orientation with user overides
*  --------------------------------------------------------
   if (ylo<ylolim | xd>xdlim1)
       vchk = 1
       if(vert = 0) ; vchk = 0 ; endif
   else
       vchk = 0
       if(vert = 1) ; vchk = 1 ; endif
   endif
 
*  Vertical bar
*  ------------
   if (vchk = 1 )
     if(xmid = '') ; xmid = xhi+xd/2 ; endif
     xwid = 0.2*sf
     ywid = 0.5*sf
     xl = xmid-xwid/2
     xr = xl + xwid
     if (ywid*cnum > ysiz*barsf)
        ywid = ysiz*barsf/cnum
     endif
     if(ymid = '') ; ymid = ysiz/2 ; endif
     yb = ymid - ywid*cnum/2
     'set string 1 l 5'
     vert = 1
 
*  Horizontal bar
*  --------------
   else
 
     ywid = 0.4
     xwid = 0.8
     if(ymid = '') ; ymid = ylo/2-ywid/2 ; endif
     yt = ymid + yoffset
     yb = ymid
     if(xmid = '') ; xmid = xsiz/2 ; endif
     if (xwid*cnum > xsiz*barsf)
         xwid = xsiz*barsf/cnum
     endif
     xl = xmid - xwid*cnum/2
     'set string 1 tc 5'
     vert = 0
   endif
 
*  Plot colorbar
*  -------------
   'set strsiz 'strxsiz' 'strysiz
   num = 0
   while (num<cnum)
     rec = sublin(shdinfo,num+2)
     col = subwrd(rec,1)
     hi = subwrd(rec,3)
     if (vert)
        yt = yb + ywid
     else
        xr = xl + xwid
     endif
 
*   Draw the left/bottom triangle
*   -----------------------------
    if (num = 0)
       if(vert = 1)
          xm = (xl+xr)*0.5
          'set line 'col
          'draw polyf 'xl' 'yt' 'xm' 'yb' 'xr' 'yt' 'xl' 'yt
          'set line 1 1 5'
          'draw line 'xl' 'yt' 'xm' 'yb
          'draw line 'xm' 'yb' 'xr' 'yt
          'draw line 'xr' 'yt' 'xl' 'yt
       else
          ym = (yb+yt)*0.5
          'set line 'col
          'draw polyf 'xl' 'ym' 'xr' 'yb' 'xr' 'yt' 'xl' 'ym
          'set line 1 1 5'
          'draw line 'xl' 'ym' 'xr' 'yb
          'draw line 'xr' 'yb' 'xr' 'yt
          'draw line 'xr' 'yt' 'xl' 'ym
       endif
   endif
 
*  Draw the middle boxes
*  ---------------------
   if (num!=0 & num!= cnum-1)
      'set line 'col
      'draw recf 'xl' 'yb' 'xr' 'yt
      'set line 1 1 5'
      'draw rec  'xl' 'yb' 'xr' 'yt
   endif
 
*  Draw the right/top triangle
*  --------------------------- 
   if (num = cnum-1)
      if (vert = 1)
         'set line 'col
         'draw polyf 'xl' 'yb' 'xm' 'yt' 'xr' 'yb' 'xl' 'yb
         'set line 1 1 5'
         'draw line 'xl' 'yb' 'xm' 'yt
         'draw line 'xm' 'yt' 'xr' 'yb
         'draw line 'xr' 'yb' 'xl' 'yb
      else
         'set line 'col
         'draw polyf 'xr' 'ym' 'xl' 'yb' 'xl' 'yt' 'xr' 'ym
         'set line 1 1 5'
         'draw line 'xr' 'ym' 'xl' 'yb
         'draw line 'xl' 'yb' 'xl' 'yt
         'draw line 'xl' 'yt' 'xr' 'ym
      endif
   endif
 
*  Put numbers under each segment of the color key
*  but only if this level is to be printed (based on cinc)
*  -------------------------------------------------------
   if(num < cnum-1)
*     base prt on hi if increment is based on data value (less reliable)
*     prt = math_fmod(hi,cinc);
*     ------------------------------------------------------------------
      prt = math_fmod(num,cinc);
      if(prt = 0)
         if (vert)
            xp=xr+stroff
            'draw string 'xp' 'yt' 'hi
         else
            yp=yb-stroff
            'draw string 'xr' 'yp' 'hi
         endif
      endif
    endif
 
*   Reset variables for next loop execution
*   ---------------------------------------
    if (vert)
      yb = yt
    else
      xl = xr
    endif
    num = num + 1
 
  endwhile
  return


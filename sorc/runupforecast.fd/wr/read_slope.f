      subroutine read_slope(funin,ninput,istart,xpos,ypos,sxpos,sypos,
     1                      rf2use2,slope,slope95,slope05,dhigh,dlow,
     2                      nobs,ier,esi)
!
!	This subroutine reads the beach slope file rovided by the USGS 
!      which contains the following for each desired output location:
!                     - 20 meter isobath latitude in decimal degrees
!                     - 20 meter isobath longitude in decimal degrees
!                     - corresponding shoreline latitude in decimal degrees
!                     - corresponding shoreline longitude in decimal degrees
!                     - average (temporal and spatial) beach slope at shoreline location
!                     - upper 95% percentile beach slope (from variance of spatial and temporal slope distribution) at shoreline location
!                     - upper 95% percentile beach slope (from variance of spatial and temporal slope distribution) at shoreline location
!                     - elevation (LMSL) of dune or structure toe
!                     - elevation (LMSL) of dune or structure crest 
!                     - backshore type: NOAA environmental sensitivity index (ESI)
!                     - runup formula to use: 0=Stockdon. 1 = TAW. 2 = SPM
!
      implicit none
!        Input/Output Variables
      integer, intent(in) :: funin,ninput,istart
      character(len=255) :: FORT21
      character(len=2),dimension(ninput) :: esi
      integer, intent(out) :: ier,nobs
      integer, intent(inout),dimension(ninput) :: rf2use2
      real, intent(inout), dimension(ninput) :: xpos,ypos,sxpos,sypos
      real, intent(inout), dimension(ninput) :: slope,slope05,slope95
      real,  dimension(ninput) :: mnth,yr
      real, intent(inout), dimension(ninput) :: dhigh,dlow
!        Internal Variables
      integer :: i,j,tmp1,tmp2
      character(len=158) :: ctemp
!
!        Initalize arrays
!
      ier=0
!
!        Open Input File 
!
      call get_environment_variable("FORT21",FORT21)
      open(unit=funin,FILE=FORT21,form="formatted",status="old")
!      open(unit=funin,FILE='SoCal_SGX_slopes_500.txt',form="formatted")

!
!        Read the input points data file.
!
      nobs=0
      j=0
      do i=istart+1, ninput
         read(funin,100,end=150)ctemp
 100     format(A158)
         if(ctemp(1:1).EQ.'%')then
!              Line that begins with '%' is a comment line, skip.
            cycle
         else
            j=j+1
            
            read(ctemp,105)xpos(j),ypos(j),sxpos(j),sypos(j),rf2use2(j),
     1  slope(j),slope95(j),slope05(j),dhigh(j),dlow(j),esi(j),tmp1,
     2  tmp2
            mnth(j)= FLOAT(tmp1)
            yr(j)  = FLOAT(tmp2)

 105        format(F10.3,1X,F11.4,1X,F12.5,1X,F12.5,5X,I1,5X,F8.5,5X,
     1             F8.5,5X,F8.5,5X,F8.2,5X,F8.2,1X,A2,5X,I2,1X,I4)
            if(J.eq.1)then
            endif
         endif
      end do 
 150  close(funin)
      nobs=j
!
      return
      end subroutine read_slope



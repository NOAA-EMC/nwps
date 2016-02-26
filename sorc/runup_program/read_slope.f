      subroutine read_slope(funin,ninput,istart,xpos,ypos,sxpos,sypos,
     1                     slope,slope95,slope05,nobs,ier)
!
!	This subroutine reads the beach slope file rovided by the USGS St. Petersburg Coastal and Marine
!   Science Center) which contains the following for each desired output location:
!                     - 20 meter isobath latitude in decimal degrees
!                     - 20 meter isobath longitude in decimal degrees
!                     - corresponding shoreline latitude in decimal degrees
!                     - corresponding shoreline longitude in decimal degrees
!                     - average (temporal and spatial) beach slope at shoreline location
!                     - upper 95% percentile beach slope (from variance of spatial and temporal slope distribution) at shoreline location
!                     - upper 95% percentile beach slope (from variance of spatial and temporal slope distribution) at shoreline location
!
      implicit none
!        Input/Output Variables
      integer, intent(in) :: funin,ninput,istart
      character(len=255) :: FORT21
      integer, intent(inout) :: ier,nobs
      real, intent(inout), dimension(ninput) :: xpos,ypos,sxpos,sypos
      real, intent(inout), dimension(ninput) :: slope,slope05,slope95
!        Internal Variables
      integer :: i,j
      character(len=158) :: ctemp
!
!        Open Input File 
!
      call get_environment_variable("FORT21",FORT21)
      open(unit=funin,FILE=FORT21,form="formatted",status="old")
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
            read(ctemp,105)xpos(j),ypos(j),sxpos(j),sypos(j),
     1           slope(j),slope95(j),slope05(j)
 105        format(F7.3,1X,F7.4,1X,F7.3,1X,F7.4,1X,
     1             F6.4,1X,F6.4,1X,F6.4)
            if(J.eq.1)then
            endif
         endif
      end do 
 150  close(funin)
      nobs=j
!
      return
      end subroutine read_slope

      subroutine read_nwps(funin,ninput,istart,ftime,xpos,ypos,hsig,pwp,
     1                     mwd,xvel,yvel,watlev,uwind,vwind,nobs,ier)

!	This subroutine reads the output from the NWPS forecast which contains the following (in order of columns) for each desired output location:
!                     - time
!                     - 20 meter isobath longitude in decimal degrees
!                     - 20 meter isobath latitude in decimal degrees
!                     - significant wave height [m]
!                     - peak wave period [s]
!                     - mean wave direction [deg]
!                     - cross-shore velocity [m/s]
!                     - alongshore velocity [m/s]
!                     - water level (tides and surge) [m]
!                     - x-component of wind velocity [m/s]
!                     - y-component of wind velocity [m/s]
!
      implicit none
!       Input/Output Variables
      integer, intent(in) :: funin,ninput,istart
      character(len=255) :: FORT20
      integer, intent(inout) :: ier,nobs
      real*8, intent(inout), dimension(ninput) :: ftime
      real, intent(inout), dimension(ninput) :: xpos,ypos
      real, intent(inout), dimension(ninput) :: hsig,pwp,mwd
      real, intent(inout), dimension(ninput) :: xvel,yvel,watlev
      real, intent(inout), dimension(ninput) :: uwind,vwind
!      Internal Variables
      integer :: i,j
      character(len=158) :: ctemp
!
!        Open Input File 
!
      call get_environment_variable("FORT20",FORT20)
      open(unit=funin,FILE=FORT20,form="formatted",status="old")
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
            read(ctemp,*)ftime(j),xpos(j),ypos(j),hsig(j),pwp(j),
     1                     mwd(j),xvel(j),yvel(j),watlev(j),uwind(j),
     2                     vwind(j)
 105        format(F15.6,10X,F7.3,6X,F8.4,5X,F9.5,6X,F8.4,6X,F8.3,4X,
     1             F10.6,4X,F10.6,6X,F8.4,6X,F8.4,6X,F8.4)
            if(J.eq.1)then
            endif
         endif
      end do 
 150  close(funin)
      nobs=j
!
      return
      end subroutine read_nwps

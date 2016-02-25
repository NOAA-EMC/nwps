      subroutine read_nwps(funin,ninput,istart,ftime,xpos,ypos,hsig,pwp,
     1                     mwd,xvel,yvel,watlev,uwind,vwind,nobs,ier)
!
!        Purpose
!
      implicit none
!        Input/Output Variables
      integer, intent(in) :: funin,ninput,istart
      integer, intent(inout) :: ier,nobs
      real*8, intent(inout), dimension(ninput) :: ftime
      real, intent(inout), dimension(ninput) :: xpos,ypos
      real, intent(inout), dimension(ninput) :: hsig,pwp,mwd
      real, intent(inout), dimension(ninput) :: xvel,yvel,watlev
      real, intent(inout), dimension(ninput) :: uwind,vwind
      real, dimension(ninput) :: dspr
!        Internal Variables
      integer :: i,j
      character(len=158) :: ctemp
!        Exception values defined for SWAN output
      real, parameter :: hsigexcp = -9.
      real, parameter :: pwpexcp = -9.
      real, parameter :: mdwexcp = -999.
!
!        Open Input File 
!
      open(unit=funin,form="formatted",status="old")
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
            read(ctemp,105)ftime(j),xpos(j),ypos(j),hsig(j),pwp(j),
     1                     mwd(j),dspr(j),xvel(j),yvel(j),watlev(j),
     2                     uwind(j),vwind(j)
 105        format(F15.6,10X,F7.3,6X,F8.4,5X,F9.5,6X,F8.4,6X,F8.3,5X,
     1             F8.4,4X,F10.6,4X,F10.6,6X,F8.4,6X,F8.4,6X,F8.4)
            if(hsig(j).EQ.hsigexcp)then
               hsig(j)=0.
            endif
            if(pwp(j).EQ.pwpexcp)then
               pwp(j)=0.
            endif
            if(mwd(j).EQ.mdwexcp)then
               mwd(j)=0.
            endif
         endif
      end do 
 150  close(funin)
      nobs=j
!
      return
      end subroutine read_nwps

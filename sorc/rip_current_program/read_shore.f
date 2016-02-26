      subroutine read_shore(funin,ninput,istart,xpos,ypos,shore,
     1                     nobs,ier)
!
!        Purpose
!
      implicit none
!        Input/Output Variables
      integer, intent(in) :: funin,ninput,istart
      integer, intent(inout) :: ier,nobs
      real, intent(inout), dimension(ninput) :: xpos,ypos
      real, intent(inout), dimension(ninput) :: shore
!        Internal Variables
      integer :: i,j
      character(len=158) :: ctemp
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
            read(ctemp,105)xpos(j),ypos(j),shore(j)
 105        format(F7.3,1X,F7.4,1X,F4.0)
            if(J.eq.1)then
            endif
         endif
      end do 
 150  close(funin)
      nobs=j
!
      return
      end subroutine read_shore

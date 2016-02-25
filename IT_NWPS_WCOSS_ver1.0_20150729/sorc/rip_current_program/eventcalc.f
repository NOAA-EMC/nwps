      subroutine eventcalc(nhs,npast72,hspast72,hs,timestep,eventout)
!
      implicit none
      integer, intent(in) :: nhs,npast72,timestep
      real, intent(in), dimension(nhs) :: hs
      real, intent(in), dimension(npast72) :: hspast72
      integer, intent(inout), dimension(nhs+npast72) :: eventout
      integer, dimension(nhs+npast72) :: eventout1
!        internal variables
      integer :: i,ii,j,jj
      integer :: nall,hourcount,peakind,peakind1
      integer :: below1,endevent,firstunder1,firstover1
      real :: c,c1
      real, allocatable, dimension(:) :: hsall
!        initialize arrays
      eventout1=0
      hourcount=72/timestep
!
!        get the size of hs and hspast72. That is the total
!        number of real values (i.e. not missing -9999.)
!
!      nhs=(minloc(hs,dim=1))-1
!      npast72=(minloc(hspast72,dim=1))-1
!
!        now we know the number of real values in hs and hspast72,
!        allocate hsall and fill with values.
!
      nall=nhs+npast72
      allocate(hsall(nall))
      hsall(1:npast72)=hspast72(1:npast72)
      hsall(npast72+1:npast72+nhs)=hs(1:nhs)
!
!        get the max value and location in hsall
!
      c=maxval(hsall) 
      peakind=maxloc(hsall,dim=1)
!
!        if the max? > 1 and occurs int he predicted data,
!        we need to make sure there wasn't another event
!        occurring in the past 72-hours that should also be
!        accounted for.
!
      if(c.gt.1.0.and.peakind.gt.npast72)then
         c1=maxval(hspast72)
         peakind1=maxloc(hspast72,dim=1)
!           only consider this and indepencent even if hs
!           drops below 1 again before the predicted hs 
         below1=0
         do i=peakind1,npast72
            if(hspast72(i).lt.1.0) below1=below1+1
         end do
         if(c1.gt.1.0.and.below1.gt.0)then
            c=c1
            peakind=peakind1
         endif
      endif
!
!        if the hs never > 1 there is no event (or if the peak occurs
!        on the last step) otherwise we need to see when the max is
!       
      if(c.lt.1.0.or.peakind.eq.nall)then
         eventout(:)=0
         eventout1(:)=0
      else
         endevent=peakind+hourcount
!           see where the event peak + 72 hour window brings us to
         if(endevent.gt.nall)then
!              if this brings us past the end of the forecast window
!              we can stop
            eventout1(1:peakind)=0
            eventout1(peakind+1:nall)=1
         endif
!
         eventout1(1:peakind)=0
         do while (endevent.lt.nall)
!              otherwise we need to make sure there isn't multiple
!              events occurring
            eventout1(peakind+1:endevent)=1
            eventout1(endevent+1:nall)=0
!              see if another event occurs (i.e. see if the hs < 1 and
!              then exceeds 1 again            
            firstunder1=0
            do i=peakind,nall
               if(hsall(i).lt.1.0)then
                  firstunder1=i+(peakind-1)
!                    adding peakind-1 to give us the absolute
!                    index from hsall
                  exit
               endif
            end do
!
            if(firstunder1.eq.0)then
               exit
            else
               firstover1=0
               do i=firstunder1,nall
                  if(hsall(i).gt.1.0)then
                     firstover1=i+(firstunder1-1)
                     exit
                  endif
               end do                
               if(firstover1.eq.0) exit
!                 find the next peak
               c=maxval(hsall(firstover1:nall))
               peakind=maxloc(hsall(firstover1:nall),dim=1)
               peakind=peakind+(firstover1-1)
               endevent=peakind+hourcount
               if(endevent.gt.nall) eventout1(peakind+1:nall)=1
!
            endif
!
         end do
!
      endif         
!            
      eventout=eventout1(nall-nhs+1:nall)
      deallocate(hsall)
!
      return
      end subroutine eventcalc

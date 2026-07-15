      subroutine bulkmodel(nhs,hs,mwdsn,event,tide,prob)
      implicit none
!
      integer, intent(in) :: nhs
      real, intent(in), dimension(nhs) :: hs,mwdsn,tide
      real, intent(inout), dimension(nhs) :: prob
      integer, intent(in), dimension(nhs) :: event
!
      integer, dimension(nhs) :: ievent
      integer i
      real :: b0,bhs,bmwd,bevent,btide
      real, dimension(nhs) :: loghs,absmwdsn,bulkout
!
      ievent=0
      b0=1.046
      bhs=3.5108
      bmwd=-0.0272
      bevent=0.4164
      btide=-1.70
      absmwdsn=abs(mwdsn)
      ievent=1*event
!
      do i=1,nhs
         if (hs(i) .gt. 0.0) then
            loghs(i)=log(hs(i))
            bulkout(i)=b0+bhs*loghs(i)+bmwd*absmwdsn(i)
     1                 +bevent*real(ievent(i))+btide*tide(i)
            prob(i)=100.*exp(bulkout(i))/(1.+exp(bulkout(i)))
         else
            prob(i) = 0.0
         endif
      enddo
!
      return
      end subroutine bulkmodel

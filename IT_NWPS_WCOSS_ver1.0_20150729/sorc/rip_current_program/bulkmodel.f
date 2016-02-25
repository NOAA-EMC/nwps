      subroutine bulkmodel(nhs,hs,mwdsn,event,tide,prob)
      implicit none
!
      integer, intent(in) :: nhs
      real, intent(in), dimension(nhs) :: hs,mwdsn,tide
      real, intent(inout), dimension(nhs) :: prob
      integer, intent(in), dimension(nhs) :: event
!
      integer, dimension(nhs) :: ievent
      integer j
      real :: b0,bhs,bmwd,bevent,btide
      real, dimension(nhs) :: loghs,absmwdsn,bulkout
!
      ievent=0
      b0=1.046
      bhs=3.5108
      bmwd=-0.0272
      bevent=0.4164
      btide=-1.70
      loghs=log(hs)
      absmwdsn=abs(mwdsn)
      ievent=1*event
!
      bulkout=b0+(bhs*loghs)+(bmwd*absmwdsn)+(bevent*real(ievent))+
     1        (btide*tide)
!
      prob=exp(bulkout)/(1.+exp(bulkout))
!
      return
      end subroutine bulkmodel

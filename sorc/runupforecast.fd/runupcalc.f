      subroutine runupcalc(nhs,hs,pwp,slope,slope95,slope05,watlev,
     1                     setup,sinc,sig,s,runup,runup95,runup05)
      implicit none
!
      integer, intent(in) :: nhs
      real, intent(in) :: slope,slope95,slope05
      real, intent(in), dimension(nhs) :: hs,pwp,watlev
      real, dimension(nhs), intent(inout) :: setup,sinc,sig,s
      real, dimension(nhs), intent(inout) :: runup,runup95,runup05
      real, dimension(nhs) :: wavel,ir
      real :: g,pi,br,br2,bsetup1,bsetup2,bsinc,bsig,bs,absslope

      real, dimension(nhs) :: wave_sqrt

      g=9.81
	  pi=3.1415927
      br=1.1
	  br2=0.039
	  bsetup1=0.016
	  bsetup2=0.35
	  bsinc=0.75
	  bsig=0.06
	  bs=0.046
	  
	  wavel=(g*pwp**2)/(2*pi)

      wave_sqrt = wavel*hs
      where (wave_sqrt .lt. 0.0 .or. wave_sqrt .ne. wave_sqrt)
          wave_sqrt = 0.0
      elsewhere
          wave_sqrt = sqrt(wave_sqrt)
      end where

	  absslope=abs(slope95)
      setup=bsetup2*absslope*wave_sqrt
	  sinc=bsinc*slope95*wave_sqrt
	  sig=bsig*wave_sqrt
	  s=sqrt(sinc**2+sig**2)
	  runup95=br*(setup+s/2)
        
      absslope=abs(slope05)
	  setup=bsetup2*absslope*wave_sqrt
	  sinc=bsinc*slope05*wave_sqrt
	  s=sqrt(sinc**2+sig**2)
	  runup05=br*(setup+s/2)
        
      absslope=abs(slope)
	  setup=bsetup2*absslope*wave_sqrt
	  sinc=bsinc*slope*wave_sqrt
	  s=sqrt(sinc**2+sig**2)
	  runup=br*(setup+s/2)

	  return
	  end subroutine runupcalc

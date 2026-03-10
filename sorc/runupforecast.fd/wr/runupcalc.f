      subroutine runupcalc(nhs,hs,pwp,slope,slope95,slope05,rf2use,
     1                     watlev,dlow,esi,setup,sinc,sig,s,runup,
     2                     runup95,runup05)
      implicit none
!   Original code written for Stockdon formulation. This is the same code amended to allow for 2 additional formulae for US west coast implementation: Stockdon 2006; TAW (van der Meer, 2002);  Shore protection manual (1984). 
!     Original code scripted for Stockdon 2006 remains unchanged. Updates are for the two additional runup formulae only. (Dec 2020)
!     For details on data sources and methods, please see: Shope,J., Erikson, L.H., Barnard, P. L., Storlazzi, C.D., Serafin, K.A., Doran, K.J.,Stockdon, H.F., Reguero, B.G., Mendez, F.J., Castanedo, S, Cid, Alba, and Cagigal, L. , 2020, Characterizing Storm-Induced Coastal Change Hazards Along the U.S. West Coast. In review. doi.xxxxx
!           
!      
      integer :: i
      character(len=2), intent(in) :: esi
      integer, intent(in) :: nhs,rf2use
      real*4 :: slope,slope95,slope05,dlow
      real*4, dimension(nhs), intent(in) :: hs,pwp,watlev
      real*4, dimension(nhs), intent(inout) :: setup,sinc,sig,s
      real*4, dimension(nhs), intent(inout) :: runup,runup95,runup05
      real*4, dimension(nhs) :: wavel,ir,mwp,wavelm, Hm0, DWL
      real*4 :: g,pi,br,br2
      real*4 :: bsetup1,bsetup2,bsinc,bsig,bs,absslope
      real*4 :: gammab, gammaf, irgammab

      g=9.8026  !gravitational acceleration at N41deg (~midway west coast study area)
      pi=3.1415927
      br=1.1
      br2=0.039
      bsetup1=0.016
      bsetup2=0.35
      bsinc=0.75
      bsig=0.06
      bs=0.046

	  
	  wavel=(g*pwp**2)/(2*pi)
	  mwp=pwp/1.1
	  wavelm=(g*mwp**2)/(2*pi)	  

! using Stockdon formulation (default)
      if (rf2use.eq.0) then

          absslope=abs(slope95)
          setup=bsetup2*absslope*sqrt(hs*wavel)
	  sinc=bsinc*slope95*sqrt(hs*wavel)
	  sig=bsig*sqrt(hs*wavel)
	  s=sqrt(sinc**2+sig**2)
	  runup95=br*(setup+s/2)
        
          absslope=abs(slope05)
	  setup=bsetup2*absslope*sqrt(hs*wavel)
	  sinc=bsinc*slope05*sqrt(hs*wavel)
	  s=sqrt(sinc**2+sig**2)
	  runup05=br*(setup+s/2)
        
          absslope=abs(slope)
	  setup=bsetup2*absslope*sqrt(hs*wavel)
	  sinc=bsinc*slope*sqrt(hs*wavel)
	  s=sqrt(sinc**2+sig**2)
	  runup=br*(setup+s/2)
	  
      end if

! using TAW method
      if (rf2use.eq.1) then
      
!       first set reduction factors
        gammab=1
        gammaf=1
      
        if (esi.eq."6D") then
           gammaf=0.65 
        else if (esi.eq."6B") then
           gammaf=0.55 
        else if (esi.eq."8C") then
           gammaf=0.5
        else if (esi.eq."6A") then
           gammaf=0.7
        else
           gammaf=1
        end if
          
        
        if (esi.eq."2A") then
           gammab=0.6
        else
           gammab=1
        end if
           
!       calculate TAW runup
        
        absslope=abs(slope95)
          setup=bsetup2*absslope*sqrt(hs*wavel)
          sinc=bsig*sqrt(hs*wavel)
          DWL=watlev+1.1*(setup+sinc/2)
          Hm0=(DWL-dlow)*0.78
!          ir=absslope/sqrt(Hm0/wavelm)
        do i=1, nhs
          if (Hm0(i).gt.0.) then
             ir(i)=absslope/sqrt(Hm0(i)/wavelm(i))
             irgammab=ir(i)*gammab
             if (irgammab.lt.1.8) then
                runup95(i)=Hm0(i)*(1.75*gammaf*irgammab)
             else
                runup95(i)=Hm0(i)*gammaf*(4.3-(1.6/sqrt(ir(i))))
             end if
          else
             runup95(i)=0.
          end if
        end do
          
        absslope=abs(slope05)
          setup=bsetup2*absslope*sqrt(hs*wavel)
          sinc=bsig*sqrt(hs*wavel)
          DWL=watlev+1.1*(setup+sinc/2)
          Hm0=(DWL-dlow)*0.78
!          ir=absslope/sqrt(Hm0/wavelm)
        do i=1, nhs
           if (Hm0(i).gt.0.) then
              ir(i)=absslope/sqrt(Hm0(i)/wavelm(i))
              irgammab=ir(i)*gammab
              if (irgammab.lt.1.8) then
                 runup05(i)=Hm0(i)*(1.75*gammaf*irgammab)
              else
                 runup05(i)=Hm0(i)*gammaf*(4.3-(1.6/sqrt(ir(i))))
              end if
           else
              runup05(i)=0.
           end if
        end do
        

        absslope=abs(slope)
          setup=bsetup2*absslope*sqrt(hs*wavel)
          sinc=bsig*sqrt(hs*wavel)
          DWL=watlev+1.1*(setup+sinc/2)
          Hm0=(DWL-dlow)*0.78
!          ir=absslope/sqrt(Hm0/wavelm)
        do i=1, nhs
           if (Hm0(i).gt.0.) then
              ir(i)=absslope/sqrt(Hm0(i)/wavelm(i))
              irgammab=ir(i)*gammab
              if (irgammab.lt.1.8) then
                runup(i)=Hm0(i)*(1.75*gammaf*irgammab)
              else
                runup(i)=Hm0(i)*gammaf*(4.3-(1.6/sqrt(ir(i))))
              end if
           else
              runup(i)=0.
           end if
        end do
          
      end if
      
! using SPM method for near-vertical cliffs & bluffs       
      if (rf2use.eq.2) then

        absslope=abs(slope)
          setup=bsetup2*absslope*sqrt(hs*wavel)
          sinc=bsig*sqrt(hs*wavel)
          DWL=watlev+1.1*(setup+sinc/2)
          Hm0=(DWL-dlow)*0.78
          runup=1.5*Hm0
          
!       becuase this is a vertical wall, there are no 95th and 5th percentile slopes
          runup05=runup
          runup95=runup

      end if
      
!       cap if too large; set to flag value 999          
        do i=1, nhs
           if (runup95(i)>20) then
              runup(i)=999
              runup05(i)=999
              runup95(i)=999
          end if
        end do
      
      
      return
	  end subroutine runupcalc


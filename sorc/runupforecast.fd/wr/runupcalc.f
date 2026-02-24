subroutine runupcalc(nhs, hs, pwp, slope, slope95, slope05, rf2use, &
                     watlev, dlow, esi, setup, sinc, sig, s, runup, &
                     runup95, runup05)
     implicit none
     ! Original code written for Stockdon formulation.
     ! Updated for US West Coast implementation: Stockdon (2006), TAW (van der Meer, 2002),
     ! and Shore Protection Manual (1984).

     ! ---- Arguments ----
     integer, intent(in) :: nhs, rf2use
     character(len=2), intent(in) :: esi
     real*4, intent(in) :: slope, slope95, slope05, dlow
     real*4, dimension(nhs), intent(in) :: hs, pwp, watlev
     real*4, dimension(nhs), intent(inout) :: setup, sinc, sig, s
     real*4, dimension(nhs), intent(inout) :: runup, runup95, runup05

     ! ---- Local variables ----
     integer :: i
     real*4, dimension(nhs) :: wavel, ir, mwp, wavelm, Hm0, DWL
     real*4 :: g, pi, br, br2
     real*4 :: bsetup1, bsetup2, bsinc, bsig, bs, absslope
     real*4 :: gammab, gammaf, irgammab
     real*4, dimension(nhs) :: setup95, setup05

     ! ---- Constants ----
     g = 9.8026       ! gravitational acceleration at ~41°N
     pi = 3.1415927
     br = 1.1
     br2 = 0.039
     bsetup1 = 0.016
     bsetup2 = 0.35
     bsinc = 0.75
     bsig = 0.06
     bs = 0.046

     ! ---- Derived wave parameters ----
     wavel = (g * pwp**2) / (2.0 * pi)
     mwp = pwp / 1.1
     wavelm = (g * mwp**2) / (2.0 * pi)

     ! ---- Stockdon formulation (default) ----
     if (rf2use .eq. 0) then
        absslope = abs(slope95)
        setup = bsetup2 * absslope * sqrt(hs * wavel)
        sinc = bsinc * slope95 * sqrt(hs * wavel)
        sig = bsig * sqrt(hs * wavel)
        s = sqrt(sinc**2 + sig**2)
        runup95 = br * (setup + s / 2.0)

        absslope = abs(slope05)
        setup = bsetup2 * absslope * sqrt(hs * wavel)
        sinc = bsinc * slope05 * sqrt(hs * wavel)
        s = sqrt(sinc**2 + sig**2)
        runup05 = br * (setup + s / 2.0)

        absslope = abs(slope)
        setup = bsetup2 * absslope * sqrt(hs * wavel)
        sinc = bsinc * slope * sqrt(hs * wavel)
        s = sqrt(sinc**2 + sig**2)
        runup = br * (setup + s / 2.0)
     end if

     ! ---- TAW method ----
     !    Version 1b changed to use a simplified formula by Nielsen and Hanslow (1991)
     !       wavesetup (not used in TAW) is now estimated with the Guza and Thornton (1981) approximation
     if (rf2use .eq. 1) then
        absslope = abs(slope95)
        if (absslope .lt. 0.1) then
            do i = 1, nhs
                runup95(i) = 0.06 * sqrt(hs(i) * wavelm(i))
                setup95(i) = 0.17 * hs(i)
            end do
        else
            do i = 1, nhs
                runup95(i) = 0.06 * absslope * sqrt(hs(i) * wavelm(i))
                setup95(i) = 0.17 * hs(i)
            end do
        end if

        absslope = abs(slope05)
        if (absslope .lt. 0.1) then
            do i = 1, nhs
                runup05(i) = 0.06 * sqrt(hs(i) * wavelm(i))
                setup05(i) = 0.17 * hs(i)
            end do
        else
            do i = 1, nhs
                runup05(i) = 0.06 * absslope * sqrt(hs(i) * wavelm(i))
                setup05(i) = 0.17 * hs(i)
            end do
        end if

        absslope = abs(slope)
        if (absslope .lt. 0.1) then
            do i = 1, nhs
                runup(i) = 0.06 * sqrt(hs(i) * wavelm(i))
                setup(i) = 0.17 * hs(i)
            end do
        else
            do i = 1, nhs
                runup(i) = 0.06 * absslope * sqrt(hs(i) * wavelm(i))
                setup(i) = 0.17 * hs(i)
            end do
        end if
     end if

     ! ---- SPM method ----
     if (rf2use .eq. 2) then
        absslope = abs(slope)
        runup = 1.5 * hs
        runup05 = runup
        runup95 = runup
     end if

     ! ---- Cap extreme values ----
     do i = 1, nhs
        if (runup95(i) .gt. 20.0) then
            runup(i) = 999.0
            runup05(i) = 999.0
            runup95(i) = 999.0
        end if
     end do

     return
end subroutine runupcalc

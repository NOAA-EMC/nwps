      program runupforecast
!
!        Purpose
!            This is a runup forecast model based on the runup
!            parameterization of:
!                     Stockdon, H. F., R. A. Holman, P. A. Howd, and J. Sallenger A. H. (2006),
!		              Empirical parameterization of setup, swash, and runup,
!		              Coastal Engineering, 53, 573-588.
!
!        Data:
!           funwps  = File unit number for NWPS output.
!           fuslope = File unit number for file containing beach slope.
!
!        I/O Variables:
!            ftime = NWPS forecast time for a given point. (NOTE: Given how
!                    the time is written in the NWPS output files, this variable
!                    needs to have a real size of 8 bytes.)
!             hsig = Bulk significant wave height in meters.
!              nhs = number of hsig values from the current file.
!           ninput = 
!              pwp = Peak wave period in seconds. 
!         timestep = time in hours between each forecast projection.
!            uwind = Zonal component of the wind velocity.
!            vwind = Meridional component of the wind velocity.
!           watlev = Water level. (NOTE: This is not the total water depth, but
!                    the deviation from MSL.)
!           cgxpos = Longitude of a given point. The longitude values given
!                    in degrees east, therefroe western hemisphere longitudes
!                    will be > 180.0.  These are from the NWPS CG grid.
!           cgxvel = Zonal component of the ambient current.
!             ypos = Latitude, in degrees, of a given point.   These are from
!                    the NWPS CG grid.
!             yvel = Meridional component of the ambient current.
!        sxpos/sxp = Longitude shoreline position, projected perpendicular
!                    from the 20m contour coordinates.
!        sypos/syp = Latitude shoreline position, projected perpendicular
!                    from the 20m contour coordinates.
!        slope/slo = slope at the shoreline position
!    slope95/slo95 = 95th percentile maximum slope
!    slope05/slo05 = 5th percentile maximum slope
!         dhigh/dh = dune crest height
!          dlow/dl = dune toe height
!              twl = total water level:  NWPS water level + wave runup
!            runup = 2% exceedence wave runup (wave setup + swash) at the shoreline based on slope
!          runup95 = 2% exceedence wave runup (wave setup + swash) at the shoreline based on slope95
!          runup05 = 2% exceedence wave runup (setup + swash) at the shoreline based on slope05
!            setup = wave setup at the shoreline based on slope
!                s = total wave swash excursion at the shoreline based on average beach slope
!             sinc = Incident swash at the shoreline based on average beach slope
!              sig = Infragravity swash at the shoreline based on average beach slope
!            owash = Overwash, defined as twl - dhigh
!         owashexd = Overwash exceedance probability
!            erosn = Erosion, defined as twl - dlow
!         erosnexd = Erosion exceedance probability

      implicit none
      integer, parameter :: ninput=3000
      integer, parameter :: funwps=20
      integer, parameter :: fuslope=21
      integer, parameter :: furun=22
!
      integer :: i
      integer :: ier,nobs,nhs,timestep,nshore,istart,loc
      real :: slo,slo95,slo05,sxp,syp,dh,dl
      real*8, dimension(ninput) :: ftime
      real, dimension(ninput) :: cgxpos,cgypos,xpos,ypos,sxpos,sypos
      real, dimension(ninput) :: hsig,pwp,mwd,mwdsn
      real, dimension(ninput) :: xvel,yvel,watlev
      real, dimension(ninput) :: uwind,vwind
      real, dimension(ninput) :: slope,slope95,slope05
      real, dimension(ninput) :: setup,sinc,sig,s
      real, dimension(ninput) :: runup,runup95,runup05
      real, dimension(ninput) :: dhigh,dlow
      real, dimension(ninput) :: twl,twl95,twl05
      real, dimension(ninput) :: owash
      real, dimension(ninput) :: erosn
      integer, dimension(ninput) :: owashexd
      integer, dimension(ninput) :: erosnexd
      character(len=255) :: FORT22
!
!        Banner
!
      write(6,*) '**************************************************'
      write(6,*) '*   W A V E  R U N U P   P R E D I C T I O N     *'
      write(6,*) '*                                                *'
      write(6,*) '*   Authors: Stockdon, H. F., R. A. Holman,      *'
      write(6,*) '*          P. A. Howd, J. Sallenger and J Long   *'
      write(6,*) '**************************************************'
!
!        initalize arrays
!
      nhs=0
      nshore=0
      timestep=3
      ftime(:)=-9999.
      cgxpos(:)=-9999.
      cgypos(:)=-9999.
      hsig(:)=-9999.
      pwp(:)=-9999.
      mwd(:)=-9999.
      mwdsn(:)=-9999.
      xvel(:)=-9999.
      yvel(:)=-9999.
      watlev(:)=-9999.
      uwind(:)=-9999.
      vwind(:)=-9999.
      owashexd(:) = 0
      erosnexd(:) = 0
!       not using past information for this
	  istart=1.
!
!
!        read input file from NWPS. The routine will return the number of
!        observations it read from funwps in nhs.
!      
      call read_nwps(funwps,ninput,istart,ftime,cgxpos,cgypos,hsig,
     1               pwp,mwd,xvel,yvel,watlev,uwind,vwind,nhs,
     2               ier)

!        get the beach slope and slope variability at each transect from USGS slope file
      call read_slope(fuslope,ninput,nshore,xpos,ypos,sxpos,sypos,
     1               slope,slope95,slope05,dhigh,dlow,nshore,ier)
      do i=1,nshore  
         if((cgxpos(1).eq.xpos(i)).and.(cgypos(1).eq.ypos(i))) then
            slo=slope(i)
            slo95=slope95(i)
            slo05=slope05(i)
            dh=dhigh(i)
            dl=dlow(i)
            sxp = sxpos(i)
            syp = sypos(i)
         endif
      end do

!        go compute runup
      call get_environment_variable("FORT22",FORT22)
      open(UNIT=furun,FILE=FORT22,ACCESS='APPEND',STATUS='OLD')
      call runupcalc(nhs,hsig,pwp,slo,slo95,slo05,watlev,setup,
     1                     sinc,sig,s,runup,runup95,runup05)
      
      twl = watlev+runup
      twl95 = watlev+runup95
      twl05 = watlev+runup05
      owash = twl-dh
      erosn = twl-dl

      do i=1,nhs
         if((twl95(i)-dh).gt.0.) then
            owashexd(i) = 5
         endif
         if((twl(i)-dh).gt.0.) then
            owashexd(i) = 50
         endif
         if((twl05(i)-dh).gt.0.) then
            owashexd(i) = 95
         endif
         if((twl95(i)-dl).gt.0.) then
            erosnexd(i) = 5
         endif
         if((twl(i)-dl).gt.0.) then
            erosnexd(i) = 50
         endif
         if((twl05(i)-dl).gt.0.) then
            erosnexd(i) = 95
         endif
      end do
      
!        write the output file
      do i=1,nhs
        write(furun,100)ftime(i),sxp,syp,hsig(i),
     1        pwp(i),slo,twl(i),twl95(i),twl05(i),runup(i),runup95(i),
     2        runup05(i),setup(i),s(i),sinc(i),sig(i),
     3        dh,dl,owash(i),erosn(i),owashexd(i),erosnexd(i)
 100   format(F14.4,4X,F8.4,5X,F8.4,4X,F5.3,5X,F7.4,6X,F5.4,5X,F5.2,8X,
     1        F5.2,6X,F5.2,12X,F4.2,12X,F4.2,12X,F4.2,12X,F4.2,10X,
     2        F4.2,12X,F4.2,17X,F4.2,11X,F8.4,10X,F8.4,
     3        10X,F5.2,10X,F5.2,12X,I3,15X,I3)
      end do
      close(furun)
!
      stop
      end program runupforecast

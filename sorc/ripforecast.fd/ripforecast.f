      program ripforecast
!
!        Purpose
!            This is a rip forecast model based on the binomial logistic
!            regression calculation of a rip liklihood given wave field
!            and tide inputs.
!
!        Data Sets Used
!           funwps = File unit number for NWPS input.
!           fupast = File unit number for past 72 hours of data.
!
!        Variables
!         eventout = logical if the event (i.e. hs > 1) occurs in the
!                    72 hour.
!            ftime = NWPS forecast time for a given point. (NOTE: Given how
!                    the time is written in the NWPS output files, this variable
!                    needs to have a real size of 8 bytes.)
!             hsig = Bulk significant wave height in meters.
!         hspast72 = Past 72 hours of bulk significant wave height in meters.
!              mwd = Mean wave direction in degrees true.
!            mwdsn = Mean wave direction in degrees normal to shorline.
!              nhs = number of hs values from the current file.
!           ninput = total number of time steps to process (incl. past 72 hours)
!          npast72 = number of hs values from the past 72 hours.
!              pwp = Peak wave period in seconds. (NOTE: Currently note used.)
!     shorelinedir = direction directly perpendicular from the shoreline
!                    in degrees true.
!         timestep = time in hours between each forecast projection.
!            uwind = Zonal component of the wind velocity.
!            vwind = Meridional component of the wind velocity.
!           watlev = Water level. (NOTE: This is not the total water depth, but
!                    the deviation from MSL.)
!             xpos = Longitude of a given point. the longitude values given
!                    in degrees east, therefroe western hemisphere longitudes
!                    will be > 180.0.
!             xvel = Zonal component of the ambient current.
!             ypos = Latitude, in degrees, of a given point.
!             yvel = Meridional component of the ambient current.
!
      implicit none
      integer, parameter :: ninput=300
      integer, parameter :: nobsread=2000
      integer, parameter :: funwps=20
      integer, parameter :: fushore=21
      integer, parameter :: fupast=22
      integer, parameter :: fuprob=23
!
      integer :: i
      integer :: ier,nobs,nhs,timestep,npast72,nall,nshore
      real :: shorelinedir
      real*8, dimension(ninput) :: ftime
      real, dimension(ninput) :: xpos,ypos
      real, dimension(ninput) :: hsig,hspast72,pwp,mwd,mwdsn
      real, dimension(ninput) :: xvel,yvel,watlev
      real, dimension(ninput) :: uwind,vwind
      real, dimension(ninput) :: prob
!      logical, dimension(ninput) :: eventout
      integer, dimension(ninput) :: eventout
      real, dimension(nobsread) :: sxpos,sypos,shore
      logical :: exist

!
!        Banner
!
      write(6,*) '**************************************************'
      write(6,*) '*   R I P  C U R R E N T  P R E D I C T I O N    *'
      write(6,*) '*                                                *'
      write(6,*) '*   Authors: Greg Dusek, Harvey Seim (2013)      *'
      write(6,*) '**************************************************'
!
!        initalize arrays
!
      shorelinedir=0.
      nall=0
      nhs=0
      npast72=0
      nshore=0
      timestep=1
!      eventout(:)=.false.
      eventout(:)=0
      ftime(:)=-9999.
      xpos(:)=-9999.
      ypos(:)=-9999.
      hsig(:)=-9999.
      hspast72(:)=-9999.
      pwp(:)=-9999.
      mwd(:)=-9999.
      mwdsn(:)=-9999.
      xvel(:)=-9999.
      yvel(:)=-9999.
      watlev(:)=-9999.
      uwind(:)=-9999.
      vwind(:)=-9999.
      exist=.false.
!
!        read past file. The routine will return the number of
!        observations it read from fupast in npast72.
!
      inquire(file='fort.22', exist=exist)
      if (exist) then
         call read_nwps(fupast,ninput,npast72,ftime,xpos,ypos,hsig,
     1                  pwp,mwd,xvel,yvel,watlev,uwind,vwind,npast72,
     2                  ier)
         hspast72=hsig(1:npast72)
      else
!        If past file doesn't exist, set all past hs to zero (no event)
         write(6,*) 'No history file. Values of hspast72 set to zero.'
         hspast72=0
         npast72=72
      endif
!
!        read input file. The routine will return the number of
!        observations it read from funwps in nhs.
!      
      call read_nwps(funwps,ninput,npast72,ftime,xpos,ypos,hsig,
     1               pwp,mwd,xvel,yvel,watlev,uwind,vwind,nhs,
     2               ier)
      nall=nhs+npast72
!
!        read the shoreline direction file
!
      call read_shore(fushore,nobsread,nshore,sxpos,sypos,shore,
     1               nshore,ier)
      do i=1,nshore
         if((xpos(1).eq.sxpos(i)).and.(ypos(1).eq.sypos(i))) then
            shorelinedir=shore(i)
         endif
      end do

!
!        calculate the event variable
!
      call eventcalc(nhs,npast72,hspast72,hsig,timestep,eventout)
!
      mwdsn=mwd-shorelinedir
!     check for condition due to circular boundary at N
      do i=1,nhs
         if(mwdsn(i).lt.-180.) then
            mwdsn(i)=mwdsn(i)+360.
         else if(mwdsn(i).gt.180.) then
            mwdsn(i)=mwdsn(i)-360.
         endif
      end do
!
      open(UNIT=fuprob,ACCESS='APPEND',STATUS='OLD')
      call bulkmodel(nhs,hsig,mwdsn,eventout,watlev,prob)
      do i=1,nhs
         write(fuprob,100)ftime(i),xpos(i),ypos(i),prob(i),hsig(i),
     1         pwp(i),mwdsn(i),watlev(i),1*eventout(i)
 100   format(F14.4,4X,F8.4,4X,F8.4,4X,F5.1,4X,F6.4,4X,F7.3,
     1        4X,F8.3,4X,F5.2,2X,I1)
      end do
      close(fuprob)
!
      stop
      end program ripforecast

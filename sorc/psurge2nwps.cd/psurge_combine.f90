program psurge_combine

!*****************************************************************************
!
!  Purpose:
!
!    Program to combine P-Surge interpolated output with ESTOFS output in order
!    to avoid zero (no data) values in the extracted P-Surge fields.
!
!  Author:
!
!    andre.vanderwesthuysen@noaa.gov
!
!  Last Modified:
!
!    August 2, 2020
!
!  Notes:
!
!    This code uses the example of PWL_INTERP_2D_TEST to call the PWL_INTERP_2D 
!    library. PWL_INTERP_2D_TEST is written by John Burkardt, 13 September 2012, 
!    distributed under the GNU LGPL license. For details, see:
!     https://people.sc.fsu.edu/~jburkardt/f_src/pwl_interp_2d/pwl_interp_2d.html
!
  implicit none

  integer ( kind = 4 ) i
  character(2)   :: HHINI
  character(3)   :: DOMAIN, FHOUR
  character(2)   :: EXCEED
  character(8)   :: DATEIN
  character(10)  :: EPOC_TIME
  character(150) :: ESTOFSDIR

  character(2)   :: HHINI2
  character(3)   :: FHOUR2
  character(8)   :: DATEIN2
  character(10)  :: EPOC_TIME2

  write (*,'(a)') '------- PSURGE_COMBINE: Uses the R8LIB library -------'

  call getarg(1,ESTOFSDIR)
  call getarg(2,DOMAIN)
  call getarg(3,EXCEED)
  call getarg(4,EPOC_TIME)
  call getarg(5,DATEIN)
  call getarg(6,HHINI)
  call getarg(7,FHOUR)
  call getarg(8,EPOC_TIME2)
  call getarg(9,DATEIN2)
  call getarg(10,HHINI2)
  call getarg(11,FHOUR2)

  call interp_combine(ESTOFSDIR,DOMAIN,EXCEED,EPOC_TIME,DATEIN,HHINI,FHOUR, &
                      EPOC_TIME2,DATEIN2,HHINI2,FHOUR2)

  write (*,'(a)') 'PSURGE_COMBINE: Normal end of execution.'
  stop 0
end

subroutine interp_combine(ESTOFSDIR,DOMAIN,EXCEED,EPOC_TIME,DATEIN,HHINI,FHOUR, &
                          EPOC_TIME2,DATEIN2,HHINI2,FHOUR2)

!*****************************************************************************
!
!  Method:
!
!    Subroutine to interpolate ESTOFS data from its native grid onto the 
!    P-Surge grid. Thereafter, the P-Surge data is supplemented with 
!    ESTOFS data where P-Surge = 0.0.
!
  implicit none

! nd : int   : Total number of coordinates on origin (data) grid
! nxd : int  : Numer of x coordinates on origin (data) grid
! nyd : int  : Numer of y coordinates on origin (data) grid
! xd : array : x coord on orgin (data) grid
! yd : array : y coord on orgin (data) grid
! zd : array : z coord on orgin (data) grid
! xi : array : x coord on interpolated grid
! yi : array : y coord on interpolated grid
! zi : array : z coord on interpolated grid

  character(2)   :: HHINI
  character(3)   :: DOMAIN, FHOUR
  character(2)   :: EXCEED
  character(8)   :: DATEIN
  character(10)  :: EPOC_TIME
  character(150) :: ESTOFSDIR

  character(2)   :: HHINI2
  character(3)   :: FHOUR2
  character(8)   :: DATEIN2
  character(10)  :: EPOC_TIME2

  character(32)  :: fname1
  character(200) :: fname2
  character(62)  :: fname3
  character(200) :: fname4
  character(62)  :: fname5

  character(19) dummy1
  real ( kind = 8 ) app_error
  integer ( kind = 4 ) i
  integer ( kind = 4 ) ij
  real ( kind = 8 ) int_error
  integer ( kind = 4 ) j
  integer ( kind = 4 ) n
  integer ( kind = 4 ) nd
  integer ( kind = 4 ) ni
  integer ( kind = 4 ) nxd
  integer ( kind = 4 ) nyd
  integer ( kind = 4 ) nxi
  integer ( kind = 4 ) nyi
  integer ( kind = 4 ) funin1, funin2, funin3, funin4, funin5
  real ( kind = 8 ) r8vec_norm_affine, xd0, yd0, dx, dy, dummy2, xi0, yi0, dxi, dyi
  real ( kind = 8 ), allocatable :: xd(:)
  real ( kind = 8 ), allocatable :: xd_1d(:)
  real ( kind = 8 ), allocatable :: xi(:)
  real ( kind = 8 ), allocatable :: xi_1d(:)
  real ( kind = 8 ), allocatable :: yd(:)
  real ( kind = 8 ), allocatable :: yd_1d(:)
  real ( kind = 8 ), allocatable :: yi(:)
  real ( kind = 8 ), allocatable :: yi_1d(:)
  real ( kind = 8 ), allocatable :: zd(:)
  real ( kind = 8 ), allocatable :: zdm(:)
  real ( kind = 8 ), allocatable :: zi(:), zi_psurge(:), zi_comb(:)

  write(*,*) 'Combining fields for: ',trim(ESTOFSDIR),' ',DOMAIN,' ',EXCEED,' ', & 
                                      EPOC_TIME,' ',DATEIN,' ',HHINI,' ',FHOUR,' ', &
                                      EPOC_TIME2,' ',DATEIN2,' ',HHINI2,' ',FHOUR2

  funin1 = 20
  fname1 = 'psurge_waterlevel_domain_'//DOMAIN//'.txt'
  funin2 = 21
  fname2 = trim(ESTOFSDIR)//'estofs_waterlevel_domain.txt'
  funin3 = 22
  fname3 = 'wave_psurge_waterlevel_'//EPOC_TIME//'_'//DATEIN//'_'//HHINI//'_'//DOMAIN//'_e'//EXCEED//'_f'//FHOUR//'.dat'
  funin4 = 23
  fname4 = trim(ESTOFSDIR)//'wave_estofs_waterlevel_'//EPOC_TIME2//'_'//DATEIN2//'_'//HHINI2//'_f'//FHOUR2//'.dat'
  funin5 = 24
  fname5 = 'wave_combnd_waterlevel_'//EPOC_TIME//'_'//DATEIN//'_'//HHINI//'_'//DOMAIN//'_e'//EXCEED//'_f'//FHOUR//'.dat'

  write(*,*) 'PSURGE domain (in): ',fname1
  write(*,*) 'ESTOFS domain (in): ',fname2
  write(*,*) 'PSURGE water levels (in): ',fname3
  write(*,*) 'ESTOFS water levels (in): ',fname4
  write(*,*) 'COMBND water levels (out): ',fname5

! Open Input File: ESTOFS domain
!
  open(unit=funin2,file=fname2,form="formatted",status="old")
  read(funin2,*,end=100) dummy1, yd0, dummy2, nxd, nyd, dx, dy
  read(dummy1(14:), *) xd0
100  close(funin2)
  write (*,*) '  ESTOFS domain:', xd0, yd0, nxd, nyd, dx, dy

! Increment nxd and nyd by one (to account for SWAN MXC,MYC definition)
  nxd = nxd+1
  nyd = nyd+1

! Set up xd and yd arrays
  allocate( xd_1d(nxd) )
  allocate( yd_1d(nyd) )
  
  xd_1d = [(xd0 + (i-1) * dx, i=1,nxd)]  ! array constructor
  yd_1d = [(yd0 + (i-1) * dy, i=1,nyd)]  ! array constructor

  nd = nxd * nyd
  write ( *, '(a,i6)' ) '  Number of data points = ', nd

  allocate ( xd(nxd*nyd) )
  allocate ( yd(nxd*nyd) )
  allocate ( zd(nxd*nyd) )

  ij = 0
  do j = 1, nyd
    do i = 1, nxd
      ij = ij + 1
      xd(ij) = xd_1d(i)
      yd(ij) = yd_1d(j)
    end do
  end do

! Read ESTOFS z data
  open(unit=funin4,file=fname4,form="formatted",status="old")
  do i=1, nd
     read(funin4,*,end=101) zd(i)
  end do
101  close(funin4)

! Open Input File: PSURGE domain
!
  open(unit=funin1,file=fname1,form="formatted",status="old")
  read(funin1,*,end=102) dummy1, yi0, dummy2, nxi, nyi, dxi, dyi
  read(dummy1(14:), *) xi0
102  close(funin1)
  write (*,*) '  P-Surge domain:', xi0, yi0, nxi, nyi, dxi, dyi

! Increment nxd and nyd by one (to account for SWAN MXC,MYC definition)
  nxi = nxi+1
  nyi = nyi+1

! Set up xi and yi arrays
  allocate( xi_1d(nxi) )
  allocate( yi_1d(nyi) )
  
  xi_1d = [(xi0 + (i-1) * dxi, i=1,nxi)]  ! array constructor
  yi_1d = [(yi0 + (i-1) * dyi, i=1,nyi)]  ! array constructor

  ni = nxi * nyi
  write ( *, '(a,i6)' ) '  Number of data points = ', ni

  allocate ( xi(ni) )
  allocate ( yi(ni) )
  allocate ( zi(ni) )
  allocate ( zi_psurge(ni) )
  allocate ( zi_comb(ni) )

  zi_comb = 0.

  ij = 0
  do j = 1, nyi
    do i = 1, nxi
      ij = ij + 1
      xi(ij) = xi_1d(i)
      yi(ij) = yi_1d(j)
    end do
  end do

  call pwl_interp_2d ( nxd, nyd, xd_1d, yd_1d, zd, ni, xi, yi, zi )

! Read PSURGE z data
  open(unit=funin3,file=fname3,form="formatted",status="old")
  do i=1, ni
     read(funin3,*,end=103) zi_psurge(i)
  end do
103  close(funin3)

! Combine PSURGE with ESTOFS, where PSURGE=0
!  zi_comb = max(zi_psurge,zi)
  zi_comb = zi_psurge
  do i=1, ni
     if (zi_psurge(i) == 0.0) zi_comb(i) = zi(i)
  end do  

! Write COMBINED z data file
  open(unit=funin5,file=fname5,form="formatted",status="unknown")
  do i=1, ni
     write(funin5,200) zi_comb(i)
  end do
200 format (F9.4)
  close(funin5)

  deallocate ( xi )
  deallocate ( yi )
  deallocate ( zi )
  deallocate ( xd )
  deallocate ( xd_1d )
  deallocate ( yd )
  deallocate ( yd_1d )
  deallocate ( zd )

  return
end


      PROGRAM psoutTOnwps
      IMPLICIT NONE
      real :: r, valuemax, Value
      integer :: i,reason,NstationFiles,iStation,dimxy,NNPX,NNPY,icon
      integer :: icount,ix,iy,npx,npy,nvaldif0
      character(LEN=100), dimension(:), allocatable :: stationFileNames
      real, allocatable, dimension(:) :: percent
      CHARACTER (LEN=4) NPX1,NPY1
      CHARACTER (LEN=3)  :: DOMAIN
      CHARACTER (LEN=100)  :: filep
      character*2 second
      character*100 command
!      character*30 first
      character*17 first,outfile
      character*16 mark
      CALL GETARG(1,DOMAIN)
      CALL GETARG(2,NPX1)
      CALL GETARG(3,NPY1)
      READ(NPX1,*) NNPX
      READ(NPY1,*) NNPY
      dimxy=NNPX*NNPY
!      allocate(Value(dimxy))
      print*, "dimxy:", dimxy
      first = " psurge*"//DOMAIN//"*.dat"
      outfile="psurge"//DOMAIN//".wlev"
      print*,outfile
      second = ">"
      mark = "fileContents.txt"
!     command = ls psurge*DOMAIN*.dat > fileConstents.txt   
      write(command,'(a," ",a, " ",a," ",a," ",a)')
     1 "ls ",first,second,mark,""

      call system(command)
      open(31,FILE='fileContents.txt',action="read")
      !how many
      i = 0
      OPEN(40,FILE='wfolist_psurge_final.dat',access='append',
     1     STATUS='old')
      do
         read(31,FMT='(a)',iostat=reason) r
         if (reason/=0) EXIT
           i = i+1
      end do
      NstationFiles = i
      allocate(percent(i))
      nvaldif0=0
      write(*,'(a,I0)') "Number of .dat files for : " , NstationFiles
      allocate(stationFileNames(NstationFiles))
      rewind(31)
! open to write      OPEN(30, FILE=outfile, STATUS='UNKNOWN', ACTION='WRITE')
      do i = 1,NstationFiles
        read(31,'(a)') stationFileNames(i)
        write(*,'(a)') trim(stationFileNames(i)) 
        OPEN(20, FILE=stationFileNames(i),STATUS='OLD', ACTION='READ')
        do icon=1,dimxy
           READ(20,*)Value
!           if (Value .gt. 0.0) nvaldif0=nvaldif0+1
           if (Value .ne. 0.0 .and. Value .ne. -9999.000)
     1     nvaldif0=nvaldif0+1
        end do
        close(20)
        percent(i)=(nvaldif0/dimxy)*100
        if (percent(i) .gt. 50.0) then 
          select case (DOMAIN)
             case ("okx")  
                   npx= 327
                   npy=  198
             case ("mfl")  
                   npx= 456
                   npy= 342
             case ("bro")  
                   npx= 436
                   npy= 409
             case ("crp")  
                   npx= 496
                   npy= 462
             case ("hgx")  
                   npx= 374
                   npy= 446
             case ("lch")  
                   npx= 261
                   npy= 261
             case ("lix")  
                   npx= 401
                   npy= 305
             case ("mob")  
                   npx= 313
                   npy= 261
             case ("tae")  
                   npx= 512
                   npy= 298
             case ("tbw")  
                   npx= 356
                   npy= 372
             case ("key")  
                   npx= 409
                   npy= 298
             case ("mlb")  
                   npx= 290
                   npy= 334
             case ("jax")  
                   npx= 253
                   npy= 320
             case ("car")  
                   npx= 290
                   npy= 224
             case ("gyx")  
                   npx= 364
                   npy= 246
             case ("box")  
                   npx= 346
                   npy= 283
             case ("phi")  
                   npx= 261
                   npy= 261
             case ("lwx")  
                   npx= 253
                   npy= 294
             case ("akq")  
                   npx= 316
                   npy= 357
             case ("mhx")  
                   npx= 316
                   npy= 279
             case ("ilm")  
                   npx= 364
                   npy= 246
             case ("chs")  
                   npx= 342
                   npy= 291
          end select
          write(40,'(a,i6, i6)') DOMAIN
        end if
! For a particular WFO and a particular time the minimum covarege (percentage) is found
! There is no need to keep checking.
        if (percent(i) .gt. 50.0) exit
      end do
      close(31)
      close(30)
      END PROGRAM

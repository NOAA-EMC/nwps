      PROGRAM psoutTOnwps
      IMPLICIT NONE
      real :: r, VCORR
      integer :: i,reason,NstationFiles,iStation,dimxy,NPX,NPY,icon
      integer :: icount,ix,iy

      INTEGER :: pos1, pos2, n 
      CHARACTER(10) :: word(8)
      Character(4) :: fhh
      CHARACTER(100) :: str

      character(LEN=100), dimension(:), allocatable :: stationFileNames
      real, allocatable, dimension(:) :: Value
      !CHARACTER (LEN=5)  :: ADVNUM
      CHARACTER (LEN=2)  :: HHINI
      CHARACTER (LEN=4) NPX1,NPY1
      CHARACTER (LEN=3)  :: DOMAIN, HH
      CHARACTER (LEN=2)  :: EXCEED1, EXCEED
      CHARACTER (LEN=7)  ::Vdatum
      CHARACTER (LEN=8)  ::YYYYMMDD
      CHARACTER (LEN=10)  :: DATEIN, DATEIN1, EPOC_TIME
      CHARACTER (LEN=100)  :: filep
      character*2 second
      character*100 command
      character*67 outfile
      character*16 first
      character*23 mark, filewfos
      CALL GETARG(1,DOMAIN)
      CALL GETARG(2,NPX1)
      CALL GETARG(3,NPY1)
      CALL GETARG(4,DATEIN1)
      CALL GETARG(5,EXCEED1)
      !CALL GETARG(6,ADVNUM)
      CALL GETARG(6,HHINI)
      CALL GETARG(7,EPOC_TIME)
      CALL GETARG(8,Vdatum)
      READ(NPX1,*) NPX
      READ(NPY1,*) NPY

      READ(DATEIN1,*) DATEIN
      READ(EXCEED1,*) EXCEED
      READ(Vdatum,*) VCORR

!      READ(EPOC,*) epoc_time
!      READ(ADVNUM1,*) ADVNUM
      dimxy=NPX*NPY
      allocate(Value(dimxy))
      print*, " VCORR NPX, NPY dimxy:",  VCORR, NPX,NPY, dimxy
!      print*, "Fortran dateinname:", DATEIN
!      print*, "EXCEEDANCE:", EXCEED
!      print*, "epoc_time:",epoc_time
!!      first = " psurge*"//DOMAIN//"*.dat"
      first = " psurge*"//DOMAIN//"*e"//EXCEED//"*.dat"
!      print*,first
      second = ">"
!!      mark = "fileContents.txt"
      mark    = "fileContents_"//DOMAIN//"_"//EXCEED//".txt"
!      filewfos= "fileContents_"//EXCEED//".txt"
      write(command,'(a," ",a, " ",a," ",a," ",a)')
     1 "ls ",first,second,mark,""

      call system(command)
!!      open(31,FILE='fileContents.txt',action="read")
      open(31,FILE="fileContents_"//DOMAIN//"_"//EXCEED//".txt",
     1     action="read")

      !how many
      i = 0
      do
         read(31,FMT='(a)',iostat=reason) r
         if (reason/=0) EXIT
           i = i+1
      end do
      NstationFiles = i
!      write(*,'(a,a,I0)') "Number of .dat files for ", DOMAIN, NstationFiles
      write(*,'(a,I0)') DOMAIN, NstationFiles
      allocate(stationFileNames(NstationFiles))
      rewind(31)
!      OPEN(30, FILE=outfile, STATUS='UNKNOWN', ACTION='WRITE')
      do i = 1,NstationFiles
        read(31,'(a)') stationFileNames(i)
        write(*,'(a)') trim(stationFileNames(i)) 

! Following lines replaced 
!        if (NPX .lt. 1000 .and. NPY .lt. 1000) then
!          HH=stationFileNames(i)(46:48)
!        else if (NPX .gt. 999 .and. NPY .lt. 1000) then
!          HH=stationFileNames(i)(47:49)
!        else if (NPX .lt. 1000 .and. NPY .gt. 999) then
!          HH=stationFileNames(i)(47:49)
!        else if (NPX .gt. 999 .and. NPY .gt. 999) then
!          HH=stationFileNames(i)(48:50)
!        end if
!  BY THESE
      str=stationFileNames(i)
      pos1=1
      n=0
      DO
        pos2 = INDEX(str(pos1:), "_")
        IF (pos2 == 0) THEN
           n = n + 1
           word(n) = str(pos1:)
           EXIT
        END IF
        n = n + 1
        word(n) = str(pos1:pos1+pos2-2)
        pos1 = pos2+pos1
      END DO
      fhh=word(7)


        YYYYMMDD=DATEIN(1:8)
! Before adding the split code
!        outfile="wave_psurge_waterlevel_"//EPOC_TIME//"_"
!     1  //YYYYMMDD//"_"//HHINI//"_"//DOMAIN//"_e"
!     2  //EXCEED//"_f"//HH//".dat"
!After the split code
        outfile="wave_psurge_waterlevel_"//EPOC_TIME//"_"
     1  //YYYYMMDD//"_"//HHINI//"_"//DOMAIN//"_e"
     2  //EXCEED//"_"//fhh//".dat"


        OPEN(30, FILE=outfile, STATUS='UNKNOWN', ACTION='WRITE')
        print*," OUTFILE from psoutTOnwps:", outfile

        OPEN(20, FILE=stationFileNames(i),STATUS='OLD', ACTION='READ')
        ! Convert feet to meters
        do icon=1,dimxy
           READ(20,*)Value(icon)
        if (Value(icon) .ne. -9999.)Value(icon)=Value(icon)*0.3048+VCORR
        if (Value(icon) .eq. -9999.)Value(icon)=0.000
        end do

        !do iy=1,NPY (start at top)
        do iy=NPY,1,-1
          do ix=1,NPX
             icount=(ix*NPY)-iy+1
             write(30,'(F9.3)')Value(icount)
          end do
        end do
        close(20)
        close(30)
      end do
      close(31)
!      close(30)
      END PROGRAM

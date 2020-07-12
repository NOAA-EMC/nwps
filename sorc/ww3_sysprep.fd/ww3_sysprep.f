!/ ------------------------------------------------------------------- /
      PROGRAM WW3_SYSPREP
!/
!/                  +-----------------------------------+
!/                  | WAVEWATCH III           NOAA/NCEP |
!/                  |     A. J. van der Westhuysen      |
!/                  |                        FORTRAN 95 |
!/                  | Last update :         12-Jul-2020 |
!/                  +-----------------------------------+
!/
!/    19-Sep-2019 : Origination                         ( version 6.07 )
!/
!/    Copyright 2009-2017 National Weather Service (NWS),
!/       National Oceanic and Atmospheric Administration.  All rights
!/       reserved.  WAVEWATCH III is a trademark of the NWS. 
!/       No unauthorized use without permission.
!/
      IMPLICIT NONE
!
!  1. Purpose :
!
!     Transform native WW3 partition output ASCII file into a "tidy"
!     dataframe formatted ASCII file.
!
!  2. Method :
!
!     Read native data from WW3 partition ASCII file, compute grid indices
!     and write into an ASCII file in a dataframe format.
!
!  3. Parameters :
!
!     Local variables
!     ----------------------------------------------------------------
!     llat     Real    Latitude of partition point, from input file 
!     llon     Real    Longitude of partition point, from input file
!     ts       Real    Time step of partition, from input file
!     hs0      Real    Wave height of partition, from input file
!     tp0      Real    Peak period of partition, from input file
!     dir0     Real    Mean direction of partition, from input file
!     dspr0    Real    Mean directional spread of partition, from input file

      LOGICAL     :: file_exists
      CHARACTER   :: infile*80, infile2*80, outfile*80
      INTEGER     :: i,ipart,numpart,IERR,nlon,nlat,ilon,ilat
      REAL*8      :: date0, date1, date2
      REAL        :: llat,llon,hs0,tp0,dir0,dspr0,wf0
      REAL        :: lonmin,lonmax,latmin,latmax,fac1,fac2

      infile = 'partition.raw'
      infile2 = 'ww3_systrk.inp'
      outfile = 'partition.blk.raw'

!     Read WW3 Spectral Partition format file
      WRITE(6,*) 'Reading raw partition file...'
      INQUIRE(FILE=infile, EXIST=file_exists)
      IF (.NOT.file_exists) THEN
         WRITE(6,2001)
         CALL ABORT
      END IF

!     Input file in formatted ASCII
      OPEN(unit=11,file=infile,status='old')
      OPEN(unit=12,file=outfile,status='unknown')
      OPEN(unit=13,file=infile2,status='old')

!     Read config file
!     Skip header lines
      DO i = 1,15
         READ(13, *)
      END DO
      READ (13,900,END=112) lonmin,lonmax,nlon
      READ (13,900,END=112) latmin,latmax,nlat
      WRITE(6,*) lonmin,lonmax,nlon
      WRITE(6,*) latmin,latmax,nlat
      fac1 = (lonmax-lonmin)/nlon
      fac2 = (latmax-latmin)/nlat
      WRITE(6,*) fac1
      WRITE(6,*) fac2

!     Skip header lines
      DO i = 1,3
         READ(11, *)
      END DO

      DO WHILE (.TRUE.)
        READ (11,1000,END=112) date1,date2,llat,llon,numpart
        ilon = nint((llon-lonmin)/fac1)
        ilat = nint((llat-latmin)/fac2)

!       Partition 0 is the total field - skip this
        READ (11, *)

        DO ipart = 1,numpart
         READ (11,1010,END=112) hs0,tp0,dir0,dspr0,wf0
         date0 = date1 + date2/1000000
         WRITE(12,1020) date0,llat,llon,hs0,tp0,dir0,dspr0,wf0,ilat,ilon
        END DO
      ENDDO
  900 FORMAT(F7.2,F7.2,I5)
 1000 FORMAT(F9.0,F7.0,F8.3,F8.3,14X,I3)
 1010 FORMAT(3X,F8.2,F8.2,8X,F9.2,F9.2,F7.2)
 1020 FORMAT(F15.6,F8.3,F8.3,F8.2,F8.2,F9.2,F9.2,F7.2,I5,I5)

 2001 FORMAT (/' *** WAVEWATCH III ERROR IN W3SYSTRK : '/
     &          '     ERROR IN OPENING INPUT FILE'/)
 2002 FORMAT (/' *** WAVEWATCH III ERROR IN W3SYSTRK : '/
     &          '     PREMATURE END OF INPUT FILE'/)

 112  CONTINUE
 110  IERR = -1
      CLOSE(11)
      CLOSE(12)
      WRITE(6,*) '... finished'

      END PROGRAM WW3_SYSPREP

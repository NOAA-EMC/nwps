!/ ------------------------------------------------------------------- /
      PROGRAM WW3_SYSPREP
!/
!/                  +-----------------------------------+
!/                  | WAVEWATCH III           NOAA/NCEP |
!/                  |     A. J. van der Westhuysen      |
!/                  |                        FORTRAN 95 |
!/                  | Last update :         18-Aug-2017 |
!/                  +-----------------------------------+
!/
!/    04-Aug-2017 : Origination                         ( version 5.16 )
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
!     Perform spatial and temporal tracking of wave systems, based 
!     on spectral partition (bulletin) output.
!
!  2. Method :
!
!     This is a controller program. It reads the input parameter file 
!     ww3_systrk.inp and calls subroutine waveTracking_NWS_V2 to 
!     perform the actual tracking procedure. Write output (fields and 
!     point output).
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
      CHARACTER   :: infile*80, outfile*80
      INTEGER     :: i,ipart,numpart, IERR
      REAL*8      :: date0, date1, date2
      REAL        :: llat,llon,hs0,tp0,dir0,dspr0,wf0

      infile = 'partition.raw'
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

!     Skip header lines
      DO i = 1,3
         READ(11, *)
      END DO

      DO WHILE (.TRUE.)
         READ (11,1000,END=112) date1,date2,llat,llon,numpart

!        Partition 0 is the total field - skip this
         READ (11, *)

         DO ipart = 1,numpart
           READ (11,1010,END=112) hs0,tp0,dir0,dspr0,wf0
           date0 = date1 + date2/1000000
           WRITE (12,1020) date0,llat,llon,hs0,tp0,dir0,dspr0,wf0
         END DO
      ENDDO
 1000 FORMAT(F9.0,F7.0,F8.3,F8.3,14X,I3)
 1010 FORMAT(3X,F8.2,F8.2,8X,F9.2,F9.2,F7.2)
 1020 FORMAT(F15.6,F8.3,F8.3,F8.2,F8.2,F9.2,F9.2,F7.2)

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

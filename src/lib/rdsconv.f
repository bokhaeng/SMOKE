 
        SUBROUTINE RDSCONV( FDEV, NNAM, ENAM, OUTNAM )

C***********************************************************************
C  subroutine body starts at line 142
C
C  DESCRIPTION:
C       Reads the pollutant organic conversion file, compares the entries
C       to the valid list of pollutants, sorts it, allocates memory for the
C       conversion tables, and populates the conversion tables for each 
C       pollutant.  It also stores the name of the destination pollutant for 
C       each pollutant in the file.  
C
C  PRECONDITIONS REQUIRED:
C       
C
C  SUBROUTINES AND FUNCTIONS CALLED:
C
C
C  REVISION  HISTORY:
C       Copied from RDSCONV.F 4.2 by M Houyoux 2/99
C
C***********************************************************************
C  
C Project Title: Sparse Matrix Operator Kernel Emissions (SMOKE) Modeling
C                System
C File: @(#)$Id$
C  
C COPYRIGHT (C) 2001, MCNC--North Carolina Supercomputing Center
C All Rights Reserved
C  
C See file COPYRIGHT for conditions of use.
C  
C Environmental Programs Group
C MCNC--North Carolina Supercomputing Center
C P.O. Box 12889
C Research Triangle Park, NC  27709-2889
C  
C env_progs@mcnc.org
C  
C Pathname: $Source$
C Last updated: $Date$ 
C  
C************************************************************************

C...........   MODULES for public variables   
C.........  This module contains the lists of unique source characteristics
        USE MODLISTS

C...........   This module contains the speciation profile tables
        USE MODSPRO

C.........  This module contains the information about the source category
        USE MODINFO

        IMPLICIT NONE

C...........   INCLUDES:

        INCLUDE 'EMCNST3.EXT'      ! emissions constant parameters
c        INCLUDE 'FDESC3.EXT'      ! I/O API file description data structure
c        INCLUDE 'IODECL3.EXT'     ! I/O API function declarations

C.........  SUBROUTINE ARGUMENTS and their descriptions:

        INTEGER     , INTENT (IN) :: FDEV            ! unit no. for file
        INTEGER     , INTENT (IN) :: NNAM            ! no. of valid inv pols
        CHARACTER(*), INTENT (IN) :: ENAM  ( NNAM )  ! inventory pollutant names
        CHARACTER(*), INTENT(OUT) :: OUTNAM( NNAM )  ! destination pol names

C.........  EXTERNAL FUNCTIONS and their descriptions:

        CHARACTER*2   CRLF
        INTEGER       FINDC
        INTEGER       GETFLINE
        INTEGER       INDEX1
        INTEGER       STR2INT
        REAL          STR2REAL

        EXTERNAL      FINDC, GETFLINE, INDEX1, STR2INT, STR2REAL

C.........  LOCAL PARAMETERS:
        INTEGER, PARAMETER :: TBLLEN = FPSLEN3 + POLLEN3

C.........  LOCAL VARIABLES and their descriptions:
C.........  Unsorted pollutant conversion table
        INTEGER                               NCONV     ! number of conv facs
        INTEGER              , ALLOCATABLE :: INDX( : ) ! index for sorting
        INTEGER              , ALLOCATABLE :: ISPA( : ) ! pollutant idx in ENAM
        INTEGER              , ALLOCATABLE :: TYPA( : ) ! type of each line

        REAL                 , ALLOCATABLE :: FACA( : ) ! conversion factors

        CHARACTER(LEN=TBLLEN), ALLOCATABLE :: PCVA( : ) ! FIPS// SCC// pol index

C.........  Counter for different types of records in the input file
        INTEGER :: N( 0:3 )

C.........  Other local variables
        INTEGER         I, J, K, K1, K2, L, T, V ! counters and indices

        INTEGER         CE1, CE2, CE3    ! ending   column numbers
        INTEGER         CS1, CS2, CS3    ! starting column numbers
        INTEGER         IOS              ! i/o Status code
        INTEGER         IREC             ! line number of input file
        INTEGER         ISP              ! tmp pol index in ENAM
        INTEGER         LTYPE            ! tmp type of each line 
        INTEGER         NLINE            ! number of lines in input file 
        INTEGER         STLP1            ! state width plus 1 

        REAL            FAC              ! tmp conversion factor

        LOGICAL      :: EFLAG = .FALSE.  ! error flag
        LOGICAL      :: RFLAG = .FALSE.  ! true: Skip records in this section
        LOGICAL      :: SFLAG = .FALSE.  ! true: Records were skipped

        CHARACTER*10           CPOL      ! tmp pollutant index in ENAM
        CHARACTER*16           LINE16    ! tmp 16-char line
        CHARACTER*300          LINE      ! line buffer
        CHARACTER*300          MESG      ! message buffer

        CHARACTER(LEN=TBLLEN)  PCV       ! tmp pollutant conversion chars
        CHARACTER(LEN=TBLLEN)  PREVPCV   ! tmp previous pol conversion chars
        CHARACTER(LEN=STALEN3) CSTA      ! tmp Cy/St code
        CHARACTER(LEN=FIPLEN3) CFIP      ! tmp Cy/St/Co code
        CHARACTER(LEN=FIPLEN3) FIPZERO   ! zero Cy/St/Co code
        CHARACTER(LEN=FIPLEN3+SCCLEN3) CFIPSCC   ! Cy/St/Co code // SCC
        CHARACTER(LEN=FIPLEN3+SCCLEN3) PFIPSCC   ! Cy/St/Co code // SCC
        CHARACTER(LEN=SCCLEN3) TSCC      ! tmp SCC
        CHARACTER(LEN=SCCLEN3) TSCL      ! tmp left SCC
        CHARACTER(LEN=SCCLEN3) SCCZERO   ! zero SCC 
        CHARACTER(LEN=FIPLEN3-STALEN3) CYIDZERO ! zero county code
        CHARACTER(LEN=IOVLEN3) IBUF      ! tmp inventory pol name buffer
        CHARACTER(LEN=IOVLEN3) SBUF      ! tmp output    pol name buffer
        CHARACTER(LEN=RWTLEN3) CRWT      ! roadway type no.
        CHARACTER(LEN=VIDLEN3) CVID      ! vehicle type ID no.

        CHARACTER*16 :: PROGNAME = 'RDSCONV' ! program name

C***********************************************************************
C   begin body of subroutine RDSCONV

C.........  Get number of lines in pollutant conversion file for an estimate of
C           the memory required for unsorted arrays
        NLINE = GETFLINE( FDEV, 'Pollutant conversion file' )

C.........  Allocate memory for unsorted arrays
        ALLOCATE( INDX( NLINE ), STAT=IOS )
        CALL CHECKMEM( IOS, 'INDX', PROGNAME )
        ALLOCATE( TYPA( NLINE ), STAT=IOS )
        CALL CHECKMEM( IOS, 'TYPA', PROGNAME )
        ALLOCATE( ISPA( NLINE ), STAT=IOS )
        CALL CHECKMEM( IOS, 'ISPA', PROGNAME )
        ALLOCATE( FACA( NLINE ), STAT=IOS )
        CALL CHECKMEM( IOS, 'FACA', PROGNAME )
        ALLOCATE( PCVA( NLINE ), STAT=IOS )
        CALL CHECKMEM( IOS, 'PCVA', PROGNAME )

C.........  Set up zero strings for FIPS code of zero and SCC code of zero
        FIPZERO  = REPEAT( '0', FIPLEN3 )
        CYIDZERO = REPEAT( '0', FIPLEN3-STALEN3 )
        SCCZERO  = REPEAT( '0', SCCLEN3 )

C.........  Set up column starts and ends
        CS1 = 1
        CE1 = FIPLEN3
        CS2 = CE1 + 2
        CE2 = CS2 + SCCLEN3 - 1
        CS3 = CE2 + 2
        CE3 = CS3 + 4

        MESG = 'Reading pollutant to pollutant conversion file...'
        CALL M3MSG2( MESG )

C.........  Read pollutant pollutants conversion factors file
        STLP1 = STALEN3 + 1
        N    = 0   ! array
        I    = 0
        ISP  = 0
        DO IREC = 1, NLINE !  head of the FDEV-read loop

            READ( FDEV, 93010, END=999, IOSTAT=IOS ) LINE

            IF ( IOS .NE. 0 ) THEN

                EFLAG = .TRUE.
                WRITE( MESG, 94010 )
     &              'I/O error', IOS, 
     &              'reading POLLUTANT CONVERSION at line', IREC
                CALL M3MESG( MESG )
                CYCLE

            END IF

            LINE16 = ADJUSTL( LINE( 1:16 ) )

C.............  Skip blank lines
            IF( LINE .EQ. ' ' ) THEN
                CYCLE

C.............  Check if line is pollutant-to-pollutant indicator or conversion
C               data
            ELSEIF( LINE16( 1:1 ) .GT. '9' ) THEN
                IBUF = LINE16
                SBUF = ADJUSTL( LINE( 18:33 ) )

                ISP = INDEX1( IBUF, NNAM, ENAM )
                IF( ISP .GT. 0 ) THEN
                    OUTNAM( ISP ) = SBUF
                    RFLAG = .TRUE.      ! Okay, read in entries in this section
                ELSE
                    RFLAG = .FALSE.     ! Don't read b/c pollutant not in inven
                ENDIF

C.............  Store data for current record when file's current pollutant is 
C               in ENAM
            ELSEIF( RFLAG ) THEN

                CFIP = ADJUSTR( LINE( CS1:CE1 ) )
                TSCC = LINE( CS2:CE2 )
                CALL PADZERO( TSCC )

                TSCL = TSCC( 1:LSCCEND )

C.................  Determine if SCC is in inventory list
                K1 = FINDC( TSCC, NINVSCC, INVSCC )
                K2 = FINDC( TSCL, NINVSCC, INVSCL )

                IF( K1 .LE. 0 .AND. K2 .LE. 0 ) CYCLE   ! Skip record if SCC not in inventory

                I = I + 1

C.................  Convert SCC to mobile internal standard
                IF( CATEGORY .EQ. 'MOBILE' ) THEN
                    CALL MBSCCADJ( IREC, TSCC, CRWT, CVID, TSCC, EFLAG )

                END IF
   
                WRITE( CPOL, '(I5.5)' ) ISP

                FAC = STR2REAL( LINE( CS3:CE3 ) )

C.................  Scan for default values and pad with zeros
                IF( INDEX( CFIP,'-9' ) .GT. 0 .OR.
     &              CFIP .EQ. ' ' ) CFIP = FIPZERO

                IF( INDEX( TSCC,'-9' ) .GT. 0 .OR.
     &              TSCC .EQ. ' ' ) TSCC = SCCZERO

                CALL PADZERO( CFIP )
                CALL PADZERO( TSCC )

C.................  Determine type of this record, and add to count for this 
C                   type
                IF( TSCC .EQ. SCCZERO ) THEN
                    T = 0
                ELSEIF( CFIP .EQ. FIPZERO ) THEN
                    T = 1
                ELSEIF( CFIP( STLP1:FIPLEN3 ) .EQ. CYIDZERO ) THEN
                    T = 2
                ELSE
                    T = 3
                END IF

C.................  Store all in unsorted arrays
                INDX( I ) = I
                PCVA( I ) = CFIP // TSCC // CPOL
                FACA( I ) = FAC
                TYPA( I ) = T
                ISPA( I ) = ISP

                N( T ) = N( T ) + 1

C.............  Set indicator for writing out warning that some entries were
C               skipped in file. 
            ELSE
                SFLAG = .TRUE.

            END IF

        END DO    ! End read loop of pollutant conversion file

        NCONV = I

        IF( NCONV .EQ. 0 ) THEN

            MESG = 'No pollutant conversion entries found for ' //
     &             'inventory pollutants, ' // CRLF() // BLANK10 //
     &             'or could not find header line(s).  THIS WILL ' //
     &             'MOST LIKELY ' // CRLF() // BLANK10 // 'RESULT '//
     &             'IN INCORRECT EMISSIONS!'
            CALL M3WARN( PROGNAME, 0, 0, MESG )

        END IF

        IF( SFLAG ) THEN
            MESG = 'Records were skipped in pollutant-to-pollutant ' //
     &             'conversion file for ' // CRLF() //
     &             BLANK10 // 'pollutants not in the inventory.'
            CALL M3WARN( PROGNAME, 0, 0, MESG )
        END IF

C.........  Sort records from pollutant conversion file
        CALL SORTIC( NCONV, INDX, PCVA )
         
C.........  Allocate memory for pollutant conversion and initialize to 1.0
        ALLOCATE( CNVFC00( NNAM ), STAT=IOS )
        CALL CHECKMEM( IOS, 'CNVFC00', PROGNAME )
        CNVFC00 = 1.0

        NCNV1 = N( 1 )
        ALLOCATE( CNVFC01( NCNV1, NNAM ), STAT=IOS )
        CALL CHECKMEM( IOS, 'CNVFC01', PROGNAME )
        ALLOCATE( CNVRT01( NCNV1 ), STAT=IOS )
        CALL CHECKMEM( IOS, 'CNVRT01', PROGNAME )
        IF( NCNV1 .GT. 0 ) THEN
            CNVFC01 = 1.0
            CNVRT01 = ' '
        ENDIF

        NCNV2 = N( 2 )
        ALLOCATE( CNVFC02( NCNV2, NNAM ), STAT=IOS )
        CALL CHECKMEM( IOS, 'CNVFC02', PROGNAME )
        ALLOCATE( CNVRT02( NCNV2 ), STAT=IOS )
        CALL CHECKMEM( IOS, 'CNVRT02', PROGNAME )
        IF( NCNV2 .GT. 0 ) THEN
            CNVFC02 = 1.0
            CNVRT02 = ' '
        ENDIF

        NCNV3 = N( 3 )
        ALLOCATE( CNVFC03( NCNV3, NNAM ), STAT=IOS )
        CALL CHECKMEM( IOS, 'CNVFC03', PROGNAME )
        ALLOCATE( CNVRT03( NCNV3 ), STAT=IOS )
        CALL CHECKMEM( IOS, 'CNVRT03', PROGNAME )
        IF( NCNV3 .GT. 0 ) THEN
            CNVFC03 = 1.0
            CNVRT03 = ' '
        ENDIF

C.........  Store pollutant conversion factors in sorted tables
        PFIPSCC = ' '
        N = 0             ! array
        PREVPCV = EMCMISS3
        DO I = 1, NCONV

            J    = INDX( I )
            T    = TYPA( J )
            V    = ISPA( J )
            PCV  = PCVA( J )
            FAC  = FACA( J ) 

            CSTA = PCV(       1:STALEN3 )
            CFIP = PCV(       1:FIPLEN3 )
            TSCC = PCV( PLTPOS3:FPSLEN3 )

            CFIPSCC = CFIP // TSCC

            IF( CFIPSCC .NE. PFIPSCC ) THEN
                N( T ) = N( T ) + 1
                K = N( T )
                PFIPSCC = CFIPSCC
            END IF

            IF( PCV .EQ. PREVPCV ) THEN

                L = LEN_TRIM( ENAM( V ) )

                MESG = 'WARNING: Duplicate entry in pollutant ' //
     &                 'conversion file:' // CRLF() // BLANK10 //
     &                 'FIP: '// CFIP// ' SCC: '// TSCC// ' IN POL: '//
     &                 ENAM( V )( 1:L )// ' OUT POL: ' // OUTNAM( V )
                CALL M3MSG2( MESG )
                CYCLE

            ENDIF

            SELECT CASE( T ) 

            CASE( 0 )
                CNVFC00( V ) = FAC

            CASE( 1 )
                CNVFC01( K,V ) = FAC
                CNVRT01( K   ) = TSCC

            CASE( 2 )
                CNVFC02( K,V ) = FAC
                CNVRT02( K   ) = CSTA // TSCC

            CASE( 3 )
                CNVFC03( K,V ) = FAC
                CNVRT03( K   ) = CFIP // TSCC

            CASE DEFAULT

                EFLAG = .TRUE.
                WRITE( MESG,94010 )
     &                 'INTERNAL ERROR: Pollutant conversion ' // 
     &                 'category', T, 
     &                 'not known in subroutine ' // PROGNAME
                CALL M3MESG( MESG )

            END SELECT

            PREVPCV = PCV

        END DO

        NCNV1 = N( 1 )
        NCNV2 = N( 2 )
        NCNV3 = N( 3 )

C.........  Deallocate temporary sorting arrays
        DEALLOCATE( INDX, PCVA, TYPA, FACA )
        
C.........  Abort for read error
        IF( EFLAG ) THEN

            MESG = 'Problem reading in pollutant conversion file'
            CALL M3EXIT( PROGNAME, 0, 0, MESG, 2 )

        END IF

        RETURN

C.........  Error message for reaching the end of file too soon
999     MESG = 'End of file reached unexpectedly. ' //
     &         'Check format of pollutant ' // CRLF() // BLANK5 //
     &         'to pollutant conversion file.'
        CALL M3EXIT( PROGNAME, 0, 0, MESG, 2 )

C******************  FORMAT  STATEMENTS   ******************************

C...........   Formatted file I/O formats............ 93xx

93010   FORMAT( A )

C...........   Internal buffering formats............ 94xxx

94010   FORMAT( 10 ( A, :, I5, :, 2X ) )

94020   FORMAT( A, I8, 2X, 10 ( A, :, E10.3, :, 1X ) )


        END


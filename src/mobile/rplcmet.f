
        SUBROUTINE RPLCMET( CTYPOS, NSCEN, NLINES, SCENARIO, STSCEN )

C***********************************************************************
C  subroutine body starts at line 75
C
C  DESCRIPTION:
C       Replaces humidity and barometric pressure values in the MOBILE6 
C       input file with values from Premobl
C
C  PRECONDITIONS REQUIRED:
C
C  SUBROUTINES AND FUNCTIONS CALLED:  none
C
C  REVISION  HISTORY:
C     10/01: Created by C. Seppanen
C
C***********************************************************************
C
C Project Title: Sparse Matrix Operator Kernel Emissions (SMOKE) Modeling
C                System
C File: @(#)$Id$
C
C COPYRIGHT (C) 2002, MCNC Environmental Modeling Center
C All Rights Reserved
C
C See file COPYRIGHT for conditions of use.
C
C Environmental Modeling Center
C MCNC
C P.O. Box 12889
C Research Triangle Park, NC  27709-2889
C
C smoke@emc.mcnc.org
C
C Pathname: $Source$
C Last updated: $Date$ 
C
C***********************************************************************
        
C.........  MODULES for public variables
C.........  This module is the derived meteorology data for emission factors
        USE MODMET, ONLY: RHHOUR, BPDAY
        
        IMPLICIT NONE

C...........   INCLUDES:

C...........   EXTERNAL FUNCTIONS and their descriptions:
        CHARACTER(LEN=2)  CRLF    
        
        EXTERNAL  CRLF

C...........   SUBROUTINE ARGUMENTS
        INTEGER,            INTENT (IN)    :: CTYPOS             ! position of county in arrays
        INTEGER,            INTENT (INOUT) :: NSCEN              ! no. actual lines in scenario
        INTEGER,            INTENT (IN)    :: NLINES             ! no. lines in scenario array
        CHARACTER(LEN=150), INTENT (INOUT) :: SCENARIO( NLINES ) ! scenario array
        INTEGER,            INTENT (INOUT) :: STSCEN             ! start of scenario level commandsit

C...........   Local allocatable arrays

C...........   Other local variables
        INTEGER I                         ! counters and indices                     
        INTEGER RHPOS                     ! position to insert relative humidity command
        INTEGER BPPOS                     ! position to insert barometric pressure command
        
        INTEGER IOS                       ! I/O status

        CHARACTER(LEN=150) CURRLINE           ! current line from scenario
        CHARACTER(LEN=150) RPLCLINE           ! replacement line
        CHARACTER(LEN=19)  COMMAND            ! Mobile 6 command        
        CHARACTER(LEN=300) MESG               !  message buffer

        CHARACTER*16 :: PROGNAME = 'RPLCMET'  ! program name
        
C***********************************************************************
C   begin body of subroutine RPLCMET
        
        RHPOS = 0
        BPPOS = 0
        
        DO I = 1, NSCEN
        
            CURRLINE = SCENARIO( I )

C.............  Skip comment and blank lines
            IF( CURRLINE( 1:1 ) == '*' ) CYCLE
            IF( CURRLINE( 1:1 ) == '>' ) CYCLE
            IF( CURRLINE == ' ' ) CYCLE
            
C.............  Get Mobile6 command                   
            COMMAND = CURRLINE( 1:19 )            

C.............  Comment out absolute humidity command
            IF( INDEX( COMMAND, 'ABSOLUTE HUMIDITY' ) > 0 ) THEN
            	RPLCLINE( 1:1 ) = '*'
            	RPLCLINE( 2:150 ) = CURRLINE( 1:149 )
            	SCENARIO( I ) = RPLCLINE
            END IF

C.............  Check for relative humidity command                	     
            IF( INDEX( COMMAND, 'RELATIVE HUMIDITY' ) > 0 ) THEN
                RHPOS = I
            END IF
            
C.............  Check for barometric pressure command
            IF( INDEX( COMMAND, 'BAROMETRIC PRES' ) > 0 ) THEN
                BPPOS = I
            END IF

        END DO

C.........  If humidity or pressure commands weren't found, stick them at
C           the end of the scenario 
        IF( RHPOS == 0 ) THEN
            RHPOS = NSCEN
            
            NSCEN = NSCEN + 2
        END IF
        
        IF( BPPOS == 0 ) THEN
            BPPOS = NSCEN
            
            NSCEN = NSCEN + 1
        END IF

C.........  Create humidity and pressure commands        
        WRITE( RPLCLINE,94020 )
     &      'RELATIVE HUMIDITY  : ', RHHOUR( CTYPOS,1:12 )
        SCENARIO( RHPOS ) = RPLCLINE
        
        WRITE( RPLCLINE,94030 ) RHHOUR( CTYPOS,13:24 )
        SCENARIO( RHPOS + 1 ) = RPLCLINE
        
        WRITE( RPLCLINE,94040 ) 'BAROMETRIC PRES    : ', BPDAY( CTYPOS )
        SCENARIO( BPPOS ) = RPLCLINE

C******************  FORMAT  STATEMENTS   ******************************

C...........   Formatted file I/O formats............ 93xxx

93000   FORMAT( A )

C...........   Internal buffering formats............ 94xxx

94010   FORMAT( 10( A, :, I8, :, 1X ) )
94020   FORMAT( A21, 12( 1X, F5.1 ) )
94030   FORMAT( 12( F5.1, :, 1X ) )
94040   FORMAT( A21, 1X, F5.2 )
        
        END SUBROUTINE RPLCMET
        

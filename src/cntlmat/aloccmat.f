
        SUBROUTINE ALOCCMAT( NGRP, NGSZ )

C***********************************************************************
C  subroutine body starts at line 
C
C  DESCRIPTION:
C      This subroutine allocates memory for the pol/act-specific indices
C      for each source to the control data tables, and the arrays for the
C      output control matrices.
C      
C  PRECONDITIONS REQUIRED:
C
C  SUBROUTINES AND FUNCTIONS CALLED:
C
C  REVISION  HISTORY:
C     Created 3/99 by M. Houyoux
C
C****************************************************************************/
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
C***************************************************************************

C.........  MODULES for public variables
C.........  This module is for cross reference tables
        USE MODXREF, ONLY:

C.........  This module contains the control packet data and control matrices
        USE MODCNTRL, ONLY:

C.........  This module contains the information about the source category
        USE MODINFO, ONLY: NSRC, NIPPA

        IMPLICIT NONE

C...........   INCLUDES
        INCLUDE 'EMCNST3.EXT'   !  emissions constant parameters

C...........   EXTERNAL FUNCTIONS:
        CHARACTER*2   CRLF
        EXTERNAL      CRLF

C...........   SUBROUTINE ARGUMENTS:

        INTEGER     , INTENT (OUT) :: NGRP     ! number of sources
        INTEGER     , INTENT (OUT) :: NGSZ     ! year to project to

C...........   Other local variables
        
        INTEGER   :: IOS1 = 0           ! i/o status
        INTEGER   :: IOS2 = 0           ! i/o status
        INTEGER   :: IOS3 = 0           ! i/o status
        INTEGER   :: IOS4 = 0           ! i/o status
        INTEGER   :: IOS5 = 0           ! i/o status
        INTEGER   :: IOS6 = 0           ! i/o status
        INTEGER   :: MEM                ! tmp memory requirement

        LOGICAL, SAVE :: FIRSTIME = .TRUE.  ! true: first time subroutine called
        LOGICAL       :: GFLAG    = .FALSE. ! true: CTG cntl packet exists
        LOGICAL       :: CFLAG    = .FALSE. ! true: CONTROL cntl packet exists
        LOGICAL       :: LFLAG    = .FALSE. ! true: ALLOWABLE cntl packet exists
        LOGICAL       :: PFLAG    = .FALSE. ! true: PROJECTION packet exists

        CHARACTER*300   MESG        ! message buffer

        CHARACTER*16 :: PROGNAME = 'ALOCCMAT' ! program name

C***********************************************************************
C   begin body of subroutine ALOCCMAT

        IF( FIRSTIME ) THEN

            FIRSTIME = .FALSE.

C.............  Determine which packets are present based on allocation of data
C               tables
            GFLAG = ALLOCATED( CUTCTG )
            CFLAG = ALLOCATED( FACCEFF )
            LFLAG = ALLOCATED( FACALW )
            PFLAG = ALLOCATED( PRJFC )

            NGSZ = NIPPA   ! Number of pollutant/activity in each group
            NGRP = 1       ! Number of groups
            DO

                IF( GFLAG ) ALLOCATE( CTGIDX( NSRC, NGSZ ), STAT=IOS1 )
                IF( CFLAG ) ALLOCATE( CTLIDX( NSRC, NGSZ ), STAT=IOS2 )
                IF( LFLAG ) ALLOCATE( ALWIDX( NSRC, NGSZ ), STAT=IOS3 )
                IF( PFLAG ) ALLOCATE( PRJIDX( NSRC, NGSZ ), STAT=IOS4 )

                IF( IOS1 .GT. 0 .OR. IOS2 .GT. 0 .OR. IOS3 .GT. 0 .OR.
     &              IOS4 .GT. 0  ) THEN

                    IF( NGSZ .EQ. 1 ) THEN
                        MEM = 8 * NSRC * 31    ! Assume 8-byte reals
                        WRITE( MESG,94010 ) 
     &                    'Insufficient memory to run program.' //
     &                    CRLF() // BLANK5 // 'Could not allocate ' // 
     &                    'pol/act-dependent block of', MEM, 'bytes.'
                        CALL M3EXIT( PROGNAME, 0, 0, MESG, 2 )
                    END IF

                    NGRP = NGRP + 1
                    NGSZ = NGSZ / NGRP + ( NIPPA - NGSZ * NGRP )

                    DEALLOCATE( CTGIDX, CTLIDX, ALWIDX, PRJIDX )

                ELSE
                    EXIT

                ENDIF

            ENDDO

        END IF

        RETURN

C******************  FORMAT  STATEMENTS   ******************************

C...........   Internal buffering formats............ 94xxx

94010   FORMAT( 10( A, :, I8, :, 1X ) )

        END SUBROUTINE ALOCCMAT

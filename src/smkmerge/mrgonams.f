
        SUBROUTINE MRGONAMS

C***********************************************************************
C  subroutine MRGONAMS body starts at line
C
C  DESCRIPTION:
C      The purpose of this subroutine is to set the default names of the
C      output files. It sets them regardless of whether they will be used
C      or not.
C
C  PRECONDITIONS REQUIRED:  
C
C  SUBROUTINES AND FUNCTIONS CALLED:
C
C  REVISION  HISTORY:
C       Created 2/99 by M. Houyoux
C
C***********************************************************************
C
C Project Title: Sparse Matrix Operator Kernel Emissions (SMOKE) Modeling
C                System
C File: @(#)$Id$
C
C COPYRIGHT (C) 2000, MCNC--North Carolina Supercomputing Center
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
C****************************************************************************

C.........  MODULES for public variables
C.........  This module contains the major data structure and control flags
        USE MODMERGE

        IMPLICIT NONE

        INTEGER         I, J    ! indices and counters

        LOGICAL      :: MOLEFLAG = .FALSE.       ! true: outputting moles
        CHARACTER*300   MESG    ! message buffer

        CHARACTER*16 :: PROGNAME = 'MRGONAMS' ! program name

C***********************************************************************
C   begin body of subroutine MRGONAMS

C.........  Set default output file name(s) depending on inputs.  Set both
C           report file(s) and gridded file(s)...

C.........  Initialize - everything will be gridded

        AREPNAME = 'REPAG'
        BREPNAME = 'REPBG'
        MREPNAME = 'REPMG'
        PREPNAME = 'REPPG'
        TREPNAME = 'REPEG'

        AONAME = 'AG'
        BONAME = 'BGTS'
        MONAME = 'MG'
        PONAME = 'PG'
        TONAME = 'EG'

        PINGNAME = 'PING'
        PELVNAME = 'ELEV'

        IF( TFLAG ) THEN

            CALL TRIM_AND_CONCAT( AREPNAME, 'T' )
            CALL TRIM_AND_CONCAT( BREPNAME, 'T' )
            CALL TRIM_AND_CONCAT( MREPNAME, 'T' )
            CALL TRIM_AND_CONCAT( PREPNAME, 'T' )
            CALL TRIM_AND_CONCAT( TREPNAME, 'T' )

            CALL TRIM_AND_CONCAT( AONAME, 'T' )
            CALL TRIM_AND_CONCAT( MONAME, 'T' )
            CALL TRIM_AND_CONCAT( PONAME, 'T' )
            CALL TRIM_AND_CONCAT( TONAME, 'T' )
            CALL TRIM_AND_CONCAT( PINGNAME, 'T' )
            CALL TRIM_AND_CONCAT( PELVNAME, 'T' )

        END IF

        IF( SFLAG ) THEN

            IF( LREPSPC ) THEN
                CALL TRIM_AND_CONCAT( AREPNAME, 'S' )
                CALL TRIM_AND_CONCAT( BREPNAME, 'S' )
                CALL TRIM_AND_CONCAT( MREPNAME, 'S' )
                CALL TRIM_AND_CONCAT( PREPNAME, 'S' )
                CALL TRIM_AND_CONCAT( TREPNAME, 'S' )
            ENDIF

            CALL TRIM_AND_CONCAT( AONAME, 'S' )
            CALL TRIM_AND_CONCAT( MONAME, 'S' )
            CALL TRIM_AND_CONCAT( PONAME, 'S' )
            CALL TRIM_AND_CONCAT( TONAME, 'S' )
            CALL TRIM_AND_CONCAT( PINGNAME, 'S' )
            CALL TRIM_AND_CONCAT( PELVNAME, 'S' )

        END IF

        IF( AUFLAG .OR. AAFLAG .OR. ARFLAG ) THEN

            IF( LREPCTL ) THEN
                CALL TRIM_AND_CONCAT( AREPNAME, 'C' )
            END IF

            CALL TRIM_AND_CONCAT( AONAME, 'C' )

        END IF

        IF( MUFLAG .OR. MAFLAG .OR. MRFLAG ) THEN

            IF( LREPCTL ) THEN
                CALL TRIM_AND_CONCAT( MREPNAME, 'C' )
            END IF

            CALL TRIM_AND_CONCAT( MONAME, 'C' )

        END IF

        IF( PUFLAG .OR. PAFLAG .OR. PRFLAG ) THEN

            IF( LREPCTL ) THEN
                CALL TRIM_AND_CONCAT( PREPNAME, 'C' )
            END IF

            CALL TRIM_AND_CONCAT( PONAME, 'C' )

        END IF

        IF( AUFLAG .OR. AAFLAG .OR. ARFLAG .OR.
     &      MUFLAG .OR. MAFLAG .OR. MRFLAG .OR.
     &      PUFLAG .OR. PAFLAG .OR. PRFLAG     ) THEN
            IF( LREPCTL ) THEN
                CALL TRIM_AND_CONCAT( TREPNAME, 'C' )
            END IF

        END IF

        IF( LFLAG ) THEN

            CALL TRIM_AND_CONCAT( PONAME, '3D' )
            CALL TRIM_AND_CONCAT( TONAME, '3D' )

        END IF

C.........  Now append mass or mole for I/O API files, depending on which
C           inputs were used
        IF( SFLAG ) THEN

C.............  Set flag if any of the output species are mole-based
            DO I = 1, NIPPA
            
                J = INDEX( GRDUNIT( I ), 'mole' )
                IF( J .GT. 0 ) THEN
                    MOLEFLAG = .TRUE.
                    EXIT
                END IF

            END DO

C.............  Get output file names depending on if there are moles in units
            IF( MOLEFLAG ) THEN 

                CALL TRIM_AND_CONCAT( AREPNAME, '_L' )
                CALL TRIM_AND_CONCAT( BREPNAME, '_L' )
                CALL TRIM_AND_CONCAT( MREPNAME, '_L' )
                CALL TRIM_AND_CONCAT( PREPNAME, '_L' )
                CALL TRIM_AND_CONCAT( TREPNAME, '_L' )

                CALL TRIM_AND_CONCAT( AONAME, '_L' )
                CALL TRIM_AND_CONCAT( BONAME, '_L' )
                CALL TRIM_AND_CONCAT( MONAME, '_L' )
                CALL TRIM_AND_CONCAT( PONAME, '_L' )
                CALL TRIM_AND_CONCAT( TONAME, '_L' )
                CALL TRIM_AND_CONCAT( PINGNAME, '_L' )
                CALL TRIM_AND_CONCAT( PELVNAME, '_L' )

            ELSE 

                CALL TRIM_AND_CONCAT( AREPNAME, '_S' )
                CALL TRIM_AND_CONCAT( BREPNAME, '_S' )
                CALL TRIM_AND_CONCAT( MREPNAME, '_S' )
                CALL TRIM_AND_CONCAT( PREPNAME, '_S' )
                CALL TRIM_AND_CONCAT( TREPNAME, '_S' )

                CALL TRIM_AND_CONCAT( AONAME, '_S' )
                CALL TRIM_AND_CONCAT( BONAME, '_S' )
                CALL TRIM_AND_CONCAT( MONAME, '_S' )
                CALL TRIM_AND_CONCAT( PONAME, '_S' )
                CALL TRIM_AND_CONCAT( TONAME, '_S' )
                CALL TRIM_AND_CONCAT( PINGNAME, '_S' )
                CALL TRIM_AND_CONCAT( PELVNAME, '_S' )

            END IF

        END IF

        RETURN

C******************  INTERNAL SUBPROGRAMS  *****************************
 
        CONTAINS
 
C.............  This internal subprogram trims and concatonates the first
C               string with the second string
            SUBROUTINE TRIM_AND_CONCAT( PART1, PART2 )

C.............  Subprogram arguments
            CHARACTER(*)  PART1
            CHARACTER(*)  PART2

C.............  Local variables
            INTEGER       L

C----------------------------------------------------------------------

            L = LEN_TRIM( PART1 )
            PART1 = PART1( 1:L ) // PART2
 
            END SUBROUTINE TRIM_AND_CONCAT

        END SUBROUTINE MRGONAMS


        SUBROUTINE TMNAMUNT

C***********************************************************************
C  subroutine body starts at line 
C
C  DESCRIPTION:
C       This program creates the temporal emissions output file variable names
C       and associated activities and a flag for diurnal or non-diurnal emission
C       factors, where needed.   It also sets the units and conversion
C       factors for creating the output emission values.
C
C  PRECONDITIONS REQUIRED:
C
C  SUBROUTINES AND FUNCTIONS CALLED:
C
C  REVISION  HISTORY:
C     Created 10/99 by M. Houyoux
C
C****************************************************************************/
C
C Project Title: Sparse Matrix Operator Kernel Emissions (SMOKE) Modeling
C                System
C File: @(#)$Id$
C
C COPYRIGHT (C) 1999, MCNC--North Carolina Supercomputing Center
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
C***************************************************************************

C.........  MODULES for public variables
C.........  This module contains emission factor tables and related
        USE MODEMFAC

C.........  This module contains the information about the source category
        USE MODINFO

        IMPLICIT NONE

C...........   INCLUDES
        INCLUDE 'EMCNST3.EXT'   !  emissions constant parameters

C...........   EXTERNAL FUNCTIONS and their descriptions:
        INTEGER   INDEX1
        CHARACTER(LEN=IOULEN3) MULTUNIT
        REAL                   UNITFAC 

        EXTERNAL     INDEX1, MULTUNIT, UNITFAC

C...........   Other local variables
        INTEGER         I, J, K, L, M     !  counters and indices

        INTEGER         IOS               !  i/o status

        REAL            FAC1, FAC2        ! tmp conversion factors

        LOGICAL      :: EFLAG = .FALSE.   ! true: error found

        CHARACTER*300          MESG       !  message buffer
        CHARACTER(LEN=IOVLEN3) CBUF       !  tmp variable name

        CHARACTER*16 :: PROGNAME = 'TMNAMUNT' ! program name

C***********************************************************************
C   begin body of subroutine TMNAMUNT

C.........  Allocate memory for the names of the emission types and associated
C           arrays for all activities in the inventory
        ALLOCATE( EMTUNT( MXETYPE, NIACT ), STAT=IOS )
        CALL CHECKMEM( IOS, 'EMTUNT', PROGNAME )
        ALLOCATE( EMTDSC( MXETYPE, NIACT ), STAT=IOS )
        CALL CHECKMEM( IOS, 'EMTDSC', PROGNAME )
        ALLOCATE( EMTEFT( MXETYPE, NIACT ), STAT=IOS )
        CALL CHECKMEM( IOS, 'EMTEFT', PROGNAME )

C.........  Allocate memory for units conversions for inventory pollutants and
C           activities (stored in MODINFO)
        ALLOCATE( EACNV( NIPPA ), STAT=IOS )
        CALL CHECKMEM( IOS, 'EACNV', PROGNAME )

C.........  Initialize arrays
        EMTUNT = ' '  ! array
        EMTDSC = ' '  ! array
        EMTEFT = ' '  ! array

C.........  Loop through the emission types for each activity and determine 
C           their associated emission factors and units for emission factors
C.........  Also, for each pollutant or activity, store the output units and
C           conversion factor to ton/hr (required output units from Temporal)
C.........  The hours adjustment is part of the temporal allocation, which
C           assumes that the input data are annual data. So, if not, add the
C           conversion to annual data here.
        DO I = 1, NIACT

            M = INDEX1( ACTVTY( I ), NIPPA, EANAM )

            DO K = 1, NETYPE( I )

C.................  Search for emission type in non-diurnal emission factors
                J = INDEX1( EMTNAM( K,I ), NNDI, NDINAM )

C.................  Store info if this emissions type is non-diurnal
C.................  For the units, multiply the emission factor units with the
C                   activity units
                IF( J .GT. 0 ) THEN
                    L = INDEX( NDIDSC( J ), 'for' )

C.....................  Store for emission types
                    EMTUNT( K,I ) = MULTUNIT( NDIUNT( J ), EAUNIT( M ) )
                    EMTDSC( K,I ) = NDIDSC( J )( L+3:DSCLEN3 )
                    EMTEFT( K,I ) = 'N'

                END IF

C.................  Search for emission type in diurnal emission factors
                J = INDEX1( EMTNAM( K,I ), NDIU, DIUNAM )

C.................  Store info if this emissions type is diurnal
C.................  For the units, multiply the emission factor units with the
C                   activity units
                IF( J .GT. 0 ) THEN
                    L = INDEX( DIUDSC( J ), 'for' )

                    EMTUNT( K,I ) = MULTUNIT( DIUUNT( J ), EAUNIT( M ) )
                    EMTDSC( K,I ) = DIUDSC( J )( L+3:DSCLEN3 )
                    EMTEFT( K,I ) = 'D'

                END IF

C.................  If emission type has not been associated with an emission
C                   factor, then error
                IF( EMTEFT( K,I ) .EQ. ' ' ) THEN

                    EFLAG = .TRUE.
                    L = LEN_TRIM( EMTNAM( K,I ) )
                    MESG = 'ERROR: Emission type "' // 
     &                     EMTNAM( K,I )( 1:L ) // '" could not be '//
     &                     'associated with an emission factor!'
                    CALL M3MSG2( MESG )

                END IF

            END DO     ! End of loop through emission types

C.............  Store units and convversion factors for activities and output
C.............  NOTE - this assumes that the units of all emission types
C               from one activity are the same.
            CBUF = EMTUNT( 1,I )
            FAC1 = UNITFAC( CBUF, 'ton', .TRUE. )
            FAC2 = UNITFAC( EAUNIT( M ), '1/yr', .FALSE. )

            EAUNIT( M ) = 'ton/hr'
            EACNV ( M ) = FAC1 / FAC2

        END DO         ! End of loop through activities

C.........  Now loop through pollutants and create units and conversion factors
        DO I = 1, NIPOL

            M = INDEX1( EINAM( I ), NIPPA, EANAM )
            
            CBUF = EAUNIT ( M )
            FAC1 = UNITFAC( CBUF, 'ton', .TRUE. )
            FAC2 = UNITFAC( EAUNIT( M ), '1/yr', .FALSE. )

            EAUNIT( M ) = 'ton/hr'
            EACNV ( M ) = FAC1 / FAC2

        END DO

C.........  Abort if error was found
        IF ( EFLAG ) THEN
            MESG = 'Problem with emission types or emission factors'
            CALL M3EXIT( PROGNAME, 0, 0, MESG, 2 )

        END IF

        RETURN

C******************  FORMAT  STATEMENTS   ******************************

C...........   Internal buffering formats............ 94xxx

94010   FORMAT( 10( A, :, I8, :, 1X ) )

        END SUBROUTINE TMNAMUNT

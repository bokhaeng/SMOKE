
        SUBROUTINE HOURTEMP( NSRC, JTIME, DAYBEGT, VALBYSRC, 
     &                       HOUROUT )

C***********************************************************************
C  subroutine HOURTEMP body starts at line < >
C
C  DESCRIPTION:
C
C  PRECONDITIONS REQUIRED:
C
C  SUBROUTINES AND FUNCTIONS CALLED:
C
C  REVISION HISTORY:
C
C***************************************************************************
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
C****************************************************************************

        IMPLICIT NONE

C...........   INCLUDES:
        INCLUDE 'PARMS3.EXT'    !  I/O API parameters

C...........   SUBROUTINE ARGUMENTS
        INTEGER, INTENT    (IN) :: NSRC                  ! no. sources
        INTEGER, INTENT    (IN) :: JTIME                 ! HHMMSS
        INTEGER, INTENT    (IN) :: DAYBEGT ( NSRC )      ! begin. time for day
        REAL   , INTENT    (IN) :: VALBYSRC( NSRC )      ! per-source values
        REAL   , INTENT(IN OUT) :: HOUROUT ( NSRC,0:23 ) ! hourly temp per source 

C...........   Other local variables
        INTEGER     S           ! counters and indices
        INTEGER     TIMESLOT    ! array location

        REAL        VAL         ! tmp value

        LOGICAL, SAVE :: INITIAL = .TRUE.  ! true: first time

        CHARACTER*16 :: PROGNAME = 'HOURTEMP' ! program name

C***********************************************************************
C   begin body of subroutine HOURTEMP

C.........  For the first time, initialize all entries to zero
        IF( INITIAL ) THEN
            HOUROUT = 0.  ! array
            INITIAL = .FALSE.
        END IF

C.........  Loop through sources
        DO S = 1, NSRC

            VAL = VALBYSRC( S )

C.............  Store temperature value in appropriate time slot in output array

            IF( VAL > AMISS3 )THEN

C.................  Appropriate time will be day starting time (in local time
C                   zone ) subtracted from met data time (in GMT)
                TIMESLOT = (JTIME - DAYBEGT( S )) / 10000
                
C.................  If less than zero, add 24 hours                
                IF( TIMESLOT < 0 ) THEN
                    TIMESLOT = TIMESLOT + 24
                END IF

                HOUROUT( S,TIMESLOT ) = VAL

            END IF

        END DO

        RETURN

C******************  FORMAT  STATEMENTS   ******************************

C...........   Internal buffering formats............ 94xxx

94010   FORMAT( 10( A, :, I9, :, 1X ) )
 
        END SUBROUTINE HOURTEMP

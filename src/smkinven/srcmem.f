        SUBROUTINE SRCMEM( CATEGORY, SORTTYPE, AFLAG, PFLAG, NDIM1, 
     &                     NDIM2, NDIM3 )

C***********************************************************************
C  subroutine body starts at line 
C
C  DESCRIPTION:
C
C  PRECONDITIONS REQUIRED:
C
C  SUBROUTINES AND FUNCTIONS CALLED:
C
C  REVISION  HISTORY:
C      Created 10/98 by M. Houyoux
C
C****************************************************************************/
C
C Project Title: Sparse Matrix Operator Kernel Emissions (SMOKE) Modeling
C                System
C File: @(#)$Id$
C
C COPYRIGHT (C) 1998, MCNC--North Carolina Supercomputing Center
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

C...........   MODULES for public variables
C...........   This module is the inventory arrays
        USE MODSOURC 

        IMPLICIT NONE

C...........   SUBROUTINE ARGUMENTS
        CHARACTER(*), INTENT (IN) :: CATEGORY  ! source category
        CHARACTER(*), INTENT (IN) :: SORTTYPE  ! sorted or unsorted
        LOGICAL     , INTENT (IN) :: AFLAG     ! true: allocate
        LOGICAL     , INTENT (IN) :: PFLAG     ! true: act on pollutant-spec
        INTEGER     , INTENT (IN) :: NDIM1     ! dim for non-pol-spec arrays
        INTEGER     , INTENT (IN) :: NDIM2     ! dim 1 for pol-spec arrays
        INTEGER     , INTENT (IN) :: NDIM3     ! dim 2 for pol-spec arrays

C...........   Other local variables
        INTEGER         IOS    ! memory allocation status

        LOGICAL         UFLAG  ! true: allocate non-pollutant variables

        CHARACTER*300   MESG

        CHARACTER*16 :: PROGNAME =  'SRCMEM' ! program name

C***********************************************************************
C   begin body of subroutine SRCMEM

        UFLAG = ( AFLAG .AND. .NOT. PFLAG )

        SELECT CASE ( SORTTYPE )

C......... Unsorted...
        CASE( 'UNSORTED' )

C.............  Allocate variables irrspeective of PFLAG
            IF( UFLAG .AND. .NOT. ALLOCATED( INDEXA ) ) THEN
                ALLOCATE( INDEXA( NDIM2 ), STAT=IOS )
                CALL CHECKMEM( IOS, 'INDEXA', PROGNAME )
            END IF

C.............  Allocate for any source category
            IF( UFLAG .AND. .NOT. ALLOCATED( IFIPA ) ) THEN
                ALLOCATE( IFIPA( NDIM1 ), STAT=IOS )
                CALL CHECKMEM( IOS, 'IFIPA', PROGNAME )
            END IF

            IF( UFLAG .AND. .NOT. ALLOCATED( TPFLGA ) ) THEN
                ALLOCATE( TPFLGA( NDIM1 ), STAT=IOS )
                CALL CHECKMEM( IOS, 'TPFLGA', PROGNAME )
            END IF

            IF( UFLAG .AND. .NOT. ALLOCATED( INVYRA ) ) THEN
                ALLOCATE( INVYRA( NDIM1 ), STAT=IOS )
                CALL CHECKMEM( IOS, 'INVYRA', PROGNAME )
            END IF
 
            IF( UFLAG .AND. .NOT. ALLOCATED( CSCCA ) ) THEN
                ALLOCATE( CSCCA( NDIM1 ), STAT=IOS )
                CALL CHECKMEM( IOS, 'CSCCA', PROGNAME )
            END IF

            IF( UFLAG .AND. .NOT. ALLOCATED( SRCIDA ) ) THEN
                ALLOCATE( SRCIDA( NDIM2 ), STAT=IOS )
                CALL CHECKMEM( IOS, 'SRCIDA', PROGNAME )
            END IF
 
            IF( UFLAG .AND. .NOT. ALLOCATED( IPOSCOD ) ) THEN
                ALLOCATE( IPOSCOD( NDIM2 ), STAT=IOS )
                CALL CHECKMEM( IOS, 'IPOSCOD', PROGNAME )
            END IF

            IF( UFLAG .AND. .NOT. ALLOCATED( CSOURCA ) ) THEN
                ALLOCATE( CSOURCA( NDIM2 ), STAT=IOS )
                CALL CHECKMEM( IOS, 'CSOURCA', PROGNAME )
            END IF

            IF( PFLAG .AND. AFLAG .AND. .NOT. ALLOCATED( POLVLA ) ) THEN
                ALLOCATE( POLVLA( NDIM2, NDIM3 ), STAT=IOS )
                CALL CHECKMEM( IOS, 'POLVLA', PROGNAME )
            END IF

C.............  Deallocate for any source category
            IF( .NOT. AFLAG .AND. .NOT. PFLAG ) THEN
                IF( ALLOCATED( IFIPA )   ) DEALLOCATE( IFIPA )
                IF( ALLOCATED( TPFLGA )  ) DEALLOCATE( TPFLGA )
                IF( ALLOCATED( INVYRA )  ) DEALLOCATE( INVYRA )
                IF( ALLOCATED( CSCCA )   ) DEALLOCATE( CSCCA )
                IF( ALLOCATED( CSOURCA ) ) DEALLOCATE( CSOURCA )

            ELSE IF( .NOT. AFLAG ) THEN
                 IF( ALLOCATED( INDEXA  ) ) DEALLOCATE( INDEXA )
                 IF( ALLOCATED( SRCIDA  ) ) DEALLOCATE( SRCIDA )
                 IF( ALLOCATED( POLVLA  ) ) DEALLOCATE( POLVLA )

            END IF               

C.............  Allocate specifically based on source category
            SELECT CASE( CATEGORY )
            CASE( 'AREA' )
            CASE( 'MOBILE' )
 
            CASE( 'POINT' )
 
                IF( UFLAG .AND. .NOT. ALLOCATED( ISICA ) ) THEN
                    ALLOCATE( ISICA( NDIM1 ), STAT=IOS )
                    CALL CHECKMEM( IOS, 'ISICA', PROGNAME )
                END IF
 
                IF( UFLAG .AND. .NOT. ALLOCATED( IORISA ) ) THEN
                    ALLOCATE( IORISA( NDIM1 ), STAT=IOS )
                    CALL CHECKMEM( IOS, 'IORISA', PROGNAME )
                END IF
 
                IF( UFLAG .AND. .NOT. ALLOCATED( IDIUA ) ) THEN
                    ALLOCATE( IDIUA( NDIM1 ), STAT=IOS )
                    CALL CHECKMEM( IOS, 'IDIUA', PROGNAME )
                END IF
 
                IF( UFLAG .AND. .NOT. ALLOCATED( IWEKA ) ) THEN
                    ALLOCATE( IWEKA( NDIM1 ), STAT=IOS )
                    CALL CHECKMEM( IOS, 'IWEKA', PROGNAME )
                END IF
 
                IF( UFLAG .AND. .NOT. ALLOCATED( SRCIDA ) ) THEN
                    ALLOCATE( SRCIDA( NDIM1 ), STAT=IOS )
                    CALL CHECKMEM( IOS, 'SRCIDA', PROGNAME )
                END IF
 
                IF( UFLAG .AND. .NOT. ALLOCATED( XLOCAA ) ) THEN
                    ALLOCATE( XLOCAA( NDIM1 ), STAT=IOS )
                    CALL CHECKMEM( IOS, 'XLOCAA', PROGNAME )
                END IF
 
                IF( UFLAG .AND. .NOT. ALLOCATED( YLOCAA ) ) THEN
                    ALLOCATE( YLOCAA( NDIM1 ), STAT=IOS )
                    CALL CHECKMEM( IOS, 'YLOCAA', PROGNAME )
                END IF
 
                IF( UFLAG .AND. .NOT. ALLOCATED( STKHTA ) ) THEN
                    ALLOCATE( STKHTA( NDIM1 ), STAT=IOS )
                    CALL CHECKMEM( IOS, 'STKHTA', PROGNAME )
                END IF
 
                IF( UFLAG .AND. .NOT. ALLOCATED( STKDMA ) ) THEN
                    ALLOCATE( STKDMA( NDIM1 ), STAT=IOS )
                    CALL CHECKMEM( IOS, 'STKDMA', PROGNAME )
                END IF
 
                IF( UFLAG .AND. .NOT. ALLOCATED( STKTKA) ) THEN
                    ALLOCATE( STKTKA( NDIM1 ), STAT=IOS )
                    CALL CHECKMEM( IOS, 'STKTKA', PROGNAME )
                END IF
 
                IF( UFLAG .AND. .NOT. ALLOCATED( STKVEA ) ) THEN
                    ALLOCATE( STKVEA( NDIM1 ), STAT=IOS )
                    CALL CHECKMEM( IOS, 'STKVEA', PROGNAME )
                END IF
 
                IF( UFLAG .AND. .NOT. ALLOCATED( CBLRIDA ) ) THEN
                    ALLOCATE( CBLRIDA( NDIM1 ), STAT=IOS )
                    CALL CHECKMEM( IOS, 'CBLRIDA', PROGNAME )
                END IF
 
                IF( UFLAG .AND. .NOT. ALLOCATED( CPDESCA ) ) THEN
                    ALLOCATE( CPDESCA( NDIM1 ), STAT=IOS )
                    CALL CHECKMEM( IOS, 'CPDESCA', PROGNAME )
                END IF

                IF( .NOT. PFLAG .AND. 
     &              .NOT. AFLAG .AND. ALLOCATED( ISICA ) ) 
     &              DEALLOCATE( ISICA, IORISA, IDIUA, IWEKA, SRCIDA, 
     &                          XLOCAA, YLOCAA, STKHTA, STKDMA, STKTKA,  
     &                          STKVEA, CBLRIDA, CPDESCA )

            CASE DEFAULT

            END SELECT  ! select category

C.........  Sorted ...
        CASE( 'SORTED' )

            IF( UFLAG .AND. .NOT. ALLOCATED( IFIP ) ) THEN
                ALLOCATE( IFIP( NDIM1 ), STAT=IOS )
                CALL CHECKMEM( IOS, 'IFIP', PROGNAME )
            END IF

            IF( UFLAG .AND. .NOT. ALLOCATED( TPFLAG ) ) THEN
                ALLOCATE( TPFLAG( NDIM1 ), STAT=IOS )
                CALL CHECKMEM( IOS, 'TPFLAG', PROGNAME )
            END IF

            IF( UFLAG .AND. .NOT. ALLOCATED( INVYR ) ) THEN
                ALLOCATE( INVYR( NDIM1 ), STAT=IOS )
                CALL CHECKMEM( IOS, 'INVYR', PROGNAME )
            END IF

            IF( UFLAG .AND. .NOT. ALLOCATED( CSCC ) ) THEN
                ALLOCATE( CSCC( NDIM1 ), STAT=IOS )
                CALL CHECKMEM( IOS, 'CSCC', PROGNAME )  
            END IF

            IF( UFLAG .AND. .NOT. ALLOCATED( CSOURC ) ) THEN
                ALLOCATE( CSOURC( NDIM1 ), STAT=IOS )
                CALL CHECKMEM( IOS, 'CSOURC', PROGNAME )
            END IF

            IF( PFLAG .AND. AFLAG .AND. .NOT. ALLOCATED( POLVAL ) ) THEN
                ALLOCATE( POLVAL( NDIM2, NDIM3 ), STAT=IOS )
                CALL CHECKMEM( IOS, 'POLVAL', PROGNAME )
            END IF

C.............  Deallocate for any source category
            IF( .NOT. AFLAG .AND. .NOT. PFLAG ) THEN
                IF( ALLOCATED( IFIP )   ) DEALLOCATE( IFIP )
                IF( ALLOCATED( TPFLAG ) ) DEALLOCATE( TPFLAG )
                IF( ALLOCATED( INVYR )  ) DEALLOCATE( INVYR )
                IF( ALLOCATED( CSCC )   ) DEALLOCATE( CSCC )
                IF( ALLOCATED( CSOURC ) ) DEALLOCATE( CSOURC )

            ELSE IF( .NOT. AFLAG ) THEN
                IF( ALLOCATED( IPOSCOD ) ) DEALLOCATE( IPOSCOD )
                IF( ALLOCATED( POLVAL  ) ) DEALLOCATE( POLVAL )

            END IF               

            SELECT CASE( CATEGORY )
            CASE( 'AREA' )
            CASE( 'MOBILE' )
 
            CASE( 'POINT' )
 
                IF( UFLAG .AND. .NOT. ALLOCATED( ISIC ) ) THEN
                    ALLOCATE( ISIC( NDIM1 ), STAT=IOS )
                    CALL CHECKMEM( IOS, 'ISIC', PROGNAME )
                END IF

                IF( UFLAG .AND. .NOT. ALLOCATED( IORIS ) ) THEN
                    ALLOCATE( IORIS( NDIM1 ), STAT=IOS )
                    CALL CHECKMEM( IOS, 'IORIS', PROGNAME )
                END IF

                IF( UFLAG .AND. .NOT. ALLOCATED( IDIU ) ) THEN
                    ALLOCATE( IDIU( NDIM1 ), STAT=IOS )
                    CALL CHECKMEM( IOS, 'IDIU', PROGNAME )
                END IF

                IF( UFLAG .AND. .NOT. ALLOCATED( IWEK ) ) THEN
                    ALLOCATE( IWEK( NDIM1 ), STAT=IOS )
                    CALL CHECKMEM( IOS, 'IWEK', PROGNAME )
                END IF

                IF( UFLAG .AND. .NOT. ALLOCATED( NPCNT ) ) THEN
                    ALLOCATE( NPCNT( NDIM1 ), STAT=IOS )
                    CALL CHECKMEM( IOS, 'NPCNT', PROGNAME )
                END IF

                IF( UFLAG .AND. .NOT. ALLOCATED( XLOCA ) ) THEN
                    ALLOCATE( XLOCA( NDIM1 ), STAT=IOS )
                    CALL CHECKMEM( IOS, 'XLOCA', PROGNAME )
                END IF

                IF( UFLAG .AND. .NOT. ALLOCATED( YLOCA ) ) THEN
                    ALLOCATE( YLOCA( NDIM1 ), STAT=IOS )
                    CALL CHECKMEM( IOS, 'YLOCA', PROGNAME )
                END IF

                IF( UFLAG .AND. .NOT. ALLOCATED( STKHT ) ) THEN
                    ALLOCATE( STKHT( NDIM1 ), STAT=IOS )
                    CALL CHECKMEM( IOS, 'STKHT', PROGNAME )
                END IF

                IF( UFLAG .AND. .NOT. ALLOCATED( STKDM ) ) THEN
                    ALLOCATE( STKDM( NDIM1 ), STAT=IOS )
                    CALL CHECKMEM( IOS, 'STKDM', PROGNAME )
                END IF

                IF( UFLAG .AND. .NOT. ALLOCATED( STKTK ) ) THEN
                    ALLOCATE( STKTK( NDIM1 ), STAT=IOS )
                    CALL CHECKMEM( IOS, 'STKTK', PROGNAME )
                END IF

                IF( UFLAG .AND. .NOT. ALLOCATED( STKVE ) ) THEN
                    ALLOCATE( STKVE( NDIM1 ), STAT=IOS )
                    CALL CHECKMEM( IOS, 'STKVE', PROGNAME )
                END IF

                IF( UFLAG .AND. .NOT. ALLOCATED( CBLRID ) ) THEN
                    ALLOCATE( CBLRID( NDIM1 ), STAT=IOS )
                    CALL CHECKMEM( IOS, 'CBLRID', PROGNAME )  
                END IF

                IF( UFLAG .AND. .NOT. ALLOCATED( CPDESC ) ) THEN
                    ALLOCATE( CPDESC( NDIM1 ), STAT=IOS )
                    CALL CHECKMEM( IOS, 'CPDESC', PROGNAME )  
                END IF

                IF( .NOT. PFLAG .AND. 
     &              .NOT. AFLAG .AND. ALLOCATED( ISICA ) ) 
     &              DEALLOCATE( ISIC, IORIS, IDIU, IWEK, NPCNT,
     &                          YLOCA, STKHT, STKDM, STKTK,  
     &                          STKVE, CBLRID, CPDESC )

            CASE DEFAULT

            END SELECT

        CASE DEFAULT

            MESG = 'INTERNAL ERROR: Do not know about sorting type ' //
     &             SORTTYPE // ' in program ' // PROGNAME
            CALL M3MSG2( MESG )
            CALL M3EXIT( PROGNAME, 0, 0, ' ', 2 )

        END SELECT      ! sorted or unsorted

        RETURN

C******************  FORMAT  STATEMENTS   ******************************

C...........   Internal buffering formats............ 94xxx

94010   FORMAT( 10( A, :, I8, :, 1X ) )

        END SUBROUTINE SRCMEM

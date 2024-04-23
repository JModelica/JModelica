
      SUBROUTINE RADAU5(N,FCN,X,Y,XEND,H,
     &                  RTOL,ATOL,ITOL,
     &                  JAC ,IJAC,MLJAC,MUJAC,
     &                  MAS ,IMAS,MLMAS,MUMAS,
     &                  SOLOUT,IOUT,
     &                  WORK,LWORK,IWORK,LIWORK,RPAR,IPAR,IDID)
C ----------------------------------------------------------
C     NUMERICAL SOLUTION OF A STIFF (OR DIFFERENTIAL ALGEBRAIC)
C     SYSTEM OF FIRST 0RDER ORDINARY DIFFERENTIAL EQUATIONS
C                     M*Y'=F(X,Y).
C     THE SYSTEM CAN BE (LINEARLY) IMPLICIT (MASS-MATRIX M .NE. I)
C     OR EXPLICIT (M=I).
C     THE METHOD USED IS AN IMPLICIT RUNGE-KUTTA METHOD (RADAU IIA)
C     OF ORDER 5 WITH STEP SIZE CONTROL AND CONTINUOUS OUTPUT.
C     CF. SECTION IV.8
C
C     AUTHORS: E. HAIRER AND G. WANNER
C              UNIVERSITE DE GENEVE, DEPT. DE MATHEMATIQUES
C              CH-1211 GENEVE 24, SWITZERLAND
C              E-MAIL:  Ernst.Hairer@math.unige.ch
C                       Gerhard.Wanner@math.unige.ch
C
C     THIS CODE IS PART OF THE BOOK:
C         E. HAIRER AND G. WANNER, SOLVING ORDINARY DIFFERENTIAL
C         EQUATIONS II. STIFF AND DIFFERENTIAL-ALGEBRAIC PROBLEMS.
C         SPRINGER SERIES IN COMPUTATIONAL MATHEMATICS 14,
C         SPRINGER-VERLAG 1991, SECOND EDITION 1996.
C
C     VERSION OF JULY 9, 1996
C     (latest small correction: January 18, 2002)
C
C     INPUT PARAMETERS
C     ----------------
C     N           DIMENSION OF THE SYSTEM
C
C     FCN         NAME (EXTERNAL) OF SUBROUTINE COMPUTING THE
C                 VALUE OF F(X,Y):
C                    SUBROUTINE FCN(N,X,Y,F,RPAR,IPAR)
C                    DOUBLE PRECISION X,Y(N),F(N)
C                    F(1)=...   ETC.
C                 RPAR, IPAR (SEE BELOW)
C
C     X           INITIAL X-VALUE
C
C     Y(N)        INITIAL VALUES FOR Y
C
C     XEND        FINAL X-VALUE (XEND-X MAY BE POSITIVE OR NEGATIVE)
C
C     H           INITIAL STEP SIZE GUESS;
C                 FOR STIFF EQUATIONS WITH INITIAL TRANSIENT,
C                 H=1.D0/(NORM OF F'), USUALLY 1.D-3 OR 1.D-5, IS GOOD.
C                 THIS CHOICE IS NOT VERY IMPORTANT, THE STEP SIZE IS
C                 QUICKLY ADAPTED. (IF H=0.D0, THE CODE PUTS H=1.D-6).
C
C     RTOL,ATOL   RELATIVE AND ABSOLUTE ERROR TOLERANCES. THEY
C                 CAN BE BOTH SCALARS OR ELSE BOTH VECTORS OF LENGTH N.
C
C     ITOL        SWITCH FOR RTOL AND ATOL:
C                   ITOL=0: BOTH RTOL AND ATOL ARE SCALARS.
C                     THE CODE KEEPS, ROUGHLY, THE LOCAL ERROR OF
C                     Y(I) BELOW RTOL*ABS(Y(I))+ATOL
C                   ITOL=1: BOTH RTOL AND ATOL ARE VECTORS.
C                     THE CODE KEEPS THE LOCAL ERROR OF Y(I) BELOW
C                     RTOL(I)*ABS(Y(I))+ATOL(I).
C
C     JAC         NAME (EXTERNAL) OF THE SUBROUTINE WHICH COMPUTES
C                 THE PARTIAL DERIVATIVES OF F(X,Y) WITH RESPECT TO Y
C                 (THIS ROUTINE IS ONLY CALLED IF IJAC=1; SUPPLY
C                 A DUMMY SUBROUTINE IN THE CASE IJAC=0).
C                 FOR IJAC=1, THIS SUBROUTINE MUST HAVE THE FORM
C                    SUBROUTINE JAC(N,X,Y,DFY,LDFY,RPAR,IPAR)
C                    DOUBLE PRECISION X,Y(N),DFY(LDFY,N)
C                    DFY(1,1)= ...
C                 LDFY, THE COLUMN-LENGTH OF THE ARRAY, IS
C                 FURNISHED BY THE CALLING PROGRAM.
C                 IF (MLJAC.EQ.N) THE JACOBIAN IS SUPPOSED TO
C                    BE FULL AND THE PARTIAL DERIVATIVES ARE
C                    STORED IN DFY AS
C                       DFY(I,J) = PARTIAL F(I) / PARTIAL Y(J)
C                 ELSE, THE JACOBIAN IS TAKEN AS BANDED AND
C                    THE PARTIAL DERIVATIVES ARE STORED
C                    DIAGONAL-WISE AS
C                       DFY(I-J+MUJAC+1,J) = PARTIAL F(I) / PARTIAL Y(J).
C
C     IJAC        SWITCH FOR THE COMPUTATION OF THE JACOBIAN:
C                    IJAC=0: JACOBIAN IS COMPUTED INTERNALLY BY FINITE
C                       DIFFERENCES, SUBROUTINE "JAC" IS NEVER CALLED.
C                    IJAC=1: JACOBIAN IS SUPPLIED BY SUBROUTINE JAC.
C
C     MLJAC       SWITCH FOR THE BANDED STRUCTURE OF THE JACOBIAN:
C                    MLJAC=N: JACOBIAN IS A FULL MATRIX. THE LINEAR
C                       ALGEBRA IS DONE BY FULL-MATRIX GAUSS-ELIMINATION.
C                    0<=MLJAC<N: MLJAC IS THE LOWER BANDWITH OF JACOBIAN
C                       MATRIX (>= NUMBER OF NON-ZERO DIAGONALS BELOW
C                       THE MAIN DIAGONAL).
C
C     MUJAC       UPPER BANDWITH OF JACOBIAN  MATRIX (>= NUMBER OF NON-
C                 ZERO DIAGONALS ABOVE THE MAIN DIAGONAL).
C                 NEED NOT BE DEFINED IF MLJAC=N.
C
C     ----   MAS,IMAS,MLMAS, AND MUMAS HAVE ANALOG MEANINGS      -----
C     ----   FOR THE "MASS MATRIX" (THE MATRIX "M" OF SECTION IV.8): -
C
C     MAS         NAME (EXTERNAL) OF SUBROUTINE COMPUTING THE MASS-
C                 MATRIX M.
C                 IF IMAS=0, THIS MATRIX IS ASSUMED TO BE THE IDENTITY
C                 MATRIX AND NEEDS NOT TO BE DEFINED;
C                 SUPPLY A DUMMY SUBROUTINE IN THIS CASE.
C                 IF IMAS=1, THE SUBROUTINE MAS IS OF THE FORM
C                    SUBROUTINE MAS(N,AM,LMAS,RPAR,IPAR)
C                    DOUBLE PRECISION AM(LMAS,N)
C                    AM(1,1)= ....
C                    IF (MLMAS.EQ.N) THE MASS-MATRIX IS STORED
C                    AS FULL MATRIX LIKE
C                         AM(I,J) = M(I,J)
C                    ELSE, THE MATRIX IS TAKEN AS BANDED AND STORED
C                    DIAGONAL-WISE AS
C                         AM(I-J+MUMAS+1,J) = M(I,J).
C
C     IMAS       GIVES INFORMATION ON THE MASS-MATRIX:
C                    IMAS=0: M IS SUPPOSED TO BE THE IDENTITY
C                       MATRIX, MAS IS NEVER CALLED.
C                    IMAS=1: MASS-MATRIX  IS SUPPLIED.
C
C     MLMAS       SWITCH FOR THE BANDED STRUCTURE OF THE MASS-MATRIX:
C                    MLMAS=N: THE FULL MATRIX CASE. THE LINEAR
C                       ALGEBRA IS DONE BY FULL-MATRIX GAUSS-ELIMINATION.
C                    0<=MLMAS<N: MLMAS IS THE LOWER BANDWITH OF THE
C                       MATRIX (>= NUMBER OF NON-ZERO DIAGONALS BELOW
C                       THE MAIN DIAGONAL).
C                 MLMAS IS SUPPOSED TO BE .LE. MLJAC.
C
C     MUMAS       UPPER BANDWITH OF MASS-MATRIX (>= NUMBER OF NON-
C                 ZERO DIAGONALS ABOVE THE MAIN DIAGONAL).
C                 NEED NOT BE DEFINED IF MLMAS=N.
C                 MUMAS IS SUPPOSED TO BE .LE. MUJAC.
C
C     SOLOUT      NAME (EXTERNAL) OF SUBROUTINE PROVIDING THE
C                 NUMERICAL SOLUTION DURING INTEGRATION.
C                 IF IOUT=1, IT IS CALLED AFTER EVERY SUCCESSFUL STEP.
C                 SUPPLY A DUMMY SUBROUTINE IF IOUT=0.
C                 IT MUST HAVE THE FORM
C                    SUBROUTINE SOLOUT (NR,XOLD,X,Y,CONT,LRC,N,
C                                       RPAR,IPAR,IRTRN)
C                    DOUBLE PRECISION X,Y(N),CONT(LRC)
C                    ....
C                 SOLOUT FURNISHES THE SOLUTION "Y" AT THE NR-TH
C                    GRID-POINT "X" (THEREBY THE INITIAL VALUE IS
C                    THE FIRST GRID-POINT).
C                 "XOLD" IS THE PRECEEDING GRID-POINT.
C                 "IRTRN" SERVES TO INTERRUPT THE INTEGRATION. IF IRTRN
C                    IS SET <0, RADAU5 RETURNS TO THE CALLING PROGRAM.
C
C          -----  CONTINUOUS OUTPUT: -----
C                 DURING CALLS TO "SOLOUT", A CONTINUOUS SOLUTION
C                 FOR THE INTERVAL [XOLD,X] IS AVAILABLE THROUGH
C                 THE FUNCTION
C                        >>>   CONTR5(I,S,CONT,LRC)   <<<
C                 WHICH PROVIDES AN APPROXIMATION TO THE I-TH
C                 COMPONENT OF THE SOLUTION AT THE POINT S. THE VALUE
C                 S SHOULD LIE IN THE INTERVAL [XOLD,X].
C                 DO NOT CHANGE THE ENTRIES OF CONT(LRC), IF THE
C                 DENSE OUTPUT FUNCTION IS USED.
C
C     IOUT        SWITCH FOR CALLING THE SUBROUTINE SOLOUT:
C                    IOUT=0: SUBROUTINE IS NEVER CALLED
C                    IOUT=1: SUBROUTINE IS AVAILABLE FOR OUTPUT.
C
C     WORK        ARRAY OF WORKING SPACE OF LENGTH "LWORK".
C                 WORK(1), WORK(2),.., WORK(20) SERVE AS PARAMETERS
C                 FOR THE CODE. FOR STANDARD USE OF THE CODE
C                 WORK(1),..,WORK(20) MUST BE SET TO ZERO BEFORE
C                 CALLING. SEE BELOW FOR A MORE SOPHISTICATED USE.
C                 WORK(21),..,WORK(LWORK) SERVE AS WORKING SPACE
C                 FOR ALL VECTORS AND MATRICES.
C                 "LWORK" MUST BE AT LEAST
C                             N*(LJAC+LMAS+3*LE+12)+20
C                 WHERE
C                    LJAC=N              IF MLJAC=N (FULL JACOBIAN)
C                    LJAC=MLJAC+MUJAC+1  IF MLJAC<N (BANDED JAC.)
C                 AND
C                    LMAS=0              IF IMAS=0
C                    LMAS=N              IF IMAS=1 AND MLMAS=N (FULL)
C                    LMAS=MLMAS+MUMAS+1  IF MLMAS<N (BANDED MASS-M.)
C                 AND
C                    LE=N               IF MLJAC=N (FULL JACOBIAN)
C                    LE=2*MLJAC+MUJAC+1 IF MLJAC<N (BANDED JAC.)
C
C                 IN THE USUAL CASE WHERE THE JACOBIAN IS FULL AND THE
C                 MASS-MATRIX IS THE INDENTITY (IMAS=0), THE MINIMUM
C                 STORAGE REQUIREMENT IS
C                             LWORK = 4*N*N+12*N+20.
C                 IF IWORK(9)=M1>0 THEN "LWORK" MUST BE AT LEAST
C                          N*(LJAC+12)+(N-M1)*(LMAS+3*LE)+20
C                 WHERE IN THE DEFINITIONS OF LJAC, LMAS AND LE THE
C                 NUMBER N CAN BE REPLACED BY N-M1.
C
C     LWORK       DECLARED LENGTH OF ARRAY "WORK".
C
C     IWORK       INTEGER WORKING SPACE OF LENGTH "LIWORK".
C                 IWORK(1),IWORK(2),...,IWORK(20) SERVE AS PARAMETERS
C                 FOR THE CODE. FOR STANDARD USE, SET IWORK(1),..,
C                 IWORK(20) TO ZERO BEFORE CALLING.
C                 IWORK(21),...,IWORK(LIWORK) SERVE AS WORKING AREA.
C                 "LIWORK" MUST BE AT LEAST 3*N+20.
C
C     LIWORK      DECLARED LENGTH OF ARRAY "IWORK".
C
C     RPAR, IPAR  REAL AND INTEGER PARAMETERS (OR PARAMETER ARRAYS) WHICH
C                 CAN BE USED FOR COMMUNICATION BETWEEN YOUR CALLING
C                 PROGRAM AND THE FCN, JAC, MAS, SOLOUT SUBROUTINES.
C
C ----------------------------------------------------------------------
C
C     SOPHISTICATED SETTING OF PARAMETERS
C     -----------------------------------
C              SEVERAL PARAMETERS OF THE CODE ARE TUNED TO MAKE IT WORK
C              WELL. THEY MAY BE DEFINED BY SETTING WORK(1),...
C              AS WELL AS IWORK(1),... DIFFERENT FROM ZERO.
C              FOR ZERO INPUT, THE CODE CHOOSES DEFAULT VALUES:
C
C    IWORK(1)  IF IWORK(1).NE.0, THE CODE TRANSFORMS THE JACOBIAN
C              MATRIX TO HESSENBERG FORM. THIS IS PARTICULARLY
C              ADVANTAGEOUS FOR LARGE SYSTEMS WITH FULL JACOBIAN.
C              IT DOES NOT WORK FOR BANDED JACOBIAN (MLJAC<N)
C              AND NOT FOR IMPLICIT SYSTEMS (IMAS=1).
C
C    IWORK(2)  THIS IS THE MAXIMAL NUMBER OF ALLOWED STEPS.
C              THE DEFAULT VALUE (FOR IWORK(2)=0) IS 100000.
C
C    IWORK(3)  THE MAXIMUM NUMBER OF NEWTON ITERATIONS FOR THE
C              SOLUTION OF THE IMPLICIT SYSTEM IN EACH STEP.
C              THE DEFAULT VALUE (FOR IWORK(3)=0) IS 7.
C
C    IWORK(4)  IF IWORK(4).EQ.0 THE EXTRAPOLATED COLLOCATION SOLUTION
C              IS TAKEN AS STARTING VALUE FOR NEWTON'S METHOD.
C              IF IWORK(4).NE.0 ZERO STARTING VALUES ARE USED.
C              THE LATTER IS RECOMMENDED IF NEWTON'S METHOD HAS
C              DIFFICULTIES WITH CONVERGENCE (THIS IS THE CASE WHEN
C              NSTEP IS LARGER THAN NACCPT + NREJCT; SEE OUTPUT PARAM.).
C              DEFAULT IS IWORK(4)=0.
C
C       THE FOLLOWING 3 PARAMETERS ARE IMPORTANT FOR
C       DIFFERENTIAL-ALGEBRAIC SYSTEMS OF INDEX > 1.
C       THE FUNCTION-SUBROUTINE SHOULD BE WRITTEN SUCH THAT
C       THE INDEX 1,2,3 VARIABLES APPEAR IN THIS ORDER.
C       IN ESTIMATING THE ERROR THE INDEX 2 VARIABLES ARE
C       MULTIPLIED BY H, THE INDEX 3 VARIABLES BY H**2.
C
C    IWORK(5)  DIMENSION OF THE INDEX 1 VARIABLES (MUST BE > 0). FOR
C              ODE'S THIS EQUALS THE DIMENSION OF THE SYSTEM.
C              DEFAULT IWORK(5)=N.
C
C    IWORK(6)  DIMENSION OF THE INDEX 2 VARIABLES. DEFAULT IWORK(6)=0.
C
C    IWORK(7)  DIMENSION OF THE INDEX 3 VARIABLES. DEFAULT IWORK(7)=0.
C
C    IWORK(8)  SWITCH FOR STEP SIZE STRATEGY
C              IF IWORK(8).EQ.1  MOD. PREDICTIVE CONTROLLER (GUSTAFSSON)
C              IF IWORK(8).EQ.2  CLASSICAL STEP SIZE CONTROL
C              THE DEFAULT VALUE (FOR IWORK(8)=0) IS IWORK(8)=1.
C              THE CHOICE IWORK(8).EQ.1 SEEMS TO PRODUCE SAFER RESULTS;
C              FOR SIMPLE PROBLEMS, THE CHOICE IWORK(8).EQ.2 PRODUCES
C              OFTEN SLIGHTLY FASTER RUNS
C
C       IF THE DIFFERENTIAL SYSTEM HAS THE SPECIAL STRUCTURE THAT
C            Y(I)' = Y(I+M2)   FOR  I=1,...,M1,
C       WITH M1 A MULTIPLE OF M2, A SUBSTANTIAL GAIN IN COMPUTERTIME
C       CAN BE ACHIEVED BY SETTING THE PARAMETERS IWORK(9) AND IWORK(10).
C       E.G., FOR SECOND ORDER SYSTEMS P'=V, V'=G(P,V), WHERE P AND V ARE
C       VECTORS OF DIMENSION N/2, ONE HAS TO PUT M1=M2=N/2.
C       FOR M1>0 SOME OF THE INPUT PARAMETERS HAVE DIFFERENT MEANINGS:
C       - JAC: ONLY THE ELEMENTS OF THE NON-TRIVIAL PART OF THE
C              JACOBIAN HAVE TO BE STORED
C              IF (MLJAC.EQ.N-M1) THE JACOBIAN IS SUPPOSED TO BE FULL
C                 DFY(I,J) = PARTIAL F(I+M1) / PARTIAL Y(J)
C                FOR I=1,N-M1 AND J=1,N.
C              ELSE, THE JACOBIAN IS BANDED ( M1 = M2 * MM )
C                 DFY(I-J+MUJAC+1,J+K*M2) = PARTIAL F(I+M1) / PARTIAL Y(J+K*M2)
C                FOR I=1,MLJAC+MUJAC+1 AND J=1,M2 AND K=0,MM.
C       - MLJAC: MLJAC=N-M1: IF THE NON-TRIVIAL PART OF THE JACOBIAN IS FULL
C                0<=MLJAC<N-M1: IF THE (MM+1) SUBMATRICES (FOR K=0,MM)
C                     PARTIAL F(I+M1) / PARTIAL Y(J+K*M2),  I,J=1,M2
C                    ARE BANDED, MLJAC IS THE MAXIMAL LOWER BANDWIDTH
C                    OF THESE MM+1 SUBMATRICES
C       - MUJAC: MAXIMAL UPPER BANDWIDTH OF THESE MM+1 SUBMATRICES
C                NEED NOT BE DEFINED IF MLJAC=N-M1
C       - MAS: IF IMAS=0 THIS MATRIX IS ASSUMED TO BE THE IDENTITY AND
C              NEED NOT BE DEFINED. SUPPLY A DUMMY SUBROUTINE IN THIS CASE.
C              IT IS ASSUMED THAT ONLY THE ELEMENTS OF RIGHT LOWER BLOCK OF
C              DIMENSION N-M1 DIFFER FROM THAT OF THE IDENTITY MATRIX.
C              IF (MLMAS.EQ.N-M1) THIS SUBMATRIX IS SUPPOSED TO BE FULL
C                 AM(I,J) = M(I+M1,J+M1)     FOR I=1,N-M1 AND J=1,N-M1.
C              ELSE, THE MASS MATRIX IS BANDED
C                 AM(I-J+MUMAS+1,J) = M(I+M1,J+M1)
C       - MLMAS: MLMAS=N-M1: IF THE NON-TRIVIAL PART OF M IS FULL
C                0<=MLMAS<N-M1: LOWER BANDWIDTH OF THE MASS MATRIX
C       - MUMAS: UPPER BANDWIDTH OF THE MASS MATRIX
C                NEED NOT BE DEFINED IF MLMAS=N-M1
C
C    IWORK(9)  THE VALUE OF M1.  DEFAULT M1=0.
C
C    IWORK(10) THE VALUE OF M2.  DEFAULT M2=M1.
C
C ----------
C
C    WORK(1)   UROUND, THE ROUNDING UNIT, DEFAULT 1.D-16.
C
C    WORK(2)   THE SAFETY FACTOR IN STEP SIZE PREDICTION,
C              DEFAULT 0.9D0.
C
C    WORK(3)   DECIDES WHETHER THE JACOBIAN SHOULD BE RECOMPUTED;
C              INCREASE WORK(3), TO 0.1 SAY, WHEN JACOBIAN EVALUATIONS
C              ARE COSTLY. FOR SMALL SYSTEMS WORK(3) SHOULD BE SMALLER
C              (0.001D0, SAY). NEGATIV WORK(3) FORCES THE CODE TO
C              COMPUTE THE JACOBIAN AFTER EVERY ACCEPTED STEP.
C              DEFAULT 0.001D0.
C
C    WORK(4)   STOPPING CRITERION FOR NEWTON'S METHOD, USUALLY CHOSEN <1.
C              SMALLER VALUES OF WORK(4) MAKE THE CODE SLOWER, BUT SAFER.
C              DEFAULT MIN(0.03D0,RTOL(1)**0.5D0)
C
C    WORK(5) AND WORK(6) : IF WORK(5) < HNEW/HOLD < WORK(6), THEN THE
C              STEP SIZE IS NOT CHANGED. THIS SAVES, TOGETHER WITH A
C              LARGE WORK(3), LU-DECOMPOSITIONS AND COMPUTING TIME FOR
C              LARGE SYSTEMS. FOR SMALL SYSTEMS ONE MAY HAVE
C              WORK(5)=1.D0, WORK(6)=1.2D0, FOR LARGE FULL SYSTEMS
C              WORK(5)=0.99D0, WORK(6)=2.D0 MIGHT BE GOOD.
C              DEFAULTS WORK(5)=1.D0, WORK(6)=1.2D0 .
C
C    WORK(7)   MAXIMAL STEP SIZE, DEFAULT XEND-X.
C
C    WORK(8), WORK(9)   PARAMETERS FOR STEP SIZE SELECTION
C              THE NEW STEP SIZE IS CHOSEN SUBJECT TO THE RESTRICTION
C                 WORK(8) <= HNEW/HOLD <= WORK(9)
C              DEFAULT VALUES: WORK(8)=0.2D0, WORK(9)=8.D0
C
C-----------------------------------------------------------------------
C
C     OUTPUT PARAMETERS
C     -----------------
C     X           X-VALUE FOR WHICH THE SOLUTION HAS BEEN COMPUTED
C                 (AFTER SUCCESSFUL RETURN X=XEND).
C
C     Y(N)        NUMERICAL SOLUTION AT X
C
C     H           PREDICTED STEP SIZE OF THE LAST ACCEPTED STEP
C
C     IDID        REPORTS ON SUCCESSFULNESS UPON RETURN:
C                   IDID= 1  COMPUTATION SUCCESSFUL,
C                   IDID= 2  COMPUT. SUCCESSFUL (INTERRUPTED BY SOLOUT)
C                   IDID=-1  INPUT IS NOT CONSISTENT,
C                   IDID=-2  LARGER NMAX IS NEEDED,
C                   IDID=-3  STEP SIZE BECOMES TOO SMALL,
C                   IDID=-4  MATRIX IS REPEATEDLY SINGULAR.
C
C   IWORK(14)  NFCN    NUMBER OF FUNCTION EVALUATIONS (THOSE FOR NUMERICAL
C                      EVALUATION OF THE JACOBIAN ARE NOT COUNTED)
C   IWORK(15)  NJAC    NUMBER OF JACOBIAN EVALUATIONS (EITHER ANALYTICALLY
C                      OR NUMERICALLY)
C   IWORK(16)  NSTEP   NUMBER OF COMPUTED STEPS
C   IWORK(17)  NACCPT  NUMBER OF ACCEPTED STEPS
C   IWORK(18)  NREJCT  NUMBER OF REJECTED STEPS (DUE TO ERROR TEST),
C                      (STEP REJECTIONS IN THE FIRST STEP ARE NOT COUNTED)
C   IWORK(19)  NDEC    NUMBER OF LU-DECOMPOSITIONS OF BOTH MATRICES
C   IWORK(20)  NSOL    NUMBER OF FORWARD-BACKWARD SUBSTITUTIONS, OF BOTH
C                      SYSTEMS; THE NSTEP FORWARD-BACKWARD SUBSTITUTIONS,
C                      NEEDED FOR STEP SIZE SELECTION, ARE NOT COUNTED
C-----------------------------------------------------------------------
C *** *** *** *** *** *** *** *** *** *** *** *** ***
C          DECLARATIONS
C *** *** *** *** *** *** *** *** *** *** *** *** ***
         IMPLICIT DOUBLE PRECISION (A-H,O-Z)
         DIMENSION Y(N),ATOL(*),RTOL(*),WORK(LWORK),IWORK(LIWORK)
         DIMENSION RPAR(*),IPAR(*)
         LOGICAL IMPLCT,JBAND,ARRET,STARTN,PRED
         EXTERNAL FCN,JAC,MAS,SOLOUT
C *** *** *** *** *** *** ***
C        SETTING THE PARAMETERS
C *** *** *** *** *** *** ***
         NFCN=0
         NJAC=0
         NSTEP=0
         NACCPT=0
         NREJCT=0
         NDEC=0
         NSOL=0
         ARRET=.FALSE.
C -------- UROUND   SMALLEST NUMBER SATISFYING 1.0D0+UROUND>1.0D0
         IF (WORK(1).EQ.0.0D0) THEN
            UROUND=1.0D-16
         ELSE
            UROUND=WORK(1)
            IF (UROUND.LE.1.0D-19.OR.UROUND.GE.1.0D0) THEN
               WRITE(6,*)' COEFFICIENTS HAVE 20 DIGITS, UROUND=',WORK(1)
               ARRET=.TRUE.
            END IF
         END IF
C -------- CHECK AND CHANGE THE TOLERANCES
         EXPM=2.0D0/3.0D0
         IF (ITOL.EQ.0) THEN
            IF (ATOL(1).LE.0.D0.OR.RTOL(1).LE.10.D0*UROUND) THEN
               WRITE (6,*) ' TOLERANCES ARE TOO SMALL'
               ARRET=.TRUE.
            ELSE
               QUOT=ATOL(1)/RTOL(1)
               RTOL(1)=0.1D0*RTOL(1)**EXPM
               ATOL(1)=RTOL(1)*QUOT
            END IF
         ELSE
            DO I=1,N
               IF (ATOL(I).LE.0.D0.OR.RTOL(I).LE.10.D0*UROUND) THEN
                  WRITE (6,*) ' TOLERANCES(',I,') ARE TOO SMALL'
                  ARRET=.TRUE.
               ELSE
                  QUOT=ATOL(I)/RTOL(I)
                  RTOL(I)=0.1D0*RTOL(I)**EXPM
                  ATOL(I)=RTOL(I)*QUOT
               END IF
            END DO
         END IF
C -------- NMAX , THE MAXIMAL NUMBER OF STEPS -----
         IF (IWORK(2).EQ.0) THEN
            NMAX=100000
         ELSE
            NMAX=IWORK(2)
            IF (NMAX.LE.0) THEN
               WRITE(6,*)' WRONG INPUT IWORK(2)=',IWORK(2)
               ARRET=.TRUE.
            END IF
         END IF
C -------- NIT    MAXIMAL NUMBER OF NEWTON ITERATIONS
         IF (IWORK(3).EQ.0) THEN
            NIT=7
         ELSE
            NIT=IWORK(3)
            IF (NIT.LE.0) THEN
               WRITE(6,*)' CURIOUS INPUT IWORK(3)=',IWORK(3)
               ARRET=.TRUE.
            END IF
         END IF
C -------- STARTN  SWITCH FOR STARTING VALUES OF NEWTON ITERATIONS
         IF(IWORK(4).EQ.0)THEN
            STARTN=.FALSE.
         ELSE
            STARTN=.TRUE.
         END IF
C -------- PARAMETER FOR DIFFERENTIAL-ALGEBRAIC COMPONENTS
         NIND1=IWORK(5)
         NIND2=IWORK(6)
         NIND3=IWORK(7)
         IF (NIND1.EQ.0) NIND1=N
         IF (NIND1+NIND2+NIND3.NE.N) THEN
            WRITE(6,*)' CURIOUS INPUT FOR IWORK(5,6,7)=',NIND1,NIND2,NIND3
            ARRET=.TRUE.
         END IF
C -------- PRED   STEP SIZE CONTROL
         IF(IWORK(8).LE.1)THEN
            PRED=.TRUE.
         ELSE
            PRED=.FALSE.
         END IF
C -------- PARAMETER FOR SECOND ORDER EQUATIONS
         M1=IWORK(9)
         M2=IWORK(10)
         NM1=N-M1
         IF (M1.EQ.0) M2=N
         IF (M2.EQ.0) M2=M1
         IF (M1.LT.0.OR.M2.LT.0.OR.M1+M2.GT.N) THEN
            WRITE(6,*)' CURIOUS INPUT FOR IWORK(9,10)=',M1,M2
            ARRET=.TRUE.
         END IF
C --------- SAFE     SAFETY FACTOR IN STEP SIZE PREDICTION
         IF (WORK(2).EQ.0.0D0) THEN
            SAFE=0.9D0
         ELSE
            SAFE=WORK(2)
            IF (SAFE.LE.0.001D0.OR.SAFE.GE.1.0D0) THEN
               WRITE(6,*)' CURIOUS INPUT FOR WORK(2)=',WORK(2)
               ARRET=.TRUE.
            END IF
         END IF
C ------ THET     DECIDES WHETHER THE JACOBIAN SHOULD BE RECOMPUTED;
         IF (WORK(3).EQ.0.D0) THEN
            THET=0.001D0
         ELSE
            THET=WORK(3)
            IF (THET.GE.1.0D0) THEN
               WRITE(6,*)' CURIOUS INPUT FOR WORK(3)=',WORK(3)
               ARRET=.TRUE.
            END IF
         END IF
C --- FNEWT   STOPPING CRITERION FOR NEWTON'S METHOD, USUALLY CHOSEN <1.
         TOLST=RTOL(1)
         IF (WORK(4).EQ.0.D0) THEN
            FNEWT=MAX(10*UROUND/TOLST,MIN(0.03D0,TOLST**0.5D0))
         ELSE
            FNEWT=WORK(4)
            IF (FNEWT.LE.UROUND/TOLST) THEN
               WRITE(6,*)' CURIOUS INPUT FOR WORK(4)=',WORK(4)
               ARRET=.TRUE.
            END IF
         END IF
C --- QUOT1 AND QUOT2: IF QUOT1 < HNEW/HOLD < QUOT2, STEP SIZE = CONST.
         IF (WORK(5).EQ.0.D0) THEN
            QUOT1=1.D0
         ELSE
            QUOT1=WORK(5)
         END IF
         IF (WORK(6).EQ.0.D0) THEN
            QUOT2=1.2D0
         ELSE
            QUOT2=WORK(6)
         END IF
         IF (QUOT1.GT.1.0D0.OR.QUOT2.LT.1.0D0) THEN
            WRITE(6,*)' CURIOUS INPUT FOR WORK(5,6)=',QUOT1,QUOT2
            ARRET=.TRUE.
         END IF
C -------- MAXIMAL STEP SIZE
         IF (WORK(7).EQ.0.D0) THEN
            HMAX=XEND-X
         ELSE
            HMAX=WORK(7)
         END IF
C -------  FACL,FACR     PARAMETERS FOR STEP SIZE SELECTION
         IF(WORK(8).EQ.0.D0)THEN
            FACL=5.D0
         ELSE
            FACL=1.D0/WORK(8)
         END IF
         IF(WORK(9).EQ.0.D0)THEN
            FACR=1.D0/8.0D0
         ELSE
            FACR=1.D0/WORK(9)
         END IF
         IF (FACL.LT.1.0D0.OR.FACR.GT.1.0D0) THEN
            WRITE(6,*)' CURIOUS INPUT WORK(8,9)=',WORK(8),WORK(9)
            ARRET=.TRUE.
         END IF
C *** *** *** *** *** *** *** *** *** *** *** *** ***
C         COMPUTATION OF ARRAY ENTRIES
C *** *** *** *** *** *** *** *** *** *** *** *** ***
C ---- IMPLICIT, BANDED OR NOT ?
         IMPLCT=IMAS.NE.0
         JBAND=MLJAC.LT.NM1
C -------- COMPUTATION OF THE ROW-DIMENSIONS OF THE 2-ARRAYS ---
C -- JACOBIAN  AND  MATRICES E1, E2
         IF (JBAND) THEN
            LDJAC=MLJAC+MUJAC+1
            LDE1=MLJAC+LDJAC
         ELSE
            MLJAC=NM1
            MUJAC=NM1
            LDJAC=NM1
            LDE1=NM1
         END IF
C -- MASS MATRIX
         IF (IMPLCT) THEN
            IF (MLMAS.NE.NM1) THEN
               LDMAS=MLMAS+MUMAS+1
               IF (JBAND) THEN
                  IJOB=4
               ELSE
                  IJOB=3
               END IF
            ELSE
               MUMAS=NM1
               LDMAS=NM1
               IJOB=5
            END IF
C ------ BANDWITH OF "MAS" NOT SMALLER THAN BANDWITH OF "JAC"
            IF (MLMAS.GT.MLJAC.OR.MUMAS.GT.MUJAC) THEN
               WRITE (6,*) 'BANDWITH OF "MAS" NOT SMALLER THAN BANDWITH OF
     & "JAC"'
               ARRET=.TRUE.
            END IF
         ELSE
            LDMAS=0
            IF (JBAND) THEN
               IJOB=2
            ELSE
               IJOB=1
               IF (N.GT.2.AND.IWORK(1).NE.0) IJOB=7
            END IF
         END IF
         LDMAS2=MAX(1,LDMAS)
C ------ HESSENBERG OPTION ONLY FOR EXPLICIT EQU. WITH FULL JACOBIAN
         IF ((IMPLCT.OR.JBAND).AND.IJOB.EQ.7) THEN
            WRITE(6,*)' HESSENBERG OPTION ONLY FOR EXPLICIT EQUATIONS WITH
     &FULL JACOBIAN'
            ARRET=.TRUE.
         END IF
C ------- PREPARE THE ENTRY-POINTS FOR THE ARRAYS IN WORK -----
         IEZ1=21
         IEZ2=IEZ1+N
         IEZ3=IEZ2+N
         IEY0=IEZ3+N
         IESCAL=IEY0+N
         IEF1=IESCAL+N
         IEF2=IEF1+N
         IEF3=IEF2+N
         IECON=IEF3+N
         IEJAC=IECON+4*N
         IEMAS=IEJAC+N*LDJAC
         IEE1=IEMAS+NM1*LDMAS
         IEE2R=IEE1+NM1*LDE1
         IEE2I=IEE2R+NM1*LDE1
C ------ TOTAL STORAGE REQUIREMENT -----------
         ISTORE=IEE2I+NM1*LDE1-1
         IF(ISTORE.GT.LWORK)THEN
            WRITE(6,*)' INSUFFICIENT STORAGE FOR WORK, MIN. LWORK=',ISTORE
            ARRET=.TRUE.
         END IF
C ------- ENTRY POINTS FOR INTEGER WORKSPACE -----
         IEIP1=21
         IEIP2=IEIP1+NM1
         IEIPH=IEIP2+NM1
C --------- TOTAL REQUIREMENT ---------------
         ISTORE=IEIPH+NM1-1
         IF (ISTORE.GT.LIWORK) THEN
            WRITE(6,*)' INSUFF. STORAGE FOR IWORK, MIN. LIWORK=',ISTORE
            ARRET=.TRUE.
         END IF
C ------ WHEN A FAIL HAS OCCURED, WE RETURN WITH IDID=-1
         IF (ARRET) THEN
            IDID=-1
            RETURN
         END IF
C -------- CALL TO CORE INTEGRATOR ------------
         CALL RADCOR(N,FCN,X,Y,XEND,HMAX,H,RTOL,ATOL,ITOL,
     &      JAC,IJAC,MLJAC,MUJAC,MAS,MLMAS,MUMAS,SOLOUT,IOUT,IDID,
     &      NMAX,UROUND,SAFE,THET,FNEWT,QUOT1,QUOT2,NIT,IJOB,STARTN,
     &      NIND1,NIND2,NIND3,PRED,FACL,FACR,M1,M2,NM1,
     &      IMPLCT,JBAND,LDJAC,LDE1,LDMAS2,WORK(IEZ1),WORK(IEZ2),
     &      WORK(IEZ3),WORK(IEY0),WORK(IESCAL),WORK(IEF1),WORK(IEF2),
     &      WORK(IEF3),WORK(IEJAC),WORK(IEE1),WORK(IEE2R),WORK(IEE2I),
     &      WORK(IEMAS),IWORK(IEIP1),IWORK(IEIP2),IWORK(IEIPH),
     &      WORK(IECON),NFCN,NJAC,NSTEP,NACCPT,
     &      NREJCT,NDEC,NSOL,RPAR,IPAR)
         IWORK(14)=NFCN
         IWORK(15)=NJAC
         IWORK(16)=NSTEP
         IWORK(17)=NACCPT
         IWORK(18)=NREJCT
         IWORK(19)=NDEC
         IWORK(20)=NSOL
C -------- RESTORE TOLERANCES
         EXPM=1.0D0/EXPM
         IF (ITOL.EQ.0) THEN
            QUOT=ATOL(1)/RTOL(1)
            RTOL(1)=(10.0D0*RTOL(1))**EXPM
            ATOL(1)=RTOL(1)*QUOT
         ELSE
            DO I=1,N
               QUOT=ATOL(I)/RTOL(I)
               RTOL(I)=(10.0D0*RTOL(I))**EXPM
               ATOL(I)=RTOL(I)*QUOT
            END DO
         END IF
C ----------- RETURN -----------
         RETURN
      END
C
C     END OF SUBROUTINE RADAU5
C
C ***********************************************************
C
      SUBROUTINE RADCOR(N,FCN,X,Y,XEND,HMAX,H,RTOL,ATOL,ITOL,
     &   JAC,IJAC,MLJAC,MUJAC,MAS,MLMAS,MUMAS,SOLOUT,IOUT,IDID,
     &   NMAX,UROUND,SAFE,THET,FNEWT,QUOT1,QUOT2,NIT,IJOB,STARTN,
     &   NIND1,NIND2,NIND3,PRED,FACL,FACR,M1,M2,NM1,
     &   IMPLCT,BANDED,LDJAC,LDE1,LDMAS,Z1,Z2,Z3,
     &   Y0,SCAL,F1,F2,F3,FJAC,E1,E2R,E2I,FMAS,IP1,IP2,IPHES,
     &   CONT,NFCN,NJAC,NSTEP,NACCPT,NREJCT,NDEC,NSOL,RPAR,IPAR)
C ----------------------------------------------------------
C     CORE INTEGRATOR FOR RADAU5
C     PARAMETERS SAME AS IN RADAU5 WITH WORKSPACE ADDED
C ----------------------------------------------------------
C         DECLARATIONS
C ----------------------------------------------------------
         IMPLICIT DOUBLE PRECISION (A-H,O-Z)
         DIMENSION Y(N),Z1(N),Z2(N),Z3(N),Y0(N),SCAL(N),F1(N),F2(N)
         DIMENSION F3(N)
         DIMENSION FJAC(LDJAC,N),FMAS(LDMAS,NM1),CONT(4*N),WERR(N)
         DIMENSION E1(LDE1,NM1),E2R(LDE1,NM1),E2I(LDE1,NM1)
         DIMENSION ATOL(*),RTOL(*),RPAR(*),IPAR(*)
         INTEGER IP1(NM1),IP2(NM1),IPHES(NM1)
         COMMON /CONRA5/NN,NN2,NN3,NN4,XSOL,HSOL,C2M1,C1M1
         COMMON/LINAL/MLE,MUE,MBJAC,MBB,MDIAG,MDIFF,MBDIAG
         LOGICAL REJECT,FIRST,IMPLCT,BANDED,CALJAC,STARTN,CALHES
         LOGICAL INDEX1,INDEX2,INDEX3,LAST,PRED
         EXTERNAL FCN
C *** *** *** *** *** *** ***
C  INITIALISATIONS
C *** *** *** *** *** *** ***
C --------- DUPLIFY N FOR COMMON BLOCK CONT -----
         NN=N
         NN2=2*N
         NN3=3*N
         LRC=4*N
C -------- CHECK THE INDEX OF THE PROBLEM -----
         INDEX1=NIND1.NE.0
         INDEX2=NIND2.NE.0
         INDEX3=NIND3.NE.0
C ------- COMPUTE MASS MATRIX FOR IMPLICIT CASE ----------
         IF (IMPLCT) CALL MAS(NM1,FMAS,LDMAS,RPAR,IPAR)
C ---------- CONSTANTS ---------
         SQ6=DSQRT(6.D0)
         C1=(4.D0-SQ6)/10.D0
         C2=(4.D0+SQ6)/10.D0
         C1M1=C1-1.D0
         C2M1=C2-1.D0
         C1MC2=C1-C2
         DD1=-(13.D0+7.D0*SQ6)/3.D0
         DD2=(-13.D0+7.D0*SQ6)/3.D0
         DD3=-1.D0/3.D0
         U1=(6.D0+81.D0**(1.D0/3.D0)-9.D0**(1.D0/3.D0))/30.D0
         ALPH=(12.D0-81.D0**(1.D0/3.D0)+9.D0**(1.D0/3.D0))/60.D0
         BETA=(81.D0**(1.D0/3.D0)+9.D0**(1.D0/3.D0))*DSQRT(3.D0)/60.D0
         CNO=ALPH**2+BETA**2
         U1=1.0D0/U1
         ALPH=ALPH/CNO
         BETA=BETA/CNO
         T11=9.1232394870892942792D-02
         T12=-0.14125529502095420843D0
         T13=-3.0029194105147424492D-02
         T21=0.24171793270710701896D0
         T22=0.20412935229379993199D0
         T23=0.38294211275726193779D0
         T31=0.96604818261509293619D0
         TI11=4.3255798900631553510D0
         TI12=0.33919925181580986954D0
         TI13=0.54177053993587487119D0
         TI21=-4.1787185915519047273D0
         TI22=-0.32768282076106238708D0
         TI23=0.47662355450055045196D0
         TI31=-0.50287263494578687595D0
         TI32=2.5719269498556054292D0
         TI33=-0.59603920482822492497D0
         IF (M1.GT.0) IJOB=IJOB+10
         POSNEG=SIGN(1.D0,XEND-X)
         HMAXN=MIN(ABS(HMAX),ABS(XEND-X))
         IF (ABS(H).LE.10.D0*UROUND) H=1.0D-6
         H=MIN(ABS(H),HMAXN)
         H=SIGN(H,POSNEG)
         HOLD=H
         REJECT=.FALSE.
         FIRST=.TRUE.
         LAST=.FALSE.
         IF ((X+H*1.0001D0-XEND)*POSNEG.GE.0.D0) THEN
            H=XEND-X
            LAST=.TRUE.
         END IF
         HOPT=H
         FACCON=1.D0
         CFAC=SAFE*(1+2*NIT)
         NSING=0
         NUNEXPECT=0
         XOLD=X
         IF (IOUT.NE.0) THEN
            IRTRN=1
            NRSOL=1
            XOSOL=XOLD
            XSOL=X
            DO I=1,N
               WERR(I)=0.D0
               CONT(I)=Y(I)
            END DO
            NSOLU=N
            HSOL=HOLD
            CALL SOLOUT(NRSOL,XOSOL,XSOL,Y,CONT,WERR,LRC,NSOLU,
     &                  RPAR,IPAR,IRTRN)
            IF (IRTRN.LT.0) GOTO 179
         END IF
         MLE=MLJAC
         MUE=MUJAC
         MBJAC=MLJAC+MUJAC+1
         MBB=MLMAS+MUMAS+1
         MDIAG=MLE+MUE+1
         MDIFF=MLE+MUE-MUMAS
         MBDIAG=MUMAS+1
         N2=2*N
         N3=3*N
         IF (ITOL.EQ.0) THEN
            DO I=1,N
               SCAL(I)=ATOL(1)+RTOL(1)*ABS(Y(I))
            END DO
         ELSE
            DO I=1,N
               SCAL(I)=ATOL(I)+RTOL(I)*ABS(Y(I))
            END DO
         END IF
         HHFAC=H
         CALL FCN(N,X,Y,Y0,RPAR,IPAR)
         NFCN=NFCN+1
C --- BASIC INTEGRATION STEP
   10    CONTINUE
C *** *** *** *** *** *** ***
C  COMPUTATION OF THE JACOBIAN
C *** *** *** *** *** *** ***
         NJAC=NJAC+1
         IF (IJAC.EQ.0) THEN
C --- COMPUTE JACOBIAN MATRIX NUMERICALLY
            IF (BANDED) THEN
C --- JACOBIAN IS BANDED
               MUJACP=MUJAC+1
               MD=MIN(MBJAC,M2)
               DO MM=1,M1/M2+1
                  DO K=1,MD
                     J=K+(MM-1)*M2
   12                F1(J)=Y(J)
                     F2(J)=DSQRT(UROUND*MAX(1.D-5,ABS(Y(J))))
                     Y(J)=Y(J)+F2(J)
                     J=J+MD
                     IF (J.LE.MM*M2) GOTO 12
                     CALL FCN(N,X,Y,CONT,RPAR,IPAR)
                     J=K+(MM-1)*M2
                     J1=K
                     LBEG=MAX(1,J1-MUJAC)+M1
   14                LEND=MIN(M2,J1+MLJAC)+M1
                     Y(J)=F1(J)
                     MUJACJ=MUJACP-J1-M1
                     DO L=LBEG,LEND
                        FJAC(L+MUJACJ,J)=(CONT(L)-Y0(L))/F2(J)
                     END DO
                     J=J+MD
                     J1=J1+MD
                     LBEG=LEND+1
                     IF (J.LE.MM*M2) GOTO 14
                  END DO
               END DO
            ELSE
C --- JACOBIAN IS FULL
               DO I=1,N
                  YSAFE=Y(I)
                  DELT=DSQRT(UROUND*MAX(1.D-5,ABS(YSAFE)))
                  Y(I)=YSAFE+DELT
                  CALL FCN(N,X,Y,CONT,RPAR,IPAR)
                  IF (IPAR(1).LT.0) THEN
                     Y(I)=YSAFE-DELT
                     CALL FCN(N,X,Y,CONT,RPAR,IPAR)
                     IF (IPAR(1).LT.0) THEN
                        Y(I)=YSAFE
                        GOTO 79
                     END IF
                     DO J=M1+1,N
                        FJAC(J-M1,I)=(Y0(J)-CONT(J))/DELT
                     END DO
                  ELSE
                     DO J=M1+1,N
                        FJAC(J-M1,I)=(CONT(J)-Y0(J))/DELT
                     END DO
                  END IF
                  Y(I)=YSAFE
               END DO
            END IF
         ELSE
C --- COMPUTE JACOBIAN MATRIX ANALYTICALLY
            CALL JAC(N,X,Y,FJAC,LDJAC,RPAR,IPAR)
         END IF
         CALJAC=.TRUE.
         CALHES=.TRUE.
   20    CONTINUE
C --- COMPUTE THE MATRICES E1 AND E2 AND THEIR DECOMPOSITIONS
         FAC1=U1/H
         ALPHN=ALPH/H
         BETAN=BETA/H
         CALL DECOMR(N,FJAC,LDJAC,FMAS,LDMAS,MLMAS,MUMAS,
     &               M1,M2,NM1,FAC1,E1,LDE1,IP1,IER,IJOB,CALHES,IPHES)
         IF (IER.NE.0) GOTO 78
         CALL DECOMC(N,FJAC,LDJAC,FMAS,LDMAS,MLMAS,MUMAS,
     &               M1,M2,NM1,ALPHN,BETAN,E2R,E2I,LDE1,IP2,IER,IJOB)
         IF (IER.NE.0) GOTO 78
         NDEC=NDEC+1
   30    CONTINUE
         NSTEP=NSTEP+1
         IF (NSTEP.GT.NMAX) GOTO 178
         IF (0.1D0*ABS(H).LE.ABS(X)*UROUND) GOTO 177
         IF (INDEX2) THEN
            DO I=NIND1+1,NIND1+NIND2
               SCAL(I)=SCAL(I)/HHFAC
            END DO
         END IF
         IF (INDEX3) THEN
            DO I=NIND1+NIND2+1,NIND1+NIND2+NIND3
               SCAL(I)=SCAL(I)/(HHFAC*HHFAC)
            END DO
         END IF
         XPH=X+H
C *** *** *** *** *** *** ***
C  STARTING VALUES FOR NEWTON ITERATION
C *** *** *** *** *** *** ***
         IF (FIRST.OR.STARTN) THEN
            DO I=1,N
               Z1(I)=0.D0
               Z2(I)=0.D0
               Z3(I)=0.D0
               F1(I)=0.D0
               F2(I)=0.D0
               F3(I)=0.D0
            END DO
         ELSE
            C3Q=H/HOLD
            C1Q=C1*C3Q
            C2Q=C2*C3Q
            DO I=1,N
               AK1=CONT(I+N)
               AK2=CONT(I+N2)
               AK3=CONT(I+N3)
               Z1I=C1Q*(AK1+(C1Q-C2M1)*(AK2+(C1Q-C1M1)*AK3))
               Z2I=C2Q*(AK1+(C2Q-C2M1)*(AK2+(C2Q-C1M1)*AK3))
               Z3I=C3Q*(AK1+(C3Q-C2M1)*(AK2+(C3Q-C1M1)*AK3))
               Z1(I)=Z1I
               Z2(I)=Z2I
               Z3(I)=Z3I
               F1(I)=TI11*Z1I+TI12*Z2I+TI13*Z3I
               F2(I)=TI21*Z1I+TI22*Z2I+TI23*Z3I
               F3(I)=TI31*Z1I+TI32*Z2I+TI33*Z3I
            END DO
         END IF
C *** *** *** *** *** *** ***
C  LOOP FOR THE SIMPLIFIED NEWTON ITERATION
C *** *** *** *** *** *** ***
         NEWT=0
         FACCON=MAX(FACCON,UROUND)**0.8D0
         THETA=ABS(THET)
   40    CONTINUE
         IF (NEWT.GE.NIT) GOTO 78
C ---     COMPUTE THE RIGHT-HAND SIDE
         DO I=1,N
            CONT(I)=Y(I)+Z1(I)
         END DO
         CALL FCN(N,X+C1*H,CONT,Z1,RPAR,IPAR)
         NFCN=NFCN+1
         IF (IPAR(1).LT.0) GOTO 79
         DO I=1,N
            CONT(I)=Y(I)+Z2(I)
         END DO
         CALL FCN(N,X+C2*H,CONT,Z2,RPAR,IPAR)
         NFCN=NFCN+1
         IF (IPAR(1).LT.0) GOTO 79
         DO I=1,N
            CONT(I)=Y(I)+Z3(I)
         END DO
         CALL FCN(N,XPH,CONT,Z3,RPAR,IPAR)
         NFCN=NFCN+1
         IF (IPAR(1).LT.0) GOTO 79
C ---     SOLVE THE LINEAR SYSTEMS
         DO I=1,N
            A1=Z1(I)
            A2=Z2(I)
            A3=Z3(I)
            Z1(I)=TI11*A1+TI12*A2+TI13*A3
            Z2(I)=TI21*A1+TI22*A2+TI23*A3
            Z3(I)=TI31*A1+TI32*A2+TI33*A3
         END DO
         CALL SLVRAD(N,FJAC,LDJAC,MLJAC,MUJAC,FMAS,LDMAS,MLMAS,MUMAS,
     &           M1,M2,NM1,FAC1,ALPHN,BETAN,E1,E2R,E2I,LDE1,Z1,Z2,Z3,
         !   &          F1,F2,F3,CONT,IP1,IP2,IPHES,IER,IJOB)
     &           F1,F2,F3,IP1,IP2,IPHES,IER,IJOB)
         NSOL=NSOL+1
         NEWT=NEWT+1
         DYNO=0.D0
         DO I=1,N
            DENOM=SCAL(I)
            DYNO=DYNO+(Z1(I)/DENOM)**2+(Z2(I)/DENOM)**2
     &       +(Z3(I)/DENOM)**2
         END DO
         DYNO=DSQRT(DYNO/N3)
C ---     BAD CONVERGENCE OR NUMBER OF ITERATIONS TO LARGE
         IF (NEWT.GT.1.AND.NEWT.LT.NIT) THEN
            THQ=DYNO/DYNOLD
            IF (NEWT.EQ.2) THEN
               THETA=THQ
            ELSE
               THETA=SQRT(THQ*THQOLD)
            END IF
            THQOLD=THQ
            IF (THETA.LT.0.99D0) THEN
               FACCON=THETA/(1.0D0-THETA)
               DYTH=FACCON*DYNO*THETA**(NIT-1-NEWT)/FNEWT
               IF (DYTH.GE.1.0D0) THEN
                  QNEWT=DMAX1(1.0D-4,DMIN1(20.0D0,DYTH))
                  HHFAC=.8D0*QNEWT**(-1.0D0/(4.0D0+NIT-1-NEWT))
                  H=HHFAC*H
                  REJECT=.TRUE.
                  LAST=.FALSE.
                  IF (CALJAC) GOTO 20
                  GOTO 10
               END IF
            ELSE
               GOTO 78
            END IF
         END IF
         DYNOLD=MAX(DYNO,UROUND)
         DO I=1,N
            F1I=F1(I)+Z1(I)
            F2I=F2(I)+Z2(I)
            F3I=F3(I)+Z3(I)
            F1(I)=F1I
            F2(I)=F2I
            F3(I)=F3I
            Z1(I)=T11*F1I+T12*F2I+T13*F3I
            Z2(I)=T21*F1I+T22*F2I+T23*F3I
            Z3(I)=T31*F1I+    F2I
         END DO
         IF (FACCON*DYNO.GT.FNEWT) GOTO 40
C --- ERROR ESTIMATION
         CALL ESTRAD (N,FJAC,LDJAC,MLJAC,MUJAC,FMAS,LDMAS,MLMAS,MUMAS,
     &             H,DD1,DD2,DD3,FCN,NFCN,Y0,Y,IJOB,X,M1,M2,NM1,
     &             E1,LDE1,Z1,Z2,Z3,CONT,WERR,F1,F2,IP1,IPHES,SCAL,ERR,
     &             FIRST,REJECT,FAC1,RPAR,IPAR)
C --- COMPUTATION OF HNEW
C --- WE REQUIRE .2<=HNEW/H<=8.
         FAC=MIN(SAFE,CFAC/(NEWT+2*NIT))
         QUOT=MAX(FACR,MIN(FACL,ERR**.25D0/FAC))
         HNEW=H/QUOT
C *** *** *** *** *** *** ***
C  IS THE ERROR SMALL ENOUGH ?
C *** *** *** *** *** *** ***
         IF (ERR.LT.1.D0) THEN
C --- STEP IS ACCEPTED
            FIRST=.FALSE.
            NACCPT=NACCPT+1
            IF (PRED) THEN
C       --- PREDICTIVE CONTROLLER OF GUSTAFSSON
               IF (NACCPT.GT.1) THEN
                  FACGUS=(HACC/H)*(ERR**2/ERRACC)**0.25D0/SAFE
                  FACGUS=MAX(FACR,MIN(FACL,FACGUS))
                  QUOT=MAX(QUOT,FACGUS)
                  HNEW=H/QUOT
               END IF
               HACC=H
               ERRACC=MAX(1.0D-2,ERR)
            END IF
            XOLD=X
            HOLD=H
            X=XPH
            DO I=1,N
               Y(I)=Y(I)+Z3(I)
               Z2I=Z2(I)
               Z1I=Z1(I)
               CONT(I+N)=(Z2I-Z3(I))/C2M1
               AK=(Z1I-Z2I)/C1MC2
               ACONT3=Z1I/C1
               ACONT3=(AK-ACONT3)/C2
               CONT(I+N2)=(AK-CONT(I+N))/C1M1
               CONT(I+N3)=CONT(I+N2)-ACONT3
            END DO
            IF (ITOL.EQ.0) THEN
               DO I=1,N
                  SCAL(I)=ATOL(1)+RTOL(1)*ABS(Y(I))
               END DO
            ELSE
               DO I=1,N
                  SCAL(I)=ATOL(I)+RTOL(I)*ABS(Y(I))
               END DO
            END IF
            IF (IOUT.NE.0) THEN
               NRSOL=NACCPT+1
               XSOL=X
               XOSOL=XOLD
               DO I=1,N
                  CONT(I)=Y(I)
               END DO
               NSOLU=N
               HSOL=HOLD
               CALL SOLOUT(NRSOL,XOSOL,XSOL,Y,CONT,WERR,LRC,NSOLU,
     &                     RPAR,IPAR,IRTRN)
               IF (IRTRN.LT.0) GOTO 179
            END IF
            CALJAC=.FALSE.
            IF (LAST) THEN
               H=HOPT
               IDID=1
               RETURN
            END IF
            CALL FCN(N,X,Y,Y0,RPAR,IPAR)
            NFCN=NFCN+1
            HNEW=POSNEG*MIN(ABS(HNEW),HMAXN)
            HOPT=HNEW
            HOPT=MIN(H,HNEW)
            IF (REJECT) HNEW=POSNEG*MIN(ABS(HNEW),ABS(H))
            REJECT=.FALSE.
            IF ((X+HNEW/QUOT1-XEND)*POSNEG.GE.0.D0) THEN
               H=XEND-X
               LAST=.TRUE.
            ELSE
               QT=HNEW/H
               HHFAC=H
               IF (THETA.LE.THET.AND.QT.GE.QUOT1.AND.QT.LE.QUOT2) 
     1            GOTO 30
               H=HNEW
            END IF
            HHFAC=H
            IF (THETA.LE.THET) GOTO 20
            GOTO 10
         ELSE
C --- STEP IS REJECTED
            REJECT=.TRUE.
            LAST=.FALSE.
            IF (FIRST) THEN
               H=H*0.1D0
               HHFAC=0.1D0
            ELSE
               HHFAC=HNEW/H
               H=HNEW
            END IF
            IF (NACCPT.GE.1) NREJCT=NREJCT+1
            IF (CALJAC) GOTO 20
            GOTO 10
         END IF
C --- UNEXPECTED STEP-REJECTION
   78    CONTINUE
         IF (IER.NE.0) THEN
            NSING=NSING+1
            IF (NSING.GE.5) GOTO 176
         END IF
         H=H*0.5D0
         HHFAC=0.5D0
         REJECT=.TRUE.
         LAST=.FALSE.
         IF (CALJAC) GOTO 20
         GOTO 10
   79    CONTINUE
         NUNEXPECT=NUNEXPECT+1
         IF (NUNEXPECT.GE.10) GOTO 175
         H=H*0.5D0
         HHFAC=0.5D0
         REJECT=.TRUE.
         LAST=.FALSE.
         IF (CALJAC) GOTO 20
         GOTO 10
C --- FAIL EXIT
  175    CONTINUE
         WRITE(6,979)X
         WRITE(6,*) ' REPEATEDLY UNEXPECTED STEP REJECTIONS'
         IDID=-5
         RETURN
  176    CONTINUE
         WRITE(6,979)X
         WRITE(6,*) ' MATRIX IS REPEATEDLY SINGULAR, IER=',IER
         IDID=-4
         RETURN
  177    CONTINUE
         WRITE(6,979)X
         WRITE(6,*) ' STEP SIZE T0O SMALL, H=',H
         IDID=-3
         RETURN
  178    CONTINUE
         WRITE(6,979)X
         WRITE(6,*) ' MORE THAN NMAX =',NMAX,'STEPS ARE NEEDED'
         IDID=-2
         RETURN
C --- EXIT CAUSED BY SOLOUT
  179    CONTINUE
C      WRITE(6,979)X
  979    FORMAT(' EXIT OF RADAU5 AT X=',E18.4)
         IDID=2
         RETURN
      END
C
C     END OF SUBROUTINE RADCOR
C
C ***********************************************************
C
      DOUBLE PRECISION FUNCTION CONTR5(I,X,CONT,LRC)
C ----------------------------------------------------------
C     THIS FUNCTION CAN BE USED FOR CONINUOUS OUTPUT. IT PROVIDES AN
C     APPROXIMATION TO THE I-TH COMPONENT OF THE SOLUTION AT X.
C     IT GIVES THE VALUE OF THE COLLOCATION POLYNOMIAL, DEFINED FOR
C     THE LAST SUCCESSFULLY COMPUTED STEP (BY RADAU5).
C ----------------------------------------------------------
         IMPLICIT DOUBLE PRECISION (A-H,O-Z)
         DIMENSION CONT(LRC)
         COMMON /CONRA5/NN,NN2,NN3,NN4,XSOL,HSOL,C2M1,C1M1
         S=(X-XSOL)/HSOL
         CONTR5=CONT(I)+S*(CONT(I+NN)+(S-C2M1)*(CONT(I+NN2)
     &        +(S-C1M1)*CONT(I+NN3)))
         RETURN
      END
C
C     END OF FUNCTION CONTR5
C
C ***********************************************************

      SUBROUTINE DEC (N, NDIM, A, IP, IER)
C VERSION REAL DOUBLE PRECISION
         INTEGER N,NDIM,IP,IER,NM1,K,KP1,M,I,J
         DOUBLE PRECISION A,T
         DIMENSION A(NDIM,N), IP(N)
C-----------------------------------------------------------------------
C  MATRIX TRIANGULARIZATION BY GAUSSIAN ELIMINATION.
C  INPUT..
C     N = ORDER OF MATRIX.
C     NDIM = DECLARED DIMENSION OF ARRAY  A .
C     A = MATRIX TO BE TRIANGULARIZED.
C  OUTPUT..
C     A(I,J), I.LE.J = UPPER TRIANGULAR FACTOR, U .
C     A(I,J), I.GT.J = MULTIPLIERS = LOWER TRIANGULAR FACTOR, I - L.
C     IP(K), K.LT.N = INDEX OF K-TH PIVOT ROW.
C     IP(N) = (-1)**(NUMBER OF INTERCHANGES) OR O .
C     IER = 0 IF MATRIX A IS NONSINGULAR, OR K IF FOUND TO BE
C           SINGULAR AT STAGE K.
C  USE  SOL  TO OBTAIN SOLUTION OF LINEAR SYSTEM.
C  DETERM(A) = IP(N)*A(1,1)*A(2,2)*...*A(N,N).
C  IF IP(N)=O, A IS SINGULAR, SOL WILL DIVIDE BY ZERO.
C
C  REFERENCE..
C     C. B. MOLER, ALGORITHM 423, LINEAR EQUATION SOLVER,
C     C.A.C.M. 15 (1972), P. 274.
C-----------------------------------------------------------------------
         IER = 0
         IP(N) = 1
         IF (N .EQ. 1) GO TO 70
         NM1 = N - 1
         DO 60 K = 1,NM1
            KP1 = K + 1
            M = K
            DO 10 I = KP1,N
               IF (DABS(A(I,K)) .GT. DABS(A(M,K))) M = I
   10       CONTINUE
            IP(K) = M
            T = A(M,K)
            IF (M .EQ. K) GO TO 20
            IP(N) = -IP(N)
            A(M,K) = A(K,K)
            A(K,K) = T
   20       CONTINUE
            IF (T .EQ. 0.D0) GO TO 80
            T = 1.D0/T
            DO 30 I = KP1,N
               A(I,K) = -A(I,K)*T
   30       CONTINUE
            DO 50 J = KP1,N
               T = A(M,J)
               A(M,J) = A(K,J)
               A(K,J) = T
               IF (T .EQ. 0.D0) GO TO 45
               DO 40 I = KP1,N
   40          A(I,J) = A(I,J) + A(I,K)*T
   45          CONTINUE
   50       CONTINUE
   60    CONTINUE
   70    K = N
         IF (A(N,N) .EQ. 0.D0) GO TO 80
         RETURN
   80    IER = K
         IP(N) = 0
         RETURN
C----------------------- END OF SUBROUTINE DEC -------------------------
      END
C
C
      SUBROUTINE SOL (N, NDIM, A, B, IP)
C VERSION REAL DOUBLE PRECISION
         INTEGER N,NDIM,IP,NM1,K,KP1,M,I,KB,KM1
         DOUBLE PRECISION A,B,T
         DIMENSION A(NDIM,N), B(N), IP(N)
C-----------------------------------------------------------------------
C  SOLUTION OF LINEAR SYSTEM, A*X = B .
C  INPUT..
C    N = ORDER OF MATRIX.
C    NDIM = DECLARED DIMENSION OF ARRAY  A .
C    A = TRIANGULARIZED MATRIX OBTAINED FROM DEC.
C    B = RIGHT HAND SIDE VECTOR.
C    IP = PIVOT VECTOR OBTAINED FROM DEC.
C  DO NOT USE IF DEC HAS SET IER .NE. 0.
C  OUTPUT..
C    B = SOLUTION VECTOR, X .
C-----------------------------------------------------------------------
         IF (N .EQ. 1) GO TO 50
         NM1 = N - 1
         DO 20 K = 1,NM1
            KP1 = K + 1
            M = IP(K)
            T = B(M)
            B(M) = B(K)
            B(K) = T
            DO 10 I = KP1,N
   10       B(I) = B(I) + A(I,K)*T
   20    CONTINUE
         DO 40 KB = 1,NM1
            KM1 = N - KB
            K = KM1 + 1
            B(K) = B(K)/A(K,K)
            T = -B(K)
            DO 30 I = 1,KM1
   30       B(I) = B(I) + A(I,K)*T
   40    CONTINUE
   50    B(1) = B(1)/A(1,1)
         RETURN
C----------------------- END OF SUBROUTINE SOL -------------------------
      END
c
c
      SUBROUTINE DECH (N, NDIM, A, LB, IP, IER)
C VERSION REAL DOUBLE PRECISION
         INTEGER N,NDIM,IP,IER,NM1,K,KP1,M,I,J,LB,NA
         DOUBLE PRECISION A,T
         DIMENSION A(NDIM,N), IP(N)
C-----------------------------------------------------------------------
C  MATRIX TRIANGULARIZATION BY GAUSSIAN ELIMINATION OF A HESSENBERG
C  MATRIX WITH LOWER BANDWIDTH LB
C  INPUT..
C     N = ORDER OF MATRIX A.
C     NDIM = DECLARED DIMENSION OF ARRAY  A .
C     A = MATRIX TO BE TRIANGULARIZED.
C     LB = LOWER BANDWIDTH OF A (DIAGONAL IS NOT COUNTED, LB.GE.1).
C  OUTPUT..
C     A(I,J), I.LE.J = UPPER TRIANGULAR FACTOR, U .
C     A(I,J), I.GT.J = MULTIPLIERS = LOWER TRIANGULAR FACTOR, I - L.
C     IP(K), K.LT.N = INDEX OF K-TH PIVOT ROW.
C     IP(N) = (-1)**(NUMBER OF INTERCHANGES) OR O .
C     IER = 0 IF MATRIX A IS NONSINGULAR, OR K IF FOUND TO BE
C           SINGULAR AT STAGE K.
C  USE  SOLH  TO OBTAIN SOLUTION OF LINEAR SYSTEM.
C  DETERM(A) = IP(N)*A(1,1)*A(2,2)*...*A(N,N).
C  IF IP(N)=O, A IS SINGULAR, SOL WILL DIVIDE BY ZERO.
C
C  REFERENCE..
C     THIS IS A SLIGHT MODIFICATION OF
C     C. B. MOLER, ALGORITHM 423, LINEAR EQUATION SOLVER,
C     C.A.C.M. 15 (1972), P. 274.
C-----------------------------------------------------------------------
         IER = 0
         IP(N) = 1
         IF (N .EQ. 1) GO TO 70
         NM1 = N - 1
         DO 60 K = 1,NM1
            KP1 = K + 1
            M = K
            NA = MIN0(N,LB+K)
            DO 10 I = KP1,NA
               IF (DABS(A(I,K)) .GT. DABS(A(M,K))) M = I
   10       CONTINUE
            IP(K) = M
            T = A(M,K)
            IF (M .EQ. K) GO TO 20
            IP(N) = -IP(N)
            A(M,K) = A(K,K)
            A(K,K) = T
   20       CONTINUE
            IF (T .EQ. 0.D0) GO TO 80
            T = 1.D0/T
            DO 30 I = KP1,NA
   30       A(I,K) = -A(I,K)*T
            DO 50 J = KP1,N
               T = A(M,J)
               A(M,J) = A(K,J)
               A(K,J) = T
               IF (T .EQ. 0.D0) GO TO 45
               DO 40 I = KP1,NA
   40          A(I,J) = A(I,J) + A(I,K)*T
   45          CONTINUE
   50       CONTINUE
   60    CONTINUE
   70    K = N
         IF (A(N,N) .EQ. 0.D0) GO TO 80
         RETURN
   80    IER = K
         IP(N) = 0
         RETURN
C----------------------- END OF SUBROUTINE DECH ------------------------
      END
C
C
      SUBROUTINE SOLH (N, NDIM, A, LB, B, IP)
C VERSION REAL DOUBLE PRECISION
         INTEGER N,NDIM,IP,NM1,K,KP1,M,I,KB,KM1,LB,NA
         DOUBLE PRECISION A,B,T
         DIMENSION A(NDIM,N), B(N), IP(N)
C-----------------------------------------------------------------------
C  SOLUTION OF LINEAR SYSTEM, A*X = B .
C  INPUT..
C    N = ORDER OF MATRIX A.
C    NDIM = DECLARED DIMENSION OF ARRAY  A .
C    A = TRIANGULARIZED MATRIX OBTAINED FROM DECH.
C    LB = LOWER BANDWIDTH OF A.
C    B = RIGHT HAND SIDE VECTOR.
C    IP = PIVOT VECTOR OBTAINED FROM DEC.
C  DO NOT USE IF DECH HAS SET IER .NE. 0.
C  OUTPUT..
C    B = SOLUTION VECTOR, X .
C-----------------------------------------------------------------------
         IF (N .EQ. 1) GO TO 50
         NM1 = N - 1
         DO 20 K = 1,NM1
            KP1 = K + 1
            M = IP(K)
            T = B(M)
            B(M) = B(K)
            B(K) = T
            NA = MIN0(N,LB+K)
            DO 10 I = KP1,NA
   10       B(I) = B(I) + A(I,K)*T
   20    CONTINUE
         DO 40 KB = 1,NM1
            KM1 = N - KB
            K = KM1 + 1
            B(K) = B(K)/A(K,K)
            T = -B(K)
            DO 30 I = 1,KM1
   30       B(I) = B(I) + A(I,K)*T
   40    CONTINUE
   50    B(1) = B(1)/A(1,1)
         RETURN
C----------------------- END OF SUBROUTINE SOLH ------------------------
      END
C
      SUBROUTINE DECC (N, NDIM, AR, AI, IP, IER)
C VERSION COMPLEX DOUBLE PRECISION
         IMPLICIT REAL*8 (A-H,O-Z)
         INTEGER N,NDIM,IP,IER,NM1,K,KP1,M,I,J
         DIMENSION AR(NDIM,N), AI(NDIM,N), IP(N)
C-----------------------------------------------------------------------
C  MATRIX TRIANGULARIZATION BY GAUSSIAN ELIMINATION
C  ------ MODIFICATION FOR COMPLEX MATRICES --------
C  INPUT..
C     N = ORDER OF MATRIX.
C     NDIM = DECLARED DIMENSION OF ARRAYS  AR AND AI .
C     (AR, AI) = MATRIX TO BE TRIANGULARIZED.
C  OUTPUT..
C     AR(I,J), I.LE.J = UPPER TRIANGULAR FACTOR, U ; REAL PART.
C     AI(I,J), I.LE.J = UPPER TRIANGULAR FACTOR, U ; IMAGINARY PART.
C     AR(I,J), I.GT.J = MULTIPLIERS = LOWER TRIANGULAR FACTOR, I - L.
C                                                    REAL PART.
C     AI(I,J), I.GT.J = MULTIPLIERS = LOWER TRIANGULAR FACTOR, I - L.
C                                                    IMAGINARY PART.
C     IP(K), K.LT.N = INDEX OF K-TH PIVOT ROW.
C     IP(N) = (-1)**(NUMBER OF INTERCHANGES) OR O .
C     IER = 0 IF MATRIX A IS NONSINGULAR, OR K IF FOUND TO BE
C           SINGULAR AT STAGE K.
C  USE  SOL  TO OBTAIN SOLUTION OF LINEAR SYSTEM.
C  IF IP(N)=O, A IS SINGULAR, SOL WILL DIVIDE BY ZERO.
C
C  REFERENCE..
C     C. B. MOLER, ALGORITHM 423, LINEAR EQUATION SOLVER,
C     C.A.C.M. 15 (1972), P. 274.
C-----------------------------------------------------------------------
         IER = 0
         IP(N) = 1
         IF (N .EQ. 1) GO TO 70
         NM1 = N - 1
         DO 60 K = 1,NM1
            KP1 = K + 1
            M = K
            DO 10 I = KP1,N
               IF (DABS(AR(I,K))+DABS(AI(I,K)) .GT.
     &               DABS(AR(M,K))+DABS(AI(M,K))) M = I
   10       CONTINUE
            IP(K) = M
            TR = AR(M,K)
            TI = AI(M,K)
            IF (M .EQ. K) GO TO 20
            IP(N) = -IP(N)
            AR(M,K) = AR(K,K)
            AI(M,K) = AI(K,K)
            AR(K,K) = TR
            AI(K,K) = TI
   20       CONTINUE
            IF (DABS(TR)+DABS(TI) .EQ. 0.D0) GO TO 80
            DEN=TR*TR+TI*TI
            TR=TR/DEN
            TI=-TI/DEN
            DO 30 I = KP1,N
               PRODR=AR(I,K)*TR-AI(I,K)*TI
               PRODI=AI(I,K)*TR+AR(I,K)*TI
               AR(I,K)=-PRODR
               AI(I,K)=-PRODI
   30       CONTINUE
            DO 50 J = KP1,N
               TR = AR(M,J)
               TI = AI(M,J)
               AR(M,J) = AR(K,J)
               AI(M,J) = AI(K,J)
               AR(K,J) = TR
               AI(K,J) = TI
               IF (DABS(TR)+DABS(TI) .EQ. 0.D0) GO TO 48
               IF (TI .EQ. 0.D0) THEN
                  DO 40 I = KP1,N
                     PRODR=AR(I,K)*TR
                     PRODI=AI(I,K)*TR
                     AR(I,J) = AR(I,J) + PRODR
                     AI(I,J) = AI(I,J) + PRODI
   40             CONTINUE
                  GO TO 48
               END IF
               IF (TR .EQ. 0.D0) THEN
                  DO 45 I = KP1,N
                     PRODR=-AI(I,K)*TI
                     PRODI=AR(I,K)*TI
                     AR(I,J) = AR(I,J) + PRODR
                     AI(I,J) = AI(I,J) + PRODI
   45             CONTINUE
                  GO TO 48
               END IF
               DO 47 I = KP1,N
                  PRODR=AR(I,K)*TR-AI(I,K)*TI
                  PRODI=AI(I,K)*TR+AR(I,K)*TI
                  AR(I,J) = AR(I,J) + PRODR
                  AI(I,J) = AI(I,J) + PRODI
   47          CONTINUE
   48          CONTINUE
   50       CONTINUE
   60    CONTINUE
   70    K = N
         IF (DABS(AR(N,N))+DABS(AI(N,N)) .EQ. 0.D0) GO TO 80
         RETURN
   80    IER = K
         IP(N) = 0
         RETURN
C----------------------- END OF SUBROUTINE DECC ------------------------
      END
C
C
      SUBROUTINE SOLC (N, NDIM, AR, AI, BR, BI, IP)
C VERSION COMPLEX DOUBLE PRECISION
         IMPLICIT REAL*8 (A-H,O-Z)
         INTEGER N,NDIM,IP,NM1,K,KP1,M,I,KB,KM1
         DIMENSION AR(NDIM,N), AI(NDIM,N), BR(N), BI(N), IP(N)
C-----------------------------------------------------------------------
C  SOLUTION OF LINEAR SYSTEM, A*X = B .
C  INPUT..
C    N = ORDER OF MATRIX.
C    NDIM = DECLARED DIMENSION OF ARRAYS  AR AND AI.
C    (AR,AI) = TRIANGULARIZED MATRIX OBTAINED FROM DEC.
C    (BR,BI) = RIGHT HAND SIDE VECTOR.
C    IP = PIVOT VECTOR OBTAINED FROM DEC.
C  DO NOT USE IF DEC HAS SET IER .NE. 0.
C  OUTPUT..
C    (BR,BI) = SOLUTION VECTOR, X .
C-----------------------------------------------------------------------
         IF (N .EQ. 1) GO TO 50
         NM1 = N - 1
         DO 20 K = 1,NM1
            KP1 = K + 1
            M = IP(K)
            TR = BR(M)
            TI = BI(M)
            BR(M) = BR(K)
            BI(M) = BI(K)
            BR(K) = TR
            BI(K) = TI
            DO 10 I = KP1,N
               PRODR=AR(I,K)*TR-AI(I,K)*TI
               PRODI=AI(I,K)*TR+AR(I,K)*TI
               BR(I) = BR(I) + PRODR
               BI(I) = BI(I) + PRODI
   10       CONTINUE
   20    CONTINUE
         DO 40 KB = 1,NM1
            KM1 = N - KB
            K = KM1 + 1
            DEN=AR(K,K)*AR(K,K)+AI(K,K)*AI(K,K)
            PRODR=BR(K)*AR(K,K)+BI(K)*AI(K,K)
            PRODI=BI(K)*AR(K,K)-BR(K)*AI(K,K)
            BR(K)=PRODR/DEN
            BI(K)=PRODI/DEN
            TR = -BR(K)
            TI = -BI(K)
            DO 30 I = 1,KM1
               PRODR=AR(I,K)*TR-AI(I,K)*TI
               PRODI=AI(I,K)*TR+AR(I,K)*TI
               BR(I) = BR(I) + PRODR
               BI(I) = BI(I) + PRODI
   30       CONTINUE
   40    CONTINUE
   50    CONTINUE
         DEN=AR(1,1)*AR(1,1)+AI(1,1)*AI(1,1)
         PRODR=BR(1)*AR(1,1)+BI(1)*AI(1,1)
         PRODI=BI(1)*AR(1,1)-BR(1)*AI(1,1)
         BR(1)=PRODR/DEN
         BI(1)=PRODI/DEN
         RETURN
C----------------------- END OF SUBROUTINE SOLC ------------------------
      END
C
C
      SUBROUTINE DECHC (N, NDIM, AR, AI, LB, IP, IER)
C VERSION COMPLEX DOUBLE PRECISION
         IMPLICIT REAL*8 (A-H,O-Z)
         INTEGER N,NDIM,IP,IER,NM1,K,KP1,M,I,J
         DIMENSION AR(NDIM,N), AI(NDIM,N), IP(N)
C-----------------------------------------------------------------------
C  MATRIX TRIANGULARIZATION BY GAUSSIAN ELIMINATION
C  ------ MODIFICATION FOR COMPLEX MATRICES --------
C  INPUT..
C     N = ORDER OF MATRIX.
C     NDIM = DECLARED DIMENSION OF ARRAYS  AR AND AI .
C     (AR, AI) = MATRIX TO BE TRIANGULARIZED.
C  OUTPUT..
C     AR(I,J), I.LE.J = UPPER TRIANGULAR FACTOR, U ; REAL PART.
C     AI(I,J), I.LE.J = UPPER TRIANGULAR FACTOR, U ; IMAGINARY PART.
C     AR(I,J), I.GT.J = MULTIPLIERS = LOWER TRIANGULAR FACTOR, I - L.
C                                                    REAL PART.
C     AI(I,J), I.GT.J = MULTIPLIERS = LOWER TRIANGULAR FACTOR, I - L.
C                                                    IMAGINARY PART.
C     LB = LOWER BANDWIDTH OF A (DIAGONAL NOT COUNTED), LB.GE.1.
C     IP(K), K.LT.N = INDEX OF K-TH PIVOT ROW.
C     IP(N) = (-1)**(NUMBER OF INTERCHANGES) OR O .
C     IER = 0 IF MATRIX A IS NONSINGULAR, OR K IF FOUND TO BE
C           SINGULAR AT STAGE K.
C  USE  SOL  TO OBTAIN SOLUTION OF LINEAR SYSTEM.
C  IF IP(N)=O, A IS SINGULAR, SOL WILL DIVIDE BY ZERO.
C
C  REFERENCE..
C     C. B. MOLER, ALGORITHM 423, LINEAR EQUATION SOLVER,
C     C.A.C.M. 15 (1972), P. 274.
C-----------------------------------------------------------------------
         IER = 0
         IP(N) = 1
         IF (LB .EQ. 0) GO TO 70
         IF (N .EQ. 1) GO TO 70
         NM1 = N - 1
         DO 60 K = 1,NM1
            KP1 = K + 1
            M = K
            NA = MIN0(N,LB+K)
            DO 10 I = KP1,NA
               IF (DABS(AR(I,K))+DABS(AI(I,K)) .GT.
     &               DABS(AR(M,K))+DABS(AI(M,K))) M = I
   10       CONTINUE
            IP(K) = M
            TR = AR(M,K)
            TI = AI(M,K)
            IF (M .EQ. K) GO TO 20
            IP(N) = -IP(N)
            AR(M,K) = AR(K,K)
            AI(M,K) = AI(K,K)
            AR(K,K) = TR
            AI(K,K) = TI
   20       CONTINUE
            IF (DABS(TR)+DABS(TI) .EQ. 0.D0) GO TO 80
            DEN=TR*TR+TI*TI
            TR=TR/DEN
            TI=-TI/DEN
            DO 30 I = KP1,NA
               PRODR=AR(I,K)*TR-AI(I,K)*TI
               PRODI=AI(I,K)*TR+AR(I,K)*TI
               AR(I,K)=-PRODR
               AI(I,K)=-PRODI
   30       CONTINUE
            DO 50 J = KP1,N
               TR = AR(M,J)
               TI = AI(M,J)
               AR(M,J) = AR(K,J)
               AI(M,J) = AI(K,J)
               AR(K,J) = TR
               AI(K,J) = TI
               IF (DABS(TR)+DABS(TI) .EQ. 0.D0) GO TO 48
               IF (TI .EQ. 0.D0) THEN
                  DO 40 I = KP1,NA
                     PRODR=AR(I,K)*TR
                     PRODI=AI(I,K)*TR
                     AR(I,J) = AR(I,J) + PRODR
                     AI(I,J) = AI(I,J) + PRODI
   40             CONTINUE
                  GO TO 48
               END IF
               IF (TR .EQ. 0.D0) THEN
                  DO 45 I = KP1,NA
                     PRODR=-AI(I,K)*TI
                     PRODI=AR(I,K)*TI
                     AR(I,J) = AR(I,J) + PRODR
                     AI(I,J) = AI(I,J) + PRODI
   45             CONTINUE
                  GO TO 48
               END IF
               DO 47 I = KP1,NA
                  PRODR=AR(I,K)*TR-AI(I,K)*TI
                  PRODI=AI(I,K)*TR+AR(I,K)*TI
                  AR(I,J) = AR(I,J) + PRODR
                  AI(I,J) = AI(I,J) + PRODI
   47          CONTINUE
   48          CONTINUE
   50       CONTINUE
   60    CONTINUE
   70    K = N
         IF (DABS(AR(N,N))+DABS(AI(N,N)) .EQ. 0.D0) GO TO 80
         RETURN
   80    IER = K
         IP(N) = 0
         RETURN
C----------------------- END OF SUBROUTINE DECHC -----------------------
      END
C
C
      SUBROUTINE SOLHC (N, NDIM, AR, AI, LB, BR, BI, IP)
C VERSION COMPLEX DOUBLE PRECISION
         IMPLICIT REAL*8 (A-H,O-Z)
         INTEGER N,NDIM,IP,NM1,K,KP1,M,I,KB,KM1
         DIMENSION AR(NDIM,N), AI(NDIM,N), BR(N), BI(N), IP(N)
C-----------------------------------------------------------------------
C  SOLUTION OF LINEAR SYSTEM, A*X = B .
C  INPUT..
C    N = ORDER OF MATRIX.
C    NDIM = DECLARED DIMENSION OF ARRAYS  AR AND AI.
C    (AR,AI) = TRIANGULARIZED MATRIX OBTAINED FROM DEC.
C    (BR,BI) = RIGHT HAND SIDE VECTOR.
C    LB = LOWER BANDWIDTH OF A.
C    IP = PIVOT VECTOR OBTAINED FROM DEC.
C  DO NOT USE IF DEC HAS SET IER .NE. 0.
C  OUTPUT..
C    (BR,BI) = SOLUTION VECTOR, X .
C-----------------------------------------------------------------------
         IF (N .EQ. 1) GO TO 50
         NM1 = N - 1
         IF (LB .EQ. 0) GO TO 25
         DO 20 K = 1,NM1
            KP1 = K + 1
            M = IP(K)
            TR = BR(M)
            TI = BI(M)
            BR(M) = BR(K)
            BI(M) = BI(K)
            BR(K) = TR
            BI(K) = TI
            DO 10 I = KP1,MIN0(N,LB+K)
               PRODR=AR(I,K)*TR-AI(I,K)*TI
               PRODI=AI(I,K)*TR+AR(I,K)*TI
               BR(I) = BR(I) + PRODR
               BI(I) = BI(I) + PRODI
   10       CONTINUE
   20    CONTINUE
   25    CONTINUE
         DO 40 KB = 1,NM1
            KM1 = N - KB
            K = KM1 + 1
            DEN=AR(K,K)*AR(K,K)+AI(K,K)*AI(K,K)
            PRODR=BR(K)*AR(K,K)+BI(K)*AI(K,K)
            PRODI=BI(K)*AR(K,K)-BR(K)*AI(K,K)
            BR(K)=PRODR/DEN
            BI(K)=PRODI/DEN
            TR = -BR(K)
            TI = -BI(K)
            DO 30 I = 1,KM1
               PRODR=AR(I,K)*TR-AI(I,K)*TI
               PRODI=AI(I,K)*TR+AR(I,K)*TI
               BR(I) = BR(I) + PRODR
               BI(I) = BI(I) + PRODI
   30       CONTINUE
   40    CONTINUE
   50    CONTINUE
         DEN=AR(1,1)*AR(1,1)+AI(1,1)*AI(1,1)
         PRODR=BR(1)*AR(1,1)+BI(1)*AI(1,1)
         PRODI=BI(1)*AR(1,1)-BR(1)*AI(1,1)
         BR(1)=PRODR/DEN
         BI(1)=PRODI/DEN
         RETURN
C----------------------- END OF SUBROUTINE SOLHC -----------------------
      END
C
      SUBROUTINE DECB (N, NDIM, A, ML, MU, IP, IER)
         REAL*8 A,T
         DIMENSION A(NDIM,N), IP(N)
C-----------------------------------------------------------------------
C  MATRIX TRIANGULARIZATION BY GAUSSIAN ELIMINATION OF A BANDED
C  MATRIX WITH LOWER BANDWIDTH ML AND UPPER BANDWIDTH MU
C  INPUT..
C     N       ORDER OF THE ORIGINAL MATRIX A.
C     NDIM    DECLARED DIMENSION OF ARRAY  A.
C     A       CONTAINS THE MATRIX IN BAND STORAGE.   THE COLUMNS
C                OF THE MATRIX ARE STORED IN THE COLUMNS OF  A  AND
C                THE DIAGONALS OF THE MATRIX ARE STORED IN ROWS
C                ML+1 THROUGH 2*ML+MU+1 OF  A.
C     ML      LOWER BANDWIDTH OF A (DIAGONAL IS NOT COUNTED).
C     MU      UPPER BANDWIDTH OF A (DIAGONAL IS NOT COUNTED).
C  OUTPUT..
C     A       AN UPPER TRIANGULAR MATRIX IN BAND STORAGE AND
C                THE MULTIPLIERS WHICH WERE USED TO OBTAIN IT.
C     IP      INDEX VECTOR OF PIVOT INDICES.
C     IP(N)   (-1)**(NUMBER OF INTERCHANGES) OR O .
C     IER     = 0 IF MATRIX A IS NONSINGULAR, OR  = K IF FOUND TO BE
C                SINGULAR AT STAGE K.
C  USE  SOLB  TO OBTAIN SOLUTION OF LINEAR SYSTEM.
C  DETERM(A) = IP(N)*A(MD,1)*A(MD,2)*...*A(MD,N)  WITH MD=ML+MU+1.
C  IF IP(N)=O, A IS SINGULAR, SOLB WILL DIVIDE BY ZERO.
C
C  REFERENCE..
C     THIS IS A MODIFICATION OF
C     C. B. MOLER, ALGORITHM 423, LINEAR EQUATION SOLVER,
C     C.A.C.M. 15 (1972), P. 274.
C-----------------------------------------------------------------------
         IER = 0
         IP(N) = 1
         MD = ML + MU + 1
         MD1 = MD + 1
         JU = 0
         IF (ML .EQ. 0) GO TO 70
         IF (N .EQ. 1) GO TO 70
         IF (N .LT. MU+2) GO TO 7
         DO 5 J = MU+2,N
            DO 5 I = 1,ML
    5    A(I,J) = 0.D0
    7    NM1 = N - 1
         DO 60 K = 1,NM1
            KP1 = K + 1
            M = MD
            MDL = MIN(ML,N-K) + MD
            DO 10 I = MD1,MDL
               IF (DABS(A(I,K)) .GT. DABS(A(M,K))) M = I
   10       CONTINUE
            IP(K) = M + K - MD
            T = A(M,K)
            IF (M .EQ. MD) GO TO 20
            IP(N) = -IP(N)
            A(M,K) = A(MD,K)
            A(MD,K) = T
   20       CONTINUE
            IF (T .EQ. 0.D0) GO TO 80
            T = 1.D0/T
            DO 30 I = MD1,MDL
   30       A(I,K) = -A(I,K)*T
            JU = MIN0(MAX0(JU,MU+IP(K)),N)
            MM = MD
            IF (JU .LT. KP1) GO TO 55
            DO 50 J = KP1,JU
               M = M - 1
               MM = MM - 1
               T = A(M,J)
               IF (M .EQ. MM) GO TO 35
               A(M,J) = A(MM,J)
               A(MM,J) = T
   35          CONTINUE
               IF (T .EQ. 0.D0) GO TO 45
               JK = J - K
               DO 40 I = MD1,MDL
                  IJK = I - JK
   40          A(IJK,J) = A(IJK,J) + A(I,K)*T
   45          CONTINUE
   50       CONTINUE
   55       CONTINUE
   60    CONTINUE
   70    K = N
         IF (A(MD,N) .EQ. 0.D0) GO TO 80
         RETURN
   80    IER = K
         IP(N) = 0
         RETURN
C----------------------- END OF SUBROUTINE DECB ------------------------
      END
C
C
      SUBROUTINE SOLB (N, NDIM, A, ML, MU, B, IP)
         REAL*8 A,B,T
         DIMENSION A(NDIM,N), B(N), IP(N)
C-----------------------------------------------------------------------
C  SOLUTION OF LINEAR SYSTEM, A*X = B .
C  INPUT..
C    N      ORDER OF MATRIX A.
C    NDIM   DECLARED DIMENSION OF ARRAY  A .
C    A      TRIANGULARIZED MATRIX OBTAINED FROM DECB.
C    ML     LOWER BANDWIDTH OF A (DIAGONAL IS NOT COUNTED).
C    MU     UPPER BANDWIDTH OF A (DIAGONAL IS NOT COUNTED).
C    B      RIGHT HAND SIDE VECTOR.
C    IP     PIVOT VECTOR OBTAINED FROM DECB.
C  DO NOT USE IF DECB HAS SET IER .NE. 0.
C  OUTPUT..
C    B      SOLUTION VECTOR, X .
C-----------------------------------------------------------------------
         MD = ML + MU + 1
         MD1 = MD + 1
         MDM = MD - 1
         NM1 = N - 1
         IF (ML .EQ. 0) GO TO 25
         IF (N .EQ. 1) GO TO 50
         DO 20 K = 1,NM1
            M = IP(K)
            T = B(M)
            B(M) = B(K)
            B(K) = T
            MDL = MIN(ML,N-K) + MD
            DO 10 I = MD1,MDL
               IMD = I + K - MD
   10       B(IMD) = B(IMD) + A(I,K)*T
   20    CONTINUE
   25    CONTINUE
         DO 40 KB = 1,NM1
            K = N + 1 - KB
            B(K) = B(K)/A(MD,K)
            T = -B(K)
            KMD = MD - K
            LM = MAX0(1,KMD+1)
            DO 30 I = LM,MDM
               IMD = I - KMD
   30       B(IMD) = B(IMD) + A(I,K)*T
   40    CONTINUE
   50    B(1) = B(1)/A(MD,1)
         RETURN
C----------------------- END OF SUBROUTINE SOLB ------------------------
      END
C
      SUBROUTINE DECBC (N, NDIM, AR, AI, ML, MU, IP, IER)
         IMPLICIT REAL*8 (A-H,O-Z)
         DIMENSION AR(NDIM,N), AI(NDIM,N), IP(N)
C-----------------------------------------------------------------------
C  MATRIX TRIANGULARIZATION BY GAUSSIAN ELIMINATION OF A BANDED COMPLEX
C  MATRIX WITH LOWER BANDWIDTH ML AND UPPER BANDWIDTH MU
C  INPUT..
C     N       ORDER OF THE ORIGINAL MATRIX A.
C     NDIM    DECLARED DIMENSION OF ARRAY  A.
C     AR, AI     CONTAINS THE MATRIX IN BAND STORAGE.   THE COLUMNS
C                OF THE MATRIX ARE STORED IN THE COLUMNS OF  AR (REAL
C                PART) AND AI (IMAGINARY PART)  AND
C                THE DIAGONALS OF THE MATRIX ARE STORED IN ROWS
C                ML+1 THROUGH 2*ML+MU+1 OF  AR AND AI.
C     ML      LOWER BANDWIDTH OF A (DIAGONAL IS NOT COUNTED).
C     MU      UPPER BANDWIDTH OF A (DIAGONAL IS NOT COUNTED).
C  OUTPUT..
C     AR, AI  AN UPPER TRIANGULAR MATRIX IN BAND STORAGE AND
C                THE MULTIPLIERS WHICH WERE USED TO OBTAIN IT.
C     IP      INDEX VECTOR OF PIVOT INDICES.
C     IP(N)   (-1)**(NUMBER OF INTERCHANGES) OR O .
C     IER     = 0 IF MATRIX A IS NONSINGULAR, OR  = K IF FOUND TO BE
C                SINGULAR AT STAGE K.
C  USE  SOLBC  TO OBTAIN SOLUTION OF LINEAR SYSTEM.
C  DETERM(A) = IP(N)*A(MD,1)*A(MD,2)*...*A(MD,N)  WITH MD=ML+MU+1.
C  IF IP(N)=O, A IS SINGULAR, SOLBC WILL DIVIDE BY ZERO.
C
C  REFERENCE..
C     THIS IS A MODIFICATION OF
C     C. B. MOLER, ALGORITHM 423, LINEAR EQUATION SOLVER,
C     C.A.C.M. 15 (1972), P. 274.
C-----------------------------------------------------------------------
         IER = 0
         IP(N) = 1
         MD = ML + MU + 1
         MD1 = MD + 1
         JU = 0
         IF (ML .EQ. 0) GO TO 70
         IF (N .EQ. 1) GO TO 70
         IF (N .LT. MU+2) GO TO 7
         DO 5 J = MU+2,N
            DO 5 I = 1,ML
               AR(I,J) = 0.D0
               AI(I,J) = 0.D0
    5    CONTINUE
    7    NM1 = N - 1
         DO 60 K = 1,NM1
            KP1 = K + 1
            M = MD
            MDL = MIN(ML,N-K) + MD
            DO 10 I = MD1,MDL
               IF (DABS(AR(I,K))+DABS(AI(I,K)) .GT.
     &               DABS(AR(M,K))+DABS(AI(M,K))) M = I
   10       CONTINUE
            IP(K) = M + K - MD
            TR = AR(M,K)
            TI = AI(M,K)
            IF (M .EQ. MD) GO TO 20
            IP(N) = -IP(N)
            AR(M,K) = AR(MD,K)
            AI(M,K) = AI(MD,K)
            AR(MD,K) = TR
            AI(MD,K) = TI
   20       IF (DABS(TR)+DABS(TI) .EQ. 0.D0) GO TO 80
            DEN=TR*TR+TI*TI
            TR=TR/DEN
            TI=-TI/DEN
            DO 30 I = MD1,MDL
               PRODR=AR(I,K)*TR-AI(I,K)*TI
               PRODI=AI(I,K)*TR+AR(I,K)*TI
               AR(I,K)=-PRODR
               AI(I,K)=-PRODI
   30       CONTINUE
            JU = MIN0(MAX0(JU,MU+IP(K)),N)
            MM = MD
            IF (JU .LT. KP1) GO TO 55
            DO 50 J = KP1,JU
               M = M - 1
               MM = MM - 1
               TR = AR(M,J)
               TI = AI(M,J)
               IF (M .EQ. MM) GO TO 35
               AR(M,J) = AR(MM,J)
               AI(M,J) = AI(MM,J)
               AR(MM,J) = TR
               AI(MM,J) = TI
   35          CONTINUE
               IF (DABS(TR)+DABS(TI) .EQ. 0.D0) GO TO 48
               JK = J - K
               IF (TI .EQ. 0.D0) THEN
                  DO 40 I = MD1,MDL
                     IJK = I - JK
                     PRODR=AR(I,K)*TR
                     PRODI=AI(I,K)*TR
                     AR(IJK,J) = AR(IJK,J) + PRODR
                     AI(IJK,J) = AI(IJK,J) + PRODI
   40             CONTINUE
                  GO TO 48
               END IF
               IF (TR .EQ. 0.D0) THEN
                  DO 45 I = MD1,MDL
                     IJK = I - JK
                     PRODR=-AI(I,K)*TI
                     PRODI=AR(I,K)*TI
                     AR(IJK,J) = AR(IJK,J) + PRODR
                     AI(IJK,J) = AI(IJK,J) + PRODI
   45             CONTINUE
                  GO TO 48
               END IF
               DO 47 I = MD1,MDL
                  IJK = I - JK
                  PRODR=AR(I,K)*TR-AI(I,K)*TI
                  PRODI=AI(I,K)*TR+AR(I,K)*TI
                  AR(IJK,J) = AR(IJK,J) + PRODR
                  AI(IJK,J) = AI(IJK,J) + PRODI
   47          CONTINUE
   48          CONTINUE
   50       CONTINUE
   55       CONTINUE
   60    CONTINUE
   70    K = N
         IF (DABS(AR(MD,N))+DABS(AI(MD,N)) .EQ. 0.D0) GO TO 80
         RETURN
   80    IER = K
         IP(N) = 0
         RETURN
C----------------------- END OF SUBROUTINE DECBC ------------------------
      END
C
C
      SUBROUTINE SOLBC (N, NDIM, AR, AI, ML, MU, BR, BI, IP)
         IMPLICIT REAL*8 (A-H,O-Z)
         DIMENSION AR(NDIM,N), AI(NDIM,N), BR(N), BI(N), IP(N)
C-----------------------------------------------------------------------
C  SOLUTION OF LINEAR SYSTEM, A*X = B ,
C                  VERSION BANDED AND COMPLEX-DOUBLE PRECISION.
C  INPUT..
C    N      ORDER OF MATRIX A.
C    NDIM   DECLARED DIMENSION OF ARRAY  A .
C    AR, AI TRIANGULARIZED MATRIX OBTAINED FROM DECB (REAL AND IMAG. PART).
C    ML     LOWER BANDWIDTH OF A (DIAGONAL IS NOT COUNTED).
C    MU     UPPER BANDWIDTH OF A (DIAGONAL IS NOT COUNTED).
C    BR, BI RIGHT HAND SIDE VECTOR (REAL AND IMAG. PART).
C    IP     PIVOT VECTOR OBTAINED FROM DECBC.
C  DO NOT USE IF DECB HAS SET IER .NE. 0.
C  OUTPUT..
C    BR, BI SOLUTION VECTOR, X (REAL AND IMAG. PART).
C-----------------------------------------------------------------------
         MD = ML + MU + 1
         MD1 = MD + 1
         MDM = MD - 1
         NM1 = N - 1
         IF (ML .EQ. 0) GO TO 25
         IF (N .EQ. 1) GO TO 50
         DO 20 K = 1,NM1
            M = IP(K)
            TR = BR(M)
            TI = BI(M)
            BR(M) = BR(K)
            BI(M) = BI(K)
            BR(K) = TR
            BI(K) = TI
            MDL = MIN(ML,N-K) + MD
            DO 10 I = MD1,MDL
               IMD = I + K - MD
               PRODR=AR(I,K)*TR-AI(I,K)*TI
               PRODI=AI(I,K)*TR+AR(I,K)*TI
               BR(IMD) = BR(IMD) + PRODR
               BI(IMD) = BI(IMD) + PRODI
   10       CONTINUE
   20    CONTINUE
   25    CONTINUE
         DO 40 KB = 1,NM1
            K = N + 1 - KB
            DEN=AR(MD,K)*AR(MD,K)+AI(MD,K)*AI(MD,K)
            PRODR=BR(K)*AR(MD,K)+BI(K)*AI(MD,K)
            PRODI=BI(K)*AR(MD,K)-BR(K)*AI(MD,K)
            BR(K)=PRODR/DEN
            BI(K)=PRODI/DEN
            TR = -BR(K)
            TI = -BI(K)
            KMD = MD - K
            LM = MAX0(1,KMD+1)
            DO 30 I = LM,MDM
               IMD = I - KMD
               PRODR=AR(I,K)*TR-AI(I,K)*TI
               PRODI=AI(I,K)*TR+AR(I,K)*TI
               BR(IMD) = BR(IMD) + PRODR
               BI(IMD) = BI(IMD) + PRODI
   30       CONTINUE
   40    CONTINUE
         DEN=AR(MD,1)*AR(MD,1)+AI(MD,1)*AI(MD,1)
         PRODR=BR(1)*AR(MD,1)+BI(1)*AI(MD,1)
         PRODI=BI(1)*AR(MD,1)-BR(1)*AI(MD,1)
         BR(1)=PRODR/DEN
         BI(1)=PRODI/DEN
   50    CONTINUE
         RETURN
C----------------------- END OF SUBROUTINE SOLBC ------------------------
      END
c
C
      subroutine elmhes(nm,n,low,igh,a,int)
C
         integer i,j,m,n,la,nm,igh,kp1,low,mm1,mp1
         real*8 a(nm,n)
         real*8 x,y
         real*8 dabs
         integer int(igh)
C
C     this subroutine is a translation of the algol procedure elmhes,
C     num. math. 12, 349-368(1968) by martin and wilkinson.
C     handbook for auto. comp., vol.ii-linear algebra, 339-358(1971).
C
C     given a real general matrix, this subroutine
C     reduces a submatrix situated in rows and columns
C     low through igh to upper hessenberg form by
C     stabilized elementary similarity transformations.
C
C     on input:
C
C      nm must be set to the row dimension of two-dimensional
C        array parameters as declared in the calling program
C        dimension statement;
C
C      n is the order of the matrix;
C
C      low and igh are integers determined by the balancing
C        subroutine  balanc.      if  balanc  has not been used,
C        set low=1, igh=n;
C
C      a contains the input matrix.
C
C     on output:
C
C      a contains the hessenberg matrix.  the multipliers
C        which were used in the reduction are stored in the
C        remaining triangle under the hessenberg matrix;
C
C      int contains information on the rows and columns
C        interchanged in the reduction.
C        only elements low through igh are used.
C
C     questions and comments should be directed to b. s. garbow,
C     applied mathematics division, argonne national laboratory
C
C     ------------------------------------------------------------------
C
         la = igh - 1
         kp1 = low + 1
         if (la .lt. kp1) go to 200
C
         do 180 m = kp1, la
            mm1 = m - 1
            x = 0.0d0
            i = m
C
            do 100 j = m, igh
               if (dabs(a(j,mm1)) .le. dabs(x)) go to 100
               x = a(j,mm1)
               i = j
  100       continue
C
            int(m) = i
            if (i .eq. m) go to 130
C    :::::::::: interchange rows and columns of a ::::::::::
            do 110 j = mm1, n
               y = a(i,j)
               a(i,j) = a(m,j)
               a(m,j) = y
  110       continue
C
            do 120 j = 1, igh
               y = a(j,i)
               a(j,i) = a(j,m)
               a(j,m) = y
  120       continue
C    :::::::::: end interchange ::::::::::
  130       if (x .eq. 0.0d0) go to 180
            mp1 = m + 1
C
            do 160 i = mp1, igh
               y = a(i,mm1)
               if (y .eq. 0.0d0) go to 160
               y = y / x
               a(i,mm1) = y
C
               do 140 j = m, n
  140          a(i,j) = a(i,j) - y * a(m,j)
C
               do 150 j = 1, igh
  150          a(j,m) = a(j,m) + y * a(j,i)
C
  160       continue
C
  180    continue
C
  200    return
C    :::::::::: last card of elmhes ::::::::::
      end


C ******************************************
C     VERSION OF SEPTEMBER 18, 1995
C ******************************************
C
      SUBROUTINE DECOMR(N,FJAC,LDJAC,FMAS,LDMAS,MLMAS,MUMAS,
     &            M1,M2,NM1,FAC1,E1,LDE1,IP1,IER,IJOB,CALHES,IPHES)
         IMPLICIT REAL*8 (A-H,O-Z)
         DIMENSION FJAC(LDJAC,N),FMAS(LDMAS,NM1),E1(LDE1,NM1),
     &             IP1(NM1),IPHES(N)
         LOGICAL CALHES
         COMMON/LINAL/MLE,MUE,MBJAC,MBB,MDIAG,MDIFF,MBDIAG
C
         GOTO (1,2,3,4,5,6,7,55,55,55,11,12,13,14,15), IJOB
C
C -----------------------------------------------------------
C
    1    CONTINUE
C ---  B=IDENTITY, JACOBIAN A FULL MATRIX
         DO J=1,N
            DO  I=1,N
               E1(I,J)=-FJAC(I,J)
            END DO
            E1(J,J)=E1(J,J)+FAC1
         END DO
         CALL DEC (N,LDE1,E1,IP1,IER)
         RETURN
C
C -----------------------------------------------------------
C
   11    CONTINUE
C ---  B=IDENTITY, JACOBIAN A FULL MATRIX, SECOND ORDER
         DO J=1,NM1
            JM1=J+M1
            DO I=1,NM1
               E1(I,J)=-FJAC(I,JM1)
            END DO
            E1(J,J)=E1(J,J)+FAC1
         END DO
   45    MM=M1/M2
         DO J=1,M2
            DO I=1,NM1
               SUM=0.D0
               DO K=0,MM-1
                  SUM=(SUM+FJAC(I,J+K*M2))/FAC1
               END DO
               E1(I,J)=E1(I,J)-SUM
            END DO
         END DO
         CALL DEC (NM1,LDE1,E1,IP1,IER)
         RETURN
C
C -----------------------------------------------------------
C
    2    CONTINUE
C ---  B=IDENTITY, JACOBIAN A BANDED MATRIX
         DO J=1,N
            DO I=1,MBJAC
               E1(I+MLE,J)=-FJAC(I,J)
            END DO
            E1(MDIAG,J)=E1(MDIAG,J)+FAC1
         END DO
         CALL DECB (N,LDE1,E1,MLE,MUE,IP1,IER)
         RETURN
C
C -----------------------------------------------------------
C
   12    CONTINUE
C ---  B=IDENTITY, JACOBIAN A BANDED MATRIX, SECOND ORDER
         DO J=1,NM1
            JM1=J+M1
            DO I=1,MBJAC
               E1(I+MLE,J)=-FJAC(I,JM1)
            END DO
            E1(MDIAG,J)=E1(MDIAG,J)+FAC1
         END DO
   46    MM=M1/M2
         DO J=1,M2
            DO I=1,MBJAC
               SUM=0.D0
               DO K=0,MM-1
                  SUM=(SUM+FJAC(I,J+K*M2))/FAC1
               END DO
               E1(I+MLE,J)=E1(I+MLE,J)-SUM
            END DO
         END DO
         CALL DECB (NM1,LDE1,E1,MLE,MUE,IP1,IER)
         RETURN
C
C -----------------------------------------------------------
C
    3    CONTINUE
C ---  B IS A BANDED MATRIX, JACOBIAN A FULL MATRIX
         DO J=1,N
            DO I=1,N
               E1(I,J)=-FJAC(I,J)
            END DO
            DO I=MAX(1,J-MUMAS),MIN(N,J+MLMAS)
               E1(I,J)=E1(I,J)+FAC1*FMAS(I-J+MBDIAG,J)
            END DO
         END DO
         CALL DEC (N,LDE1,E1,IP1,IER)
         RETURN
C
C -----------------------------------------------------------
C
   13    CONTINUE
C ---  B IS A BANDED MATRIX, JACOBIAN A FULL MATRIX, SECOND ORDER
         DO J=1,NM1
            JM1=J+M1
            DO I=1,NM1
               E1(I,J)=-FJAC(I,JM1)
            END DO
            DO I=MAX(1,J-MUMAS),MIN(NM1,J+MLMAS)
               E1(I,J)=E1(I,J)+FAC1*FMAS(I-J+MBDIAG,J)
            END DO
         END DO
         GOTO 45
C
C -----------------------------------------------------------
C
    4    CONTINUE
C ---  B IS A BANDED MATRIX, JACOBIAN A BANDED MATRIX
         DO J=1,N
            DO I=1,MBJAC
               E1(I+MLE,J)=-FJAC(I,J)
            END DO
            DO I=1,MBB
               IB=I+MDIFF
               E1(IB,J)=E1(IB,J)+FAC1*FMAS(I,J)
            END DO
         END DO
         CALL DECB (N,LDE1,E1,MLE,MUE,IP1,IER)
         RETURN
C
C -----------------------------------------------------------
C
   14    CONTINUE
C ---  B IS A BANDED MATRIX, JACOBIAN A BANDED MATRIX, SECOND ORDER
         DO J=1,NM1
            JM1=J+M1
            DO I=1,MBJAC
               E1(I+MLE,J)=-FJAC(I,JM1)
            END DO
            DO I=1,MBB
               IB=I+MDIFF
               E1(IB,J)=E1(IB,J)+FAC1*FMAS(I,J)
            END DO
         END DO
         GOTO 46
C
C -----------------------------------------------------------
C
    5    CONTINUE
C ---  B IS A FULL MATRIX, JACOBIAN A FULL MATRIX
         DO J=1,N
            DO I=1,N
               E1(I,J)=FMAS(I,J)*FAC1-FJAC(I,J)
            END DO
         END DO
         CALL DEC (N,LDE1,E1,IP1,IER)
         RETURN
C
C -----------------------------------------------------------
C
   15    CONTINUE
C ---  B IS A FULL MATRIX, JACOBIAN A FULL MATRIX, SECOND ORDER
         DO J=1,NM1
            JM1=J+M1
            DO I=1,NM1
               E1(I,J)=FMAS(I,J)*FAC1-FJAC(I,JM1)
            END DO
         END DO
         GOTO 45
C
C -----------------------------------------------------------
C
    6    CONTINUE
C ---  B IS A FULL MATRIX, JACOBIAN A BANDED MATRIX
C ---  THIS OPTION IS NOT PROVIDED
         RETURN
C
C -----------------------------------------------------------
C
    7    CONTINUE
C ---  B=IDENTITY, JACOBIAN A FULL MATRIX, HESSENBERG-OPTION
         IF (CALHES) CALL ELMHES (LDJAC,N,1,N,FJAC,IPHES)
         CALHES=.FALSE.
         DO J=1,N-1
            J1=J+1
            E1(J1,J)=-FJAC(J1,J)
         END DO
         DO J=1,N
            DO I=1,J
               E1(I,J)=-FJAC(I,J)
            END DO
            E1(J,J)=E1(J,J)+FAC1
         END DO
         CALL DECH(N,LDE1,E1,1,IP1,IER)
         RETURN
C
C -----------------------------------------------------------
C
   55    CONTINUE
         RETURN
      END
C
C     END OF SUBROUTINE DECOMR
C
C ***********************************************************
C
      SUBROUTINE DECOMC(N,FJAC,LDJAC,FMAS,LDMAS,MLMAS,MUMAS,
     &            M1,M2,NM1,ALPHN,BETAN,E2R,E2I,LDE1,IP2,IER,IJOB)
         IMPLICIT REAL*8 (A-H,O-Z)
         DIMENSION FJAC(LDJAC,N),FMAS(LDMAS,NM1),
     &             E2R(LDE1,NM1),E2I(LDE1,NM1),IP2(NM1)
         COMMON/LINAL/MLE,MUE,MBJAC,MBB,MDIAG,MDIFF,MBDIAG
C
         GOTO (1,2,3,4,5,6,7,55,55,55,11,12,13,14,15), IJOB
C
C -----------------------------------------------------------
C
    1    CONTINUE
C ---  B=IDENTITY, JACOBIAN A FULL MATRIX
         DO J=1,N
            DO I=1,N
               E2R(I,J)=-FJAC(I,J)
               E2I(I,J)=0.D0
            END DO
            E2R(J,J)=E2R(J,J)+ALPHN
            E2I(J,J)=BETAN
         END DO
         CALL DECC (N,LDE1,E2R,E2I,IP2,IER)
         RETURN
C
C -----------------------------------------------------------
C
   11    CONTINUE
C ---  B=IDENTITY, JACOBIAN A FULL MATRIX, SECOND ORDER
         DO J=1,NM1
            JM1=J+M1
            DO I=1,NM1
               E2R(I,J)=-FJAC(I,JM1)
               E2I(I,J)=0.D0
            END DO
            E2R(J,J)=E2R(J,J)+ALPHN
            E2I(J,J)=BETAN
         END DO
   45    MM=M1/M2
         ABNO=ALPHN**2+BETAN**2
         ALP=ALPHN/ABNO
         BET=BETAN/ABNO
         DO J=1,M2
            DO I=1,NM1
               SUMR=0.D0
               SUMI=0.D0
               DO K=0,MM-1
                  SUMS=SUMR+FJAC(I,J+K*M2)
                  SUMR=SUMS*ALP+SUMI*BET
                  SUMI=SUMI*ALP-SUMS*BET
               END DO
               E2R(I,J)=E2R(I,J)-SUMR
               E2I(I,J)=E2I(I,J)-SUMI
            END DO
         END DO
         CALL DECC (NM1,LDE1,E2R,E2I,IP2,IER)
         RETURN
C
C -----------------------------------------------------------
C
    2    CONTINUE
C ---  B=IDENTITY, JACOBIAN A BANDED MATRIX
         DO J=1,N
            DO I=1,MBJAC
               IMLE=I+MLE
               E2R(IMLE,J)=-FJAC(I,J)
               E2I(IMLE,J)=0.D0
            END DO
            E2R(MDIAG,J)=E2R(MDIAG,J)+ALPHN
            E2I(MDIAG,J)=BETAN
         END DO
         CALL DECBC (N,LDE1,E2R,E2I,MLE,MUE,IP2,IER)
         RETURN
C
C -----------------------------------------------------------
C
   12    CONTINUE
C ---  B=IDENTITY, JACOBIAN A BANDED MATRIX, SECOND ORDER
         DO J=1,NM1
            JM1=J+M1
            DO I=1,MBJAC
               E2R(I+MLE,J)=-FJAC(I,JM1)
               E2I(I+MLE,J)=0.D0
            END DO
            E2R(MDIAG,J)=E2R(MDIAG,J)+ALPHN
            E2I(MDIAG,J)=E2I(MDIAG,J)+BETAN
         END DO
   46    MM=M1/M2
         ABNO=ALPHN**2+BETAN**2
         ALP=ALPHN/ABNO
         BET=BETAN/ABNO
         DO J=1,M2
            DO I=1,MBJAC
               SUMR=0.D0
               SUMI=0.D0
               DO K=0,MM-1
                  SUMS=SUMR+FJAC(I,J+K*M2)
                  SUMR=SUMS*ALP+SUMI*BET
                  SUMI=SUMI*ALP-SUMS*BET
               END DO
               IMLE=I+MLE
               E2R(IMLE,J)=E2R(IMLE,J)-SUMR
               E2I(IMLE,J)=E2I(IMLE,J)-SUMI
            END DO
         END DO
         CALL DECBC (NM1,LDE1,E2R,E2I,MLE,MUE,IP2,IER)
         RETURN
C
C -----------------------------------------------------------
C
    3    CONTINUE
C ---  B IS A BANDED MATRIX, JACOBIAN A FULL MATRIX
         DO  J=1,N
            DO  I=1,N
               E2R(I,J)=-FJAC(I,J)
               E2I(I,J)=0.D0
            END DO
         END DO
         DO J=1,N
            DO I=MAX(1,J-MUMAS),MIN(N,J+MLMAS)
               BB=FMAS(I-J+MBDIAG,J)
               E2R(I,J)=E2R(I,J)+ALPHN*BB
               E2I(I,J)=BETAN*BB
            END DO
         END DO
         CALL DECC(N,LDE1,E2R,E2I,IP2,IER)
         RETURN
C
C -----------------------------------------------------------
C
   13    CONTINUE
C ---  B IS A BANDED MATRIX, JACOBIAN A FULL MATRIX, SECOND ORDER
         DO J=1,NM1
            JM1=J+M1
            DO I=1,NM1
               E2R(I,J)=-FJAC(I,JM1)
               E2I(I,J)=0.D0
            END DO
            DO I=MAX(1,J-MUMAS),MIN(NM1,J+MLMAS)
               FFMA=FMAS(I-J+MBDIAG,J)
               E2R(I,J)=E2R(I,J)+ALPHN*FFMA
               E2I(I,J)=E2I(I,J)+BETAN*FFMA
            END DO
         END DO
         GOTO 45
C
C -----------------------------------------------------------
C
    4    CONTINUE
C ---  B IS A BANDED MATRIX, JACOBIAN A BANDED MATRIX
         DO J=1,N
            DO I=1,MBJAC
               IMLE=I+MLE
               E2R(IMLE,J)=-FJAC(I,J)
               E2I(IMLE,J)=0.D0
            END DO
            DO I=MAX(1,MUMAS+2-J),MIN(MBB,MUMAS+1-J+N)
               IB=I+MDIFF
               BB=FMAS(I,J)
               E2R(IB,J)=E2R(IB,J)+ALPHN*BB
               E2I(IB,J)=BETAN*BB
            END DO
         END DO
         CALL DECBC (N,LDE1,E2R,E2I,MLE,MUE,IP2,IER)
         RETURN
C
C -----------------------------------------------------------
C
   14    CONTINUE
C ---  B IS A BANDED MATRIX, JACOBIAN A BANDED MATRIX, SECOND ORDER
         DO J=1,NM1
            JM1=J+M1
            DO I=1,MBJAC
               E2R(I+MLE,J)=-FJAC(I,JM1)
               E2I(I+MLE,J)=0.D0
            END DO
            DO I=1,MBB
               IB=I+MDIFF
               FFMA=FMAS(I,J)
               E2R(IB,J)=E2R(IB,J)+ALPHN*FFMA
               E2I(IB,J)=E2I(IB,J)+BETAN*FFMA
            END DO
         END DO
         GOTO 46
C
C -----------------------------------------------------------
C
    5    CONTINUE
C ---  B IS A FULL MATRIX, JACOBIAN A FULL MATRIX
         DO J=1,N
            DO I=1,N
               BB=FMAS(I,J)
               E2R(I,J)=BB*ALPHN-FJAC(I,J)
               E2I(I,J)=BB*BETAN
            END DO
         END DO
         CALL DECC(N,LDE1,E2R,E2I,IP2,IER)
         RETURN
C
C -----------------------------------------------------------
C
   15    CONTINUE
C ---  B IS A FULL MATRIX, JACOBIAN A FULL MATRIX, SECOND ORDER
         DO J=1,NM1
            JM1=J+M1
            DO I=1,NM1
               E2R(I,J)=ALPHN*FMAS(I,J)-FJAC(I,JM1)
               E2I(I,J)=BETAN*FMAS(I,J)
            END DO
         END DO
         GOTO 45
C
C -----------------------------------------------------------
C
    6    CONTINUE
C ---  B IS A FULL MATRIX, JACOBIAN A BANDED MATRIX
C ---  THIS OPTION IS NOT PROVIDED
         RETURN
C
C -----------------------------------------------------------
C
    7    CONTINUE
C ---  B=IDENTITY, JACOBIAN A FULL MATRIX, HESSENBERG-OPTION
         DO J=1,N-1
            J1=J+1
            E2R(J1,J)=-FJAC(J1,J)
            E2I(J1,J)=0.D0
         END DO
         DO J=1,N
            DO I=1,J
               E2I(I,J)=0.D0
               E2R(I,J)=-FJAC(I,J)
            END DO
            E2R(J,J)=E2R(J,J)+ALPHN
            E2I(J,J)=BETAN
         END DO
         CALL DECHC(N,LDE1,E2R,E2I,1,IP2,IER)
         RETURN
C
C -----------------------------------------------------------
C
   55    CONTINUE
         RETURN
      END
C
C     END OF SUBROUTINE DECOMC
C
C ***********************************************************
C
      SUBROUTINE SLVRAR(N,FJAC,LDJAC,MLJAC,MUJAC,FMAS,LDMAS,MLMAS,MUMAS,
     &          M1,M2,NM1,FAC1,E1,LDE1,Z1,F1,IP1,IPHES,IER,IJOB)
         IMPLICIT REAL*8 (A-H,O-Z)
         DIMENSION FJAC(LDJAC,N),FMAS(LDMAS,NM1),E1(LDE1,NM1),
     &             IP1(NM1),IPHES(N),Z1(N),F1(N)
         COMMON/LINAL/MLE,MUE,MBJAC,MBB,MDIAG,MDIFF,MBDIAG
C
         GOTO (1,2,3,4,5,6,7,55,55,55,11,12,13,13,15), IJOB
C
C -----------------------------------------------------------
C
    1    CONTINUE
C ---  B=IDENTITY, JACOBIAN A FULL MATRIX
         DO I=1,N
            Z1(I)=Z1(I)-F1(I)*FAC1
         END DO
         CALL SOL (N,LDE1,E1,Z1,IP1)
         RETURN
C
C -----------------------------------------------------------
C
   11    CONTINUE
C ---  B=IDENTITY, JACOBIAN A FULL MATRIX, SECOND ORDER
         DO I=1,N
            Z1(I)=Z1(I)-F1(I)*FAC1
         END DO
   48    CONTINUE
         MM=M1/M2
         DO J=1,M2
            SUM1=0.D0
            DO K=MM-1,0,-1
               JKM=J+K*M2
               SUM1=(Z1(JKM)+SUM1)/FAC1
               DO I=1,NM1
                  IM1=I+M1
                  Z1(IM1)=Z1(IM1)+FJAC(I,JKM)*SUM1
               END DO
            END DO
         END DO
         CALL SOL (NM1,LDE1,E1,Z1(M1+1),IP1)
   49    CONTINUE
         DO I=M1,1,-1
            Z1(I)=(Z1(I)+Z1(M2+I))/FAC1
         END DO
         RETURN
C
C -----------------------------------------------------------
C
    2    CONTINUE
C ---  B=IDENTITY, JACOBIAN A BANDED MATRIX
         DO I=1,N
            Z1(I)=Z1(I)-F1(I)*FAC1
         END DO
         CALL SOLB (N,LDE1,E1,MLE,MUE,Z1,IP1)
         RETURN
C
C -----------------------------------------------------------
C
   12    CONTINUE
C ---  B=IDENTITY, JACOBIAN A BANDED MATRIX, SECOND ORDER
         DO I=1,N
            Z1(I)=Z1(I)-F1(I)*FAC1
         END DO
   45    CONTINUE
         MM=M1/M2
         DO J=1,M2
            SUM1=0.D0
            DO K=MM-1,0,-1
               JKM=J+K*M2
               SUM1=(Z1(JKM)+SUM1)/FAC1
               DO I=MAX(1,J-MUJAC),MIN(NM1,J+MLJAC)
                  IM1=I+M1
                  Z1(IM1)=Z1(IM1)+FJAC(I+MUJAC+1-J,JKM)*SUM1
               END DO
            END DO
         END DO
         CALL SOLB (NM1,LDE1,E1,MLE,MUE,Z1(M1+1),IP1)
         GOTO 49
C
C -----------------------------------------------------------
C
    3    CONTINUE
C ---  B IS A BANDED MATRIX, JACOBIAN A FULL MATRIX
         DO I=1,N
            S1=0.0D0
            DO J=MAX(1,I-MLMAS),MIN(N,I+MUMAS)
               S1=S1-FMAS(I-J+MBDIAG,J)*F1(J)
            END DO
            Z1(I)=Z1(I)+S1*FAC1
         END DO
         CALL SOL (N,LDE1,E1,Z1,IP1)
         RETURN
C
C -----------------------------------------------------------
C
   13    CONTINUE
C ---  B IS A BANDED MATRIX, JACOBIAN A FULL MATRIX, SECOND ORDER
         DO I=1,M1
            Z1(I)=Z1(I)-F1(I)*FAC1
         END DO
         DO I=1,NM1
            IM1=I+M1
            S1=0.0D0
            DO J=MAX(1,I-MLMAS),MIN(NM1,I+MUMAS)
               S1=S1-FMAS(I-J+MBDIAG,J)*F1(J+M1)
            END DO
            Z1(IM1)=Z1(IM1)+S1*FAC1
         END DO
         IF (IJOB.EQ.14) GOTO 45
         GOTO 48
C
C -----------------------------------------------------------
C
    4    CONTINUE
C ---  B IS A BANDED MATRIX, JACOBIAN A BANDED MATRIX
         DO I=1,N
            S1=0.0D0
            DO J=MAX(1,I-MLMAS),MIN(N,I+MUMAS)
               S1=S1-FMAS(I-J+MBDIAG,J)*F1(J)
            END DO
            Z1(I)=Z1(I)+S1*FAC1
         END DO
         CALL SOLB (N,LDE1,E1,MLE,MUE,Z1,IP1)
         RETURN
C
C -----------------------------------------------------------
C
    5    CONTINUE
C ---  B IS A FULL MATRIX, JACOBIAN A FULL MATRIX
         DO I=1,N
            S1=0.0D0
            DO J=1,N
               S1=S1-FMAS(I,J)*F1(J)
            END DO
            Z1(I)=Z1(I)+S1*FAC1
         END DO
         CALL SOL (N,LDE1,E1,Z1,IP1)
         RETURN
C
C -----------------------------------------------------------
C
   15    CONTINUE
C ---  B IS A FULL MATRIX, JACOBIAN A FULL MATRIX, SECOND ORDER
         DO I=1,M1
            Z1(I)=Z1(I)-F1(I)*FAC1
         END DO
         DO I=1,NM1
            IM1=I+M1
            S1=0.0D0
            DO J=1,NM1
               S1=S1-FMAS(I,J)*F1(J+M1)
            END DO
            Z1(IM1)=Z1(IM1)+S1*FAC1
         END DO
         GOTO 48
C
C -----------------------------------------------------------
C
    6    CONTINUE
C ---  B IS A FULL MATRIX, JACOBIAN A BANDED MATRIX
C ---  THIS OPTION IS NOT PROVIDED
         RETURN
C
C -----------------------------------------------------------
C
    7    CONTINUE
C ---  B=IDENTITY, JACOBIAN A FULL MATRIX, HESSENBERG-OPTION
         DO I=1,N
            Z1(I)=Z1(I)-F1(I)*FAC1
         END DO
         DO MM=N-2,1,-1
            MP=N-MM
            MP1=MP-1
            I=IPHES(MP)
            IF (I.EQ.MP) GOTO 746
            ZSAFE=Z1(MP)
            Z1(MP)=Z1(I)
            Z1(I)=ZSAFE
  746       CONTINUE
            DO I=MP+1,N
               Z1(I)=Z1(I)-FJAC(I,MP1)*Z1(MP)
            END DO
         END DO
         CALL SOLH(N,LDE1,E1,1,Z1,IP1)
         DO MM=1,N-2
            MP=N-MM
            MP1=MP-1
            DO I=MP+1,N
               Z1(I)=Z1(I)+FJAC(I,MP1)*Z1(MP)
            END DO
            I=IPHES(MP)
            IF (I.EQ.MP) GOTO 750
            ZSAFE=Z1(MP)
            Z1(MP)=Z1(I)
            Z1(I)=ZSAFE
  750       CONTINUE
         END DO
         RETURN
C
C -----------------------------------------------------------
C
   55    CONTINUE
         RETURN
      END
C
C     END OF SUBROUTINE SLVRAR
C
C ***********************************************************
C
      SUBROUTINE SLVRAI(N,FJAC,LDJAC,MLJAC,MUJAC,FMAS,LDMAS,MLMAS,MUMAS,
     &          M1,M2,NM1,ALPHN,BETAN,E2R,E2I,LDE1,Z2,Z3,
     &          F2,F3,CONT,IP2,IPHES,IER,IJOB)
         IMPLICIT REAL*8 (A-H,O-Z)
         DIMENSION FJAC(LDJAC,N),FMAS(LDMAS,NM1),
     &             IP2(NM1),IPHES(N),Z2(N),Z3(N),F2(N),F3(N)
         DIMENSION E2R(LDE1,NM1),E2I(LDE1,NM1)
         COMMON/LINAL/MLE,MUE,MBJAC,MBB,MDIAG,MDIFF,MBDIAG
C
         GOTO (1,2,3,4,5,6,7,55,55,55,11,12,13,13,15), IJOB
C
C -----------------------------------------------------------
C
    1    CONTINUE
C ---  B=IDENTITY, JACOBIAN A FULL MATRIX
         DO I=1,N
            S2=-F2(I)
            S3=-F3(I)
            Z2(I)=Z2(I)+S2*ALPHN-S3*BETAN
            Z3(I)=Z3(I)+S3*ALPHN+S2*BETAN
         END DO
         CALL SOLC (N,LDE1,E2R,E2I,Z2,Z3,IP2)
         RETURN
C
C -----------------------------------------------------------
C
   11    CONTINUE
C ---  B=IDENTITY, JACOBIAN A FULL MATRIX, SECOND ORDER
         DO I=1,N
            S2=-F2(I)
            S3=-F3(I)
            Z2(I)=Z2(I)+S2*ALPHN-S3*BETAN
            Z3(I)=Z3(I)+S3*ALPHN+S2*BETAN
         END DO
   48    ABNO=ALPHN**2+BETAN**2
         MM=M1/M2
         DO J=1,M2
            SUM2=0.D0
            SUM3=0.D0
            DO K=MM-1,0,-1
               JKM=J+K*M2
               SUMH=(Z2(JKM)+SUM2)/ABNO
               SUM3=(Z3(JKM)+SUM3)/ABNO
               SUM2=SUMH*ALPHN+SUM3*BETAN
               SUM3=SUM3*ALPHN-SUMH*BETAN
               DO I=1,NM1
                  IM1=I+M1
                  Z2(IM1)=Z2(IM1)+FJAC(I,JKM)*SUM2
                  Z3(IM1)=Z3(IM1)+FJAC(I,JKM)*SUM3
               END DO
            END DO
         END DO
         CALL SOLC (NM1,LDE1,E2R,E2I,Z2(M1+1),Z3(M1+1),IP2)
   49    CONTINUE
         DO I=M1,1,-1
            MPI=M2+I
            Z2I=Z2(I)+Z2(MPI)
            Z3I=Z3(I)+Z3(MPI)
            Z3(I)=(Z3I*ALPHN-Z2I*BETAN)/ABNO
            Z2(I)=(Z2I*ALPHN+Z3I*BETAN)/ABNO
         END DO
         RETURN
C
C -----------------------------------------------------------
C
    2    CONTINUE
C ---  B=IDENTITY, JACOBIAN A BANDED MATRIX
         DO I=1,N
            S2=-F2(I)
            S3=-F3(I)
            Z2(I)=Z2(I)+S2*ALPHN-S3*BETAN
            Z3(I)=Z3(I)+S3*ALPHN+S2*BETAN
         END DO
         CALL SOLBC (N,LDE1,E2R,E2I,MLE,MUE,Z2,Z3,IP2)
         RETURN
C
C -----------------------------------------------------------
C
   12    CONTINUE
C ---  B=IDENTITY, JACOBIAN A BANDED MATRIX, SECOND ORDER
         DO I=1,N
            S2=-F2(I)
            S3=-F3(I)
            Z2(I)=Z2(I)+S2*ALPHN-S3*BETAN
            Z3(I)=Z3(I)+S3*ALPHN+S2*BETAN
         END DO
   45    ABNO=ALPHN**2+BETAN**2
         MM=M1/M2
         DO J=1,M2
            SUM2=0.D0
            SUM3=0.D0
            DO K=MM-1,0,-1
               JKM=J+K*M2
               SUMH=(Z2(JKM)+SUM2)/ABNO
               SUM3=(Z3(JKM)+SUM3)/ABNO
               SUM2=SUMH*ALPHN+SUM3*BETAN
               SUM3=SUM3*ALPHN-SUMH*BETAN
               DO I=MAX(1,J-MUJAC),MIN(NM1,J+MLJAC)
                  IM1=I+M1
                  IIMU=I+MUJAC+1-J
                  Z2(IM1)=Z2(IM1)+FJAC(IIMU,JKM)*SUM2
                  Z3(IM1)=Z3(IM1)+FJAC(IIMU,JKM)*SUM3
               END DO
            END DO
         END DO
         CALL SOLBC (NM1,LDE1,E2R,E2I,MLE,MUE,Z2(M1+1),Z3(M1+1),IP2)
         GOTO 49
C
C -----------------------------------------------------------
C
    3    CONTINUE
C ---  B IS A BANDED MATRIX, JACOBIAN A FULL MATRIX
         DO I=1,N
            S2=0.0D0
            S3=0.0D0
            DO J=MAX(1,I-MLMAS),MIN(N,I+MUMAS)
               BB=FMAS(I-J+MBDIAG,J)
               S2=S2-BB*F2(J)
               S3=S3-BB*F3(J)
            END DO
            Z2(I)=Z2(I)+S2*ALPHN-S3*BETAN
            Z3(I)=Z3(I)+S3*ALPHN+S2*BETAN
         END DO
         CALL SOLC(N,LDE1,E2R,E2I,Z2,Z3,IP2)
         RETURN
C
C -----------------------------------------------------------
C
   13    CONTINUE
C ---  B IS A BANDED MATRIX, JACOBIAN A FULL MATRIX, SECOND ORDER
         DO I=1,M1
            S2=-F2(I)
            S3=-F3(I)
            Z2(I)=Z2(I)+S2*ALPHN-S3*BETAN
            Z3(I)=Z3(I)+S3*ALPHN+S2*BETAN
         END DO
         DO I=1,NM1
            IM1=I+M1
            S2=0.0D0
            S3=0.0D0
            DO J=MAX(1,I-MLMAS),MIN(NM1,I+MUMAS)
               JM1=J+M1
               BB=FMAS(I-J+MBDIAG,J)
               S2=S2-BB*F2(JM1)
               S3=S3-BB*F3(JM1)
            END DO
            Z2(IM1)=Z2(IM1)+S2*ALPHN-S3*BETAN
            Z3(IM1)=Z3(IM1)+S3*ALPHN+S2*BETAN
         END DO
         IF (IJOB.EQ.14) GOTO 45
         GOTO 48
C
C -----------------------------------------------------------
C
    4    CONTINUE
C ---  B IS A BANDED MATRIX, JACOBIAN A BANDED MATRIX
         DO I=1,N
            S2=0.0D0
            S3=0.0D0
            DO J=MAX(1,I-MLMAS),MIN(N,I+MUMAS)
               BB=FMAS(I-J+MBDIAG,J)
               S2=S2-BB*F2(J)
               S3=S3-BB*F3(J)
            END DO
            Z2(I)=Z2(I)+S2*ALPHN-S3*BETAN
            Z3(I)=Z3(I)+S3*ALPHN+S2*BETAN
         END DO
         CALL SOLBC(N,LDE1,E2R,E2I,MLE,MUE,Z2,Z3,IP2)
         RETURN
C
C -----------------------------------------------------------
C
    5    CONTINUE
C ---  B IS A FULL MATRIX, JACOBIAN A FULL MATRIX
         DO I=1,N
            S2=0.0D0
            S3=0.0D0
            DO J=1,N
               BB=FMAS(I,J)
               S2=S2-BB*F2(J)
               S3=S3-BB*F3(J)
            END DO
            Z2(I)=Z2(I)+S2*ALPHN-S3*BETAN
            Z3(I)=Z3(I)+S3*ALPHN+S2*BETAN
         END DO
         CALL SOLC(N,LDE1,E2R,E2I,Z2,Z3,IP2)
         RETURN
C
C -----------------------------------------------------------
C
   15    CONTINUE
C ---  B IS A FULL MATRIX, JACOBIAN A FULL MATRIX, SECOND ORDER
         DO I=1,M1
            S2=-F2(I)
            S3=-F3(I)
            Z2(I)=Z2(I)+S2*ALPHN-S3*BETAN
            Z3(I)=Z3(I)+S3*ALPHN+S2*BETAN
         END DO
         DO I=1,NM1
            IM1=I+M1
            S2=0.0D0
            S3=0.0D0
            DO J=1,NM1
               JM1=J+M1
               BB=FMAS(I,J)
               S2=S2-BB*F2(JM1)
               S3=S3-BB*F3(JM1)
            END DO
            Z2(IM1)=Z2(IM1)+S2*ALPHN-S3*BETAN
            Z3(IM1)=Z3(IM1)+S3*ALPHN+S2*BETAN
         END DO
         GOTO 48
C
C -----------------------------------------------------------
C
    6    CONTINUE
C ---  B IS A FULL MATRIX, JACOBIAN A BANDED MATRIX
C ---  THIS OPTION IS NOT PROVIDED
         RETURN
C
C -----------------------------------------------------------
C
    7    CONTINUE
C ---  B=IDENTITY, JACOBIAN A FULL MATRIX, HESSENBERG-OPTION
         DO I=1,N
            S2=-F2(I)
            S3=-F3(I)
            Z2(I)=Z2(I)+S2*ALPHN-S3*BETAN
            Z3(I)=Z3(I)+S3*ALPHN+S2*BETAN
         END DO
         DO MM=N-2,1,-1
            MP=N-MM
            MP1=MP-1
            I=IPHES(MP)
            IF (I.EQ.MP) GOTO 746
            ZSAFE=Z2(MP)
            Z2(MP)=Z2(I)
            Z2(I)=ZSAFE
            ZSAFE=Z3(MP)
            Z3(MP)=Z3(I)
            Z3(I)=ZSAFE
  746       CONTINUE
            DO I=MP+1,N
               E1IMP=FJAC(I,MP1)
               Z2(I)=Z2(I)-E1IMP*Z2(MP)
               Z3(I)=Z3(I)-E1IMP*Z3(MP)
            END DO
         END DO
         CALL SOLHC(N,LDE1,E2R,E2I,1,Z2,Z3,IP2)
         DO MM=1,N-2
            MP=N-MM
            MP1=MP-1
            DO I=MP+1,N
               E1IMP=FJAC(I,MP1)
               Z2(I)=Z2(I)+E1IMP*Z2(MP)
               Z3(I)=Z3(I)+E1IMP*Z3(MP)
            END DO
            I=IPHES(MP)
            IF (I.EQ.MP) GOTO 750
            ZSAFE=Z2(MP)
            Z2(MP)=Z2(I)
            Z2(I)=ZSAFE
            ZSAFE=Z3(MP)
            Z3(MP)=Z3(I)
            Z3(I)=ZSAFE
  750       CONTINUE
         END DO
         RETURN
C
C -----------------------------------------------------------
C
   55    CONTINUE
         RETURN
      END
C
C     END OF SUBROUTINE SLVRAI
C
C ***********************************************************
C
      SUBROUTINE SLVRAD(N,FJAC,LDJAC,MLJAC,MUJAC,FMAS,LDMAS,MLMAS,MUMAS,
     &          M1,M2,NM1,FAC1,ALPHN,BETAN,E1,E2R,E2I,LDE1,Z1,Z2,Z3,
      !   &          F1,F2,F3,CONT,IP1,IP2,IPHES,IER,IJOB)
     &          F1,F2,F3,IP1,IP2,IPHES,IER,IJOB)
         IMPLICIT REAL*8 (A-H,O-Z)
         DIMENSION FJAC(LDJAC,N),FMAS(LDMAS,NM1),E1(LDE1,NM1),
     &             E2R(LDE1,NM1),E2I(LDE1,NM1),IP1(NM1),IP2(NM1),
     &             IPHES(N),Z1(N),Z2(N),Z3(N),F1(N),F2(N),F3(N)
         COMMON/LINAL/MLE,MUE,MBJAC,MBB,MDIAG,MDIFF,MBDIAG
C
         GOTO (1,2,3,4,5,6,7,55,55,55,11,12,13,13,15), IJOB
C
C -----------------------------------------------------------
C
    1    CONTINUE
C ---  B=IDENTITY, JACOBIAN A FULL MATRIX
         DO I=1,N
            S2=-F2(I)
            S3=-F3(I)
            Z1(I)=Z1(I)-F1(I)*FAC1
            Z2(I)=Z2(I)+S2*ALPHN-S3*BETAN
            Z3(I)=Z3(I)+S3*ALPHN+S2*BETAN
         END DO
         CALL SOL (N,LDE1,E1,Z1,IP1)
         CALL SOLC (N,LDE1,E2R,E2I,Z2,Z3,IP2)
         RETURN
C
C -----------------------------------------------------------
C
   11    CONTINUE
C ---  B=IDENTITY, JACOBIAN A FULL MATRIX, SECOND ORDER
         DO I=1,N
            S2=-F2(I)
            S3=-F3(I)
            Z1(I)=Z1(I)-F1(I)*FAC1
            Z2(I)=Z2(I)+S2*ALPHN-S3*BETAN
            Z3(I)=Z3(I)+S3*ALPHN+S2*BETAN
         END DO
   48    ABNO=ALPHN**2+BETAN**2
         MM=M1/M2
         DO J=1,M2
            SUM1=0.D0
            SUM2=0.D0
            SUM3=0.D0
            DO K=MM-1,0,-1
               JKM=J+K*M2
               SUM1=(Z1(JKM)+SUM1)/FAC1
               SUMH=(Z2(JKM)+SUM2)/ABNO
               SUM3=(Z3(JKM)+SUM3)/ABNO
               SUM2=SUMH*ALPHN+SUM3*BETAN
               SUM3=SUM3*ALPHN-SUMH*BETAN
               DO I=1,NM1
                  IM1=I+M1
                  Z1(IM1)=Z1(IM1)+FJAC(I,JKM)*SUM1
                  Z2(IM1)=Z2(IM1)+FJAC(I,JKM)*SUM2
                  Z3(IM1)=Z3(IM1)+FJAC(I,JKM)*SUM3
               END DO
            END DO
         END DO
         CALL SOL (NM1,LDE1,E1,Z1(M1+1),IP1)
         CALL SOLC (NM1,LDE1,E2R,E2I,Z2(M1+1),Z3(M1+1),IP2)
   49    CONTINUE
         DO I=M1,1,-1
            MPI=M2+I
            Z1(I)=(Z1(I)+Z1(MPI))/FAC1
            Z2I=Z2(I)+Z2(MPI)
            Z3I=Z3(I)+Z3(MPI)
            Z3(I)=(Z3I*ALPHN-Z2I*BETAN)/ABNO
            Z2(I)=(Z2I*ALPHN+Z3I*BETAN)/ABNO
         END DO
         RETURN
C
C -----------------------------------------------------------
C
    2    CONTINUE
C ---  B=IDENTITY, JACOBIAN A BANDED MATRIX
         DO I=1,N
            S2=-F2(I)
            S3=-F3(I)
            Z1(I)=Z1(I)-F1(I)*FAC1
            Z2(I)=Z2(I)+S2*ALPHN-S3*BETAN
            Z3(I)=Z3(I)+S3*ALPHN+S2*BETAN
         END DO
         CALL SOLB (N,LDE1,E1,MLE,MUE,Z1,IP1)
         CALL SOLBC (N,LDE1,E2R,E2I,MLE,MUE,Z2,Z3,IP2)
         RETURN
C
C -----------------------------------------------------------
C
   12    CONTINUE
C ---  B=IDENTITY, JACOBIAN A BANDED MATRIX, SECOND ORDER
         DO I=1,N
            S2=-F2(I)
            S3=-F3(I)
            Z1(I)=Z1(I)-F1(I)*FAC1
            Z2(I)=Z2(I)+S2*ALPHN-S3*BETAN
            Z3(I)=Z3(I)+S3*ALPHN+S2*BETAN
         END DO
   45    ABNO=ALPHN**2+BETAN**2
         MM=M1/M2
         DO J=1,M2
            SUM1=0.D0
            SUM2=0.D0
            SUM3=0.D0
            DO K=MM-1,0,-1
               JKM=J+K*M2
               SUM1=(Z1(JKM)+SUM1)/FAC1
               SUMH=(Z2(JKM)+SUM2)/ABNO
               SUM3=(Z3(JKM)+SUM3)/ABNO
               SUM2=SUMH*ALPHN+SUM3*BETAN
               SUM3=SUM3*ALPHN-SUMH*BETAN
               DO I=MAX(1,J-MUJAC),MIN(NM1,J+MLJAC)
                  IM1=I+M1
                  FFJA=FJAC(I+MUJAC+1-J,JKM)
                  Z1(IM1)=Z1(IM1)+FFJA*SUM1
                  Z2(IM1)=Z2(IM1)+FFJA*SUM2
                  Z3(IM1)=Z3(IM1)+FFJA*SUM3
               END DO
            END DO
         END DO
         CALL SOLB (NM1,LDE1,E1,MLE,MUE,Z1(M1+1),IP1)
         CALL SOLBC (NM1,LDE1,E2R,E2I,MLE,MUE,Z2(M1+1),Z3(M1+1),IP2)
         GOTO 49
C
C -----------------------------------------------------------
C
    3    CONTINUE
C ---  B IS A BANDED MATRIX, JACOBIAN A FULL MATRIX
         DO I=1,N
            S1=0.0D0
            S2=0.0D0
            S3=0.0D0
            DO J=MAX(1,I-MLMAS),MIN(N,I+MUMAS)
               BB=FMAS(I-J+MBDIAG,J)
               S1=S1-BB*F1(J)
               S2=S2-BB*F2(J)
               S3=S3-BB*F3(J)
            END DO
            Z1(I)=Z1(I)+S1*FAC1
            Z2(I)=Z2(I)+S2*ALPHN-S3*BETAN
            Z3(I)=Z3(I)+S3*ALPHN+S2*BETAN
         END DO
         CALL SOL (N,LDE1,E1,Z1,IP1)
         CALL SOLC(N,LDE1,E2R,E2I,Z2,Z3,IP2)
         RETURN
C
C -----------------------------------------------------------
C
   13    CONTINUE
C ---  B IS A BANDED MATRIX, JACOBIAN A FULL MATRIX, SECOND ORDER
         DO I=1,M1
            S2=-F2(I)
            S3=-F3(I)
            Z1(I)=Z1(I)-F1(I)*FAC1
            Z2(I)=Z2(I)+S2*ALPHN-S3*BETAN
            Z3(I)=Z3(I)+S3*ALPHN+S2*BETAN
         END DO
         DO I=1,NM1
            IM1=I+M1
            S1=0.0D0
            S2=0.0D0
            S3=0.0D0
            J1B=MAX(1,I-MLMAS)
            J2B=MIN(NM1,I+MUMAS)
            DO J=J1B,J2B
               JM1=J+M1
               BB=FMAS(I-J+MBDIAG,J)
               S1=S1-BB*F1(JM1)
               S2=S2-BB*F2(JM1)
               S3=S3-BB*F3(JM1)
            END DO
            Z1(IM1)=Z1(IM1)+S1*FAC1
            Z2(IM1)=Z2(IM1)+S2*ALPHN-S3*BETAN
            Z3(IM1)=Z3(IM1)+S3*ALPHN+S2*BETAN
         END DO
         IF (IJOB.EQ.14) GOTO 45
         GOTO 48
C
C -----------------------------------------------------------
C
    4    CONTINUE
C ---  B IS A BANDED MATRIX, JACOBIAN A BANDED MATRIX
         DO I=1,N
            S1=0.0D0
            S2=0.0D0
            S3=0.0D0
            DO J=MAX(1,I-MLMAS),MIN(N,I+MUMAS)
               BB=FMAS(I-J+MBDIAG,J)
               S1=S1-BB*F1(J)
               S2=S2-BB*F2(J)
               S3=S3-BB*F3(J)
            END DO
            Z1(I)=Z1(I)+S1*FAC1
            Z2(I)=Z2(I)+S2*ALPHN-S3*BETAN
            Z3(I)=Z3(I)+S3*ALPHN+S2*BETAN
         END DO
         CALL SOLB (N,LDE1,E1,MLE,MUE,Z1,IP1)
         CALL SOLBC(N,LDE1,E2R,E2I,MLE,MUE,Z2,Z3,IP2)
         RETURN
C
C -----------------------------------------------------------
C
    5    CONTINUE
C ---  B IS A FULL MATRIX, JACOBIAN A FULL MATRIX
         DO I=1,N
            S1=0.0D0
            S2=0.0D0
            S3=0.0D0
            DO J=1,N
               BB=FMAS(I,J)
               S1=S1-BB*F1(J)
               S2=S2-BB*F2(J)
               S3=S3-BB*F3(J)
            END DO
            Z1(I)=Z1(I)+S1*FAC1
            Z2(I)=Z2(I)+S2*ALPHN-S3*BETAN
            Z3(I)=Z3(I)+S3*ALPHN+S2*BETAN
         END DO
         CALL SOL (N,LDE1,E1,Z1,IP1)
         CALL SOLC(N,LDE1,E2R,E2I,Z2,Z3,IP2)
         RETURN
C
C -----------------------------------------------------------
C
   15    CONTINUE
C ---  B IS A FULL MATRIX, JACOBIAN A FULL MATRIX, SECOND ORDER
         DO I=1,M1
            S2=-F2(I)
            S3=-F3(I)
            Z1(I)=Z1(I)-F1(I)*FAC1
            Z2(I)=Z2(I)+S2*ALPHN-S3*BETAN
            Z3(I)=Z3(I)+S3*ALPHN+S2*BETAN
         END DO
         DO I=1,NM1
            IM1=I+M1
            S1=0.0D0
            S2=0.0D0
            S3=0.0D0
            DO J=1,NM1
               JM1=J+M1
               BB=FMAS(I,J)
               S1=S1-BB*F1(JM1)
               S2=S2-BB*F2(JM1)
               S3=S3-BB*F3(JM1)
            END DO
            Z1(IM1)=Z1(IM1)+S1*FAC1
            Z2(IM1)=Z2(IM1)+S2*ALPHN-S3*BETAN
            Z3(IM1)=Z3(IM1)+S3*ALPHN+S2*BETAN
         END DO
         GOTO 48
C
C -----------------------------------------------------------
C
    6    CONTINUE
C ---  B IS A FULL MATRIX, JACOBIAN A BANDED MATRIX
C ---  THIS OPTION IS NOT PROVIDED
         RETURN
C
C -----------------------------------------------------------
C
    7    CONTINUE
C ---  B=IDENTITY, JACOBIAN A FULL MATRIX, HESSENBERG-OPTION
         DO I=1,N
            S2=-F2(I)
            S3=-F3(I)
            Z1(I)=Z1(I)-F1(I)*FAC1
            Z2(I)=Z2(I)+S2*ALPHN-S3*BETAN
            Z3(I)=Z3(I)+S3*ALPHN+S2*BETAN
         END DO
         DO MM=N-2,1,-1
            MP=N-MM
            MP1=MP-1
            I=IPHES(MP)
            IF (I.EQ.MP) GOTO 746
            ZSAFE=Z1(MP)
            Z1(MP)=Z1(I)
            Z1(I)=ZSAFE
            ZSAFE=Z2(MP)
            Z2(MP)=Z2(I)
            Z2(I)=ZSAFE
            ZSAFE=Z3(MP)
            Z3(MP)=Z3(I)
            Z3(I)=ZSAFE
  746       CONTINUE
            DO I=MP+1,N
               E1IMP=FJAC(I,MP1)
               Z1(I)=Z1(I)-E1IMP*Z1(MP)
               Z2(I)=Z2(I)-E1IMP*Z2(MP)
               Z3(I)=Z3(I)-E1IMP*Z3(MP)
            END DO
         END DO
         CALL SOLH(N,LDE1,E1,1,Z1,IP1)
         CALL SOLHC(N,LDE1,E2R,E2I,1,Z2,Z3,IP2)
         DO MM=1,N-2
            MP=N-MM
            MP1=MP-1
            DO I=MP+1,N
               E1IMP=FJAC(I,MP1)
               Z1(I)=Z1(I)+E1IMP*Z1(MP)
               Z2(I)=Z2(I)+E1IMP*Z2(MP)
               Z3(I)=Z3(I)+E1IMP*Z3(MP)
            END DO
            I=IPHES(MP)
            IF (I.EQ.MP) GOTO 750
            ZSAFE=Z1(MP)
            Z1(MP)=Z1(I)
            Z1(I)=ZSAFE
            ZSAFE=Z2(MP)
            Z2(MP)=Z2(I)
            Z2(I)=ZSAFE
            ZSAFE=Z3(MP)
            Z3(MP)=Z3(I)
            Z3(I)=ZSAFE
  750       CONTINUE
         END DO
         RETURN
C
C -----------------------------------------------------------
C
   55    CONTINUE
         RETURN
      END
C
C     END OF SUBROUTINE SLVRAD
C
C ***********************************************************
C
      SUBROUTINE ESTRAD(N,FJAC,LDJAC,MLJAC,MUJAC,FMAS,LDMAS,MLMAS,MUMAS,
     &          H,DD1,DD2,DD3,FCN,NFCN,Y0,Y,IJOB,X,M1,M2,NM1,
     &          E1,LDE1,Z1,Z2,Z3,CONT,WERR,F1,F2,IP1,IPHES,SCAL,ERR,
     &          FIRST,REJECT,FAC1,RPAR,IPAR)
         IMPLICIT DOUBLE PRECISION (A-H,O-Z)
         DIMENSION FJAC(LDJAC,N),FMAS(LDMAS,NM1),E1(LDE1,NM1),IP1(NM1),
     &        SCAL(N),IPHES(N),Z1(N),Z2(N),Z3(N),F1(N),F2(N),Y0(N),Y(N)
         DIMENSION CONT(N),WERR(N),RPAR(1),IPAR(1)
         LOGICAL FIRST,REJECT
         COMMON/LINAL/MLE,MUE,MBJAC,MBB,MDIAG,MDIFF,MBDIAG
         HEE1=DD1/H
         HEE2=DD2/H
         HEE3=DD3/H
         GOTO (1,2,3,4,5,6,7,55,55,55,11,12,13,14,15), IJOB
C
    1    CONTINUE
C ------  B=IDENTITY, JACOBIAN A FULL MATRIX
         DO  I=1,N
            F2(I)=HEE1*Z1(I)+HEE2*Z2(I)+HEE3*Z3(I)
            CONT(I)=F2(I)+Y0(I)
         END DO
         CALL SOL (N,LDE1,E1,CONT,IP1)
         GOTO 77
C
   11    CONTINUE
C ------  B=IDENTITY, JACOBIAN A FULL MATRIX, SECOND ORDER
         DO I=1,N
            F2(I)=HEE1*Z1(I)+HEE2*Z2(I)+HEE3*Z3(I)
            CONT(I)=F2(I)+Y0(I)
         END DO
   48    MM=M1/M2
         DO J=1,M2
            SUM1=0.D0
            DO K=MM-1,0,-1
               SUM1=(CONT(J+K*M2)+SUM1)/FAC1
               DO I=1,NM1
                  IM1=I+M1
                  CONT(IM1)=CONT(IM1)+FJAC(I,J+K*M2)*SUM1
               END DO
            END DO
         END DO
         CALL SOL (NM1,LDE1,E1,CONT(M1+1),IP1)
         DO I=M1,1,-1
            CONT(I)=(CONT(I)+CONT(M2+I))/FAC1
         END DO
         GOTO 77
C
    2    CONTINUE
C ------  B=IDENTITY, JACOBIAN A BANDED MATRIX
         DO I=1,N
            F2(I)=HEE1*Z1(I)+HEE2*Z2(I)+HEE3*Z3(I)
            CONT(I)=F2(I)+Y0(I)
         END DO
         CALL SOLB (N,LDE1,E1,MLE,MUE,CONT,IP1)
         GOTO 77
C
   12    CONTINUE
C ------  B=IDENTITY, JACOBIAN A BANDED MATRIX, SECOND ORDER
         DO I=1,N
            F2(I)=HEE1*Z1(I)+HEE2*Z2(I)+HEE3*Z3(I)
            CONT(I)=F2(I)+Y0(I)
         END DO
   45    MM=M1/M2
         DO J=1,M2
            SUM1=0.D0
            DO K=MM-1,0,-1
               SUM1=(CONT(J+K*M2)+SUM1)/FAC1
               DO I=MAX(1,J-MUJAC),MIN(NM1,J+MLJAC)
                  IM1=I+M1
                  CONT(IM1)=CONT(IM1)+FJAC(I+MUJAC+1-J,J+K*M2)*SUM1
               END DO
            END DO
         END DO
         CALL SOLB (NM1,LDE1,E1,MLE,MUE,CONT(M1+1),IP1)
         DO I=M1,1,-1
            CONT(I)=(CONT(I)+CONT(M2+I))/FAC1
         END DO
         GOTO 77
C
    3    CONTINUE
C ------  B IS A BANDED MATRIX, JACOBIAN A FULL MATRIX
         DO I=1,N
            F1(I)=HEE1*Z1(I)+HEE2*Z2(I)+HEE3*Z3(I)
         END DO
         DO I=1,N
            SUM=0.D0
            DO J=MAX(1,I-MLMAS),MIN(N,I+MUMAS)
               SUM=SUM+FMAS(I-J+MBDIAG,J)*F1(J)
            END DO
            F2(I)=SUM
            CONT(I)=SUM+Y0(I)
         END DO
         CALL SOL (N,LDE1,E1,CONT,IP1)
         GOTO 77
C
   13    CONTINUE
C ------  B IS A BANDED MATRIX, JACOBIAN A FULL MATRIX, SECOND ORDER
         DO I=1,M1
            F2(I)=HEE1*Z1(I)+HEE2*Z2(I)+HEE3*Z3(I)
            CONT(I)=F2(I)+Y0(I)
         END DO
         DO I=M1+1,N
            F1(I)=HEE1*Z1(I)+HEE2*Z2(I)+HEE3*Z3(I)
         END DO
         DO I=1,NM1
            SUM=0.D0
            DO J=MAX(1,I-MLMAS),MIN(NM1,I+MUMAS)
               SUM=SUM+FMAS(I-J+MBDIAG,J)*F1(J+M1)
            END DO
            IM1=I+M1
            F2(IM1)=SUM
            CONT(IM1)=SUM+Y0(IM1)
         END DO
         GOTO 48
C
    4    CONTINUE
C ------  B IS A BANDED MATRIX, JACOBIAN A BANDED MATRIX
         DO I=1,N
            F1(I)=HEE1*Z1(I)+HEE2*Z2(I)+HEE3*Z3(I)
         END DO
         DO I=1,N
            SUM=0.D0
            DO J=MAX(1,I-MLMAS),MIN(N,I+MUMAS)
               SUM=SUM+FMAS(I-J+MBDIAG,J)*F1(J)
            END DO
            F2(I)=SUM
            CONT(I)=SUM+Y0(I)
         END DO
         CALL SOLB (N,LDE1,E1,MLE,MUE,CONT,IP1)
         GOTO 77
C
   14    CONTINUE
C ------  B IS A BANDED MATRIX, JACOBIAN A BANDED MATRIX, SECOND ORDER
         DO I=1,M1
            F2(I)=HEE1*Z1(I)+HEE2*Z2(I)+HEE3*Z3(I)
            CONT(I)=F2(I)+Y0(I)
         END DO
         DO I=M1+1,N
            F1(I)=HEE1*Z1(I)+HEE2*Z2(I)+HEE3*Z3(I)
         END DO
         DO I=1,NM1
            SUM=0.D0
            DO J=MAX(1,I-MLMAS),MIN(NM1,I+MUMAS)
               SUM=SUM+FMAS(I-J+MBDIAG,J)*F1(J+M1)
            END DO
            IM1=I+M1
            F2(IM1)=SUM
            CONT(IM1)=SUM+Y0(IM1)
         END DO
         GOTO 45
C
    5    CONTINUE
C ------  B IS A FULL MATRIX, JACOBIAN A FULL MATRIX
         DO I=1,N
            F1(I)=HEE1*Z1(I)+HEE2*Z2(I)+HEE3*Z3(I)
         END DO
         DO I=1,N
            SUM=0.D0
            DO J=1,N
               SUM=SUM+FMAS(I,J)*F1(J)
            END DO
            F2(I)=SUM
            CONT(I)=SUM+Y0(I)
         END DO
         CALL SOL (N,LDE1,E1,CONT,IP1)
         GOTO 77
C
   15    CONTINUE
C ------  B IS A BANDED MATRIX, JACOBIAN A FULL MATRIX, SECOND ORDER
         DO I=1,M1
            F2(I)=HEE1*Z1(I)+HEE2*Z2(I)+HEE3*Z3(I)
            CONT(I)=F2(I)+Y0(I)
         END DO
         DO I=M1+1,N
            F1(I)=HEE1*Z1(I)+HEE2*Z2(I)+HEE3*Z3(I)
         END DO
         DO I=1,NM1
            SUM=0.D0
            DO J=1,NM1
               SUM=SUM+FMAS(I,J)*F1(J+M1)
            END DO
            IM1=I+M1
            F2(IM1)=SUM
            CONT(IM1)=SUM+Y0(IM1)
         END DO
         GOTO 48
C
    6    CONTINUE
C ------  B IS A FULL MATRIX, JACOBIAN A BANDED MATRIX
C ------  THIS OPTION IS NOT PROVIDED
         RETURN
C
    7    CONTINUE
C ------  B=IDENTITY, JACOBIAN A FULL MATRIX, HESSENBERG-OPTION
         DO I=1,N
            F2(I)=HEE1*Z1(I)+HEE2*Z2(I)+HEE3*Z3(I)
            CONT(I)=F2(I)+Y0(I)
         END DO
         DO MM=N-2,1,-1
            MP=N-MM
            I=IPHES(MP)
            IF (I.EQ.MP) GOTO 310
            ZSAFE=CONT(MP)
            CONT(MP)=CONT(I)
            CONT(I)=ZSAFE
  310       CONTINUE
            DO I=MP+1,N
               CONT(I)=CONT(I)-FJAC(I,MP-1)*CONT(MP)
            END DO
         END DO
         CALL SOLH(N,LDE1,E1,1,CONT,IP1)
         DO MM=1,N-2
            MP=N-MM
            DO I=MP+1,N
               CONT(I)=CONT(I)+FJAC(I,MP-1)*CONT(MP)
            END DO
            I=IPHES(MP)
            IF (I.EQ.MP) GOTO 440
            ZSAFE=CONT(MP)
            CONT(MP)=CONT(I)
            CONT(I)=ZSAFE
  440       CONTINUE
         END DO
C
C --------------------------------------
C
   77    CONTINUE
         ERR=0.D0
         DO  I=1,N
            WERR(I) = CONT(I)/SCAL(I)
            ERR=ERR+(WERR(I))**2
         END DO
         ERR=MAX(SQRT(ERR/N),1.D-10)
C
         IF (ERR.LT.1.D0) RETURN
         IF (FIRST.OR.REJECT) THEN
            DO I=1,N
               CONT(I)=Y(I)+CONT(I)
            END DO
            CALL FCN(N,X,CONT,F1,RPAR,IPAR)
            NFCN=NFCN+1
            DO I=1,N
               CONT(I)=F1(I)+F2(I)
            END DO
            GOTO (31,32,31,32,31,32,33,55,55,55,41,42,41,42,41), IJOB
C ------ FULL MATRIX OPTION
   31       CONTINUE
            CALL SOL(N,LDE1,E1,CONT,IP1)
            GOTO 88
C ------ FULL MATRIX OPTION, SECOND ORDER
   41       CONTINUE
            DO J=1,M2
               SUM1=0.D0
               DO K=MM-1,0,-1
                  SUM1=(CONT(J+K*M2)+SUM1)/FAC1
                  DO I=1,NM1
                     IM1=I+M1
                     CONT(IM1)=CONT(IM1)+FJAC(I,J+K*M2)*SUM1
                  END DO
               END DO
            END DO
            CALL SOL(NM1,LDE1,E1,CONT(M1+1),IP1)
            DO I=M1,1,-1
               CONT(I)=(CONT(I)+CONT(M2+I))/FAC1
            END DO
            GOTO 88
C ------ BANDED MATRIX OPTION
   32       CONTINUE
            CALL SOLB (N,LDE1,E1,MLE,MUE,CONT,IP1)
            GOTO 88
C ------ BANDED MATRIX OPTION, SECOND ORDER
   42       CONTINUE
            DO J=1,M2
               SUM1=0.D0
               DO K=MM-1,0,-1
                  SUM1=(CONT(J+K*M2)+SUM1)/FAC1
                  DO I=MAX(1,J-MUJAC),MIN(NM1,J+MLJAC)
                     IM1=I+M1
                     CONT(IM1)=CONT(IM1)+FJAC(I+MUJAC+1-J,J+K*M2)*SUM1
                  END DO
               END DO
            END DO
            CALL SOLB (NM1,LDE1,E1,MLE,MUE,CONT(M1+1),IP1)
            DO I=M1,1,-1
               CONT(I)=(CONT(I)+CONT(M2+I))/FAC1
            END DO
            GOTO 88
C ------ HESSENBERG MATRIX OPTION
   33       CONTINUE
            DO MM=N-2,1,-1
               MP=N-MM
               I=IPHES(MP)
               IF (I.EQ.MP) GOTO 510
               ZSAFE=CONT(MP)
               CONT(MP)=CONT(I)
               CONT(I)=ZSAFE
  510          CONTINUE
               DO I=MP+1,N
                  CONT(I)=CONT(I)-FJAC(I,MP-1)*CONT(MP)
               END DO
            END DO
            CALL SOLH(N,LDE1,E1,1,CONT,IP1)
            DO MM=1,N-2
               MP=N-MM
               DO I=MP+1,N
                  CONT(I)=CONT(I)+FJAC(I,MP-1)*CONT(MP)
               END DO
               I=IPHES(MP)
               IF (I.EQ.MP) GOTO 640
               ZSAFE=CONT(MP)
               CONT(MP)=CONT(I)
               CONT(I)=ZSAFE
  640          CONTINUE
            END DO
C -----------------------------------
   88       CONTINUE
            ERR=0.D0
            DO I=1,N
               WERR(I) = CONT(I)/SCAL(I)
               ERR=ERR+(WERR(I))**2
            END DO
            ERR=MAX(SQRT(ERR/N),1.D-10)
         END IF
         RETURN
C -----------------------------------------------------------
   55    CONTINUE
         RETURN
      END
C
C     END OF SUBROUTINE ESTRAD
C
C ***********************************************************
C
      SUBROUTINE ESTRAV(N,FJAC,LDJAC,MLJAC,MUJAC,FMAS,LDMAS,MLMAS,MUMAS,
     &          H,DD,FCN,NFCN,Y0,Y,IJOB,X,M1,M2,NM1,NS,NNS,
     &          E1,LDE1,ZZ,CONT,FF,IP1,IPHES,SCAL,ERR,
     &          FIRST,REJECT,FAC1,RPAR,IPAR)
         IMPLICIT REAL*8 (A-H,O-Z)
         DIMENSION FJAC(LDJAC,N),FMAS(LDMAS,NM1),E1(LDE1,NM1),IP1(NM1),
     &        SCAL(N),IPHES(N),ZZ(NNS),FF(NNS),Y0(N),Y(N)
         DIMENSION DD(NS),CONT(N),RPAR(1),IPAR(1)
         LOGICAL FIRST,REJECT
         COMMON/LINAL/MLE,MUE,MBJAC,MBB,MDIAG,MDIFF,MBDIAG
         GOTO (1,2,3,4,5,6,7,55,55,55,11,12,13,14,15), IJOB
C
    1    CONTINUE
C ------  B=IDENTITY, JACOBIAN A FULL MATRIX
         DO  I=1,N
            SUM=0.D0
            DO K=1,NS
               SUM=SUM+DD(K)*ZZ(I+(K-1)*N)
            END DO
            FF(I+N)=SUM/H
            CONT(I)=FF(I+N)+Y0(I)
         END DO
         CALL SOL (N,LDE1,E1,CONT,IP1)
         GOTO 77
C
   11    CONTINUE
C ------  B=IDENTITY, JACOBIAN A FULL MATRIX, SECOND ORDER
         DO  I=1,N
            SUM=0.D0
            DO K=1,NS
               SUM=SUM+DD(K)*ZZ(I+(K-1)*N)
            END DO
            FF(I+N)=SUM/H
            CONT(I)=FF(I+N)+Y0(I)
         END DO
   48    MM=M1/M2
         DO J=1,M2
            SUM1=0.D0
            DO K=MM-1,0,-1
               SUM1=(CONT(J+K*M2)+SUM1)/FAC1
               DO I=1,NM1
                  IM1=I+M1
                  CONT(IM1)=CONT(IM1)+FJAC(I,J+K*M2)*SUM1
               END DO
            END DO
         END DO
         CALL SOL (NM1,LDE1,E1,CONT(M1+1),IP1)
         DO I=M1,1,-1
            CONT(I)=(CONT(I)+CONT(M2+I))/FAC1
         END DO
         GOTO 77
C
    2    CONTINUE
C ------  B=IDENTITY, JACOBIAN A BANDED MATRIX
         DO  I=1,N
            SUM=0.D0
            DO K=1,NS
               SUM=SUM+DD(K)*ZZ(I+(K-1)*N)
            END DO
            FF(I+N)=SUM/H
            CONT(I)=FF(I+N)+Y0(I)
         END DO
         CALL SOLB (N,LDE1,E1,MLE,MUE,CONT,IP1)
         GOTO 77
C
   12    CONTINUE
C ------  B=IDENTITY, JACOBIAN A BANDED MATRIX, SECOND ORDER
         DO  I=1,N
            SUM=0.D0
            DO K=1,NS
               SUM=SUM+DD(K)*ZZ(I+(K-1)*N)
            END DO
            FF(I+N)=SUM/H
            CONT(I)=FF(I+N)+Y0(I)
         END DO
   45    MM=M1/M2
         DO J=1,M2
            SUM1=0.D0
            DO K=MM-1,0,-1
               SUM1=(CONT(J+K*M2)+SUM1)/FAC1
               DO I=MAX(1,J-MUJAC),MIN(NM1,J+MLJAC)
                  IM1=I+M1
                  CONT(IM1)=CONT(IM1)+FJAC(I+MUJAC+1-J,J+K*M2)*SUM1
               END DO
            END DO
         END DO
         CALL SOLB (NM1,LDE1,E1,MLE,MUE,CONT(M1+1),IP1)
         DO I=M1,1,-1
            CONT(I)=(CONT(I)+CONT(M2+I))/FAC1
         END DO
         GOTO 77
C
    3    CONTINUE
C ------  B IS A BANDED MATRIX, JACOBIAN A FULL MATRIX
         DO  I=1,N
            SUM=0.D0
            DO K=1,NS
               SUM=SUM+DD(K)*ZZ(I+(K-1)*N)
            END DO
            FF(I)=SUM/H
         END DO
         DO I=1,N
            SUM=0.D0
            DO J=MAX(1,I-MLMAS),MIN(N,I+MUMAS)
               SUM=SUM+FMAS(I-J+MBDIAG,J)*FF(J)
            END DO
            FF(I+N)=SUM
            CONT(I)=SUM+Y0(I)
         END DO
         CALL SOL (N,LDE1,E1,CONT,IP1)
         GOTO 77
C
   13    CONTINUE
C ------  B IS A BANDED MATRIX, JACOBIAN A FULL MATRIX, SECOND ORDER
         DO  I=1,M1
            SUM=0.D0
            DO K=1,NS
               SUM=SUM+DD(K)*ZZ(I+(K-1)*N)
            END DO
            FF(I+N)=SUM/H
            CONT(I)=FF(I+N)+Y0(I)
         END DO
         DO I=M1+1,N
            SUM=0.D0
            DO K=1,NS
               SUM=SUM+DD(K)*ZZ(I+(K-1)*N)
            END DO
            FF(I)=SUM/H
         END DO
         DO I=1,NM1
            SUM=0.D0
            DO J=MAX(1,I-MLMAS),MIN(NM1,I+MUMAS)
               SUM=SUM+FMAS(I-J+MBDIAG,J)*FF(J+M1)
            END DO
            IM1=I+M1
            FF(IM1+N)=SUM
            CONT(IM1)=SUM+Y0(IM1)
         END DO
         GOTO 48
C
    4    CONTINUE
C ------  B IS A BANDED MATRIX, JACOBIAN A BANDED MATRIX
         DO  I=1,N
            SUM=0.D0
            DO K=1,NS
               SUM=SUM+DD(K)*ZZ(I+(K-1)*N)
            END DO
            FF(I)=SUM/H
         END DO
         DO I=1,N
            SUM=0.D0
            DO J=MAX(1,I-MLMAS),MIN(N,I+MUMAS)
               SUM=SUM+FMAS(I-J+MBDIAG,J)*FF(J)
            END DO
            FF(I+N)=SUM
            CONT(I)=SUM+Y0(I)
         END DO
         CALL SOLB (N,LDE1,E1,MLE,MUE,CONT,IP1)
         GOTO 77
C
   14    CONTINUE
C ------  B IS A BANDED MATRIX, JACOBIAN A BANDED MATRIX, SECOND ORDER
         DO  I=1,M1
            SUM=0.D0
            DO K=1,NS
               SUM=SUM+DD(K)*ZZ(I+(K-1)*N)
            END DO
            FF(I+N)=SUM/H
            CONT(I)=FF(I+N)+Y0(I)
         END DO
         DO I=M1+1,N
            SUM=0.D0
            DO K=1,NS
               SUM=SUM+DD(K)*ZZ(I+(K-1)*N)
            END DO
            FF(I)=SUM/H
         END DO
         DO I=1,NM1
            SUM=0.D0
            DO J=MAX(1,I-MLMAS),MIN(NM1,I+MUMAS)
               SUM=SUM+FMAS(I-J+MBDIAG,J)*FF(J+M1)
            END DO
            IM1=I+M1
            FF(IM1+N)=SUM
            CONT(IM1)=SUM+Y0(IM1)
         END DO
         GOTO 45
C
    5    CONTINUE
C ------  B IS A FULL MATRIX, JACOBIAN A FULL MATRIX
         DO I=1,N
            SUM=0.D0
            DO K=1,NS
               SUM=SUM+DD(K)*ZZ(I+(K-1)*N)
            END DO
            FF(I)=SUM/H
         END DO
         DO I=1,N
            SUM=0.D0
            DO J=1,N
               SUM=SUM+FMAS(I,J)*FF(J)
            END DO
            FF(I+N)=SUM
            CONT(I)=SUM+Y0(I)
         END DO
         CALL SOL (N,LDE1,E1,CONT,IP1)
         GOTO 77
C
   15    CONTINUE
C ------  B IS A BANDED MATRIX, JACOBIAN A FULL MATRIX, SECOND ORDER
         DO  I=1,M1
            SUM=0.D0
            DO K=1,NS
               SUM=SUM+DD(K)*ZZ(I+(K-1)*N)
            END DO
            FF(I+N)=SUM/H
            CONT(I)=FF(I+N)+Y0(I)
         END DO
         DO I=M1+1,N
            SUM=0.D0
            DO K=1,NS
               SUM=SUM+DD(K)*ZZ(I+(K-1)*N)
            END DO
            FF(I)=SUM/H
         END DO
         DO I=1,NM1
            SUM=0.D0
            DO J=1,NM1
               SUM=SUM+FMAS(I,J)*FF(J+M1)
            END DO
            IM1=I+M1
            FF(IM1+N)=SUM
            CONT(IM1)=SUM+Y0(IM1)
         END DO
         GOTO 48
C
    6    CONTINUE
C ------  B IS A FULL MATRIX, JACOBIAN A BANDED MATRIX
C ------  THIS OPTION IS NOT PROVIDED
         RETURN
C
    7    CONTINUE
C ------  B=IDENTITY, JACOBIAN A FULL MATRIX, HESSENBERG-OPTION
         DO  I=1,N
            SUM=0.D0
            DO K=1,NS
               SUM=SUM+DD(K)*ZZ(I+(K-1)*N)
            END DO
            FF(I+N)=SUM/H
            CONT(I)=FF(I+N)+Y0(I)
         END DO
         DO MM=N-2,1,-1
            MP=N-MM
            I=IPHES(MP)
            IF (I.EQ.MP) GOTO 310
            ZSAFE=CONT(MP)
            CONT(MP)=CONT(I)
            CONT(I)=ZSAFE
  310       CONTINUE
            DO I=MP+1,N
               CONT(I)=CONT(I)-FJAC(I,MP-1)*CONT(MP)
            END DO
         END DO
         CALL SOLH(N,LDE1,E1,1,CONT,IP1)
         DO MM=1,N-2
            MP=N-MM
            DO I=MP+1,N
               CONT(I)=CONT(I)+FJAC(I,MP-1)*CONT(MP)
            END DO
            I=IPHES(MP)
            IF (I.EQ.MP) GOTO 440
            ZSAFE=CONT(MP)
            CONT(MP)=CONT(I)
            CONT(I)=ZSAFE
  440       CONTINUE
         END DO
C
C --------------------------------------
C
   77    CONTINUE
         ERR=0.D0
         DO  I=1,N
            ERR=ERR+(CONT(I)/SCAL(I))**2
         END DO
         ERR=MAX(SQRT(ERR/N),1.D-10)
C
         IF (ERR.LT.1.D0) RETURN
         IF (FIRST.OR.REJECT) THEN
            DO I=1,N
               CONT(I)=Y(I)+CONT(I)
            END DO
            CALL FCN(N,X,CONT,FF,RPAR,IPAR)
            NFCN=NFCN+1
            DO I=1,N
               CONT(I)=FF(I)+FF(I+N)
            END DO
            GOTO (31,32,31,32,31,32,33,55,55,55,41,42,41,42,41), IJOB
C ------ FULL MATRIX OPTION
   31       CONTINUE
            CALL SOL (N,LDE1,E1,CONT,IP1)
            GOTO 88
C ------ FULL MATRIX OPTION, SECOND ORDER
   41       CONTINUE
            DO J=1,M2
               SUM1=0.D0
               DO K=MM-1,0,-1
                  SUM1=(CONT(J+K*M2)+SUM1)/FAC1
                  DO I=1,NM1
                     IM1=I+M1
                     CONT(IM1)=CONT(IM1)+FJAC(I,J+K*M2)*SUM1
                  END DO
               END DO
            END DO
            CALL SOL (NM1,LDE1,E1,CONT(M1+1),IP1)
            DO I=M1,1,-1
               CONT(I)=(CONT(I)+CONT(M2+I))/FAC1
            END DO
            GOTO 88
C ------ BANDED MATRIX OPTION
   32       CONTINUE
            CALL SOLB (N,LDE1,E1,MLE,MUE,CONT,IP1)
            GOTO 88
C ------ BANDED MATRIX OPTION, SECOND ORDER
   42       CONTINUE
            DO J=1,M2
               SUM1=0.D0
               DO K=MM-1,0,-1
                  SUM1=(CONT(J+K*M2)+SUM1)/FAC1
                  DO I=MAX(1,J-MUJAC),MIN(NM1,J+MLJAC)
                     IM1=I+M1
                     CONT(IM1)=CONT(IM1)+FJAC(I+MUJAC+1-J,J+K*M2)*SUM1
                  END DO
               END DO
            END DO
            CALL SOLB (NM1,LDE1,E1,MLE,MUE,CONT(M1+1),IP1)
            DO I=M1,1,-1
               CONT(I)=(CONT(I)+CONT(M2+I))/FAC1
            END DO
            GOTO 88
C ------ HESSENBERG MATRIX OPTION
   33       CONTINUE
            DO MM=N-2,1,-1
               MP=N-MM
               I=IPHES(MP)
               IF (I.EQ.MP) GOTO 510
               ZSAFE=CONT(MP)
               CONT(MP)=CONT(I)
               CONT(I)=ZSAFE
  510          CONTINUE
               DO I=MP+1,N
                  CONT(I)=CONT(I)-FJAC(I,MP-1)*CONT(MP)
               END DO
            END DO
            CALL SOLH(N,LDE1,E1,1,CONT,IP1)
            DO MM=1,N-2
               MP=N-MM
               DO I=MP+1,N
                  CONT(I)=CONT(I)+FJAC(I,MP-1)*CONT(MP)
               END DO
               I=IPHES(MP)
               IF (I.EQ.MP) GOTO 640
               ZSAFE=CONT(MP)
               CONT(MP)=CONT(I)
               CONT(I)=ZSAFE
  640          CONTINUE
            END DO
C -----------------------------------
   88       CONTINUE
            ERR=0.D0
            DO I=1,N
               ERR=ERR+(CONT(I)/SCAL(I))**2
            END DO
            ERR=MAX(SQRT(ERR/N),1.D-10)
         END IF
         RETURN
C
C -----------------------------------------------------------
C
   55    CONTINUE
         RETURN
      END
C
C     END OF SUBROUTINE ESTRAV
C
C ***********************************************************
C
      SUBROUTINE SLVROD(N,FJAC,LDJAC,MLJAC,MUJAC,FMAS,LDMAS,MLMAS,MUMAS,
     &          M1,M2,NM1,FAC1,E,LDE,IP,DY,AK,FX,YNEW,HD,IJOB,STAGE1)
         IMPLICIT REAL*8 (A-H,O-Z)
         DIMENSION FJAC(LDJAC,N),FMAS(LDMAS,NM1),E(LDE,NM1),
     &             IP(NM1),DY(N),AK(N),FX(N),YNEW(N)
         LOGICAL STAGE1
         COMMON/LINAL/MLE,MUE,MBJAC,MBB,MDIAG,MDIFF,MBDIAG
C
         IF (HD.EQ.0.D0) THEN
            DO  I=1,N
               AK(I)=DY(I)
            END DO
         ELSE
            DO I=1,N
               AK(I)=DY(I)+HD*FX(I)
            END DO
         END IF
C
         GOTO (1,2,3,4,5,6,55,55,55,55,11,12,13,13,15), IJOB
C
C -----------------------------------------------------------
C
    1    CONTINUE
C ---  B=IDENTITY, JACOBIAN A FULL MATRIX
         IF (STAGE1) THEN
            DO I=1,N
               AK(I)=AK(I)+YNEW(I)
            END DO
         END IF
         CALL SOL (N,LDE,E,AK,IP)
         RETURN
C
C -----------------------------------------------------------
C
   11    CONTINUE
C ---  B=IDENTITY, JACOBIAN A FULL MATRIX, SECOND ORDER
         IF (STAGE1) THEN
            DO I=1,N
               AK(I)=AK(I)+YNEW(I)
            END DO
         END IF
   48    MM=M1/M2
         DO J=1,M2
            SUM=0.D0
            DO K=MM-1,0,-1
               JKM=J+K*M2
               SUM=(AK(JKM)+SUM)/FAC1
               DO I=1,NM1
                  IM1=I+M1
                  AK(IM1)=AK(IM1)+FJAC(I,JKM)*SUM
               END DO
            END DO
         END DO
         CALL SOL (NM1,LDE,E,AK(M1+1),IP)
         DO I=M1,1,-1
            AK(I)=(AK(I)+AK(M2+I))/FAC1
         END DO
         RETURN
C
C -----------------------------------------------------------
C
    2    CONTINUE
C ---  B=IDENTITY, JACOBIAN A BANDED MATRIX
         IF (STAGE1) THEN
            DO I=1,N
               AK(I)=AK(I)+YNEW(I)
            END DO
         END IF
         CALL SOLB (N,LDE,E,MLE,MUE,AK,IP)
         RETURN
C
C -----------------------------------------------------------
C
   12    CONTINUE
C ---  B=IDENTITY, JACOBIAN A BANDED MATRIX, SECOND ORDER
         IF (STAGE1) THEN
            DO I=1,N
               AK(I)=AK(I)+YNEW(I)
            END DO
         END IF
   45    MM=M1/M2
         DO J=1,M2
            SUM=0.D0
            DO K=MM-1,0,-1
               JKM=J+K*M2
               SUM=(AK(JKM)+SUM)/FAC1
               DO I=MAX(1,J-MUJAC),MIN(NM1,J+MLJAC)
                  IM1=I+M1
                  AK(IM1)=AK(IM1)+FJAC(I+MUJAC+1-J,JKM)*SUM
               END DO
            END DO
         END DO
         CALL SOLB (NM1,LDE,E,MLE,MUE,AK(M1+1),IP)
         DO I=M1,1,-1
            AK(I)=(AK(I)+AK(M2+I))/FAC1
         END DO
         RETURN
C
C -----------------------------------------------------------
C
    3    CONTINUE
C ---  B IS A BANDED MATRIX, JACOBIAN A FULL MATRIX
         IF (STAGE1) THEN
            DO  I=1,N
               SUM=0.D0
               DO  J=MAX(1,I-MLMAS),MIN(N,I+MUMAS)
                  SUM=SUM+FMAS(I-J+MBDIAG,J)*YNEW(J)
               END DO
               AK(I)=AK(I)+SUM
            END DO
         END IF
         CALL SOL (N,LDE,E,AK,IP)
         RETURN
C
C -----------------------------------------------------------
C
   13    CONTINUE
C ---  B IS A BANDED MATRIX, JACOBIAN A FULL MATRIX, SECOND ORDER
         IF (STAGE1) THEN
            DO I=1,M1
               AK(I)=AK(I)+YNEW(I)
            END DO
            DO I=1,NM1
               SUM=0.D0
               DO J=MAX(1,I-MLMAS),MIN(NM1,I+MUMAS)
                  SUM=SUM+FMAS(I-J+MBDIAG,J)*YNEW(J+M1)
               END DO
               IM1=I+M1
               AK(IM1)=AK(IM1)+SUM
            END DO
         END IF
         IF (IJOB.EQ.14) GOTO 45
         GOTO 48
C
C -----------------------------------------------------------
C
    4    CONTINUE
C ---  B IS A BANDED MATRIX, JACOBIAN A BANDED MATRIX
         IF (STAGE1) THEN
            DO I=1,N
               SUM=0.D0
               DO J=MAX(1,I-MLMAS),MIN(N,I+MUMAS)
                  SUM=SUM+FMAS(I-J+MBDIAG,J)*YNEW(J)
               END DO
               AK(I)=AK(I)+SUM
            END DO
         END IF
         CALL SOLB (N,LDE,E,MLE,MUE,AK,IP)
         RETURN
C
C -----------------------------------------------------------
C
    5    CONTINUE
C ---  B IS A FULL MATRIX, JACOBIAN A FULL MATRIX
         IF (STAGE1) THEN
            DO I=1,N
               SUM=0.D0
               DO J=1,N
                  SUM=SUM+FMAS(I,J)*YNEW(J)
               END DO
               AK(I)=AK(I)+SUM
            END DO
         END IF
         CALL SOL (N,LDE,E,AK,IP)
         RETURN
C
C -----------------------------------------------------------
C
   15    CONTINUE
C ---  B IS A FULL MATRIX, JACOBIAN A FULL MATRIX, SECOND ORDER
         IF (STAGE1) THEN
            DO I=1,M1
               AK(I)=AK(I)+YNEW(I)
            END DO
            DO I=1,NM1
               SUM=0.D0
               DO J=1,NM1
                  SUM=SUM+FMAS(I,J)*YNEW(J+M1)
               END DO
               IM1=I+M1
               AK(IM1)=AK(IM1)+SUM
            END DO
         END IF
         GOTO 48
C
C -----------------------------------------------------------
C
    6    CONTINUE
C ---  B IS A FULL MATRIX, JACOBIAN A BANDED MATRIX
C ---  THIS OPTION IS NOT PROVIDED
         IF (STAGE1) THEN
            DO 624 I=1,N
               SUM=0.D0
               DO 623 J=1,N
  623          SUM=SUM+FMAS(I,J)*YNEW(J)
  624       AK(I)=AK(I)+SUM
            CALL SOLB (N,LDE,E,MLE,MUE,AK,IP)
         END IF
         RETURN
C
C -----------------------------------------------------------
C
   55    CONTINUE
         RETURN
      END
C
C     END OF SUBROUTINE SLVROD
C
C
C ***********************************************************
C
      SUBROUTINE SLVSEU(N,FJAC,LDJAC,MLJAC,MUJAC,FMAS,LDMAS,MLMAS,MUMAS,
     &          M1,M2,NM1,FAC1,E,LDE,IP,IPHES,DEL,IJOB)
         IMPLICIT REAL*8 (A-H,O-Z)
         DIMENSION FJAC(LDJAC,N),FMAS(LDMAS,NM1),E(LDE,NM1),DEL(N)
         DIMENSION IP(NM1),IPHES(N)
         COMMON/LINAL/MLE,MUE,MBJAC,MBB,MDIAG,MDIFF,MBDIAG
C
         GOTO (1,2,1,2,1,55,7,55,55,55,11,12,11,12,11), IJOB
C
C -----------------------------------------------------------
C
    1    CONTINUE
C ---  B=IDENTITY, JACOBIAN A FULL MATRIX
         CALL SOL (N,LDE,E,DEL,IP)
         RETURN
C
C -----------------------------------------------------------
C
   11    CONTINUE
C ---  B=IDENTITY, JACOBIAN A FULL MATRIX, SECOND ORDER
         MM=M1/M2
         DO J=1,M2
            SUM=0.D0
            DO K=MM-1,0,-1
               JKM=J+K*M2
               SUM=(DEL(JKM)+SUM)/FAC1
               DO I=1,NM1
                  IM1=I+M1
                  DEL(IM1)=DEL(IM1)+FJAC(I,JKM)*SUM
               END DO
            END DO
         END DO
         CALL SOL (NM1,LDE,E,DEL(M1+1),IP)
         DO I=M1,1,-1
            DEL(I)=(DEL(I)+DEL(M2+I))/FAC1
         END DO
         RETURN
C
C -----------------------------------------------------------
C
    2    CONTINUE
C ---  B=IDENTITY, JACOBIAN A BANDED MATRIX
         CALL SOLB (N,LDE,E,MLE,MUE,DEL,IP)
         RETURN
C
C -----------------------------------------------------------
C
   12    CONTINUE
C ---  B=IDENTITY, JACOBIAN A BANDED MATRIX, SECOND ORDER
         MM=M1/M2
         DO J=1,M2
            SUM=0.D0
            DO K=MM-1,0,-1
               JKM=J+K*M2
               SUM=(DEL(JKM)+SUM)/FAC1
               DO I=MAX(1,J-MUJAC),MIN(NM1,J+MLJAC)
                  IM1=I+M1
                  DEL(IM1)=DEL(IM1)+FJAC(I+MUJAC+1-J,JKM)*SUM
               END DO
            END DO
         END DO
         CALL SOLB (NM1,LDE,E,MLE,MUE,DEL(M1+1),IP)
         DO I=M1,1,-1
            DEL(I)=(DEL(I)+DEL(M2+I))/FAC1
         END DO
         RETURN
C
C -----------------------------------------------------------
C
    7    CONTINUE
C ---  HESSENBERG OPTION
         DO MMM=N-2,1,-1
            MP=N-MMM
            MP1=MP-1
            I=IPHES(MP)
            IF (I.EQ.MP) GOTO 110
            ZSAFE=DEL(MP)
            DEL(MP)=DEL(I)
            DEL(I)=ZSAFE
  110       CONTINUE
            DO I=MP+1,N
               DEL(I)=DEL(I)-FJAC(I,MP1)*DEL(MP)
            END DO
         END DO
         CALL SOLH(N,LDE,E,1,DEL,IP)
         DO MMM=1,N-2
            MP=N-MMM
            MP1=MP-1
            DO I=MP+1,N
               DEL(I)=DEL(I)+FJAC(I,MP1)*DEL(MP)
            END DO
            I=IPHES(MP)
            IF (I.EQ.MP) GOTO 240
            ZSAFE=DEL(MP)
            DEL(MP)=DEL(I)
            DEL(I)=ZSAFE
  240       CONTINUE
         END DO
         RETURN
C
C -----------------------------------------------------------
C
   55    CONTINUE
         RETURN
      END
C
C     END OF SUBROUTINE SLVSEU
C

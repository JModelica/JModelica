

      DOUBLE PRECISION FUNCTION FREALSCALAR(x)
          DOUBLE PRECISION x
          FREALSCALAR = 3.14D0 * x
      END

      SUBROUTINE FREALARRAY(x, xs, y, ys)
          DOUBLE PRECISION x(*)
          INTEGER xs
          DOUBLE PRECISION y(*)
          INTEGER ys
          do 10 i = 1, xs
              y(i) = x(xs + 1 - i)
10        continue
      END
      
      SUBROUTINE FREALMATRIX(xs1, xs2, x, y)
          INTEGER xs1,xs2
          DOUBLE PRECISION x(xs1, xs2)
          DOUBLE PRECISION y(xs1, xs2)
          do 10 i = 1, xs1
              do 11 j = 1, xs2
                  y(i,j) = x(xs1 + 1 - i, xs2 + 1 - j)
11            continue
10        continue
      END

      INTEGER FUNCTION FINTEGERSCALAR(x)
          INTEGER x
          FINTEGERSCALAR = 3 * x
      END

      SUBROUTINE FINTEGERARRAY(x, xs, y, ys)
          INTEGER x(*)
          INTEGER xs
          INTEGER y(*)
          INTEGER ys
          do 10 i = 1, xs
              y(i) = x(xs + 1 - i)
10        continue
      END

      LOGICAL FUNCTION FBOOLEANSCALAR(x)
          LOGICAL x
          FBOOLEANSCALAR = .NOT. x
      END

      SUBROUTINE FBOOLEANARRAY(x, xs, y, ys)
          LOGICAL x(*)
          INTEGER xs
          LOGICAL y(*)
          INTEGER ys
          do 10 i = 1, xs
              y(i) = .NOT. x(i)
10        continue
      END

      INTEGER FUNCTION FENUMSCALAR(x)
          INTEGER x
          FENUMSCALAR = 2
      END

      SUBROUTINE FENUMARRAY(x, xs, y, ys)
          INTEGER x(*)
          INTEGER xs
          INTEGER y(*)
          INTEGER ys
          do 10 i = 1, xs
              y(i) = x(xs + 1 - i)
10        continue
      END
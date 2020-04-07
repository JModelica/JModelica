package TestMinMax
  model TestGuess
    Real x1 (min = -1.0, max = 1.0) "box";
    Real x2 (start = -5.0, min = -10.0, max = -1.0) "underbox";
    Real x3 (start = 5.0, min = 1.0, max = 10.0) "overbox";
    Real x4 (start = -5.0, max = -1.0) "under";
    Real x5 (start = 5.0, min = 1.0) "over";
    Real x6 (start = -5.0, max = 0.0) "underzero";
    Real x7 (start = 5.0, min = 0.0) "overzero";
    Real w1 (min = 0.0, start = 0.0) "w1";
    Real w2 (max = 0.0, start = 0.0) "w2";
  equation
    der(x1) = 1;
    der(x2) = 1;
    der(x3) = 1;
    der(x4) = 1;
    der(x5) = 1;
    der(x6) = 1;
    der(x7) = 1;
    der(w1) = 0;
    der(w2) = 0;
  end TestGuess;
end TestMinMax;

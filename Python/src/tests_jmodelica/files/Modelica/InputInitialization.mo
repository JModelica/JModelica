model InputInitialization
  Real x(start=1);
  input Real u;
equation
  der(x) = x/u;
end InputInitialization;
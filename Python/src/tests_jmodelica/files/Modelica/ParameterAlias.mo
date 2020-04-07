model ParameterAlias
  parameter Real p1 = p2;
  parameter Real p2 = 3;
  Real x;
  Real y;
equation
  der(y) = x;
  x = p2;
end ParameterAlias;
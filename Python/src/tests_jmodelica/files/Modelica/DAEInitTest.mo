model DAEInitTest
  Real x1(start=3);
  Real x2(start=4);
  Real u(start=1)=1;
  parameter Real p=5;
  Real y1;
  Real y2;
  Real y3;
equation
  der(x1) = -p*x1^3 - x2^3 + sin(u);
  der(x2) = -sin(x2) - u^2;
  y1 = (x1+y2+p)^3;
  y2 = 5;
  y3 = sin(x1-y1);
end DAEInitTest;
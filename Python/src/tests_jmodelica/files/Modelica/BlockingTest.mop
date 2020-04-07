optimization BlockingTest (objective=cost(finalTime),startTime=0,finalTime=3)

  Real x[2](start={1,1},each fixed=true);
  input Real u1;
  input Real u2;
  Real y(min=-20,max=20);
  Real w1;
  Real w2;
  Real w3;
  Real w4;
  parameter Real A[2,2] = {{-1,0},{1,-2}};
  parameter Real B[2] = {1,1};
  parameter Real C[2] = {1,1};

  Real cost(start=0,fixed=true);

equation

  der(x) = A*x + B*u1;
  y = C*x + u2;
  der(cost) = y^2 + u1^2 + u2^2;
  
  w1 = x[1]*x[2];
  w2 = x[1] - x[2];

constraint
  u1 <= 0.5;
  u1 >= -0.5 - x[1](0.5)*0.3;

  w3 = x[1] + x[2];
  w4 = x[1] - x[2];
  u2(finalTime) = 0.1;
end BlockingTest;
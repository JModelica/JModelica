package LagrangeCost

model SISOLinearSystem
  parameter Integer N;
  parameter Real x0[N] = ones(N);
  parameter Real A[N,N];
  parameter Real B[N];
  parameter Real C[N];
  parameter Real D;
  Real x[N](start=x0);
  input Real u;
  output Real y;
equation
  der(x) = A*x + B*u;
  y = C*x + D*u;
end SISOLinearSystem;

optimization OptTest(objectiveIntegrand = sys.x*Q*sys.x + sys.u*R*sys.u, 
                      objective = 10*sys.x(finalTime)*sys.x(finalTime), startTime = 0, finalTime = 1)
  parameter Real A[:,:] = {{-1, 1},{0, -1}};
  parameter Real B[:] = {0,1};
  parameter Real C[:] = {1,0};
  parameter Real D = 0;
  parameter Real Q[:,:] = {{1,0},{0,1}};
  parameter Real R = 0.1;
  SISOLinearSystem sys(N=size(B,1),A=A,B=B,C=C,D=D,x(each fixed=true));
  input Real u = sys.u;
end OptTest;
 
end LagrangeCost;
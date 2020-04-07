optimization ArrayIntBoolPars_Opt (objective=1,startTime=0,finalTime=1)
  parameter Boolean B = true;
  parameter Integer N = 3;
  parameter Real A[N,N] = identity(N);
  Real x[N](each start =1,fixed=true);
  Real y(start=1,fixed=true);
equation
  der(x) = A*x/N;
  der(y) = if B then 1 else -1;	
end ArrayIntBoolPars_Opt;
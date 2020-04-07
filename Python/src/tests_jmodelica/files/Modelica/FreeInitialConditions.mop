optimization FreeInitialConditions (objective=cost(finalTime),startTime=0,finalTime=1)
  Real cost(start=0,fixed=true);
  Real x(start=1,fixed=true);
  Real u(start=0);
  input Real d_u;
equation
  der(x) = -x + u;
  der(u) = d_u;
  der(cost) = 100*x^2 + d_u^2;
constraint  
  d_u<=0.1;
  d_u>=-0.1;
end FreeInitialConditions;
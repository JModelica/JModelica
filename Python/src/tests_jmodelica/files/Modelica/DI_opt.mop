optimization DI_opt(objective=cost(finalTime),startTime=0,finalTime=2.1)

  Real x(start=1,fixed=true);
  Real v(start=0,fixed=true);
  Real cost(start=0,fixed=true);
  input Real u(min=-1,max=1);
  Real w1;
  Real w2;

equation
  
  der(x) = v;
  der(v) = u;
  der(cost) = u^2;
  w1 = x-v;
  w2 = x+v;
  
constraint
  
  x(finalTime)=0;
  v(finalTime)=0;

end DI_opt;
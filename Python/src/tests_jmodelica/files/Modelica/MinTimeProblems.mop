package MinTimeProblems
optimization MinTimeProblem1 (objective=finalTime,finalTime(free=true,start=1,initialGuess=3)=4)
  Real x(start=1,fixed=true);
  Real dx(start=0,fixed=true);
  input Real u;
equation
  der(x) = dx;
  der(dx) = u;
constraint
  u<=1; u>=-1;
  x(finalTime) = 0;
  dx(finalTime) = 0;
end MinTimeProblem1;

optimization MinTimeProblem2 (objective=-startTime,
                          startTime(free=true,initialGuess=-1)=2)
  Real x(start=1,fixed=true);
  Real dx(start=0,fixed=true);
  input Real u;
equation
  der(x) = dx;
  der(dx) = u;
constraint
  u<=1; u>=-1;
  x(finalTime) = 0;
  dx(finalTime) = 0;
end MinTimeProblem2;

optimization MinTimeProblem3 (objective=finalTime,
                          startTime(free=true,initialGuess=-1), 
                          finalTime(free=true,initialGuess)=2)
  Real x(start=1,fixed=true);
  Real dx(start=0,fixed=true);
  input Real u;
equation
  der(x) = dx;
  der(dx) = u;
constraint
  startTime=-1;
  u<=1; u>=-1;
  x(finalTime) = 0;
  dx(finalTime) = 0;
end MinTimeProblem3;

  model SecondOrder
    parameter Real w = 1;
    parameter Real z = 0.3;
    parameter Real x1_0 = 0;
    parameter Real x2_0 = 0;
    input Real u;
    Real x1(start=x1_0,fixed=true);
    Real x2(start=x2_0,fixed=true);
    Real y=x1;
  equation
    der(x1) = -2*w*z*x1 + x2;
    der(x2) = -w^2*x1 + w^2*u;
  end SecondOrder;

optimization MinTimeProblem4 (objective=finalTime,/* objectiveIntegrand=0.01*u^2,*/
finalTime(free=true,initialGuess,min=1,max=3)=2)
  SecondOrder sys(x1_0 = 1, x2_0 = 1, u = u);
  input Real u;
constraint
  sys.x1(finalTime) = 0;
  sys.x2(finalTime) = 0;
  u<=2; u>=-2;
end MinTimeProblem4;

  model VDP

    // The states
    Real x1(start=1,fixed=true);
    Real x2(start=1,fixed=true);
    
    // The control signal
    input Real u;

  equation
    der(x1) = (1 - x2^2) * x1 - x2 + u;
    der(x2) = x1;
  end VDP;

optimization MinTimeProblem5 (objective=finalTime,
finalTime(free=true,initialGuess,min=1,max=3)=2)
  VDP sys(u = u);
  input Real u;
constraint
  sys.x1(finalTime) = 0;
  sys.x2(finalTime) = 0;
  u<=2; u>=-2;
end MinTimeProblem5;

end MinTimeProblems;
package StaticOptimizationTest

  model FirstOrder
    Real x(start=2);
    output Real y(start=4) = x;
    input Real u;
    parameter Real k(start=3) = 1;
   equation
    der(x) = -x + k*u;
  end FirstOrder;

  optimization StaticOptimizationTest1(objective=(fo.y-y_meas)^2, startTime=0,finalTime=1,static=true)
     parameter Real p0(free=true) = 1;
     FirstOrder fo(k(initialGuess=3,free=true));
     parameter Real y_meas = 1.2;
  initial equation
     der(fo.x) = 0;  
  equation
     fo.u = 1;
  end StaticOptimizationTest1;

  optimization StaticOptimizationTest2(objective=(fo1.y-y_meas1)^2 + (fo2.y-y_meas2)^2, static=true)
      parameter Real k(free=true) = 1;
     FirstOrder fo1(k=k);
     FirstOrder fo2(k=k);
     parameter Real y_meas1 = 1.2;
     parameter Real y_meas2 = 1.0;
  initial equation
     der(fo1.x) = 0;  
     der(fo2.x) = 0;  
  equation
     fo1.u = 1;
     fo2.u = 1;
  end StaticOptimizationTest2;


end StaticOptimizationTest;
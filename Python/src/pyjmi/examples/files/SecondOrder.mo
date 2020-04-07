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

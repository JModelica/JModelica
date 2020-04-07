package Pendulum_pack

  model Pendulum
    parameter Real th0=0.1;
    parameter Real dth0 = 0;
    parameter Real x0=0;
    parameter Real dx0 = 0;

    Real theta(start=th0);
    Real dtheta(start=dth0);
    Real x(start=x0);
    Real dx(start=dx0);
    input Real u;

  equation
    der(theta) = dtheta;
    der(dtheta) = sin(theta) + u*cos(theta);
    der(x) = dx;
    der(dx) = u;
  end Pendulum;
  
  model PlanarPendulum
    parameter Real L = 1 "Pendulum length";
    parameter Real g= 9.81 "Acceleration due to gravity";
    Real x(start=0.4,stateSelect=StateSelect.always) "Cartesian x coordinate";
    Real y "Cartesian y coordinate";
    Real vx(start=0,fixed=true,stateSelect=StateSelect.always)
      "Velocity in x coordinate";
    Real vy(start=0) "Velocity in y coordinate";
    Real lambda "Lagrange multiplier";

    Real theta(start=acos(0.9),fixed=true);
    Real dtheta(start=0,fixed=true);
    Real ct;
    Real st;

    Real err;
  initial equation

    y = ct;

  equation

    der(x) = vx;
    der(y) = vy;
    der(vx) = lambda*x;
    der(vy) = lambda*y - g;
    x^2 + y^2 = L;

    der(theta) = dtheta;
    der(dtheta) = -g*sin(theta);
    ct = -cos(theta);
    st = sin(theta);

    err = sqrt((ct - y)^2+(st-x)^2);
    annotation (experiment(StopTime=10));
  end PlanarPendulum;

end Pendulum_pack;

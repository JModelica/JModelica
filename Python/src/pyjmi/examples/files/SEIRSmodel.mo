within ;
model SEIRSmodel

  parameter Real p1(nominal=2.78e5) = 2.78e5; //S0
  parameter Real p2 = 1.08e-1; //E0
  parameter Real p3 = 1.89e-1; //I0
  parameter Real p4(nominal=1.00e6) = 1.00e6; //N
  parameter Real p5(nominal=5) = 5.00; //L
  parameter Real p6(nominal=10e-3) = 9.59e-3; //D
  parameter Real p7(nominal=5e-3) = 5.48e-3; //M
  parameter Real p8(nominal=75) = 75; //P
  parameter Real p9(nominal=375) = 375; //beta0
  parameter Real p10(nominal=2.00e-2) = 2.00e-2;//a1
  parameter Real p11(nominal=2.00e-2) = -2.00e-2;//b1

  parameter Real R0 = p4-p3-p2-p1;
  constant Real pi = 3.14159265;

  Real S(start=p1,fixed=true,nominal=1e5);
  Real E(start=p2,fixed=true,nominal=1e3);
  Real I(start=p3,fixed=true,nominal=1e3);
  Real R(start=R0,fixed=true,nominal=7e5);

  Real Beta(start=382.5,nominal=100);
  Real N(start = 1e6,nominal=1e6);
equation
 Beta = p9*(1 + p10*cos(2*pi*time) + p11*sin(2*pi*time));

 N = S + E + I + R;
 der(S) = (1/p8)*N + (1/p5)*R - Beta*S*(I/N) - 1/p8*S;
 der(E) = Beta*S*I/N - 1/p7*E - 1/p8*E;
 der(I) = (1/p7)*E - (1/p6)*I - (1/p8)*I;
 der(R) = (1/p6)*I - (1/p5)*R - (1/p8)*R;

  annotation (uses(Modelica(version="3.2")));
end SEIRSmodel;

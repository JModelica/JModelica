package NominalTests

model NominalTest1
  Real y(start=1e4, nominal=1e4);
  Real x(start=3);
  Real z(start=10000,nominal=10000)=4;
  parameter Real p(nominal=4) =1;
equation
 der(x) = 3;
 der(y) = -y;
end NominalTest1;


model NominalTest2
  output Real x(min=-3, max=-1,nominal=-2)=-2;
end NominalTest2;


model NominalTest3
    type T1 = Real(nominal=6);
    Real x1, x2(nominal=1), x3(nominal=2), x4, x5(nominal=3), x6(nominal=4);
    T1 x7, x8(nominal=5), x9;
equation
    der(x1) = 1;
    der(x2) = 2;
    der(x3) = 3;
    x4 = 4 * time;
    x5 = 5 * time;
    x6 = 6 * time;
    der(x7) = 7;
    der(x8) = 8;
    x9 = 9 * time;
end NominalTest3;

model NominalTest4
    Real x(nominal=-2, start=1.0);
    Real y(nominal=0.0, start=1.0);
equation
    der(x) = -1;
    der(y) = -1;
end NominalTest4;

end NominalTests;

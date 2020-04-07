
model BasicSens1
    Real x(start=1);
    parameter Real d = -1;
equation
    der(x) = d*x;
end BasicSens1;

model BasicSens2
    Real x(start=1);
    input Real d(start=-1);
equation
    der(x) = d*x;
end BasicSens2;

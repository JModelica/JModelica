model SimpleTest
    "Very simple test model"
    Real x(start=1.0);
equation
    der(x) = -x;
    annotation(Documentation(info="<html>Simple exponential decay: x' = -x</html>"));
end SimpleTest;

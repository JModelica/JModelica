package ParameterEvalTests

model ParameterEval1
    parameter Real p = 1;
    parameter Real pd = p + 1;
    Real x(start=pd);
equation
    x = time;
end ParameterEval1;

end ParameterEvalTests;

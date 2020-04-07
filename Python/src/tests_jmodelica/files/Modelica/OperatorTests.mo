package OperatorTests "Some tests for operators" 

model HomotopyTest
  Real x = homotopy(time,time*2);
end HomotopyTest;

model SemiLinearTest
  Real x,y;
equation
  x = time*time - 1;
  y = semiLinear(x,3,-5);
end SemiLinearTest;

model DivTest
  Real x;
  Real y;
equation 
  x = div(time*time*10, 2);
  y = div(time*time*10, -2);
end DivTest;

model ModTest
  Real x;
  Real y;
equation 
  x = mod(time*time*10, 2);
  y = mod(time*time*10, -2);
end ModTest;

model RemTest
  Real x;
  Real y;
equation 
  x = rem(time*time*10, 2);
  y = rem(time*time*10, -2);
end RemTest;

model CeilTest
  Real x;
  Real y;
equation 
  x = 4*sin(2*Modelica.Constants.pi*time);
  y = ceil(x);
end CeilTest;

model FloorTest
  Real x;
  Real y;
equation 
  x = 4*sin(2*Modelica.Constants.pi*time);
  y = floor(x);
end FloorTest;

model IntegerTest
  Real x;
  Integer y;
equation 
  x = 4*sin(2*Modelica.Constants.pi*time);
  y = integer(x);
end IntegerTest;

model NestedTest
  Real x;
  Real y;
equation 
  x = 8*sin(2*Modelica.Constants.pi*time);
  y = integer(1.5 + floor(x/2));
end NestedTest;

model SignTest
  Real[2,2] a = {{-1,2},{3,-4}} * time;
  discrete Real b;
  Real[2,2] x;
  Real y,z;
initial equation
  b = 1;
equation 
  x = sign(a);
  y = sign(-7.9*time);
  z = sign(2*b);
  when time > 0.5 then
    b = 0;
  end when;
end SignTest;

model EdgeTest
  discrete Boolean b;
  discrete Boolean x;
  discrete Boolean y;
initial equation 
  b = false;
  x = false;
equation 
  y = edge(b);
  when {time > 0.5, time > 1.5} then
    x = edge(b);
    b = not(pre(b));
  end when;
end EdgeTest;

model ChangeTest
  discrete Boolean b;
  discrete Boolean x;
  discrete Boolean y;
initial equation 
  b = false;
  x = false;
equation 
  y = change(b);
  when {time > 0.5, time > 1.5} then
    x = change(b);
    b = not(pre(b));
  end when;
end ChangeTest;

model StringExpHelper
    function StringCompare
        input String expected;
        input String actual;
    algorithm
        assert(actual == expected, "Compare failed, expected: " + expected + ", actual: " + actual);
    end StringCompare;
    type E = enumeration(small, medium, large, xlarge);
    discrete Real realVar;
    Integer intVar = if realVar < 2.5 then 12 else 42;
    Boolean boolVar = if realVar < 2.5 then true else false;
    E enumVar = if realVar < 2.5 then E.small else E.medium;
equation
    StringCompare("42",           String(intVar));
    StringCompare("42          ", String(intVar, minimumLength=12));
    StringCompare("          42", String(intVar, minimumLength=12, leftJustified=false));
    
    StringCompare("3.14159",      String(realVar));
    StringCompare("3.14159     ", String(realVar, minimumLength=12));
    StringCompare("     3.14159", String(realVar, minimumLength=12, leftJustified=false));
    StringCompare("3.1415927",    String(realVar, significantDigits=8));
    StringCompare("3.1415927   ", String(realVar, minimumLength=12, significantDigits=8));
    StringCompare("   3.1415927", String(realVar, minimumLength=12, leftJustified=false, significantDigits=8));
    
    StringCompare("-3.14159",     String(-realVar));
    StringCompare("-3.14159    ", String(-realVar, minimumLength=12));
    StringCompare("    -3.14159", String(-realVar, minimumLength=12, leftJustified=false));
    StringCompare("-3.1415927",   String(-realVar, significantDigits=8));
    StringCompare("-3.1415927  ", String(-realVar, minimumLength=12, significantDigits=8));
    StringCompare("  -3.1415927", String(-realVar, minimumLength=12, leftJustified=false, significantDigits=8));
    
    StringCompare("false",        String(boolVar));
    StringCompare("false       ", String(boolVar, minimumLength=12));
    StringCompare("       false", String(boolVar, minimumLength=12, leftJustified=false));
    
    StringCompare("true",         String(not boolVar));
    StringCompare("true        ", String(not boolVar, minimumLength=12));
    StringCompare("        true", String(not boolVar, minimumLength=12, leftJustified=false));
    
    StringCompare("medium",       String(enumVar));
    StringCompare("medium      ", String(enumVar, minimumLength=12));
    StringCompare("      medium", String(enumVar, minimumLength=12, leftJustified=false));
end StringExpHelper;

model StringExpConstant
    extends StringExpHelper;
equation
    realVar = 3.14159265359;
end StringExpConstant;

model StringExpParameter
    extends StringExpHelper;
    parameter Real x = 3.14159265359;
equation
    realVar = x;
end StringExpParameter;


model OutOfRange
    Real t1 = time*1e300;
    Real t2 = 1 - time;
    Real x1 = exp(t1);
    Real x2 = log(t2);
    Real x3 = log10(t2);
    Real x4 = sinh(t1);
    Real x5 = cosh(t1);
    Real x6 = t1^t1;
    Real x7 = 1 / t2;
end OutOfRange;

end OperatorTests;

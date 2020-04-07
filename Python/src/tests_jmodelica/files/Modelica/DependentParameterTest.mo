model DependentParameterTest1
  parameter Real p1 = 1;
  parameter Real p2 = p1*3;
  parameter Real p3 = p2 + p4;
  parameter Real p4 = 5;
end DependentParameterTest1;

model DependentParameterTest2
  parameter Real pri = 3;
  parameter Real prd = 2*pri;
  constant Real cr = 5;
  parameter Integer pii = 4;
  parameter Integer pid = 2*pii;
  constant Integer ci = 4;
  parameter Boolean pbi = true;
  parameter Boolean pbd = false and not pbi;
  constant Boolean cb = true;
end DependentParameterTest2;
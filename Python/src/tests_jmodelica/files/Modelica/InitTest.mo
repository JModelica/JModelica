model InitTest
  Real x(start=1,fixed=true);
  Real y;
  input Real u;
equation
  der(x) = -x + u;
  x=2*y;
end InitTest;

model InitTest1
  Real x1,y1,z1;
  Real x2,y2,z2,w2;
  input Real u1;
  input Real p(start = 4);

initial equation
 der(x1) = if time>=1 then 1 elseif time>=2 then 3 else 5;
equation
 y1 - (if time>=5 then -z1 else z1) + x1 = 3;
 y1 + sin(z1) + x1 = 5 + u1 + p;
 der(x1) = -x1 + z1 * p;
 
y2 - (if time>=5 then -z2 else z1) + x1 = w2;
 y2 + sin(z2 + z1) + x2 = 5 + u1 + p - 3*w2 + der(x2);
 der(x2) = -x2 - x1 + z2 * p + w2;
 w2 + y2 + y1 + z1 + x2 = 4;

end InitTest1;

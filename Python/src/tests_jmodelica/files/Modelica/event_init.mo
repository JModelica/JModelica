model Init
  Real s1,s2,s3,s4;
  Real x(start=0);
equation 
  s1 = sin(x)+2;
  s2 = if s1>=1 then 1 else 0;
  s3 = 1/s2;
  s4 = if s3>=2 then 1 else 0;
  x^3 + 0.01*sin(x)= x + s1 + s3 + s4 - 10;
end Init;

model Diode
  Boolean off;
  Real s;
  Real u;
  Real i0;
  Real i1;
  Real i2;
  Real v1;
  Real v2;   
  parameter Real R1 = 1;
  parameter Real R2 = 1;
  parameter Real C = 1;
  Real v0;
equation
  off = s<0;
  u = v1 - v2;
  u = if off then s else 0;
  i0 = if off then 0 else s;
  R1*i0 = v0 - v1;
  i2 = v2/R2;
  i1 = i0 - i2;
  der(v2) = i1/C;
  v0 = sin(time);
end Diode;
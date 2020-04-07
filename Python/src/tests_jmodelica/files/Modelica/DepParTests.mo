package DepParTests

model DepPar1
   //[ 1.,  1.,  2.,  2.,  2.,  2.,  2.,  1.,  1.,  1.,  2.,  2.,  1.,
   //     0.,  1.,  0.,  0.]
   parameter Integer i = 1;
   parameter Integer i2 = 2*i;
   parameter Real a[N] = ones(N)*i2;
   parameter Real b[N] = a;
   parameter Integer N1 = 1;
   parameter Integer N2 = 1;
   parameter Integer N = 2;
   parameter Real r[3] = array((if i<=N then 1. else 2.) for i in 1:3);
   parameter Boolean b1 = true;
   parameter Boolean b2 = false;
   parameter Boolean b3 = b1 or b2;
   parameter Boolean b4 = b1 and b2;
end DepPar1;

function f1
  input Real x;
  output Real y;
algorithm
  y:=2*x;
end f1;

function f2
  input Real x[2];
  output Real y[2];
algorithm
  y:=2*x;
end f2;

function f2_int
  input Integer x[2];
  output Integer y[2];
algorithm
  y:=2*x;
end f2_int;


function f3
  input Real x[2];
  output Real y;
algorithm
  y:=x[1]+x[2];
end f3;

model DepPar2
  // [ 1.  4.  0.]
  parameter Real p0 = 1;
  parameter Real p = f1(f1(p0));
end DepPar2;

model DepPar3
  // [  2.   3.   4.   6.  10.   0.]
  parameter Real p0[2] = {2,3};
  parameter Real p = f3(f2(p0));
end DepPar3;

model DepPar4
  // [ 2.  3.  2.  3.  0.]
  parameter Real p0[2] = {2,3};
  parameter Real p[2] = p0;
end DepPar4;

model DepPar5
  // [ 2.  3.  4.  6.  4.  6.  0.]
  parameter Real p0[2] = {2,3};
  parameter Real p[2] = f2(p0);
end DepPar5;

model DepPar6
  // [ 2.,  3.,  4.,  6.,  4.,  6.,  4.,  6.,  4.,  6.,  0.]
  parameter Real p0[2] = {2,3};
  parameter Real p1[2] = f2(p0);
  parameter Real p2[2] = f2(p0);
end DepPar6;

model DepPar7
  // [ 2.,  3.,  4.,  6.,  4.,  6.,  0.]
  parameter Integer p0[2] = {2,3};
  parameter Integer p[2] = f2_int(p0);
end DepPar7;

model DepPar8
  //[ 2.,  1.,  3.,  0.,  1.,  1.,  0.,  0.,  0.,  1.,  1.,  1.,  0.]
  parameter Integer N1 = 2;
  parameter Integer N2 = 1;
  parameter Integer N3 = N1 + N2;
  parameter Boolean b[N3] = array((if i<=N2 then false else true) for i in 1:N3);
  Real x[N3](each start=1, fixed=b);
equation
  der(x) = -x;
end DepPar8;

  record R
    Real x;
    Real y;
  end R;

function f_r
  input R x[2];
  output R y[2];
algorithm
  y := x;
end f_r;

model DepRec1

  parameter R[2] r = {R(3,3),R(4,6)};
  parameter R[2] r2 = f_r(r);

end DepRec1;

end DepParTests;
package FunctionAR

  model UnknownArray1
    Real x[3](start={2,3,4}, each fixed=true);
    Real y[3](each fixed=true);
  equation
    der(y) = F_UA1(x);
    der(x) = y;
  end UnknownArray1;

  function F_UA1
    input Real[:] x;
    output Real[size(x,1)] y;
  protected 
    Real[size(x,1)] z;
    Real w;
  algorithm
    z := x;
    w := x * z;
    for i in 1:size(x,1) loop
      y[i] := - x[i] * w * i;
    end for;
  end F_UA1;
  
  model FuncRecord1
    Real x(start=2, fixed=true);
    Real y(start=0, fixed=true);
    R_FR1 r(b={1,2});
  equation
    der(x) = -F_FR1(x, r);
    der(y) = x;
    r.a = y;
  end FuncRecord1;

  record R_FR1
    Real a;
    Real b[2];
  end R_FR1;

  function F_FR1
    input Real x;
    input R_FR1 r;
    output Real y;
  algorithm
    y := x * (r.a + r.b * r.b);
  end F_FR1;

end FunctionAR;

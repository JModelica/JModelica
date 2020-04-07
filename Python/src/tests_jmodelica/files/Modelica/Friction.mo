model Friction
 parameter Real m = 1;
 parameter Real f0 = 1;
 parameter Real f1 = 1;
 Real v;
 Real a;
 Real f;
 Real u;
 Real sa;
 Boolean startFor(start=false);
 Boolean startBack(start=false);
 Integer mode(start=2);
 Real dummy;
equation 
 der(dummy) = 1;
 u = 2*sin(time);
 m*der(v) = u - f;
 der(v) = a;
 startFor = pre(mode)==2 and sa > 1;
 startBack = pre(mode) == 2 and sa < -1;
 a = if pre(mode) == 1 or startFor then sa-1 else 
     if pre(mode) == 3 or startBack then 
     sa + 1 else 0;
 f = if pre(mode) == 1 or startFor then 
     f0 + f1*v else 
     if pre(mode) == 3 or startBack then 
     -f0 + f1*v else f0*sa;
 mode=if (pre(mode) == 1 or startFor)
      and v>0 then 1 else 
      if (pre(mode) == 3 or startBack)
          and v<0 then 3 else 2;
end Friction;
















model Friction2
 parameter Real m = 1;
 parameter Real f0 = 1;
 parameter Real f1 = 1;
 Real v;
 Real a;
 Real f;
 Real u;
 Real sa;
 Boolean startFor;
 Boolean startBack;
 Mode mode;
 type Mode = enumeration(
      Forward,
      Stuck,
      Backward);
equation 
 u = 2*sin(time);
 m*der(v) = u - f;
 der(v) = a;
 startFor = pre(mode)==Mode.Stuck and sa > 1;
 startBack = pre(mode) == Mode.Stuck and sa < -1;
 a = if pre(mode) == Mode.Forward or startFor then sa-1 else 
     if pre(mode) == Mode.Backward or startBack then 
     sa + 1 else 0;
 f = if pre(mode) == Mode.Forward or startFor then 
     f0 + f1*v else 
     if pre(mode) == Mode.Backward or startBack then 
     -f0 + f1*v else f0*sa;
 mode=if (pre(mode) == Mode.Forward or startFor)
      and v>0 then Mode.Forward else 
      if (pre(mode) == Mode.Backward or startBack)
          and v<0 then Mode.Backward else Mode.Stuck;
end Friction2;

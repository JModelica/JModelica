package Reinit

model ReinitWriteback
    //Declaration(s)
  output Integer os( start = 0);
  output Modelica.SIunits.Time timer;


algorithm 
  when pre(os) == 0 and timer >= 10 then
    os :=1;
  elsewhen pre(os) == 1 and timer >= 10 then
    os :=0;
  end when;

equation 
  when pre(os) <> os then
    reinit(timer, 0);
  end when;

  if os == 0 then
    der(timer) = 0.5;
  else
    der(timer) = 1;
  end if;
end  ReinitWriteback;

model ReinitBlock
 Boolean b1(start=true);
 Boolean b2;
 Real x;
 Real h(start = 1.0);
 Real v(start = 0.0);
equation 
 der(h) = v;
 der(v) = if b1 then -9.81 else 0.0;
 when b2 then
  reinit(v,-x*pre(v));
 end when;
algorithm 
 b2 := h <= 0;
 when {b2, b2 and v <= 0} then
  if edge(b2) then
   b1 := pre(v) <= 0;
   x := 0.7;
  else
   b1 := false;
   x := 0.0;
  end if;
 end when;
end  ReinitBlock;

end Reinit;

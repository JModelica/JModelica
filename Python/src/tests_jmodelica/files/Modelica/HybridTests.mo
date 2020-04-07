package HybridTests

model WhenEqu2

Real xx(start=2);
discrete Real x; 
discrete Real y; 
discrete Boolean w(start=true); 
discrete Boolean v(start=true); 
discrete Boolean z(start=true); 
equation
der(xx) = -x; 
when y > 2 and pre(z) then 
w = false; 
end when; 
when y > 2 and z then 
v = false; 
end when; 
when x > 2 then 
z = false; 
end when; 
when sample(0,1) then 
x = pre(x) + 1.1; 
y = pre(y) + 1.1; 
end when; 
end WhenEqu2;

model WhenEqu3
Real xx(start=2);
discrete Real x; 
discrete Real y; 
discrete Boolean w(start=true); 
discrete Boolean v(start=true); 
discrete Boolean z(start=true);
discrete Boolean b1; 
equation
der(xx) = -x; 
when b1 and pre(z) then 
w = false; 
end when; 
when b1 and z then 
v = false; 
end when; 
when b1 then 
z = false; 
end when; 
when sample(0,1) then 
x = pre(x) + 1.1; 
y = pre(y) + 1.1; 
end when; 
b1 = y>2;
end WhenEqu3;

model WhenEqu5 
Real x(start = 1); 
discrete Real a(start = 1.0); 
discrete Boolean z(start = false); 
discrete Boolean y(start = false); 
discrete Boolean h1,h2; 
equation 
der(x) = a * x; 
h1 = x >= 2; 
h2 = der(x) >= 4; 
when h1 then 
y = true; 
end when; 
when y then 
a = 2; 
end when; 
when h2 then 
z = true; 
end when; 
end WhenEqu5; 

/* This model is not yet treated correctly
model WhenEqu7 
 discrete Real x(start=0);
 Real dummy;
equation
 der(dummy) = 0;
 when dummy>-1 then
   x = pre(x) + 1;
 end when;
end WhenEqu7; 
*/

model WhenEqu8 
 discrete Real x,y;
 Real dummy;
equation
 der(dummy) = 0;
 when sample(0,1/3) then
   x = pre(x) + 1;
 end when;
 when sample(0,2/3) then
   y = pre(y) + 1;
 end when;
end WhenEqu8; 

model WhenEqu9 

 Real x,ref;
 discrete Real I;
 discrete Real u;

 parameter Real K = 1;
 parameter Real Ti = 1;
 parameter Real h = 0.1;

equation
 der(x) = -x + u;
 when sample(0,h) then
   I = pre(I) + h*(ref-x);
   u = K*(ref-x) + 1/Ti*I;
 end when;
 ref = if time <1 then 0 else 1;
end WhenEqu9; 

model WhenEqu10 

 discrete Real x,y;
 Real dummy;
equation
 der(dummy) = 0;
 when {sample(0,1), sample(0.1,1)} then
   x = pre(x) + 1;
 end when;
 when sample(0,2/3) then
   y = pre(y) + 1;
 end when;

end WhenEqu10; 

model WhenEqu11
	function F
		input Real x;
		output Real y1;
		output Real y2;
	algorithm
		y1 := 1 + x;
		y2 := 2 + x;
	end F;
	Real x,y;
	equation
	when sample(0,1) then
	  (x,y) = F(time);
	end when;
end WhenEqu11;


model WhenEqu12
 discrete Real x;
 Real dummy;
equation
 der(dummy) = 0;
 when sample(0,1e-10) then
   x = pre(x) + 1;
 end when;
end WhenEqu12; 

model ZeroOrderHold1

  Modelica.Blocks.Discrete.ZeroOrderHold sampler(samplePeriod=0.1);
  Modelica.Blocks.Sources.ExpSine expSine;
equation
  connect(expSine.y,sampler.u);

end ZeroOrderHold1;

model WhenFunction1
  function F
    input Real x[2];
    output Real y[2];
  algorithm
    y := x*2;
  end F;
  Real x[2](start=0);
equation
  when sample(0,1) then
    x = F({time, 2*time});
  end when;

end WhenFunction1;

model IfTest1
    input Real u;
    Real x;
equation
    if u > 1 then
        der(x) = 1;
    else
        der(x) = -1;
    end if;
end IfTest1;

end HybridTests;

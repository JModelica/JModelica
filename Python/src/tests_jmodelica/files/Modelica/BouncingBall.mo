model BouncingBall "the bouncing ball model" 
  parameter Real g=9.82;  // gravitational acc. 
  parameter Real c=0.90;  // elasticity constant 
  Real h(start=10, fixed=true), v(start=0, fixed=true);
equation 
  der(h) = v; 
  der(v) = -g; 
  when h < 0 then
    reinit(v, -c * v); 
  end when;
end BouncingBall;

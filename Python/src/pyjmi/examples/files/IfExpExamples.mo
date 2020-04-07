model IfExpExamples

  model IfExpExample1
    Real x,u;
  equation
    u = noEvent(if time<=Modelica.Constants.pi/2 then sin(time) elseif 
              time<=Modelica.Constants.pi then 1 else sin(time-Modelica.Constants.pi/2));
    der(x) = u;

  end IfExpExample1;

  model IfExpExample2
    Real x,u;
  equation
    u = if time<=Modelica.Constants.pi/2 then sin(time) elseif 
              time<=Modelica.Constants.pi then 1 else sin(time-Modelica.Constants.pi/2);
    der(x) = u;

  end IfExpExample2;




end IfExpExamples;
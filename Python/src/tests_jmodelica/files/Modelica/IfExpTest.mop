optimization IfExpTest(objective=cost(finalTime),startTime=0.0,finalTime=3.0)

 Real x(start=0,fixed=true);
 Real u;
 Real cost(start=0,fixed=true);
equation
 u = noEvent(if time<=Modelica.Constants.pi/2 then sin(time) else 1);
 der(x) = -x + u;
 der(cost) = x^2;
end IfExpTest;

optimization IfExpTestEvents(objective=cost(finalTime),startTime=0.0,finalTime=3.0)

 Real x(start=0,fixed=true);
 Real u;
 Real cost(start=0,fixed=true);
equation
 u = if time<=Modelica.Constants.pi/2 then sin(time) else 1;
 der(x) = -x + u;
 der(cost) = x^2;
end IfExpTestEvents;
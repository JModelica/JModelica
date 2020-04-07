optimization DependentParameterTest2(objectiveIntegrand = (x-2)^2 + u^2 + p1^2 + (p2-3)^2 + (p1-3)^2,
                         objective=x(finalTime)^2*10 + p2^2)
 parameter Real p1(free=true) = 1;
 parameter Real p2 = p1;
 parameter Real p3 = 1;  
 parameter Real p4(min=-1,max=1,free=true) = 1;
 Real w = p2;
 Real z;
 Real x(start=0,fixed=true);
 input Real u;
equation
 der(x) = -x + u*(p4^2+1)  + p3^2;
constraint
 z = p1^3;
 x <= 4;
 x(finalTime) <=5;
 x(finalTime) = 1;
end DependentParameterTest2;


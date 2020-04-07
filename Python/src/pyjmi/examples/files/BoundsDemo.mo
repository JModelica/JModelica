within SimpleModels;
model BoundsDemo

Real x_1(start = -4.5, min = -6, max = 6);
Real x_2(start = 1.0, min = -4, max = 4);


Real dummy(start = 0);

initial equation
-(x_1)^2 -(x_2)^2 + 25 = 0;
(x_1 - 5)^2 + (x_2 - 2)^2 - 4 = 0;

equation

der(dummy) = sin(time);
der(x_1) = 0;
der(x_2) = 0;

end BoundsDemo;

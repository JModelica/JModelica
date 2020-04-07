within SimpleModels;
model BouncingBounds

Real x_1(start = 0.1, nominal = 100);
Real x_2(start = 0.1);

Real dummy(start = 0);

initial equation
(x_1)^2 + (x_2)^2 = 36 annotation(__Modelon(nominal = 3.0));
(x_1-10)^2 + (x_2)^2 = 36;


equation

der(dummy) = sin(time);
der(x_1) = 0;
der(x_2) = 0;

end BouncingBounds;

model DiscreteVar
  Real x(start=3) = 3;
  Real y(start=1);
equation
  when sample(0,1) then
    y = pre(y) + 1;
  end when;
end DiscreteVar;
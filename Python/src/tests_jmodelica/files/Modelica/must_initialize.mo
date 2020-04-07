model must_initialize

    // The states
    output Real x(start=0);
    Real y(start=5);

  equation
    der(y) = -y+x;
    x=3;

end must_initialize;

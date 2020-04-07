package VDP_pack

  model VDP

    // Parameters
    parameter Real p1 = 1;             // Parameter 1

    // The states
    Real x1(start=0);
    Real x2(start=1);

    // The control signal
    input Real u;

  equation
    der(x1) = (1 - x2^2) * x1 - x2 + u;
    der(x2) = p1 * x1;
  end VDP;

end VDP_pack;
